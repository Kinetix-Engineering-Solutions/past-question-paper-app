const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const { generateBlueprintCompliantTest } = require('../src/services/enhancedTestService');

async function testGeneration() {
  console.log('🧪 Testing Smart Compensation Algorithm\n');
  
  const testCases = [
    { year: 2020, season: 'November', expected: 149 },
    { year: 2021, season: 'November', expected: 128 },
    { year: 2024, season: 'November', expected: 56 }
  ];
  
  for (const testCase of testCases) {
    console.log('='.repeat(80));
    console.log(`Testing: ${testCase.year} ${testCase.season}`);
    console.log(`Expected available marks: ${testCase.expected}`);
    console.log('='.repeat(80));
    
    try {
      const params = {
        subject: 'mathematics',
        paper: 'p1',
        grade: 12,
        year: testCase.year,
        season: testCase.season,
        mode: 'pqp'
      };
      
      const result = await generateBlueprintCompliantTest(params);
      
      const totalMarks = result.questions.reduce((sum, q) => 
        sum + Number(q.maxMarks || q.marks || 0), 0
      );
      
      console.log('\n📊 RESULTS:');
      console.log(`   Questions generated: ${result.questions.length}`);
      console.log(`   Total marks: ${totalMarks}`);
      console.log(`   Target marks: 150`);
      console.log(`   Achievement: ${((totalMarks/150)*100).toFixed(1)}%`);
      
      // Show topic distribution
      const topicDist = {};
      result.questions.forEach(q => {
        const topic = q.allocatedTopic || q.topic;
        const marks = Number(q.maxMarks || q.marks || 0);
        if (!topicDist[topic]) topicDist[topic] = 0;
        topicDist[topic] += marks;
      });
      
      console.log('\n   Topic Distribution:');
      Object.entries(topicDist).forEach(([topic, marks]) => {
        console.log(`      ${topic}: ${marks} marks`);
      });
      
      if (totalMarks >= testCase.expected * 0.95) {
        console.log('\n✅ PASS: Generated sufficient marks!');
      } else {
        console.log('\n⚠️ WARNING: Generated fewer marks than available');
      }
      
    } catch (error) {
      console.error('\n❌ ERROR:', error.message);
    }
    
    console.log('\n');
  }
  
  console.log('✨ Test complete!');
  process.exit(0);
}

testGeneration().catch(err => {
  console.error('❌ Fatal error:', err);
  process.exit(1);
});
