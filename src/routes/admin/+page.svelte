<script lang="ts">
  import {
    Card,
    CardContent,
    CardHeader,
    CardTitle,
  } from "$lib/components/ui/card";
  import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
  } from "$lib/components/ui/table";
  import * as Sheet from "$lib/components/ui/sheet";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import { Label } from "$lib/components/ui/label";
  import { Textarea } from "$lib/components/ui/textarea";
  import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
  } from "$lib/components/ui/select";
  import { Badge } from "$lib/components/ui/badge";
  import {
    Package,
    Users,
    AlertCircle,
    CheckCircle2,
    Plus,
  } from "@lucide/svelte";
  import { enhance } from "$app/forms";
  import { invalidateAll } from "$app/navigation";

  let { data } = $props();

  // Sheet state
  let isSheetOpen = $state(false);
  let editingItem: any = $state(null);

  // Form fields
  let title = $state("");
  let description = $state("");
  let location = $state("");
  let status = $state("checked_in");
  let selectValue = $state("available"); // Mapped value for Select component
  let tag_label = $state("");
  let checked_out_to = $state("");
  let tags = $state("");

  function openEditSheet(item: any) {
    editingItem = item;
    title = item.title;
    description = item.description || "";
    location = item.location || "";
    status = item.status;
    // Map checked_in to available to avoid key collision in Select
    selectValue = item.status === "checked_in" ? "available" : item.status;
    tag_label = item.tag_label || "";
    checked_out_to = item.checked_out_to || "";
    tags = item.tags?.join(", ") || "";
    isSheetOpen = true;
  }

  function openAddSheet() {
    editingItem = null;
    title = "";
    description = "";
    location = "";
    status = "checked_in";
    selectValue = "available";
    tag_label = "";
    checked_out_to = "";
    tags = "";
    isSheetOpen = true;
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
  <div class="flex items-center justify-between">
    <h1 class="text-3xl font-bold tracking-tight">Admin Dashboard</h1>
    <Button onclick={openAddSheet}>
      <Plus class="mr-2 h-4 w-4" />
      Add Item
    </Button>
  </div>

  <!-- Statistics Cards -->
  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">Total Items</CardTitle>
        <Package class="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">{data?.stats?.totalItems || 0}</div>
        <p class="text-xs text-muted-foreground">Across all categories</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">Checked Out</CardTitle>
        <CheckCircle2 class="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">{data?.stats?.checkedOut || 0}</div>
        <p class="text-xs text-muted-foreground">Active loans</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">Retired Items</CardTitle>
        <AlertCircle class="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">{data?.stats?.retired || 0}</div>
        <p class="text-xs text-muted-foreground">Out of circulation</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader
        class="flex flex-row items-center justify-between space-y-0 pb-2"
      >
        <CardTitle class="text-sm font-medium">Active Users</CardTitle>
        <Users class="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div class="text-2xl font-bold">
          {data?.stats?.activeUsers || "N/A"}
        </div>
        <p class="text-xs text-muted-foreground">Students & Instructors</p>
      </CardContent>
    </Card>
  </div>

  <!-- Data Table -->
  <Card>
    <CardHeader>
      <CardTitle>Inventory Items</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Title</TableHead>
              <TableHead>Tag Label</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Location</TableHead>
              <TableHead>Tags</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {#each data?.items || [] as item (item.id)}
              <TableRow
                class="cursor-pointer hover:bg-muted/50"
                onclick={() => openEditSheet(item)}
              >
                <TableCell class="font-medium">{item.title}</TableCell>
                <TableCell>{item.tag_label || "-"}</TableCell>
                <TableCell>
                  <Badge
                    variant={item.status === "checked_in"
                      ? "default"
                      : "secondary"}
                  >
                    {getStatusLabel(item.status)}
                  </Badge>
                </TableCell>
                <TableCell>{item.location || "N/A"}</TableCell>
                <TableCell class="max-w-[200px] truncate">
                  {item.tags?.join(", ") || "None"}
                </TableCell>
              </TableRow>
            {/each}
          </TableBody>
        </Table>
      </div>
    </CardContent>
  </Card>
</div>

<!-- Edit/Add Item Sheet -->
<Sheet.Root bind:open={isSheetOpen}>
  <Sheet.Content class="overflow-y-auto p-6">
    <Sheet.Header class="p-0">
      <Sheet.Title>{editingItem ? "Edit Item" : "Add New Item"}</Sheet.Title>
      <Sheet.Description>
        Make changes to the inventory item here. Click save when you're done.
      </Sheet.Description>
    </Sheet.Header>

    <form
      method="POST"
      action="?/{editingItem ? 'update' : 'create'}"
      use:enhance={() => {
        return async ({ result }) => {
          console.log("Form result:", result);
          if (result.type === "success") {
            isSheetOpen = false;
            await invalidateAll();
          } else if (result.type === "failure") {
            console.error("Form action failed:", result.data);
            alert(`Error: ${result.data?.error || "Failed to save item"}`);
          }
        };
      }}
    >
      {#if editingItem}
        <input type="hidden" name="id" value={editingItem.id} />
      {/if}

      <div class="grid gap-4 py-4">
        <div class="grid gap-2">
          <Label for="title">Title</Label>
          <Input id="title" name="title" bind:value={title} required />
        </div>
        <div class="grid gap-2">
          <Label for="tag_label">Tag Label</Label>
          <Input
            id="tag_label"
            name="tag_label"
            bind:value={tag_label}
            placeholder="Optional"
          />
        </div>
        <div class="grid gap-2">
          <Label for="description">Description</Label>
          <Textarea
            id="description"
            name="description"
            bind:value={description}
          />
        </div>
        <div class="grid gap-2">
          <Label for="location">Location</Label>
          <Input id="location" name="location" bind:value={location} />
        </div>
        <div class="grid gap-2">
          <Label for="status">Status</Label>
          <input
            type="hidden"
            name="status"
            value={selectValue === "available" ? "checked_in" : selectValue}
          />
          <Select type="single" bind:value={selectValue}>
            <SelectTrigger>
              {selectValue === "available"
                ? "Available"
                : selectValue === "checked_out"
                  ? "Checked Out"
                  : "Retired"}
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="available" label="Available"
                >Available</SelectItem
              >
              <SelectItem value="checked_out" label="Checked Out"
                >Checked Out</SelectItem
              >
              <SelectItem value="retired" label="Retired">Retired</SelectItem>
            </SelectContent>
          </Select>
        </div>
        {#if selectValue === "checked_out"}
          <div class="grid gap-2">
            <Label for="checked_out_to">Checked Out To</Label>
            <Input
              id="checked_out_to"
              name="checked_out_to"
              bind:value={checked_out_to}
              required
              placeholder="Name or Contact Info"
            />
          </div>
        {/if}
        <div class="grid gap-2">
          <Label for="tags">Tags</Label>
          <Input
            id="tags"
            name="tags"
            bind:value={tags}
            placeholder="Comma separated"
          />
        </div>
      </div>

      <Sheet.Footer>
        <Button type="submit">Save changes</Button>
      </Sheet.Footer>
    </form>
  </Sheet.Content>
</Sheet.Root>
