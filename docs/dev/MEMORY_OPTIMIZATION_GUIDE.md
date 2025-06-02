# NeuroVis Memory Optimization Guide

## Overview

The NeuroVis educational platform implements comprehensive memory management to ensure smooth performance on diverse hardware while maintaining high-quality medical visualizations. This guide covers memory optimization strategies, configuration, and best practices.

## Target Performance

- **Memory Budget**: <500MB total application memory
- **Target Usage**: 400MB operational memory
- **Frame Rate**: Consistent 60fps
- **Load Time**: <3 seconds to interactive state

## Memory Architecture

### Core Systems

1. **ResourceManager** (`core/resources/ResourceManager.gd`)
   - Centralized resource loading and caching
   - LRU cache eviction
   - Educational content prioritization
   - Async loading support

2. **MemoryManager** (`core/systems/MemoryManager.gd`)
   - Real-time memory monitoring
   - Automatic optimization levels
   - Emergency cleanup procedures
   - Performance coordination

3. **PerformanceMonitor** (`core/systems/PerformanceMonitor.gd`)
   - FPS and frame time tracking
   - Memory usage monitoring
   - Draw call optimization
   - Performance alerts

### Memory Budgets

```
Total Budget: 500MB
├── 3D Models: 150MB (30%)
├── Textures: 200MB (40%)
├── UI/Code: 100MB (20%)
└── Cache/Buffer: 50MB (10%)
```

## Configuration

### Memory Settings (`config/memory_settings.cfg`)

```ini
[memory_limits]
target_memory_mb = 400
critical_memory_mb = 450
texture_budget_mb = 200
model_budget_mb = 150
```

### Memory Presets (`config/presets/memory_presets.cfg`)

- **Student Laptop**: 350MB target, optimized for 8GB RAM systems
- **Classroom**: 400MB target, balanced quality/performance
- **Clinical**: 600MB target, maximum quality for workstations
- **Mobile**: 250MB target, aggressive optimization
- **VR**: 450MB target, optimized for headsets

## Optimization Levels

### 1. None (0-70% usage)
- Full quality settings
- All features enabled
- No active optimization

### 2. Mild (70-85% usage)
- Texture compression enabled
- Distant object quality reduction
- Old cache entries cleared

### 3. Moderate (85-95% usage)
- Shadow quality reduced
- Unused models unloaded
- Aggressive texture compression
- Shorter cache timeouts

### 4. Aggressive (95%+ usage)
- MSAA disabled
- Non-essential resources unloaded
- Immediate garbage collection
- Emergency cache clearing

## Best Practices

### 1. Resource Loading

```gdscript
# Good: Use ResourceManager for centralized loading
var model = ResourceManager.get_resource("res://assets/models/brain.glb")

# Good: Mark educational priority resources
ResourceManager.mark_as_educational_priority([
    "res://assets/models/Internal_Structures.glb",
    "res://assets/data/anatomical_data.json"
])

# Good: Async loading for non-critical resources
ResourceManager.load_resource_async(path, _on_resource_loaded)
```

### 2. Texture Management

```gdscript
# Good: Use appropriate texture sizes
const MAX_TEXTURE_SIZE = 2048

# Good: Enable compression for large textures
texture.compress_mode = Texture2D.COMPRESS_MODE_VRAM_COMPRESSED

# Good: Use mipmaps for 3D textures
texture.generate_mipmaps = true
```

### 3. Model Optimization

```gdscript
# Good: Implement LOD for complex models
var lod_manager = LODManager.new()
lod_manager.set_lod_distances([0, 50, 100, 200])

# Good: Unload models when not visible
func _on_visibility_changed():
    if not visible:
        ModelRegistry.unload_model(model_path)
```

### 4. Memory Monitoring

```gdscript
# Good: Monitor memory in development
func _ready():
    if OS.is_debug_build():
        MemoryManager.connect("memory_warning", _on_memory_warning)

# Good: Request optimization when needed
func _on_memory_warning(usage_mb, limit_mb):
    MemoryManager.request_memory_optimization()
```

## Educational Content Optimization

### Priority System

Educational content is prioritized to ensure critical learning materials remain available:

1. **Critical**: Currently displayed anatomical structures
2. **High**: Core educational models (brain hemispheres, major structures)
3. **Normal**: Supporting educational content
4. **Low**: Decorative or optional elements

### Preloading Strategy

```gdscript
# Preload essential educational content
func _ready():
    var essential_resources = [
        "res://assets/models/Half_Brain.glb",
        "res://assets/models/Internal_Structures.glb",
        "res://assets/data/anatomical_data.json"
    ]
    ResourceManager.preload_resources(essential_resources, "educational_core")
```

## Debug Commands

Access memory debugging via F1 console:

- `memory stats` - Display current memory usage
- `memory optimize` - Trigger manual optimization
- `memory clear_cache` - Clear resource cache
- `memory set_preset [name]` - Apply memory preset

## Performance Testing

### Memory Profiling

```bash
# Run memory profiler
godot --path . --script tools/scripts/MemoryProfiler.gd

# Monitor real-time usage
godot --path . --debug-collisions --debug-navigation
```

### Stress Testing

```gdscript
# Stress test memory system
func stress_test_memory():
    for i in range(100):
        var texture = load("res://assets/test_texture.png")
        await get_tree().create_timer(0.1).timeout
    
    print("Memory after stress: ", PerformanceMonitor.get_memory_usage())
```

## Platform-Specific Considerations

### macOS
- Metal renderer optimizations
- Unified memory architecture benefits
- Texture compression via ASTC

### Windows
- DirectX 12 memory management
- Dedicated VRAM tracking
- NVIDIA/AMD specific optimizations

### Linux
- Vulkan memory allocation
- System memory monitoring via /proc
- Mesa driver considerations

## Troubleshooting

### High Memory Usage

1. Check texture sizes:
   ```bash
   find assets -name "*.png" -exec identify {} \; | grep -E "[0-9]{4}x"
   ```

2. Verify model complexity:
   ```gdscript
   print("Model stats: ", mesh.get_surface_count(), " surfaces")
   ```

3. Monitor cache usage:
   ```gdscript
   ResourceManager.print_cache_statistics()
   ```

### Memory Leaks

1. Enable detailed tracking:
   ```gdscript
   OS.dump_memory_to_file("user://memory_dump.txt")
   ```

2. Use memory monitors:
   ```gdscript
   PerformanceMonitor.set_monitoring_enabled(true)
   ```

3. Check for circular references:
   ```gdscript
   # Ensure proper cleanup
   func _exit_tree():
       disconnect_all_signals()
       clear_references()
   ```

## Future Optimizations

1. **Texture Streaming**: Dynamic texture resolution based on distance
2. **Model Streaming**: Progressive mesh loading
3. **Memory Pools**: Pre-allocated memory for common operations
4. **GPU Memory Management**: Direct VRAM monitoring and optimization

## Conclusion

Effective memory management is crucial for delivering a smooth educational experience across diverse hardware. By following these guidelines and utilizing the provided systems, NeuroVis maintains excellent performance while preserving educational content quality.