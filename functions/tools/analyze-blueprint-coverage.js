const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function analyzeBlueprintCoverage() {
  console.log('🔍 Analyzing Blueprint Coverage for Mathematics P1 Grade 12\n');
  
  // Fetch blueprint
  const blueprintDoc = await db.collection('blueprints').doc('mathematics_p1_gr12').get();
  
  if (!blueprintDoc.exists) {
    console.log('❌ Blueprint not found!');
    return;
  }
  
  const blueprint = blueprintDoc.data();
  console.log('📋 Blueprint Requirements:');
  console.log('   Total Marks:', blueprint.totalMarks);
  console.log('   Topics:', blueprint.topics);
  console.log('');
  
  // Get command line arguments for year and season
  const targetYear = process.argv[2] ? parseInt(process.argv[2]) : null;
  const targetSeason = process.argv[3] || null;
  
  if (targetYear && targetSeason) {
    console.log(`🎯 Filtering for: Year ${targetYear}, Season: ${targetSeason}\n`);
  } else {
    console.log(`📊 Analyzing ALL years and seasons (specify year and season as arguments to filter)\n`);
  }
  
  // Fetch all Mathematics Grade 12 Paper 1 questions
  let query = db.collection('questions')
    .where('subject', '==', 'mathematics')
    .where('grade', '==', 12)
    .where('paper', '==', 'p1');
  
  // Add year and season filters if provided
  if (targetYear) {
    query = query.where('year', '==', targetYear);
  }
  if (targetSeason) {
    query = query.where('season', '==', targetSeason);
  }
  
  const questionsSnapshot = await query.get();
  
  console.log(`📊 Total Questions in Database: ${questionsSnapshot.size}\n`);
  
  // Track year/season distribution
  const yearSeasonStats = {};
  
  // Analyze by topic
  const topicStats = {};
  const parentQuestions = [];
  const answerableQuestions = [];
  
  questionsSnapshot.forEach(doc => {
    const question = { id: doc.id, ...doc.data() };
    
    // Track year/season
    const year = question.year || 'Unknown';
    const season = question.season || 'Unknown';
    const yearSeasonKey = `${year} ${season}`;
    if (!yearSeasonStats[yearSeasonKey]) {
      yearSeasonStats[yearSeasonKey] = { count: 0, marks: 0 };
    }
    yearSeasonStats[yearSeasonKey].count++;
    
    // Track parent questions
    if (question.isParent) {
      parentQuestions.push(question);
      return; // Don't count parents as answerable
    }
    
    answerableQuestions.push(question);
    const questionMarks = Number(question.marks || question.maxMarks || 0);
    yearSeasonStats[yearSeasonKey].marks += questionMarks;
    
    const topic = question.topic || 'Unknown';
    
    if (!topicStats[topic]) {
      topicStats[topic] = {
        count: 0,
        totalMarks: 0,
        questions: []
      };
    }
    
    topicStats[topic].count++;
    topicStats[topic].totalMarks += questionMarks;
    topicStats[topic].questions.push({
      id: question.id,
      marks: questionMarks,
      format: question.format || question.questionType,
      hasParent: !!question.parentId
    });
  });
  
  console.log(`🚫 Parent Questions (filtered out): ${parentQuestions.length}`);
  console.log(`✅ Answerable Questions: ${answerableQuestions.length}\n`);
  
  // Show year/season distribution
  if (!targetYear || !targetSeason) {
    console.log('=' .repeat(80));
    console.log('📅 YEAR/SEASON DISTRIBUTION');
    console.log('='.repeat(80));
    Object.entries(yearSeasonStats)
      .sort((a, b) => b[0].localeCompare(a[0])) // Sort by year/season descending
      .forEach(([yearSeason, stats]) => {
        console.log(`${yearSeason}: ${stats.count} questions (${stats.marks} marks)`);
      });
    console.log('');
  }
  
  console.log('=' .repeat(80));
  console.log('📊 TOPIC-BY-TOPIC ANALYSIS');
  console.log('='.repeat(80));
  
  let totalAvailableMarks = 0;
  
  Object.entries(blueprint.topics).forEach(([topic, requiredMarks]) => {
    const stats = topicStats[topic] || { count: 0, totalMarks: 0, questions: [] };
    totalAvailableMarks += stats.totalMarks;
    
    const status = stats.totalMarks >= requiredMarks ? '✅' : '⚠️';
    const shortfall = Math.max(0, requiredMarks - stats.totalMarks);
    
    console.log(`\n${status} ${topic}`);
    console.log(`   Required: ${requiredMarks} marks`);
    console.log(`   Available: ${stats.totalMarks} marks (${stats.count} questions)`);
    
    if (shortfall > 0) {
      console.log(`   ❌ SHORTFALL: ${shortfall} marks`);
    }
    
    // Show question breakdown
    if (stats.questions.length > 0) {
      console.log(`   Questions:`);
      stats.questions.slice(0, 10).forEach(q => {
        console.log(`      - ${q.id}: ${q.marks}m [${q.format}]${q.hasParent ? ' (has parent)' : ''}`);
      });
      if (stats.questions.length > 10) {
        console.log(`      ... and ${stats.questions.length - 10} more`);
      }
    }
  });
  
  console.log('\n' + '='.repeat(80));
  console.log('📈 SUMMARY');
  console.log('='.repeat(80));
  console.log(`Blueprint Requires: ${blueprint.totalMarks} marks`);
  console.log(`Database Has: ${totalAvailableMarks} marks available`);
  console.log(`Parent Questions Filtered: ${parentQuestions.length}`);
  console.log(`Answerable Questions: ${answerableQuestions.length}`);
  
  if (totalAvailableMarks < blueprint.totalMarks) {
    const gap = blueprint.totalMarks - totalAvailableMarks;
    console.log(`\n❌ CRITICAL: Database has ${gap} marks SHORTFALL!`);
    console.log(`   - Blueprint needs: ${blueprint.totalMarks} marks`);
    console.log(`   - Database has: ${totalAvailableMarks} marks`);
    console.log(`   - Missing: ${gap} marks (${((gap/blueprint.totalMarks)*100).toFixed(1)}%)`);
  } else {
    console.log(`\n✅ Database has SUFFICIENT marks (${totalAvailableMarks} >= ${blueprint.totalMarks})`);
  }
  
  console.log('\n✨ Analysis complete!');
  process.exit(0);
}

analyzeBlueprintCoverage().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
