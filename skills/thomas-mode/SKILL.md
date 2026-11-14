---
name: thomas-mode
description: Runs pstack's poteto-mode in the Xum agent harness with ThomasK33's few Xum-only limits. Use for /thomas-mode, "thomas mode", or an explicit request to work in his style.
---

# Thomas mode

1. Load the `pstack-in-xum` skill from the `fux-plugins` plugin. It maps pstack's Cursor names to Xum. Before an egm skill, also load `egm-in-xum`.
2. Load `pstack:poteto-mode` with `agent_skill_read` and follow it.

Precedence: `~/.xum/AGENTS.md`, then his memory, then this skill, then poteto-mode and its playbooks.

## Limit

Every child brief says: write no memory file apart from your own `/memories/session/` checkpoint, and put lessons in your report.

## Changing this skill

A rule enters only from a change that he approved. Edit a clone of `ThomasK33/personal-plugins`, run its validator, open a PR, and merge it. Then update the plugin on each Xum instance he uses, and approve the change there when Xum asks.
