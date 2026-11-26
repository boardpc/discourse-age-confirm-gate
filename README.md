# discourse-age-confirm-gate

Age-gates NSFW **topics** and/or **categories** on Discourse. Users confirm a minimum age (no date of birth stored). Non-compliant viewers see a configurable banner or have topics hidden entirely. Staff always bypass the gate.

## Install

Add the plugin to your Discourse `containers/app.yml` (or equivalent) and rebuild:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/boardpc/discourse-age-confirm-gate.git
```

Enable **age_confirm_gate_enabled** in Admin → Settings.

## Effective NSFW rule

The gate applies when **either** the topic or its category is marked NSFW:

| Category NSFW | Topic NSFW | Gate?   |
| ------------- | ---------- | ------- |
| no            | no         | no      |
| yes           | no         | **yes** |
| no            | yes        | **yes** |
| yes           | yes        | **yes** |

Marking a category NSFW gates every topic in that category, even if individual topics are unmarked.

## Site settings

| Setting                                                 | Default                         | Description                                                                                                                          |
| ------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `age_confirm_gate_enabled`                              | `true`                          | Master enable switch                                                                                                                 |
| `age_confirm_gate_min_age`                              | `18`                            | Enum: `16` / `18` / `21`                                                                                                             |
| `age_confirm_gate_blocked_message`                      | English default message (`18+`) | Banner text; blank falls back to i18n. `locale_default` supplies PL when site default locale is `pl_PL`. Reset restores the default. |
| `age_confirm_gate_topic_visibility`                     | `show_with_banner`              | `show_with_banner` or `hide_entirely`                                                                                                |
| `age_confirm_gate_require_reconfirm_on_threshold_raise` | `true`                          | Require reconfirm when min age is raised                                                                                             |
| `age_confirm_gate_staff_verification_required`          | `false`                         | Only staff may set age status (self-confirm off)                                                                                     |
| `age_confirm_gate_always_allow_groups`                  | _(empty)_                       | Group members bypass age confirmation for NSFW content                                                                               |
| `age_confirm_gate_block_guests`                         | `true`                          | Block anonymous guests from NSFW content                                                                                             |
| `age_confirm_gate_guests_see_titles`                    | `false`                         | When guests are blocked, still list titles + show banner                                                                             |

## Always-allow groups

Members of groups listed in `age_confirm_gate_always_allow_groups` can access NSFW topics/categories **without** age confirmation (same bypass class as staff for the age check). Staff still always bypass regardless of this list.

## Staff verification mode

When `age_confirm_gate_staff_verification_required` is enabled:

- Signup and preferences self-confirm controls are hidden/disabled
- Mods/admins set `age_gate_confirmed_min_age` on the user admin page after verifying out-of-band
- This plugin does **not** implement a DM or ticket verification workflow

## Data model

- Topic custom field `age_gate_nsfw` (boolean) — settable by author on create; staff-only afterwards
- Category custom field `age_gate_nsfw` (boolean) — staff category settings
- User custom field `age_gate_confirmed_min_age` (integer or unset) — no DOB stored

## Locales

English (`en`) and Polish (`pl_PL`) client + server locales are included. Discourse’s Polish locale code is `pl_PL` (not `pl`), so plugin locale filenames and YAML root keys must match.

Plugin display name (admin plugins list, plugin settings page title, sidebar) is translated via:

- `admin_js.admin.site_settings.categories.discourse_age_confirm_gate`
- `js.discourse_age_confirm_gate.title`
- `js.discourse_age_confirm_gate.admin_navigation`

Setting **descriptions** are translated under `site_settings.*`. Individual setting **titles** (humanized keys like “Age confirm gate enabled”) are **not** localizable in Discourse by design; rely on the translated descriptions.

## Development

```bash
pnpm install
pnpm lint
bundle install
```

Discourse plugin CI runs via `.github/workflows/discourse-plugin.yml`. Trunk (`trunk_branch: develop`) + conventional commits via `.commitlintrc.yaml`.

### Conventional commits (Commitizen)

Interactive commits that match Trunk/commitlint conventional rules:

```bash
pnpm cz
# or
pnpm commit
```

### Release (version bump + git tag)

`pnpm release` uses `standard-version` and always does **all** of the following (not tag-only):

1. Bump `package.json` version
2. Bump `# version:` in `plugin.rb`
3. Update `CHANGELOG.md`
4. Create a release commit (`chore: release vX.Y.Z`)
5. Create an annotated git tag `vX.Y.Z`

```bash
# preview the bump/changelog/tag without writing anything
pnpm release:dry-run

# perform bump + commit + tag (e.g. v0.2.0)
pnpm release

# publish the release commit and tag
git push --follow-tags origin develop
```

SemVer is driven by conventional commit types (`feat` → minor, `fix` → patch, `BREAKING CHANGE` → major). Force a version with `pnpm release -- --release-as 0.2.0`. For the very first tag of the current version without bumping again: `pnpm release -- --first-release`.

## License

MIT
