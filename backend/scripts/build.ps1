echo off
set CURRENT_VERSION=%1

rem -- Adapt commands --
rd /s /q target 2>nul
mkdir target\classes 2>nul
mkdir target\dist 2>nul
echo %CURRENT_VERSION% > target\classes\version.txt
copy ..\CHANGES.md target\classes\changelog.md

clojure -T:build jar
move target\penpot.jar target\dist\penpot.jar
copy resources\log4j2.xml target\dist\log4j2.xml
copy scripts\run.template.sh target\dist\run.sh
copy scripts\manage.py target\dist\manage.py

rem -- Prefetch templates --
rd /s /q builtin-templates 2>nul
mkdir builtin-templates
bb ./scripts/prefetch-templates.clj resources/app/onboarding.edn builtin-templates/
xcopy /E /I builtin-templates target\dist\
