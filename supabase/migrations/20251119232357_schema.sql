-- Enable Row Level Security
alter default privileges in schema public grant all on tables to postgres, anon, authenticated, service_role;

-- Items Table
create table items (
  id uuid default gen_random_uuid() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  description text,
  tags text[],
  status text default 'checked_in' check (status in ('checked_in', 'checked_out', 'retired')),
  location text,
  notes text,
  image_url text
);

-- Profiles Table (extends auth.users)
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  full_name text,
  role text default 'student' check (role in ('student', 'instructor', 'admin')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Transactions/Logs Table
create table transactions (
  id uuid default gen_random_uuid() primary key,
  item_id uuid references items(id) on delete set null,
  user_id uuid references auth.users(id) on delete set null,
  action text not null check (action in ('check_out', 'check_in', 'maintenance_start', 'maintenance_end', 'note_added')),
  notes text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies (Basic)
alter table items enable row level security;
alter table profiles enable row level security;
alter table transactions enable row level security;

-- Public read access for items
create policy "Items are viewable by everyone" on items
  for select using (true);

-- Only admins/instructors can modify items
create policy "Admins can insert items" on items
  for insert with check (auth.uid() in (select id from profiles where role in ('instructor', 'admin')));

create policy "Admins can update items" on items
  for update using (auth.uid() in (select id from profiles where role in ('instructor', 'admin')));

create policy "Admins can delete items" on items
  for delete using (auth.uid() in (select id from profiles where role in ('instructor', 'admin')));

-- Profiles are viewable by everyone (or just authenticated?)
create policy "Profiles are viewable by everyone" on profiles
  for select using (true);

-- Users can update their own profile
create policy "Users can update own profile" on profiles
  for update using (auth.uid() = id);

-- Transactions viewable by admins
create policy "Transactions viewable by admins" on transactions
  for select using (auth.uid() in (select id from profiles where role in ('instructor', 'admin')));

-- Transactions viewable by owner (if applicable)
create policy "Transactions viewable by owner" on transactions
  for select using (auth.uid() = user_id);

-- Function to handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, new.raw_user_meta_data->>'full_name', 'student');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user signup
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
