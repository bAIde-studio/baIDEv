# Get the current script's directory
$scriptDir = $PSScriptRoot

# Construct the full path to the new file
$filePath = Join-Path $scriptDir "test.txt"

# Create the file (can optionally add content)
New-Item -ItemType File -Path $filePath
