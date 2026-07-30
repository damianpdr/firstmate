#!/usr/bin/env bash
# Behavior and tracked-registration tests for the native session-start nudge.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

unset NO_MISTAKES_GATE

TMP_ROOT=$(fm_test_tmproot fm-sessionstart-nudge)
NUDGE="$ROOT/bin/fm-sessionstart-nudge.sh"
# shellcheck source=/dev/null
. "$ROOT/bin/fm-operational-input.sh"
NUDGE_TEXT="Run \`bin/fm-session-start.sh\` now, exactly once, before executing any other instructions."
fm_operational_input_encode session-start "$NUDGE_TEXT" NUDGE_LINE \
  || fail "could not construct expected session-start nudge"
fm_git_identity fmtest fmtest@example.invalid

make_primary() {
  local dir=$1
  mkdir -p "$dir/bin" "$dir/state"
  git init -q "$dir"
  git -C "$dir" commit -q --allow-empty -m init
  : > "$dir/AGENTS.md"
}

run_nudge() {
  local root=$1
  FM_GATE_REFUSE_BYPASS=0 FM_ROOT_OVERRIDE="$root" FM_HOME="$root" "$NUDGE"
}

expect_silent_zero() {
  local label=$1
  shift
  local out status=0
  out=$("$@" 2>&1) || status=$?
  expect_code 0 "$status" "$label must exit 0"
  [ -z "$out" ] || fail "$label must be silent, got: $out"
}

test_genuine_primary_nudges() {
  local root="$TMP_ROOT/primary" out prefix_hex status=0
  make_primary "$root"
  out=$(run_nudge "$root") || status=$?
  expect_code 0 "$status" "genuine primary nudge"
  [ "$out" = "$NUDGE_LINE" ] || fail "genuine primary printed unexpected output: $out"
  prefix_hex=$(printf '%s' "$out" | head -c 3 | od -An -tx1 | tr -d ' \n')
  [ "$prefix_hex" = e281a3 ] || fail "genuine primary nudge lost its U+2063 operational marker: $prefix_hex"
  pass "fm-sessionstart-nudge: a genuine primary gets one explicitly marked instruction line"
}

test_gate_env_is_silent() {
  local root="$TMP_ROOT/gate-env"
  make_primary "$root"
  expect_silent_zero "gate env nudge" env NO_MISTAKES_GATE=1 FM_GATE_REFUSE_BYPASS=0 \
    FM_ROOT_OVERRIDE="$root" FM_HOME="$root" "$NUDGE"
  pass "fm-sessionstart-nudge: NO_MISTAKES_GATE is silent"
}

test_gate_common_dir_is_silent() {
  local source="$TMP_ROOT/gate-source" bare="$TMP_ROOT/.no-mistakes/repos/gate.git"
  local root="$TMP_ROOT/gate-worktree"
  fm_git_init_commit "$source"
  mkdir -p "$(dirname "$bare")"
  git clone --quiet --bare "$source" "$bare"
  git --git-dir="$bare" worktree add --quiet -b gate-test "$root" HEAD
  mkdir -p "$root/bin" "$root/state"
  : > "$root/AGENTS.md"
  printf 'gate-test\n' > "$root/.fm-secondmate-home"
  expect_silent_zero "gate common-dir nudge" env FM_GATE_REFUSE_BYPASS=0 \
    FM_ROOT_OVERRIDE="$root" FM_HOME="$root" "$NUDGE"
  pass "fm-sessionstart-nudge: .no-mistakes gate common-dir is silent"
}

test_unmarked_linked_worktree_is_silent() {
  local base="$TMP_ROOT/worktree-base" root="$TMP_ROOT/worktree-child"
  fm_git_worktree "$base" "$root" fm/sessionstart-linked
  mkdir -p "$root/bin" "$root/state"
  : > "$root/AGENTS.md"
  expect_silent_zero "linked worktree nudge" run_nudge "$root"
  pass "fm-sessionstart-nudge: an unmarked linked task worktree is silent"
}

test_linked_secondmate_primary_nudges() {
  local base="$TMP_ROOT/secondmate-base" root="$TMP_ROOT/secondmate-home" out status=0
  fm_git_worktree "$base" "$root" fm/sessionstart-secondmate
  mkdir -p "$root/bin" "$root/state"
  : > "$root/AGENTS.md"
  printf 'sessionstart-sm\n' > "$root/.fm-secondmate-home"
  out=$(run_nudge "$root") || status=$?
  expect_code 0 "$status" "linked secondmate nudge"
  [ "$out" = "$NUDGE_LINE" ] || fail "linked secondmate printed unexpected output: $out"
  pass "fm-sessionstart-nudge: a marked linked secondmate home is a primary"
}

test_missing_state_is_silent() {
  local root="$TMP_ROOT/missing-state"
  make_primary "$root"
  rmdir "$root/state"
  expect_silent_zero "missing state nudge" run_nudge "$root"
  pass "fm-sessionstart-nudge: a checkout without state is silent"
}

test_owned_lock_is_silent() {
  local root="$TMP_ROOT/already-ran"
  make_primary "$root"
  printf '%s\n' "$$" > "$root/state/.lock"
  expect_silent_zero "owned lock nudge" run_nudge "$root"
  pass "fm-sessionstart-nudge: a lock holder in process ancestry is already run"
}

test_opencode_plugin_delivers_exact_nudge_once() {
  local root="$TMP_ROOT/opencode-primary" out status=0
  make_primary "$root"
  cp "$ROOT/bin/fm-sessionstart-nudge.sh" "$ROOT/bin/fm-primary-scope-lib.sh" \
    "$ROOT/bin/fm-gate-refuse-lib.sh" "$ROOT/bin/fm-operational-input.sh" "$root/bin/"
  chmod +x "$root/bin/fm-sessionstart-nudge.sh"
  out=$(PLUGIN="$ROOT/.opencode/plugins/fm-primary-sessionstart-nudge.js" \
    WORKTREE="$root" EXPECTED="$NUDGE_LINE" node --input-type=module 2>&1 <<'EOF'
import { pathToFileURL } from "node:url";

const prompts = [];
const client = {
  session: {
    promptAsync: async (request) => {
      prompts.push(request.body.parts[0].text);
    },
  },
};
const mod = await import(pathToFileURL(process.env.PLUGIN).href);
const hooks = await mod.FmPrimarySessionstartNudge({
  client,
  directory: process.env.WORKTREE,
  worktree: process.env.WORKTREE,
});
const event = {
  type: "session.created",
  properties: { sessionID: "session-nudge-test", info: { id: "session-nudge-test" } },
};
await hooks.event({ event });
await hooks.event({ event });
if (prompts.length !== 1) throw new Error(`expected one prompt, got ${prompts.length}`);
if (prompts[0] !== process.env.EXPECTED) throw new Error(`unexpected prompt: ${prompts[0]}`);
EOF
  ) || status=$?
  expect_code 0 "$status" "OpenCode exact nudge delivery"
  [ -z "$out" ] || fail "OpenCode exact nudge delivery printed output: $out"
  pass "OpenCode session.created delivers the exact wrapper nudge once per session"
}

test_omp_session_start_delivers_exact_nudge() {
  local root home ext guardlog out status=0
  root="$TMP_ROOT/omp-primary"
  home="$TMP_ROOT/omp-home"
  ext="$root/.omp/extensions/fm-primary-turnend-guard.ts"
  guardlog="$root/guard-env.log"
  fm_git_init_commit "$root"
  mkdir -p "$root/.omp/extensions" "$root/bin"
  cp "$ROOT/.omp/extensions/fm-primary-turnend-guard.ts" "$ext"
  printf '# Firstmate\n' > "$root/AGENTS.md"
  cp "$ROOT/bin/fm-primary-scope-lib.sh" "$root/bin/fm-primary-scope-lib.sh"
  cat > "$root/bin/fm-sessionstart-nudge.sh" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "${EXPECTED:?}"
SH
  chmod +x "$root/bin/fm-sessionstart-nudge.sh"
  cat > "$root/bin/fm-turnend-guard.sh" <<'SH'
#!/usr/bin/env bash
printf '%s\t%s\n' "${OMPCODE:-}" "${CLAUDECODE:-}" > "${OMP_GUARD_ENV_LOG:?}"
SH
  chmod +x "$root/bin/fm-turnend-guard.sh"
  out=$(PLUGIN="$ext" FM_HOME="$home" EXPECTED="$NUDGE_LINE" OMP_GUARD_ENV_LOG="$guardlog" CLAUDECODE=1 node --input-type=module 2>&1 <<'EOF'
import { pathToFileURL } from "node:url";
import { existsSync, mkdirSync } from "node:fs";

const handlers = new Map();
const messages = [];
const pi = {
  on(event, handler) {
    handlers.set(event, handler);
  },
  sendMessage(message) {
    messages.push(message);
  },
};
const mod = await import(pathToFileURL(process.env.PLUGIN).href);
mod.default(pi);
const sessionStart = handlers.get("session_start");
if (!sessionStart) throw new Error("OMP session_start handler was not registered");
sessionStart({ type: "session_start" });
if (messages.length !== 1) throw new Error(`expected one OMP nudge, got ${messages.length}`);
const message = messages[0];
if (message.customType !== "firstmate-sessionstart-nudge") throw new Error(`unexpected custom type: ${message.customType}`);
if (message.content !== process.env.EXPECTED) throw new Error(`unexpected nudge: ${message.content}`);
if (message.display !== false) throw new Error("OMP nudge must remain hidden context");
const marker = `${process.env.FM_HOME}/state/.omp-turnend-extension-loaded`;
if (existsSync(marker)) throw new Error("OMP extension created state in an uninitialized primary");
mkdirSync(`${process.env.FM_HOME}/state`, { recursive: true });
sessionStart({ type: "session_start" });
if (!existsSync(marker)) throw new Error("OMP extension did not mark an initialized primary");
const sessionStop = handlers.get("session_stop");
if (!sessionStop) throw new Error("OMP session_stop handler was not registered");
await sessionStop({ type: "session_stop" });
EOF
  ) || status=$?
  expect_code 0 "$status" "OMP exact session_start nudge delivery"
  [ -z "$out" ] || fail "OMP exact session_start nudge delivery printed output: $out"
  assert_present "$home/state/.omp-turnend-extension-loaded" \
    "OMP primary extension must mark an initialized primary state directory"
  assert_grep 'sha256:' "$home/state/.omp-turnend-extension-loaded" \
    "OMP primary extension marker must record the extension version"
  [ "$(cat "$guardlog")" = $'1\t1' ] \
    || fail "OMP session_stop guard did not receive explicit OMP identity"
  pass "OMP native events deliver the startup nudge, preserve OMP guard identity, and remain inert without state"
}

test_omp_marker_is_inert_in_linked_task_worktree() {
  local project worktree ext out status=0
  project="$TMP_ROOT/omp-linked-project"
  worktree="$TMP_ROOT/omp-linked-worktree"
  fm_git_worktree "$project" "$worktree" "omp-linked-worktree"
  ext="$worktree/.omp/extensions/fm-primary-turnend-guard.ts"
  mkdir -p "$worktree/.omp/extensions" "$worktree/bin" "$worktree/state"
  printf '# Firstmate\n' > "$worktree/AGENTS.md"
  cp "$ROOT/.omp/extensions/fm-primary-turnend-guard.ts" "$ext"
  cp "$ROOT/bin/fm-primary-scope-lib.sh" "$worktree/bin/fm-primary-scope-lib.sh"

  out=$(PLUGIN="$ext" FM_HOME="$worktree" node --input-type=module 2>&1 <<'EOF'
import { pathToFileURL } from "node:url";
const pi = { on() {} };
const mod = await import(pathToFileURL(process.env.PLUGIN).href);
mod.default(pi);
EOF
  ) || status=$?
  expect_code 0 "$status" "OMP linked-task-worktree marker scope"
  [ -z "$out" ] || fail "OMP linked-task-worktree marker scope printed output: $out"
  assert_absent "$worktree/state/.omp-turnend-extension-loaded" \
    "OMP extension must not mark an unmarked linked task worktree with pre-existing state"
  pass "OMP extension marker remains inert in linked task worktrees with state"
}


test_genuine_primary_nudges
test_gate_env_is_silent
test_gate_common_dir_is_silent
test_unmarked_linked_worktree_is_silent
test_linked_secondmate_primary_nudges
test_missing_state_is_silent
test_owned_lock_is_silent
test_opencode_plugin_delivers_exact_nudge_once
test_omp_session_start_delivers_exact_nudge
test_omp_marker_is_inert_in_linked_task_worktree
