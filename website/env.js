// ===== PIAGET WEBSITE — ENVIRONMENT CONFIGURATION =====
// All configurable values in one place. Edit this file to customize the site.

const ENV = {
  // ── App Branding ──
  APP_NAME: 'Piaget',
  APP_TAGLINE: 'AI-Powered Cognitive Development Assessment',
  APP_DESCRIPTION:
    'Piaget uses AI to assess children\'s cognitive development based on Jean Piaget\'s theory. Identify cognitive stages, get detailed reports, and personalized activity recommendations.',
  FOOTER_TEXT: '© 2026 Piaget — AI-Powered Cognitive Assessment. Built with ❤️ and Flutter.',

  // ── API Keys ──
  // ⚠️ WARNING: This key is exposed in the browser. Use a backend proxy for production.
  GROQ_API_KEY: 'your_groq_api_key_here',

  // ── AI Configuration ──
  AI_MODEL: 'LLaMA 3.3 70B Versatile',
  AI_MODEL_SHORT: 'LLaMA 3.3 70B',
  AI_PROVIDER: 'Groq API',
  AI_TEMPERATURE: '0.7–0.8',
  AI_MAX_TOKENS: 4000,
  AI_OUTPUT_FORMAT: 'Structured JSON',
  AI_RETRY_ATTEMPTS: 3,

  // ── Assessment Settings ──
  QUESTIONS_PER_SESSION: 10,
  MCQ_COUNT: 7,
  DESCRIPTIVE_COUNT: 3,
  CRITERIA_PER_STAGE: 10,
  AGE_RANGE: '0–18',

  // ── Scoring Thresholds ──
  SCORE_ACHIEVED_MIN: 80,
  SCORE_DEVELOPING_MIN: 50,
  SCORE_LABELS: {
    achieved: 'Achieved',
    developing: 'Developing',
    notAchieved: 'Not Yet Achieved',
  },

  // ── Theme Colors ──
  COLOR_PRIMARY: '#0066CC',
  COLOR_PRIMARY_LIGHT: '#66B3FF',
  COLOR_PURPLE: '#9966FF',
  COLOR_PURPLE_LIGHT: '#CC99FF',
  COLOR_SUCCESS: '#00CC66',
  COLOR_SUCCESS_LIGHT: '#66FF99',
  COLOR_WARNING: '#FFAA00',
  COLOR_WARNING_LIGHT: '#FFCC66',
  COLOR_ERROR: '#CC0000',
  COLOR_ACCENT_PINK: '#CC0066',
  COLOR_ACCENT_PINK_LIGHT: '#FF6699',
  COLOR_ACCENT_CYAN: '#0099CC',
  COLOR_ACCENT_CYAN_LIGHT: '#66CCFF',

  // ── Tech Stack ──
  FRAMEWORK: 'Flutter 3.x',
  LANGUAGE: 'Dart 3.8+',
  STATE_MANAGEMENT: 'Provider',
  DESIGN_SYSTEM: 'Material 3',

  // ── Cognitive Stages ──
  STAGES: {
    sensorimotor: { name: 'Sensorimotor', range: '0–2 years', ageMax: 2 },
    preoperational: { name: 'Preoperational', range: '2–7 years', ageMax: 7 },
    concreteOperational: { name: 'Concrete Operational', range: '7–11 years', ageMax: 11 },
    formalOperational: { name: 'Formal Operational', range: '11+ years', ageMax: 99 },
  },
};
