# Past Question Papers App — Features & Development Goals

This document describes the current feature set of the **Past Question Papers** app and outlines **development goals** for future iterations. It is written to support business planning (product scope, differentiation, and roadmap).

## 1) Product Summary
A Flutter + Firebase learning platform that helps students prepare for exams using authentic past-paper practice, fast revision sessions, and topic-focused drilling. The system supports rich question formats (including LaTeX) and tracks progress over time.

## 2) Current Student Features

### 2.1 Authentication & Onboarding
- Email/password sign up and login
- Email verification flow (verification gating before full access)
- Forgot password / password reset flow
- Onboarding flow to capture learner profile (grade and selected subjects)

### 2.2 Practice Modes
The app supports multiple ways to practice, depending on the learner’s goals:
- **Full Exam (PQP)**: Exam-authentic mode using past paper structures and **real question numbering** when available (e.g., “Question 4.2.1”).
- **Quick Practice (Sprint)**: Timed practice designed for rapid revision sessions.
- **By Topic**: Targeted practice focused on specific topics.
- **Retry Mistakes**: Re-practice questions the learner previously answered incorrectly or left unanswered.

### 2.3 Question Formats (Interactive Engine)
Supports multiple assessment types (depending on content availability):
- **MCQ (Text options)**
- **MCQ (Image options)**
- **True/False**
- **Short Answer**
- **Essay / Long-form response**
- **Drag & Drop (matching / ordering)**
- **Fill-in-the-blanks** (where configured)

### 2.4 Results, Review & Feedback
- Session results summary (score, percentage, grade)
- Per-question review experience (including navigation across questions)
- Parent/context support for questions that belong to a larger prompt or scenario

### 2.5 Progress & Learning Reinforcement
- **Mistake Bank**: Stores missed/unanswered questions for targeted remediation
- Progress insights and history built from stored test attempts
- Basic “readiness” style indicators based on past results

### 2.6 Content Library
- Past paper library browsing (with search and filters such as subject/grade/year)
- In-app PDF viewing for papers

### 2.7 Reliability UX
- Connectivity awareness (offline/degraded banner with retry/check actions)

## 3) Current Admin Features (Content Operations)
A dedicated Admin Portal exists for content creation and management.

### 3.1 Admin Access
- Admin login using Firebase authentication
- Admin dashboard navigation

### 3.2 Content Creation & Editing
- Create/edit questions across supported formats
- Configure PQP-specific metadata (e.g., question numbering)
- Create/edit **parent context** questions to support parent-child question sets

### 3.3 Content Browsing & Maintenance
- Browse questions with filtering/search and paging
- Browse and manage parent-child sets

### 3.4 Paper Upload
- Upload past paper PDFs and metadata (subject/grade/year/season/paper number/title)

## 4) Backend & Platform Capabilities

### 4.1 Firebase Architecture
- Firebase Authentication for user identity
- Cloud Firestore for questions, blueprints, papers, and user progress
- Firebase Storage for PDFs and media assets

### 4.2 Cloud Functions (Server-Side Logic)
- **Test generation** (selects questions based on blueprints and constraints)
- **Grading** (grades supported question types and stores results)
- Mistake bank updates during grading

### 4.3 Security & Cost Controls (High-Level)
- Firestore + Storage rules to restrict access to user data and protect question assets
- Function limits (rate limiting, request sizing) to reduce abuse and control costs

## 5) Feature Goals (Development Roadmap)
These are development-oriented goals intended to guide implementation planning. Items are written to be credible and measurable.

### 5.1 Near-Term Goals (MVP Completion & Stability)
**Primary objective:** make the core learning loop dependable and production-ready.
- Improve consistency across all practice modes (PQP / Sprint / By Topic / Retry Mistakes)
- Strengthen grading coverage and edge-case handling across all supported formats
- Reduce “no content available” failures by improving blueprint coverage and validation
- Harden App Check and production security configuration for public release
- Tighten documentation so it reflects actual behavior (especially auth + function requirements)

### 5.2 Mid-Term Goals (Content Scale & Better Learning Outcomes)
**Primary objective:** expand content and improve learning effectiveness.
- Expand the question bank and past-paper coverage (more years/seasons/topics)
- Better analytics: trend tracking by topic, weak-area identification, and progress insights
- Enhanced mistake bank workflows (e.g., structured revision sessions and mastery status)
- Improve content discovery: clearer topic taxonomy and more predictable filtering/search
- Performance and reliability improvements across web and mobile

### 5.3 Longer-Term Goals (Operational Scale & Partnerships)
**Primary objective:** reduce operational cost per question/paper and support growth.
- Bulk content ingestion tooling (CSV import, validation rules, conflict detection)
- Role-based admin access (permissions, audit trails, content approval workflows)
- Data model evolution/migrations for parent-child questions and media deduplication
- Multi-curriculum or multi-region support (subject mappings, local exam structures)

### 5.4 Non-Goals (For Now)
To keep the roadmap realistic and reduce scope creep:
- No new UI “theme system” beyond the existing Paper & Ink design language
- No complex social features (leaderboards, chat) unless explicitly prioritized
- No promise of full offline practice until a dedicated caching/download strategy is implemented and tested per platform

## 6) Constraints & Design Principles (Important for Development)
- **Paper & Ink theme**: maintain the monochrome palette + single accent; avoid introducing new colors and visual noise.
- **Mode flags, one unified practice UI**: PQP/Sprint/By Topic are handled via mode flags rather than separate app flows.
- **PQP numbering integrity**: PQP mode must display authentic exam numbering when present.

## 7) Dependencies & Risks
- Content coverage is a critical dependency (blueprints + question bank completeness)
- Any schema migrations must preserve PQP numbering and parent-child relationships
- Cloud costs scale with usage; rate limits and request sizing must be tuned over time
