# GitHub Actions

## Workflows

`build-and-test.yml` runs on every pull request, pushes to `master` or `develop`, and manual requests. Independent macOS and iOS jobs run the shared TennoWatch scheme's Debug tests and build Release. Both use the `xcode-27` preview runner with Xcode 27.2; iOS uses the iPhone 18 Pro simulator on iOS 27.0. The runner currently supplies Xcode 27.2 as a release candidate; its build number may differ from the local release. Xcode 27.2 is required for the current SDK APIs and availability syntax, even though deployment targets remain iOS 26.5 and macOS 26. Test result bundles are retained for seven days. A newer commit cancels an obsolete run.

`swiftlint.yml` runs on the same events using the official SwiftLint 0.65.1 container, pinned by image digest, on Ubuntu. It uses `.swiftlint.yml` and GitHub annotations. Errors fail the job; warnings do not. The existing Xcode lint phase remains useful locally, but the dedicated job enforces linting even when SwiftLint is absent from a build runner.

`refresh-game-data.yml` runs every Monday at 07:17 UTC and can be started manually. It always checks out the repository's default branch, refreshes the mastery catalog from Digital Extremes PublicExport and the Prime release list from WFCD, validates both snapshots, and opens or updates a single PR from `maintenance/game-data-refresh`. Only these two resource files can enter that PR. It preserves the manually maintained non-item mastery sources and discards timestamp-only changes. It never merges the PR.

The refresh does not update `Scripts/input.json`, generated item-name mappings, or the bundled `solNodes.json` snapshot. Those remain separate manual updates.

## Repository setup

1. Enable GitHub Actions under **Settings → Actions → General**, with a policy allowing the actions referenced by these workflows. Action references use full commit SHAs.
2. Enable **Allow GitHub Actions to create and approve pull requests**. The refresh job requests `contents: write` and `pull-requests: write`; the other jobs have read-only repository access. No personal token, signing certificate, or API key is required.
3. Merge the workflows into the default branch (`master` at setup time). GitHub schedules run from the default branch, and the manual **Run workflow** button requires a workflow definition there. Merging only into `develop` does not activate the weekly schedule.
4. After the first runs, configure the desired branch rules to require `Build and test (macos)`, `Build and test (ios)`, and `SwiftLint` before merging.
5. When the refresh bot opens or updates a PR, select **Approve workflows to run** if GitHub requests approval, then review its data changes and merge after checks pass. The built-in `GITHUB_TOKEN` can require this approval for bot-created PR checks. Fully unattended checks would require a separately configured GitHub App token or personal token.

The refresh always uses the default branch's scripts and resources, including when manually started from another branch. A failed download or validation stops before opening a PR. No content change means no new refresh commit. Existing refresh PRs are updated rather than duplicated.

## Local validation

Run `bash Scripts/ci/build-and-test.sh macos` or `bash Scripts/ci/build-and-test.sh ios` with a compatible Xcode selected. Set `IOS_SIMULATOR_DESTINATION` if the default iOS simulator is unavailable. `DERIVED_DATA_PATH` and `TEST_RESULTS_PATH` can override the output locations. An existing test-result bundle must be moved or a fresh path selected before rerunning; the script does not delete prior results.

Run `swiftlint lint --no-cache --config .swiftlint.yml --reporter github-actions-logging` with SwiftLint 0.65.1.

Run `python3 Scripts/refresh_game_data.py --validate-only` to validate the checked-in snapshots without network access. For an actual refresh, first run `npm ci --ignore-scripts` in `Scripts/generate_catalog`, then run `python3 Scripts/refresh_game_data.py` from the repository root. The refresh requires Python 3.12+, Node.js 24, and network access. It stages downloads and generated output in a temporary directory and validates both snapshots before replacing bundled files.

## Updating tools

Update the pinned action commits and SwiftLint image digest deliberately. Update the runner, Xcode path, and simulator destination together when moving to another toolchain; do not rely on a changing `macos-latest` default. Local validation cannot verify GitHub permissions or the hosted runner environment; inspect the first GitHub run after pushing these workflows.

`.github/actionlint.yaml` adds GitHub's new hosted `xcode-27` label to the runner allowlist in older actionlint releases. This validator setting does not make the workflow self-hosted.
