<script lang="ts">
  import { Badge } from "$lib/components/ui/badge";
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
  import { Separator } from "$lib/components/ui/separator";
  import { Search, Filter } from "@lucide/svelte";

  let { data } = $props();

  let searchQuery = $state("");
  let statusFilter = $state("all");

  // Filter items based on search and status
  let filteredItems = $derived(
    (data?.items || []).filter((item) => {
      const matchesSearch =
        item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.description?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.tags?.some((tag) =>
          tag.toLowerCase().includes(searchQuery.toLowerCase()),
        );
      const matchesStatus =
        statusFilter === "all" || item.status === statusFilter;
      return matchesSearch && matchesStatus;
    }),
  );

  function getStatusColor(status: string) {
    switch (status) {
      case "checked_in":
        return "bg-green-500 hover:bg-green-600";
      case "checked_out":
        return "bg-yellow-500 hover:bg-yellow-600";
      case "retired":
        return "bg-gray-500 hover:bg-gray-600";
      default:
        return "bg-gray-500 hover:bg-gray-600";
    }
  }

  function getStatusLabel(status: string) {
    switch (status) {
      case "checked_in":
        return "Available";
      case "checked_out":
        return "Checked Out";
      case "retired":
        return "Retired";
      default:
        return status;
    }
  }
</script>

<div class="space-y-6">
  <div
    class="flex flex-col md:flex-row md:items-center md:justify-between gap-4"
  >
    <div>
      <h1 class="text-3xl font-bold tracking-tight">Inventory</h1>
      <p class="text-muted-foreground">
        Browse available hardware for your capstone project.
      </p>
    </div>
    <div class="flex items-center gap-2">
      <div class="relative w-full md:w-64">
        <Search
          class="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground"
        />
        <Input
          type="search"
          placeholder="Search..."
          class="pl-8"
          bind:value={searchQuery}
        />
      </div>
      <Button variant="outline" size="icon">
        <Filter class="h-4 w-4" />
        <span class="sr-only">Filter</span>
      </Button>
    </div>
  </div>

  <Separator />

  <div class="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
    {#each filteredItems as item (item.id)}
      <Card class="flex flex-col h-full">
        <CardHeader>
          <div class="flex justify-between items-start gap-2">
            <CardTitle class="line-clamp-1" title={item.title}>
              {item.title}
            </CardTitle>
            <Badge class={getStatusColor(item.status)}
              >{getStatusLabel(item.status)}</Badge
            >
          </div>
          <CardDescription class="line-clamp-2">
            {item.description}
          </CardDescription>
        </CardHeader>
        <CardContent class="flex-grow">
          <div class="flex flex-wrap gap-1">
            {#each item.tags as tag}
              <Badge variant="secondary" class="text-xs">{tag}</Badge>
            {/each}
          </div>
        </CardContent>
        <CardFooter>
          <Button
            class="w-full"
            variant={item.status === "checked_in" ? "default" : "secondary"}
            disabled={item.status !== "checked_in"}
          >
            {item.status === "checked_in" ? "Request Item" : "Unavailable"}
          </Button>
        </CardFooter>
      </Card>
    {/each}
  </div>

  {#if filteredItems.length === 0}
    <div class="text-center py-12">
      <p class="text-muted-foreground text-lg">
        No items found matching your criteria.
      </p>
      <Button
        variant="link"
        onclick={() => {
          searchQuery = "";
          statusFilter = "all";
        }}>Clear filters</Button
      >
    </div>
  {/if}
</div>
