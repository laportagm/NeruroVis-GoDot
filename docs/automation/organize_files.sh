#\!/bin/bash

# Create log file for operations
echo "File organization log - $(date)" > organize_log.txt

# Move AI test files to tests/integration/ai/
echo "Moving AI test files..." | tee -a organize_log.txt
for file in test_ai_*.gd test_gemini_*.gd; do
  if [ -f "$file" ]; then
    echo "Moving $file to tests/integration/ai/" | tee -a organize_log.txt
    cp "$file" "tests/integration/ai/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tests/integration/ai/"
    fi
  fi
done

# Move UI tests to tests/unit/ui/
echo "Moving UI test files..." | tee -a organize_log.txt
for file in test_*ui*.gd test_responsive*.gd; do
  if [ -f "$file" ]; then
    echo "Moving $file to tests/unit/ui/" | tee -a organize_log.txt
    cp "$file" "tests/unit/ui/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tests/unit/ui/"
    fi
  fi
done

# Move core development scripts to tools/scripts/core_dev/
echo "Moving core development scripts..." | tee -a organize_log.txt
for file in enable_core_development_mode.gd disable_core_development_mode.gd fix_core_development_flags.gd validate_core_dev_mode.gd; do
  if [ -f "$file" ]; then
    echo "Moving $file to tools/scripts/core_dev/" | tee -a organize_log.txt
    cp "$file" "tools/scripts/core_dev/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tools/scripts/core_dev/"
    fi
  fi
done

# Move other validation scripts to tools/scripts/
echo "Moving validation scripts..." | tee -a organize_log.txt
for file in validate_ai_commands.gd test_syntax.gd; do
  if [ -f "$file" ]; then
    echo "Moving $file to tools/scripts/" | tee -a organize_log.txt
    cp "$file" "tools/scripts/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tools/scripts/"
    fi
  fi
done

# Move test runners to tests/
echo "Moving test runners..." | tee -a organize_log.txt
for file in run_neurovis_tests.gd run_ai_debug_test.gd; do
  if [ -f "$file" ]; then
    echo "Moving $file to tests/" | tee -a organize_log.txt
    cp "$file" "tests/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tests/"
    fi
  fi
done

# Move remaining test files to tests/integration/
echo "Moving remaining test files..." | tee -a organize_log.txt
for file in test_*.gd; do
  if [ -f "$file" ] && [[ \! "$file" == test_*ui* ]] && [[ \! "$file" == test_responsive* ]] && [[ \! "$file" == test_ai_* ]] && [[ \! "$file" == test_gemini_* ]] && [[ \! "$file" == test_syntax.gd ]]; then
    echo "Moving $file to tests/integration/" | tee -a organize_log.txt
    cp "$file" "tests/integration/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tests/integration/"
    fi
  fi
done

# Move utility scripts to tools/scripts/
echo "Moving utility scripts..." | tee -a organize_log.txt
for file in quick_test.gd; do
  if [ -f "$file" ]; then
    echo "Moving $file to tools/scripts/" | tee -a organize_log.txt
    cp "$file" "tools/scripts/"
    if [ -f "${file}.uid" ]; then
      cp "${file}.uid" "tools/scripts/"
    fi
  fi
done

echo "File copying completed. Please review organize_log.txt before deleting original files." | tee -a organize_log.txt
