# Agent instructions

## thomas-mode credential rules

Banned premise: the skill text can list every trigger, channel, attacker and probe step, and a lane that tests credential handling can probe with the real credential or against real targets.

The trigger, channel, attacker and probe lists of a PR live in that PR's trail, never in `skills/thomas-mode/SKILL.md`.

## Code Review Rules

### Credential handling in thomas-mode

- The threat-model rule and every lane that tests credential handling in `skills/thomas-mode/SKILL.md` each keep one general trigger, built on who can read a credential, where, or for how long. Do not add another trigger, or a channel, attacker or probe step, to them. Safe path: when the rule or such a lane can miss a case, record the case in that PR's trail.
- Flag text that lets a lane that tests credential handling hold the real credential or act on a real target.
