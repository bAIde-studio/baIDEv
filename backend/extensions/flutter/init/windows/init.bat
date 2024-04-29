@echo off

:: 1. Check for Dart
dart --version > NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo "Dart not found. Attempting to install..."

    :: Attempt winget install
    winget install dart > NUL 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo "Winget installation failed. Trying Chocolatey..."

        :: Attempt Chocolatey install
        choco install dart-sdk > NUL 2>&1
        IF %ERRORLEVEL% NEQ 0 (
            echo "Installation via winget anddd Chocolatey failed."
            echo "Please download and install Dart manually from https://dart.dev/get-dart"
            pause
            start https://dart.dev/get-dart
        )
    )

    ELSE (
        echo "Dart is already installed."
    )
)

:: 2. Check for Flutter
flutter --version > NUL 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo "Flutter not found. Attempting to install..."

    :: Repeat logic similar to Dart installation using winget and choco here
    :: ...

)

:: 3. Project Creation (Powershell portion)
powershell -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -NoExit -File .\create_project.ps1'"

:: 4. Open in Explorer
echo "Project setup complete. Please verify the path and files."
pause
explorer .
