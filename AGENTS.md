# Agent instructions

## thomas-mode credential rules

Banned premise: the skill text can list every trigger, channel, attacker and probe step, and a lane that tests credential handling can probe with the real credential or against real targets.

The trigger, channel, attacker and probe lists of a PR live in that PR's trail, never in `skills/thomas-mode/SKILL.md`.

## Code Review Rules

### Credential handling in thomas-mode

- Do not add a trigger, channel, attacker or probe step to the threat-model rule or to a lane that tests credential handling in `skills/thomas-mode/SKILL.md`. Safe path: when the rule or such a lane can miss a case, record the case in that PR's trail.
- Flag text that lets a lane that tests credential handling hold the real credential or act on a real target.
