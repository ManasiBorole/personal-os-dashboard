-- Document manager: folders and files
create table if not exists public.document_folders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  parent_id uuid references public.document_folders(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  folder_id uuid references public.document_folders(id) on delete set null,
  name text not null,
  file_name text not null,
  storage_path text not null,
  public_url text,
  mime_type text not null default 'application/octet-stream',
  file_type text not null default 'other',
  size_bytes bigint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists document_folders_user_id_idx on public.document_folders (user_id);
create index if not exists document_folders_parent_id_idx on public.document_folders (parent_id);
create index if not exists documents_user_id_idx on public.documents (user_id);
create index if not exists documents_folder_id_idx on public.documents (folder_id);
create index if not exists documents_file_type_idx on public.documents (file_type);

alter table public.document_folders enable row level security;
alter table public.documents enable row level security;

create policy "Users manage own document folders"
  on public.document_folders for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users manage own documents"
  on public.documents for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('documents', 'documents', true)
on conflict (id) do nothing;

create policy "Users upload own documents"
  on storage.objects for insert
  with check (
    bucket_id = 'documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users read own documents"
  on storage.objects for select
  using (
    bucket_id = 'documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users delete own documents"
  on storage.objects for delete
  using (
    bucket_id = 'documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
