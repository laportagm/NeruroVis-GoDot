#\!/bin/bash

# Create a list of files that can be deleted
echo "# Files that can be deleted from the root directory:" > files_to_delete.txt

# List all the script files we've organized
for file in test_*.gd run_*.gd validate_*.gd enable_*.gd disable_*.gd fix_*.gd quick_test.gd; do
  if [ -f "$file" ]; then
    echo "$file" >> files_to_delete.txt
    # Also list the .uid files if they exist
    if [ -f "${file}.uid" ]; then
      echo "${file}.uid" >> files_to_delete.txt
    fi
  fi
done

echo "Created files_to_delete.txt listing all files that can be deleted from root"
echo "Review this file and when ready, run:"
echo "rm \$(cat files_to_delete.txt)"
