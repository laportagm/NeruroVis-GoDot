# NeuroVis Current Project State - Mon Jun  2 14:00:52 EDT 2025
## ALWAYS REFERENCE THIS FOR MAXIMUM CLAUDE EFFECTIVENESS

## 🎯 PROJECT OVERVIEW
- **Platform**: Educational neuroscience visualization for medical students
- **Architecture**: Modular Godot 4.4.1 with educational focus
- **Performance Targets**: 60fps, <500MB memory, <100 draw calls
- **Standards**: WCAG 2.1 AA accessibility + medical accuracy

## 📊 CURRENT CODEBASE ANALYSIS
### File Statistics:
- GDScript files: 279
- Scene files: 59
- Educational components: 0
- Total lines of code: 82195

## 🏗️ ARCHITECTURE OVERVIEW
### Directory Structure:
- .anima
- .claude
- .git
- .github
- .godot
- .vscode
- ai
- archive
- assets
- config
- docs
- src
- tests
- tools

### Core Components:

### UI Components:

## 📈 RECENT DEVELOPMENT
### Git History (Last 10 commits):
- 21c8619 fix: remove duplicate NeuroVisMainSceneCore class to resolve parser error
- 3f84662 refactor: complete architecture migration cleanup
- 5b1e7ee refactor: major architecture refactor and file reorganization
- 4f0bb69 fix: Remove duplicate BrainStructureSelectionManager class_name to resolve parser error
- ac05ec5 Merge remote-tracking branch 'origin/Branch-1-NeuroVis4' and resolve conflicts
- b6c21e4 refactor: project-wide reorganization and file consolidation
- 516636d fix(ui): resolve parser errors and memory access issues in GeminiSetupDialog
- 9fa8b08 feat(ui): comprehensive UI transformation and code quality improvements
- 39ff7c1 fix: Remove duplicate BrainStructureSelectionManager class_name to resolve conflict
- 5b5c3a2 fix(ai): Fix Gemini integration service references and type issues

## 🔧 ACTIVE FEATURES
### Educational Components:
- {{CLASS_NAME}}
- {{SCENE_NAME}}Controller
- AccessibilityManager
- ActionsComponent
- Advanced3DFeatures
- AdvancedInteractionSystem
- AIAssistantPanel
- AIAssistantService
- AnatomicalKnowledgeDatabase
- AppState
- AutoloadDebugTest
- AutoloadHelper
- BaseUIComponent
- BenchmarkRunner
- BrainAnalysisPanel
- BrainStructureInfoPanel
- BrainVisualization
- BrainVisualizationCore
- BrainVisualizer
- CameraBehaviorController
- CameraControllerUnitTest
- CameraControlPanel
- CameraControlsTest
- CameraSystem
- ComponentBase
- ComponentRegistry
- ComponentRegistryCompat
- ComponentStateManager
- ContentComponent
- CoreSystemsBootstrap
- CoreSystemsRegistry
- DebugButtonMasks
- DebugController
- DebugVisualizer
- DesignSystem
- EducationalCoordinator
- EducationalNotificationSystem
- EducationalTooltipManager
- EducationalTutor
- EducationalUI
- EducationalVisualFeedback
- EndToEndWorkflowTest
- EnhancedAIAssistant
- EnhancedInfoPanel
- EnhancedInformationPanel
- EnhancedLoadingOverlay
- EnhancedMainSceneStyling
- EnhancedModelControlPanel
- EnhancedModelControlPanelCore
- EnhancedStructureInfoPanel
- EnhancedStructureInfoPanelCore
- ErrorHandler
- ErrorNotification
- EventBus
- ExampleFrameworkTest
- GeminiAIService
- GeminiModelSelector
- GeminiSetupDialog
- GeminiSetupDialogEnhanced
- GodotDebugRunner
- GodotEngineDebugTest
- GodotErrorDetectionTest
- HeaderComponent
- InfoPanelComponent
- InfoPanelFactory
- InformationPanelController
- InputRouter
- InputRouterTest
- InputSystem
- InteractionHandler
- InteractiveTooltip
- KeyInputHandler
- KnowledgeBaseTest
- KnowledgeBaseUnitTest
- LearningPathManager
- LoadingOverlay
- LoadingStateManager
- LODManager
- MainScene
- MainSceneComponents
- MainSceneHybrid
- MainSceneRobust
- MainSceneSimple
- MaterialLibrary
- MedicalCameraController
- MedicalLighting
- MemoryManager
- MeshDiagnostic
- MinimalInfoPanel
- ModelControlPanel
- ModelLoader
- ModelRegistry
- ModelSwitcherSceneTest
- ModelSwitcherTest
- ModelSwitcherTestCore
- ModelSwitcherUnitTest
- ModelSystem
- ModelVisibilityManager
- ModernInfoDisplay
- ModularInfoPanel
- MultiStructureSelectionManager
- NameMappingTest
- NavigationItem
- NavigationPanel
- NavigationSection
- NavigationSidebar
- NavItem
- NeuroVisDarkTheme
- NeuroVisEnhancedScene
- NeuroVisMainEnhanced
- NeuroVisMainScene
- NeuroVisMainSceneCore
- OnboardingManager
- or node.is_class(class_name):
- PerformanceComparer
- PerformanceDebugger
- PerformanceMonitor
- PerformanceRegressionTest
- QuizSystem
- RefactoredMainSceneTest
- RenderingBenchmark
- RenderingOptimizer
- ResourceLoadingDebugTest
- ResourceManager
- ResponsiveComponent
- ResponsiveComponentSafe
- SafeUIComponentTest
- SceneLoadingDebugTest
- SectionComponent
- SelectionDebugVisualizer
- SelectionPerformanceValidator
- SelectionReliabilityTest
- SelectionSystem
- SelectionTestRunner
- SelectionVisualizer
- ServiceLocator
- SimplifiedComponentFactory
- StartupValidator
- StartupValidatorCodeQuality
- StateManager
- StructureInfoPanel
- StructureLabeler
- StructureSelectionTest
- StyleEngine
- SystemBootstrap
- SystemBootstrapTest
- TestFramework
- TestPlayer
- TestRunnerCLI
- ThemeToggle
- to avoid autoload conflicts - accessed via autoload name "ResourceDebugger"
- UIComponentFactory
- UIDiagnostic
- UIInfoPanelTest
- UIManager
- UISystem
- UnifiedStructureInfoPanel
- UpdatedInputHandlerFixed
- VisualDebugger
./src/ui/panels/UIDiagnostic.gd:	# Note: Using is operator might not work if MainScene is not a class_name
./tests/integration/RenderingValidationTest.gd:func _find_node_by_class(class_name: String) -> Node:

## ⚠️ KNOWN ISSUES TO WATCH
### Common NeuroVis Development Challenges:
- VBoxContainer configure() method calls - ensure ContentComponent has proper methods
- Type hint compliance - all functions must have parameter and return types
- Educational documentation - all components need learning objectives
- Performance optimization - maintain 60fps for 3D brain interactions
- Accessibility compliance - WCAG 2.1 AA for diverse learning needs

## 🎯 CURRENT DEVELOPMENT PRIORITIES
### Next Steps:
- Fix any ContentComponent configure() method issues
- Ensure all educational components have proper documentation
- Validate medical accuracy of anatomical content
- Optimize performance for educational interactions
- Test accessibility compliance for learning tools

## 📊 PERFORMANCE INDICATORS
### Code Quality Metrics:
- Classes with educational documentation: 0
- Functions with type hints: 3747
- Signal declarations: 518

## 🛡️ CLAUDE OPTIMIZATION NOTES
### For Maximum Effectiveness:
- Always reference this file for current project state
- Use enhanced standards enforcement (Ctrl+Shift+U)
- Include educational context in all development requests
- Validate medical accuracy for anatomical content
- Ensure accessibility compliance in UI changes
- Maintain performance budgets for educational platform
