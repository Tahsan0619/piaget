-- =====================================================
-- MindTrack Piaget Assessment - Supabase Database Schema
-- =====================================================
-- This schema supports Student, Teacher, and Admin roles
-- with full assessment tracking and management capabilities
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ENUMS
-- =====================================================

-- User role types
CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');

-- Criterion assessment status
CREATE TYPE criterion_status AS ENUM ('achieved', 'developing', 'not_yet_achieved');

-- Assessment question response types
CREATE TYPE response_type AS ENUM ('yes_no', 'multiple_choice', 'short_answer');

-- Cognitive stages based on Piaget's theory
CREATE TYPE cognitive_stage AS ENUM (
    'sensorimotor',           -- 0-2 years
    'preoperational',         -- 2-7 years
    'concrete_operational',   -- 7-11 years
    'formal_operational'      -- 11+ years
);

-- =====================================================
-- TABLES
-- =====================================================

-- -------------------------
-- Users Table (Authentication linked)
-- -------------------------
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role user_role NOT NULL DEFAULT 'student',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    
    -- Profile fields
    phone TEXT,
    avatar_url TEXT,
    date_of_birth DATE,
    
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- -------------------------
-- Students Table (Extended profile for students)
-- -------------------------
CREATE TABLE students (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    student_id TEXT UNIQUE NOT NULL, -- School/Institution ID
    grade_level TEXT,
    class_name TEXT,
    age INTEGER,
    assigned_teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
    parent_email TEXT,
    parent_phone TEXT,
    special_needs TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_age CHECK (age >= 0 AND age <= 25)
);

-- -------------------------
-- Teachers Table (Extended profile for teachers)
-- -------------------------
CREATE TABLE teachers (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    teacher_id TEXT UNIQUE NOT NULL,
    department TEXT,
    specialization TEXT,
    qualification TEXT,
    experience_years INTEGER,
    is_verified BOOLEAN DEFAULT FALSE,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Admins Table (Extended profile for admins)
-- -------------------------
CREATE TABLE admins (
    id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    admin_id TEXT UNIQUE NOT NULL,
    permission_level INTEGER DEFAULT 1, -- 1=basic, 2=advanced, 3=super_admin
    department TEXT,
    can_manage_users BOOLEAN DEFAULT TRUE,
    can_manage_assessments BOOLEAN DEFAULT TRUE,
    can_view_reports BOOLEAN DEFAULT TRUE,
    can_modify_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Classes/Groups Table
-- -------------------------
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    grade_level TEXT,
    academic_year TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Class Members (Student-Class relationship)
-- -------------------------
CREATE TABLE class_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID REFERENCES classes(id) ON DELETE CASCADE,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    
    UNIQUE(class_id, student_id)
);

-- -------------------------
-- Assessment Sessions
-- -------------------------
CREATE TABLE assessment_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES teachers(id) ON DELETE SET NULL,
    class_id UUID REFERENCES classes(id) ON DELETE SET NULL,
    
    stage cognitive_stage NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    
    status TEXT DEFAULT 'in_progress', -- in_progress, completed, cancelled
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Assessment Questions
-- -------------------------
CREATE TABLE assessment_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    
    question_text TEXT NOT NULL,
    criterion TEXT NOT NULL,
    stage cognitive_stage NOT NULL,
    response_type response_type NOT NULL,
    
    options JSONB, -- For multiple choice questions
    correct_answer TEXT,
    scoring_rules JSONB,
    
    order_index INTEGER NOT NULL,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Question Responses
-- -------------------------
CREATE TABLE question_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES assessment_questions(id) ON DELETE CASCADE,
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    
    answer TEXT NOT NULL,
    is_correct BOOLEAN,
    time_spent_seconds INTEGER,
    
    responded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Assessment Results
-- -------------------------
CREATE TABLE assessment_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES assessment_sessions(id) ON DELETE CASCADE,
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    
    identified_stage cognitive_stage NOT NULL,
    overall_score DECIMAL(5,2) NOT NULL,
    
    strengths TEXT[],
    development_areas TEXT[],
    suggested_activities TEXT[],
    
    detailed_feedback JSONB,
    criteria_results JSONB, -- Detailed criterion evaluations
    
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Progress Tracking
-- -------------------------
CREATE TABLE student_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id UUID REFERENCES students(id) ON DELETE CASCADE,
    
    current_stage cognitive_stage,
    last_assessment_date TIMESTAMP WITH TIME ZONE,
    total_assessments_taken INTEGER DEFAULT 0,
    average_score DECIMAL(5,2),
    
    improvement_rate DECIMAL(5,2), -- Percentage improvement
    
    notes TEXT,
    
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(student_id)
);

-- -------------------------
-- Activity Logs (Audit trail)
-- -------------------------
CREATE TABLE activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    
    action TEXT NOT NULL,
    entity_type TEXT, -- e.g., 'assessment', 'student', 'class'
    entity_id UUID,
    
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- Notifications
-- -------------------------
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT DEFAULT 'info', -- info, success, warning, error
    
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    
    related_entity_type TEXT,
    related_entity_id UUID,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- -------------------------
-- System Settings
-- -------------------------
CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    category TEXT,
    
    updated_by UUID REFERENCES admins(id) ON DELETE SET NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES for Performance Optimization
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_auth_id ON users(auth_id);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Students indexes
CREATE INDEX idx_students_student_id ON students(student_id);
CREATE INDEX idx_students_teacher ON students(assigned_teacher_id);
CREATE INDEX idx_students_age ON students(age);

-- Teachers indexes
CREATE INDEX idx_teachers_teacher_id ON teachers(teacher_id);
CREATE INDEX idx_teachers_department ON teachers(department);

-- Assessment sessions indexes
CREATE INDEX idx_sessions_student ON assessment_sessions(student_id);
CREATE INDEX idx_sessions_teacher ON assessment_sessions(teacher_id);
CREATE INDEX idx_sessions_status ON assessment_sessions(status);
CREATE INDEX idx_sessions_started_at ON assessment_sessions(started_at DESC);

-- Assessment results indexes
CREATE INDEX idx_results_student ON assessment_results(student_id);
CREATE INDEX idx_results_session ON assessment_results(session_id);
CREATE INDEX idx_results_stage ON assessment_results(identified_stage);
CREATE INDEX idx_results_created_at ON assessment_results(created_at DESC);

-- Questions and responses indexes
CREATE INDEX idx_questions_session ON assessment_questions(session_id);
CREATE INDEX idx_responses_question ON question_responses(question_id);
CREATE INDEX idx_responses_session ON question_responses(session_id);

-- Class members indexes
CREATE INDEX idx_class_members_class ON class_members(class_id);
CREATE INDEX idx_class_members_student ON class_members(student_id);

-- Activity logs indexes
CREATE INDEX idx_activity_logs_user ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON activity_logs(created_at DESC);
CREATE INDEX idx_activity_logs_action ON activity_logs(action);

-- Notifications indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- -------------------------
-- Users Policies
-- -------------------------

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = auth_id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = auth_id);

-- Admins can view all users
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- Admins can insert users
CREATE POLICY "Admins can insert users" ON users
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- Admins can update users
CREATE POLICY "Admins can update users" ON users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- -------------------------
-- Students Policies
-- -------------------------

-- Students can view their own profile
CREATE POLICY "Students can view own profile" ON students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.id = students.id AND u.auth_id = auth.uid()
        )
    );

-- Teachers can view their assigned students
CREATE POLICY "Teachers can view assigned students" ON students
    FOR SELECT USING (
        assigned_teacher_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid() AND role = 'teacher'
        )
    );

-- Admins can view all students
CREATE POLICY "Admins can view all students" ON students
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- Admins and teachers can insert students
CREATE POLICY "Admins and teachers can insert students" ON students
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role IN ('admin', 'teacher')
        )
    );

-- -------------------------
-- Teachers Policies
-- -------------------------

-- Teachers can view their own profile
CREATE POLICY "Teachers can view own profile" ON teachers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.id = teachers.id AND u.auth_id = auth.uid()
        )
    );

-- Admins can view all teachers
CREATE POLICY "Admins can view all teachers" ON teachers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- -------------------------
-- Assessment Sessions Policies
-- -------------------------

-- Students can view their own assessments
CREATE POLICY "Students can view own assessments" ON assessment_sessions
    FOR SELECT USING (
        student_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()
        )
    );

-- Teachers can view assessments of their students
CREATE POLICY "Teachers can view student assessments" ON assessment_sessions
    FOR SELECT USING (
        teacher_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid() AND role = 'teacher'
        )
        OR
        student_id IN (
            SELECT s.id FROM students s
            JOIN users u ON u.id = s.assigned_teacher_id
            WHERE u.auth_id = auth.uid()
        )
    );

-- Teachers can create assessments
CREATE POLICY "Teachers can create assessments" ON assessment_sessions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role IN ('teacher', 'admin')
        )
    );

-- Admins can view all assessments
CREATE POLICY "Admins can view all assessments" ON assessment_sessions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() AND u.role = 'admin'
        )
    );

-- -------------------------
-- Assessment Results Policies
-- -------------------------

-- Students can view their own results
CREATE POLICY "Students can view own results" ON assessment_results
    FOR SELECT USING (
        student_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()
        )
    );

-- Teachers can view results of their students
CREATE POLICY "Teachers can view student results" ON assessment_results
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM assessment_sessions s
            WHERE s.id = assessment_results.session_id
            AND (
                s.teacher_id IN (
                    SELECT id FROM users WHERE auth_id = auth.uid() AND role = 'teacher'
                )
                OR s.student_id IN (
                    SELECT st.id FROM students st
                    JOIN users u ON u.id = st.assigned_teacher_id
                    WHERE u.auth_id = auth.uid()
                )
            )
        )
    );

-- -------------------------
-- Notifications Policies
-- -------------------------

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (
        user_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()
        )
    );

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (
        user_id IN (
            SELECT id FROM users WHERE auth_id = auth.uid()
        )
    );

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teachers_updated_at BEFORE UPDATE ON teachers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_classes_updated_at BEFORE UPDATE ON classes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON assessment_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_progress_updated_at BEFORE UPDATE ON student_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically create student_progress entry
CREATE OR REPLACE FUNCTION create_student_progress()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO student_progress (student_id)
    VALUES (NEW.id)
    ON CONFLICT (student_id) DO NOTHING;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_create_student_progress
    AFTER INSERT ON students
    FOR EACH ROW EXECUTE FUNCTION create_student_progress();

-- Function to update student progress after assessment
CREATE OR REPLACE FUNCTION update_student_progress_after_assessment()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE student_progress
    SET 
        current_stage = NEW.identified_stage,
        last_assessment_date = NEW.created_at,
        total_assessments_taken = total_assessments_taken + 1,
        average_score = (
            SELECT AVG(overall_score)
            FROM assessment_results
            WHERE student_id = NEW.student_id
        ),
        updated_at = NOW()
    WHERE student_id = NEW.student_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_update_progress_after_result
    AFTER INSERT ON assessment_results
    FOR EACH ROW EXECUTE FUNCTION update_student_progress_after_assessment();

-- Function to log user activities
CREATE OR REPLACE FUNCTION log_activity(
    p_user_id UUID,
    p_action TEXT,
    p_entity_type TEXT DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL,
    p_details JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_log_id UUID;
BEGIN
    INSERT INTO activity_logs (user_id, action, entity_type, entity_id, details)
    VALUES (p_user_id, p_action, p_entity_type, p_entity_id, p_details)
    RETURNING id INTO v_log_id;
    
    RETURN v_log_id;
END;
$$ language 'plpgsql';

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_title TEXT,
    p_message TEXT,
    p_type TEXT DEFAULT 'info',
    p_entity_type TEXT DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO notifications (user_id, title, message, type, related_entity_type, related_entity_id)
    VALUES (p_user_id, p_title, p_message, p_type, p_entity_type, p_entity_id)
    RETURNING id INTO v_notification_id;
    
    RETURN v_notification_id;
END;
$$ language 'plpgsql';

-- =====================================================
-- INITIAL DATA / SEED DATA
-- =====================================================

-- Insert default system settings
INSERT INTO system_settings (key, value, description, category) VALUES
    ('app_name', '"MindTrack: Piaget Assessment"', 'Application name', 'general'),
    ('version', '"1.0.0"', 'Application version', 'general'),
    ('maintenance_mode', 'false', 'Enable/disable maintenance mode', 'general'),
    ('max_assessment_duration_minutes', '60', 'Maximum duration for an assessment session', 'assessment'),
    ('default_questions_per_assessment', '10', 'Default number of questions per assessment', 'assessment'),
    ('enable_notifications', 'true', 'Enable/disable notifications', 'features'),
    ('enable_progress_tracking', 'true', 'Enable/disable progress tracking', 'features');

-- =====================================================
-- VIEWS FOR REPORTING
-- =====================================================

-- Comprehensive student view
CREATE OR REPLACE VIEW v_student_details AS
SELECT 
    u.id,
    u.email,
    u.full_name,
    u.phone,
    u.date_of_birth,
    u.is_active,
    u.created_at,
    s.student_id,
    s.grade_level,
    s.class_name,
    s.age,
    s.assigned_teacher_id,
    t.full_name as teacher_name,
    s.parent_email,
    s.parent_phone,
    s.special_needs,
    sp.current_stage,
    sp.total_assessments_taken,
    sp.average_score,
    sp.last_assessment_date
FROM users u
JOIN students s ON u.id = s.id
LEFT JOIN users t ON s.assigned_teacher_id = t.id
LEFT JOIN student_progress sp ON s.id = sp.student_id
WHERE u.role = 'student';

-- Assessment summary view
CREATE OR REPLACE VIEW v_assessment_summary AS
SELECT 
    asess.id as session_id,
    asess.student_id,
    u.full_name as student_name,
    s.student_id as student_number,
    asess.teacher_id,
    t.full_name as teacher_name,
    asess.stage,
    asess.status,
    asess.started_at,
    asess.completed_at,
    asess.duration_seconds,
    ar.identified_stage,
    ar.overall_score,
    COUNT(DISTINCT aq.id) as total_questions,
    COUNT(DISTINCT qr.id) as answered_questions
FROM assessment_sessions asess
LEFT JOIN users u ON asess.student_id = u.id
LEFT JOIN students s ON asess.student_id = s.id
LEFT JOIN users t ON asess.teacher_id = t.id
LEFT JOIN assessment_results ar ON asess.id = ar.session_id
LEFT JOIN assessment_questions aq ON asess.id = aq.session_id
LEFT JOIN question_responses qr ON aq.id = qr.question_id
GROUP BY asess.id, u.full_name, s.student_id, t.full_name, ar.identified_stage, ar.overall_score;

-- =====================================================
-- COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE users IS 'Main users table storing all user types with auth integration';
COMMENT ON TABLE students IS 'Extended profile information for student users';
COMMENT ON TABLE teachers IS 'Extended profile information for teacher users';
COMMENT ON TABLE admins IS 'Extended profile information for admin users with permissions';
COMMENT ON TABLE assessment_sessions IS 'Tracks individual assessment sessions taken by students';
COMMENT ON TABLE assessment_results IS 'Stores comprehensive results and analysis of completed assessments';
COMMENT ON TABLE student_progress IS 'Tracks overall progress and improvement of students over time';
COMMENT ON TABLE activity_logs IS 'Audit trail of all significant actions in the system';
COMMENT ON TABLE notifications IS 'User notifications for various events and updates';

-- =====================================================
-- STORAGE CONFIGURATION
-- =====================================================

/*
STORAGE BUCKET SETUP (Manual in Supabase UI):
=====================================================
1. Go to your Supabase Dashboard
2. Navigate to: Storage > Buckets
3. Create new bucket named: "avatars"
   - Click "New bucket"
   - Name: avatars
   - Make it private
   - Click "Create bucket"

4. After creating bucket, set up policies:
   - Click on "avatars" bucket
   - Go to "Policies" tab
   - Click "New policy"
   
   Policy 1: Users can upload their own avatars
   - Action: INSERT
   - Define a custom expression:
     auth.uid()::text = (storage.foldername[1])
   
   Policy 2: Public read access to avatars
   - Action: SELECT
   - Using expression: true (to make all avatars public)

This allows users to upload images and retrieve them.
Images will be stored at: storage/avatars/{user_id}/{filename}
*/

-- =====================================================
-- SETUP INSTRUCTIONS
-- =====================================================

/*
IMPORTANT: After running this schema, you need to create the admin user.

STEP 1: Create Admin in Supabase Auth
======================================
1. Go to your Supabase Dashboard
2. Navigate to: Authentication > Users
3. Click "Create new user"
4. Fill in:
   - Email: admin@gmail.com
   - Password: admin000
   - Auto confirm user: YES (check this box)
5. Click "Create user"
6. Copy the user ID (UUID) from the created user

STEP 2: Create Admin Profile in Database
==========================================
Replace YOUR_AUTH_UUID with the UUID from Step 1, then run:

-- Create admin user record
INSERT INTO users (auth_id, email, full_name, role, is_active)
VALUES (
    'YOUR_AUTH_UUID'::uuid,
    'admin@gmail.com',
    'System Admin',
    'admin',
    true
);

-- Get the user ID
SELECT id FROM users WHERE email = 'admin@gmail.com' LIMIT 1;

-- Create admin profile (replace YOUR_USER_UUID with the ID from above)
INSERT INTO admins (
    id,
    admin_id,
    permission_level,
    can_manage_users,
    can_manage_assessments,
    can_view_reports,
    can_modify_system
)
VALUES (
    'YOUR_USER_UUID'::uuid,
    'ADMIN_001',
    3,
    true,
    true,
    true,
    true
);

DEFAULT LOGIN CREDENTIALS FOR ADMIN
====================================
Email: admin@gmail.com
Password: admin000

These credentials can be changed after first login via the app.

TESTING OTHER ROLES
====================
You can also create test accounts directly in the app:
1. Select Role: Teacher / Student / Admin
2. Click "Sign Up"
3. Fill in the details
4. Account will be automatically created

All accounts must be confirmed before login.
*/

-- =====================================================
-- END OF SCHEMA
-- =====================================================
