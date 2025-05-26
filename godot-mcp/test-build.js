const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

console.log('Testing Godot MCP Build...');
console.log('=========================\n');

const cliServerPath = path.join(__dirname, 'cli-server');

try {
  // Clear previous build
  const buildPath = path.join(cliServerPath, 'build');
  if (fs.existsSync(buildPath)) {
    fs.rmSync(buildPath, { recursive: true, force: true });
  }
  
  // Run build
  console.log('Running npm build...');
  const output = execSync('npm run build', {
    cwd: cliServerPath,
    encoding: 'utf8'
  });
  
  console.log('Build output:', output);
  console.log('\n✅ Build successful!');
  
  // Check if files were created
  const indexPath = path.join(buildPath, 'index.js');
  if (fs.existsSync(indexPath)) {
    console.log('✅ Output file created:', indexPath);
  } else {
    console.log('⚠️  Warning: index.js not found in build directory');
  }
  
} catch (error) {
  console.error('\n❌ Build failed!');
  console.error('Error:', error.message);
  
  if (error.stdout) {
    console.log('\nStdout:', error.stdout.toString());
  }
  
  if (error.stderr) {
    console.error('\nStderr:', error.stderr.toString());
  }
  
  // Save error log
  const errorLog = `
Build Error Log
===============
Time: ${new Date().toISOString()}

Error: ${error.message}

Stdout:
${error.stdout || 'None'}

Stderr:
${error.stderr || 'None'}

Status: ${error.status || 'Unknown'}
Signal: ${error.signal || 'None'}
  `.trim();
  
  fs.writeFileSync(path.join(cliServerPath, 'build-error.log'), errorLog);
  console.log('\nError log saved to: cli-server/build-error.log');
  process.exit(1);
}
