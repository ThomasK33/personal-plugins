# pstack in Xum

pstack skills use Cursor names. Xum installs the Claude Code copy of pstack (`harness/pstack/claude-code`), so many pstack SKILL.md files say "In Claude Code, read the Claude Code adapter". In Xum, read this file instead, once per chat, then map each Cursor name with the tables below. Ignore the Claude Code adapter. Its `Agent`, `/pstack:<name>` and `~/.claude/` names are wrong in Xum.

`<pstack>` is the pstack plugin folder, `~/.mux/plugins/pstack`. If a Cursor field has no row, drop it and say so. Never pass a field the tool schema rejects.

Written against pstack 0.15.36. The thomas-mode drift check (`scripts/check-drift.sh`) watches the Claude Code adapter as a proxy: when upstream adds or changes a Cursor name, that file changes too. Then compare its rows with this file.

## Tools

| Cursor | Xum |
| --- | --- |
| `Task` | `task` |
| `AskQuestion` | `ask_user_question`, for balanced choices only. Its options carry no recommended pick. A decision that needs a recommendation goes in the chat reply instead. Outside plan mode the tool returns at once and the answer arrives as a later user message. Keep working on your best assumption. |
| Open a todolist | `todo_write`. It holds at most 15 items. When a playbook has more steps, merge the finished ones into one line. |
| Run another pstack skill (`/name` or "the **name** skill") | `agent_skill_read` with the name. Hidden pstack skills load by name too. When a global skill has the same name (`tdd`), use `pstack:<name>`. When you tell the user to type it, write `/<name>`. |
| A `Read` of a skill's `SKILL.md` as the sign that the skill ran | An `agent_skill_read` or `file_read` of that skill. |
| `Grep`, `Glob` | `bash` with `rg`, or `file_read`. |
| Cursor's `create-skill` | The `update-skill` skill. |
| `/loop`, a watcher, "poll until X" | `bash` with `run_in_background` and a `monitor` filter. Set `wake_on_exit: false` unless the exit matters. For a predicate that spans turns, `set_goal`, only when the user asks for multi-turn work. |

## Subagent fields

| Cursor | Xum |
| --- | --- |
| `subagent_type: generalPurpose` | `agentId: "exec"` |
| `poteto-agent`, `comment-sicko` | `agentId: "poteto-agent"`, `agentId: "comment-sicko"`. No `pstack:` prefix. |
| `readonly: true` | `agentId: "explore"`. |
| `readonly: false` | `agentId: "exec"`. |
| `environment: "local"` | Omit. |
| `environment: "cloud"` | In a local runtime, sub-agents share your working directory and can edit the same files. Give each parallel code writer its own `git worktree` and put the path in the brief. In a worktree or devcontainer runtime, each child starts from a fork of your committed state, so commit before you spawn. |
| `cloud_base_branch: <b>` | Tell the worker to check out `<b>` first, or pass `workspace.trunkBranch` with `kind: "workspace"`. |
| `run_in_background: true` | Use it for parallel spawns. For one task, run in the foreground. Each background report wakes the parent and costs one turn, so tell workers to report only state changes. |
| `resume`, or steering a running agent | `task_send_message` to the child. It reawakens an inactive child and steers an active one. pstack's "fresh subagents by default" still holds. Remove consumed children with `task_remove`. Keep at most 7 direct children. |
| `file_attachments` | List absolute paths in the brief. Never pass `$XUM_SCRATCH_DIR/...`: each child has its own scratch folder. |
| Best-of N candidates | `task` with `n`, for identical briefs to agents that cannot interfere, such as read-only ones. Give different slices separate `task` calls. |

## Models

| Cursor | Xum |
| --- | --- |
| The `pstack-models.mdc` rule | The "## pstack models" section of `~/.xum/AGENTS.md`. It is already in context. |
| A role line `<provider:model>` + level | `task` `model` and `thinking`. |
| `claude-<family>-<version>-<effort>[-fast]` with no role line | `model: "anthropic:claude-<family>-<version>"`, `thinking: "<effort>"`. Drop `-fast`. |
| `grok-*`, or a slug this host lacks | Use the role's line. With no line, omit `model` and say so. |
| `auto`, `inherit-parent` | Omit `model`. Exception: `explore` children do not inherit the parent model, so pass it. |

## setup-pstack

CAUTION: Never overwrite `~/.xum/AGENTS.md`. setup-pstack step 5 says "write the rule", and in Xum the rule is one section of that file. Follow its steps with these changes:

- Detect. The detected models are the ones `models_list` returns.
- Load. Read the current "## pstack models" section of `~/.xum/AGENTS.md`.
- Write. Replace only that section: the heading, the intro line, the `Budget:` line, and the role table. Leave the rest of the file as it is. Back the file up first.

## Paths

| Cursor | Xum |
| --- | --- |
| `.cursor/skills/`, `~/.cursor/skills/` | `.xum/skills/` or `.agents/skills/`, and `~/.xum/skills/` |
| `~/.cursor/plugins/`, `.cursor-plugin/plugin.json` | `~/.mux/plugins/<name>/`. The install record (source, ref, locked commit) is in `~/.xum/plugins.json`. |
| `.cursor/rules/*.mdc`, always-applied rules | The project's `AGENTS.md`, or `~/.xum/AGENTS.md` for global rules. Edit a section. Never overwrite the file. |
| `https://github.com/cursor/plugins/blob/main/pstack/<path>` | `<pstack>/<path>` when the file exists. Give the user the URL when they need a link. |
| `agent-transcripts/` of this workspace | `session_history` for this chat and its sub-agents. |
| Past transcripts | `~/.mux/sessions/<workspace-id>/chat.jsonl`. `~/.xum/config.json` `projects` maps each project path to its workspace ids, so you can stay inside one project. Read locally. Never upload transcripts or excerpts. See the filter below. |

A human message has `role: "user"`, no `metadata.synthetic`, no `metadata.retrySendOptions.agentInitiated`, and `metadata.muxMetadata.type` absent, `normal` or `agent-skill`. Other agents that write through the Xum CLI pass this filter too. Drop messages that start with "From the coordinating agent" or "Answer from the coordinating agent", and count identical text sent to many workspaces once.

## Xum limits that change pstack steps

- Each sub-agent report and each settled monitor wakes the parent and costs it one turn. A turn cap can run out long before the budget does, so set `wake_on_exit: false` unless the exit itself matters.
- The bash tool fails a whole result when one line passes 1024 bytes. Write evidence to a file and print counts.

## Cursor-only features

When a step needs one of these, write one line, `Skipped in Xum: <step>. <reason>.`, and go on. Do not stop or ask. When a later step needs what the skipped step made, such as a URL or a key, leave a placeholder and name it in the line.

| Cursor | Xum |
| --- | --- |
| Cursor Automations, `update_state` routine calls, routine wakes, `SendToUser` | Skip. A Xum workspace heartbeat is the nearest equivalent. Name it to the user. Do not set one up. |
| Bugbot, agentic security review | Treat their comments as ordinary review threads, triaged per `<pstack>/skills/poteto-mode/references/bugbot-triage.md`. Codex (`@codex review`) is the usual reviewer. Skip a step that starts, waits for, or configures Bugbot when the PR has no Bugbot check or comment. |
| Cursor cloud agents | See `environment: "cloud"`. Skip a step that needs the cloud agent's dashboard or machine. |
| Built-in PR tool | `gh`. Not a skip. |
| Cursor custom mode (option+enter) | None. Invoke the skill again on the next message. |
