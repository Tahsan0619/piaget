-- ============================================
-- FIX: ADMIN RLS POLICIES FOR ALL TABLES
-- ============================================
-- Problem: Admin dashboard shows 0 for all stats because
-- RLS policies don't allow admins to SELECT from tables.
-- 
-- We use a SECURITY DEFINER function (runs as DB owner, bypasses RLS)
-- to check the user's role from the users table safely.
-- ============================================

-- ============================================
-- HELPER: SECURITY DEFINER function to get role (bypasses RLS)
-- ============================================
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.users WHERE auth_id = auth.uid() LIMIT 1;
$$;

-- ============================================
-- 1. USERS TABLE
-- ============================================
-- Drop ALL existing select/update/delete policies to start clean
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "Teachers can view all users" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Enable read access for all users" ON users;
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Allow all select" ON users;

-- Users can see their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth_id = auth.uid());

-- Admins can see ALL users (uses SECURITY DEFINER function - no recursion)
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (public.get_user_role() = 'admin');

-- Teachers can see all users (needed for student info lookups)
CREATE POLICY "Teachers can view all users" ON users
    FOR SELECT USING (public.get_user_role() = 'teacher');

-- Admins can update any user
CREATE POLICY "Admins can update all users" ON users
    FOR UPDATE USING (public.get_user_role() = 'admin');

-- Admins can delete users
CREATE POLICY "Admins can delete users" ON users
    FOR DELETE USING (public.get_user_role() = 'admin');

-- Anyone authenticated can insert (for signup)
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- ============================================
-- 2. STUDENTS TABLE
-- ============================================
DROP POLICY IF EXISTS "Admins can view all students" ON students;
DROP POLICY IF EXISTS "Students can view own record" ON students;
DROP POLICY IF EXISTS "Teachers can view all students" ON students;
DROP POLICY IF EXISTS "Teachers can update students" ON students;
DROP POLICY IF EXISTS "Admins can update students" ON students;

CREATE POLICY "Admins can view all students" ON students
    FOR SELECT USING (public.get_user_role() = 'admin');

CREATE POLICY "Teachers can view all students" ON students
    FOR SELECT USING (public.get_user_role() = 'teacher');

CREATE POLICY "Students can view own record" ON students
    FOR SELECT USING (
        id IN (SELECT id FROM public.users WHERE auth_id = auth.uid())
    );

CREATE POLICY "Teachers can update students" ON students
    FOR UPDATE USING (public.get_user_role() = 'teacher');

CREATE POLICY "Admins can update students" ON students
    FOR UPDATE USING (public.get_user_role() = 'admin');

-- ============================================
-- 3. TEACHERS TABLE
-- ============================================
DROP POLICY IF EXISTS "Admins can view all teachers" ON teachers;
DROP POLICY IF EXISTS "Teachers can view own record" ON teachers;

CREATE POLICY "Admins can view all teachers" ON teachers
    FOR SELECT USING (public.get_user_role() = 'admin');

CREATE POLICY "Teachers can view own record" ON teachers
    FOR SELECT USING (
        id IN (SELECT id FROM public.users WHERE auth_id = auth.uid())
    );

-- ============================================
-- 4. ASSESSMENT_SESSIONS TABLE
-- ============================================
DROP POLICY IF EXISTS "Admins can view all assessments" ON assessment_sessions;
DROP POLICY IF EXISTS "Students can view own assessments" ON assessment_sessions;
DROP POLICY IF EXISTS "Teachers can view student assessments" ON assessment_sessions;

CREATE POLICY "Admins can view all assessments" ON assessment_sessions
    FOR SELECT USING (public.get_user_role() = 'admin');

CREATE POLICY "Students can view own assessments" ON assessment_sessions
    FOR SELECT USING (
        student_id IN (SELECT id FROM public.users WHERE auth_id = auth.uid())
    );

CREATE POLICY "Teachers can view student assessments" ON assessment_sessions
    FOR SELECT USING (public.get_user_role() = 'teacher');

-- ============================================
-- 5. STUDENT_PROGRESS TABLE
-- ============================================
DROP POLICY IF EXISTS "Admins can view all progress" ON student_progress;

CREATE POLICY "Admins can view all progress" ON student_progress
    FOR SELECT USING (public.get_user_role() = 'admin');

-- ============================================
-- 6. CLASSES TABLE
-- ============================================
DROP POLICY IF EXISTS "Admins can view all classes" ON classes;

CREATE POLICY "Admins can view all classes" ON classes
    FOR SELECT USING (public.get_user_role() = 'admin');

-- ============================================
-- 7. CLASS_MEMBERS TABLE
-- ============================================
DROP POLICY IF EXISTS "Admins can view all class members" ON class_members;

CREATE POLICY "Admins can view all class members" ON class_members
    FOR SELECT USING (public.get_user_role() = 'admin');

-- ============================================
-- VERIFY: Check all policies
-- ============================================
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename IN ('users', 'students', 'teachers', 'assessment_sessions', 'student_progress', 'classes', 'class_members')
ORDER BY tablename, policyname;
