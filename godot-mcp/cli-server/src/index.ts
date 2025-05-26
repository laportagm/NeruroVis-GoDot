#!/usr/bin/env node
// Unified Godot MCP Server
// Combines features from ee0pdt/Godot-MCP and Coding-Solo/godot-mcp

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { 
  CallToolRequestSchema, 
  ListToolsRequestSchema,
  Tool 
} from '@modelcontextprotocol/sdk/types.js';
import { spawn, ChildProcess } from 'child_process';
import * as fs from 'fs/promises';
import * as path from 'path';
import { existsSync } from 'fs';
import { z } from 'zod';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

// ES module __dirname equivalent
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

class GodotMCPServer {
  private server: Server;
  private godotPath: string | null = null;
  private runningProcess: ChildProcess | null = null;
  private debugOutput: string[] = [];
  private projectPath: string | null = null;

  constructor() {
    this.server = new Server({
      name: 'godot-mcp',
      version: '1.0.0',
    }, {
      capabilities: {
        tools: {}
      }
    });
  }

  async initialize() {
    console.error('[Godot MCP] Initializing server...');
    
    // Find Godot executable
    this.godotPath = await this.findGodotPath();
    
    if (!this.godotPath) {
      console.error('[Godot MCP] Warning: Godot executable not found. Set GODOT_PATH environment variable.');
    }
    
    // Register handlers
    this.registerHandlers();
    
    // Set up transport
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    
    console.error('[Godot MCP] Server initialized successfully');
  }

  private async findGodotPath(): Promise<string | null> {
    // Check environment variable first
    if (process.env.GODOT_PATH) {
      return process.env.GODOT_PATH;
    }
    
    // Common paths to check
    const paths = [
      '/Applications/Godot.app/Contents/MacOS/Godot',
      '/usr/local/bin/godot',
      '/usr/bin/godot',
      'C:\\Program Files\\Godot\\Godot.exe',
      'C:\\Program Files (x86)\\Godot\\Godot.exe'
    ];
    
    for (const p of paths) {
      if (existsSync(p)) {
        return p;
      }
    }
    
    return null;
  }

  private registerHandlers() {
    // Register tool listing handler
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: this.getTools()
    }));

    // Register tool call handler
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      
      // Set project path if provided
      if (args && typeof args === 'object' && 'projectPath' in args) {
        this.projectPath = (args as any).projectPath;
      }
      
      try {
        const result = await this.callTool(name, args || {});
        return {
          content: [{
            type: 'text' as const,
            text: result
          }]
        };
      } catch (error: any) {
        return {
          content: [{
            type: 'text' as const,
            text: `Error: ${error.message}`
          }],
          isError: true
        };
      }
    });
  }

  private getTools(): Tool[] {
    return [
      // Editor Control
      {
        name: 'launch_editor',
        description: 'Launch Godot editor for a project',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { 
              type: 'string', 
              description: 'Path to the Godot project directory' 
            }
          },
          required: ['projectPath']
        }
      },
      {
        name: 'run_project',
        description: 'Run a Godot project in debug mode',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' },
            scene: { 
              type: 'string', 
              description: 'Optional: Specific scene to run' 
            }
          },
          required: ['projectPath']
        }
      },
      {
        name: 'stop_project',
        description: 'Stop the currently running project',
        inputSchema: {
          type: 'object',
          properties: {}
        }
      },
      {
        name: 'get_debug_output',
        description: 'Get captured debug output',
        inputSchema: {
          type: 'object',
          properties: {}
        }
      },
      
      // Project Management
      {
        name: 'get_project_info',
        description: 'Get information about a Godot project',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' }
          },
          required: ['projectPath']
        }
      },
      {
        name: 'list_scenes',
        description: 'List all scenes in a project',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' }
          },
          required: ['projectPath']
        }
      },
      {
        name: 'list_scripts',
        description: 'List all scripts in a project',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' }
          },
          required: ['projectPath']
        }
      },
      
      // Scene Operations
      {
        name: 'create_scene',
        description: 'Create a new scene file',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' },
            scenePath: { 
              type: 'string',
              description: 'Path relative to project root (e.g., "scenes/player.tscn")'
            },
            rootNodeType: { 
              type: 'string', 
              default: 'Node2D',
              description: 'Type of the root node (e.g., Node2D, Node3D)'
            }
          },
          required: ['projectPath', 'scenePath']
        }
      },
      {
        name: 'add_node',
        description: 'Add a node to an existing scene',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' },
            scenePath: { type: 'string' },
            nodeType: { 
              type: 'string',
              description: 'Type of node to add (e.g., Sprite2D, CollisionShape2D)'
            },
            nodeName: { 
              type: 'string',
              description: 'Name for the new node'
            },
            parentNodePath: { 
              type: 'string', 
              default: '.',
              description: 'Path to parent node (. for root)'
            },
            properties: { 
              type: 'object',
              description: 'Properties to set on the node'
            }
          },
          required: ['projectPath', 'scenePath', 'nodeType', 'nodeName']
        }
      },
      
      // Script Operations
      {
        name: 'create_script',
        description: 'Create a new GDScript file',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' },
            scriptPath: { 
              type: 'string',
              description: 'Path relative to project root (e.g., "scripts/player.gd")'
            },
            baseType: { 
              type: 'string',
              default: 'Node',
              description: 'Base class to extend (e.g., CharacterBody2D)'
            },
            content: {
              type: 'string',
              description: 'Optional: Full script content'
            }
          },
          required: ['projectPath', 'scriptPath']
        }
      },
      {
        name: 'read_script',
        description: 'Read a GDScript file',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' },
            scriptPath: { type: 'string' }
          },
          required: ['projectPath', 'scriptPath']
        }
      },
      {
        name: 'update_script',
        description: 'Update a GDScript file',
        inputSchema: {
          type: 'object',
          properties: {
            projectPath: { type: 'string' },
            scriptPath: { type: 'string' },
            content: { type: 'string' }
          },
          required: ['projectPath', 'scriptPath', 'content']
        }
      }
    ];
  }

  private async callTool(name: string, args: any): Promise<string> {
    // Use project path from args or saved path
    if (args.projectPath) {
      this.projectPath = args.projectPath;
    }
    
    switch (name) {
      case 'launch_editor':
        return await this.launchEditor(args);
      case 'run_project':
        return await this.runProject(args);
      case 'stop_project':
        return await this.stopProject();
      case 'get_debug_output':
        return await this.getDebugOutput();
      case 'get_project_info':
        return await this.getProjectInfo(args);
      case 'list_scenes':
        return await this.listScenes(args);
      case 'list_scripts':
        return await this.listScripts(args);
      case 'create_scene':
        return await this.createScene(args);
      case 'add_node':
        return await this.addNode(args);
      case 'create_script':
        return await this.createScript(args);
      case 'read_script':
        return await this.readScript(args);
      case 'update_script':
        return await this.updateScript(args);
      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  }

  // Tool implementations
  private async launchEditor(args: any): Promise<string> {
    if (!this.godotPath) {
      throw new Error('Godot executable not found');
    }
    
    const projectPath = path.resolve(args.projectPath);
    const godotArgs = ['--editor', '--path', projectPath];
    
    const process = spawn(this.godotPath, godotArgs, {
      detached: true,
      stdio: 'ignore'
    });
    
    process.unref();
    
    return `Launched Godot editor for project: ${projectPath}`;
  }

  private async runProject(args: any): Promise<string> {
    if (!this.godotPath) {
      throw new Error('Godot executable not found');
    }
    
    if (this.runningProcess) {
      this.runningProcess.kill();
    }
    
    const projectPath = path.resolve(args.projectPath);
    const godotArgs = ['--debug', '--path', projectPath];
    
    if (args.scene) {
      godotArgs.push(args.scene);
    }
    
    this.debugOutput = [];
    this.runningProcess = spawn(this.godotPath, godotArgs);
    
    this.runningProcess.stdout?.on('data', (data: Buffer) => {
      const output = data.toString();
      this.debugOutput.push(output);
      console.error('[Godot Output]', output);
    });
    
    this.runningProcess.stderr?.on('data', (data: Buffer) => {
      const output = `ERROR: ${data.toString()}`;
      this.debugOutput.push(output);
      console.error('[Godot Error]', output);
    });
    
    this.runningProcess.on('close', (code: number | null) => {
      this.debugOutput.push(`Process exited with code ${code}`);
      this.runningProcess = null;
    });
    
    return `Started project: ${projectPath}`;
  }

  private async stopProject(): Promise<string> {
    if (this.runningProcess) {
      this.runningProcess.kill();
      this.runningProcess = null;
      return 'Project stopped';
    }
    
    return 'No project is currently running';
  }

  private async getDebugOutput(): Promise<string> {
    return this.debugOutput.join('\n') || 'No debug output captured';
  }

  private async getProjectInfo(args: any): Promise<string> {
    const projectPath = path.resolve(args.projectPath);
    const projectFile = path.join(projectPath, 'project.godot');
    
    try {
      const content = await fs.readFile(projectFile, 'utf-8');
      const config = this.parseGodotConfig(content);
      
      return JSON.stringify({
        projectName: config.application?.config?.name || 'Unknown',
        mainScene: config.application?.run?.main_scene || 'None',
        renderer: config.rendering?.renderer?.rendering_method || 'unknown',
        features: config.application?.config?.features || []
      }, null, 2);
    } catch (error) {
      throw new Error(`Failed to read project file: ${error}`);
    }
  }

  private async listScenes(args: any): Promise<string> {
    const projectPath = path.resolve(args.projectPath);
    const scenes = await this.findFiles(projectPath, '.tscn');
    
    return scenes.join('\n') || 'No scenes found';
  }

  private async listScripts(args: any): Promise<string> {
    const projectPath = path.resolve(args.projectPath);
    const scripts = await this.findFiles(projectPath, '.gd');
    
    return scripts.join('\n') || 'No scripts found';
  }

  private async createScene(args: any): Promise<string> {
    if (!this.godotPath) {
      throw new Error('Godot executable not found');
    }
    
    const scriptPath = path.join(__dirname, '..', 'godot_operations.gd');
    const operation = {
      type: 'create_scene',
      scene_path: args.scenePath,
      root_node_type: args.rootNodeType || 'Node2D'
    };
    
    await this.executeGodotOperation(args.projectPath, operation);
    
    return `Created scene: ${args.scenePath} with root node type: ${args.rootNodeType || 'Node2D'}`;
  }

  private async addNode(args: any): Promise<string> {
    if (!this.godotPath) {
      throw new Error('Godot executable not found');
    }
    
    const operation = {
      type: 'add_node',
      scene_path: args.scenePath,
      node_type: args.nodeType,
      node_name: args.nodeName,
      parent_node_path: args.parentNodePath || '.',
      properties: args.properties || {}
    };
    
    await this.executeGodotOperation(args.projectPath, operation);
    
    return `Added ${args.nodeType} node "${args.nodeName}" to ${args.scenePath}`;
  }

  private async createScript(args: any): Promise<string> {
    const projectPath = path.resolve(args.projectPath);
    const scriptFullPath = path.join(projectPath, args.scriptPath);
    
    // Ensure directory exists
    await fs.mkdir(path.dirname(scriptFullPath), { recursive: true });
    
    let content = args.content;
    
    if (!content) {
      // Generate template based on base type
      const baseType = args.baseType || 'Node';
      content = this.generateScriptTemplate(baseType);
    }
    
    await fs.writeFile(scriptFullPath, content, 'utf-8');
    
    return `Created script: ${args.scriptPath}`;
  }

  private async readScript(args: any): Promise<string> {
    const projectPath = path.resolve(args.projectPath);
    const scriptFullPath = path.join(projectPath, args.scriptPath);
    
    try {
      const content = await fs.readFile(scriptFullPath, 'utf-8');
      return content;
    } catch (error) {
      throw new Error(`Failed to read script: ${error}`);
    }
  }

  private async updateScript(args: any): Promise<string> {
    const projectPath = path.resolve(args.projectPath);
    const scriptFullPath = path.join(projectPath, args.scriptPath);
    
    await fs.writeFile(scriptFullPath, args.content, 'utf-8');
    
    return `Updated script: ${args.scriptPath}`;
  }

  // Helper methods
  private async executeGodotOperation(projectPath: string, operation: any): Promise<void> {
    if (!this.godotPath) {
      throw new Error('Godot executable not found');
    }
    
    const operationsScript = path.join(__dirname, '..', 'godot_operations.gd');
    const args = [
      '--headless',
      '--script', operationsScript,
      '--path', projectPath,
      '--',
      JSON.stringify(operation)
    ];
    
    return new Promise((resolve, reject) => {
      const process = spawn(this.godotPath as string, args);
      let output = '';
      let error = '';
      
      process.stdout?.on('data', (data: Buffer) => {
        output += data.toString();
      });
      
      process.stderr?.on('data', (data: Buffer) => {
        error += data.toString();
      });
      
      process.on('close', (code: number | null) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error(`Operation failed: ${error || output}`));
        }
      });
    });
  }

  private parseGodotConfig(content: string): any {
    const config: any = {};
    let currentSection: string | null = null;
    
    content.split('\n').forEach(line => {
      const sectionMatch = line.match(/\[(.+)\]/);
      if (sectionMatch) {
        currentSection = sectionMatch[1];
        const parts = currentSection.split('/');
        let current = config;
        
        for (const part of parts) {
          if (!current[part]) {
            current[part] = {};
          }
          current = current[part];
        }
      } else if (currentSection && line.includes('=')) {
        const [key, value] = line.split('=').map(s => s.trim());
        const parts = currentSection.split('/');
        let current = config;
        
        for (const part of parts) {
          current = current[part];
        }
        
        current[key] = value.replace(/"/g, '');
      }
    });
    
    return config;
  }

  private async findFiles(dir: string, extension: string): Promise<string[]> {
    const files: string[] = [];
    
    async function scan(currentDir: string) {
      try {
        const entries = await fs.readdir(currentDir, { withFileTypes: true });
        
        for (const entry of entries) {
          const fullPath = path.join(currentDir, entry.name);
          
          if (entry.isDirectory() && !entry.name.startsWith('.')) {
            await scan(fullPath);
          } else if (entry.isFile() && entry.name.endsWith(extension)) {
            files.push(path.relative(dir, fullPath));
          }
        }
      } catch (error) {
        // Skip directories we can't read
      }
    }
    
    await scan(dir);
    return files;
  }

  private generateScriptTemplate(baseType: string): string {
    const templates: { [key: string]: string } = {
      'CharacterBody2D': `extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
\t# Add the gravity.
\tif not is_on_floor():
\t\tvelocity += get_gravity() * delta

\t# Handle jump.
\tif Input.is_action_just_pressed("ui_accept") and is_on_floor():
\t\tvelocity.y = JUMP_VELOCITY

\t# Get the input direction and handle the movement/deceleration.
\tvar direction := Input.get_axis("ui_left", "ui_right")
\tif direction:
\t\tvelocity.x = direction * SPEED
\telse:
\t\tvelocity.x = move_toward(velocity.x, 0, SPEED * delta)

\tmove_and_slide()
`,
      'CharacterBody3D': `extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta: float) -> void:
\t# Add the gravity.
\tif not is_on_floor():
\t\tvelocity += get_gravity() * delta

\t# Handle jump.
\tif Input.is_action_just_pressed("ui_accept") and is_on_floor():
\t\tvelocity.y = JUMP_VELOCITY

\t# Get the input direction and handle the movement/deceleration.
\tvar input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
\tvar direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
\tif direction:
\t\tvelocity.x = direction.x * SPEED
\t\tvelocity.z = direction.z * SPEED
\telse:
\t\tvelocity.x = move_toward(velocity.x, 0, SPEED * delta)
\t\tvelocity.z = move_toward(velocity.z, 0, SPEED * delta)

\tmove_and_slide()
`,
      'Area2D': `extends Area2D

func _ready() -> void:
\tbody_entered.connect(_on_body_entered)
\tbody_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
\tprint("Body entered: ", body.name)

func _on_body_exited(body: Node2D) -> void:
\tprint("Body exited: ", body.name)
`,
      'default': `extends ${baseType}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
\tpass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
\tpass
`
    };
    
    return templates[baseType] || templates['default'];
  }
}

// Start the server
async function main() {
  const server = new GodotMCPServer();
  await server.initialize();
}

main().catch(console.error);
