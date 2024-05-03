# Get project details from the user
$projectName = Read-Host -Prompt "Enter project name"
$projectDirectory = Read-Host -Prompt "Enter desired project directory (full path)"

# Create the Flutter project
New-Item -ItemType Directory -Path $projectDirectory -Force
cd $projectDirectory
flutter create $projectName

# Inform the user
Write-Host "Flutter project created successfully!"

# Start the development server (assuming typical Flutter port)
Write-Host "Starting Flutter development server..."
flutter run

# Inform the user about the server
Write-Host "bAIdev is running locally at http://localhost:9001"
Write-Host "open in your browser and start coding!!!"











# # Get project details from the user
# $projectName = Read-Host -Prompt "Enter project name"
# $projectDirectory = Read-Host -Prompt "Enter desired project directory (full path)"
#
# # Create the Flutter project
# New-Item -ItemType Directory -Path $projectDirectory -Force
# cd $projectDirectory
# flutter create $projectName
#
# # Inform the user
# Write-Host "Flutter project created successfully!"
