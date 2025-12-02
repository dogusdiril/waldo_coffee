-- ================================================
-- WALDO COFFEE - Supabase Database Schema
-- ================================================
-- Bu SQL'i Supabase Dashboard > SQL Editor'da çalıştır
-- ================================================

-- 1. PROFILES TABLE (Kullanıcı profilleri)
-- ================================================
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text not null,
  full_name text not null,
  role text not null default 'employee' check (role in ('admin', 'employee')),
  avatar_url text,
  is_approved boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Mevcut kullanıcıları onayla (eğer tablo zaten varsa bu komutu çalıştır)
-- ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_approved boolean default false;
-- UPDATE public.profiles SET is_approved = true WHERE is_approved IS NULL;

-- RLS (Row Level Security) aktif et
alter table public.profiles enable row level security;

-- Herkes profilleri okuyabilir
create policy "Profiles are viewable by everyone" 
  on public.profiles for select 
  using (true);

-- Kullanıcı kendi profilini güncelleyebilir
create policy "Users can update own profile" 
  on public.profiles for update 
  using (auth.uid() = id);

-- Yeni kayıt için insert izni
create policy "Users can insert own profile" 
  on public.profiles for insert 
  with check (auth.uid() = id);

-- 2. TASKS TABLE (Görevler)
-- ================================================
create table if not exists public.tasks (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  priority integer not null default 0 check (priority >= 0 and priority <= 2),
  is_recurring boolean default false,
  assigned_to uuid references public.profiles(id) on delete set null,
  status text not null default 'pending' check (status in ('pending', 'in_progress', 'completed')),
  created_by uuid references public.profiles(id) on delete set null not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  completed_at timestamp with time zone,
  due_date timestamp with time zone
);

-- RLS aktif et
alter table public.tasks enable row level security;

-- Herkes görevleri okuyabilir
create policy "Tasks are viewable by authenticated users" 
  on public.tasks for select 
  to authenticated
  using (true);

-- Admin görev oluşturabilir
create policy "Admins can create tasks" 
  on public.tasks for insert 
  to authenticated
  with check (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role = 'admin'
    )
  );

-- Herkes görevleri güncelleyebilir (atama, tamamlama için)
create policy "Authenticated users can update tasks" 
  on public.tasks for update 
  to authenticated
  using (true);

-- Admin görevleri silebilir
create policy "Admins can delete tasks" 
  on public.tasks for delete 
  to authenticated
  using (
    exists (
      select 1 from public.profiles 
      where id = auth.uid() and role = 'admin'
    )
  );

-- 3. INDEXES (Performans için)
-- ================================================
create index if not exists idx_tasks_status on public.tasks(status);
create index if not exists idx_tasks_assigned_to on public.tasks(assigned_to);
create index if not exists idx_tasks_created_at on public.tasks(created_at);
create index if not exists idx_tasks_priority on public.tasks(priority);
create index if not exists idx_profiles_role on public.profiles(role);

-- 4. FUNCTIONS (Yardımcı fonksiyonlar)
-- ================================================

-- Günlük tekrarlayan görevleri oluşturan fonksiyon
create or replace function create_recurring_tasks()
returns void as $$
begin
  insert into public.tasks (title, description, priority, is_recurring, status, created_by)
  select 
    title,
    description,
    priority,
    true,
    'pending',
    created_by
  from public.tasks
  where is_recurring = true
    and created_at::date < current_date
    and not exists (
      select 1 from public.tasks t2 
      where t2.title = tasks.title 
        and t2.is_recurring = true 
        and t2.created_at::date = current_date
    );
end;
$$ language plpgsql security definer;

-- 5. İLK ADMIN KULLANICI
-- ================================================
-- NOT: Önce Supabase Authentication'dan bir kullanıcı oluştur,
-- sonra o kullanıcıyı admin yap:
--
-- insert into public.profiles (id, email, full_name, role)
-- values ('KULLANICI_UUID', 'admin@waldocoffee.com', 'Admin', 'admin');

-- ================================================
-- KURULUM SONRASI YAPILACAKLAR:
-- ================================================
-- 1. Supabase Dashboard > Authentication > Users'dan ilk kullanıcıyı oluştur
-- 2. Yukarıdaki INSERT ile o kullanıcıyı admin yap
-- 3. Flutter uygulamasındaki app_constants.dart dosyasına:
--    - SUPABASE_URL
--    - SUPABASE_ANON_KEY
--    bilgilerini ekle
-- ================================================

