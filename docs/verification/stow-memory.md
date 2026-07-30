# Startup-memory `/stow` verification

Audience: maintainer verification.

This record supports the active bounded-memory and whole-file curation guarantees for Firstmate's internal `/stow` skill.
[`docs/configuration.md`](../configuration.md) owns the current operator-facing setting and estimate.
The internal skill owns curation and completion-receipt behavior.
Task chronology, fixture paths, and delivery evidence remain outside this record.

## Synthetic real-agent pass

The development-only real-agent pass ran on 2026-07-29 with Pi 0.82.0 on `openai-codex/gpt-5.6-terra` at medium thinking.
It used disposable primary and secondmate-shaped `FM_HOME` directories under the repository worktree only.
No live Firstmate memory, project data, credential content, or external system was placed in either fixture or prompt.
The following exact shell body created the sanitized fixtures, invoked the model-qualified skill twice per home, and captured reports and hashes:

```sh
set -eu
VERIFY_ROOT=$(mktemp -d "$PWD/.stow-verification.XXXXXX")
PRIMARY="$VERIFY_ROOT/primary"
SECONDMATE="$VERIFY_ROOT/secondmate"
mkdir -p "$PRIMARY/config" "$PRIMARY/data" "$SECONDMATE/config" "$SECONDMATE/data"
printf '%s\n' 350 >"$PRIMARY/config/startup-memory-budget"
printf '%s\n' 350 >"$SECONDMATE/config/startup-memory-budget"
touch "$SECONDMATE/.fm-secondmate-home"

cat >"$PRIMARY/data/captain.md" <<'EOF'
# Captain

## Current preferences

- Prefer the simplest direct end-to-end operational path.
- Preserve unique current facts when compacting memory.
- Use plain dashes in prose.

## Duplicate and superseded material

- Prefer the simplest direct end-to-end operational path.
- Old policy: build a wrapper before every one-off operation.
- Old policy copy: always build a wrapper for one-off work.
- Stale tool path: `/opt/old-firstmate/bin/fm`.
- Stale release version: 0.41.0.
- Completed task: migrated the demo fixture on Monday.
- Completed task detail: checked the demo fixture again on Tuesday.
- Metric from the completed task: 47 records moved.
EOF

cat >"$PRIMARY/data/captain-shared.md" <<'EOF'
# Shared captain memory

- The primary Firstmate owns shared memory; secondmates treat this file as read-only.
- Never expose secrets or weaken an accepted safety boundary.
- Prefer the simplest direct end-to-end operational path.
- Superseded policy: secondmates may rewrite shared memory when convenient.
- Duplicate safety note: do not expose secrets.
EOF

cat >"$PRIMARY/data/learnings.md" <<'EOF'
# Learnings

- Stable fact: startup-memory configuration is documented in `docs/configuration.md`.
- Authoritative pointer: incident detail belongs in `data/reports/synthetic-incident.md`.
- Stable fact copy: consult `docs/configuration.md` for startup-memory configuration.
- Completed chronology: first the synthetic incident was detected, then triaged, then assigned.
- Completed chronology continued: a patch was drafted, reviewed, merged, and announced.
- Old metric: the discarded prototype used 812 estimated tokens.
- Stale path: the discarded prototype lived at `/tmp/old-memory-prototype`.
- Superseded alternative: maintain both a JSON memory database and Markdown files.
- Report-sized procedure: create a staging directory, enumerate every file, copy each file, compare every line, write a status ledger, notify all operators, archive the ledger, and repeat the entire sequence after every prompt.
EOF

FM_HOME="$PRIMARY" bin/fm-startup-memory-budget.sh report \
  >"$VERIFY_ROOT/primary.before.report"
for file in captain.md captain-shared.md learnings.md; do
  shasum -a 256 "$PRIMARY/data/$file"
done >"$VERIFY_ROOT/primary.before.sha256"

FM_HOME="$PRIMARY" pi -p --no-session --no-extensions --no-context-files \
  --model openai-codex/gpt-5.6-terra --thinking medium \
  --skill .agents/skills/stow/SKILL.md \
  'Invoke /stow now against only the disposable synthetic Firstmate home in $FM_HOME. There are no new session facts to file. Follow every requirement in the loaded stow skill. Run the repository-owned bin/fm-startup-memory-budget.sh report command, with the existing FM_HOME environment, before and after curation; that executable is the only permitted path outside $FM_HOME. Retain the exact before total, and make the completion receipt state the effective budget, exact before and after totals, an action for each of the three files, every exception, and reset safety. Inspect all three startup-memory files completely, preserve every unique current preference, authority or safety boundary, stable fact, and authoritative pointer, and consolidate the supplied duplicate, superseded, stale, chronological, metric, and report-sized material. Do not access or modify any other home, credential, project data, or external system.' \
  >"$VERIFY_ROOT/primary.pass1.out"
FM_HOME="$PRIMARY" bin/fm-startup-memory-budget.sh report \
  >"$VERIFY_ROOT/primary.after.report"
for file in captain.md captain-shared.md learnings.md; do
  shasum -a 256 "$PRIMARY/data/$file"
done >"$VERIFY_ROOT/primary.after.sha256"

FM_HOME="$PRIMARY" pi -p --no-session --no-extensions --no-context-files \
  --model openai-codex/gpt-5.6-terra --thinking medium \
  --skill .agents/skills/stow/SKILL.md \
  'Invoke /stow now against only the disposable synthetic Firstmate home in $FM_HOME. There are no new session facts to file. Follow every requirement in the loaded stow skill. Run the repository-owned bin/fm-startup-memory-budget.sh report command, with the existing FM_HOME environment, before and after curation; that executable is the only permitted path outside $FM_HOME. Retain the exact before total, and make the completion receipt state the effective budget, exact before and after totals, an action for each of the three files, every exception, and reset safety. Inspect all three startup-memory files completely, preserve every unique current preference, authority or safety boundary, stable fact, and authoritative pointer, and consolidate the supplied duplicate, superseded, stale, chronological, metric, and report-sized material. Do not access or modify any other home, credential, project data, or external system.' \
  >"$VERIFY_ROOT/primary.pass2.out"
FM_HOME="$PRIMARY" bin/fm-startup-memory-budget.sh report \
  >"$VERIFY_ROOT/primary.repeat.report"
for file in captain.md captain-shared.md learnings.md; do
  shasum -a 256 "$PRIMARY/data/$file"
done >"$VERIFY_ROOT/primary.repeat.sha256"

cp "$PRIMARY/data/captain-shared.md" "$SECONDMATE/data/captain-shared.md"
cat >"$SECONDMATE/data/captain.md" <<'EOF'
# Secondmate captain memory

- Current preference: report concrete blockers instead of guessing.
- Current preference copy: never guess when a concrete blocker can be reported.
- Shared overlap: never expose secrets.
- Superseded preference: silently infer missing configuration.
- Stale version: the fleet uses 0.41.0.
- Completed task: inspected the synthetic queue yesterday.
- Completed task detail: closed the synthetic queue inspection after 19 checks.
EOF

cat >"$SECONDMATE/data/learnings.md" <<'EOF'
# Secondmate learnings

- Unique current learning: inherited shared memory counts against the local total.
- Authoritative pointer: startup-memory behavior is documented in `docs/configuration.md`.
- Duplicate learning: include inherited shared memory in the local total.
- Stale path: `/tmp/secondmate-memory-v1`.
- Superseded alternative: copy shared facts into every local file.
- Completed chronology: opened the sample, measured it, discussed it, revised it, remeasured it, and closed it.
- Old metric: the sample once measured 604 estimated tokens.
- Report-sized procedure: take a snapshot, copy it to a ledger, annotate every old measurement, preserve every discarded alternative, append a timestamp, and repeat after each completed task.
EOF

FM_HOME="$SECONDMATE" bin/fm-startup-memory-budget.sh report \
  >"$VERIFY_ROOT/secondmate.before.report"
for file in captain.md captain-shared.md learnings.md; do
  shasum -a 256 "$SECONDMATE/data/$file"
done >"$VERIFY_ROOT/secondmate.before.sha256"

FM_HOME="$SECONDMATE" pi -p --no-session --no-extensions --no-context-files \
  --model openai-codex/gpt-5.6-terra --thinking medium \
  --skill .agents/skills/stow/SKILL.md \
  'Invoke /stow now against only the disposable synthetic secondmate-shaped Firstmate home in $FM_HOME. There are no new session facts to file. Follow every requirement in the loaded stow skill. Run the repository-owned bin/fm-startup-memory-budget.sh report command, with the existing FM_HOME environment, before and after curation; that executable is the only permitted path outside $FM_HOME. Retain the exact before total, and make the completion receipt state the effective budget, exact before and after totals, an action for each of the three files, every exception, and reset safety. Inspect all three startup-memory files completely, keep data/captain-shared.md byte-identical because it is inherited and primary-owned, preserve every unique current preference, stable learning, and authoritative pointer, and consolidate the supplied duplicate, superseded, stale, chronological, metric, overlap, and report-sized material in editable local memory. Do not access or modify any other home, credential, project data, or external system.' \
  >"$VERIFY_ROOT/secondmate.pass1.out"
FM_HOME="$SECONDMATE" bin/fm-startup-memory-budget.sh report \
  >"$VERIFY_ROOT/secondmate.after.report"
for file in captain.md captain-shared.md learnings.md; do
  shasum -a 256 "$SECONDMATE/data/$file"
done >"$VERIFY_ROOT/secondmate.after.sha256"

FM_HOME="$SECONDMATE" pi -p --no-session --no-extensions --no-context-files \
  --model openai-codex/gpt-5.6-terra --thinking medium \
  --skill .agents/skills/stow/SKILL.md \
  'Invoke /stow now against only the disposable synthetic secondmate-shaped Firstmate home in $FM_HOME. There are no new session facts to file. Follow every requirement in the loaded stow skill. Run the repository-owned bin/fm-startup-memory-budget.sh report command, with the existing FM_HOME environment, before and after curation; that executable is the only permitted path outside $FM_HOME. Retain the exact before total, and make the completion receipt state the effective budget, exact before and after totals, an action for each of the three files, every exception, and reset safety. Inspect all three startup-memory files completely, keep data/captain-shared.md byte-identical because it is inherited and primary-owned, preserve every unique current preference, stable learning, and authoritative pointer, and consolidate the supplied duplicate, superseded, stale, chronological, metric, overlap, and report-sized material in editable local memory. Do not access or modify any other home, credential, project data, or external system.' \
  >"$VERIFY_ROOT/secondmate.pass2.out"
FM_HOME="$SECONDMATE" bin/fm-startup-memory-budget.sh report \
  >"$VERIFY_ROOT/secondmate.repeat.report"
for file in captain.md captain-shared.md learnings.md; do
  shasum -a 256 "$SECONDMATE/data/$file"
done >"$VERIFY_ROOT/secondmate.repeat.sha256"
```

Bounded observed output:

```text
primary: 641 -> 161 estimated tokens against a 350-token budget
primary repeat: 161 -> 161; all three files byte-identical
secondmate: 460 -> 129 estimated tokens against a 350-token budget
secondmate repeat: 129 -> 129; all three files byte-identical
secondmate shared before/after/repeat SHA-256:
64d9d07b0ee7b866b24470a67d863b6b722526798be15ee65122cd5819c5a80a
```

The first pass preserved current preferences, shared-memory and safety authority, a stable operating fact, and authoritative configuration and incident-report pointers while removing duplicate, superseded, stale, and chronological material.
The secondmate pass preserved its unique local preference and learning while leaving the inherited read-only shared file untouched.
This verifies the real instruction path consolidates to budget, reports truthful deltas, preserves the primary-owned shared boundary, and does not grow on an identical second pass.
