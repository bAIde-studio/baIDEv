# -- Checking for Required Dependencies --

function Check-Windows-Installation($programName) {
    Write-Host "Checking for $programName on Windows..."
    if (-not (Get-Command $programName -ErrorAction SilentlyContinue)) {
        Write-Warning "$programName is not installed on Windows."
        return $false
    } else {
        Write-Host "$programName is installed."
        return $true
    }
}

#function Check-WSL-Installation($programName) {
#    Write-Host "Checking for $programName in WSL..."
#    if (-not (wsl $programName --version 2>/dev/null)) {
#        Write-Warning "$programName is not installed in WSL."
#        return $false
#    } else {
#        Write-Host "$programName is installed in WSL."
#        return $true
#    }
#}



function Check-WSL-Installation($programName) {
    Write-Host "Checking for $programName in WSL..."

    # Get installed WSL distributions
    $wslDistros = wsl --list --quiet

#    wsl -d $distro $programName --version | Out-Null


    if (!$wslDistros) {
        Write-Warning "No WSL distributions found."
        return $false
    }

    # Check each distribution
    foreach ($distro in $wslDistros) {
#        $result = wsl -d $distro $programName --version 2>/dev/null
        $result = wsl -d $distro $programName --version | Out-Null

        if ($result) {
            Write-Host "$programName is installed in WSL ($distro)."
            return $true
        }
    }

    # Not found in any distro
    Write-Warning "$programName is not installed in any available WSL distribution."
    return $false
}



# Example programs to check
$programsToCheck = @(
    "psql",
    "redis-server"  # Redis detection might need refined commands
    "node",
    "clojure",
    "openssl",
    "docker",
    "podman",
    "podman-compose",
    "docker-compose"
)

# Iterate through the programs
foreach ($program in $programsToCheck) {
    if (!(Check-Windows-Installation $program)) {
        if (!(Check-WSL-Installation $program)) {
            Write-Error "$program is REQUIRED for 'baIDev'. Please install it."
        }
    }
}

# -- Creating the Build Directory --
Write-Host "Creating build directory..."

# Get the current directory, go up one level
$buildDirParent = Split-Path -Parent (Get-Location).Path
$buildDirName = "build"
$buildDirPath = Join-Path $buildDirParent $buildDirName

## Attempt to create the build directory
#try {
#    New-Item -ItemType Directory -Path $buildDirPath -ErrorAction Stop
#    Write-Host "Build directory created at: $buildDirPath"
#} catch {
#    Write-Error "Failed to create build directory: $buildDirPath"
#}

# -- Checking for Existing Build Directory --
if (Test-Path $buildDirPath) {
    Write-Warning "Build directory already exists at: $buildDirPath"
    $userChoice = Read-Host "Delete and replace existing build directory? (y/N)"

    if ($userChoice.ToLower() -eq "y") {
        try {
            Remove-Item $buildDirPath -Recurse -Force -ErrorAction Stop
            Write-Host "Old build directory removed."
        } catch {
            Write-Error "Failed to remove old build directory: $buildDirPath"
            # Exit or provide further instructions here
        }
    } else {
        Write-Host "Using existing build directory."
        # ... Optionally, add logic to handle a non-empty build directory if needed
        break # Skip to the next step of your script if nothing else needs to be done
    }
}

# -- Creating the Build Directory --
# (This section is executed only if the old directory was removed or didn't exist)

try {
    New-Item -ItemType Directory -Path $buildDirPath -ErrorAction Stop
    Write-Host "Build directory created at: $buildDirPath"
} catch {
    Write-Error "Failed to create build directory: $buildDirPath"
}


