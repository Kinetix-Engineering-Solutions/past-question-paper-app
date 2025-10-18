/**
 * Check Mathematics Question Count
 * Run: node functions/tools/check-math-questions.js
 * 
 * This script audits your Mathematics questions to help decide release readiness
 */

const admin = require('firebase-admin');
const serviceAccount = require('../../serviceAccountKey.json');

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();

async function auditMathQuestions() {
  console.log('🔍 Auditing Mathematics Questions...\n');
  console.log('='.repeat(60));
  
  try {
    // Query all Mathematics questions
    const snapshot = await db.collection('questions')
      .where('subject', '==', 'mathematics')
      .get();
    
    if (snapshot.empty) {
      console.log('❌ No Mathematics questions found!');
      console.log('\n💡 Recommendation: Upload at least 30 questions before release');
      return;
    }
    
    // Statistics
    const stats = {
      total: 0,
      byGrade: {},
      byTopic: {},
      byFormat: {},
      byMode: {
        pqp: 0,
        sprint: 0,
        byTopic: 0
      },
      withImages: 0,
      parents: 0,
      children: 0
    };
    
    // Analyze each question
    snapshot.forEach(doc => {
      const data = doc.data();
      stats.total++;
      
      // Count by grade
      const grade = data.grade || 'unknown';
      stats.byGrade[grade] = (stats.byGrade[grade] || 0) + 1;
      
      // Count by topic
      const topic = data.topic || 'unknown';
      stats.byTopic[topic] = (stats.byTopic[topic] || 0) + 1;
      
      // Count by format
      const format = data.format || data.questionType || 'unknown';
      stats.byFormat[format] = (stats.byFormat[format] || 0) + 1;
      
      // Count by mode availability
      const modes = data.availableInModes || [];
      if (modes.includes('pqp')) stats.byMode.pqp++;
      if (modes.includes('sprint')) stats.byMode.sprint++;
      if (modes.includes('by_topic')) stats.byMode.byTopic++;
      
      // Images
      if (data.imageUrl) stats.withImages++;
      
      // Parent/Child
      if (data.isParent) stats.parents++;
      if (data.parentQuestionId) stats.children++;
    });
    
    // Display results
    console.log('\n📊 TOTAL MATHEMATICS QUESTIONS:', stats.total);
    console.log('='.repeat(60));
    
    // Grade breakdown
    console.log('\n📚 BY GRADE LEVEL:');
    Object.entries(stats.byGrade)
      .sort((a, b) => b[1] - a[1])
      .forEach(([grade, count]) => {
        const percentage = ((count / stats.total) * 100).toFixed(1);
        const bar = '█'.repeat(Math.floor(count / 5));
        console.log(`   Grade ${grade}: ${count.toString().padStart(3)} (${percentage}%) ${bar}`);
      });
    
    // Topic breakdown
    console.log('\n🎯 BY TOPIC:');
    Object.entries(stats.byTopic)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10) // Top 10 topics
      .forEach(([topic, count]) => {
        const percentage = ((count / stats.total) * 100).toFixed(1);
        console.log(`   ${topic.padEnd(40)}: ${count.toString().padStart(3)} (${percentage}%)`);
      });
    
    if (Object.keys(stats.byTopic).length > 10) {
      console.log(`   ... and ${Object.keys(stats.byTopic).length - 10} more topics`);
    }
    
    // Format breakdown
    console.log('\n📝 BY QUESTION FORMAT:');
    Object.entries(stats.byFormat)
      .sort((a, b) => b[1] - a[1])
      .forEach(([format, count]) => {
        const percentage = ((count / stats.total) * 100).toFixed(1);
        const bar = '█'.repeat(Math.floor(count / 5));
        console.log(`   ${format.padEnd(20)}: ${count.toString().padStart(3)} (${percentage}%) ${bar}`);
      });
    
    // Mode availability
    console.log('\n🎮 BY PRACTICE MODE:');
    console.log(`   PQP Mode:       ${stats.byMode.pqp.toString().padStart(3)} questions`);
    console.log(`   Sprint Mode:    ${stats.byMode.sprint.toString().padStart(3)} questions`);
    console.log(`   By Topic Mode:  ${stats.byMode.byTopic.toString().padStart(3)} questions`);
    
    // Other stats
    console.log('\n🖼️  ADDITIONAL STATS:');
    console.log(`   Questions with images: ${stats.withImages}`);
    console.log(`   Parent questions:      ${stats.parents}`);
    console.log(`   Child questions:       ${stats.children}`);
    
    // Release readiness assessment
    console.log('\n' + '='.repeat(60));
    console.log('🚦 RELEASE READINESS ASSESSMENT:');
    console.log('='.repeat(60));
    
    if (stats.total >= 50) {
      console.log('✅ READY FOR FULL RELEASE (50+ questions)');
      console.log('   Recommendation: Release all available modes');
    } else if (stats.total >= 30) {
      console.log('✅ READY FOR MVP RELEASE (30-49 questions)');
      console.log('   Recommendation: Release Sprint + By Topic modes');
      console.log('   Consider: Disable PQP mode until more questions added');
    } else if (stats.total >= 15) {
      console.log('⚠️  MARGINAL (15-29 questions)');
      console.log('   Recommendation: Internal testing only');
      console.log('   Need: At least 30 questions for public release');
    } else {
      console.log('❌ NOT READY (< 15 questions)');
      console.log('   Recommendation: Add more questions before release');
      console.log('   Target: Minimum 30 questions');
    }
    
    // Grade level recommendation
    console.log('\n📌 RECOMMENDED RELEASE STRATEGY:');
    const topGrade = Object.entries(stats.byGrade)
      .sort((a, b) => b[1] - a[1])[0];
    
    if (topGrade) {
      console.log(`   Focus on Grade ${topGrade[0]} (${topGrade[1]} questions available)`);
      console.log(`   Lock app to Grade ${topGrade[0]} for initial release`);
      console.log(`   Add other grades in future updates`);
    }
    
    // Mode recommendations
    console.log('\n🎮 MODE RECOMMENDATIONS:');
    if (stats.byMode.sprint >= 30) {
      console.log('   ✅ Sprint Mode: Ready (recommended 5-15 min practice)');
    } else {
      console.log('   ⚠️  Sprint Mode: Limited (need 30+ questions)');
    }
    
    if (stats.byMode.byTopic >= 20) {
      console.log('   ✅ By Topic Mode: Ready');
    } else {
      console.log('   ⚠️  By Topic Mode: Limited (need more topic coverage)');
    }
    
    if (stats.byMode.pqp >= 40 && stats.parents >= 5) {
      console.log('   ✅ PQP Mode: Ready (authentic exam experience)');
    } else {
      console.log('   ❌ PQP Mode: Disable for MVP (need full exam paper)');
    }
    
    console.log('\n' + '='.repeat(60));
    console.log('📋 NEXT STEPS:');
    console.log('='.repeat(60));
    
    if (stats.total < 30) {
      console.log('1. Add more Mathematics questions (target: 30 minimum)');
      console.log('2. Focus on high-demand topics');
      console.log('3. Include variety of formats (MCQ, Short Answer, etc.)');
      console.log('4. Run this audit again after uploading');
    } else {
      console.log('1. Test all questions manually');
      console.log('2. Verify correct answers');
      console.log('3. Update RELEASE_STRATEGY_MVP.md with actual numbers');
      console.log('4. Build release APK: flutter build apk --release');
      console.log('5. Internal testing with 5-10 users');
      console.log('6. Deploy to Play Store Internal Testing track');
    }
    
    console.log('\n✨ Audit complete!\n');
    
  } catch (error) {
    console.error('❌ Error during audit:', error);
  } finally {
    await admin.app().delete();
  }
}

// Run the audit
auditMathQuestions();
