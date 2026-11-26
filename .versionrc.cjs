module.exports = {
  header: "# Changelog\n",
  releaseCommitMessageFormat: "chore: release {{currentTag}}",
  tagPrefix: "v",
  // Explicit: bump versions + changelog + commit + annotated tag (never tag-only)
  skip: {
    bump: false,
    changelog: false,
    commit: false,
    tag: false,
  },
  types: [
    { type: "feat", section: "Features" },
    { type: "fix", section: "Bug Fixes" },
    { type: "perf", section: "Performance" },
    { type: "refactor", section: "Refactors" },
    { type: "docs", section: "Documentation" },
    { type: "build", section: "Build" },
    { type: "ci", section: "CI" },
    { type: "chore", section: "Chores", hidden: true },
    { type: "test", section: "Tests", hidden: true },
    { type: "style", section: "Styles", hidden: true },
    { type: "revert", section: "Reverts" },
    { type: "bump", section: "Chores", hidden: true },
  ],
  packageFiles: [{ filename: "package.json", type: "json" }],
  bumpFiles: [
    { filename: "package.json", type: "json" },
    {
      filename: "plugin.rb",
      updater: "scripts/plugin-rb-version-updater.cjs",
    },
  ],
};
