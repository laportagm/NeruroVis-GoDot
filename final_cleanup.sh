#\!/bin/bash

# Log file for final cleanup operations
echo "Final cleanup operations log - $(date)" > final_cleanup_log.txt

# 1. Move remaining reports to docs/reports
echo "Moving reports to docs/reports..." | tee -a final_cleanup_log.txt
for file in ALL_FIXES_SUMMARY.md CODE_QUALITY_STANDARDS_APPLIED.md SELECTION_OPTIMIZATION_REPORT.md TEST_REPORT.md PATH_FIXES_SUMMARY.md; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/reports/" | tee -a final_cleanup_log.txt
    mv "$file" docs/reports/
  fi
done

# 2. Move remaining scenes to tests/scenes
echo "Moving remaining test scenes..." | tee -a final_cleanup_log.txt
for file in validate_refactoring.tscn; do
  if [ -f "$file" ]; then
    echo "Moving $file to tests/scenes/" | tee -a final_cleanup_log.txt
    mv "$file" tests/scenes/
  fi
done

# 3. Move configuration scripts to scripts/configuration
echo "Moving configuration scripts..." | tee -a final_cleanup_log.txt
for file in setup_*.sh install_mcp_packages.sh fix_project_paths.sh disable_core_dev.sh enable_core_dev.sh; do
  if [ -f "$file" ]; then
    echo "Moving $file to scripts/configuration/" | tee -a final_cleanup_log.txt
    mv "$file" scripts/configuration/
  fi
done

# 4. Move validation scripts to tools/validation
echo "Moving validation scripts..." | tee -a final_cleanup_log.txt
for file in validate_*.sh run_validation_tests.sh check_errors.sh test_godot_mcp.sh run_tests.sh; do
  if [ -f "$file" ]; then
    echo "Moving $file to tools/validation/" | tee -a final_cleanup_log.txt
    mv "$file" tools/validation/
  fi
done

# 5. Move patch and utility files to scripts
echo "Moving patch and utility files..." | tee -a final_cleanup_log.txt
for file in fix_*.patch fix_*.py; do
  if [ -f "$file" ]; then
    echo "Moving $file to scripts/" | tee -a final_cleanup_log.txt
    mv "$file" scripts/
  fi
done

# 6. Move remaining .uid files
echo "Cleaning up .uid files..." | tee -a final_cleanup_log.txt
mkdir -p tmp/uid_files
for file in *.uid; do
  if [ -f "$file" ]; then
    echo "Moving $file to tmp/uid_files/" | tee -a final_cleanup_log.txt
    mv "$file" tmp/uid_files/
  fi
done

# 7. Move cleanup script to docs/automation
echo "Moving cleanup scripts..." | tee -a final_cleanup_log.txt
for file in cleanup_obsolete_files.sh organize_root.sh; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/automation/" | tee -a final_cleanup_log.txt
    mv "$file" docs/automation/
  fi
done

# 8. Move core development docs
echo "Moving core development docs..." | tee -a final_cleanup_log.txt
mkdir -p docs/core_development
for file in CORE_DEVELOPMENT_MODE.md; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/core_development/" | tee -a final_cleanup_log.txt
    mv "$file" docs/core_development/
  fi
done

# Move this script to docs/automation when done
echo "Root directory cleanup completed. See final_cleanup_log.txt for details." | tee -a final_cleanup_log.txt
echo "Moving final_cleanup.sh to docs/automation/" | tee -a final_cleanup_log.txt
mv final_cleanup_log.txt logs/
mv root_organize_log.txt logs/

