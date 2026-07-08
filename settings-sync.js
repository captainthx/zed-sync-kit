#!/usr/bin/env node

const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

function fail(message) {
  process.stderr.write(`${message}\n`);
  process.exit(1);
}

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function parseConfig(filePath) {
  if (!fs.existsSync(filePath)) {
    return null;
  }

  const text = fs.readFileSync(filePath, "utf8").trim();
  if (text === "") {
    return {};
  }

  let value;
  try {
    value = vm.runInNewContext(`(${text})`, Object.create(null), { timeout: 1000 });
  } catch (error) {
    fail(`Failed to parse ${filePath}: ${error.message}`);
  }

  if (!isPlainObject(value)) {
    fail(`Expected ${filePath} to contain a JSON object`);
  }

  return clone(value);
}

function writeJson(filePath, value) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function removeFileIfExists(filePath) {
  if (fs.existsSync(filePath)) {
    fs.unlinkSync(filePath);
  }
}

function deepMerge(target, source) {
  const output = isPlainObject(target) ? clone(target) : {};

  if (!isPlainObject(source)) {
    return output;
  }

  for (const [key, value] of Object.entries(source)) {
    if (isPlainObject(value) && isPlainObject(output[key])) {
      output[key] = deepMerge(output[key], value);
      continue;
    }

    output[key] = clone(value);
  }

  return output;
}

function isEmptyObject(value) {
  return isPlainObject(value) && Object.keys(value).length === 0;
}

function ensurePath(root, keys) {
  let current = root;
  for (const key of keys) {
    if (!isPlainObject(current[key])) {
      current[key] = {};
    }
    current = current[key];
  }
  return current;
}

function extractSecrets(settings) {
  const localOverride = {};
  const contextServers = settings.context_servers;

  if (!isPlainObject(contextServers)) {
    return localOverride;
  }

  for (const [serverName, serverConfig] of Object.entries(contextServers)) {
    if (!isPlainObject(serverConfig) || !isPlainObject(serverConfig.settings)) {
      continue;
    }

    for (const key of Object.keys(serverConfig.settings)) {
      if (!/(_key|_token|_secret)$/i.test(key)) {
        continue;
      }

      ensurePath(localOverride, ["context_servers", serverName, "settings"])[key] = serverConfig.settings[key];
      delete serverConfig.settings[key];
    }
  }

  return localOverride;
}

function exportSettings(settingsPath, localSettingsPath, repoSettingsPath) {
  const currentSettings = parseConfig(settingsPath);
  if (currentSettings === null) {
    fail(`Missing settings file: ${settingsPath}`);
  }

  const existingLocal = parseConfig(localSettingsPath) ?? {};
  const sanitizedSettings = clone(currentSettings);
  const extractedSecrets = extractSecrets(sanitizedSettings);
  const mergedLocal = deepMerge(existingLocal, extractedSecrets);
  const effectiveSettings = deepMerge(sanitizedSettings, mergedLocal);

  writeJson(repoSettingsPath, sanitizedSettings);
  writeJson(settingsPath, effectiveSettings);

  if (isEmptyObject(mergedLocal)) {
    removeFileIfExists(localSettingsPath);
  } else {
    writeJson(localSettingsPath, mergedLocal);
  }
}

function installSettings(repoSettingsPath, localSettingsPath, targetSettingsPath) {
  const baseSettings = parseConfig(repoSettingsPath) ?? {};
  const localSettings = parseConfig(localSettingsPath) ?? {};
  const effectiveSettings = deepMerge(baseSettings, localSettings);
  writeJson(targetSettingsPath, effectiveSettings);
}

const [command, ...args] = process.argv.slice(2);

switch (command) {
  case "export":
    if (args.length !== 3) {
      fail("Usage: settings-sync.js export SETTINGS LOCAL_SETTINGS REPO_SETTINGS");
    }
    exportSettings(args[0], args[1], args[2]);
    break;
  case "install":
    if (args.length !== 3) {
      fail("Usage: settings-sync.js install REPO_SETTINGS LOCAL_SETTINGS TARGET_SETTINGS");
    }
    installSettings(args[0], args[1], args[2]);
    break;
  default:
    fail("Usage: settings-sync.js <export|install> ...");
}
