import { supabase } from '$lib/supabaseClient';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async () => {
    const { data: items, error } = await supabase
        .from('items')
        .select('*')
        .neq('status', 'retired')
        .order('title', { ascending: true });

    if (error) {
        console.error('Error fetching items:', error);
        return { items: [] };
    }

    return { items: items || [] };
};
