// ===== PIAGET WEBSITE — FULL INTERACTIVE JS =====

document.addEventListener('DOMContentLoaded', () => {
  applyEnv();
  initNavbar();
  initAgeChips();
  initDemo();
  initActivityTabs();
  initScrollAnimations();
});

// ===== APPLY ENV CONFIG TO DOM =====
function applyEnv() {
  // Title & meta
  document.title = `${ENV.APP_NAME} — ${ENV.APP_TAGLINE}`;
  const metaDesc = document.querySelector('meta[name="description"]');
  if (metaDesc) metaDesc.setAttribute('content', ENV.APP_DESCRIPTION);

  // Hero badge
  const heroBadge = document.querySelector('.hero-badge');
  if (heroBadge) heroBadge.innerHTML = `🤖 Powered by AI &bull; ${escapeHTML(ENV.AI_MODEL_SHORT)}`;

  // Hero stats
  const stats = document.querySelectorAll('.hero-stats .stat strong');
  if (stats.length >= 4) {
    stats[0].textContent = Object.keys(ENV.STAGES).length;
    stats[1].textContent = `${Object.keys(ENV.STAGES).length * ENV.CRITERIA_PER_STAGE}+`;
    stats[2].textContent = ENV.QUESTIONS_PER_SESSION;
    stats[3].textContent = ENV.AGE_RANGE;
  }

  // AI spec values
  const specVals = document.querySelectorAll('.spec-val');
  if (specVals.length >= 8) {
    specVals[0].textContent = ENV.AI_MODEL;
    specVals[1].textContent = ENV.AI_PROVIDER;
    specVals[2].textContent = `${ENV.AI_TEMPERATURE} (dynamic)`;
    specVals[3].textContent = `${ENV.AI_MAX_TOKENS.toLocaleString()} per request`;
    specVals[4].textContent = ENV.AI_OUTPUT_FORMAT;
    specVals[5].textContent = `${ENV.AI_RETRY_ATTEMPTS} attempts with dedup`;
    specVals[6].textContent = `${ENV.QUESTIONS_PER_SESSION} (${ENV.MCQ_COUNT} MCQ + ${ENV.DESCRIPTIVE_COUNT} Descriptive)`;
    specVals[7].textContent = `${ENV.CRITERIA_PER_STAGE} unique indicators`;
  }

  // Footer
  const footerBottom = document.querySelector('.footer-bottom p');
  if (footerBottom) footerBottom.innerHTML = ENV.FOOTER_TEXT;
}

// ===== NAVBAR =====
function initNavbar() {
  const navbar = document.getElementById('navbar');
  const toggle = document.getElementById('navToggle');
  const links = document.getElementById('navLinks');

  window.addEventListener('scroll', () => {
    navbar.classList.toggle('scrolled', window.scrollY > 40);
  });

  toggle.addEventListener('click', () => {
    links.classList.toggle('active');
  });

  links.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => links.classList.remove('active'));
  });
}

// ===== COGNITIVE STAGE DATA =====
const stageData = {
  sensorimotor: {
    name: 'Sensorimotor', range: '0–2 years',
    desc: 'Learning through senses and motor actions (Ages 0-2)',
    indicators: ['Object Permanence','Cause-Effect Understanding','Goal-Directed Behavior','Imitation','Sensory Exploration','Coordination of Actions','Recognition','Trial & Error Learning','Anticipation','Mental Representation'],
  },
  preoperational: {
    name: 'Preoperational', range: '2–7 years',
    desc: 'Symbolic but illogical thinking (Ages 2-7)',
    indicators: ['Symbolic Thinking','Egocentrism','Centration','Conservation','Animistic Thinking','Irreversibility','Intuitive Thought','Pretend Play','Perceptual Dominance','Egocentric Speech'],
  },
  concreteOperational: {
    name: 'Concrete Operational', range: '7–11 years',
    desc: 'Logical thinking about concrete objects (Ages 7-11)',
    indicators: ['Conservation','Reversibility','Decentration','Classification','Seriation','Transitive Inference','Logical Operations','Cause-Effect Reasoning','Perspective-Taking','Concrete Problem Solving'],
  },
  formalOperational: {
    name: 'Formal Operational', range: '11+ years',
    desc: 'Abstract and hypothetical thinking (Ages 11+)',
    indicators: ['Abstract Thinking','Hypothetical Reasoning','Hypothetico-Deductive','Systematic Problem Solving','Metacognition','Moral Reasoning','Relativistic Thinking','Propositional Logic','Future Orientation','Ideological Thinking'],
  }
};

function getStageFromAge(age) {
  for (const [key, stage] of Object.entries(ENV.STAGES)) {
    if (age <= stage.ageMax) return key;
  }
  return Object.keys(ENV.STAGES).pop();
}

// ===== AGE CHIPS =====
function initAgeChips() {
  const chips = document.querySelectorAll('.age-chip');
  chips.forEach(chip => {
    chip.addEventListener('click', () => {
      chips.forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      const age = parseInt(chip.dataset.age);
      const stageKey = getStageFromAge(age);
      const stage = stageData[stageKey];
      document.getElementById('demoStageName').textContent = stage.name;
      document.getElementById('demoStageDesc').textContent = stage.desc;
    });
  });
}

// ===== DEMO QUESTION BANKS =====
const questionBanks = {
  sensorimotor: [
    { text: 'You hide a toy under a blanket while a baby watches. What does the baby most likely do?', criterion: 'Object Permanence', type: 'mcq', options: ['Looks for the toy under the blanket','Cries because the toy is gone forever','Plays with the blanket instead','Forgets about the toy immediately'], correct: 0, scores: [90,25,40,20] },
    { text: 'A baby accidentally hits a rattle and it makes a sound. The baby then tries to hit it again. What does this show?', criterion: 'Cause-Effect Understanding', type: 'mcq', options: ['The baby understands hitting causes sound','The baby is just moving randomly','The baby does not like the sound','The baby wants a different toy'], correct: 0, scores: [95,20,15,10] },
    { text: 'When a parent waves goodbye, the baby tries to wave back. What cognitive ability is developing?', criterion: 'Imitation', type: 'mcq', options: ['Early imitation — copying observed actions','Language comprehension','Abstract thinking about greetings','Random arm movement'], correct: 0, scores: [95,40,15,20] },
    { text: 'Describe what happens when a 1-year-old drops a spoon from a high chair and then leans over to look for it.', criterion: 'Goal-Directed Behavior', type: 'short' },
    { text: 'A baby pushes a button on a toy and music plays. The baby laughs and pushes it again. What developmental milestone does this represent?', criterion: 'Trial & Error Learning', type: 'mcq', options:['Learning through experimentation — repeating actions that produce results','Musical talent developing early','The baby prefers one toy over others','Simple reflex response'], correct: 0, scores: [95,20,30,25] },
  ],
  preoperational: [
    { text: 'If I pour water from a tall, thin glass into a short, wide glass, does the amount of water change?', criterion: 'Conservation', type: 'mcq', options: ['Yes — the tall glass had more water because it was higher','No — the amount stays the same regardless of container shape','Maybe — it depends on how fast you pour','The wide glass has more because it is bigger'], correct: 1, scores: [20,90,40,25] },
    { text: 'A child says "The sun went to sleep" when it gets dark. What does this reveal about their thinking?', criterion: 'Animistic Thinking', type: 'mcq', options: ['They give human qualities to non-living things','They understand astronomy very well','They are making a scientific observation','They learned this from a teacher'], correct: 0, scores: [90,15,25,35] },
    { text: 'When looking at a model of mountains from one side, a child says their friend on the other side sees the same view. What is this called?', criterion: 'Egocentrism', type: 'mcq', options: ['Egocentrism — inability to see from another\'s perspective','Good observation skills','Empathy — understanding others\' feelings','Advanced spatial reasoning'], correct: 0, scores: [95,20,35,25] },
    { text: 'When you pretend a banana is a telephone and hold it to your ear, explain what you are doing and why the banana can be used this way.', criterion: 'Symbolic Thinking', type: 'short' },
    { text: 'A child sees two rows of 5 coins. When one row is spread out, they say it has "more." Why might they think this?', criterion: 'Centration', type: 'mcq', options: ['They focus on the length of the row instead of counting — centration','They can\'t count to 5','They are guessing randomly','They prefer longer rows of coins'], correct: 0, scores: [95,20,15,25] },
  ],
  concreteOperational: [
    { text: 'If you flatten a ball of clay into a pancake shape, has the amount of clay changed?', criterion: 'Conservation', type: 'mcq', options: ['No — the amount of clay stays the same; only the shape changed','Yes — the pancake is bigger so there is more clay','Yes — the ball was thicker so it had more','It depends on how hard you press'], correct: 0, scores: [95,20,25,35] },
    { text: 'If Alex is taller than Ben, and Ben is taller than Charlie, who is the shortest?', criterion: 'Transitive Inference', type: 'mcq', options: ['Charlie','Ben','Alex','Cannot tell from this information'], correct: 0, scores: [95,20,15,30] },
    { text: 'You have: Rose, Tulip, Dog, Cat. Which grouping best organizes these items?', criterion: 'Classification', type: 'mcq', options: ['Flowers: Rose & Tulip; Animals: Dog & Cat','Living things: all together in one group','Things that are colorful vs not colorful','Outdoor things vs indoor things'], correct: 0, scores: [95,45,25,30] },
    { text: 'You added 3 blocks to a tower of 5, making 8. If you remove 3 blocks, how many remain? Explain your reasoning.', criterion: 'Reversibility', type: 'short' },
    { text: 'A plant on the windowsill grows taller than one in a dark closet. What can we conclude about why?', criterion: 'Cause-Effect Reasoning', type: 'mcq', options: ['Sunlight is causing the plant to grow more — a cause-effect relationship','The windowsill plant is a different species','The closet plant is sleeping','Plants grow randomly regardless of light'], correct: 0, scores: [95,30,15,20] },
  ],
  formalOperational: [
    { text: 'Imagine a society where all laws were suddenly removed. Which response shows the most sophisticated thinking?', criterion: 'Hypothetical Reasoning', type: 'mcq', options: ['People would need to develop new social contracts balancing freedom and responsibility through collective decision-making','Everyone would just fight and steal everything','People would be happier without rules','Nothing would change because people are naturally good'], correct: 0, scores: [95,25,20,35] },
    { text: 'A city wants to reduce air pollution. What approach demonstrates the most systematic problem-solving?', criterion: 'Systematic Problem Solving', type: 'mcq', options: ['Analyze multiple variables (traffic, industry, energy sources, geography) and test integrated solutions across different sectors','Ban all cars immediately','Plant more trees everywhere','Just tell factories to stop polluting'], correct: 0, scores: [95,25,35,20] },
    { text: 'Two classmates disagree about whether homework is helpful. One says it builds discipline; the other says it causes stress. Which is the most advanced way to think about this?', criterion: 'Relativistic Thinking', type: 'mcq', options: ['Both perspectives have valid foundations based on different values and experiences; understanding each doesn\'t require abandoning your own view','The first person is right because adults say homework is important','The second person is right because students know best','There is no right answer so the debate is pointless'], correct: 0, scores: [95,30,30,20] },
    { text: 'All mammals are warm-blooded. Whales are mammals. What can you conclude, and explain the logical structure of your reasoning?', criterion: 'Propositional Logic', type: 'short' },
    { text: 'If all students study the same hours, why might their test scores still differ? Pick the most sophisticated explanation.', criterion: 'Abstract Thinking', type: 'mcq', options: ['Grades depend on interconnected factors: prior knowledge, learning style, test format, sleep, nutrition, and aptitude interact in complex ways','Some students are just smarter than others','The teacher grades unfairly','The test was too hard for some students'], correct: 0, scores: [95,30,20,25] },
  ],
};

// ===== DEMO ENGINE =====
let demoState = { questions: [], current: 0, score: 0, answers: [], stage: '' };

function initDemo() {
  document.getElementById('startDemoBtn').addEventListener('click', startDemo);
}

function startDemo() {
  const activeChip = document.querySelector('.age-chip.active');
  const age = parseInt(activeChip.dataset.age);
  const stageKey = getStageFromAge(age);
  const bank = questionBanks[stageKey];

  demoState = {
    questions: bank,
    current: 0,
    score: 0,
    answers: [],
    stage: stageData[stageKey].name,
    stageKey: stageKey,
  };

  document.getElementById('demoWelcome').classList.add('hidden');
  document.getElementById('demoResults').classList.add('hidden');
  document.getElementById('demoAssessment').classList.remove('hidden');

  renderQuestion();
}

function renderQuestion() {
  const q = demoState.questions[demoState.current];
  const total = demoState.questions.length;
  const area = document.getElementById('demoQuestionArea');

  document.getElementById('demoQNum').textContent = `Question ${demoState.current + 1}/${total}`;
  document.getElementById('demoProgressFill').style.width = `${((demoState.current) / total) * 100}%`;
  document.getElementById('demoScore').textContent = `Score: ${demoState.score}`;

  let html = `
    <div class="demo-q-tag">${demoState.stage}</div>
    <p class="demo-q-text">${escapeHTML(q.text)}</p>
    <div class="demo-q-criterion">🔍 ${escapeHTML(q.criterion)}</div>
  `;

  if (q.type === 'mcq') {
    html += '<div class="demo-q-options">';
    q.options.forEach((opt, i) => {
      html += `<button class="demo-opt" data-index="${i}">
        <span class="demo-opt-marker">○</span>
        <span>${escapeHTML(opt)}</span>
      </button>`;
    });
    html += '</div>';
  } else {
    html += `
      <div class="demo-textarea-label">✏️ Type your detailed answer below</div>
      <textarea class="demo-textarea" placeholder="Enter your thoughtful answer here..." rows="5"></textarea>
      <button class="demo-submit-btn" id="demoSubmitShort">✓ Submit Answer</button>
    `;
  }

  area.innerHTML = html;

  if (q.type === 'mcq') {
    area.querySelectorAll('.demo-opt').forEach(btn => {
      btn.addEventListener('click', () => handleMCQAnswer(parseInt(btn.dataset.index)));
    });
  } else {
    document.getElementById('demoSubmitShort').addEventListener('click', handleShortAnswer);
  }
}

function handleMCQAnswer(index) {
  const q = demoState.questions[demoState.current];
  const opts = document.querySelectorAll('.demo-opt');

  opts.forEach((opt, i) => {
    opt.style.pointerEvents = 'none';
    if (i === index) {
      opt.classList.add('selected');
      opt.querySelector('.demo-opt-marker').textContent = '✓';
    }
  });

  const score = q.scores[index];
  demoState.score += score;
  demoState.answers.push({ criterion: q.criterion, score: score, answer: q.options[index] });

  setTimeout(() => advanceQuestion(), 600);
}

function handleShortAnswer() {
  const textarea = document.querySelector('.demo-textarea');
  const text = textarea.value.trim();
  if (!text) {
    textarea.style.borderColor = '#ef4444';
    textarea.placeholder = 'Please provide an answer before continuing...';
    return;
  }

  const q = demoState.questions[demoState.current];
  // For demo, score descriptive at 60 (developing)
  const score = 60;
  demoState.score += score;
  demoState.answers.push({ criterion: q.criterion, score: score, answer: text });

  advanceQuestion();
}

function advanceQuestion() {
  demoState.current++;
  if (demoState.current >= demoState.questions.length) {
    showResults();
  } else {
    renderQuestion();
  }
}

function showResults() {
  document.getElementById('demoAssessment').classList.add('hidden');
  document.getElementById('demoResults').classList.remove('hidden');

  const total = demoState.questions.length;
  const avgScore = Math.round(demoState.score / total);
  const scoreClass = avgScore >= ENV.SCORE_ACHIEVED_MIN ? 'green' : avgScore >= ENV.SCORE_DEVELOPING_MIN ? 'orange' : 'red';
  const label = avgScore >= ENV.SCORE_ACHIEVED_MIN ? 'Excellent' : avgScore >= 60 ? 'Good' : avgScore >= ENV.SCORE_DEVELOPING_MIN ? 'Fair' : 'Needs Support';

  let criterionHTML = '';
  demoState.answers.forEach(a => {
    const s = a.score;
    const statusClass = s >= ENV.SCORE_ACHIEVED_MIN ? 'achieved' : s >= ENV.SCORE_DEVELOPING_MIN ? 'developing' : 'not-achieved';
    const statusIcon = s >= ENV.SCORE_ACHIEVED_MIN ? '✓' : s >= ENV.SCORE_DEVELOPING_MIN ? '⚡' : '✗';
    const barColor = s >= ENV.SCORE_ACHIEVED_MIN ? ENV.COLOR_SUCCESS : s >= ENV.SCORE_DEVELOPING_MIN ? ENV.COLOR_WARNING : ENV.COLOR_ERROR;
    criterionHTML += `
      <div class="dr-criterion">
        <div class="dr-crit-status ${statusClass}">${statusIcon}</div>
        <span class="dr-crit-name">${escapeHTML(a.criterion)}</span>
        <span class="dr-crit-score">${s}%</span>
        <div class="dr-crit-bar"><div class="dr-crit-bar-fill" style="width:${s}%;background:${barColor}"></div></div>
      </div>`;
  });

  const strengths = demoState.answers.filter(a => a.score >= ENV.SCORE_ACHIEVED_MIN).map(a => a.criterion);
  const developing = demoState.answers.filter(a => a.score >= ENV.SCORE_DEVELOPING_MIN && a.score < ENV.SCORE_ACHIEVED_MIN).map(a => a.criterion);
  const needsWork = demoState.answers.filter(a => a.score < ENV.SCORE_DEVELOPING_MIN).map(a => a.criterion);

  const resultsEl = document.getElementById('demoResults');
  resultsEl.innerHTML = `
    <div class="dr-header">
      <div class="dr-trophy">🏆</div>
      <div class="dr-score ${scoreClass}">${avgScore}%</div>
      <div class="dr-label">${label}</div>
      <div class="dr-stage">${demoState.stage}</div>
    </div>
    <div class="dr-breakdown">
      <h4>Criterion Breakdown</h4>
      ${criterionHTML}
    </div>
    ${strengths.length ? `<div style="margin-bottom:16px"><h4 style="color:#15803d;font-size:.92rem;margin-bottom:8px">✅ Strengths</h4><p style="font-size:.88rem;color:#666">${strengths.map(escapeHTML).join(', ')}</p></div>` : ''}
    ${developing.length ? `<div style="margin-bottom:16px"><h4 style="color:#a16207;font-size:.92rem;margin-bottom:8px">⚡ Developing</h4><p style="font-size:.88rem;color:#666">${developing.map(escapeHTML).join(', ')}</p></div>` : ''}
    ${needsWork.length ? `<div style="margin-bottom:16px"><h4 style="color:#b91c1c;font-size:.92rem;margin-bottom:8px">🔴 Needs Development</h4><p style="font-size:.88rem;color:#666">${needsWork.map(escapeHTML).join(', ')}</p></div>` : ''}
    <div class="dr-actions">
      <button class="btn btn-primary" onclick="restartDemo()">Try Again</button>
      <button class="btn btn-outline" onclick="backToWelcome()">Back to Setup</button>
    </div>
  `;
}

function restartDemo() {
  startDemo();
}

function backToWelcome() {
  document.getElementById('demoAssessment').classList.add('hidden');
  document.getElementById('demoResults').classList.add('hidden');
  document.getElementById('demoWelcome').classList.remove('hidden');
}

// ===== ACTIVITY TABS =====
const activityData = {
  preoperational: [
    { criterion: 'Conservation', title: 'Conservation Exploration Lab', desc: 'Use water, clay, and blocks to explore conservation of volume, mass, and number. Pour liquids between different containers, reshape clay, and count objects in various arrangements.', materials: '🧪 Containers, water, clay, objects', duration: '⏱ 15-20 min daily' },
    { criterion: 'Egocentrism', title: 'Perspective-Taking Games', desc: 'Practice "Three Mountains Task" adaptations and role-playing. Describe what others can see from different positions to develop decentration.', materials: '🎭 Picture cards, toys, story props', duration: '⏱ 10-15 min, 3-4x weekly' },
    { criterion: 'Symbolic Thinking', title: 'Creative Symbolic Play', desc: 'Engage in pretend play with minimal props, encouraging use of objects to represent other things. Build narratives using imagination.', materials: '🎨 Blocks, fabric, boxes, art supplies', duration: '⏱ 20-30 min daily' },
    { criterion: 'Animistic Thinking', title: 'Living vs Non-Living Exploration', desc: 'Investigate properties of living and non-living things through observation and discussion to develop scientific reasoning.', materials: '🌱 Plants, toys, natural objects, books', duration: '⏱ 15-20 min, 2-3x weekly' },
  ],
  concrete: [
    { criterion: 'Classification', title: 'Advanced Sorting & Taxonomy', desc: 'Practice hierarchical classification with increasing complexity. Sort objects by multiple attributes simultaneously.', materials: '📦 Collections, sorting trays, labels', duration: '⏱ 20-25 min, 3x weekly' },
    { criterion: 'Reversibility', title: 'Reversible Thinking Challenges', desc: 'Solve problems involving reversal of operations. Practice mental math with inverse operations.', materials: '🧮 Math manipulatives, puzzles', duration: '⏱ 15-20 min, 4x weekly' },
    { criterion: 'Transitive Inference', title: 'Logical Reasoning Puzzles', desc: 'Work through comparison chains (if A>B and B>C, then A>C). Use height comparisons, weight ordering, and logical deduction.', materials: '🧩 Puzzles, measuring tools, cards', duration: '⏱ 20 min, 3-4x weekly' },
    { criterion: 'Seriation', title: 'Ordering & Sequencing Practice', desc: 'Arrange objects in logical sequences by various attributes. Create number lines, order events chronologically.', materials: '📏 Objects of varying sizes, timelines', duration: '⏱ 15-20 min, 3x weekly' },
  ],
  formal: [
    { criterion: 'Hypothetical Reasoning', title: 'Scientific Hypothesis Testing', desc: 'Design and conduct experiments testing hypotheses. Practice "if-then" reasoning, predict outcomes before testing, and analyze results systematically.', materials: '🔬 Science kits, journals', duration: '⏱ 30-40 min weekly' },
    { criterion: 'Abstract Thinking', title: 'Conceptual Discussion & Debate', desc: 'Explore abstract concepts through structured discussion. Debate ethical dilemmas, discuss philosophical questions, analyze metaphors.', materials: '📖 Discussion prompts, books, writing', duration: '⏱ 25-30 min, 2-3x weekly' },
    { criterion: 'Systematic Problem Solving', title: 'Strategic Planning Projects', desc: 'Tackle complex, multi-step projects requiring systematic approaches. Use scientific method consistently, create organized plans.', materials: '📋 Planners, strategy games, coding', duration: '⏱ 30-45 min sessions' },
    { criterion: 'Metacognition', title: 'Reflective Thinking Strategies', desc: 'Practice thinking about thinking. Use learning journals, self-assessment rubrics, and strategy reflection.', materials: '📓 Journals, checklists, rubrics', duration: '⏱ 15-20 min daily' },
  ],
};

function initActivityTabs() {
  renderActivities('preoperational');
  document.querySelectorAll('.activity-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.activity-tab').forEach(t => t.classList.remove('active'));
      tab.classList.add('active');
      renderActivities(tab.dataset.stage);
    });
  });
}

function renderActivities(stage) {
  const container = document.getElementById('activityContent');
  const data = activityData[stage] || [];
  container.innerHTML = data.map(a => `
    <div class="activity-card">
      <div class="ac-criterion">${escapeHTML(a.criterion)}</div>
      <h4>${escapeHTML(a.title)}</h4>
      <p>${escapeHTML(a.desc)}</p>
      <div class="ac-meta">
        <span>${a.materials}</span>
        <span>${a.duration}</span>
      </div>
    </div>
  `).join('');
}

// ===== SCROLL ANIMATIONS =====
function initScrollAnimations() {
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.feature-card, .step-card, .stage-card, .ai-card, .tech-card, .activity-card, .prompt-showcase').forEach(el => {
    observer.observe(el);
  });
}

// ===== UTILS =====
function escapeHTML(str) {
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}
