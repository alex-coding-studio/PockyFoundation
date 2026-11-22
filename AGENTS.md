# PockyFoundation Contributor Instructions

Read ProjectContext.md and docs/PROJECT.md before changing the package.

- Keep one library product and target; add no package dependencies without an explicit decision.
- Keep public type identifiers prefixed with PKY and source identifiers in English.
- Do not write source comments (including DocC and implementation comments); only tool directives
  such as swift-tools-version are allowed. Express intent through names, types, tests, and
  package documentation.
- Prefer semantic roles, shared values, and pure geometry over views or theme systems.
- Import AppKit or UIKit only inside `#if os(macOS)` / `#if os(iOS)` blocks. Shared roles stay
  platform-neutral; each platform mapping sits beside them. Never import private packages.
- Keep role values shared across platforms; branch only for native API or coordinate differences.
- Preserve native floating-point geometry semantics except documented placement input guards.
- Use repository lint, test, and build entry points. Tests assert relationships for visual roles,
  not exact visual measurements. Pure mathematical placement examples may assert computed frames.
- Never commit personal emails, private paths, private links, tool-provider dependencies, caches,
  or symbolic links. Keep logs and result bundles in system temporary storage.
- Enable committed hooks with `git config core.hooksPath .githooks`.
- Deliver changes through work branches and pull requests; never commit directly to main.
- Do not change other repositories or publish releases as part of a package-only task.
