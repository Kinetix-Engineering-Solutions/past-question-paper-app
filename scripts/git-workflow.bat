@echo off
REM Simple Git Workflow Helper for Windows
REM Usage: scripts\git-workflow.bat [command] [name]

if "%1"=="" goto :help
if "%1"=="help" goto :help

if "%1"=="feature" (
    if "%2"=="" (
        echo Please provide a feature name
        exit /b 1
    )
    echo Creating feature branch: feature/%2
    git checkout develop
    git pull origin develop
    git checkout -b feature/%2
    git push -u origin feature/%2
    echo Done! Start coding. When finished, run: scripts\git-workflow.bat finish
    goto :end
)

if "%1"=="fix" (
    if "%2"=="" (
        echo Please provide a fix name
        exit /b 1
    )
    echo Creating fix branch: fix/%2
    git checkout develop
    git pull origin develop
    git checkout -b fix/%2
    git push -u origin fix/%2
    echo Done! Start fixing. When finished, run: scripts\git-workflow.bat finish
    goto :end
)

if "%1"=="finish" (
    for /f %%i in ('git branch --show-current') do set current_branch=%%i
    echo Pushing %current_branch% and opening PR...
    git push origin %current_branch%
    start https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/compare/develop...%current_branch%?quick_pull=1
    echo PR opened in browser. Ask teammate for review!
    goto :end
)

if "%1"=="promote-staging" (
    echo Preparing develop -^> staging promotion...
    git checkout develop
    git pull origin develop
    git push origin develop
    start https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/compare/staging...develop?quick_pull=1
    echo PR opened for develop -^> staging.
    goto :end
)

if "%1"=="promote-master" (
    echo Preparing staging -^> master promotion...
    git checkout staging
    git pull origin staging
    git push origin staging
    start https://github.com/Kinetix-Engineering-Solutions/past-question-paper-v0.01/compare/master...staging?quick_pull=1
    echo PR opened for staging -^> master.
    goto :end
)

echo Unknown command: %1

:help
echo Simple Git Workflow Helper
echo.
echo Commands:
echo   feature [name]    Create new feature branch
echo   fix [name]        Create new fix branch  
echo   finish            Push branch and open PR
echo   promote-staging   Open PR develop -^> staging
echo   promote-master    Open PR staging -^> master
echo.
echo Examples:
echo   scripts\git-workflow.bat feature login-page
echo   scripts\git-workflow.bat fix crash-bug
echo   scripts\git-workflow.bat finish
echo   scripts\git-workflow.bat promote-staging
echo   scripts\git-workflow.bat promote-master

:end
