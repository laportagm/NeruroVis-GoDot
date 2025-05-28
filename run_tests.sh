#!/bin/bash
# NeuroVis Test Suite Runner Script

echo "🧪 NeuroVis Test Suite Runner"
echo "=============================="
echo ""

# Set Godot path (update this to your Godot installation)
GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_PATH="/Users/gagelaporta/11A-NeuroVis copy3"

# Check if Godot exists
if [ ! -f "$GODOT_PATH" ]; then
    echo "❌ Error: Godot not found at $GODOT_PATH"
    echo "Please update GODOT_PATH in this script"
    exit 1
fi

# Function to run tests
run_tests() {
    echo "🚀 Running test suite: $1"
    echo "------------------------"
    
    # Run Godot in headless mode with test scene
    "$GODOT_PATH" --headless --path "$PROJECT_PATH" --script res://tests/$1
    
    # Check exit code
    if [ $? -eq 0 ]; then
        echo "✅ Test suite passed!"
    else
        echo "❌ Test suite failed!"
        return 1
    fi
}

# Function to run specific test file
run_specific_test() {
    echo "🎯 Running specific test: $1"
    "$GODOT_PATH" --headless --path "$PROJECT_PATH" --script "$1"
}

# Parse command line arguments
case "$1" in
    "all")
        echo "Running all tests..."
        run_tests "TestRunner.gd"
        ;;
    "core")
        echo "Running core system tests..."
        run_specific_test "res://tests/integration/test_brain_visualization_core.gd"
        ;;
    "ui")
        echo "Running UI component tests..."
        run_specific_test "res://tests/integration/test_ui_components.gd"
        ;;
    "ai")
        echo "Running AI assistant tests..."
        run_specific_test "res://tests/integration/test_ai_assistant.gd"
        ;;
    "pipeline")
        echo "Running full pipeline tests..."
        run_specific_test "res://tests/integration/test_full_pipeline.gd"
        ;;
    "watch")
        echo "Running tests in watch mode..."
        echo "Press Ctrl+C to stop"
        
        # Use fswatch on macOS or inotifywait on Linux
        if command -v fswatch &> /dev/null; then
            fswatch -o "$PROJECT_PATH/tests" "$PROJECT_PATH/ui" "$PROJECT_PATH/core" | while read; do
                clear
                run_tests "TestRunner.gd"
            done
        else
            echo "❌ fswatch not installed. Install with: brew install fswatch"
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [all|core|ui|ai|pipeline|watch]"
        echo ""
        echo "Options:"
        echo "  all      - Run all test suites"
        echo "  core     - Run core system tests only"
        echo "  ui       - Run UI component tests only"
        echo "  ai       - Run AI assistant tests only"
        echo "  pipeline - Run full pipeline tests only"
        echo "  watch    - Run tests in watch mode (auto-run on file changes)"
        echo ""
        echo "Example: $0 all"
        exit 1
        ;;
esac

# Generate test report
if [ "$1" != "watch" ]; then
    echo ""
    echo "📊 Generating test report..."
    
    # Create reports directory
    mkdir -p "$PROJECT_PATH/test_reports"
    
    # Copy test results
    if [ -f "$HOME/.local/share/godot/app_userdata/NeuroVis/test_results.json" ]; then
        cp "$HOME/.local/share/godot/app_userdata/NeuroVis/test_results.json" \
           "$PROJECT_PATH/test_reports/test_results_$(date +%Y%m%d_%H%M%S).json"
        echo "✅ Test report saved to test_reports/"
    fi
fi

echo ""
echo "🏁 Test run complete!"
