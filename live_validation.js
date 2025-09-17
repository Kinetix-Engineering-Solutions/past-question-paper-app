const admin = require('firebase-admin');

// Initialize Firebase first before importing any modules that depend on it
try {
  const serviceAccount = require('./serviceAccountKey.json');
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase initialized successfully');
} catch (e) {
  console.error("❌ ERROR: serviceAccountKey.json not found or invalid.");
  console.error("Please download it from your Firebase project settings and place it in the root directory.");
  process.exit(1);
}

// Import the test generation service AFTER Firebase is initialized
const { generateBlueprintCompliantTest } = require('./functions/src/services/enhancedTestService');

// Mock blueprint data for testing
const mockBlueprint = {
  subject: "mathematics",
  grade: "12",
  paper: "paper_1",
  totalMarks: 150,
  topics: {
    "Algebra": 40,
    "Functions & Graphs": 50,
    "Differential Calculus": 40,
    "Probability": 20
  },
  cognitiveLevels: {
    "Level 1": 0.2,  // 20%
    "Level 2": 0.35, // 35%
    "Level 3": 0.3,  // 30%
    "Level 4": 0.15  // 15%
  }
};

// Mock the fetchBlueprint function to return our test blueprint
const originalFetchBlueprint = require('./functions/src/services/databaseService').fetchBlueprint;
require('./functions/src/services/databaseService').fetchBlueprint = async (blueprintId) => {
  console.log(`🎯 Using mock blueprint for: ${blueprintId}`);
  return mockBlueprint;
};

/**
 * Runs live validation against the questions_test collection
 */
async function runLiveValidation() {
  console.log('🚀 Starting Live Validation with Real Database...\n');

  try {
    // Test parameters
    const testParams = {
      subject: 'mathematics',
      grade: '12',
      paper: 'paper_1'
    };

    console.log('📋 Test Parameters:');
    console.log(`  Subject: ${testParams.subject}`);
    console.log(`  Grade: ${testParams.grade}`);
    console.log(`  Paper: ${testParams.paper}\n`);

    console.log('🎯 Mock Blueprint:');
    console.log(`  Total Marks: ${mockBlueprint.totalMarks}`);
    console.log('  Topics:');
    Object.entries(mockBlueprint.topics).forEach(([topic, marks]) => {
      console.log(`    ${topic}: ${marks} marks`);
    });
    console.log('  Cognitive Levels:');
    Object.entries(mockBlueprint.cognitiveLevels).forEach(([level, percentage]) => {
      console.log(`    ${level}: ${(percentage * 100).toFixed(1)}%`);
    });

    console.log('\n⚡ Generating test...');
    const result = await generateBlueprintCompliantTest(testParams);

    console.log('\n📊 Test Generation Results:');
    console.log(`  Total Questions: ${result.totalQuestions}`);
    console.log(`  Total Marks: ${result.totalMarks}`);
    
    console.log('\n📈 Topic Distribution:');
    Object.entries(result.topicDistribution || {}).forEach(([topic, count]) => {
      const targetMarks = mockBlueprint.topics[topic] || 0;
      const actualMarks = result.topicMarksDistribution[topic] || 0;
      console.log(`  ${topic}: ${count} questions, ${actualMarks}/${targetMarks} marks`);
    });

    console.log('\n🧠 Cognitive Level Distribution:');
    Object.entries(result.cognitiveDistribution || {}).forEach(([level, count]) => {
      const targetPercentage = (mockBlueprint.cognitiveLevels[level] * 100).toFixed(1);
      const actualPercentage = ((count / result.totalQuestions) * 100).toFixed(1);
      console.log(`  ${level}: ${count} questions (${actualPercentage}% vs ${targetPercentage}% target)`);
    });

    // Detailed compliance analysis
    console.log('\n✅ Compliance Analysis:');
    
    if (result.complianceReport) {
      console.log(`  Overall Compliance: ${result.complianceReport.overall.compliant ? '✅ PASS' : '❌ FAIL'}`);
      console.log(`  Overall Score: ${(result.complianceReport.overall.score * 100).toFixed(1)}%`);
      
      console.log('\n  Topic Compliance:');
      result.complianceReport.topic.deviations.forEach(deviation => {
        const status = deviation.compliant ? '✅' : '❌';
        console.log(`    ${status} ${deviation.topic}: ${deviation.actual}/${deviation.target} marks (${deviation.deviation > 0 ? '+' : ''}${deviation.deviation})`);
      });
      
      console.log('\n  Cognitive Level Compliance:');
      result.complianceReport.cognitive.deviations.forEach(deviation => {
        const status = deviation.compliant ? '✅' : '❌';
        console.log(`    ${status} ${deviation.level}: ${deviation.actualCount} questions (${deviation.actualPct.toFixed(1)}% vs ${deviation.targetPct.toFixed(1)}%)`);
      });
    }

    console.log('\n🎯 Validation Summary:');
    const overallSuccess = result.complianceReport && result.complianceReport.overall.compliant;
    console.log(`  Status: ${overallSuccess ? '✅ SUCCESS - Logic is stable with real data' : '❌ NEEDS ATTENTION - Logic may need refinement'}`);
    console.log(`  Questions Generated: ${result.totalQuestions}`);
    console.log(`  Total Test Marks: ${result.totalMarks}/${mockBlueprint.totalMarks}`);

    if (!overallSuccess) {
      console.log('\n⚠️  The test generation logic may need further refinement for real-world data.');
      console.log('   Consider reviewing the algorithm parameters or blueprint requirements.');
    }

  } catch (error) {
    console.error('\n❌ Error during live validation:', error.message);
    console.error('Stack trace:', error.stack);
  }
}

// Run the validation
runLiveValidation().then(() => {
  console.log('\n🏁 Live validation complete.');
  process.exit(0);
}).catch(error => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});