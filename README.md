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
| `node-build.yml` | `npm ci` / build / test, upload test results | `contents: read` (+ `id-token: write` if `run-codecov`) |
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
- `persist-credentials: false` on every checkout except `release.yml`, which needs the
  credentials to push tags and documents that exception inline.

Two syntax constraints that surprise people: a `uses:` job **cannot** set
`timeout-minutes`, `runs-on`, `env`, `services` or `steps` — each has to be an input. And
`workflow_run` cannot make a workflow reusable, which is why `test-report.yml`'s trigger
lives in the caller stub while the shared job lives here.

## Versioning: `@v1` is a moving tag

Consumers pin `@v1`. `v1` is moved only by `release.yml`, which is gated behind the
`release` environment's required reviewers.

This is deliberate, and it is *not* the same as `@main`:

- **`@main`** would make every merge here instant production CI across 16 repos —
  including `gradle-publish.yml`, which holds `packages: write`. No gate, no soak, no
  rollback but another merge.
- **`@<sha>` in consumers** would reintroduce exactly the 16-PR toil this replaces, and
  SHA-bump PRs show a diff of `@a1b2c3d → @e4f5g6h` with no visible content change. In
  practice they get rubber-stamped, so the protection is theatre. SHA pinning is the right
  control for third-party code you cannot govern; it is the wrong one for a repo you own
  and can put a ruleset on.

`@v1` is made safe by hardening *this repo* instead of freezing the ref: a branch ruleset
on `main` requiring PR + code-owner review + the `ci` check with no bypass actors, a `v*`
tag ruleset, and the reviewer-gated `release` environment. **Merging to `main` is not a
release.** Promoting a commit to the ref that 16 repos execute is a separate, deliberate,
audited act.

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

Actions → **Release** → Run workflow → `v1.3.0`. It validates the format, refuses to
overwrite an existing version tag, creates `v1.3.0`, and force-moves `v1` to the same
commit.

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
