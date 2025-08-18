# Firebase Functions Deployment

## Prerequisites
1. Install Firebase CLI globally:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Set the Firebase project:
   ```bash
   firebase use vibe-code-4c59f
   ```

## Deploy Functions
To deploy the functions to Firebase:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

## Available Functions

### generateTest
- **Purpose**: Securely builds a practice test based on user-selected criteria
- **Authentication**: Required
- **Parameters**: grade, subject, paper, year, season, mode
- **Returns**: Array of questions with sensitive data removed

### gradeTest  
- **Purpose**: Marks submitted answers and saves results
- **Authentication**: Required
- **Parameters**: answers (object), subject, paper
- **Returns**: score and totalMarks

## Function Security
- Both functions require user authentication
- generateTest removes correctAnswer and explanation before sending to client
- gradeTest securely fetches correct answers from Firestore server-side
- Test results are saved to user's private sub-collection

## Local Testing
To test functions locally:
```bash
firebase emulators:start --only functions
```