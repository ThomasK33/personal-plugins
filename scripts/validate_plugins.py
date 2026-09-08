#!/usr/bin/env python3
"""Check the skills-only Agent Plugin at this repository's root."""

import argparse
import hashlib
import json
import os
import re
from pathlib import Path
from urllib.parse import unquote, urlsplit
from urllib.request import urlopen

import yaml
from jsonschema import Draft202012Validator


SCHEMA_URL = "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json"
SCHEMA_SHA256 = "0a4aad95ce337878ad38802ebf0daa3fde76abe3f65400c86bcbb1ec0b3ab883"
SKILL_NAME = re.compile(r"[a-z0-9]+(?:-[a-z0-9]+)*")
LOCAL_LINK = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


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


def check_skill(skill, plugin):
    entry = skill / "SKILL.md"
    require(entry.is_file(), f"Missing skill entry: {entry}")
    text = entry.read_text(encoding="utf-8")
    match = re.match(r"\A---\r?\n(.*?)\r?\n---(?:\r?\n|\Z)", text, re.S)
    require(match is not None, f"Missing YAML frontmatter: {entry}")
    data = yaml.safe_load(match.group(1))
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
    require(text[match.end():].strip(), f"Empty skill body: {entry}")
    for document in skill.rglob("*.md"):
        check_links(document, plugin)


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
    print(f"Validated {data['name']}: root manifest, {len(entries)} skill(s), containment, references")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--schema", type=Path, help="Use a local copy of the pinned official schema")
    args = parser.parse_args()
    if args.schema:
        raw = args.schema.read_bytes()
    else:
        with urlopen(SCHEMA_URL, timeout=30) as response:
            raw = response.read()
    require(hashlib.sha256(raw).hexdigest() == SCHEMA_SHA256,
            "Official schema digest changed; inspect the upstream change before updating the pin.")
    schema = json.loads(raw)
    Draft202012Validator.check_schema(schema)
    root = Path(__file__).resolve().parents[1]
    check_plugin(root, schema)
    check_links(root / "README.md", root)


if __name__ == "__main__":
    main()
