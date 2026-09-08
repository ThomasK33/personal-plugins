# Personal plugins

An [Agent Plugins 1.0.0](https://agent-plugins.org/specification) package for coding agents. The repository root is the plugin root, with `plugin.json` and `skills/` directly inside it.

## Included skills

| Skill | When to use it |
| --- | --- |
| [deliver-reviewable-changes](skills/deliver-reviewable-changes/SKILL.md) | Before planning or implementing substantial changes, to choose independently shippable increments and prepare focused human review. |

The skill carries one workflow from scoping through implementation, verification, and PR preparation. It keeps necessary tests and correctness protections within each increment, freezes implementation scope when review begins, and prepares complete bounded stacks to merge together once review and CI are ready. Codex review approval and human approval remain separate; the workflow requires human approval before merge.

## Use the plugin

```sh
git clone https://github.com/thomask33/personal-plugins.git
```

Install from `https://github.com/thomask33/personal-plugins` in a client that supports Agent Plugins skills. For local installation, use the cloned `personal-plugins` directory itself as the plugin root. No repository subpath is needed. Installation and activation are client-specific; follow your client's [setup instructions](https://agent-plugins.org/compatible-clients).

Once the skill is available, give the agent this instruction at task start:

> Use the deliver-reviewable-changes skill before planning or implementing this change. Choose the next independently shippable increment, identify its required validation, and carry that scope through the PR handoff.

If your client supports Agent Skills but cannot yet load this plugin format, import the complete `skills/deliver-reviewable-changes` directory through its skill installation mechanism. Keep the `references/` directory with `SKILL.md`.

The description is written for early discovery. Explicitly invoking the skill makes the intended use clear; installation alone does not guarantee that an agent will select it for every task. The plugin needs no MCP server, credentials, or executable hooks.

## Package layout

```text
personal-plugins/
├── plugin.json
└── skills/
    └── deliver-reviewable-changes/
        ├── SKILL.md
        ├── agents/openai.yaml
        └── references/
```

The repository distributes one plugin, named `deliver-reviewable-changes` in its manifest. Skills live directly under the standard's fixed `skills/` discovery location. The skill's optional `agents/openai.yaml` carries UI metadata for clients that understand it.

## Validate changes

Use Python 3.11 or newer:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python scripts/validate_plugins.py
```

Validation requires a manifest at the repository root, validates it against the official versioned JSON Schema, checks skill frontmatter and package containment, and verifies local Markdown references. It downloads the schema from its canonical HTTPS URL and verifies a pinned SHA-256 digest. To validate offline after installing the dependencies, pass a previously downloaded copy with `--schema /path/to/plugin.schema.json`.

These are packaging checks. They do not establish that the instructions improve agent behavior or that every client has been tested. GitHub Actions runs the same checks on pushes and pull requests.

To add another skill to this plugin, create `skills/<skill-name>/SKILL.md` and add it to the table above. Keep the single `plugin.json` at the repository root. Client-specific extensions must follow the standard's extension conventions.
