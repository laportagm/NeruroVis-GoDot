#\!/bin/bash

# Log file for organization operations
echo "Root directory organization log - $(date)" > root_organize_log.txt

# 1. Move fix summary files to docs/fix_summaries
echo "Moving fix summary files..." | tee -a root_organize_log.txt
for file in *_FIX_SUMMARY.md FIX_*.md DEBUG_FIX_SUMMARY.md PARSER_ERROR_FIX_SUMMARY.md; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/fix_summaries/" | tee -a root_organize_log.txt
    mv "$file" docs/fix_summaries/
  fi
done

# 2. Move implementation report files to docs/implementation_reports
echo "Moving implementation report files..." | tee -a root_organize_log.txt
for file in *_IMPLEMENTATION_SUMMARY.md *_SYSTEM.md *_COMPLETE.md; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/implementation_reports/" | tee -a root_organize_log.txt
    mv "$file" docs/implementation_reports/
  fi
done

# 3. Move guide files to docs/guides
echo "Moving guide files..." | tee -a root_organize_log.txt
for file in *_GUIDE.md VSCODE_ENHANCEMENT_README.md GODOT_MCP_INTEGRATION.md; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/guides/" | tee -a root_organize_log.txt
    mv "$file" docs/guides/
  fi
done

# 4. Move plan files to docs/plans
echo "Moving plan files..." | tee -a root_organize_log.txt
for file in *_PLAN.md PHASE_1_BASELINE_ANALYSIS.md; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/plans/" | tee -a root_organize_log.txt
    mv "$file" docs/plans/
  fi
done

# 5. Move automation scripts to docs/automation
echo "Moving automation scripts..." | tee -a root_organize_log.txt
for file in cleanup_script*.sh organize_files*.sh delete_original_files.sh; do
  if [ -f "$file" ]; then
    echo "Moving $file to docs/automation/" | tee -a root_organize_log.txt
    mv "$file" docs/automation/
  fi
done

# 6. Clean up old log files
echo "Cleaning up old log files..." | tee -a root_organize_log.txt
mkdir -p logs
for file in *.log; do
  if [ -f "$file" ] && [ "$file" \!= "root_organize_log.txt" ] && [ "$file" \!= "cleanup_log.txt" ]; then
    echo "Moving $file to logs/" | tee -a root_organize_log.txt
    mv "$file" logs/
  fi
done

# 7. Clean up test scene files in root
echo "Cleaning up test scene files..." | tee -a root_organize_log.txt
mkdir -p tests/scenes
for file in test_*.tscn; do
  if [ -f "$file" ]; then
    echo "Moving $file to tests/scenes/" | tee -a root_organize_log.txt
    mv "$file" tests/scenes/
  fi
done

# 8. Clean up remaining temp files
echo "Cleaning up remaining temporary files..." | tee -a root_organize_log.txt
rm -f files_to_delete.txt
mv cleanup_log.txt logs/
mv organize_log.txt logs/

echo "Root directory organization completed. See root_organize_log.txt for details." | tee -a root_organize_log.txt

