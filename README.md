# Personal plugins

An [Agent Plugins 1.0.0](https://agent-plugins.org/specification) package for coding agents. The repository root is the plugin root, with `plugin.json` and `skills/` directly inside it.

## Included skills

| Skill | When to use it |
| --- | --- |
| [refactor-split-stack](skills/refactor-split-stack/SKILL.md) | When planning or running a behaviour-preserving refactor that splits long methods or a large file across several stacks of PRs, written by sub-agent workers. |
| [thomas-mode](skills/thomas-mode/SKILL.md) | When invoked as `/thomas-mode`. Runs the pstack plugin's `poteto-mode` in the Xum agent harness through the `pstack-in-xum` adapter, with Thomas's few Xum-only limits. |

## Use the plugin

```sh
git clone https://github.com/thomask33/personal-plugins.git
```

Install from `https://github.com/thomask33/personal-plugins` in a client that supports Agent Plugins skills. For local installation, use the cloned `personal-plugins` directory itself as the plugin root. No repository subpath is needed. Installation and activation are client-specific; follow your client's [setup instructions](https://agent-plugins.org/compatible-clients).

## Package layout

```text
personal-plugins/
├── plugin.json
└── skills/
    ├── refactor-split-stack/
    │   └── SKILL.md
    └── thomas-mode/
        └── SKILL.md
```

The repository distributes one plugin, named `personal-plugins` in its manifest. `thomas-mode` needs the pstack plugin and the `pstack-in-xum` skill from `coder/fux-plugins`, and works best with egm and the `egm-in-xum` skill from the same plugin. Skills live directly under the standard's fixed `skills/` discovery location.

## Validate changes

Use Python 3.11 or newer:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python scripts/validate_plugins.py
```

Validation requires a manifest at the repository root, validates it against the official versioned JSON Schema, checks skill frontmatter, argument placeholders (`$ARGUMENTS` and `$1` to `$9`) in `SKILL.md` bodies, and package containment, and verifies local Markdown references. It reads the committed schema copy at `scripts/plugin.schema.json`, so it needs no network, and verifies a pinned SHA-256 digest. To use another copy, pass `--schema /path/to/plugin.schema.json`.

These are packaging checks. They do not establish that the instructions improve agent behavior or that every client has been tested. GitHub Actions runs the validator on pushes and pull requests.

To add another skill to this plugin, create `skills/<skill-name>/SKILL.md` and add it to the table above. Keep the single `plugin.json` at the repository root. Client-specific extensions must follow the standard's extension conventions.
