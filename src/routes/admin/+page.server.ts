import type { PageServerLoad, Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ locals: { supabase, safeGetSession } }) => {
    const { session } = await safeGetSession();

    // Redirect to login if not authenticated
    if (!session) {
        throw redirect(303, '/login');
    }

    // Fetch all items
    const { data: items, error: itemsError } = await supabase
        .from('items')
        .select('*')
        .order('created_at', { ascending: false });

    if (itemsError) {
        console.error('Error fetching items:', itemsError);
    }

    // Calculate statistics
    const totalItems = items?.length || 0;
    const checkedOut = items?.filter(item => item.status === 'checked_out').length || 0;
    const retired = items?.filter(item => item.status === 'retired').length || 0;

    return {
        items: items || [],
        stats: {
            totalItems,
            checkedOut,
            retired,
            activeUsers: 0, // Placeholder - would need to query profiles table
        },
    };
};

export const actions = {
    create: async ({ request, locals: { supabase } }) => {
        const formData = await request.formData();
        const title = formData.get('title') as string;
        const description = formData.get('description') as string;
        const location = formData.get('location') as string;
        const status = formData.get('status') as string;
        const tag_label = formData.get('tag_label') as string;
        const checked_out_to = formData.get('checked_out_to') as string;
        const tags = (formData.get('tags') as string)
            ?.split(',')
            .map((tag) => tag.trim())
            .filter((tag) => tag.length > 0);

        const { data, error } = await supabase
            .from('items')
            .insert({
                title,
                description,
                location,
                status,
                tag_label,
                checked_out_to: status === 'checked_out' ? checked_out_to : null,
                tags,
            })
            .select()
            .single();

        if (error) {
            console.error('Supabase create error:', error);
            return fail(500, {
                error: error.message,
            });
        }

        return {
            success: true,
            item: data,
        };
    },

    update: async (event) => {
        const session = await event.locals.safeGetSession();
        if (!session) {
            throw redirect(303, '/login');
        }

        const formData = await event.request.formData();
        const id = formData.get('id') as string;
        const title = formData.get('title') as string;
        const description = formData.get('description') as string;
        const location = formData.get('location') as string;
        const status = formData.get('status') as string;
        const tag_label = formData.get('tag_label') as string;
        const checked_out_to = formData.get('checked_out_to') as string;
        const tags = (formData.get('tags') as string)
            ?.split(',')
            .map((tag) => tag.trim())
            .filter((tag) => tag.length > 0);

        const { data, error } = await event.locals.supabase
            .from('items')
            .update({
                title,
                description,
                location,
                status,
                tag_label,
                checked_out_to: status === 'checked_out' ? checked_out_to : null,
                tags,
            })
            .eq('id', id)
            .select()
            .single();

        if (error) {
            console.error('Error updating item:', error);
            return fail(500, { error: error.message || 'Failed to update item' });
        }

        return { success: true };
    },

    delete: async ({ request, locals: { supabase } }) => {
        const formData = await request.formData();
        const id = formData.get('id') as string;

        const { error } = await supabase
            .from('items')
            .delete()
            .eq('id', id);

        if (error) {
            console.error('Error deleting item:', error);
            return fail(500, { error: error.message || 'Failed to delete item' });
        }
        return { success: true };
    },
} satisfies Actions;
