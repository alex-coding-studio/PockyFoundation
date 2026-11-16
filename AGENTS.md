# PockyFoundation Contributor Instructions

Read ProjectContext.md and docs/PROJECT.md before changing the package.

- Keep one library product and target; add no dependencies without a Setup task.
- Keep public type identifiers prefixed with PKY and source identifiers in English.
- Write meaningful English DocC comments for public API; internal implementation has no comments.
- Prefer semantic roles, platform-specific values, and pure geometry over views or theme systems.
- Import AppKit or UIKit only inside `#if os(macOS)` / `#if os(iOS)` blocks. Shared roles stay
  platform-neutral; each platform mapping sits beside them. Never import private packages.
- Foundation code moved from Pocky keeps its public API and behaviour; translate its documentation
  to English and move its tests with it. Pocky's PockyComponents stays iOS-only.
- Keep platform values in conditional compilation; preserve iOS values and documented desktop roles.
- Preserve native floating-point geometry semantics except documented placement input guards.
- Use repository lint, test, and build entry points. Tests assert relationships for visual roles,
  not exact visual measurements. Pure mathematical placement examples may assert computed frames.
- Never commit personal emails, private paths, private links, tool-provider dependencies, caches,
  or symbolic links. Keep logs and result bundles in system temporary storage.
- Enable committed hooks with `git config core.hooksPath .githooks`.
- Later delivery uses work branches and ready pull requests with independent review where required.
  The initial local commit may exist on main; pushing it requires separate explicit authorization.
- Do not change other repositories or publish releases as part of a package-only task.
