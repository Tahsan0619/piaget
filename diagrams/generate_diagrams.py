"""
MindTrack (Piaget Assessment) — Software Engineering Diagrams
Generates 6 high-quality diagrams as PNG files using matplotlib.
"""

import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Arc
import numpy as np
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ---------- colour palette ----------
C_BG = '#FAFBFE'
C_ACTOR_STUDENT = '#4A90D9'
C_ACTOR_TEACHER = '#E8913A'
C_ACTOR_ADMIN = '#D94A4A'
C_SYSTEM = '#7B68EE'
C_GROQ = '#10B981'
C_SUPABASE = '#3ECF8E'
C_PDF = '#E74C3C'
C_BORDER = '#CBD5E1'
C_TEXT = '#1E293B'
C_LIGHT = '#F1F5F9'
C_WHITE = '#FFFFFF'
C_LINE = '#64748B'
C_USECASE = '#EEF2FF'
C_USECASE_BORDER = '#818CF8'
C_CLASS_HEADER = '#4338CA'
C_CLASS_BG = '#EEF2FF'
C_ENTITY = '#DBEAFE'
C_ENTITY_BORDER = '#3B82F6'
C_PK = '#F59E0B'
C_FK = '#10B981'
C_PROCESS = '#DBEAFE'
C_PROCESS_BORDER = '#3B82F6'
C_DATASTORE = '#D1FAE5'
C_DATASTORE_BORDER = '#059669'
C_EXTERNAL = '#FEF3C7'
C_EXTERNAL_BORDER = '#D97706'

def save(fig, name):
    path = os.path.join(OUTPUT_DIR, name)
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor=fig.get_facecolor(), edgecolor='none')
    plt.close(fig)
    print(f"  ✓ {name}")


# ================================================================
# 1. USE CASE DIAGRAM
# ================================================================
def draw_use_case_diagram():
    fig, ax = plt.subplots(figsize=(20, 16))
    fig.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    ax.set_xlim(-1, 21)
    ax.set_ylim(-1, 17)
    ax.axis('off')
    ax.set_aspect('equal')

    # Title
    ax.text(10, 16.2, 'MindTrack — Use Case Diagram', fontsize=22, fontweight='bold',
            ha='center', va='center', color=C_TEXT, fontfamily='sans-serif')
    ax.text(10, 15.6, 'Piaget Cognitive Development Assessment System', fontsize=12,
            ha='center', va='center', color=C_LINE, fontfamily='sans-serif')

    # System boundary
    rect = FancyBboxPatch((4, 0.5), 13, 14.5, boxstyle="round,pad=0.3",
                          facecolor='#F8FAFF', edgecolor=C_USECASE_BORDER, linewidth=2.5, linestyle='-')
    ax.add_patch(rect)
    ax.text(10.5, 14.6, '«system» MindTrack Assessment Platform', fontsize=11,
            ha='center', va='center', color=C_USECASE_BORDER, fontweight='bold', fontstyle='italic')

    # Draw actor
    def draw_actor(ax, x, y, label, color):
        head = plt.Circle((x, y + 0.55), 0.22, fill=True, facecolor=color, edgecolor='white', linewidth=2, zorder=5)
        ax.add_patch(head)
        ax.plot([x, x], [y + 0.33, y - 0.05], color=color, linewidth=2.5, zorder=5)
        ax.plot([x - 0.3, x + 0.3], [y + 0.2, y + 0.2], color=color, linewidth=2.5, zorder=5)
        ax.plot([x - 0.25, x], [y - 0.45, y - 0.05], color=color, linewidth=2.5, zorder=5)
        ax.plot([x + 0.25, x], [y - 0.45, y - 0.05], color=color, linewidth=2.5, zorder=5)
        ax.text(x, y - 0.75, label, fontsize=11, ha='center', va='top', fontweight='bold', color=color)

    # Actors
    draw_actor(ax, 1.5, 12, 'Student', C_ACTOR_STUDENT)
    draw_actor(ax, 1.5, 7.5, 'Teacher', C_ACTOR_TEACHER)
    draw_actor(ax, 1.5, 3, 'Admin', C_ACTOR_ADMIN)

    # Draw use-case ellipse
    def draw_uc(ax, x, y, text, w=2.8, h=0.65):
        ellipse = mpatches.Ellipse((x, y), w, h, facecolor=C_USECASE, edgecolor=C_USECASE_BORDER,
                                    linewidth=1.8, zorder=3)
        ax.add_patch(ellipse)
        ax.text(x, y, text, fontsize=8.5, ha='center', va='center', color=C_TEXT, fontweight='medium',
                wrap=True, zorder=4)
        return (x, y)

    # Student use cases
    uc1 = draw_uc(ax, 7, 13.5, 'Select Role')
    uc2 = draw_uc(ax, 7, 12.4, 'Sign Up / Login')
    uc3 = draw_uc(ax, 7, 11.3, 'View Dashboard')
    uc4 = draw_uc(ax, 7, 10.2, 'Start Assessment')
    uc5 = draw_uc(ax, 7, 9.1, 'Answer Questions')
    uc6 = draw_uc(ax, 7, 8.0, 'View Results')
    uc7 = draw_uc(ax, 7, 6.9, 'Download PDF Report')

    # Teacher use cases
    uc8 = draw_uc(ax, 12, 13.5, 'View Teacher Dashboard')
    uc9 = draw_uc(ax, 12, 12.4, 'Add / Manage Students')
    uc10 = draw_uc(ax, 12, 11.3, 'Browse All Students')
    uc11 = draw_uc(ax, 12, 10.2, 'Create / Manage Classes')
    uc12 = draw_uc(ax, 12, 9.1, 'View Student Assessments')
    uc13 = draw_uc(ax, 12, 8.0, 'Download Student PDF')

    # Admin use cases
    uc14 = draw_uc(ax, 14.5, 6.9, 'Manage All Users')
    uc15 = draw_uc(ax, 14.5, 5.8, 'View System Statistics')
    uc16 = draw_uc(ax, 14.5, 4.7, 'Deactivate Accounts')
    uc17 = draw_uc(ax, 14.5, 3.6, 'Monitor Activity Logs')

    # Shared
    uc18 = draw_uc(ax, 10, 1.5, 'AI Evaluates Responses\n«Groq LLM»', w=3.4, h=0.85)

    # Connection lines
    def connect(ax, x1, y1, x2, y2, color=C_LINE, ls='-'):
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle='-', color=color, lw=1.2, linestyle=ls))

    # Student connections
    for uc in [uc1, uc2, uc3, uc4, uc5, uc6, uc7]:
        connect(ax, 2.0, 12, uc[0] - 1.4, uc[1], C_ACTOR_STUDENT)

    # Teacher connections
    for uc in [uc2, uc3, uc8, uc9, uc10, uc11, uc12, uc13]:
        connect(ax, 2.0, 7.5, uc[0] - 1.4, uc[1], C_ACTOR_TEACHER)

    # Admin connections
    for uc in [uc2, uc3, uc14, uc15, uc16, uc17]:
        connect(ax, 2.0, 3, uc[0] - 1.4, uc[1], C_ACTOR_ADMIN)

    # Include/extend
    ax.annotate('', xy=(10, 1.95), xytext=(7, 8.0 - 0.35),
                arrowprops=dict(arrowstyle='->', color=C_GROQ, lw=1.5, linestyle='--'))
    ax.text(8.2, 4.8, '«include»', fontsize=8, ha='center', va='center', color=C_GROQ,
            fontstyle='italic', rotation=55)

    ax.annotate('', xy=(12, 8.0 - 0.35), xytext=(12, 9.1 + 0.35),
                arrowprops=dict(arrowstyle='->', color=C_USECASE_BORDER, lw=1.3, linestyle='--'))
    ax.text(12.8, 8.55, '«extend»', fontsize=7.5, ha='center', color=C_USECASE_BORDER, fontstyle='italic')

    # Legend
    legend_y = 0.2
    ax.plot([5, 5.5], [legend_y, legend_y], color=C_ACTOR_STUDENT, lw=2)
    ax.text(5.7, legend_y, 'Student', fontsize=8, va='center', color=C_ACTOR_STUDENT)
    ax.plot([8, 8.5], [legend_y, legend_y], color=C_ACTOR_TEACHER, lw=2)
    ax.text(8.7, legend_y, 'Teacher', fontsize=8, va='center', color=C_ACTOR_TEACHER)
    ax.plot([11, 11.5], [legend_y, legend_y], color=C_ACTOR_ADMIN, lw=2)
    ax.text(11.7, legend_y, 'Admin', fontsize=8, va='center', color=C_ACTOR_ADMIN)
    ax.plot([14, 14.5], [legend_y, legend_y], color=C_GROQ, lw=2, linestyle='--')
    ax.text(14.7, legend_y, '«include»', fontsize=8, va='center', color=C_GROQ, fontstyle='italic')

    save(fig, '1_use_case_diagram.png')


# ================================================================
# 2. UML CLASS DIAGRAM
# ================================================================
def draw_class_diagram():
    fig, ax = plt.subplots(figsize=(24, 20))
    fig.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    ax.set_xlim(-1, 25)
    ax.set_ylim(-1, 21)
    ax.axis('off')

    ax.text(12, 20.5, 'MindTrack — UML Class Diagram', fontsize=22, fontweight='bold',
            ha='center', va='center', color=C_TEXT)
    ax.text(12, 19.9, 'Models, Services, and Providers Architecture', fontsize=12,
            ha='center', va='center', color=C_LINE)

    def draw_class(ax, x, y, name, stereotype, attrs, methods, w=4.5, header_color=C_CLASS_HEADER):
        line_h = 0.32
        attr_h = len(attrs) * line_h + 0.2
        meth_h = len(methods) * line_h + 0.2
        total_h = 0.7 + attr_h + meth_h

        # Background
        bg = FancyBboxPatch((x, y - total_h), w, total_h, boxstyle="round,pad=0.05",
                            facecolor=C_CLASS_BG, edgecolor=header_color, linewidth=2, zorder=3)
        ax.add_patch(bg)
        # Header
        hdr = FancyBboxPatch((x, y - 0.7), w, 0.7, boxstyle="round,pad=0.05",
                             facecolor=header_color, edgecolor=header_color, linewidth=2, zorder=4)
        ax.add_patch(hdr)

        if stereotype:
            ax.text(x + w/2, y - 0.18, f'«{stereotype}»', fontsize=7, ha='center', va='center',
                    color='#C4B5FD', fontstyle='italic', zorder=5)
            ax.text(x + w/2, y - 0.48, name, fontsize=10, ha='center', va='center',
                    color='white', fontweight='bold', zorder=5)
        else:
            ax.text(x + w/2, y - 0.35, name, fontsize=10, ha='center', va='center',
                    color='white', fontweight='bold', zorder=5)

        # Divider line
        ax.plot([x + 0.1, x + w - 0.1], [y - 0.7, y - 0.7], color=header_color, lw=1.5, zorder=5)

        # Attributes
        for i, attr in enumerate(attrs):
            ax.text(x + 0.15, y - 0.7 - 0.15 - i * line_h, attr, fontsize=7.5, va='top',
                    color=C_TEXT, fontfamily='monospace', zorder=5)
        
        # Divider
        div_y = y - 0.7 - attr_h
        ax.plot([x + 0.1, x + w - 0.1], [div_y, div_y], color=header_color, lw=0.8, alpha=0.5, zorder=5)

        # Methods
        for i, meth in enumerate(methods):
            ax.text(x + 0.15, div_y - 0.15 - i * line_h, meth, fontsize=7.5, va='top',
                    color=C_TEXT, fontfamily='monospace', zorder=5)

        return (x, y, w, total_h)

    # ---------- Enums ----------
    draw_class(ax, 0, 19.5, 'UserRole', 'enum', 
               ['student', 'teacher', 'admin'], [], w=3, header_color='#7C3AED')

    draw_class(ax, 0, 17.5, 'CognitiveStage', 'enum',
               ['concreteOperational', 'formalOperational'], 
               ['+displayName: String', '+indicators: List<String>'], w=3.6, header_color='#7C3AED')

    draw_class(ax, 0, 15, 'CriterionStatus', 'enum',
               ['achieved', 'developing', 'notYetAchieved'], [], w=3, header_color='#7C3AED')

    draw_class(ax, 0, 13.2, 'ResponseType', 'enum',
               ['yesNo', 'multipleChoice', 'shortAnswer', 'matching'], [], w=3.2, header_color='#7C3AED')

    # ---------- Model Classes ----------
    draw_class(ax, 5, 19.5, 'UserProfile', 'model',
               ['- id: String', '- authId: String?', '- name: String',
                '- role: UserRole', '- email: String?', '- phone: String?',
                '- isActive: bool', '- createdAt: DateTime'],
               ['+fromJson(Map): UserProfile', '+toJson(): Map', '+copyWith(): UserProfile'],
               w=4.5, header_color='#2563EB')

    draw_class(ax, 5, 14.8, 'StudentProfile', 'model',
               ['- studentId: String', '- age: int?', '- gradeLevel: String?',
                '- className: String?', '- assignedTeacherId: String?',
                '- parentEmail: String?', '- specialNeeds: String?'],
               ['+fromJson(Map): StudentProfile', '+toJson(): Map'],
               w=4.5, header_color='#2563EB')

    draw_class(ax, 10, 14.8, 'TeacherProfile', 'model',
               ['- teacherId: String', '- department: String?',
                '- specialization: String?', '- qualification: String?',
                '- experienceYears: int?', '- isVerified: bool'],
               ['+fromJson(Map): TeacherProfile', '+toJson(): Map'],
               w=4.5, header_color='#2563EB')

    draw_class(ax, 15, 14.8, 'AdminProfile', 'model',
               ['- adminId: String', '- permissionLevel: int',
                '- canManageUsers: bool', '- canManageAssessments: bool',
                '- canViewReports: bool'],
               ['+fromJson(Map): AdminProfile', '+toJson(): Map'],
               w=4.5, header_color='#2563EB')

    draw_class(ax, 20, 19.5, 'LearnerProfile', 'model',
               ['- id: String', '- name: String', '- age: int',
                '- className: String?', '- teacherId: String?'],
               ['+fromJson(Map): LearnerProfile', '+toJson(): Map'],
               w=4, header_color='#2563EB')

    # ---------- Assessment Models ----------
    draw_class(ax, 10, 19.5, 'Question', 'model',
               ['- id: String', '- text: String', '- criterion: String',
                '- stage: String', '- responseType: ResponseType',
                '- options: List<String>?', '- correctAnswer: String?',
                '- scoringRules: Map?'],
               ['+fromJson(Map): Question', '+toJson(): Map'],
               w=4.5, header_color='#0891B2')

    draw_class(ax, 15, 19.5, 'QuestionResponse', 'model',
               ['- questionId: String', '- answer: String',
                '- timeSpentSeconds: int', '- respondedAt: DateTime'],
               ['+fromJson(Map): QuestionResponse', '+toJson(): Map'],
               w=4, header_color='#0891B2')

    draw_class(ax, 10, 11.5, 'AssessmentSession', 'model',
               ['- id: String', '- learnerId: String',
                '- stageName: String', '- questions: List<Question>',
                '- responses: List<Response>',
                '- startedAt: DateTime', '- completedAt: DateTime?'],
               ['+isCompleted: bool', '+progress: int', '+progressPercentage: double'],
               w=4.8, header_color='#0891B2')

    draw_class(ax, 15.5, 11.5, 'AssessmentResult', 'model',
               ['- id: String', '- learnerId: String',
                '- assessmentStage: String',
                '- criteriaResults: List<CriterionEval>',
                '- identifiedStage: String',
                '- strengths: List<String>',
                '- developmentAreas: List<String>',
                '- suggestedActivities: List<String>',
                '- overallScore: double',
                '- completedAt: DateTime'],
               ['+fromJson(Map): AssessmentResult', '+toJson(): Map'],
               w=4.8, header_color='#0891B2')

    draw_class(ax, 20.5, 14.8, 'CriterionEvaluation', 'model',
               ['- criterionName: String', '- status: CriterionStatus',
                '- score: double', '- feedback: String'],
               ['+fromJson(Map)', '+toJson(): Map'],
               w=3.8, header_color='#0891B2')

    # ---------- Services ----------
    draw_class(ax, 0, 9.5, 'SupabaseService', 'service',
               ['- _client: SupabaseClient?'],
               ['+initialize()', '+signUp()', '+signIn()', '+signOut()',
                '+getUserProfile()', '+getStudentAssessments()',
                '+getAssessmentResult()', '+getStudentProgress()',
                '+createClass()', '+getTeacherClasses()',
                '+logActivity()', '+createNotification()'],
               w=4.5, header_color='#059669')

    draw_class(ax, 5, 9.5, 'GroqService', 'service',
               ['- _apiKey: String', '- _client: http.Client'],
               ['+generateContent()', '+generateJsonResponse()',
                '+generateSuggestions()', '+evaluateResponse()'],
               w=4.2, header_color='#059669')

    draw_class(ax, 0, 4.5, 'AssessmentService', 'service',
               ['+ questionBank: Map'],
               ['+createAssessmentSession()', '+evaluateResponses()'],
               w=4.2, header_color='#059669')

    draw_class(ax, 5, 4.5, 'PdfService', 'service',
               [],
               ['+generateAndShareReport()', '+printReport()',
                '-_buildPdfHeader()', '-_buildScoreSection()',
                '-_buildStageSection()', '-_buildCriteriaSection()'],
               w=4.2, header_color='#059669')

    # ---------- Providers ----------
    draw_class(ax, 10, 5, 'AuthProvider', 'provider',
               ['- _currentUser: UserProfile?', '- _selectedRole: UserRole?',
                '- _isAuthenticated: bool', '- _dashboardStats: Map?'],
               ['+signIn()', '+signUp()', '+logout()',
                '+setUserRole()', '+loadUserProfile()',
                '+updateProfile()', '+refreshDashboardStats()'],
               w=4.8, header_color='#DC2626')

    draw_class(ax, 15.5, 5, 'AssessmentProvider', 'provider',
               ['- _currentSession: Session?', '- _currentLearner: Learner?',
                '- _responses: List<Response>', '- _lastResult: Result?'],
               ['+initializeLearner()', '+startAssessment()',
                '+submitResponse()', '+completeAssessment()',
                '+reset()'],
               w=4.8, header_color='#DC2626')

    # Inheritance arrows (StudentProfile, TeacherProfile, AdminProfile -> UserProfile)
    for target_x in [5, 10, 15]:
        ax.annotate('', xy=(7.25, 14.85), xytext=(target_x + 2.25, 14.8),
                     arrowprops=dict(arrowstyle='-|>', color=C_CLASS_HEADER, lw=1.5,
                                     connectionstyle='arc3,rad=0'))

    # Composition arrows
    # AssessmentSession has Questions
    ax.annotate('', xy=(12.25, 14.7), xytext=(12.25, 11.5),
                arrowprops=dict(arrowstyle='-|>', color='#0891B2', lw=1.2, linestyle='--'))
    ax.text(12.5, 13.1, '  has ▸', fontsize=7, color='#0891B2')

    # AssessmentResult has CriterionEvaluation
    ax.annotate('', xy=(20.5, 14.8), xytext=(17.8, 11.5),
                arrowprops=dict(arrowstyle='-|>', color='#0891B2', lw=1.2, linestyle='--'))
    ax.text(19.5, 13.0, 'has ◆', fontsize=7, color='#0891B2')

    # Legend
    legend_items = [
        ('Enums', '#7C3AED'), ('Models', '#2563EB'), ('Assessment', '#0891B2'),
        ('Services', '#059669'), ('Providers', '#DC2626')
    ]
    for i, (label, color) in enumerate(legend_items):
        bx = 0.5 + i * 3.5
        p = FancyBboxPatch((bx, -0.7), 0.4, 0.3, boxstyle="round,pad=0.02",
                           facecolor=color, edgecolor=color, linewidth=1.5)
        ax.add_patch(p)
        ax.text(bx + 0.6, -0.55, label, fontsize=9, va='center', color=color, fontweight='bold')

    save(fig, '2_uml_class_diagram.png')


# ================================================================
# 3. ENTITY RELATIONSHIP DIAGRAM
# ================================================================
def draw_er_diagram():
    fig, ax = plt.subplots(figsize=(22, 18))
    fig.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    ax.set_xlim(-1, 23)
    ax.set_ylim(-1, 19)
    ax.axis('off')

    ax.text(11, 18.5, 'MindTrack — Entity Relationship Diagram', fontsize=22, fontweight='bold',
            ha='center', va='center', color=C_TEXT)
    ax.text(11, 17.9, 'Supabase PostgreSQL Database Schema', fontsize=12,
            ha='center', va='center', color=C_LINE)

    def draw_entity(ax, x, y, name, fields, w=4.5):
        line_h = 0.30
        total_h = 0.55 + len(fields) * line_h + 0.15

        bg = FancyBboxPatch((x, y - total_h), w, total_h, boxstyle="round,pad=0.06",
                            facecolor=C_WHITE, edgecolor=C_ENTITY_BORDER, linewidth=2.2, zorder=3)
        ax.add_patch(bg)
        hdr = FancyBboxPatch((x, y - 0.55), w, 0.55, boxstyle="round,pad=0.06",
                             facecolor=C_ENTITY_BORDER, edgecolor=C_ENTITY_BORDER, linewidth=2.2, zorder=4)
        ax.add_patch(hdr)
        ax.text(x + w/2, y - 0.275, name, fontsize=11, ha='center', va='center',
                color='white', fontweight='bold', zorder=5)

        for i, (fname, ftype, key) in enumerate(fields):
            yy = y - 0.55 - 0.12 - i * line_h
            prefix = ''
            color = C_TEXT
            if key == 'PK':
                prefix = 'PK '
                color = '#B45309'
            elif key == 'FK':
                prefix = 'FK '
                color = '#047857'
            ax.text(x + 0.15, yy, f'{prefix}{fname}', fontsize=8, va='top', color=color,
                    fontweight='bold' if key else 'normal', fontfamily='monospace', zorder=5)
            ax.text(x + w - 0.15, yy, ftype, fontsize=7.5, va='top', ha='right',
                    color=C_LINE, fontfamily='monospace', zorder=5)

        return (x + w/2, y, x + w/2, y - total_h, x, y - total_h/2, x + w, y - total_h/2)

    # Entities
    users = draw_entity(ax, 0, 17, 'users', [
        ('id', 'UUID', 'PK'), ('auth_id', 'UUID', ''), ('email', 'VARCHAR', ''),
        ('full_name', 'VARCHAR', ''), ('role', 'ENUM', ''),
        ('phone', 'VARCHAR', ''), ('is_active', 'BOOLEAN', ''),
        ('last_login', 'TIMESTAMP', ''), ('created_at', 'TIMESTAMP', ''),
    ], w=4.5)

    students = draw_entity(ax, 0, 12.8, 'students', [
        ('id', 'UUID', 'PK'), ('student_id', 'TEXT', ''),
        ('age', 'INT', ''), ('grade_level', 'VARCHAR', ''),
        ('class_name', 'VARCHAR', ''), ('assigned_teacher_id', 'UUID', 'FK'),
        ('parent_email', 'VARCHAR', ''), ('special_needs', 'TEXT', ''),
    ], w=4.5)

    teachers = draw_entity(ax, 6, 17, 'teachers', [
        ('id', 'UUID', 'PK'), ('teacher_id', 'TEXT', ''),
        ('department', 'VARCHAR', ''), ('specialization', 'VARCHAR', ''),
        ('qualification', 'VARCHAR', ''), ('experience_years', 'INT', ''),
        ('is_verified', 'BOOLEAN', ''),
    ], w=4.5)

    admins = draw_entity(ax, 6, 12.8, 'admins', [
        ('id', 'UUID', 'PK'), ('admin_id', 'TEXT', ''),
        ('department', 'VARCHAR', ''), ('permission_level', 'INT', ''),
        ('can_manage_users', 'BOOLEAN', ''),
    ], w=4.5)

    sessions = draw_entity(ax, 12, 17, 'assessment_sessions', [
        ('id', 'UUID', 'PK'), ('student_id', 'UUID', 'FK'),
        ('stage', 'ENUM', ''), ('title', 'VARCHAR', ''),
        ('description', 'TEXT', ''), ('status', 'VARCHAR', ''),
        ('started_at', 'TIMESTAMP', ''), ('completed_at', 'TIMESTAMP', ''),
    ], w=5)

    questions = draw_entity(ax, 12, 12.8, 'assessment_questions', [
        ('id', 'UUID', 'PK'), ('session_id', 'UUID', 'FK'),
        ('question_text', 'TEXT', ''), ('criterion', 'VARCHAR', ''),
        ('response_type', 'ENUM', ''), ('options', 'JSONB', ''),
        ('order_index', 'INT', ''),
    ], w=5)

    responses = draw_entity(ax, 18, 17, 'question_responses', [
        ('id', 'UUID', 'PK'), ('session_id', 'UUID', 'FK'),
        ('question_id', 'UUID', 'FK'), ('answer', 'TEXT', ''),
        ('time_spent', 'INT', ''), ('responded_at', 'TIMESTAMP', ''),
    ], w=4.5)

    results = draw_entity(ax, 18, 12.8, 'assessment_results', [
        ('id', 'UUID', 'PK'), ('session_id', 'UUID', 'FK'),
        ('student_id', 'UUID', 'FK'), ('stage', 'ENUM', ''),
        ('overall_score', 'DECIMAL', ''), ('identified_stage', 'VARCHAR', ''),
        ('criteria_results', 'JSONB', ''), ('strengths', 'JSONB', ''),
        ('development_areas', 'JSONB', ''), ('suggested_activities', 'JSONB', ''),
        ('completed_at', 'TIMESTAMP', ''),
    ], w=4.5)

    classes = draw_entity(ax, 0, 8, 'classes', [
        ('id', 'UUID', 'PK'), ('name', 'VARCHAR', ''),
        ('description', 'TEXT', ''), ('teacher_id', 'UUID', 'FK'),
        ('grade_level', 'VARCHAR', ''), ('academic_year', 'VARCHAR', ''),
        ('is_active', 'BOOLEAN', ''),
    ], w=4.5)

    class_members = draw_entity(ax, 6, 8, 'class_members', [
        ('id', 'UUID', 'PK'), ('class_id', 'UUID', 'FK'),
        ('student_id', 'UUID', 'FK'), ('joined_at', 'TIMESTAMP', ''),
    ], w=4.5)

    notifications = draw_entity(ax, 12, 8, 'notifications', [
        ('id', 'UUID', 'PK'), ('user_id', 'UUID', 'FK'),
        ('title', 'VARCHAR', ''), ('message', 'TEXT', ''),
        ('type', 'VARCHAR', ''), ('is_read', 'BOOLEAN', ''),
        ('created_at', 'TIMESTAMP', ''),
    ], w=4.5)

    activity_logs = draw_entity(ax, 18, 8, 'activity_logs', [
        ('id', 'UUID', 'PK'), ('user_id', 'UUID', 'FK'),
        ('action', 'VARCHAR', ''), ('details', 'JSONB', ''),
        ('created_at', 'TIMESTAMP', ''),
    ], w=4.5)

    progress = draw_entity(ax, 6, 3.5, 'student_progress', [
        ('student_id', 'UUID', 'PK/FK'), ('current_stage', 'ENUM', ''),
        ('total_assessments', 'INT', ''), ('average_score', 'DECIMAL', ''),
    ], w=4.5)

    # Relationship lines with cardinality
    def rel(ax, x1, y1, x2, y2, card1, card2, color=C_ENTITY_BORDER):
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle='-', color=color, lw=1.8))
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(x1 + (x2 - x1) * 0.15, y1 + (y2 - y1) * 0.15 + 0.15, card1, fontsize=8,
                ha='center', color=color, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.1', facecolor='white', edgecolor='none', alpha=0.9))
        ax.text(x1 + (x2 - x1) * 0.85, y1 + (y2 - y1) * 0.85 + 0.15, card2, fontsize=8,
                ha='center', color=color, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.1', facecolor='white', edgecolor='none', alpha=0.9))

    # users 1--1 students
    rel(ax, 2.25, 13.85, 2.25, 12.8, '1', '1', '#2563EB')
    # users 1--1 teachers
    rel(ax, 4.5, 16, 6, 16, '1', '1', '#2563EB')
    # users 1--1 admins
    rel(ax, 4.5, 13.5, 6, 13.5, '1', '1', '#2563EB')
    # students 1--N assessment_sessions
    rel(ax, 4.5, 11, 12, 15.5, '1', 'N', '#DC2626')
    # sessions 1--N questions
    rel(ax, 14.5, 14.15, 14.5, 12.8, '1', 'N', '#0891B2')
    # sessions 1--N responses
    rel(ax, 17, 16, 18, 16, '1', 'N', '#0891B2')
    # sessions 1--1 results
    rel(ax, 17, 14, 18, 14, '1', '1', '#7C3AED')
    # classes N--1 teacher
    rel(ax, 2.25, 8, 2.25, 10.0, 'N', '1', '#E8913A')
    # class_members N--1 students
    rel(ax, 8.25, 8, 4.5, 10.5, 'N', '1', '#E8913A')
    # class_members N--1 classes
    rel(ax, 6, 8.5, 4.5, 8.5, 'N', '1', '#E8913A')
    # notifications -> users
    rel(ax, 12, 10.2, 4.5, 14.5, 'N', '1', '#6B7280')
    # activity_logs -> users
    rel(ax, 18, 10.2, 4.5, 15, 'N', '1', '#6B7280')
    # student_progress -> students
    rel(ax, 6, 3.5, 2.25, 10.0, '1', '1', '#059669')

    save(fig, '3_er_diagram.png')


# ================================================================
# 4. DATA FLOW DIAGRAM
# ================================================================
def draw_dfd():
    fig, ax = plt.subplots(figsize=(22, 16))
    fig.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    ax.set_xlim(-1, 23)
    ax.set_ylim(-1, 17)
    ax.axis('off')

    ax.text(11, 16.5, 'MindTrack — Data Flow Diagram (Level 1)', fontsize=22, fontweight='bold',
            ha='center', va='center', color=C_TEXT)
    ax.text(11, 15.9, 'Showing major processes, data stores, and external entities', fontsize=12,
            ha='center', va='center', color=C_LINE)

    def draw_external(ax, x, y, label, w=3, h=0.8, color=C_EXTERNAL_BORDER):
        rect = FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.08",
                              facecolor=C_EXTERNAL, edgecolor=color, linewidth=2.2, zorder=3)
        ax.add_patch(rect)
        ax.text(x, y, label, fontsize=10, ha='center', va='center', color=color, fontweight='bold', zorder=4)
        return (x, y)

    def draw_process(ax, x, y, num, label, w=3.2, h=1.2, color=C_PROCESS_BORDER):
        circle = plt.Circle((x, y), h/2 + 0.3, facecolor=C_PROCESS, edgecolor=color,
                            linewidth=2.2, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y + 0.2, f'{num}', fontsize=9, ha='center', va='center', color=color,
                fontweight='bold', zorder=4)
        ax.text(x, y - 0.15, label, fontsize=9, ha='center', va='center', color=C_TEXT,
                fontweight='bold', zorder=4, wrap=True)
        return (x, y)

    def draw_datastore(ax, x, y, label, w=3.8, h=0.7, color=C_DATASTORE_BORDER):
        rect = FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.05",
                              facecolor=C_DATASTORE, edgecolor=color, linewidth=2, zorder=3)
        ax.add_patch(rect)
        ax.plot([x - w/2, x - w/2], [y - h/2, y + h/2], color=color, linewidth=3, zorder=4)
        ax.text(x + 0.1, y, label, fontsize=9.5, ha='center', va='center', color=color,
                fontweight='bold', zorder=4)
        return (x, y)

    def flow(ax, x1, y1, x2, y2, label, color=C_LINE, offset=(0, 0.15)):
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle='->', color=color, lw=1.8,
                                     connectionstyle='arc3,rad=0.1'))
        mx = (x1 + x2) / 2 + offset[0]
        my = (y1 + y2) / 2 + offset[1]
        ax.text(mx, my, label, fontsize=7.5, ha='center', va='center', color=color,
                fontstyle='italic',
                bbox=dict(boxstyle='round,pad=0.15', facecolor='white', edgecolor='none', alpha=0.9))

    # External entities
    e_student = draw_external(ax, 1.5, 14, 'Student', color=C_ACTOR_STUDENT)
    e_teacher = draw_external(ax, 1.5, 8.5, 'Teacher', color=C_ACTOR_TEACHER)
    e_admin = draw_external(ax, 1.5, 3, 'Admin', color=C_ACTOR_ADMIN)
    e_groq = draw_external(ax, 20, 8.5, 'Groq LLM\n(AI Engine)', w=3, h=1, color=C_GROQ)

    # Processes
    p1 = draw_process(ax, 6, 14, '1.0', 'Authentication\n& Role Mgmt')
    p2 = draw_process(ax, 11, 14, '2.0', 'Assessment\nManagement')
    p3 = draw_process(ax, 16, 14, '3.0', 'AI Response\nEvaluation')
    p4 = draw_process(ax, 16, 10, '4.0', 'Results &\nPDF Generation')
    p5 = draw_process(ax, 6, 8.5, '5.0', 'Student &\nClass Mgmt')
    p6 = draw_process(ax, 11, 8.5, '6.0', 'Dashboard\n& Analytics')
    p7 = draw_process(ax, 6, 3, '7.0', 'User & System\nAdministration')

    # Data stores
    d1 = draw_datastore(ax, 11, 5.5, 'D1  Supabase Database', w=5)
    d2 = draw_datastore(ax, 11, 1, 'D2  Activity Logs', w=4)
    d3 = draw_datastore(ax, 20, 5.5, 'D3  PDF Reports', w=3.5)

    # Flows from Student
    flow(ax, 3, 14, 4.5, 14, 'Credentials', C_ACTOR_STUDENT)
    flow(ax, 7.5, 14, 9.5, 14, 'Auth Token', '#6366F1')
    flow(ax, 12.5, 14, 14.5, 14, 'Responses', '#0891B2')
    flow(ax, 16, 12.5, 16, 11.5, 'Evaluated\nResults', '#7C3AED')

    # AI flow
    flow(ax, 17.5, 14, 18.8, 9.5, 'Prompt +\nResponses', C_GROQ, offset=(0.8, 0))
    flow(ax, 18.5, 8, 17.5, 13, 'AI Evaluation\nJSON', C_GROQ, offset=(-0.8, 0))

    # Teacher flows
    flow(ax, 3, 8.5, 4.5, 8.5, 'Student\nData', C_ACTOR_TEACHER)
    flow(ax, 7.5, 8.5, 9.5, 8.5, 'Stats\nRequest', C_ACTOR_TEACHER)
    flow(ax, 3, 9.2, 4.5, 14, 'Login', C_ACTOR_TEACHER, offset=(-0.5, 0))

    # Results & PDF
    flow(ax, 17.5, 10, 18.8, 6.2, 'PDF\nFile', C_PDF, offset=(0.3, 0))
    flow(ax, 16, 8.5, 16, 9, 'Report\nRequest', '#7C3AED', offset=(0.5, 0))

    # Database flows
    flow(ax, 6, 7, 9, 5.8, 'Student\nRecords', C_DATASTORE_BORDER, offset=(-0.3, 0))
    flow(ax, 11, 7, 11, 6.2, 'Stats\nData', C_DATASTORE_BORDER)
    flow(ax, 11, 12.5, 11, 6.2, 'Assessment\nSessions', C_DATASTORE_BORDER, offset=(0.6, 0))
    flow(ax, 14.5, 9.5, 13, 6.2, 'Results\nData', C_DATASTORE_BORDER, offset=(0.3, 0))
    flow(ax, 6, 14, 6, 13, '', '#6366F1')

    # Admin flows
    flow(ax, 3, 3, 4.5, 3, 'Admin\nActions', C_ACTOR_ADMIN)
    flow(ax, 6, 4.5, 9, 5.2, 'User\nUpdates', C_ACTOR_ADMIN, offset=(-0.3, 0.3))
    flow(ax, 7.5, 3, 9, 1.3, 'Log\nEntries', '#6B7280', offset=(-0.2, 0))

    save(fig, '4_data_flow_diagram.png')


# ================================================================
# 5. SYSTEM FLOW DIAGRAM
# ================================================================
def draw_system_flow():
    fig, ax = plt.subplots(figsize=(22, 18))
    fig.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    ax.set_xlim(-1, 23)
    ax.set_ylim(-1, 19)
    ax.axis('off')

    ax.text(11, 18.5, 'MindTrack — System Flow Diagram', fontsize=22, fontweight='bold',
            ha='center', va='center', color=C_TEXT)
    ax.text(11, 17.9, 'End-to-End Application Flow Architecture', fontsize=12,
            ha='center', va='center', color=C_LINE)

    def draw_box(ax, x, y, label, w=3.5, h=1.0, color='#3B82F6', sublabel=None):
        rect = FancyBboxPatch((x - w/2, y - h/2), w, h, boxstyle="round,pad=0.12",
                              facecolor=color, edgecolor='white', linewidth=2, zorder=3, alpha=0.9)
        ax.add_patch(rect)
        if sublabel:
            ax.text(x, y + 0.15, label, fontsize=10, ha='center', va='center', color='white',
                    fontweight='bold', zorder=4)
            ax.text(x, y - 0.15, sublabel, fontsize=7.5, ha='center', va='center', color='#E2E8F0',
                    zorder=4)
        else:
            ax.text(x, y, label, fontsize=10, ha='center', va='center', color='white',
                    fontweight='bold', zorder=4)
        return (x, y)

    def draw_decision(ax, x, y, label, size=0.7, color='#F59E0B'):
        diamond = plt.Polygon([(x, y + size), (x + size * 1.3, y), (x, y - size), (x - size * 1.3, y)],
                              facecolor=color, edgecolor='white', linewidth=2, zorder=3, alpha=0.9)
        ax.add_patch(diamond)
        ax.text(x, y, label, fontsize=8, ha='center', va='center', color='white',
                fontweight='bold', zorder=4)
        return (x, y)

    def arrow(ax, x1, y1, x2, y2, label='', color=C_LINE, lw=2):
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle='->', color=color, lw=lw,
                                     connectionstyle='arc3,rad=0'))
        if label:
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            ax.text(mx, my + 0.2, label, fontsize=7.5, ha='center', va='center', color=color,
                    fontweight='bold',
                    bbox=dict(boxstyle='round,pad=0.1', facecolor='white', edgecolor='none', alpha=0.9))

    # ---------- Flow Steps ----------
    # Start
    start = plt.Circle((3, 17), 0.4, facecolor='#10B981', edgecolor='white', linewidth=2, zorder=3)
    ax.add_patch(start)
    ax.text(3, 17, 'START', fontsize=8, ha='center', va='center', color='white', fontweight='bold', zorder=4)

    b1 = draw_box(ax, 3, 15.5, 'App Launch', sublabel='main.dart → init', color='#6366F1')
    b2 = draw_box(ax, 3, 13.8, 'Role Selection', sublabel='Student / Teacher / Admin', color='#8B5CF6')
    b3 = draw_box(ax, 3, 12.1, 'Login / Sign Up', sublabel='Email + Password', color='#3B82F6')

    d1 = draw_decision(ax, 3, 10.3, 'Auth\nValid?', color='#F59E0B')

    b_fail = draw_box(ax, 0, 10.3, 'Show Error', w=2.2, h=0.7, color='#EF4444')

    d2 = draw_decision(ax, 3, 8.5, 'Role?', color='#F59E0B')

    # Student path
    b_s1 = draw_box(ax, 8, 12, 'Student Dashboard', sublabel='Stats, History', color=C_ACTOR_STUDENT, w=3.5)
    b_s2 = draw_box(ax, 8, 10.3, 'Select Age &\nStart Assessment', color=C_ACTOR_STUDENT, w=3.5)
    b_s3 = draw_box(ax, 8, 8.5, 'Answer Questions', sublabel='MCQ / Short Answer / Matching', color=C_ACTOR_STUDENT, w=3.5)
    b_s4 = draw_box(ax, 8, 6.5, 'AI Evaluates\nResponses', sublabel='Groq LLM API', color=C_GROQ, w=3.5)
    b_s5 = draw_box(ax, 8, 4.5, 'View Results', sublabel='Score, Stage, Criteria', color='#7C3AED', w=3.5)
    b_s6 = draw_box(ax, 8, 2.5, 'Download /\nPrint PDF', color=C_PDF, w=3.5)

    # Teacher path
    b_t1 = draw_box(ax, 15, 12, 'Teacher Dashboard', sublabel='Stats, Students', color=C_ACTOR_TEACHER, w=3.5)
    b_t2 = draw_box(ax, 15, 10.3, 'Manage Students\n& Classes', color=C_ACTOR_TEACHER, w=3.5)
    b_t3 = draw_box(ax, 15, 8.5, 'View Student\nAssessments', color=C_ACTOR_TEACHER, w=3.5)
    b_t4 = draw_box(ax, 15, 6.5, 'Download Student\nPDF Reports', color=C_PDF, w=3.5)

    # Admin path
    b_a1 = draw_box(ax, 20.5, 12, 'Admin Dashboard', sublabel='System Stats', color=C_ACTOR_ADMIN, w=3.5)
    b_a2 = draw_box(ax, 20.5, 10.3, 'Manage Users\n& Permissions', color=C_ACTOR_ADMIN, w=3.5)
    b_a3 = draw_box(ax, 20.5, 8.5, 'View Logs\n& Reports', color=C_ACTOR_ADMIN, w=3.5)

    # Supabase
    b_db = draw_box(ax, 11.5, 0.5, 'Supabase Database', sublabel='PostgreSQL + Auth + Storage', color=C_SUPABASE, w=5, h=1)

    # Arrows
    arrow(ax, 3, 16.6, 3, 16, '')
    arrow(ax, 3, 15, 3, 14.3, '')
    arrow(ax, 3, 13.3, 3, 12.6, '')
    arrow(ax, 3, 11.6, 3, 11, '')
    arrow(ax, 1.7, 10.3, 0.8, 10.3, 'No', '#EF4444')
    arrow(ax, 3, 9.6, 3, 9.2, 'Yes', '#10B981')

    # Role branching
    arrow(ax, 4.3, 8.5, 6.2, 12, 'Student', C_ACTOR_STUDENT, lw=2.5)
    arrow(ax, 4.3, 8.5, 13.2, 12, 'Teacher', C_ACTOR_TEACHER, lw=2.5)
    arrow(ax, 4.3, 8.5, 18.7, 12, 'Admin', C_ACTOR_ADMIN, lw=2.5)

    # Student flow
    arrow(ax, 8, 11.5, 8, 10.8, '')
    arrow(ax, 8, 9.8, 8, 9, '')
    arrow(ax, 8, 8, 8, 7, '')
    arrow(ax, 8, 6, 8, 5, '')
    arrow(ax, 8, 4, 8, 3, '')
    arrow(ax, 8, 2, 9, 1, '', C_PDF)

    # Teacher flow
    arrow(ax, 15, 11.5, 15, 10.8, '')
    arrow(ax, 15, 9.8, 15, 9, '')
    arrow(ax, 15, 8, 15, 7, '')
    arrow(ax, 15, 6, 14, 1, '', C_PDF)

    # Admin flow
    arrow(ax, 20.5, 11.5, 20.5, 10.8, '')
    arrow(ax, 20.5, 9.8, 20.5, 9, '')
    arrow(ax, 20.5, 8, 16.3, 1, '', C_ACTOR_ADMIN)

    # DB connections
    arrow(ax, 8, 6.0, 11, 1.1, 'Save Results', C_SUPABASE)
    arrow(ax, 15, 10, 12, 1.1, 'Read Data', C_SUPABASE)

    # End
    end = plt.Circle((3, 0.5), 0.4, facecolor='#EF4444', edgecolor='white', linewidth=2, zorder=3)
    ax.add_patch(end)
    inner = plt.Circle((3, 0.5), 0.28, facecolor='none', edgecolor='white', linewidth=1.5, zorder=4)
    ax.add_patch(inner)
    ax.text(3, 0.5, 'END', fontsize=8, ha='center', va='center', color='white', fontweight='bold', zorder=5)
    arrow(ax, 0, 9.8, 0, 1, '', '#EF4444')
    arrow(ax, 0, 1, 2.6, 0.7, '', '#EF4444')

    save(fig, '5_system_flow_diagram.png')


# ================================================================
# 6. SEQUENCE DIAGRAM
# ================================================================
def draw_sequence_diagram():
    fig, ax = plt.subplots(figsize=(24, 20))
    fig.set_facecolor(C_BG)
    ax.set_facecolor(C_BG)
    ax.set_xlim(-1, 25)
    ax.set_ylim(-1, 22)
    ax.axis('off')

    ax.text(12, 21.5, 'MindTrack — Sequence Diagram', fontsize=22, fontweight='bold',
            ha='center', va='center', color=C_TEXT)
    ax.text(12, 20.9, 'Student Assessment Flow (Login → PDF Report)', fontsize=12,
            ha='center', va='center', color=C_LINE)

    # Lifeline participants
    participants = [
        (2, 'Student\n(User)', C_ACTOR_STUDENT),
        (6, 'Flutter\nApp', '#6366F1'),
        (10, 'Auth\nProvider', '#DC2626'),
        (14, 'Supabase\nService', C_SUPABASE),
        (18, 'Assessment\nProvider', '#0891B2'),
        (22, 'Groq\nAI / PDF', C_GROQ),
    ]

    top_y = 20
    bottom_y = 0.5

    for px, pname, pcolor in participants:
        # Header box
        rect = FancyBboxPatch((px - 1.2, top_y - 0.1), 2.4, 1.1, boxstyle="round,pad=0.08",
                              facecolor=pcolor, edgecolor='white', linewidth=2, zorder=5)
        ax.add_patch(rect)
        ax.text(px, top_y + 0.45, pname, fontsize=9, ha='center', va='center', color='white',
                fontweight='bold', zorder=6)
        # Lifeline
        ax.plot([px, px], [top_y - 0.1, bottom_y], color=pcolor, linewidth=1.5, linestyle='--',
                alpha=0.4, zorder=1)

    # Activation bars
    def activation(ax, x, y_top, y_bot, color='#E2E8F0'):
        rect = FancyBboxPatch((x - 0.2, y_bot), 0.4, y_top - y_bot, boxstyle="round,pad=0.02",
                              facecolor=color, edgecolor=C_BORDER, linewidth=1, alpha=0.6, zorder=2)
        ax.add_patch(rect)

    # Message arrow
    def msg(ax, x1, x2, y, label, color=C_LINE, dashed=False, response=False):
        style = '->' if not response else '->'
        ls = '--' if dashed or response else '-'
        ax.annotate('', xy=(x2, y), xytext=(x1, y),
                     arrowprops=dict(arrowstyle=style, color=color, lw=1.5, linestyle=ls))
        mx = (x1 + x2) / 2
        ax.text(mx, y + 0.22, label, fontsize=7.5, ha='center', va='center', color=color,
                fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.12', facecolor='white', edgecolor='none', alpha=0.95))

    # Step labels (left side)
    def step(ax, y, num, label):
        ax.text(-0.5, y, f'{num}', fontsize=9, ha='center', va='center', color='white', fontweight='bold',
                bbox=dict(boxstyle='circle,pad=0.15', facecolor='#6366F1', edgecolor='none'), zorder=5)
        ax.text(-0.5, y - 0.35, label, fontsize=7, ha='center', va='center', color=C_LINE, fontstyle='italic')

    # Activation bars
    activation(ax, 6, 19.5, 1, '#E0E7FF')
    activation(ax, 10, 18.5, 16, '#FEE2E2')
    activation(ax, 14, 17.5, 2, '#D1FAE5')
    activation(ax, 18, 13, 3.5, '#CFFAFE')
    activation(ax, 22, 10.5, 4, '#D1FAE5')

    # ===== Messages =====
    y = 19.5
    step(ax, y, 1, 'Select\nRole')
    msg(ax, 2, 6, y, '1. selectRole(Student)', C_ACTOR_STUDENT)

    y = 18.5
    step(ax, y, 2, 'Login')
    msg(ax, 2, 6, y, '2. enterCredentials(email, pwd)', C_ACTOR_STUDENT)
    msg(ax, 6, 10, y - 0.5, '3. signIn(email, pwd)', '#6366F1')
    msg(ax, 10, 14, y - 1.0, '4. auth.signInWithPassword()', '#DC2626')
    msg(ax, 14, 10, y - 1.5, '5. return AuthResponse', C_SUPABASE, response=True)
    msg(ax, 10, 14, y - 2.0, '6. getUserProfile(userId)', '#DC2626')
    msg(ax, 14, 10, y - 2.5, '7. return UserProfile', C_SUPABASE, response=True)
    msg(ax, 10, 6, y - 3.0, '8. navigate → Dashboard', '#DC2626', response=True)

    y = 14
    step(ax, y, 3, 'View\nDash')
    msg(ax, 6, 14, y, '9. getStudentDashboardStats()', '#6366F1')
    msg(ax, 14, 6, y - 0.5, '10. return stats, assessments', C_SUPABASE, response=True)
    msg(ax, 2, 6, y - 0.5, '  [Student views dashboard]', C_ACTOR_STUDENT, dashed=True)

    y = 12.5
    step(ax, y, 4, 'Start\nAssess')
    msg(ax, 2, 6, y, '11. startNewAssessment(age)', C_ACTOR_STUDENT)
    msg(ax, 6, 18, y - 0.5, '12. initializeLearner() → startAssessment()', '#6366F1')
    msg(ax, 18, 14, y - 1.0, '13. createAssessmentSession()', '#0891B2')
    msg(ax, 14, 18, y - 1.5, '14. return sessionId', C_SUPABASE, response=True)
    msg(ax, 18, 6, y - 2.0, '15. return questions[]', '#0891B2', response=True)

    y = 9.5
    step(ax, y, 5, 'Answer\nQuestions')
    msg(ax, 2, 6, y, '16. submitAnswer(response)', C_ACTOR_STUDENT)
    msg(ax, 6, 18, y - 0.5, '17. submitResponse(answer)', '#6366F1')

    # Loop box
    loop_rect = FancyBboxPatch((1, 8.2), 20, 2, boxstyle="round,pad=0.08",
                                facecolor='none', edgecolor='#6366F1', linewidth=1.5, linestyle='--', zorder=1)
    ax.add_patch(loop_rect)
    ax.text(1.5, 10, 'loop', fontsize=8, color='#6366F1', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.08', facecolor='#EEF2FF', edgecolor='#6366F1'))
    ax.text(4, 10, '[for each question]', fontsize=7.5, color='#6366F1', fontstyle='italic')

    msg(ax, 18, 14, y - 1.0, '18. saveResponse()', '#0891B2')

    y = 7.5
    step(ax, y, 6, 'AI\nEval')
    msg(ax, 18, 22, y, '19. completeAssessment()', '#0891B2')
    msg(ax, 22, 22, y - 0.4, '  Groq evaluateResponses()', C_GROQ, dashed=True)
    msg(ax, 22, 18, y - 0.9, '20. return AssessmentResult', C_GROQ, response=True)
    msg(ax, 18, 14, y - 1.4, '21. saveAssessmentResult()', '#0891B2')
    msg(ax, 14, 18, y - 1.9, '22. return resultId', C_SUPABASE, response=True)

    y = 4.8
    step(ax, y, 7, 'View\nResults')
    msg(ax, 18, 6, y, '23. navigate → ResultsScreen', '#0891B2', response=True)
    msg(ax, 6, 2, y - 0.5, '24. display score, stage, criteria', '#6366F1', response=True)

    y = 3.5
    step(ax, y, 8, 'PDF')
    msg(ax, 2, 6, y, '25. downloadPDF()', C_ACTOR_STUDENT)
    msg(ax, 6, 22, y - 0.5, '26. PdfService.generateAndShareReport()', '#6366F1')
    msg(ax, 22, 6, y - 1.0, '27. return PDF bytes → share', C_GROQ, response=True)
    msg(ax, 6, 2, y - 1.5, '28. PDF shared/downloaded', '#6366F1', response=True)

    # Alt box for Teacher viewing PDF
    alt_rect = FancyBboxPatch((1, 0.8), 22, 1.2, boxstyle="round,pad=0.08",
                               facecolor='#FFF7ED', edgecolor=C_ACTOR_TEACHER, linewidth=1.5, zorder=1)
    ax.add_patch(alt_rect)
    ax.text(1.5, 1.8, 'alt', fontsize=8, color=C_ACTOR_TEACHER, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.08', facecolor='#FFEDD5', edgecolor=C_ACTOR_TEACHER))
    ax.text(4, 1.8, '[Teacher views student report]', fontsize=7.5, color=C_ACTOR_TEACHER, fontstyle='italic')
    msg(ax, 6, 14, 1.2, 'getAssessmentResult(sessionId)', C_ACTOR_TEACHER)
    msg(ax, 14, 22, 1.2, 'PdfService.generateAndShareReport()', C_ACTOR_TEACHER)

    save(fig, '6_sequence_diagram.png')


# ================================================================
# MAIN
# ================================================================
if __name__ == '__main__':
    print("\n📊 Generating MindTrack Software Engineering Diagrams...")
    print(f"📁 Output directory: {OUTPUT_DIR}\n")

    draw_use_case_diagram()
    draw_class_diagram()
    draw_er_diagram()
    draw_dfd()
    draw_system_flow()
    draw_sequence_diagram()

    print(f"\n✅ All 6 diagrams generated successfully in: {OUTPUT_DIR}")
    print("   1. 1_use_case_diagram.png")
    print("   2. 2_uml_class_diagram.png")
    print("   3. 3_er_diagram.png")
    print("   4. 4_data_flow_diagram.png")
    print("   5. 5_system_flow_diagram.png")
    print("   6. 6_sequence_diagram.png")
