# Contributing

Applies across the [labelzoom](https://github.com/labelzoom) organization. Individual
repos may add an `AGENTS.md` or their own `CONTRIBUTING.md`; **those override this file.**

## Getting a change in

1. **Branch off the repo's default branch.** It is `main` almost everywhere; the
   exceptions are `labelzoom-web-app-react` and `labelzoom-website`, which use `dev`.
   Resolve it rather than assuming:
   ```sh
   git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||'
   ```
2. **Keep the change scoped to one subproject** unless you are updating both sides of a
   shared contract (an API model touched by a producer and a consumer, say) — in which
   case update both in the same change set.
3. **Open a pull request.** Never push directly to a default branch.

## Conventions

- Commit subjects follow [Conventional Commits](https://www.conventionalcommits.org/):
  `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
- Java projects target **Java 21** and build with the committed Gradle wrapper
  (`./gradlew build`). Node projects use `npm ci`, never `npm install`.
- Some repos carry a proprietary license header (RJF Technology Solutions LLC). Preserve
  it on new source files there.

## CI

Most repos call the shared reusable workflows in this repo. If you are changing CI:

- **Product repos should only contain a caller stub** — triggers, `concurrency`,
  `permissions`, and a `uses:` line. Logic belongs in `labelzoom/.github`.
- A change to a reusable workflow affects **16 repos at once**. It needs a code-owner
  review and does not reach anyone until `v1` is moved by a gated release.

See [`README.md`](README.md) for the workflow contract.

## Security

Do not report vulnerabilities through issues or pull requests. See
[`SECURITY.md`](SECURITY.md).
