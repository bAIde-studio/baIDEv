import os
import subprocess

# Get the directory of the 'build.ps1' script (assuming it's in the same dir as this script)
build_script_dir = os.path.dirname(__file__)

# Build the full path to the script
build_script_path = os.path.join(build_script_dir, "build.ps1")

# Check if the script exists
if os.path.isfile(build_script_path):
    print("Running 'build.ps1'")
    subprocess.run(["powershell.exe", "-ExecutionPolicy", "Bypass", build_script_path])
else:
    print("Warning: 'build.ps1' not found.")


# -- Running Scripts in the 'runner' Directory --

# Get the runner directory path (assuming it's in the same directory as the script)
runner_dir = os.path.join(os.path.dirname(__file__), "runners")

# Verify that the 'runner' directory exists
if not os.path.exists(runner_dir):
    print("Warning: Directory 'runners' does not exist.")
else:
    print(f"Runner directory found at: {runner_dir}")

# Get all .ps1 and .bat files
scripts = [f for f in os.listdir(runner_dir) if f.endswith(('.ps1', '.bat'))]

# Run each script
for script in scripts:
    script_type = os.path.splitext(script)[1][1:]  # Get type (ps1 or bat)
    print(f"Running {script}")

    script_path = os.path.join(runner_dir, script)

    # Execute the script
    if script_type == "ps1":
        subprocess.run(["powershell.exe", "-ExecutionPolicy", "Bypass", script_path])
    else:  # Assuming script_type == "bat"
        subprocess.run(script_path)
