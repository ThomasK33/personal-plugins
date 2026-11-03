#!/usr/bin/env python3
"""Check the skills-only Agent Plugin at this repository's root."""

import argparse
import hashlib
import json
import os
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit

import yaml
from jsonschema import Draft202012Validator


# Committed copy of https://agent-plugins.org/schemas/1.0.0/plugin.schema.json, so checks need no network.
# To refresh it, download that URL over this file, inspect the upstream change, then update SCHEMA_SHA256.
SCHEMA_PATH = Path(__file__).with_name("plugin.schema.json")
SCHEMA_SHA256 = "0a4aad95ce337878ad38802ebf0daa3fde76abe3f65400c86bcbb1ec0b3ab883"
SKILL_NAME = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
LOCAL_LINK = re.compile(r"\[[^\]]*\]\(([^)]+)\)")
# Matches Xum's SKILL_ARGUMENT_PLACEHOLDER_RE. JavaScript \b is ASCII-only, hence re.ASCII.
ARGUMENT_PLACEHOLDER = re.compile(r"\$(ARGUMENTS\b|[1-9])", re.ASCII)
# The characters JavaScript's String.prototype.trim removes; Python's str.strip set differs.
JS_WHITESPACE = "\t\n\v\f\r \u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000\ufeff"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def inside(path, root):
    require(path.resolve().is_relative_to(root.resolve()), f"Path escapes package: {path}")


def check_links(document, root):
    for target in LOCAL_LINK.findall(document.read_text(encoding="utf-8")):
        target = target.strip("<>")
        link = urlsplit(target)
        if link.scheme in {"https", "http", "mailto"}:
            continue
        require(not link.scheme and not link.netloc, f"Nonportable link in {document}: {target}")
        if not link.path:
            continue
        relative = Path(unquote(link.path))
        require(not relative.is_absolute(), f"Absolute local link in {document}: {target}")
        resolved = document.parent / relative
        inside(resolved, root)
        require(resolved.exists(), f"Missing reference in {document}: {target}")


def split_frontmatter(text):
    """Split SKILL.md text the way Xum's parseSkillMarkdown does.

    Returns (yaml_text, body_lines, body_start_line). yaml_text is None when Xum would
    reject the file for missing or unclosed frontmatter; body_lines is then every line.
    Line numbers count lines after Xum's newline normalization, so they are file lines.
    """
    text = text.removeprefix("\ufeff").replace("\r\n", "\n").replace("\r", "\n")
    lines = text.split("\n")
    if text.startswith("---") and lines[0].strip(JS_WHITESPACE) == "---":
        end = next((i for i in range(1, len(lines)) if lines[i].strip(JS_WHITESPACE) == "---"), None)
        if end is not None:
            return "\n".join(lines[1:end]), lines[end + 1:], end + 2
    return None, lines, 1


def check_placeholders(document):
    # Xum replaces $ARGUMENTS and $1 to $9 anywhere in a skill body, code blocks included.
    _, lines, start = split_frontmatter(document.read_text(encoding="utf-8"))
    for number, line in enumerate(lines, start):
        require(not ARGUMENT_PLACEHOLDER.search(line),
                f"Argument placeholder in {document}:{number}: Xum replaces $ARGUMENTS and $1 to $9 with invocation arguments")


def check_skill(skill, plugin):
    entry = skill / "SKILL.md"
    require(entry.is_file(), f"Missing skill entry: {entry}")
    text = entry.read_text(encoding="utf-8")
    frontmatter, body, _ = split_frontmatter(text)
    require(frontmatter is not None, f"Missing YAML frontmatter: {entry}")
    data = yaml.safe_load(frontmatter)
    require(isinstance(data, dict), f"Frontmatter must be a mapping: {entry}")
    allowed = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
    require(not set(data) - allowed, f"Unknown frontmatter fields: {entry}")
    name = data.get("name")
    require(isinstance(name, str) and 1 <= len(name) <= 64 and SKILL_NAME.fullmatch(name),
            f"Invalid skill name: {entry}")
    require(name == skill.name, f"Skill name must match directory: {entry}")
    description = data.get("description")
    require(isinstance(description, str) and description.strip() and len(description) <= 1024,
            f"Invalid skill description: {entry}")
    for key in {"license", "compatibility", "allowed-tools"} & data.keys():
        require(isinstance(data[key], str) and data[key].strip(), f"Invalid {key}: {entry}")
    if "compatibility" in data:
        require(len(data["compatibility"]) <= 500, f"Compatibility is too long: {entry}")
    if "metadata" in data:
        require(isinstance(data["metadata"], dict) and all(
            isinstance(k, str) and isinstance(v, str) for k, v in data["metadata"].items()
        ), f"Metadata must map strings to strings: {entry}")
    require("\n".join(body).strip(), f"Empty skill body: {entry}")
    for document in skill.rglob("*.md"):
        check_links(document, plugin)
    for document in skill.rglob("SKILL.md"):
        check_placeholders(document)


def check_plugin(plugin, schema):
    require(plugin.is_dir(), f"Expected plugin directory: {plugin}")
    manifest = plugin / "plugin.json"
    require(manifest.is_file(), f"Missing portable manifest at repository root: {manifest}")
    # A deliberately stricter repository convention keeps archives straightforward.
    require(not plugin.is_symlink(), f"Plugin root cannot be a symlink: {plugin}")
    for directory, folders, files in os.walk(plugin):
        # Local checkout and development files are not distributed in Git archives.
        folders[:] = [name for name in folders if name not in {".git", ".venv", "__pycache__"}]
        for name in folders + files:
            if Path(directory) == plugin and name == ".git":
                continue  # A worktree may have a .git file instead of a directory.
            path = Path(directory) / name
            require(not path.is_symlink(), f"Package symlinks are not used in this repository: {path}")
            inside(path, plugin)
    data = json.loads(manifest.read_text(encoding="utf-8"))
    errors = sorted(Draft202012Validator(schema).iter_errors(data), key=lambda e: str(e.path))
    require(not errors, f"{manifest}: " + "; ".join(error.message for error in errors))
    require(not (plugin / "mcp.json").exists(),
            f"Add MCP schema and semantic checks before introducing MCP packages: {plugin}")
    skills = plugin / "skills"
    require(skills.is_dir(), f"Expected skills directory: {plugin}")
    entries = sorted(path for path in skills.iterdir() if path.is_dir())
    require(entries, f"No skills found: {plugin}")
    for skill in entries:
        check_skill(skill, plugin)
    print(f"Validated {data['name']}: root manifest, {len(entries)} skill(s), containment, references, placeholders")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--schema", type=Path, default=SCHEMA_PATH,
                        help="Use another copy of the pinned official schema (default: %(default)s)")
    args = parser.parse_args()
    raw = args.schema.read_bytes()
    require(hashlib.sha256(raw).hexdigest() == SCHEMA_SHA256,
            "Official schema digest changed; inspect the upstream change before updating the pin.")
    schema = json.loads(raw)
    Draft202012Validator.check_schema(schema)
    root = Path(__file__).resolve().parents[1]
    check_plugin(root, schema)
    check_links(root / "README.md", root)


if __name__ == "__main__":
    main()
