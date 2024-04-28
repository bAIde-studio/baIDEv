# Get project details from the user
$projectName = Read-Host -Prompt "Enter project name"
$projectDirectory = Read-Host -Prompt "Enter desired project directory (full path)"

# Create the Flutter project
New-Item -ItemType Directory -Path $projectDirectory -Force
cd $projectDirectory
flutter create $projectName

# Inform the user
Write-Host "Flutter project created successfully!"
