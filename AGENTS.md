# Agent instructions

## thomas-mode credential rules

Banned premise: the skill text can list every trigger, channel, attacker and probe step, and a lane can probe with the real credential or against real targets.

The channel and attacker lists of a PR live in that PR's trail, never in `skills/thomas-mode/SKILL.md`.

## Code Review Rules

### thomas-mode credential rules

- Do not add a trigger, channel, attacker or probe step to the threat-model rule or to a verify lane in `skills/thomas-mode/SKILL.md`. Safe path: when a lane can miss a case, record the case in that PR's trail.
- Flag lane text that lets a probe hold the real credential or act on a real target.
