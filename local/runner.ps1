

# -- Running Scripts in the 'runner' Directory --

# Get the runner directory path (assuming it's in the same directory as the script)
$runnerDir = Join-Path $PSScriptRoot "runners"

# Verify that the 'runner' directory exists
if (-not (Test-Path $runnerDir)) {
    Write-Warning "Directory 'runners' does not exist."
    break  # Skip this section if the directory is missing
}
else {
    Write-Host "Runner directory found at: $runnerDir"
}



# Get all .ps1 and .bat files
#$scripts = Get-ChildItem $runnerDir -Filter *.ps1, *.bat
$scripts = Get-ChildItem $runnerDir -Filter "*.*" -Include "*.ps1", "*.bat"

# Run each script
foreach ($script in $scripts) {
    $scriptType = $script.Extension.TrimStart(".") # Get type (ps1 or bat)
    Write-Host "Running $($script.Name)"

    # Execute the script
    if ($scriptType -eq "ps1") {
        # Call PowerShell to run a .ps1 script
        & $script.FullName
    } else {
        # Directly call a .bat script
        Start-Process $script.FullName
    }
}
