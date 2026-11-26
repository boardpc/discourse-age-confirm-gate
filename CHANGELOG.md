# Changelog

### 0.1.1 (2026-11-26)

### Features

- add age confirm gate site settings and en/pl locales ([f9b166a](https://github.com/boardpc/discourse-age-confirm-gate/commit/f9b166a0631dc41dd787ab34b570fa86d3ad2b77))
- add always-allow groups for NSFW age gate bypass ([8684777](https://github.com/boardpc/discourse-age-confirm-gate/commit/8684777cc6d33b567e8c7725c3156cfe0094b8c7))
- add composer, category, banner, and badge UI ([5c0987e](https://github.com/boardpc/discourse-age-confirm-gate/commit/5c0987e7cebb44c2240583fc818d46c0c8a0970c))
- add NSFW fields, user age confirmation, and access gating ([2c3b6b1](https://github.com/boardpc/discourse-age-confirm-gate/commit/2c3b6b192fa1e0e859d3c3e988a3c90c042bc427))
- localize plugin display name for en and pl_PL ([0e01e47](https://github.com/boardpc/discourse-age-confirm-gate/commit/0e01e478e70c6bbcf5f80fcbcd8d08fea510fd1b))

### Bug Fixes

- allow guests through the age gate when block_guests is off ([c6e85c6](https://github.com/boardpc/discourse-age-confirm-gate/commit/c6e85c6307756793d12eebd0e32682e339a0dd02))
- resolve trunk check formatting and lint issues ([7fc953d](https://github.com/boardpc/discourse-age-confirm-gate/commit/7fc953d3d5cf8e00827bce3076b2d30845f9ae62))
- unblock CI lint and age_gate_nsfw boolean casting ([0076f89](https://github.com/boardpc/discourse-age-confirm-gate/commit/0076f899b455cdd91924e839c057d0e7f233ef58))
- use pl_PL locales and prefill blocked message default ([87612fa](https://github.com/boardpc/discourse-age-confirm-gate/commit/87612faeab6a0e9adc67c98b8b8842b8710e9134))

### CI

- add Trunk Code Quality GitHub Actions workflow ([a979bea](https://github.com/boardpc/discourse-age-confirm-gate/commit/a979bea9d8d6e210435107d0a999012150e004aa))
- add Trunk setup-ci to install pnpm deps for prettier ([86bbca7](https://github.com/boardpc/discourse-age-confirm-gate/commit/86bbca76d21a5136d3cac182406811e2257f38be))
- drop Trunk post-annotations that break on push ([993f345](https://github.com/boardpc/discourse-age-confirm-gate/commit/993f3457fc882deced0cdd18a49dcebf1c6e3f29))
- fix Trunk markdownlint failure and check-mode warning ([b9618f1](https://github.com/boardpc/discourse-age-confirm-gate/commit/b9618f1138ca156467505a05bad20410fe2c3eac))
- install pnpm deps before Trunk prettier in CI ([1430452](https://github.com/boardpc/discourse-age-confirm-gate/commit/1430452ec257c9fcfe4c1cd26072440abfbd24cf))
