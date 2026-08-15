---
name: inyo-git-release
description: Use when grouping or creating Inyo commits, checking commit quality, preparing a SemVer release, creating an annotated Git tag, or pushing an explicitly approved Inyo branch and tag. Enforces project-specific staging, validation, CHANGELOG, and Git safety rules.
---

# Inyo Git Release

Use this skill for Git operations. Runtime, visual, documentation, CI, and compatibility facts remain owned by `AGENTS.md`, source, verifiers, and the relevant Inyo skills.

## Authorization boundary

- Inspect status, diffs, history, branches, remotes, and tags without mutation when reviewing or planning.
- Commit, tag, and push only when the user explicitly requests that operation in the current turn.
- Never discard or overwrite work, rewrite history, replace an existing tag, bypass hooks, or create a GitHub Release unless the user explicitly asks for that separate operation.
- Preserve unrelated user changes. Stage explicit paths; do not default to broad staging.

## Preflight

Run from the repository root before every mutation:

```shell
git status --short --untracked-files=all
git branch --show-current
git log --oneline --decorate -10
git tag --sort=-version:refname
git diff --check
```

Stop and report when the target branch, target version, intended files, or ownership of existing changes is unclear. Do not stage generated `public/`, `resources/`, lock files, fixture output, credentials, or environment files.

## Commit workflow

1. Group changes by one user-visible behavior or one maintenance concern: runtime behavior, tests, documentation, CI, repository hygiene, then release metadata.
2. Select a Conventional Commit type: `feat`, `fix`, `docs`, `design`, `style`, `chore`, `perf`, `refactor`, `test`, or `ci`.
3. Stage only the agreed files, then inspect:

```shell
git diff --cached --stat
git diff --cached --check
git diff --cached
```

4. Use an imperative subject of at most 72 characters. Keep a release-preparation commit separate from feature, fix, test, and documentation commits.
5. Run the checks proportionate to the change. Any runtime, configuration, routing, visual, CI, or release change uses the full release gate below.
6. Commit without bypassing repository hooks. If a hook fails, repair the cause and create a new commit rather than bypassing the check.

## Versioned release workflow

Use this workflow only when the user explicitly requests a release or version tag.

1. Confirm the target is a new SemVer tag in `vX.Y.Z` form and inspect the previous tag and release history.
2. Move verified `CHANGELOG.md` entries from `Unreleased` into the target version with the current date. Do not invent features or change `theme.toml`'s Hugo `min_version` as part of a theme version release.
3. Run the full release gate:

```shell
hugo --source exampleSite --minify --printPathWarnings
pwsh -File scripts/verify-theme.ps1
pwsh -File scripts/verify-consumer.ps1
pwsh -File scripts/verify-hugo-basic-example.ps1
git diff --check
```

4. Remove only verified build artifacts listed by `AGENTS.md`, then confirm the worktree contains only intended release files.
5. Create a dedicated release commit and annotated tag:

```shell
git commit -m "chore(release): prepare Inyo vX.Y.Z"
git tag -a vX.Y.Z -m "Release Inyo vX.Y.Z"
git show --no-patch --decorate vX.Y.Z
git status --short
```

6. Confirm the tag resolves to the release commit and the worktree is clean. Report the commit, tag object, checks run, and any non-blocking warnings.

## Push workflow

Push only after a separate explicit user instruction. Before pushing, report the remote, branch, commit, and exact tag that will be sent. Push the branch and matching tag together, then verify the remote state. Do not publish a GitHub Release unless explicitly requested.

## Failure routing

- Runtime, template, CSS, or configuration failure: use `inyo-theme-development`.
- Demo content or Front Matter failure: use `inyo-content-authoring`.
- README, CHANGELOG, Pages, consumer, or compatibility failure: use `inyo-theme-release`.
- Existing target tag, failed release gate, or unrelated dirty files: stop before creating the tag and state the blocking evidence.
