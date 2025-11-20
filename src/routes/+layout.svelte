<script lang="ts">
	import "./layout.css";
	import * as NavigationMenu from "$lib/components/ui/navigation-menu";
	import { invalidate } from "$app/navigation";
	import { onMount } from "svelte";

	let { data, children } = $props();
	let { supabase, session } = $derived(data);

	onMount(() => {
		const { data: authData } = supabase.auth.onAuthStateChange(
			(event, _session) => {
				if (_session?.expires_at !== session?.expires_at) {
					invalidate("supabase:auth");
				}
			},
		);

		return () => authData.subscription.unsubscribe();
	});
</script>

<div class="min-h-screen bg-background">
	<header class="border-b">
		<div class="container mx-auto px-4 py-4">
			<NavigationMenu.Root>
				<NavigationMenu.List>
					<NavigationMenu.Item>
						<NavigationMenu.Link href="/">
							Search Inventory
						</NavigationMenu.Link>
					</NavigationMenu.Item>
					<NavigationMenu.Item>
						<NavigationMenu.Link href="/admin">
							Manage Inventory
						</NavigationMenu.Link>
					</NavigationMenu.Item>
					{#if !session}
						<NavigationMenu.Item>
							<NavigationMenu.Link href="/login">
								Login
							</NavigationMenu.Link>
						</NavigationMenu.Item>
					{/if}
				</NavigationMenu.List>
			</NavigationMenu.Root>
		</div>
	</header>

	<main class="container mx-auto px-4 py-8">
		{@render children()}
	</main>
</div>
