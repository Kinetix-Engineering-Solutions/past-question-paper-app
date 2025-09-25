/**
 * Test script for your specific Firestore structure:
 * questions/short_answer/[question_documents]
 */

console.log('🔥 Testing with your Firestore structure: questions/short_answer/questions');

// Test 1: Direct Firestore path test
console.log('\n1. Testing correct Firestore path...');
console.log('Your structure: questions > short_answer > [question documents]');
console.log('Updated queries to use: collection("questions").doc("short_answer").collection("questions")');

// Test 2: Generate Short Answer Test (PQP Mode)
console.log('\n2. Test command for PQP mode:');
console.log('curl -X POST http://localhost:5001/vibe-code-4c59f/us-central1/generateTest \\');
console.log('  -H "Content-Type: application/json" \\');
console.log('  -d \'{');
console.log('    "data": {');
console.log('      "grade": 12,');
console.log('      "subject": "mathematics",');
console.log('      "paper": "p1",');
console.log('      "format": "short_answer",');
console.log('      "mode": "pqp",');
console.log('      "year": 2023,');
console.log('      "season": "November"');
console.log('    }');
console.log('  }\'');

// Test 3: Generate Short Answer Test (Sprint Mode)
console.log('\n3. Test command for Sprint mode:');
console.log('curl -X POST http://localhost:5001/vibe-code-4c59f/us-central1/generateTest \\');
console.log('  -H "Content-Type: application/json" \\');
console.log('  -d \'{');
console.log('    "data": {');
console.log('      "grade": 12,');
console.log('      "subject": "mathematics",');
console.log('      "format": "short_answer",');
console.log('      "mode": "sprint",');
console.log('      "difficulty": "easy"');
console.log('    }');
console.log('  }\'');

// Test 4: Grade Short Answer
console.log('\n4. Test grading (replace with real question ID):');
console.log('curl -X POST http://localhost:5001/vibe-code-4c59f/us-central1/gradeTest \\');
console.log('  -H "Content-Type: application/json" \\');
console.log('  -d \'{');
console.log('    "data": {');
console.log('      "submissions": {');
console.log('        "your_question_id_here": {');
console.log('          "answer": "g(x) = 2^x"');
console.log('        }');
console.log('      }');
console.log('    }');
console.log('  }\'');

console.log('\n📋 To test:');
console.log('1. Start emulators: firebase emulators:start');
console.log('2. Make sure you have short answer questions in: questions/short_answer/[documents]');
console.log('3. Run the curl commands above');
console.log('4. Check the Firebase emulator UI at http://localhost:4000');

console.log('\n📊 Your question documents should have this structure:');
console.log('{');
console.log('  "grade": 12,');
console.log('  "subject": "mathematics",');
console.log('  "topic": "exponential_functions",');
console.log('  "answerType": "equation",');
console.log('  "availableInModes": ["pqp", "sprint"],');
console.log('  "correctAnswer": {');
console.log('    "answer": "g(x) = 2^x",');
console.log('    "variations": ["g(x) = 2^x", "g(x)=2^x", "y = 2^x"]');
console.log('  },');
console.log('  "pqpData": {');
console.log('    "paper": "p1",');
console.log('    "year": 2023,');
console.log('    "season": "November",');
console.log('    "questionText": "Write down the equation...",');
console.log('    "marks": 1');
console.log('  },');
console.log('  "sprintData": {');
console.log('    "difficulty": "easy",');
console.log('    "questionText": "Given that f(x)...",');
console.log('    "marks": 2');
console.log('  }');
console.log('}');

console.log('\n✅ Database service updated for your structure!');