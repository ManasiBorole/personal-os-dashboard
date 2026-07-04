-- CRM module: companies and contacts
create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  industry text default '',
  phone text,
  email text,
  address text,
  website text,
  tags jsonb not null default '[]'::jsonb,
  notes text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  company_id uuid references public.companies(id) on delete set null,
  first_name text not null,
  last_name text default '',
  phone text,
  email text,
  address text,
  category text not null default 'other',
  tags jsonb not null default '[]'::jsonb,
  visiting_card_path text,
  visiting_card_url text,
  contact_notes jsonb not null default '[]'::jsonb,
  follow_ups jsonb not null default '[]'::jsonb,
  meeting_history jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists companies_user_id_idx on public.companies (user_id);
create index if not exists companies_name_idx on public.companies (name);
create index if not exists contacts_user_id_idx on public.contacts (user_id);
create index if not exists contacts_company_id_idx on public.contacts (company_id);
create index if not exists contacts_category_idx on public.contacts (category);

alter table public.companies enable row level security;
alter table public.contacts enable row level security;

create policy "Users manage own companies"
  on public.companies for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users manage own contacts"
  on public.contacts for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Storage bucket for visiting cards (run in Supabase dashboard or storage migration)
insert into storage.buckets (id, name, public)
values ('visiting-cards', 'visiting-cards', true)
on conflict (id) do nothing;

create policy "Users upload own visiting cards"
  on storage.objects for insert
  with check (
    bucket_id = 'visiting-cards'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users read own visiting cards"
  on storage.objects for select
  using (
    bucket_id = 'visiting-cards'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users delete own visiting cards"
  on storage.objects for delete
  using (
    bucket_id = 'visiting-cards'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
