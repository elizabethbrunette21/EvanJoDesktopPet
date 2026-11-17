const fs = require('node:fs');
const path = require('node:path');
const { randomUUID } = require('node:crypto');

function preferences(value) {
  const source = value && typeof value === 'object' && !Array.isArray(value) ? value : {};
  return {
    roaming: typeof source.roaming === 'boolean' ? source.roaming : true,
    paused: typeof source.paused === 'boolean' ? source.paused : false
  };
}

function readPreferences(file) {
  try { return preferences(JSON.parse(fs.readFileSync(file, 'utf8'))); }
  catch (error) {
    if (error.code === 'ENOENT' || error instanceof SyntaxError) return preferences();
    throw error;
  }
}

function writePreferences(file, value) {
  const temporary = `${file}.${randomUUID()}.tmp`;
  fs.mkdirSync(path.dirname(file), { recursive: true });
  try {
    fs.writeFileSync(temporary, JSON.stringify(preferences(value)) + '\n', { encoding: 'utf8', mode: 0o600, flag: 'wx' });
    fs.renameSync(temporary, file);
  } finally {
    fs.rmSync(temporary, { force: true });
  }
}

module.exports = { readPreferences, writePreferences };
