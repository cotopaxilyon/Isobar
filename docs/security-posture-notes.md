# Isobar Security Posture — Deviations from Dolly Template Baseline

Template baseline: `instructions/agent-security-hardening.md` in the Dolly template repo, as of DEC-0019
(2026-04-22). This file records every point where Isobar's posture intentionally differs from that baseline, so
the reason is preserved across future template pulls.

## Deliberate deviations

### Mode-based layout vs persona-based

Isobar uses mode manifests (`autopilot`, `qa-check`), not persona manifests. The template is oriented around
Dolly's 14 personas. Concept is identical — declarative per-invocation scope — with different naming appropriate
to Isobar's single-dev PWA shape.

**Template equivalent:** §2c per-persona manifest format.
**Isobar form:** `.claude/mode-manifests/<mode>.txt` et al.

### `preToolUse-linear-output.sh` hook name

Isobar posts only to Linear. The hook name is specific; the template uses generic
`preToolUse-output-template.sh` because other forks may post to Jira/Slack. No functional difference.

**Template equivalent:** §5.6.

### Browser-navigate pin-to-localhost

Isobar's `preToolUse-browser-navigate.sh` hardcodes `http://127.0.0.1:8765/*` and `http://localhost:8765/*` as
the only allowed origins — not a configurable per-fork allowlist from `settings.json`. Justified because Isobar
is a local-first PWA with no staging URL.

**Template equivalent:** §5.4 allows per-fork configuration. Isobar's hardcoded approach is stricter and
engagement-appropriate; keep as-is.

### Threat model scoped to accidental misuse, not adversarial ingest

Isobar's hardening was tuned for accidental misuse amplified by ticket-body injection, not for adversarial
content as core workflow (which is Dolly's template framing). The three-bucket model applies equally, but the
Rule-of-Two audit for Isobar's two modes is trivial. Classification: `autopilot: 2/3 (untrusted + external)`,
`qa-check: 2/3 (untrusted + external)`. Neither crosses to 3/3 → no HITL gate required at the current surface.

**Template equivalent:** §4 Per-Persona Rule-of-Two Classification.

## Non-deviations (adopted from template)

- Universal hard-block deny list per template §2a — includes additions over Isobar's original posture: `sudo`,
  `chmod 777`, `chown`, `git filter-branch`, `git rebase -i`, `git config --global`, `aws configure`, `docker
  login`, `~/.gnupg/**`, `~/.config/gh/**`, `~/.netrc`, `~/.docker/config.json`, `**/.env*` at any depth.
- Advisory filename format `<date>-<mode>-<short>.md` per template §5.8.
- Trust-tier wrapper XML format per template §2d.
- Diff-scanner added-lines-only scope per template §5.3 (already in place).

## Maintenance

When pulling future template updates:
1. Resolve merge conflicts on `.claude/settings.json`, hook scripts, and
   `instructions/agent-security-hardening.md` by keeping Isobar's deliberate deviations (listed above) and
   accepting everything else.
2. Update this file if a new deviation is introduced, or if a previously-deliberate deviation is retired because
   the template caught up.
3. If Isobar innovates a pattern worth back-porting to the template, file a proposal in the Dolly template
   repo's `proposals/`.
