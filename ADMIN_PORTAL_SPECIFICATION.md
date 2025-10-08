# Web Admin Portal - Specification Document

## 🎯 Overview

A web-based content management system for educational administrators and content creators to manage questions, parent-child structures, blueprints, and user data for the Past Question Papers app.

**Goal:** Enable non-technical staff to create, edit, and manage educational content without writing code or directly accessing Firestore.

---

## 👥 User Roles

### **1. Super Admin**
- Full system access
- Manage all users and roles
- System configuration
- Access analytics and reports
- Manage blueprints

### **2. Content Manager**
- Create/edit/delete questions
- Upload images
- Manage parent-child structures
- Import from spreadsheets
- Preview questions

### **3. Subject Expert**
- Create/edit questions in assigned subjects only
- Limited to specific grades/topics
- Cannot delete questions
- Cannot access user data

### **4. Viewer**
- Read-only access
- View questions and statistics
- Export data
- No editing capabilities

---

## 🏗️ Architecture

### **Tech Stack:**
- **Frontend:** Flutter Web (consistent with mobile app)
- **Backend:** Firebase Cloud Functions (existing infrastructure)
- **Database:** Firestore (existing database)
- **Storage:** Firebase Storage (image/file uploads)
- **Auth:** Firebase Authentication with role-based access control
- **Hosting:** Firebase Hosting

### **URL Structure:**
```
https://admin.pastquestionpapers.com/
├── /login
├── /dashboard
├── /questions
│   ├── /create
│   ├── /edit/:id
│   ├── /parent/create
│   └── /import
├── /blueprints
├── /users
├── /analytics
└── /settings
```

---

## 📋 Core Features

### **1. Authentication & Authorization**

#### **1.1 Login System**
- Email/password authentication
- Google Sign-In integration
- Password reset via email
- Two-factor authentication (optional)
- Session management with timeout

#### **1.2 Role Management**
- Assign roles: Super Admin, Content Manager, Subject Expert, Viewer
- Subject/grade restrictions for Subject Experts
- Role-based route protection
- Activity logging per user

**UI Components:**
- Login page with branding
- Role selection dropdown (for Super Admin)
- Password strength indicator
- "Remember me" checkbox
- Forgot password link

---

### **2. Dashboard**

#### **2.1 Overview Statistics**
- Total questions by subject
- Questions by format (MCQ, Short Answer, etc.)
- Recent uploads (last 7 days)
- Parent-child sets count
- Questions by availability mode (PQP, Sprint, By Topic)

#### **2.2 Quick Actions**
- Create new question
- Create parent-child set
- Import from spreadsheet
- View recent activity
- System health status

#### **2.3 Activity Feed**
- Recent edits/creations
- User activity timeline
- System notifications
- Validation errors/warnings

**UI Components:**
- Card-based layout
- Interactive charts (pie, bar, line)
- Quick action buttons
- Real-time updates
- Export dashboard data (PDF/CSV)

---

### **3. Question Management**

#### **3.1 Question List/Browser**

**Features:**
- Paginated table view (50 items per page)
- Search by ID, text, topic, subject
- Filter by:
  - Subject
  - Grade
  - Topic
  - Format (MCQ, Short Answer, etc.)
  - Paper (P1, P2, P3)
  - Year
  - Season
  - Availability mode
  - Has parent (yes/no)
- Sort by: Date created, Marks, Question number
- Bulk actions: Delete, Export, Change availability
- Preview question in modal

**UI Components:**
- Data table with checkboxes
- Filter sidebar (collapsible)
- Search bar with autocomplete
- Column sorting arrows
- Pagination controls
- Bulk action toolbar
- Quick preview on hover

#### **3.2 Create Question (Standalone)**

**Form Sections:**

**A. Basic Information**
- Question ID (auto-generated, editable)
- Subject (dropdown)
- Grade (dropdown)
- Topic (dropdown - filtered by subject)
- Paper (P1, P2, P3)
- Year (dropdown, last 10 years)
- Season (November, June, March)

**B. Question Content**
- Question format (dropdown):
  - MCQ (Multiple Choice)
  - Short Answer
  - Drag & Drop
  - True/False
  - Essay
- Question text (rich text editor with LaTeX support)
- Image upload (optional)
  - Drag & drop area
  - Image preview
  - Crop/resize tool
  - Alt text for accessibility

**C. Answer Configuration**

**For MCQ:**
- Option A, B, C, D (text inputs)
- Option images (optional)
- Correct answer (radio buttons)
- Explanation (rich text)

**For Short Answer:**
- Answer type (text, number, coordinates, equation)
- Correct answer (text input)
- Answer variations (add/remove fields)
- Case sensitive (checkbox)
- Tolerance (for numeric, number input)
- Units (optional, text input)

**For Drag & Drop:**
- Drag items (list builder)
- Drop targets (list builder)
- Correct order (reorderable list)

**D. Metadata**
- Marks (number input, min 1, max 20)
- Cognitive level (dropdown: Level 1-4)
- Difficulty (dropdown: Easy, Medium, Hard)
- Time allocation (minutes, number input)

**E. Availability**
- Available in modes (checkboxes):
  - Full Exam (PQP)
  - Quick Practice (Sprint)
  - By Topic
- PQP-specific data (if PQP mode selected):
  - Question number (e.g., 4.1.1)
  - Show in chains (checkbox)
- Sprint-specific data (if Sprint mode selected):
  - Hint text (text area)
  - Time estimate (minutes)
  - Provided context (key-value pairs)

**F. Preview & Validation**
- Live preview panel (side-by-side)
- Validation status indicators
- Required field warnings
- Save as draft button
- Publish button

**UI Components:**
- Multi-step form wizard OR single scrollable form
- Rich text editor (Quill.js or TinyMCE)
- LaTeX preview for math equations
- Image upload with drag-drop
- Dynamic field addition (answer variations)
- Inline validation with error messages
- Auto-save draft (every 30 seconds)
- Discard changes confirmation

---

#### **3.3 Create Parent-Child Set**

**Step 1: Create Parent (Context Document)**

**Form Fields:**
- Parent ID (auto-generated, editable)
- Context type (always "context")
- Context text (rich text editor)
  - Full scenario/diagram description
  - LaTeX support for math
- Image upload (required for most cases)
  - Shared diagram/graph
  - Image preview
- Subject, Grade, Topic, Paper, Year, Season (same as standalone)
- Total marks (calculated automatically from children)
- PQP question number (e.g., 4.1)
- Availability modes (checkboxes)

**Step 2: Add Children Questions**

**Features:**
- Add child button (opens child form modal)
- List of added children (editable/deletable)
- Each child shows:
  - Child number (e.g., 4.1.1)
  - Question text preview
  - Marks
  - Format
  - Edit/Delete buttons
- Reorder children (drag handles)
- Duplicate child (copy with incremented number)

**Child Form (Modal or Inline):**
- Child ID (auto-generated based on parent + sequence)
- Format (MCQ, Short Answer, etc.)
- Question text (text area)
- Uses parent image (checkbox, default: true)
- Override image (if unchecked above)
- Answer configuration (based on format)
- Marks (number input)
- Cognitive level, Difficulty
- PQP question number (auto-calculated: 4.1.1, 4.1.2, etc.)
- Sprint hint (text area)
- Sprint time estimate (minutes)

**Step 3: Review & Publish**
- Summary card showing:
  - Parent context preview
  - List of children with marks
  - Total marks calculation
  - Validation status
- Preview in app-like interface
- Save as draft button
- Publish button (validates and uploads)

**UI Components:**
- Stepper navigation (Step 1 → 2 → 3)
- Parent preview card
- Children list with drag-drop reordering
- Modal for child editing
- Validation summary panel
- Breadcrumb navigation
- Discard confirmation dialog

---

#### **3.4 Edit Question**

**Features:**
- Load existing question data
- All fields editable (same as create)
- Version history (show last 5 edits)
- Restore previous version
- Track changes (highlight modified fields)
- Preview changes before saving
- Cancel/Revert button
- Update button (validates and saves)

**Additional Elements:**
- "Created by" and "Last modified by" info
- Modification timestamp
- Change log (who changed what, when)
- Related questions (if part of parent-child set)

---

#### **3.5 Bulk Import from Spreadsheet**

**Features:**
- Upload CSV/Excel file
- Template download buttons (Parents, Children)
- File validation before upload
- Preview imported data in table
- Error report with line numbers
- Fix errors inline (optional)
- Mapping tool (if columns don't match template)
- Import progress bar
- Success/failure summary
- Rollback option (if errors occur)

**Validation Checks:**
- Required fields present
- Valid data types
- Parent-child ID matching
- Topic names match blueprints
- Mark totals match
- PQP numbering format
- No duplicate IDs

**UI Components:**
- File upload dropzone
- Template download section
- Data preview table (editable)
- Error list with line numbers
- Column mapping interface
- Progress indicator
- Import summary modal

---

### **4. Parent-Child Set Management**

#### **4.1 Parent-Child Browser**

**Features:**
- List view of all parent documents
- Show parent ID, topic, total marks, # of children
- Expand/collapse to show children
- Filter by subject, grade, topic
- Search by parent ID or context text
- Actions: View, Edit, Duplicate, Delete

**UI Components:**
- Expandable table rows
- Parent row styling (distinct from children)
- Child count badge
- Quick actions menu
- Expand all / Collapse all buttons

#### **4.2 Edit Parent-Child Set**

**Features:**
- Load parent + all children
- Edit parent context
- Add new children to existing parent
- Edit individual children
- Remove children (with confirmation)
- Reorder children
- Recalculate total marks automatically
- Update button (saves all changes in batch)

**UI Components:**
- Split view: Parent (left) + Children (right)
- Add child button
- Child cards with inline editing
- Drag handles for reordering
- Delete confirmation modal

---

### **5. Blueprint Management**

#### **5.1 Blueprint List**

**Features:**
- List all blueprints by subject
- Show: Subject, Grade, Total marks, # of topics
- Search by subject
- Filter by grade
- Actions: View, Edit, Duplicate, Create new

**UI Components:**
- Card layout (one card per blueprint)
- Subject icon/image
- Key stats display
- Action buttons

#### **5.2 Create/Edit Blueprint**

**Form Sections:**

**A. Basic Info**
- Subject (dropdown)
- Grade (dropdown)
- Paper (P1, P2, P3)
- Total marks (number input)
- Duration (minutes)

**B. Topics & Mark Allocation**
- Add topic button
- Topic list (editable/deletable):
  - Topic name (text input with autocomplete)
  - Marks allocated (number input)
  - Cognitive level distribution (sliders or inputs):
    - Level 1: X marks
    - Level 2: X marks
    - Level 3: X marks
    - Level 4: X marks
  - Move up/down (reorder buttons)

**C. Question Format Distribution**
- MCQ: X marks (number input)
- Short Answer: X marks
- Drag & Drop: X marks
- Essay: X marks
- Total calculation (auto-updates)

**D. Validation & Preview**
- Check total marks match
- Check cognitive levels sum correctly
- Preview blueprint structure
- Save button

**UI Components:**
- Dynamic list builder for topics
- Progress bars for mark distribution
- Validation warnings (real-time)
- Pie chart preview (mark distribution)
- Save/Cancel buttons

---

### **6. Image Management**

#### **6.1 Image Library**

**Features:**
- Gallery view of all uploaded images
- Thumbnail preview
- Filter by:
  - Upload date
  - Subject
  - Used/Unused
  - File type (PNG, JPG, SVG)
- Search by filename
- View image details (size, dimensions, URL, usage count)
- Bulk delete unused images
- Copy public URL

**UI Components:**
- Grid layout with thumbnails
- Image detail modal on click
- Filter sidebar
- Search bar
- Copy URL button (with toast notification)
- Delete confirmation

#### **6.2 Image Upload**

**Features:**
- Drag & drop multiple files
- File type validation (PNG, JPG, SVG, WebP)
- File size limit (5MB per image)
- Auto-resize/compress large images
- Add alt text and tags
- Progress bar for upload
- Generate public URL
- Option to link to question/parent immediately

**UI Components:**
- Dropzone area
- Upload queue with progress bars
- Thumbnail preview after upload
- Tag input field
- Success/error notifications

---

### **7. User Management** (Super Admin Only)

#### **7.1 User List**

**Features:**
- Table of all admin users
- Show: Email, Name, Role, Last login
- Filter by role
- Search by email/name
- Actions: Edit, Deactivate, Delete

**UI Components:**
- Data table with pagination
- Role badge (color-coded)
- Last login timestamp
- Active/Inactive status indicator
- Action menu (three dots)

#### **7.2 Add/Edit User**

**Form Fields:**
- Email (text input, validated)
- Full name (text input)
- Role (dropdown)
- Subject restrictions (for Subject Experts, multi-select)
- Grade restrictions (multi-select)
- Active status (toggle switch)
- Send welcome email (checkbox)

**UI Components:**
- Form with validation
- Role explanation tooltips
- Conditional fields (show restrictions only for Subject Expert)
- Save button

#### **7.3 Activity Log**

**Features:**
- Timeline of all user actions
- Filter by:
  - User
  - Action type (Create, Edit, Delete, Login)
  - Date range
- Export activity report (CSV)

**UI Components:**
- Timeline view
- Filter controls
- Export button
- Detailed action modal on click

---

### **8. Analytics & Reports**

#### **8.1 Question Statistics**

**Charts/Metrics:**
- Questions by subject (pie chart)
- Questions by format (bar chart)
- Questions by cognitive level (stacked bar)
- Questions by difficulty (pie chart)
- Upload trend over time (line chart)
- Top contributors (table)

**UI Components:**
- Interactive charts (Chart.js or similar)
- Date range selector
- Export as image/PDF
- Filter by subject/grade

#### **8.2 Content Health Dashboard**

**Metrics:**
- Questions missing images
- Questions with validation errors
- Orphaned children (parent deleted)
- Unused images
- Duplicate question text
- Blueprint compliance (% of topics covered)

**UI Components:**
- Warning cards (color-coded)
- Click to view affected questions
- Fix suggestions
- Batch fix tools

#### **8.3 Usage Analytics** (Future)

**Metrics:**
- Most practiced questions
- Question difficulty vs. student performance
- Average time per question
- Hint usage statistics
- Topic popularity

**UI Components:**
- Interactive dashboards
- Date range filters
- Export reports

---

### **9. System Settings** (Super Admin Only)

#### **9.1 General Settings**

**Configuration Options:**
- App name and branding
- Default marks per question type
- Default time allocations
- Cognitive level definitions
- Difficulty criteria

**UI Components:**
- Settings form with sections
- Save changes button
- Reset to defaults option

#### **9.2 Topic & Subject Management**

**Features:**
- Add/edit/delete subjects
- Add/edit/delete topics per subject
- Reorder topics
- Set topic categories
- Topic aliases (for search)

**UI Components:**
- Tree view (Subject → Topics)
- Add/edit/delete buttons
- Drag-drop reordering
- Confirmation dialogs

#### **9.3 Backup & Restore**

**Features:**
- Create full database backup
- Schedule automatic backups
- Download backup files
- Restore from backup (with confirmation)
- View backup history

**UI Components:**
- Backup now button
- Backup schedule settings
- Backup list with dates
- Download/Restore buttons
- Progress indicators

---

## 🎨 UI/UX Design Guidelines

### **Design System:**
- Use app's existing "Paper & Ink" theme
- Colors: Ink (#262626), Paper (#F5F5F5), Accent (#FF7A1A)
- Consistent spacing (8px grid)
- Rounded corners (12px)
- Drop shadows for elevation

### **Responsive Design:**
- Desktop-first (1920x1080 optimal)
- Tablet support (1024x768)
- Mobile view (basic, for emergency edits)

### **Accessibility:**
- WCAG 2.1 AA compliance
- Keyboard navigation support
- Screen reader friendly
- High contrast mode option
- Text size adjustment

### **Navigation:**
- Persistent sidebar (collapsible)
- Breadcrumb navigation
- Quick search (Ctrl+K / Cmd+K)
- Keyboard shortcuts for common actions
- Context menus (right-click)

---

## 🔐 Security Features

### **Authentication:**
- Firebase Authentication
- Email verification required
- Password complexity requirements
- Session timeout (30 min inactivity)
- Force logout on role change

### **Authorization:**
- Role-based access control (RBAC)
- Route-level permissions
- API-level permissions (Cloud Functions)
- Action-level checks (edit, delete, publish)

### **Data Protection:**
- Input sanitization (prevent XSS)
- SQL injection prevention (Firestore queries)
- Rate limiting on API calls
- File upload validation
- HTTPS only

### **Audit Trail:**
- Log all create/edit/delete actions
- Track user IP addresses
- Export audit logs
- Retention policy (1 year)

---

## 📱 Mobile Considerations

### **Responsive Breakpoints:**
- Desktop: ≥1200px (full features)
- Tablet: 768px - 1199px (adapted layout)
- Mobile: <768px (limited features)

### **Mobile Limitations:**
- Read-only mode recommended
- Simple edits allowed (text changes)
- Image upload not recommended
- Bulk operations disabled
- Use mobile app for content consumption

---

## 🚀 Implementation Phases

### **Phase 1: MVP (8-10 weeks)**
**Features:**
- Basic authentication (email/password)
- Dashboard with statistics
- Create/edit/delete standalone questions
- Question list with search & filter
- Image upload
- Basic role management (Admin, Content Manager)

**Deliverables:**
- Login system
- Question CRUD operations
- Image management
- Basic dashboard

### **Phase 2: Parent-Child Management (4-6 weeks)**
**Features:**
- Create/edit parent-child sets
- Parent-child browser
- Bulk import from CSV
- Enhanced validation

**Deliverables:**
- Parent-child creation wizard
- Spreadsheet import tool
- Validation engine

### **Phase 3: Advanced Features (6-8 weeks)**
**Features:**
- Blueprint management
- Analytics dashboard
- User activity log
- Content health monitoring
- Backup & restore

**Deliverables:**
- Blueprint editor
- Analytics charts
- Audit logging
- System health dashboard

### **Phase 4: Polish & Optimization (4 weeks)**
**Features:**
- Performance optimization
- Advanced search
- Keyboard shortcuts
- Accessibility improvements
- Mobile responsive refinements

**Deliverables:**
- Optimized performance
- Full accessibility compliance
- Mobile-friendly interface

---

## 🧪 Testing Requirements

### **Unit Tests:**
- Form validation logic
- Data transformation functions
- Permission checks
- Utility functions

### **Integration Tests:**
- Firebase Authentication flow
- Firestore CRUD operations
- File upload to Storage
- Cloud Functions API calls

### **E2E Tests:**
- Complete question creation flow
- Parent-child set creation
- Bulk import process
- User role switching
- Search and filter operations

### **User Acceptance Testing:**
- Content Manager workflow
- Subject Expert workflow
- Super Admin tasks
- Error handling scenarios

---

## 📊 Success Metrics

### **Performance:**
- Page load time: <2 seconds
- Form submission: <1 second
- Image upload: <5 seconds (per image)
- Search results: <500ms
- Bulk import: 100 questions/minute

### **Usability:**
- Time to create standalone question: <3 minutes
- Time to create parent-child set: <8 minutes
- User error rate: <5%
- Task completion rate: >95%
- User satisfaction: >4/5 stars

### **Adoption:**
- 80% of questions created via admin portal (not manual scripts)
- 3+ active content managers
- 10+ questions added per week
- Zero critical bugs in production

---

## 🛠️ Technical Architecture

### **Frontend Structure:**
```
lib/
├── admin/
│   ├── main_admin.dart              # Admin entry point
│   ├── routes/                      # Admin routes
│   ├── views/
│   │   ├── dashboard/
│   │   ├── questions/
│   │   │   ├── question_list_view.dart
│   │   │   ├── question_create_view.dart
│   │   │   ├── question_edit_view.dart
│   │   │   └── parent_child_create_view.dart
│   │   ├── blueprints/
│   │   ├── users/
│   │   ├── analytics/
│   │   └── settings/
│   ├── viewmodels/
│   │   ├── question_admin_viewmodel.dart
│   │   ├── user_management_viewmodel.dart
│   │   └── analytics_viewmodel.dart
│   ├── widgets/
│   │   ├── admin_sidebar.dart
│   │   ├── rich_text_editor.dart
│   │   ├── image_uploader.dart
│   │   └── validation_indicator.dart
│   └── services/
│       ├── admin_auth_service.dart
│       └── admin_api_service.dart
```

### **Backend (Cloud Functions):**
```
functions/src/
├── admin/
│   ├── questions.js        # Question CRUD
│   ├── parents.js          # Parent-child operations
│   ├── blueprints.js       # Blueprint management
│   ├── users.js            # User management
│   ├── import.js           # Bulk import handler
│   └── analytics.js        # Analytics aggregation
├── middleware/
│   ├── auth.js             # Role verification
│   └── validation.js       # Input validation
└── utils/
    └── permissions.js      # Permission checks
```

### **Database Structure:**
```
Firestore:
/questions          (existing)
/blueprints         (existing)
/users              (existing)
/admin_users        (new - admin-specific data)
/audit_log          (new - activity tracking)
/drafts             (new - unpublished questions)
```

---

## 💰 Cost Considerations

### **Firebase Usage:**
- **Firestore:** ~$0.06 per 100k reads (low impact)
- **Cloud Functions:** ~$0.40 per million invocations
- **Storage:** ~$0.026 per GB/month (images)
- **Hosting:** Free tier sufficient

### **Estimated Monthly Cost:**
- Small team (3-5 users): $5-10/month
- Medium team (10-20 users): $20-30/month
- Large team (50+ users): $50-100/month

---

## 📚 Documentation Requirements

### **User Guides:**
- Quick start guide (PDF)
- Video tutorials (10 min each):
  - Creating standalone questions
  - Creating parent-child sets
  - Bulk import process
  - Managing users (for admins)
- FAQ document
- Troubleshooting guide

### **Technical Docs:**
- API documentation (Cloud Functions)
- Database schema
- Role permission matrix
- Deployment guide
- Backup/recovery procedures

---

## 🎓 Training Plan

### **Content Manager Training:**
- 2-hour workshop (hands-on)
- Topics:
  - Creating questions
  - Using parent-child structure
  - Image management
  - Quality assurance tips
- Practice exercises
- Certification quiz

### **Subject Expert Training:**
- 1-hour workshop
- Focus on question creation only
- Subject-specific examples
- Best practices for hints

### **Super Admin Training:**
- 3-hour comprehensive training
- User management
- System configuration
- Analytics interpretation
- Troubleshooting

---

## 🔮 Future Enhancements (Post-Launch)

### **AI-Assisted Features:**
- Question text auto-completion
- Answer variation suggestions
- Difficulty estimation based on text
- Topic auto-tagging
- Image OCR for extracting text

### **Collaboration:**
- Multi-user editing (with conflict resolution)
- Comment system on questions
- Review/approval workflow
- Version comparison (diff view)

### **Advanced Analytics:**
- Predictive difficulty scoring
- Topic gap analysis
- Question performance predictions
- Content recommendations

### **Integrations:**
- Google Sheets sync
- LMS integration (Moodle, Canvas)
- LaTeX equation editor (embedded)
- Plagiarism checker

---

**Document Version:** 1.0  
**Last Updated:** October 3, 2025  
**Author:** Kinetix Engineering Solutions  
**Status:** Specification - Pending Approval
