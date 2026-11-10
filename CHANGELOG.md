# git-pages-chart

<!-- towncrier release notes start -->

# git-pages-chart 1.2.0 (2026-11-02)

## Features

- Added `allow-expiration` config option to `limits` section in `gitPages.config` ConfigMap
- Updated `git-pages` to 0.10.1

## Bugfixes

- Removed blocking check if nixpkgs `git-pages` version is out of sync

## Misc

- (BREAKING) Renamed `caddy` to `proxy` in the `server` section in the `gitPages.config` ConfigMap


# git-pages-chart 1.1.0 (2026-10-05)

## Features

- Set the deployment strategy to `Recreate` by default.


# git-pages-chart 1.0.0 (2026-09-08)

## Features

- Initial release.
