# Agent instructions

## thomas-mode credential rules

Banned premise: the skill text can list every trigger, channel, attacker and probe step, and a lane that tests credential handling can probe with the real credential or against real targets.

The trigger, channel, attacker and probe lists of a PR live in that PR's trail, never in `skills/thomas-mode/SKILL.md`.

## Code Review Rules

### Credential handling in thomas-mode

- The threat-model rule and every lane that tests credential handling in `skills/thomas-mode/SKILL.md` each keep one general trigger, built on who can read a credential, where, or for how long, and only the method steps that hold for every PR they apply to, such as the canary lane's sandbox and canary. Each such lane also keeps one finding rule, judged against what the owner wrote into the trail. Their rule text names no channel, attacker or input value. An incident note in parentheses can, because it records what happened. Safe path: any other trigger, channel, attacker or probe step, and any case that the rule or such a lane can miss, goes into that PR's trail.
- Flag text that lets a lane that tests credential handling hold the real credential or act on a real target.

### Shadow verifier study in thomas-mode

- The study reference (`skills/thomas-mode/references/verifier-shadow-study.md`) coordinates several roots only through the end marker and one `flock`. Flag text that adds another cross-root protocol: a report owner, a report claim, an acknowledgement from other roots, or a lock held across a brief launch. A shadow run after the end costs money but changes no result, and the operator accepted that.
