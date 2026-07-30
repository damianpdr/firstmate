# Startup-memory `/stow` verification

Audience: maintainer verification.

This record supports the active bounded-memory and whole-file curation guarantees for Firstmate's internal `/stow` skill.
[`docs/configuration.md`](../configuration.md) owns the current operator-facing setting and estimate.
The internal skill owns curation and completion-receipt behavior.
Task chronology, fixture paths, and delivery evidence remain outside this record.

## Synthetic real-agent pass

The development-only real-agent pass ran on 2026-07-30 with Pi 0.82.0 on `openai-codex/gpt-5.6-terra`.
It used disposable primary and secondmate-shaped `FM_HOME` directories only, with no live Firstmate home, project, credential, or external system accessed.
Each fixture contained duplicate statements, a superseded policy, stale version and path details, completed task chronology, a unique current preference and learning, shared-policy overlap, and existing authoritative pointers.

```sh
FM_HOME="$PRIMARY" pi -p --no-session --no-extensions \
  --skill .agents/skills/stow/SKILL.md "$PRIMARY_PROMPT"
FM_HOME="$PRIMARY" bin/fm-startup-memory-budget.sh report
FM_HOME="$PRIMARY" pi -p --no-session --no-extensions \
  --skill .agents/skills/stow/SKILL.md "$PRIMARY_REPEAT_PROMPT"
FM_HOME="$SECONDMATE" pi -p --no-session --no-extensions \
  --skill .agents/skills/stow/SKILL.md "$SECONDMATE_PROMPT"
FM_HOME="$SECONDMATE" bin/fm-startup-memory-budget.sh report
FM_HOME="$SECONDMATE" pi -p --no-session --no-extensions \
  --skill .agents/skills/stow/SKILL.md "$SECONDMATE_REPEAT_PROMPT"
shasum -a 256 "$SECONDMATE/data/captain-shared.md"
```

Bounded observed output:

```text
primary: 531 -> 207 estimated tokens against a 350-token budget
primary repeat: 207 -> 207; all three startup-memory files byte-identical
secondmate: 321 -> 229 estimated tokens against a 350-token budget
secondmate shared file: unchanged SHA-256 before, after, and after repeat
secondmate repeat: 229 -> 229; all startup-memory files byte-identical
```

The first pass preserved current preferences, merge and safety authority, a stable operating fact, and authoritative configuration and incident-report pointers while removing duplicate, superseded, stale, and chronological material.
The secondmate pass preserved its unique local preference and learning while leaving the inherited read-only shared file untouched.
This verifies the real instruction path consolidates to budget, reports truthful deltas, preserves the primary-owned shared boundary, and does not grow on an identical second pass.
