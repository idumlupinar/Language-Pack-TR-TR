# Releasing the tr-TR language pack

This guide is for maintainers. Contributors don't need it; see [CONTRIBUTING.md](CONTRIBUTING.md) instead.

- [Overview](#overview)
- [Before any release](#before-any-release)
- [Stable release](#stable-release-eg-1040)
- [Pre-release](#pre-release-eg-1040-rc3)
- [Verifying a draft](#verifying-a-draft)
- [If something goes wrong](#if-something-goes-wrong)
- [Notes](#notes)

## Overview

Each language pack release matches the DNN Platform release it is built for.

Form | Example | Used for
--- | --- | ---
Git tag ([SemVer](https://semver.org/)) | `v10.4.0`, `v10.4.0-rc3` | Tags and release pages
Release title | `10.4.0`, `10.4.0-rc3` | The list on the Releases page
Manifest version | `10.04.00` | `Resources/DNNCE_tr-TR.dnn`. This format has no room for a pre-release suffix, so `10.4.0-rc3` and `10.4.0` both use `10.04.00`

Branches:

- `develop` is the default branch. All contributions go there.
- `master` only receives stable releases.
- `release/X.Y.Z` and `release/X.Y.Z-rcN` are cut from `develop` for each release.

Workflows in `.github/workflows`:

Workflow | Runs on | What it does
--- | --- | ---
Validate | Pull requests; pushes to `develop`, `master`, `release/**` | `tools/Build-Manifest.ps1 -Check`: valid XML and an up-to-date manifest
Update Versions | Creating a `release/...` branch | Sets the manifest version from the branch name and commits it if it changed
Release | Push to `master` → stable; push of a `v*-*` tag → pre-release | Checks, packages the zip and its SHA-256 checksum, and creates a **draft** release on the commit that was built

Releases are always created as drafts, so a maintainer reviews them before anything is public.

## Before any release

1. **Check what changed in DNN Platform.** List the resource files that changed between the DNN Platform version of
   the previous language pack release and the new one, e.g. for 10.4.0-rc3 → 10.4.0:

   ```powershell
   $dnn = Join-Path $env:TEMP 'Dnn.Platform'
   if (Test-Path $dnn) { git -C $dnn fetch --tags --quiet }
   else { git clone --filter=blob:none --no-checkout --quiet https://github.com/dnnsoftware/Dnn.Platform.git $dnn }
   git -C $dnn diff --name-status v10.4.0-rc3 v10.4.0 -- '*.resx'
   ```

   The clone downloads history but no file contents, so it takes seconds. To see the changed strings in one file, run
   `git -C $dnn diff v10.4.0-rc3 v10.4.0 -- '<path>'`. Use git rather than GitHub's compare page or API: those list
   at most 300 changed files and can silently leave out `.resx` files when a release has many changes.

   No output means no resource changes, and the translations carry over as they are. Otherwise, translate the new or
   changed strings (the English `.resx` files, without a culture suffix) on a DNN Platform site of the new version, then
   run `tools/Sync-FromSite.ps1` and `tools/Build-Manifest.ps1` and merge the result into `develop` (see
   [CONTRIBUTING.md](CONTRIBUTING.md)) before cutting the release branch.

2. **Check new extensions.** If DNN Platform added an extension with its own resources, add it to `$PackageMap` in
   `tools/Build-Manifest.ps1`. Unmapped files go into the core pack.

3. **Write the release notes.** Add an entry at the top of `Resources/ReleaseNotes.txt` (HTML, in Turkish). It is
   shown in DNN Platform during installation. You can do this on the release branch.

## Stable release (e.g. 10.4.0)

1. Cut the release branch from an up-to-date `develop`, add the release notes and push:

   ```powershell
   git switch develop
   git pull --ff-only
   git switch -c release/10.4.0
   # edit Resources/ReleaseNotes.txt
   git commit -am "Release notes for 10.4.0"
   git push -u origin release/10.4.0
   ```

2. Wait for **Update Versions** and **Validate** to finish (`gh run list --branch release/10.4.0`). If Update Versions
   committed a new manifest version, run `git pull` before continuing.

3. Open the release pull request into `master` and wait for its checks:

   ```powershell
   gh pr create --base master --head release/10.4.0 --title "Release 10.4.0" --body "Language pack for DNN Platform v10.4.0."
   gh pr checks release/10.4.0 --watch
   ```

4. Merge by **fast-forwarding** `master` locally (see [Notes](#notes) for why). GitHub marks the pull request as
   merged, and the push starts the **Release** workflow:

   ```powershell
   git switch master
   git pull --ff-only
   git merge --ff-only release/10.4.0
   git push origin master
   ```

   If the fast-forward fails, `master` has commits that aren't on the release branch. Stop and find out why;
   `master` should only ever receive releases.

5. Bring `develop` up to date the same way:

   ```powershell
   git switch develop
   git merge --ff-only master
   git push origin develop
   ```

6. [Verify the draft](#verifying-a-draft), then publish it as the Latest release:

   ```powershell
   gh release edit v10.4.0 --draft=false --latest
   ```

## Pre-release (e.g. 10.4.0-rc3)

Pre-releases match a DNN Platform release candidate. They are built from the release branch and never go to `master`.

1. Cut `release/10.4.0-rc3` from `develop`, add the release notes and push, as in steps 1–2 of the stable release.

2. Create an annotated tag on the head of the release branch and push it. This starts the **Release** workflow:

   ```powershell
   git tag -a v10.4.0-rc3 -m "DNN Platform Language Pack tr-TR 10.4.0-rc3"
   git push origin v10.4.0-rc3
   ```

   The workflow fails if the tag doesn't match the manifest version (`v10.4.0-rc3` needs `10.04.00`).

3. Bring `develop` up to date if the release branch has commits it doesn't have (e.g. the release notes):

   ```powershell
   git switch develop
   git merge --ff-only release/10.4.0-rc3
   git push origin develop
   ```

4. [Verify the draft](#verifying-a-draft), then publish it. Pre-releases are never marked as Latest:

   ```powershell
   gh release edit v10.4.0-rc3 --draft=false
   ```

## Verifying a draft

Check the draft on the Releases page or with `gh release view v10.4.0`:

- Title is the version (`10.4.0`), the tag is `v10.4.0`, and the pre-release flag is set only for pre-releases.
- Two assets: `Dnn_Platform_Language-Pack-TR-TR_<version>.zip` and `.zip.sha256`.
- The notes link to the matching DNN Platform release.

Then download the assets and check them:

```powershell
gh release download v10.4.0 --dir release-check
cd release-check
Get-FileHash *.zip -Algorithm SHA256   # compare with the .sha256 file, or: sha256sum -c *.sha256
```

The zip must contain `DNNCE_tr-TR.dnn` with the expected manifest version, `license.txt`, `ReleaseNotes.txt` with the
new entry, and all `*.tr-TR.resx` files. For a final check, install it on a test site of the matching DNN Platform version.

## If something goes wrong

**The Release workflow failed.** Open the run (`gh run list --workflow release.yml`), fix the cause on the release
branch, then:

- Stable: merge the fix into `master` again (fast-forward); the push starts a new run.
- Pre-release: move the tag to the fixed commit. Only do this while the release is still a draft.

  ```powershell
  git tag -d v10.4.0-rc3
  git push origin :refs/tags/v10.4.0-rc3
  git tag -a v10.4.0-rc3 -m "DNN Platform Language Pack tr-TR 10.4.0-rc3"
  git push origin v10.4.0-rc3
  ```

**The draft is wrong.** Delete the draft and its tag, fix, and run the release again as above:

```powershell
gh release delete v10.4.0 --cleanup-tag --yes
```

**Wrong title or notes on a published release.** Edit them; the tag and the assets stay the same:

```powershell
gh release edit v10.4.0 --title "10.4.0"
```

**A published release has a real problem.** Don't move its tag or replace its assets; people may already have
downloaded it. Fix the problem on `develop` and ship it with the next release, and note the problem in the release
description in the meantime.

## Notes

- **Fast-forward instead of GitHub's merge button.** A merge, squash or rebase on GitHub creates a new commit with the
  email set for web-based commits on the merging account, which can be a private address. Fast-forwarding pushes the
  existing commits unchanged. If you prefer the merge button, first turn on *Keep my email addresses private* in your
  GitHub email settings.
- **Release branches** are kept after a release, as in the other DNN Platform language pack repositories. They can be
  deleted at any time; the tags keep the exact released commits.
- **Immutable releases** (*Settings → General → Releases*) lock the tag and assets once a release is published. It
  fits the rule above of never changing a published release.
