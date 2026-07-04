-- Extend meetings table for full meeting management
alter table public.meetings add column if not exists notes text default '';
alter table public.meetings add column if not exists follow_up text default '';
alter table public.meetings add column if not exists reminder_at timestamptz;
alter table public.meetings add column if not exists status text not null default 'scheduled';
alter table public.meetings add column if not exists participants jsonb not null default '[]'::jsonb;
alter table public.meetings add column if not exists attachments jsonb not null default '[]'::jsonb;

create index if not exists meetings_status_idx on public.meetings (status);
