---
name: thomas-mode
description: "Works in ThomasK33's style on top of pstack's poteto-mode in the Xum agent harness: Xum names for pstack tools, his shipping and review rules, and his amendments to pstack and egm playbook steps. Use only for /thomas-mode, \"thomas mode\", or an explicit request to work in his style."
---

# Thomas mode

Paths are relative to this skill's directory (`skillDir` in the `agent_skill_read` result).

1. Load the `pstack-in-xum` skill from the `fux-plugins` plugin. It maps pstack's Cursor names to Xum. When `scripts/check-drift.sh` reports a change to pstack's `docs/harness/claude-code.md`, check whether `pstack-in-xum` needs a new row.
2. Run `scripts/check-drift.sh`. On exit 1, name each changed file and read its diff (`--diff`, redirected to a file) for the steps this skill amends. Tell the user what changed before you follow an amended step. Do not stop. On exit 2, report the error and continue without the check.
3. Load `pstack:poteto-mode` with `agent_skill_read` and follow it, with the rules below.

Precedence: `~/.xum/AGENTS.md`, then his memory (`/memories/global/user-workflow-preferences.md`, read it with the `memory` tool at task start), then this skill, then poteto-mode and its playbooks. This skill does not repeat AGENTS.md or memory.

## Where poteto-mode yields

- **PRs.** "Land", "get it merged", "ship it", or his ship prompt is the request to open a PR and merge it. "Fix" alone is not. Then poteto-mode's "Opening a PR" runs.
- **Review rounds.** AGENTS.md section 5 caps review at six rounds per PR. It replaces any round count in a playbook.
- **Subagents.** Pass `model: "anthropic:claude-opus-5-5"` on every `task` unless a pstack role line says otherwise.
- **Reply style.** Follow both AGENTS.md "Plain English" and poteto-mode "Writing the reply". Where they differ, AGENTS.md wins.

## Shipping

His ship prompt is the definition of done:

1. Commit on a branch from fresh `origin/main`.
2. When the prompt asks for a bug bash, run it. Fix what it finds and repeat until a round finds nothing new. Attach the last report as an artifact.
3. Open the PR and wait for checks.
4. Merge through the merge queue when CI is green, Codex has no open comments, and an independent final review finds no issues.
5. Report landed per the Shipping amendment "Stop at the ceiling".

- **Merge is your job** once he asked for it. Never end with "PR is open, do you want me to merge?". `--admin` needs his explicit word in this chat. A bypass list is not that word.
- **Pixel does not block.** Ignore the `Pixel / Review` status.
- **A silent Codex blocks.** Re-request the review once after about an hour. If Codex is still silent, report it and ask. Merge without a Codex verdict only on his word for that PR.
- **Fix now.** Fix a concrete defect in or next to the work in this branch, or in a sub-agent PR that you drive to merged. Do not offer to file an issue. Defer only scope creep, as defined in memory ("a fix bigger than the original change").

## Doing the work

- **Never hand him a step you can do.** Use `gh`, the Xum CLI, and the other CLIs to check state, find IDs, and merge.
- **Prefer the real fix.** Cut scope, delete code, and remove a race by construction instead of adding a heuristic or a workaround.
- **UI and HTML artifacts.** Check at phone width (mobile Safari) and in dark mode before you publish. Apply the `coder-brand` skill to visual output. When you fix a UI bug, find siblings with the same defect and fix them in the same PR.
- **Verification skills.** "Verify and formally verify" means run the repo's verification skill and its formal-verification skill. When the repo has none, create them with `create-verification-skill` and `create-formal-verification-skill`, land them, then fix what they find.
- **Forks in research.** When research ends in "which approach" or "should we build this", write an `html-plan` with the decisions on it. Do not end with an offer.
- **Long or fan-out work.** Keep a `status-page` artifact. On his stop order, stop every sub-agent, monitor, and heartbeat. On "wind down", archive the helper workspaces this chat created. Delete one only when he says delete.
- **End every final report with a verdict.** Done or Not done, what merged, and what is still open. No "if you want" offers.

## Amendments to plugin steps

Each rule names the plugin step it changes as `[<plugin> <path> § <step title>]`. `scripts/check-drift.sh` checks that each title still exists. When the installed plugin commit differs from `PINNED`, it fetches the pinned upstream files and diffs them against the installed ones. A rule is stale when its step no longer exists or the plugin now says the same thing. Then follow the plugin, delete the rule, and tell the user. After you review a drift report, run `scripts/check-drift.sh --accept` in a clone of `ThomasK33/personal-plugins` and commit `PINNED`.

### Autopilot

[pstack skills/poteto-mode/playbooks/autopilot-full.md § Spawn one owner per PR]

- Every owner brief says: report only a new head, code-ready, merge-ready, a blocker, or a question. Never report "nothing changed" after a wake. Each report wakes the root and costs one turn. (A program used 116 of 120 turns and only $324 of $450.)
- The root sends no reply after a wake that changed nothing.
- "Checks for the touched paths" means typecheck plus every test folder that imports or reaches the changed modules, never only the test files a plan lists. (An owner missed a broken existing unit test.)

[pstack skills/poteto-mode/playbooks/autopilot-stack.md § Stack a PR only when it builds on another PR]

- When the root's go depends only on a condition an owner can check, put it in the brief as a conditional order. Example: "When the PR below has Required green, 0 unresolved threads and a Codex approval on its exact head, merge its branch into yours, publish, and link the stack." The owner checks it read-only and acts. The root does not relay each go.
- A new head on a lower PR must reach every upper branch by merge, and each upper verdict must be re-checked, docs included. Under merge-only rules nothing restacks by itself. Before shipping, check `git merge-base --is-ancestor <lower-head> <upper-head>` for each adjacent pair. (A lower PR's last fix never reached the docs branch, and main shipped a wrong docs line. Script request: coder/xum#7873.)

[pstack skills/poteto-mode/playbooks/autopilot-full.md § Swarm-verify once]

- Add a spec lane. It checks the diff against each numbered decision of the governing spec or RFC. (Behavior tests alone passed a PR that broke one.)
- A docs PR gets a claim lane. It checks each changed sentence against the code, with file:line. Only lanes the root briefs count. A helper that the owner briefed is not independent.
- An evidence script prints one short line per result and ends with a count line. A receipt without its count line is unchecked. (The bash tool dropped an over-long line, and 111 failures read as a pass. Tool request: coder/xum#7876.)

[pstack skills/poteto-mode/playbooks/autopilot-full.md § Run the root layer]

- By the fourth review round with findings in one area, stop asking for a waiver per round. Ask the operator one question whose options include narrowing the scope or redesigning that area.
- Decide when to stop by the severity of new findings, not by the round count. On security and trust code, do not stop early: late rounds kept finding real P1s. Rounds past six still need his waiver.
- When the same gate false positive blocks a second PR, fix the gate in its own PR. Do not approve the bypass again.

### Babysit

[pstack skills/poteto-mode/playbooks/babysit.md § Order is conflicts, then review threads, then CI]

- Before each fix push, confirm that the review of the current head has finished (the review board names the head and reads completed). Then list every unresolved thread again. (An owner pushed a fix five minutes before Codex posted two P1s on the old head, and lost two rounds.)

[pstack skills/poteto-mode/references/bugbot-triage.md § Recurring skip candidates]

- Add this pattern, "Implementation detail on a design doc". On a design doc or RFC PR, defer a finding about a file-level plan detail to the code PR that implements it. Block only on an error in a decision, an interface or an invariant. (An RFC drew 14, 7, 10, 4, 5 and 5 code-level findings over six rounds and never converged.)

### Shipping

[pstack skills/poteto-mode/playbooks/shipping.md § Land only the contiguous verified run]

- A request to land does not waive a gate that the repo or the operator named, such as "Codex approval on the exact head". Ask for each exception by name before you enqueue.

[pstack skills/poteto-mode/playbooks/shipping.md § Re-check that the verdicts still describe the code]

- Prove that each upper branch contains every lower PR's final head (`git merge-base --is-ancestor`). If one does not, merge it up and re-verify that PR, docs included. (Script request: coder/xum#7873.)

[pstack skills/poteto-mode/playbooks/shipping.md § Land bottom-up, one PR at a time]

- On a repo with a merge queue, land a native stack with `gh stack merge <stack#> --yes`. `gh pr merge` refuses stacked PRs.
- Before you enqueue several PRs together (a stack plus an independent PR, or any batch), build their combined merge result and run typecheck and the touched tests on it. A clean `git merge-tree` proves only that the text merges. (The queue dropped a PR on a type error caused by another PR in the same batch. Script request: coder/xum#7872.)

[pstack skills/poteto-mode/playbooks/shipping.md § Stop at the ceiling]

- Count a PR as landed only after trunk's post-merge CI on its commit passes, and report that result.

### Reflect

[pstack skills/reflect/SKILL.md § 1. Locate the active transcript]

- A Xum transcript over a few MB (`~/.xum/sessions/<ws>/chat-archive.jsonl` plus `chat.jsonl`) goes to the reviewers as a digest file with the JSONL paths and his verbatim corrections. (A 20 MB archive cannot be read whole.)

[pstack skills/reflect/SKILL.md § 5. Apply]

- Route every Accepted edit that targets a pstack or egm file into this skill. A general rule goes in a theme section. A change to one plugin step goes under Amendments with its anchor. Never copy a plugin skill into `~/.xum/skills/` or `.xum/skills/`: the copy hides the plugin skill and stops getting upstream updates.
- Route the other edits by who owns the file. A fux-plugins skill gets a PR to `coder/fux-plugins`. A skill that the skills CLI installed (`~/.agents/skills`, such as gh-stack) gets a global memory rule, because an upstream change is an external fix that needs his approval. A repo skill or a Xum built-in skill gets a PR in that repo. A personal workflow gets a skill in personal-plugins.
- Before you accept a row, read the target and his memory. Sharpen an existing rule instead of adding a new one. (Most gh-stack rows of one /reflect were already in memory.)
- Show the thomas-mode destination in the approval list. After approval, ship the edit per "Changing this skill". This replaces reflect's "Never open a PR or push" for thomas-mode.
- List Backlog items in the reply. File an issue only when he says so.

### Design docs

[egm skills/egm-draft/SKILL.md § Step 5: Draft Implementation]

- Put the file-by-file plan under a heading marked advisory, apart from the binding decisions and acceptance criteria. Reviewers and implementers treat only the binding part as the contract.
- After implementation, record file-level drift once in an "As built" list. Do not fix the doc in each review round.
- List acceptance tests by behavior. Do not let the doc's test list become the implementer's whole test run. (An owner ran only the listed test files and missed a broken existing test.)

## Changing this skill

`/reflect` and `/correct` lessons about pstack or egm go here, never into `~/.mux/plugins/`. A general rule goes in a theme section. A rule that changes one plugin step goes under Amendments, with its anchor and the incident that taught it in one line. When a script starts to enforce a rule, replace the prose with "run <script>". Edit in a clone of `ThomasK33/personal-plugins`, run `scripts/check-drift.sh` and the repo validator, and open a PR.
