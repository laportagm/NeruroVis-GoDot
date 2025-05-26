import { readFile, writeFile } from 'fs/promises';
import { exec } from 'child_process';
import { promisify } from 'util';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const execAsync = promisify(exec);
const __dirname = dirname(fileURLToPath(import.meta.url));

async function testBuild() {
  console.log('Testing Godot MCP Build...');
  console.log('=========================');
  
  const cliServerPath = join(__dirname, '..', 'cli-server');
  
  try {
    // Run TypeScript build
    console.log('Running TypeScript compilation...');
    const { stdout, stderr } = await execAsync('npm run build', {
      cwd: cliServerPath
    });
    
    console.log('Build output:', stdout);
    if (stderr) {
      console.error('Build errors:', stderr);
    }
    
    console.log('✅ Build completed successfully!');
  } catch (error: any) {
    console.error('❌ Build failed!');
    console.error('Error:', error.message);
    if (error.stdout) console.log('Stdout:', error.stdout);
    if (error.stderr) console.error('Stderr:', error.stderr);
    
    // Save error log
    const logPath = join(cliServerPath, 'build-error.log');
    await writeFile(logPath, `
Build Error Log
===============
Time: ${new Date().toISOString()}

Error Message:
${error.message}

Stdout:
${error.stdout || 'None'}

Stderr:
${error.stderr || 'None'}
    `.trim());
    
    console.log(`\nError log saved to: ${logPath}`);
  }
}

testBuild().catch(console.error);
