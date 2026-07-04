-- Calendar module schema
create table if not exists public.calendar_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text default '',
  event_type text not null default 'meeting',
  start_time timestamptz not null,
  end_time timestamptz not null,
  is_all_day boolean not null default false,
  location text,
  reminder_at timestamptz,
  attendee_count integer not null default 0,
  linked_task_id uuid references public.tasks(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists calendar_events_user_id_idx on public.calendar_events (user_id);
create index if not exists calendar_events_start_time_idx on public.calendar_events (start_time);
create index if not exists calendar_events_event_type_idx on public.calendar_events (event_type);

alter table public.calendar_events enable row level security;

create policy "Users manage own calendar events"
  on public.calendar_events for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Meetings table for dashboard compatibility
create table if not exists public.meetings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  start_time timestamptz not null,
  duration_minutes integer not null default 30,
  location text,
  attendee_count integer not null default 0,
  agenda text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists meetings_user_id_idx on public.meetings (user_id);
create index if not exists meetings_start_time_idx on public.meetings (start_time);

alter table public.meetings enable row level security;

create policy "Users manage own meetings"
  on public.meetings for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
