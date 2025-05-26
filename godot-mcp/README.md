# Godot MCP Integration

This directory contains a unified Model Context Protocol (MCP) server that enables Claude and other AI assistants to interact with Godot projects.

## Features

- **Editor Control**: Launch Godot editor, run projects, capture debug output
- **Scene Management**: Create scenes, add nodes, modify properties
- **Script Operations**: Create, read, and update GDScript files with intelligent templates
- **Project Analysis**: List scenes/scripts, analyze project structure
- **No Plugin Required**: Uses Godot's CLI interface for maximum compatibility

## Quick Start

1. **Setup**:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. **Configure** (if needed):
   - Update Godot path in configuration files if not using default location
   - Default macOS path: `/Applications/Godot.app/Contents/MacOS/Godot`

3. **Use with Claude Desktop**:
   - Copy settings from `claude_desktop_config.json` to Claude's config file
   - Restart Claude Desktop

## Available Commands

### Editor Operations
- `launch_editor` - Open Godot editor
- `run_project` - Run project in debug mode
- `stop_project` - Stop running project
- `get_debug_output` - Get console output

### Scene Operations
- `create_scene` - Create new scene files
- `add_node` - Add nodes to scenes
- `list_scenes` - List all scene files

### Script Operations
- `create_script` - Create GDScript files
- `read_script` - Read script contents
- `update_script` - Update script contents
- `list_scripts` - List all script files

## Architecture

The integration uses a TypeScript MCP server that communicates with Godot through:
1. Command-line interface for editor control
2. Headless mode for scene/node operations
3. Direct file system access for script management

## Development

To modify the server:
1. Edit files in `cli-server/src/`
2. Run `npm run dev` for watch mode
3. Rebuild with `npm run build`

## Troubleshooting

- **Godot not found**: Set `GODOT_PATH` environment variable
- **Permission denied**: Run `chmod +x setup.sh`
- **Build errors**: Ensure Node.js 18+ is installed
