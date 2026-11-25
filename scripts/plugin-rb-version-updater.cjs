/** standard-version updater for Discourse plugin.rb `# version:` header. */
module.exports = {
  readVersion(contents) {
    const match = contents.match(/^# version:\s*(.+)$/m);
    if (!match) {
      throw new Error("Could not read `# version:` from plugin.rb");
    }
    return match[1].trim();
  },
  writeVersion(contents, version) {
    return contents.replace(/^# version:\s*.+$/m, `# version: ${version}`);
  },
};
