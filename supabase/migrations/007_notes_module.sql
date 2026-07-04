-- Notes module
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default '',
  content text default '',
  note_type text not null default 'text',
  checklist jsonb not null default '[]'::jsonb,
  category text not null default 'other',
  tags jsonb not null default '[]'::jsonb,
  images jsonb not null default '[]'::jsonb,
  documents jsonb not null default '[]'::jsonb,
  is_pinned boolean not null default false,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists notes_user_id_idx on public.notes (user_id);
create index if not exists notes_category_idx on public.notes (category);
create index if not exists notes_is_pinned_idx on public.notes (is_pinned);
create index if not exists notes_is_archived_idx on public.notes (is_archived);
create index if not exists notes_updated_at_idx on public.notes (updated_at desc);

alter table public.notes enable row level security;

create policy "Users manage own notes"
  on public.notes for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('note-attachments', 'note-attachments', true)
on conflict (id) do nothing;

create policy "Users upload own note attachments"
  on storage.objects for insert
  with check (
    bucket_id = 'note-attachments'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users read own note attachments"
  on storage.objects for select
  using (
    bucket_id = 'note-attachments'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users delete own note attachments"
  on storage.objects for delete
  using (
    bucket_id = 'note-attachments'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
