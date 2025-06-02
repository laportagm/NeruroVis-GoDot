#\!/bin/bash

# Log file for cleanup operations
echo "Cleanup operations log - $(date)" > cleanup_log.txt

# 1. Clean up temporary directories
echo "Cleaning up temporary directories..." | tee -a cleanup_log.txt
rm -rf temp_syntax_check >> cleanup_log.txt 2>&1
rm -f temp_line_reader.py >> cleanup_log.txt 2>&1

# 2. Remove redundant backup directories
echo "Removing redundant backup directories..." | tee -a cleanup_log.txt
rm -rf copy3 >> cleanup_log.txt 2>&1

# 3. Remove backup files
echo "Removing backup files..." | tee -a cleanup_log.txt
rm -f project.godot.backup >> cleanup_log.txt 2>&1
rm -f scenes/*.bak >> cleanup_log.txt 2>&1

# 4. Remove original test files that were already moved
echo "Removing original test files (already moved to proper locations)..." | tee -a cleanup_log.txt
if [ -f files_to_delete.txt ]; then
  cat files_to_delete.txt | while read file; do
    if [[ $file == \#* ]]; then
      continue # Skip comment lines
    fi
    if [ -f "$file" ]; then
      echo "Removing $file" | tee -a cleanup_log.txt
      rm "$file" >> cleanup_log.txt 2>&1
    fi
  done
fi

# 5. Remove redundant test runners from root
echo "Removing redundant test runners..." | tee -a cleanup_log.txt
for file in run_button_action_tests.sh run_gemini_key_test.sh run_gemini_manual_test.sh run_gemini_test.sh test_google_console_state.sh; do
  if [ -f "$file" ]; then
    echo "Removing $file" | tee -a cleanup_log.txt
    rm "$file" >> cleanup_log.txt 2>&1
  fi
done

# 6. Create a report of what was removed
echo "Cleanup completed. See cleanup_log.txt for details." | tee -a cleanup_log.txt
echo "For safety, the 'tmp/' directory was not removed. You may want to review it manually." | tee -a cleanup_log.txt

