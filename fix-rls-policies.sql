-- Fix for circular dependency in RLS policies causing 500 errors
-- This script updates existing policies without recreating tables

-- Create function to check if user is admin (bypasses RLS)
CREATE OR REPLACE FUNCTION is_admin(user_id UUID) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM users WHERE id = user_id AND role = 'admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing policies that cause circular dependencies
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can insert users" ON users;
DROP POLICY IF EXISTS "Admins can update users" ON users;
DROP POLICY IF EXISTS "Admins can insert materials" ON materials;
DROP POLICY IF EXISTS "Admins can update materials" ON materials;
DROP POLICY IF EXISTS "Admins can view all attendance" ON attendance;
DROP POLICY IF EXISTS "Admins can insert attendance" ON attendance;
DROP POLICY IF EXISTS "Admins can update attendance" ON attendance;
DROP POLICY IF EXISTS "Admins can view all submissions" ON task_submissions;
DROP POLICY IF EXISTS "Admins can update submissions" ON task_submissions;

-- Recreate policies using the is_admin function
CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert users" ON users
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update users" ON users
  FOR UPDATE USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert materials" ON materials
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update materials" ON materials
  FOR UPDATE USING (is_admin(auth.uid()));

CREATE POLICY "Admins can view all attendance" ON attendance
  FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert attendance" ON attendance
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update attendance" ON attendance
  FOR UPDATE USING (is_admin(auth.uid()));

CREATE POLICY "Admins can view all submissions" ON task_submissions
  FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Admins can update submissions" ON task_submissions
  FOR UPDATE USING (is_admin(auth.uid()));
