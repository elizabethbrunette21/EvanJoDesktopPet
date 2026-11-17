const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { build: { productName } } = require('../package.json');

function findPackagedApp(dist, platform = process.platform, arch = process.arch) {
  const candidates = platform === 'darwin'
    ? ['mac-universal', `mac-${arch}`, 'mac'].map(folder => path.join(dist, folder, `${productName}.app`, 'Contents', 'MacOS', productName))
    : platform === 'win32'
      ? ['win-unpacked', `win-${arch}-unpacked`].map(folder => path.join(dist, folder, `${productName}.exe`))
      : [];
  const binary = candidates.find(candidate => fs.existsSync(candidate));
  if (!binary) throw new Error(`No packaged app found for ${platform}/${arch}. Build first. Searched: ${candidates.join(', ') || dist}`);
  return binary;
}

function runPackagedSmoke(binary, args = ['--smoke-test'], timeoutMs = 30_000) {
  return new Promise((resolve, reject) => {
    const child = spawn(binary, args, { stdio: ['ignore', 'pipe', 'pipe'], windowsHide: true });
    let output = '', exited = false, done = false;
    const marker = 'Evan motion smoke passed:';
    const finish = error => {
      if (done) return;
      done = true;
      clearTimeout(timer);
      child.stdout.destroy(); child.stderr.destroy();
      if (error) reject(error); else resolve();
    };
    const timer = setTimeout(() => {
      child.kill();
      finish(new Error(`Packaged smoke timed out after ${timeoutMs}ms: ${binary}`));
    }, timeoutMs);
    child.stdout.on('data', data => {
      process.stdout.write(data);
      output = (output + data.toString()).slice(-16_384);
      if (exited && output.includes(marker)) finish();
    });
    child.stderr.on('data', data => process.stderr.write(data));
    child.on('error', finish);
    child.on('exit', (code, signal) => {
      if (code !== 0) return finish(new Error(`Packaged smoke exited with ${signal ? `signal ${signal}` : `code ${code}`}: ${binary}`));
      exited = true;
      // Electron helpers can keep inherited pipes open after the application has exited.
      if (output.includes(marker)) finish();
    });
    child.on('close', () => {
      if (!done) finish(new Error(`Packaged app did not report smoke success: ${binary}`));
    });
  });
}

if (require.main === module) {
  try {
    const binary = findPackagedApp(path.resolve(__dirname, '../dist'));
    console.log(`Checking packaged app: ${binary}`);
    runPackagedSmoke(binary).catch(error => { console.error(error.message); process.exitCode = 1; });
  } catch (error) { console.error(error.message); process.exitCode = 1; }
}
module.exports = { findPackagedApp, runPackagedSmoke };
