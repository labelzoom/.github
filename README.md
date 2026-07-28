# labelzoom/.github

Org-level GitHub configuration: the **reusable workflows** every LabelZoom repo's CI
calls, plus the community health files that inherit across the org.

This repo is **public**, and that is load-bearing, not an oversight. `labelzoom-api` and
`labelzoom-zpl-sdk` are public repos, and **a public repo cannot call a reusable workflow
from a private one.** No setting changes that. Nothing secret lives here: workflow YAML,
secret *names*, toolchain versions and action SHAs are all public by design. Secret
*values* never are.

## The doubled path

Reusable workflows must live in `.github/workflows/` of a repo named `.github`, so the
path genuinely repeats:

```yaml
uses: labelzoom/.github/.github/workflows/gradle-build.yml@v1
#              ^^^^^^^ repo   ^^^^^^^ directory
```

This trips up every reviewer once. It is not a typo.

## Available workflows

| Workflow | Purpose | Caller job needs |
|---|---|---|
| `gradle-build.yml` | Build + test a Java project, upload test results, Codecov | `contents: read`, `id-token: write` |
| `gradle-publish.yml` | Build + publish to GitHub Packages on `release: created` | `contents: read`, `packages: write` |
| `node-build.yml` | `npm ci` / build / test, upload test results | `contents: read`, `id-token: write` (**both always**) |
| `test-report.yml` | Publish a JUnit check run from an uploaded artifact | `contents: read`, `actions: read`, `checks: write` |

Inputs are documented inline in each file — read the `workflow_call.inputs` block, it is
the contract.

## Contract rules

- **Inputs are `kebab-case`; secret parameters are `UPPER_SNAKE_CASE`.**
- **Never `secrets: inherit`.** This repo is public; `inherit` would let it read *any*
  caller secret. Secrets are always named explicitly. Callers map their real secret names
  (`ACTION_ACTOR`/`ACTION_TOKEN`) onto the generic parameters (`PACKAGES_ACTOR`/
  `PACKAGES_TOKEN`) inside their own private stub.
- **`permissions` is authoritative on the caller job.** A called workflow can only ever
  *downgrade* what the caller granted, so the stub declares the real scopes and the
  reusable workflow mirrors them.
- **Third-party actions are pinned to a full commit SHA** with a `# vX.Y.Z` comment.
  `ci.yml` fails if that ever regresses.
- `persist-credentials: false` on every checkout, with no exceptions.

Two syntax constraints that surprise people: a `uses:` job **cannot** set
`timeout-minutes`, `runs-on`, `env`, `services` or `steps` — each has to be an input. And
`workflow_run` cannot make a workflow reusable, which is why `test-report.yml`'s trigger
lives in the caller stub while the shared job lives here.

## Versioning: `@v1` is a moving tag

Consumers pin `@v1`. `v1` is moved only by [`script/cut-release.sh`](script/cut-release.sh),
run locally by a member of `@labelzoom/labelzoom`.

This is deliberate, and it is *not* the same as `@main`:

- **`@main`** would make every merge here instant production CI across 16 repos —
  including `gradle-publish.yml`, which holds `packages: write`. No gate, no soak, no
  rollback but another merge.
- **`@<sha>` in consumers** would reintroduce exactly the 16-PR toil this replaces, and
  SHA-bump PRs show a diff of `@a1b2c3d → @e4f5g6h` with no visible content change. In
  practice they get rubber-stamped, so the protection is theatre. SHA pinning is the right
  control for third-party code you cannot govern; it is the wrong one for a repo you own
  and can put a ruleset on.

`@v1` is made safe by hardening *this repo* instead of freezing the ref:

- **`main` requires a PR** with code-owner review and a passing `ci` check, and the org
  ruleset has an empty bypass list — nobody pushes to `main`, org owner included.
- **A `v*` tag ruleset restricts creation, update and deletion** to
  `@labelzoom/labelzoom`. Accounts with plain write access — notably automation and agent
  accounts — cannot create or move a version tag at all.

**Merging to `main` is not a release.** Promoting a commit to the ref that 16 repos
execute is a separate, deliberate act performed by a human at a terminal.

Consumers must tell Dependabot to leave the moving tag alone, or it will "helpfully" pin
`@v1` to `@v1.3.0`:

```yaml
    ignore:
      - dependency-name: "labelzoom/.github/*"
```

**Breaking-change path:** additive inputs ship in `v1.x`. A renamed input, a changed
default, or a new required secret means cutting `v2` and migrating consumers repo by repo.
`v1` and `v2` coexist indefinitely.

## Cutting a release

```sh
git switch main && git pull
./script/cut-release.sh v1.3.0
```

It refuses to run unless you are on a clean `main` level with `origin/main`, validates the
tag format, refuses to overwrite an existing version tag, prompts for confirmation, then
creates `v1.3.0` and force-moves `v1` onto the same commit.

**Why this is a script and not a workflow.** The `v*` tag ruleset restricts creation and
update, and GitHub Actions cannot be granted a bypass — the API rejects it outright:

> Actor GitHub Actions integration must be part of the ruleset source or owner organization

Actions is built into the platform rather than installed as an org integration, so it can
never satisfy that. Only a *custom* org-owned GitHub App could bypass, and that means
storing a private key in order to automate two `git` commands. That trade isn't worth it,
so the release stays manual and the ruleset stays strict.

## What inherits org-wide, and what does not

| File | Inherits? |
|---|---|
| `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `SUPPORT.md`, `GOVERNANCE.md`, `FUNDING.yml` | **Yes** |
| `.github/PULL_REQUEST_TEMPLATE.md`, `.github/ISSUE_TEMPLATE/*` | **Yes** |
| `profile/README.md` | **Yes** — renders the org overview page |
| `workflow-templates/*` | **Yes** — appears in every repo's "New workflow" chooser |
| `.github/workflows/*.yml` | **No.** Not auto-run anywhere; callable via `uses:` only |
| `.github/dependabot.yml` | **No.** Each repo keeps its own |
| `CODEOWNERS` | **No.** Each repo keeps its own |
| `LICENSE` | **No** — explicitly unsupported by GitHub |

## Caller permissions are not inherited — declare them

A called workflow's job permissions must be **equal to or more restrictive** than the
caller job's. Two consequences, both verified the hard way:

- **Grant at least what the reusable workflow declares.** Granting less is not a warning
  or a downgrade — the run dies with `startup_failure` before any job begins, and the
  Actions UI says only "This run likely failed because of a workflow file issue."
- **Omitting `permissions:` in the reusable workflow does not inherit the caller's.**
  The job falls back to `Metadata: read`, and even `actions/checkout` fails with
  `Repository not found` on a private repo.

So the tables above are minimums *and* requirements. `node-build.yml` needs
`id-token: write` from every caller even when `run-codecov` is false, because a static
permissions block cannot vary with an input.
