---
name: thomas-mode
description: "Runs pstack's poteto-mode in the Xum agent harness with ThomasK33's few Xum-only limits. Use for /thomas-mode, \"thomas mode\", or an explicit request to work in his style. Also read its Amendments to plugin steps before any pstack or egm step that runs without it, including /reflect."
---

# Thomas mode

Paths are relative to this skill's directory (`skillDir` in the `agent_skill_read` result).

When you load this skill only for its Amendments (a pstack or egm step that runs without `/thomas-mode`), skip step 2 below, and apply only the "Amendments to plugin steps" rules for the steps you run.

1. Load the `pstack-in-xum` skill from the `fux-plugins` plugin. It maps pstack's Cursor names to Xum. Before you follow an egm skill, also load `egm-in-xum` from `fux-plugins`.
2. Load `pstack:poteto-mode` with `agent_skill_read` and follow it.

Precedence: `~/.xum/AGENTS.md`, then his memory (`/memories/global/user-workflow-preferences.md`, read it with the `memory` tool at task start and after every context rollover), then this skill, then poteto-mode and its playbooks.

## His limits

- **Sub-agent memory.** Every child brief says: write no memory file apart from your own `/memories/session/` checkpoint, and put lessons in your report.
- **Theme toggle.** Every HTML artifact has an Auto / Light / Dark theme toggle at the top right. Copy its markup, CSS and script from [references/theme-toggle.md](references/theme-toggle.md), and follow that file's rules for the page and its check. When you change that file's markup, CSS or script, run `scripts/test-theme-toggle.sh`.
- **Verification skills.** "Verify and formally verify" means run the repo's verification skill and its formal-verification skill. When the repo has none, create them with `pstack:create-verification-skill` and `pstack:create-formal-verification-skill`.

## Amendments to plugin steps

### Reflect

[pstack skills/reflect/SKILL.md § 5. Apply]

- An edit to a pstack or egm step is a Backlog item. Never copy a plugin skill into `~/.xum/skills/` or `.xum/skills/`: the copy hides the plugin skill and stops getting upstream updates.
- Route every other row by the owner of its file: a `coder/fux-plugins` PR for a fux-plugins skill, a memory rule for a skill that the skills CLI installed, a repo PR for a repo skill, and `ThomasK33/personal-plugins` for a personal workflow. Show each row's destination in the approval list, and ship the approved rows there. This replaces reflect's "Never open a PR or push".
- List Backlog items in the reply. File an issue only when he says so.

## Changing this skill

A new rule enters only from a Backlog row that he approved. No amendment changes how a pstack step runs. Edit in a clone of `ThomasK33/personal-plugins`, run the repo validator, and open a PR.
