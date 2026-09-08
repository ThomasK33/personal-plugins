# Personal plugins

Reusable workflows for coding agents, packaged as [Agent Plugins 1.0.0](https://agent-plugins.org/specification).

## Plugins

| Plugin | When to use it |
| --- | --- |
| [deliver-reviewable-changes](plugins/deliver-reviewable-changes/skills/deliver-reviewable-changes/SKILL.md) | Before planning or implementing substantial changes, to choose independently shippable increments and prepare focused human review. |

The first plugin carries one workflow from scoping through implementation, verification, and PR preparation. It helps an agent keep necessary tests and correctness protections within each increment, explain review priorities, and reconsider scope when review keeps uncovering new concerns. Its workflow retains human approval before merge.

## Use a plugin

```sh
git clone https://github.com/thomask33/personal-plugins.git
```

Use `personal-plugins/plugins/deliver-reviewable-changes` as the plugin root in a client that supports Agent Plugins skills. That directory contains the portable `plugin.json` and `skills/` tree. Installation and activation are client-specific; follow your client's [setup instructions](https://agent-plugins.org/compatible-clients).

Once the skill is available, give the agent this instruction at task start:

> Use the deliver-reviewable-changes skill before planning or implementing this change. Choose the next independently shippable increment, identify its required validation, and carry that scope through the PR handoff.

If your client supports Agent Skills but cannot yet load this plugin format, import the complete `plugins/deliver-reviewable-changes/skills/deliver-reviewable-changes` directory through its skill installation mechanism. Keep the `references/` directory with `SKILL.md`.

The description is written for early discovery. Explicitly invoking the skill makes the intended use clear; installation alone does not guarantee that an agent will select it for every task. The plugin needs no MCP server, credentials, or executable hooks.

## Package layout

```text
plugins/
└── deliver-reviewable-changes/
    ├── plugin.json
    └── skills/
        └── deliver-reviewable-changes/
            ├── SKILL.md
            ├── agents/openai.yaml
            └── references/
```

Each directory immediately under `plugins/` is a separate portable package. The repository itself is a collection, not a plugin root. The portable manifest uses the standard's fixed `skills/` discovery location. The skill's optional `agents/openai.yaml` carries UI metadata for clients that understand it.

## Validate changes

Use Python 3.11 or newer:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python scripts/validate_plugins.py
```

Validation checks each manifest against the official versioned JSON Schema, checks skill frontmatter and package containment, and verifies local Markdown references. It downloads the schema from its canonical HTTPS URL and verifies a pinned SHA-256 digest. To validate offline after installing the dependencies, pass a previously downloaded copy with `--schema /path/to/plugin.schema.json`.

These are packaging checks. They do not establish that the instructions improve agent behavior or that every client has been tested. GitHub Actions runs the same checks on pushes and pull requests.

To add another plugin, create `plugins/<plugin-name>/plugin.json`, place its skills directly under `skills/`, and add it to the table above. Client-specific distribution adapters belong outside the portable package unless they follow the standard's extension conventions.
