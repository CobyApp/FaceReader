-- FaceReader: monsters leaderboard + RLS for publishable-key clients.
-- Idempotent: safe to re-run in SQL Editor.

create extension if not exists "uuid-ossp";

create table if not exists public.monsters (
  id uuid primary key default uuid_generate_v4(),
  nickname text not null,
  image_url text not null,
  grade int not null,
  score int not null,
  year text not null,
  month text not null,
  day text not null
);

create index if not exists monsters_score_idx on public.monsters (score desc);
create index if not exists monsters_ymd_idx on public.monsters (year, month, day);

alter table public.monsters enable row level security;

-- Drop legacy anon-named or existing publishable policies, then recreate
drop policy if exists "monsters_select_anon" on public.monsters;
drop policy if exists "monsters_insert_anon" on public.monsters;
drop policy if exists "monsters_delete_anon" on public.monsters;
drop policy if exists "monsters_select_publishable" on public.monsters;
drop policy if exists "monsters_insert_publishable" on public.monsters;
drop policy if exists "monsters_delete_publishable" on public.monsters;

create policy "monsters_select_publishable" on public.monsters for select using (true);
create policy "monsters_insert_publishable" on public.monsters for insert with check (true);
create policy "monsters_delete_publishable" on public.monsters for delete using (true);
