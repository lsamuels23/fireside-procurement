-- Procurement Tracker — Supabase table setup
-- Run once in your existing project: Dashboard → SQL Editor → New query → paste → Run.
-- This only creates a new table; nothing already in the project is touched.

create table if not exists public.procurement_items (
  id         text primary key,
  data       jsonb       not null,
  updated_at timestamptz not null default now()
);

alter table public.procurement_items enable row level security;

-- Table-level privileges. RLS decides WHICH ROWS a role may touch; GRANT
-- decides whether it may touch the table at all. Both are required — an RLS
-- policy alone yields "permission denied for table procurement_items".
grant usage on schema public to anon;
grant select, insert, update, delete on public.procurement_items to anon;

-- ⚠ WIDE OPEN ON PURPOSE: anyone who has the site link can read, edit and
-- delete every row. That was the accepted trade-off for now. When you want to
-- lock it down, drop this policy and require an authenticated role instead.
drop policy if exists "public full access" on public.procurement_items;
create policy "public full access"
  on public.procurement_items
  for all
  to anon
  using (true)
  with check (true);

-- Powers the live-update subscription so open tabs refresh for each other.
do $$
begin
  alter publication supabase_realtime add table public.procurement_items;
exception
  when duplicate_object then null;
end $$;
