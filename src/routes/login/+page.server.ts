import type { PageServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ locals: { safeGetSession } }) => {
    const { session } = await safeGetSession();

    // Redirect to admin if already authenticated
    if (session) {
        throw redirect(303, '/admin');
    }

    return {};
};
