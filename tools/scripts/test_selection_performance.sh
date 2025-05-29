#!/bin/bash
# Test script for validating enhanced selection system performance

echo "🔬 Selection System Performance Test"
echo "===================================="

# Set project path
PROJECT_PATH="/Users/gagelaporta/11A-NeuroVis copy3"
cd "$PROJECT_PATH"

# Check if Godot is available
GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
if [ ! -f "$GODOT_PATH" ]; then
    echo "❌ Godot not found at expected location"
    exit 1
fi

echo "✅ Godot found: $GODOT_PATH"
echo ""

# Create performance test script
cat > test_selection_perf.gd << 'EOF'
extends SceneTree

func _initialize():
    print("\n🚀 Running Selection Performance Tests")
    print("=====================================")
    
    # Test 1: Check enhanced selection manager
    print("\n📍 Test 1: Enhanced Selection Manager")
    var manager_path = "res://core/interaction/BrainStructureSelectionManager.gd"
    if ResourceLoader.exists(manager_path):
        var script = load(manager_path)
        if script:
            print("✅ Enhanced selection manager loaded")
            
            # Check for multi-ray sampling
            var source = script.source_code
            if "MULTI_RAY_SAMPLES" in source:
                print("✅ Multi-ray sampling implemented")
            else:
                print("❌ Multi-ray sampling NOT found")
                
            if "get_adaptive_tolerance" in source:
                print("✅ Adaptive tolerance implemented")
            else:
                print("❌ Adaptive tolerance NOT found")
                
            if "_get_structure_screen_size" in source:
                print("✅ Structure size awareness implemented")
            else:
                print("❌ Structure size awareness NOT found")
        else:
            print("❌ Failed to load selection manager script")
    else:
        print("❌ Enhanced selection manager not found")
    
    # Test 2: Check performance validator
    print("\n📊 Test 2: Performance Validator")
    var perf_path = "res://tests/qa/SelectionPerformanceValidator.gd"
    if ResourceLoader.exists(perf_path):
        print("✅ Performance validator found")
        var script = load(perf_path)
        if script:
            var source = script.source_code
            if "TARGET_FPS: float = 60.0" in source:
                print("✅ 60 FPS target configured")
            if "MAX_SELECTION_TIME_MS: float = 16.67" in source:
                print("✅ Frame time budget configured")
    else:
        print("❌ Performance validator not found")
    
    # Test 3: Check test runner integration
    print("\n🧪 Test 3: Test Runner Integration")
    var runner_path = "res://tests/qa/SelectionTestRunner.gd"
    if ResourceLoader.exists(runner_path):
        print("✅ Selection test runner found")
        var script = load(runner_path)
        if script:
            var source = script.source_code
            if "qa_perf" in source:
                print("✅ Performance test command integrated")
            if "SelectionPerformanceValidator" in source:
                print("✅ Performance validator integrated")
    else:
        print("❌ Selection test runner not found")
    
    # Test 4: Check main scene integration
    print("\n🎮 Test 4: Main Scene Integration")
    var main_scene_path = "res://scenes/main/node_3d.gd"
    if ResourceLoader.exists(main_scene_path):
        var script = load(main_scene_path)
        if script:
            var source = script.source_code
            if "BrainStructureSelectionManager" in source:
                print("✅ Selection manager integrated in main scene")
            if "handle_selection_at_position" in source:
                print("✅ Selection handling implemented")
        else:
            print("❌ Failed to load main scene script")
    else:
        print("❌ Main scene script not found")
    
    print("\n✨ Performance Test Summary")
    print("==========================")
    print("Enhanced selection system validation complete.")
    print("Run 'qa_perf' in F1 console to measure actual performance.")
    print("")
    
    quit()
EOF

# Run the test
echo "🏃 Running performance validation..."
"$GODOT_PATH" --headless --script test_selection_perf.gd --path "$PROJECT_PATH" 2>&1 | grep -v "Vulkan"

# Clean up
rm -f test_selection_perf.gd

echo ""
echo "📋 Next Steps:"
echo "1. Launch NeuroVis with: godot --path \"$PROJECT_PATH\""
echo "2. Press F1 to open debug console"
echo "3. Run: qa_perf"
echo "4. Wait for 10-second performance test"
echo "5. Check results for 60 FPS target"