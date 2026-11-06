-- ======================================================================
-- QUAD SQUAD — STEAKS DAY 2026  ·  full schema + seed  (apply in one go)
-- Project: odpexghueerscbvdkjjy  ·  region ap-southeast-2 (Sydney)
-- ======================================================================

-- ---------- schema ----------
create table if not exists couples (
  id int primary key,
  label text not null
);

create table if not exists players (
  id int primary key,
  first_name text not null,
  surname text,
  display_name text not null,
  gender text not null check (gender in ('M','F')),
  couple_id int references couples(id),
  is_admin boolean default false,
  is_prez boolean default false,
  photo_url text,
  sort_order int
);

create table if not exists races (
  id int primary key,
  track text not null,
  race_no int not null,
  name text not null,
  distance text,
  grade text,
  jump_time timestamptz,
  sort_order int,
  eligible boolean default true,
  pod_nominated boolean default false,
  status text default 'upcoming',          -- upcoming | locked | resulted
  result_win int,
  result_places int[] default '{}',
  resulted_at timestamptz
);

create table if not exists runners (
  id bigint generated always as identity primary key,
  race_id int references races(id),
  number int not null,
  horse_name text not null,
  scratched boolean default false,
  unique(race_id, number)
);

create table if not exists bets (
  id bigint generated always as identity primary key,
  player_id int references players(id),
  race_id int references races(id),
  runner_number int,
  horse_name text,
  bet_type text not null,                  -- individual | pick_of_day
  stake numeric not null default 10,
  odds numeric,
  status text default 'open',              -- open | won | lost | placed | scratched
  points numeric default 0,
  payout numeric default 0,
  created_at timestamptz default now(),
  unique(player_id, race_id, bet_type)
);

create table if not exists pod_assignments (
  player_id int primary key references players(id),
  race_id int references races(id)
);

create table if not exists quaddies (
  id int primary key,
  key text unique not null,                -- boys_flem | girls_flem | rosehill_mixed
  name text not null,
  track text,
  gender_scope text,                       -- M | F | ALL
  leg_race_ids int[] not null,
  stake numeric,
  style text                               -- split | all_pick
);

create table if not exists quaddie_groups (
  quaddie_id int references quaddies(id),
  player_id int references players(id),
  grp text,                                -- first | last
  primary key (quaddie_id, player_id)
);

create table if not exists quaddie_entries (
  id bigint generated always as identity primary key,
  quaddie_id int references quaddies(id),
  player_id int references players(id),
  leg_index int not null,                  -- 1..4
  runner_number int,
  created_at timestamptz default now(),
  unique(quaddie_id, player_id, leg_index)
);

create table if not exists feature_votes (
  player_id int primary key references players(id),
  gender text,
  runner_number int,
  created_at timestamptz default now()
);

create table if not exists feature_picks (
  gender text primary key,                 -- M | F
  runner_number int,
  locked boolean default false
);

create table if not exists group_bets (
  id int primary key,
  key text unique not null,
  label text not null,
  category text not null,                  -- feature | getout | mystery
  gender_scope text,                       -- M | F | ALL
  track text,
  race_id int references races(id),
  runner_number int,
  bet_mode text,                           -- ew | win
  stake numeric,
  odds numeric,
  status text default 'open',              -- open | won | placed | lost
  points numeric default 0,
  created_at timestamptz default now()
);

create table if not exists settings (
  key text primary key,
  value jsonb
);

-- ---------- permissions (trusted-friends app: open policies) ----------
grant usage on schema public to anon, authenticated;
grant all on all tables in schema public to anon, authenticated;
grant all on all sequences in schema public to anon, authenticated;
alter default privileges in schema public grant all on tables to anon, authenticated;
alter default privileges in schema public grant all on sequences to anon, authenticated;

do $$
declare t text;
begin
  foreach t in array array['couples','players','races','runners','bets','pod_assignments',
    'quaddies','quaddie_groups','quaddie_entries','feature_votes','feature_picks','group_bets','settings']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists allow_all on public.%I', t);
    execute format('create policy allow_all on public.%I for all to anon, authenticated using (true) with check (true)', t);
  end loop;
end $$;

-- ---------- realtime ----------
do $$
begin
  perform 1;
  begin
    alter publication supabase_realtime add table
      bets, races, runners, group_bets, quaddie_entries, quaddie_groups,
      feature_picks, feature_votes, players, pod_assignments;
  exception when duplicate_object then null;
  end;
  -- settings carries Group P&L + quaddie returns, which must push live too
  begin
    alter publication supabase_realtime add table settings;
  exception when duplicate_object then null;
  end;
end $$;

-- ======================================================================
-- SEED
-- ======================================================================

insert into couples (id,label) values
 (1,'Gerard & Amy'),(2,'Liam & Casey'),(3,'Dane & Bec'),(4,'Tim & Jodie'),
 (5,'Glen & Eva'),(6,'Corey & Megan'),(7,'Joel & Casey'),(8,'Blake & Elly')
on conflict (id) do nothing;

insert into players (id,first_name,surname,display_name,gender,couple_id,is_admin,is_prez,sort_order) values
 (1 ,'Gerard','O''Connor','Gerard'      ,'M',1,false,false,1),
 (2 ,'Amy'   ,null       ,'Amy'         ,'F',1,false,false,2),
 (3 ,'Liam'  ,'Mason'    ,'Liam'        ,'M',2,true ,false,3),
 (4 ,'Casey' ,'Mason'    ,'Casey Mason' ,'F',2,false,false,4),
 (5 ,'Dane'  ,'Mason'    ,'Dane'        ,'M',3,false,false,5),
 (6 ,'Bec'   ,null       ,'Bec'         ,'F',3,false,false,6),
 (7 ,'Tim'   ,'Franzini' ,'Tim'         ,'M',4,false,false,7),
 (8 ,'Jodie' ,null       ,'Jodie'       ,'F',4,false,false,8),
 (9 ,'Glen'  ,'Tolley'   ,'Glen'        ,'M',5,false,false,9),
 (10,'Eva'   ,null       ,'Eva'         ,'F',5,false,false,10),
 (11,'Corey' ,'Smith'    ,'Corey'       ,'M',6,false,false,11),
 (12,'Megan' ,null       ,'Megan'       ,'F',6,false,false,12),
 (13,'Joel'  ,'Moore'    ,'Joel'        ,'M',7,false,false,13),
 (14,'Casey' ,'Moore'    ,'Casey Moore' ,'F',7,false,false,14),
 (15,'Blake' ,'Lennard'  ,'Blake'       ,'M',8,true ,true ,15),
 (16,'Elly'  ,null       ,'Elly'        ,'F',8,false,false,16)
on conflict (id) do nothing;

-- races (jump times in Melbourne AEDT, +11)
insert into races (id,track,race_no,name,distance,grade,jump_time,sort_order,eligible,pod_nominated) values
 (104,'Flemington',4 ,'Fisher Stakes'         ,'1200m','Listed','2026-11-07T14:30:00+11:00',1 ,true,true ),
 (205,'Rosehill'  ,5 ,'Singapore Pools'       ,'1400m','Bm78'  ,'2026-11-07T14:50:00+11:00',2 ,true,false),
 (105,'Flemington',5 ,'Matriarch Stakes'      ,'2000m','G2'    ,'2026-11-07T15:10:00+11:00',3 ,true,true ),
 (206,'Rosehill'  ,6 ,'Golden Gift'           ,'1100m','Listed','2026-11-07T15:30:00+11:00',4 ,true,false),
 (106,'Flemington',6 ,'VRC Champions Sprint'  ,'1200m','G1'    ,'2026-11-07T15:50:00+11:00',5 ,true,true ),
 (207,'Rosehill'  ,7 ,'Hot Danish Stakes'     ,'1400m','G2'    ,'2026-11-07T16:10:00+11:00',6 ,true,false),
 (107,'Flemington',7 ,'VRC Champions Mile'    ,'1600m','G1'    ,'2026-11-07T16:30:00+11:00',7 ,true,true ),
 (208,'Rosehill'  ,8 ,'Five Diamonds'         ,'1800m','G3'    ,'2026-11-07T16:50:00+11:00',8 ,true,false),
 (108,'Flemington',8 ,'TAB Champions Stakes'  ,'2000m','G1'    ,'2026-11-07T17:10:00+11:00',9 ,true,true ),
 (209,'Rosehill'  ,9 ,'Grant Burge'           ,'1100m','Bm78'  ,'2026-11-07T17:25:00+11:00',10,true,true ),
 (109,'Flemington',9 ,'HKJC World Pool Grand' ,'1100m','Bm80'  ,'2026-11-07T17:50:00+11:00',11,true,true ),
 (210,'Rosehill'  ,10,'Kia Ora Bloodlines'    ,'1200m','Bm78'  ,'2026-11-07T18:05:00+11:00',12,true,true )
on conflict (id) do nothing;

insert into quaddies (id,key,name,track,gender_scope,leg_race_ids,stake,style) values
 (1,'boys_flem'     ,'Boys'' Flemington Quaddie','Flemington','M'  ,'{106,107,108,109}',125,'split'),
 (2,'girls_flem'    ,'Girls'' Flemington Quaddie','Flemington','F' ,'{106,107,108,109}',125,'split'),
 (3,'rosehill_mixed','Rosehill Mixed Quaddie'  ,'Rosehill'  ,'ALL','{207,208,209,210}',200,'all_pick')
on conflict (id) do nothing;

insert into feature_picks (gender,runner_number,locked) values ('M',null,false),('F',null,false)
on conflict (gender) do nothing;

insert into group_bets (id,key,label,category,gender_scope,track,race_id,bet_mode,stake) values
 (1,'feature_boys'     ,'Boys Feature — Champions Stakes' ,'feature','M','Flemington',108,'ew' ,100),
 (2,'feature_girls'    ,'Girls Feature — Champions Stakes','feature','F','Flemington',108,'ew' ,100),
 (3,'getout_boys'      ,'Boys Get Out of Jail — Flem R9'  ,'getout' ,'M','Flemington',109,'win',25 ),
 (4,'getout_girls'     ,'Girls Get Out of Jail — Rose R10','getout' ,'F','Rosehill'  ,210,'win',25 ),
 (5,'mystery_boys_melb','Boys Mystery — Melbourne'        ,'mystery','M','Flemington',null,'win',25 ),
 (6,'mystery_boys_syd' ,'Boys Mystery — Sydney'           ,'mystery','M','Rosehill'  ,null,'win',25 ),
 (7,'mystery_girls_melb','Girls Mystery — Melbourne'      ,'mystery','F','Flemington',null,'win',25 ),
 (8,'mystery_girls_syd','Girls Mystery — Sydney'          ,'mystery','F','Rosehill'  ,null,'win',25 )
on conflict (id) do nothing;

insert into settings (key,value) values
 ('event' ,'{"name":"Quad Squad — Steaks Day 2026","date":"2026-11-07","start":"2026-11-07T14:30:00+11:00"}'),
 ('config','{"individual_stake":10,"individual_count":5,"pod_stake":25}'),
 ('pnl'   ,'{"staked":2000,"returned":0}')
on conflict (key) do nothing;
