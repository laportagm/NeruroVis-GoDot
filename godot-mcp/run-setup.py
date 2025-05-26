#!/usr/bin/env python3

import os
import subprocess
import sys
from datetime import datetime

print("Godot MCP - Permission Fix and Final Setup")
print("==========================================")
print()

# Change to script directory
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

try:
    # Step 1: Make all scripts executable
    print("Step 1: Making all scripts executable...")
    
    scripts = [
        'make-executable.sh',
        'setup.sh',
        'test.sh',
        'rebuild.sh',
        'rebuild-and-log.sh',
        'run-build-test.sh',
        'complete-rebuild.sh',
        'final-setup-verify.sh',
        'test-server.sh',
        'test-build.sh',
        'fix-and-setup.sh',
        'execute-setup.sh'
    ]
    
    for script in scripts:
        if os.path.exists(script):
            os.chmod(script, 0o755)  # rwxr-xr-x
            print(f"  ✅ {script}")
    
    print("\n✅ All scripts are now executable\n")
    
    # Step 2: Run the final setup
    print("Step 2: Running final setup...")
    print("=============================\n")
    
    # Run the setup script
    result = subprocess.run(['./final-setup-verify.sh'], 
                          capture_output=True, 
                          text=True)
    
    # Print output
    print(result.stdout)
    
    if result.stderr:
        print("Stderr:", result.stderr)
    
    if result.returncode == 0:
        print("\n✅ Setup completed successfully!")
        print("\nNext steps:")
        print("1. Restart Claude Desktop")
        print("2. Test with Godot commands like:")
        print('   - "List all scenes in my project"')
        print('   - "Launch the Godot editor"')
    else:
        print("\n❌ Setup failed with exit code:", result.returncode)
        
        # Save error log
        with open('setup-error.log', 'w') as f:
            f.write(f"Setup Error Log\n")
            f.write(f"===============\n")
            f.write(f"Time: {datetime.now().isoformat()}\n\n")
            f.write(f"Exit Code: {result.returncode}\n\n")
            f.write(f"Stdout:\n{result.stdout}\n\n")
            f.write(f"Stderr:\n{result.stderr}\n")
        
        print("Error log saved to: setup-error.log")
        sys.exit(1)
        
except Exception as e:
    print(f"\n❌ Error: {str(e)}")
    
    # Save error log
    with open('setup-error.log', 'w') as f:
        f.write(f"Setup Error Log\n")
        f.write(f"===============\n")
        f.write(f"Time: {datetime.now().isoformat()}\n\n")
        f.write(f"Error: {str(e)}\n")
        f.write(f"Type: {type(e).__name__}\n")
    
    print("Error log saved to: setup-error.log")
    sys.exit(1)
