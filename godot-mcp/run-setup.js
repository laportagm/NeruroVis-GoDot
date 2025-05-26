const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

console.log('Godot MCP - Fixing Permissions and Running Setup');
console.log('==============================================\n');

const godotMcpPath = path.join(__dirname);

try {
  // First, make all scripts executable
  console.log('Step 1: Making all scripts executable...');
  const scripts = [
    'make-executable.sh',
    'setup.sh',
    'test.sh',
    'rebuild.sh',
    'rebuild-and-log.sh',
    'run-build-test.sh',
    'complete-rebuild.sh',
    'final-setup-verify.sh',
    'test-server.sh',
    'test-build.sh',
    'fix-and-setup.sh'
  ];
  
  scripts.forEach(script => {
    const scriptPath = path.join(godotMcpPath, script);
    if (fs.existsSync(scriptPath)) {
      execSync(`chmod +x "${scriptPath}"`, { cwd: godotMcpPath });
      console.log(`  ✅ ${script}`);
    }
  });
  
  console.log('\n✅ All scripts are now executable\n');
  
  // Run the final setup
  console.log('Step 2: Running final setup...');
  console.log('=============================\n');
  
  const setupOutput = execSync('./final-setup-verify.sh', {
    cwd: godotMcpPath,
    encoding: 'utf8',
    stdio: 'pipe'
  });
  
  console.log(setupOutput);
  
  console.log('\n✅ Setup completed successfully!');
  
} catch (error) {
  console.error('\n❌ Error during setup:');
  console.error(error.message);
  
  if (error.stdout) {
    console.log('\nStdout:', error.stdout.toString());
  }
  
  if (error.stderr) {
    console.error('\nStderr:', error.stderr.toString());
  }
  
  // Save error log
  const errorLog = `
Setup Error Log
===============
Time: ${new Date().toISOString()}

Error: ${error.message}

Stdout:
${error.stdout || 'None'}

Stderr:
${error.stderr || 'None'}

Working Directory: ${godotMcpPath}
  `.trim();
  
  fs.writeFileSync(path.join(godotMcpPath, 'setup-error.log'), errorLog);
  console.log('\nError log saved to: setup-error.log');
  process.exit(1);
}
