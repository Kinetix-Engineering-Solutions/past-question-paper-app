# 🤝 Team Collaboration Guide

Simple and practical guide for working together on the Past Question Papers project.

## � Basic Branch Strategy

```
main (production) ← Always stable, ready for release
└── develop ← Integration branch for new features
    ├── feature/login-system
    ├── feature/question-types  
    └── feature/user-dashboard
```

## 📝 Simple Workflow

### 1. Starting New Work
```bash
# Get latest code
git checkout develop
git pull origin develop

# Create your branch  
git checkout -b feature/your-feature-name

# Work on your changes...
# Commit often with clear messages
git add .
git commit -m "Add user login form"

# Push your branch
git push origin feature/your-feature-name
```

### 2. Getting Your Changes Reviewed
1. Go to GitHub and create a Pull Request
2. Ask a teammate to review your changes
3. Make any requested changes
4. Once approved, merge to `develop`

### 3. Branch Naming (Keep it Simple)
- `feature/login-page` - New features
- `fix/crash-on-startup` - Bug fixes  
- `update/readme` - Documentation updates

## � Release Process

### When ready to release:
```bash
# Test everything on develop branch
# If all good, merge develop → main
git checkout main
git pull origin main
git merge develop
git push origin main

# Tag the release
git tag v1.0.0
git push origin v1.0.0
```

## 👥 Team Communication

### Daily Check-ins
- Quick sync on what everyone is working on
- Share any blockers or questions
- Coordinate who reviews what

### Code Review Checklist
- ✅ Code works and solves the problem
- ✅ No obvious bugs or issues
- ✅ Code is readable and makes sense
- ✅ Follows basic Flutter/Dart conventions

## 🛡️ Keep It Secure

### Never Commit These Files:
- `lib/firebase_options.dart` 
- `android/app/google-services.json`
- `.env` files
- Any file with API keys or passwords

### Share Config Safely:
1. Use the template files (`firebase_options_template.dart`)
2. Team members get their own Firebase keys
3. Each developer sets up their own `.env` file

## � Quick Commands

### Use the helper script:
```bash
# Windows
scripts\git-workflow.bat feature my-new-feature
scripts\git-workflow.bat finish

# Mac/Linux  
./scripts/git-workflow.sh feature my-new-feature
./scripts/git-workflow.sh finish
```

### Or do it manually:
```bash
# Create feature branch
git checkout develop
git pull origin develop  
git checkout -b feature/my-feature

# Finish and create PR
git push origin feature/my-feature
# Then go to GitHub to create Pull Request
```

## 🔧 Development Setup

### New Team Member Checklist:
1. Clone the repo
2. Run `flutter doctor` to check setup
3. Copy `.env.example` to `.env` and fill in values
4. Set up Firebase (see `FIREBASE_SETUP.md`)
5. Run `flutter pub get`
6. Run `flutter test` to make sure everything works
7. Create your first feature branch and start coding!

---

**That's it! Keep it simple and focus on building great features together! 🚀**
