-- ============================================
-- FIX: ALLOW TEACHERS TO ASSIGN ANY STUDENT
-- ============================================
-- Problem: SELECT RLS only shows teachers their already-assigned students,
-- so UPDATE can't find unassigned students either.
-- Solution: Create a SECURITY DEFINER function that bypasses RLS.

-- Drop existing policies first
DROP POLICY IF EXISTS "Teachers can assign students to themselves" ON students;
DROP POLICY IF EXISTS "Admins can update students" ON students;

-- Option 1: Broaden SELECT policy so teachers can see ALL students
DROP POLICY IF EXISTS "Teachers can view all students" ON students;
CREATE POLICY "Teachers can view all students" ON students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'teacher'
        )
    );

-- Re-create UPDATE policy for teachers
CREATE POLICY "Teachers can update students" ON students
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'teacher'
        )
    );

-- Add UPDATE policy for admins
DROP POLICY IF EXISTS "Admins can update students" ON students;
CREATE POLICY "Admins can update students" ON students
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- Option 2: Also create an RPC function as backup
CREATE OR REPLACE FUNCTION assign_student_to_teacher(
    p_student_id UUID,
    p_teacher_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE students
    SET assigned_teacher_id = p_teacher_id,
        updated_at = NOW()
    WHERE id = p_student_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Student with id % not found', p_student_id;
    END IF;
END;
$$;

-- Verify
SELECT tablename, policyname, cmd 
FROM pg_policies 
WHERE tablename = 'students';
