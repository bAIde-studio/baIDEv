# -- Backend Build Script --

# (Assumption: You're starting in the project's root directory)
$backendDir = "..\backend"

# 1. System Requirements
# * You'll need to provide or download installers for:
#   - Python 3
#   - ImageMagick
#   - Font tools (if equivalents for Windows exist)
#   - Install these manually or script their silent installation if possible

# 2. Java Installation
#   * Download Adoptium JDK 21 for Windows from https://adoptium.net
#   * Set JAVA_HOME environment variable using PowerShell commands (consider Set-Item Env:JAVA_HOME ...)

# 3. User and Directories (If Needed on Windows)
#   * Might need to create the 'penpot' user using Windows tools or adjust file permissions (Set-ACL)
#   * Create necessary directories:
#       New-Item -ItemType Directory -Path 'C:\opt\penpot' -Force
#       New-Item -ItemType Directory -Path 'C:\opt\data\assets' -Force

# 4. Copy Backend Code
Copy-Item -Path $backendDir -Destination 'C:\opt\penpot\backend' -Recurse

# 5. Running the 'run.sh'
#   * If 'run.sh' is a Bash script, you likely need:
#       - Install WSL (Windows Subsystem for Linux)
#       - Execute it within WSL:   wsl /opt/penpot/backend/run.sh
