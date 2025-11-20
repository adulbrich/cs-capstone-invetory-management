<script lang="ts">
    import { Button } from "$lib/components/ui/button";
    import {
        Card,
        CardContent,
        CardDescription,
        CardFooter,
        CardHeader,
        CardTitle,
    } from "$lib/components/ui/card";
    import { Input } from "$lib/components/ui/input";
    import { Label } from "$lib/components/ui/label";
    import { goto, invalidateAll } from "$app/navigation";

    let { data } = $props();
    let { supabase } = $derived(data);

    let email = $state("");
    let password = $state("");
    let loading = $state(false);
    let error = $state("");

    async function handleLogin() {
        loading = true;
        error = "";
        const { data: authData, error: err } =
            await supabase.auth.signInWithPassword({
                email,
                password,
            });

        if (err) {
            error = err.message;
            loading = false;
        } else {
            // Invalidate to refresh session data
            await invalidateAll();
            // Redirect to admin
            goto("/admin");
        }
    }
</script>

<div class="flex items-center justify-center min-h-[calc(100vh-200px)]">
    <Card class="w-full max-w-md">
        <CardHeader>
            <CardTitle class="text-2xl">Login</CardTitle>
            <CardDescription>
                Enter your email below to login to your account.
            </CardDescription>
        </CardHeader>
        <CardContent class="grid gap-4">
            {#if error}
                <div class="text-red-500 text-sm">{error}</div>
            {/if}
            <div class="grid gap-2">
                <Label for="email">Email</Label>
                <Input
                    id="email"
                    type="email"
                    placeholder="m@example.com"
                    bind:value={email}
                    required
                />
            </div>
            <div class="grid gap-2">
                <Label for="password">Password</Label>
                <Input
                    id="password"
                    type="password"
                    bind:value={password}
                    required
                />
            </div>
        </CardContent>
        <CardFooter>
            <Button class="w-full" onclick={handleLogin} disabled={loading}>
                {loading ? "Logging in..." : "Sign in"}
            </Button>
        </CardFooter>
    </Card>
</div>
