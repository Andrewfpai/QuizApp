-- Recall sync database. Run this once in Supabase: SQL Editor → New query → paste → Run.
-- Every quiz and every attempt is one row. Deleted ones stay as tombstones (deleted = true)
-- so the delete reaches your other devices.

create table if not exists public.items (
  user_id    uuid not null default auth.uid() references auth.users (id) on delete cascade,
  id         text not null,
  kind       text not null check (kind in ('quiz', 'attempt')),
  data       jsonb,
  updated_at bigint not null,                              -- set by the device that made the change (ms)
  deleted    boolean not null default false,
  synced_at  timestamptz not null default clock_timestamp(), -- set by the server; devices pull by this
  primary key (user_id, id)
);
create index if not exists items_user_synced on public.items (user_id, synced_at);

-- Each signed-in user can only see and change their own rows.
alter table public.items enable row level security;
drop policy if exists "own items" on public.items;
create policy "own items" on public.items for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
grant select, insert, update, delete on public.items to authenticated;

-- Devices push their changes through this. A row is only overwritten by a newer version,
-- so an old offline edit can't clobber a newer one from another device.
create or replace function public.push_items(items jsonb)
returns void
language sql
security invoker
set search_path = public
as $$
  insert into public.items as t (user_id, id, kind, data, updated_at, deleted, synced_at)
  select auth.uid(), x.id, x.kind, x.data, x.updated_at, coalesce(x.deleted, false), clock_timestamp()
  from jsonb_to_recordset(items) as x (id text, kind text, data jsonb, updated_at bigint, deleted boolean)
  on conflict (user_id, id) do update
    set kind = excluded.kind,
        data = excluded.data,
        updated_at = excluded.updated_at,
        deleted = excluded.deleted,
        synced_at = clock_timestamp()
    where t.updated_at < excluded.updated_at;
$$;
revoke execute on function public.push_items(jsonb) from public, anon;
grant execute on function public.push_items(jsonb) to authenticated;
