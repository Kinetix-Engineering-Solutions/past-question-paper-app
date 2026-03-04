#!/bin/bash
# Simple Git Workflow Helper
# Usage: ./scripts/git-workflow.sh [command] [name]

case "$1" in
    "feature")
        if [ -z "$2" ]; then
            echo "Please provide a feature name"
            exit 1
        fi
        echo "Creating feature branch: feature/$2"
        git checkout develop
        git pull origin develop
        git checkout -b "feature/$2"
        git push -u origin "feature/$2"
        echo "Done! Start coding. When finished, run: ./scripts/git-workflow.sh finish"
        ;;
    "fix")
        if [ -z "$2" ]; then
            echo "Please provide a fix name"
            exit 1
        fi
        echo "Creating fix branch: fix/$2"
        git checkout develop
        git pull origin develop
        git checkout -b "fix/$2"
        git push -u origin "fix/$2"
        echo "Done! Start fixing. When finished, run: ./scripts/git-workflow.sh finish"
        ;;
    "finish")
        current_branch=$(git branch --show-current)
        echo "Pushing $current_branch and opening PR..."
        git push origin "$current_branch"
        pr_url="https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/compare/develop...$current_branch?quick_pull=1"
        echo "Create PR at: $pr_url"
        # Try to open in browser
        if command -v open &> /dev/null; then
            open "$pr_url"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$pr_url"
        fi
        ;;
    "promote-staging")
        echo "Preparing develop -> staging promotion..."
        git checkout develop
        git pull origin develop
        git push origin develop
        pr_url="https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/compare/staging...develop?quick_pull=1"
        echo "Create PR at: $pr_url"
        if command -v open &> /dev/null; then
            open "$pr_url"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$pr_url"
        fi
        ;;
    "promote-master")
        echo "Preparing staging -> master promotion..."
        git checkout staging
        git pull origin staging
        git push origin staging
        pr_url="https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/compare/master...staging?quick_pull=1"
        echo "Create PR at: $pr_url"
        if command -v open &> /dev/null; then
            open "$pr_url"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$pr_url"
        fi
        ;;
    *)
        echo "Simple Git Workflow Helper"
        echo ""
        echo "Commands:"
        echo "  feature [name]    Create new feature branch"
        echo "  fix [name]        Create new fix branch"
        echo "  finish            Push branch and open PR"
        echo "  promote-staging   Open PR develop -> staging"
        echo "  promote-master    Open PR staging -> master"
        echo ""
        echo "Examples:"
        echo "  ./scripts/git-workflow.sh feature login-page"
        echo "  ./scripts/git-workflow.sh fix crash-bug"
        echo "  ./scripts/git-workflow.sh finish"
        echo "  ./scripts/git-workflow.sh promote-staging"
        echo "  ./scripts/git-workflow.sh promote-master"
        ;;
esac
