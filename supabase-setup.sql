-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  role TEXT CHECK (role IN ('admin', 'student')) NOT NULL,
  username TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create materials table
CREATE TABLE materials (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  photos TEXT[] DEFAULT '{}',
  questions JSONB DEFAULT '[]',
  tasks JSONB DEFAULT '[]',
  created_by UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create attendance table
CREATE TABLE attendance (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  session_date DATE NOT NULL,
  present BOOLEAN DEFAULT FALSE,
  grade TEXT CHECK (grade IN ('A', 'B', 'C')) DEFAULT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, session_date)
);

-- Create task_submissions table
CREATE TABLE task_submissions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  material_id UUID REFERENCES materials(id) ON DELETE CASCADE,
  task_id TEXT NOT NULL,
  answer TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  submitted_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, material_id, task_id)
);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON materials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_attendance_updated_at BEFORE UPDATE ON attendance FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to check if user is admin (bypasses RLS)
CREATE OR REPLACE FUNCTION is_admin(user_id UUID) RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (SELECT 1 FROM users WHERE id = user_id AND role = 'admin');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_submissions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert users" ON users
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update users" ON users
  FOR UPDATE USING (is_admin(auth.uid()));

-- RLS Policies for materials table
CREATE POLICY "Everyone can view materials" ON materials
  FOR SELECT USING (true);

CREATE POLICY "Admins can insert materials" ON materials
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update materials" ON materials
  FOR UPDATE USING (is_admin(auth.uid()));

-- RLS Policies for attendance table
CREATE POLICY "Users can view their own attendance" ON attendance
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all attendance" ON attendance
  FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert attendance" ON attendance
  FOR INSERT WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update attendance" ON attendance
  FOR UPDATE USING (is_admin(auth.uid()));

-- RLS Policies for task_submissions table
CREATE POLICY "Users can view their own submissions" ON task_submissions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all submissions" ON task_submissions
  FOR SELECT USING (is_admin(auth.uid()));

CREATE POLICY "Users can insert their own submissions" ON task_submissions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can update submissions" ON task_submissions
  FOR UPDATE USING (is_admin(auth.uid()));

-- Insert default admin user (you'll need to set a password via Supabase Auth)
-- Note: This will be created through the app interface
-- INSERT INTO users (email, role, username) VALUES ('admin@primaextra.com', 'admin', 'admin');
