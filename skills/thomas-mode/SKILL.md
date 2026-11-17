---
name: thomas-mode
description: Runs pstack's poteto-mode in the Xum agent harness with ThomasK33's few Xum-only limits. Use for /thomas-mode, "thomas mode", or an explicit request to work in his style.
---

# Thomas mode

1. Load the `pstack-in-xum` skill from the `fux-plugins` plugin. It maps pstack's Cursor names to Xum. Before an egm skill, also load `egm-in-xum`.
2. Load `pstack:poteto-mode` with `agent_skill_read` and follow it.

Precedence: `~/.xum/AGENTS.md`, then his memory, then this skill, then poteto-mode and its playbooks.

## Overrides of poteto-mode

1. A value that encodes a third party's wire behavior (callback parameters, issuer, error and status codes) is checked against the provider's published metadata, its docs or a recorded real exchange. A fact recalled from memory is unverified, and the report says so.
2. Each integration's tests include one happy path fed by a recorded real exchange or the provider's published metadata. Provider input that the author made up proves only the author's belief. Killed mutants do not change that.
3. A brief that touches a third party asks for every external assumption the code encodes, each tagged observed, documented or assumed. The parent checks each provider-facing value in the delegated diff against that list.
4. Any request to merge, land or ship, one PR included, loads poteto-mode's Shipping playbook (`pstack:poteto-mode`, `playbooks/shipping.md`) before any merge command runs. Green CI is not a verdict. An independent verifier checks the exact head first.
5. When a change's user path crosses a third-party login that no check completed, the merge report says so first. Before the merge, offer a labeled choice. Option A: one real sign-in first, on a preview whose callback the provider allows, or on production while the agent reads the logs. Option B: accept that the person's first use is the test.

## Limit

Every child brief says: write no memory file apart from your own `/memories/session/` checkpoint, and put lessons in your report.

## Changing this skill

A rule enters only from a change that he approved. Edit a clone of `ThomasK33/personal-plugins`, run its validator, open a PR, and merge it. Then update the plugin on each Xum instance he uses, and approve the change there when Xum asks.
