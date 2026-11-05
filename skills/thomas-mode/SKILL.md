---
name: thomas-mode
description: "Works in ThomasK33's style on top of pstack's poteto-mode in the Xum agent harness: Xum names for pstack tools, his shipping and review rules, and his amendments to pstack and egm playbook steps. Use for /thomas-mode, \"thomas mode\", or an explicit request to work in his style. Also read its Amendments to plugin steps before any pstack or egm step that runs without it, including runs started with \"Using skill poteto-mode\" and /reflect."
---

# Thomas mode

Paths are relative to this skill's directory (`skillDir` in the `agent_skill_read` result).

When you load this skill only for its Amendments (a pstack or egm step that runs without `/thomas-mode`), skip steps 1 and 3 below. Still run step 2. Before an egm step, load `egm-in-xum` as step 1 says. Then apply only the "Amendments to plugin steps" rules for the steps you run.

1. Load the `pstack-in-xum` skill from the `fux-plugins` plugin. It maps pstack's Cursor names to Xum. Before you follow an egm skill, also load `egm-in-xum` from `fux-plugins`. It maps egm's harness steps to Xum. When `scripts/check-drift.sh` reports a change to pstack's `docs/harness/claude-code.md`, check whether `pstack-in-xum` needs a new row. When it reports a change to egm's `docs/harnesses.md`, `docs/claude.md` or `docs/codex.md`, check `egm-in-xum` the same way.
2. Run `scripts/check-drift.sh` and keep its report. The report does not survive a context rollover, so run the script again after one, from the checkpoint's resume list (see Precedence). On exit 1, act on a reported file only when the task reaches it. A full `/thomas-mode` run reaches `docs/harness/claude-code.md` (step 1) and `skills/poteto-mode/SKILL.md` (step 3) at the start. A task that runs an egm skill reaches egm's `docs/harnesses.md`, `docs/claude.md` and `docs/codex.md` when it loads `egm-in-xum`. It reaches any other file when it enters a step in that file, such as a playbook that poteto-mode routes to. Do not read or mention drift in a file the task never reaches. (A chat that never used `egm-draft` still listed its drift as a thing to know.) A skill edit reviews it per "Changing this skill". Do not stop. On exit 2, report the error and continue without the check. Handle each report line this way:
   - `CHANGED`: read the diff for that file only (`--diff=<path>`, redirected to a file). Before you follow an amended step, tell the user what changed in it. `skills/poteto-mode/SKILL.md` and `skills/setup-pstack/SKILL.md` have no amended step: follow the installed file, and tell the user only when the change conflicts with a rule here. For a watched docs file (pstack `docs/harness/claude-code.md`, egm `docs/harnesses.md`, `docs/claude.md` or `docs/codex.md`), run step 1's mapping check. Tell the user only when `pstack-in-xum` or `egm-in-xum` needs a new row.
   - `ADDED`: read the whole file. Before you follow an amended step in it, tell the user what it says, the same as for `CHANGED`. For a watched docs file, run step 1's mapping check, as for `CHANGED`.
   - `ANCHOR`: the plugin dropped or renamed a step that this skill names. Treat a rule anchored there as stale per the Amendments intro. An `ANCHOR` on a `MISSING` file is not stale on its own: handle it as `MISSING`.
   - `MISSING`: the installed plugin lacks a file that this skill names. Report it as a setup error, as on exit 2. Do not treat a rule as stale on `MISSING` alone.
   - `NOPIN`: it names a plugin, not a file. Report it as a setup error, as on exit 2, whatever the task reaches.
3. Load `pstack:poteto-mode` with `agent_skill_read` and follow it, with the rules below.

Precedence: `~/.xum/AGENTS.md`, then his memory (`/memories/global/user-workflow-preferences.md`, read it with the `memory` tool at task start and after every context rollover), then this skill, then poteto-mode and its playbooks. This skill does not repeat AGENTS.md or memory. A new context window reads only its checkpoint, so the checkpoint's first line is a resume list: `agent_skill_read` thomas-mode, `agent_skill_read` poteto-mode plus `agent_skill_read_file` for the playbook in use, `memory view /memories/global/user-workflow-preferences.md`, and `scripts/check-drift.sh`. Run it first in every new window. (After two rollovers, a root read only its checkpoint and dropped its per-round duties.)

## Where poteto-mode yields

- **PRs.** "Land", "get it merged", "ship it", or his ship prompt is the request to open a PR and merge it. "Fix" alone is not. Then poteto-mode's "Opening a PR" runs.
- **Review rounds.** AGENTS.md section 5 caps review at six rounds per PR. It replaces any round count in a playbook. Its section 5.3 clean-context advisor runs before each merge decision, at any round count. A verifier does not replace it.
- **Subagents.** Before every `task`, look up the role's row in the `~/.xum/AGENTS.md` "pstack models" table and pass its model and thinking level. Autopilot roles use these rows: an owner uses "feature, refactoring" or "bug-fix" (Sonnet, `xhigh`), a verifier uses "swarm workers" (Sonnet, `xhigh`), and the clean-context advisor uses "judgment and prose" (Opus, `xhigh`). A task with no row passes `model: "anthropic:claude-opus-5-5"`. (13 of 14 owners in one autopilot ran Opus, and its advisors ran Opus at `high`.)
- **Reply style.** Follow both AGENTS.md "Plain English" and poteto-mode "Writing the reply". Where they differ, AGENTS.md wins.

## Shipping

His ship prompt is the definition of done:

1. Commit on a branch from fresh `origin/main`.
2. When the prompt asks for a bug bash, run it. Fix what it finds and repeat until a round finds no regression, incomplete fix or new defect in changed code. Bugs that main had before the loop started follow the Swarm-verify amendment: each valid one is loop work, in this PR or in a follow-up PR. Attach the last report as an artifact.
3. Open the PR and wait for checks.
4. Merge through the merge queue when CI is green, both Codex lanes are clean on the exact head, and an independent final review finds no issues.
5. Report landed per the Shipping amendment "Stop at the ceiling".

- **Merge is your job** once he asked for it. Never end with "PR is open, do you want me to merge?". `--admin` needs his explicit word in this chat. A bypass list is not that word.
- **Pixel does not block.** Ignore the `Pixel / Review` status.
- **A silent Codex blocks.** Re-request the review once after about an hour. If Codex is still silent, report it and ask. Merge without a Codex verdict only on his word for that PR.
- **Fix now.** Fix a concrete defect in or next to the work in this branch, or in a sub-agent PR that you drive to merged. Do not offer to file an issue. Defer only scope creep that he agrees to defer. Memory defines scope creep as "a fix bigger than the original change". For a valid review finding from any source (a verifier or lane, an advisor, Codex, a trail review, a bug bash, a PR reviewer or your own check), the loop rule under "Swarm-verify once" wins: fix it in this PR or in a follow-up PR in the same run, and open no issue. A known gap that he agreed to defer as scope creep is a deferral: open its tracking issue before the merge, and link it from one contract line instead of listing its conditions. (A data-loss gap lived only in closed issues and a 7,954-character README bullet until a trail review flagged it.)

## Doing the work

- **Never hand him a step you can do.** Use `gh`, the Xum CLI, and the other CLIs to check state, find IDs, and merge.
- **Prefer the real fix.** Cut scope, delete code, and remove a race by construction instead of adding a heuristic or a workaround.
- **UI and HTML artifacts.** Check at phone width (mobile Safari) and in dark mode before you publish. Apply the `coder-brand` skill to visual output. When you fix a UI bug, find siblings with the same defect and fix them in the same PR.
- **Verification skills.** "Verify and formally verify" means run the repo's verification skill and its formal-verification skill. When the repo has none, create them with `create-verification-skill` and `create-formal-verification-skill`, land them, then fix what they find. Every verify brief names each output's home. Receipts go to the trail. A probe or scratch harness that caught a blocker goes to the repo's verification skill, or to its test folder when it has none. Memory gets only durable host facts, without SHAs or PR numbers. Memory points at repo paths, never at a workspace's scratch folder. (The matrices that caught the claudecode.nvim blockers lived only in sub-agent scratch folders. Aegis verifiers filled a required-reading memory file with per-PR receipts.)
- **Forks in research.** When research ends in "which approach" or "should we build this", write an `html-plan` with the decisions on it. Do not end with an offer.
- **Long or fan-out work.** Keep a `status-page` artifact. On his stop order, stop every sub-agent, monitor, and heartbeat. On "wind down", archive the helper workspaces this chat created. Delete one only when he says delete.
- **End every final report with a verdict.** Done or Not done, what merged, and what is still open. No "if you want" offers.

## Amendments to plugin steps

Each rule names the plugin step it changes as `[<plugin> <path> § <step title>]`. `scripts/check-drift.sh` checks that each title still exists. When the installed plugin commit differs from `PINNED`, it fetches the pinned upstream files and diffs them against the installed ones. A rule is stale when its step no longer exists or the plugin now says the same thing. Then follow the plugin and tell the user. Only a skill edit deletes the rule or accepts drift, as "Changing this skill" describes.

### Autopilot

[pstack skills/poteto-mode/playbooks/autopilot-full.md § Spawn one owner per PR]

- Every owner brief says: report only a new head, code-ready, merge-ready, a blocker, or a question. Never report "nothing changed" after a wake. Each report wakes the root and costs one turn. (A program used 116 of 120 turns and only 324 USD of a 450 USD budget.) Before any report, an owner stops every poller and monitor it started: the late wakes come from pollers that outlive the report.
- The root sends no reply after a wake that changed nothing.
- "Checks for the touched paths" means typecheck plus every test folder that imports or reaches the changed modules, never only the test files a plan lists. (An owner missed a broken existing unit test.)
- Each behavior premise in a root brief or verdict, such as "same as main" or "consistent with X", carries a file:line on origin/main or a control run. The owner checks it before building on it or quoting it. (A brief said the packed unpacker "already rejects symlinks", and owners copied that false premise into commits and PR bodies.)
- A rule learned from an incident goes into every brief whose readers run that operation: owner briefs, verifier briefs and the root's own scripts. Send it to every running child that runs that operation too. (After a `/tmp` backup collision, the `mktemp` rule reached only the verifier brief, and owners who also ran mutants never got it.)

[pstack skills/poteto-mode/playbooks/autopilot-stack.md § Stack a PR only when it builds on another PR]

- When the root's go depends only on a condition an owner can check, put it in the brief as a conditional order. Example: "When the PR below has Required green, 0 unresolved threads and a Codex approval on its exact head, merge its branch into yours, publish, and link the stack." The owner checks it read-only and acts. The root does not relay each go.
- A new head on a lower PR must reach every upper branch by merge, and each upper verdict must be re-checked, docs included. Under merge-only rules nothing restacks by itself. Before shipping, check `git merge-base --is-ancestor <lower-head> <upper-head>` for each adjacent pair. (A lower PR's last fix never reached the docs branch, and main shipped a wrong docs line. Script request: coder/xum#7873.)

[pstack skills/poteto-mode/playbooks/autopilot-full.md § Swarm-verify once]

- Only a push that changes no runtime behavior skips the verifier, and never one that answers a verifier's ISSUES verdict or that the root made itself. Every other push gets one root-briefed verifier at the new head. A root diff read is never a verifier, and "root delta" never appears in a merge gate or a `VERDICT` line. When the root regenerates a committed file with a repo tool, such as a lock file, the regenerated-file rule under "Re-check that the verdicts still describe the code" wins. A verifier never stands in for clean Codex lanes on the exact head or for the section 5.3 advisor. At any round count, past the review cap included, a merge without clean Codex lanes on the exact head needs his waiver for that PR. Ask for it by name before you enqueue. (A loop merged five PRs on the root's own diff read, and one past six Codex rounds on a verifier's word. Later a root diff read replaced the verifier on a setuid restore that macOS CI caught.)
- Every verify brief asks for one closing line per requested PR: `VERDICT #<pr> <40-char sha> PASS|ISSUES`. Merge only on a line whose PR and SHA match the head. A missing line means ask again. (A long-lived verifier answered two queued PRs in one turn and reported one.)
- Verify briefs carry over the owner rules under "Spawn one owner per PR", with one change to the report types. A verifier reports only when it has its `VERDICT` lines, a blocker or a question. It never reports "nothing changed" after a wake. Before any report, a verifier stops every poller and monitor it started. Every verify brief sets a time box and tells the verifier to name its unfinished lanes when the box runs out. The root records the verifier's stuck-after as the time box plus a margin and probes it then. (A verifier without a time box ran silent for hours. The 7 later briefs with one all reported on time.)
- A loop is a run of rounds with a stop rule. In a loop whose verifiers raise follow-ups, "a problem the PR's base already has" means the commit where the loop started, not current trunk. A regression the loop introduced is always loop work. A valid review finding from any source (a verifier or lane, an advisor, Codex, a trail review, a bug bash, a PR reviewer or your own check) is loop work too, whether the loop introduced it or main already had it. Fix it in the current PR while rounds allow. Only a bug that a user can hit, a failed gate or a wrong shipped doc opens a follow-up PR, which you drive to merged in the same run. Fix a nit or an item marked optional or cosmetic in the PR whose review raised it, or decline it with a reason. Never put it in a parking or tracking issue unless he agreed to defer it as scope creep (see "Fix now"). A reasoned decline of an invalid finding is still fine. Log each finding in a findings ledger in the trail when it arrives, with its disposition. A row stays open until its fix merges, it is declined with a reason, or he defers it. The loop stops, and a "done" report or notify goes out, only when no row is open. (An overwrite that one PR introduced was later called a known gap on main. Issue #15 parked 9 valid leftovers. He had them shipped in 3 PRs, plus 1 PR for their review leftovers. A 44-PR autopilot ran a follow-up chain #765→#790 off optional advisor nits, and sent "all fixed" while 7 valid findings sat only in subagent reports.)
- Add a spec lane. It checks the diff against each numbered decision of the governing spec or RFC. (Behavior tests alone passed a PR that broke one.)
- A docs PR gets a claim lane. It checks each changed sentence against the code, with file:line. Only lanes the root briefs count. A helper that the owner briefed is not independent.
- A docs PR that tells readers to run commands also gets an execution lane, before its Codex loop: a fresh agent follows the doc on a scratch clone of a real target repository. It skips or fakes every command that acts outside that clone, such as `gh`, `kubectl` or a deploy, and reports each one it skipped. Run it only when you trust the PR's author, such as his own agents or his team: a doc from anyone else gets the claim lane only. Run it again on the final head when a later edit changes a command. (An adoption page passed 3 Codex rounds. Then a dry run on coder/xum found 10 gaps, one of them a copy command that deleted the repository's own hook.)
- An evidence script prints one short line per result and ends with a count line. A receipt without its count line is unchecked. (The bash tool dropped an over-long line, and 111 failures read as a pass. Tool request: coder/xum#7876.)

[pstack skills/poteto-mode/playbooks/autopilot-full.md § Run the root layer]

- By the fourth review round with findings in one area, counted across every PR and follow-up PR that reopens that area, stop asking for a waiver per round. A split or follow-up PR continues its area's round count and gets no fresh budget. Each owner report carries that count. Make the call to narrow the scope or redesign that area yourself, with the section 5.3 advisor, instead of asking the operator. When you close an area, write the banned premise (such as "no proxy for editor state that has no API") into the repo's AGENTS.md in the PR that closes the area (create it if absent), and into every later brief for that area. In a repo you do not own, put it in the closing PR body and every later brief. (openFile's reload code took about 19 Codex rounds over six PRs, and the owner after a "stop adding mechanism" decision added a proxy that regressed. A split PR later got "its own six-round budget", so no area closed and no banned premise was written.)
- At every round boundary and after every context rollover, run the checkpoint's resume list (see Precedence). Check the checkpoint's flow against the playbook step by step. Below the resume list, the checkpoint lists every per-round duty: status page, spend from `session-usage.json`, trunk CI, the cross-model trail review and stuck-after probes. Rebuild the owner and verifier briefs from the trail. (A 30-hour loop followed its own checkpoint flow, which ran the verifier after the Codex rounds, and it published no status page and no spend.)
- Decide when to stop by the severity of new findings, not by the round count. On security and trust code, do not stop early: late rounds kept finding real P1s. Rounds past six still need his waiver.
- When the same gate false positive blocks a second PR, fix the gate in its own PR. Do not approve the bypass again.
- Before you spawn work after a final report, or ship a breaking change to a published contract, send him one catch-up that names the new scope and the spend so far. Then continue without waiting. (After a "done" notify, a root reopened the run for about 28 hours and shipped a breaking `fix!:` change, and he heard nothing until the release notify.)

[pstack skills/poteto-mode/playbooks/autopilot-full.md § **Reply:**]

- The reply lists follow-up PRs with their state, and links the tracking issue of each gap he agreed to defer as scope creep. It lists no other parked follow-ups. (Issue #15 parked 9 valid leftovers.)

### Babysit

[pstack skills/poteto-mode/playbooks/babysit.md § Order is conflicts, then review threads, then CI]

- Before each fix push, confirm that the review of the current head has finished (the review board names the head and reads completed). Then list every unresolved thread again. (An owner pushed a fix five minutes before Codex posted two P1s on the old head, and lost two rounds.)

[pstack skills/poteto-mode/references/bugbot-triage.md § Recurring skip candidates]

- Add this pattern, "Implementation detail on a design doc". On a design doc or RFC PR, defer a finding about a file-level plan detail to the code PR that implements it. Copy each such finding into that PR's brief. When that PR is part of this run, ship it before you stop. Otherwise ask him to bring it into this run or to defer the finding as scope creep. Block only on an error in a decision, an interface or an invariant. (An RFC drew 14, 7, 10, 4, 5 and 5 code-level findings over six rounds and never converged.)

[pstack skills/poteto-mode/references/bugbot-triage.md § Owner-declared follow-up or deferred cleanup]

- Only his word counts as the owner's declaration. A sub-agent owner cannot declare a follow-up to skip a finding. Then the finding is a follow-up PR in this run, unless he agreed to defer it as scope creep. (Issue #15 parked 9 valid leftovers.)

### Shipping

[pstack skills/poteto-mode/playbooks/shipping.md § Land only the contiguous verified run]

- A request to land does not waive a gate that the repo or the operator named, such as "Codex approval on the exact head". Ask for each exception by name before you enqueue.

[pstack skills/poteto-mode/playbooks/shipping.md § Re-check that the verdicts still describe the code]

- A verdict carries across a committed file that a repo tool regenerates (such as a lock file) when the tool's own check passes at the new head and the PR's own change outside that file is the same as at the verified head. Compare with `--binary --no-textconv --no-ext-diff`, and treat any git error as a change. PRs that regenerate the same file do it one at a time, each after the previous one reads MERGED. When both sides changed the same source file, the merge result gets fresh checks. (claudecode.nvim `covered.lock`, 2026-11.)
- Prove that each upper branch contains every lower PR's final head (`git merge-base --is-ancestor`). If one does not, merge it up and re-verify that PR, docs included. (Script request: coder/xum#7873.)

[pstack skills/poteto-mode/playbooks/shipping.md § Land bottom-up, one PR at a time]

- On a repo with a merge queue, land a native stack with `gh stack merge <stack#> --yes`. `gh pr merge` refuses stacked PRs.
- Before you enqueue several PRs together (a stack plus an independent PR, or any batch), build their combined merge result and run typecheck and the touched tests on it. A clean `git merge-tree` proves only that the text merges. (The queue dropped a PR on a type error caused by another PR in the same batch. Script request: coder/xum#7872.)

[pstack skills/poteto-mode/playbooks/shipping.md § Stop at the ceiling]

- Count a PR as landed only after the post-merge runs on its merge commit have settled and none of them failed, `Required` or not (release jobs included). `success`, `neutral` and `skipped` count as passing. Post-merge workflows can start late, and a PR that adds, removes or renames a workflow changes the set, so check those workflows by name. Report the result. (release-please went red on main during a loop that checked only `Required`.)

### Show me your work

[pstack skills/show-me-your-work/SKILL.md § Cross-model review of the trail]

- In a loop that does not hand back (a loop as defined under "Swarm-verify once"), run this review at each round boundary (each merged follow-up PR), not only before handing back. Give the reviewer the Xum transcript paths (`~/.xum/sessions/<ws>/chat.jsonl` and `chat-archive.jsonl`) or a digest, as in the Reflect amendment. (Five under-verified merges landed in a 24-hour gap between reviews.)
- In a one-shot campaign, run this review before the last merges, so that its findings can still change them. Run it again on the final main and on the closing drafts, before you post them. A closing comment states only what is true on main. (An audit after most merges found a miscount and a contradicted decision already on main, and closing drafts that called items fixed by a PR that was still open.)

[pstack skills/show-me-your-work/SKILL.md § Rules]

- Before you `task_remove` a child, grep the trail for its workspace ID, copy every cited file into the parent's trail folder, and append a row that maps each cited path to its copy. Old rows stay as they are. Removal deletes the child's scratch folder. (A measurement child's replay summary was lost, and an audit still cited its scratch path.)

### Figure it out

[pstack skills/figure-it-out/SKILL.md § Phase A: Frame]

- When the scope is an inventory of issue items, one cross-model agent checks the inventory against the raw issue threads. Fix every mismatch that it reports in the inventory before the lanes start. (An inventory missed 3 items, and the gaps reached builders and closing comments.)

[pstack skills/figure-it-out/SKILL.md § Phase B: Design the workflow]

- Each worker that builds also gets its own build-output folder, such as `CARGO_TARGET_DIR`, and deletes it in its final task. The parent keeps a list of these folders, and deletes a folder itself when its worker stops early, fails or is removed. (Builders kept one Cargo target folder per variant, about 90 GB across 4 lanes, while the home folder was over its limit.)

### Reflect

[pstack skills/reflect/SKILL.md § 1. Locate the active transcript]

- A Xum transcript over a few MB (`~/.xum/sessions/<ws>/chat-archive.jsonl` plus `chat.jsonl`) goes to the reviewers as a digest file with the JSONL paths and his verbatim corrections. (A 20 MB archive cannot be read whole.)

[pstack skills/reflect/SKILL.md § 5. Apply]

- Route every Accepted edit that targets a pstack or egm file into this skill. A general rule goes in a theme section. A change to one plugin step goes under Amendments with its anchor. Never copy a plugin skill into `~/.xum/skills/` or `.xum/skills/`: the copy hides the plugin skill and stops getting upstream updates.
- Route the other edits by who owns the file. A fux-plugins skill gets a PR to `coder/fux-plugins`. A skill that the skills CLI installed (`~/.agents/skills`, such as gh-stack) gets a global memory rule, because an upstream change is an external fix that needs his approval. A repo skill or a Xum built-in skill gets a PR in that repo. A personal workflow gets a skill in personal-plugins.
- Before you accept a row, read the target and his memory. Sharpen an existing rule instead of adding a new one. (Most gh-stack rows of one /reflect were already in memory.)
- Show each row's destination in the approval list. After approval, ship a thomas-mode edit per "Changing this skill", and ship every other row at its own destination. This replaces reflect's "Never open a PR or push" for every route above.
- List Backlog items in the reply. File an issue only when he says so.

### Design docs

[egm skills/egm-draft/SKILL.md § Step 5: Draft Implementation]

- Put the file-by-file plan under a heading marked advisory, apart from the binding decisions and acceptance criteria. Reviewers and implementers treat only the binding part as the contract.
- After implementation, record file-level drift once in an "As built" list. Do not fix the doc in each review round.
- List acceptance tests by behavior. Do not let the doc's test list become the implementer's whole test run. (An owner ran only the listed test files and missed a broken existing test.)

## Changing this skill

`/reflect` and `/correct` lessons about pstack or egm go here, never into `~/.mux/plugins/`. A general rule goes in a theme section. A rule that changes one plugin step goes under Amendments, with its anchor and the incident that taught it in one line. When a script starts to enforce a rule, replace the prose with "run <script>". Edit in a clone of `ThomasK33/personal-plugins`, run `scripts/check-drift.sh` and the repo validator, and open a PR. When the check exits 1, read each report line before `--accept`:

- `CHANGED`: read that file's `--diff`.
- `ADDED`: read the whole file.
- `ANCHOR`: the plugin dropped or renamed that step. Re-anchor each rule there to the renamed step, or delete it as stale. On a `MISSING` file, handle it as `MISSING` instead.
- `MISSING`: check whether the file exists upstream. Take the plugin's entry in `~/.mux/plugins.json`. Look in the repo at `source.url`, with any trailing slash dropped, at commit `lockedSha`. The path is `<source.subpath>/<path>` when `subpath` is set, else `<path>`. pstack sets `subpath`, and without it the check gets 404 for a file that exists. If the file exists, the install is broken. Fix the install and run the check again. An `ANCHOR` on that file is not stale. If it does not, the plugin dropped or moved the file. Re-anchor each rule on it to the new path, or delete it as stale. For a `WATCH` file, update or remove its `WATCH` entry in `scripts/check-drift.sh` instead, and the same path where steps 1 and 2 name it. Then run the check again. `--accept` refuses while any file is MISSING.
- `NOPIN`: the plugin has no pin to diff against. Read each of its files whole, as for `ADDED`: each anchor path of that plugin in this skill, plus each `WATCH` entry for that plugin in `scripts/check-drift.sh`.

Apply the stale-rule test from "Amendments to plugin steps" to each amended step you read. This skill edit deletes or re-anchors each stale rule. Then run `--accept` and commit `PINNED` in the same PR. `--accept` pins whole plugins, so never run it after reading only some files.
