-- Enterprise project management schema
create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text default '',
  status text not null default 'planning',
  client_name text default '',
  client_email text default '',
  client_company text default '',
  client_phone text default '',
  budget_amount numeric(12, 2) not null default 0,
  budget_currency text not null default 'USD',
  budget_spent numeric(12, 2) not null default 0,
  start_date timestamptz,
  end_date timestamptz,
  progress integer not null default 0 check (progress >= 0 and progress <= 100),
  completed_tasks integer not null default 0,
  total_tasks integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_members (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null,
  email text not null default '',
  role text not null default 'Member',
  created_at timestamptz not null default now()
);

create table if not exists public.project_notes (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  title text not null,
  content text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_files (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  name text not null,
  storage_path text not null,
  mime_type text not null default 'application/octet-stream',
  size_bytes bigint not null default 0,
  uploaded_at timestamptz not null default now()
);

alter table public.tasks add column if not exists project_id uuid references public.projects(id) on delete set null;

create index if not exists projects_user_id_idx on public.projects (user_id);
create index if not exists project_members_project_id_idx on public.project_members (project_id);
create index if not exists project_notes_project_id_idx on public.project_notes (project_id);
create index if not exists project_files_project_id_idx on public.project_files (project_id);
create index if not exists tasks_project_id_idx on public.tasks (project_id);

alter table public.projects enable row level security;
alter table public.project_members enable row level security;
alter table public.project_notes enable row level security;
alter table public.project_files enable row level security;

create policy "Users manage own projects"
  on public.projects for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users manage project members via project ownership"
  on public.project_members for all
  using (exists (
    select 1 from public.projects p
    where p.id = project_members.project_id and p.user_id = auth.uid()
  ));

create policy "Users manage project notes via project ownership"
  on public.project_notes for all
  using (exists (
    select 1 from public.projects p
    where p.id = project_notes.project_id and p.user_id = auth.uid()
  ));

create policy "Users manage project files via project ownership"
  on public.project_files for all
  using (exists (
    select 1 from public.projects p
    where p.id = project_files.project_id and p.user_id = auth.uid()
  ));
