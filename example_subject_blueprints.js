/**
 * Example blueprint for Physics Grade 12 Paper 1
 * Blueprint ID: physics_p1_gr12
 */

const physicsP1Gr12Blueprint = {
  paper: "p1",
  subject: "physics", 
  grade: 12,
  totalMarks: 150,
  topics: {
    "Mechanics": 40,           // 40 marks - Motion, Forces, Momentum
    "Waves and Sound": 30,     // 30 marks - Wave properties, Sound waves
    "Electricity": 35,         // 35 marks - Current, Circuits, Power
    "Magnetism": 25,          // 25 marks - Magnetic fields, Induction
    "Optical Phenomena": 20    // 20 marks - Light, Optics
  },
  cognitiveLevels: {
    "Level 1": 0.25, // 25% - Knowledge/Remember
    "Level 2": 0.35, // 35% - Understand/Apply  
    "Level 3": 0.25, // 25% - Analyze/Evaluate
    "Level 4": 0.15  // 15% - Create/Synthesize
  }
};

/**
 * Example blueprint for Chemistry Grade 12 Paper 1
 * Blueprint ID: chemistry_p1_gr12
 */

const chemistryP1Gr12Blueprint = {
  paper: "p1",
  subject: "chemistry", 
  grade: 12,
  totalMarks: 150,
  topics: {
    "Atomic Structure": 25,      // 25 marks
    "Chemical Bonding": 30,      // 30 marks
    "Organic Chemistry": 35,     // 35 marks
    "Physical Chemistry": 30,    // 30 marks
    "Analytical Chemistry": 30   // 30 marks
  },
  cognitiveLevels: {
    "Level 1": 0.2,  // 20%
    "Level 2": 0.4,  // 40%
    "Level 3": 0.3,  // 30%
    "Level 4": 0.1   // 10%
  }
};

/**
 * Example blueprint for English Grade 12 Paper 1
 * Blueprint ID: english_p1_gr12
 */

const englishP1Gr12Blueprint = {
  paper: "p1",
  subject: "english", 
  grade: 12,
  totalMarks: 100,
  topics: {
    "Comprehension": 30,         // 30 marks
    "Language Usage": 25,        // 25 marks
    "Literature Analysis": 25,   // 25 marks
    "Creative Writing": 20       // 20 marks
  },
  cognitiveLevels: {
    "Level 1": 0.15, // 15%
    "Level 2": 0.30, // 30%
    "Level 3": 0.35, // 35%
    "Level 4": 0.20  // 20%
  }
};

module.exports = {
  physicsP1Gr12Blueprint,
  chemistryP1Gr12Blueprint,
  englishP1Gr12Blueprint
};
