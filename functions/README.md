# Cloud Functions - Past Question Paper App

This directory contains Firebase Cloud Functions for the Past Question Paper application, built with a modular architecture for better maintainability and scalability.

## 🏗️ Architecture

The functions are organized into a modular structure:

```
functions/
├── index.js                    # Main entry point with HTTP endpoints
├── package.json               # Dependencies and scripts
└── src/
    ├── helpers/               # Reusable helper functions
    │   ├── dataHelpers.js    # Data transformation utilities
    │   └── validation.js     # Request validation functions
    └── services/             # Business logic services
        ├── databaseService.js # Firestore operations
        ├── testService.js    # Test generation logic
        └── gradingService.js # Answer grading logic
```

## 🚀 Functions

### `generateTest`
Generates test papers based on parameters and exam blueprints.

**Parameters:**
- `grade` (number) - Student grade level
- `subject` (string) - Subject name
- `paper` (string) - Paper identifier
- `mode` (string) - Test mode: 'full_exam', 'quick_practice', 'by_topic'
- `year` (number, optional) - Exam year
- `season` (string, optional) - Exam season
- `topic` (string, optional) - Specific topic for 'by_topic' mode

**Returns:**
- Array of sanitized questions (sensitive answers removed)
- Blueprint information
- Generation metadata

### `gradeTest`
Grades submitted test answers and returns detailed results.

**Parameters:**
- `submissions` (object) - Question ID to answer mapping
- `userId` (string, optional) - User identifier for result storage

**Returns:**
- Individual question results
- Overall statistics (score, percentage, grade)
- Detailed grading breakdown

### `createEmailVerificationLink`
Generates a Firebase email verification link using the Admin SDK and sends a branded email via Titan SMTP.

**Auth:**
- Requires authenticated user (`request.auth.uid`)

**Behavior:**
- Rejects requests if account has no email
- Returns early if email is already verified
- Applies a 60-second resend cooldown per user
- Sends branded verification email using Titan SMTP (`nodemailer`)

**Required environment variables:**
- `TITAN_SMTP_USER`
- `TITAN_SMTP_PASSWORD`
- `TITAN_FROM_EMAIL`
- `EMAIL_VERIFICATION_CONTINUE_URL`

**Optional environment variables:**
- `TITAN_SMTP_HOST` (default: `smtp.titan.email`)
- `TITAN_SMTP_PORT` (default: `587`)
- `TITAN_SMTP_SECURE` (default: `false` when port `587`, `true` when port `465`)
- `TITAN_SMTP_REQUIRE_TLS` (default: `true` when port `587`)
- `TITAN_FROM_NAME` (default: `Past Question Papers`)
- `EMAIL_VERIFICATION_ANDROID_PACKAGE_NAME`
- `EMAIL_VERIFICATION_ANDROID_MIN_VERSION`
- `EMAIL_VERIFICATION_IOS_BUNDLE_ID`

### `createPasswordResetLink`
Generates a Firebase password reset link using the Admin SDK and sends a branded email via Resend.

**Parameters:**
- `email` (string) - Email address to send the reset link to

**Returns:**
- `success` (bool)
- `sent` (bool)
- `message` (string)

**Required environment variables:**
- `RESEND_API_KEY`
- `RESEND_FROM_EMAIL`
- `PASSWORD_RESET_CONTINUE_URL`

### `extractQuestionDraftFromImage`
Extracts a draft question payload from an uploaded image URL using Mathpix OCR. Intended for admin-only content workflows.

**Parameters:**
- `imageUrl` (string, required) - Publicly reachable HTTP(S) image URL

**Returns:**
- `draft` object with inferred format and auto-fill fields:
   - `format`
   - `questionText`
   - `options`
   - `correctAnswer`
   - `answerVariations`
   - `dragItems`
   - `correctOrder`
   - `explanation`
   - `warnings`
   - `confidence`

**Required environment variables:**
- `MATHPIX_APP_ID`
- `MATHPIX_APP_KEY`

## 📁 Service Modules

### Data Helpers (`src/helpers/dataHelpers.js`)
- `safeArray()` - Safely converts values to arrays
- `mapQuestionData()` - Maps Firestore documents to question objects
- `normalizePaperFormat()` - Normalizes paper identifiers

### Validation (`src/helpers/validation.js`)
- `validateTestParams()` - Validates test generation parameters
- `validateGradingParams()` - Validates grading request parameters

### Database Service (`src/services/databaseService.js`)
- `buildQuestionQuery()` - Constructs Firestore queries
- `fetchBlueprint()` - Retrieves exam blueprints
- `executeQuestionQuery()` - Executes and validates query results
- `fetchQuestionsForGrading()` - Fetches questions for grading
- `saveUserTestResults()` - Saves results to user profiles

### Test Service (`src/services/testService.js`)
- `selectRandomQuestions()` - Randomly selects questions from pool
- `processQuestionsForFormat()` - Processes questions for specific formats
- `generateQuestionsForFormat()` - Generates questions for specific format section
- `generateTestPaper()` - Main test generation orchestrator

### Grading Service (`src/services/gradingService.js`)
- `gradeMultipleChoice()` - Grades multiple choice questions
- `gradeTrueFalse()` - Grades true/false questions  
- `gradeDragAndDrop()` - Grades drag-and-drop questions
- `gradeFillInBlanks()` - Grades fill-in-the-blanks questions
- `calculateTestStatistics()` - Calculates overall test statistics
- `gradeTestSubmission()` - Main grading orchestrator

## 🎯 Question Format Support

The functions support multiple question formats:

1. **Multiple Choice** - Single correct answer from options
2. **True/False** - Binary true/false questions
3. **Drag and Drop** - Match items to correct targets
4. **Fill in Blanks** - Complete sentences with correct words

Each format has specialized grading logic and data processing.

## 🔧 Development

### Prerequisites
- Node.js 20+
- Firebase CLI
- Firebase project with Firestore enabled

### Local Development
```bash
# Install dependencies
npm install

# Start emulator
npm run serve

# Deploy functions
npm run deploy

# View logs
npm run logs
```

### Testing
```bash
# Run tests (when implemented)
npm test
```

## 📊 Data Flow

1. **Test Generation:**
   - Validate parameters
   - Fetch exam blueprint
   - Query questions from Firestore
   - Process and format questions
   - Return sanitized questions

2. **Test Grading:**
   - Validate submissions
   - Fetch question data
   - Grade each question by format
   - Calculate statistics
   - Save results (optional)
   - Return grading results

## 🛡️ Error Handling

All functions implement comprehensive error handling:
- Parameter validation with specific error messages
- Firestore operation error handling
- Graceful degradation for non-critical operations
- Structured error logging

## 🔐 Security

- Authentication temporarily disabled for development
- Input validation on all parameters
- Sensitive answer data removed from client responses
- Firestore security rules applied at database level

## 📈 Performance

- Modular architecture allows for selective optimization
- Database queries optimized with proper indexing
- Question selection uses efficient algorithms
- Result caching potential for future enhancement

## 🚀 Deployment

### Prerequisites
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

### Deploy Functions
To deploy the functions to Firebase:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### Local Testing
To test functions locally:
```bash
firebase emulators:start --only functions
```

## ✉️ Titan SMTP Quick Setup

1. Copy the template file and create your local env file:
   ```bash
   cd functions
   cp .env.example .env
   ```
   On Windows PowerShell:
   ```powershell
   Copy-Item .env.example .env
   ```

2. Open `.env` and set your real Titan SMTP password in `TITAN_SMTP_PASSWORD`.

3. Deploy functions so env values are applied:
   ```bash
   cd ..
   firebase deploy --only functions
   ```

Recommended Titan values from your setup:
- `TITAN_SMTP_HOST=smtp.titan.email`
- `TITAN_SMTP_PORT=587`
- `TITAN_SMTP_SECURE=false`
- `TITAN_SMTP_REQUIRE_TLS=true`
- `TITAN_SMTP_USER=support@pastquestionpapers.com`
- `TITAN_FROM_EMAIL=support@pastquestionpapers.com`