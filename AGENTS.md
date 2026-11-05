# Agent instructions

## thomas-mode credential and input lanes

Banned premise: the skill text can list every trigger, channel, attacker and probe step, and a lane can probe with the real credential or against real targets.

`skills/thomas-mode/SKILL.md` states only the outcome of the threat-model rule, the canary lane and the input lane: one general trigger, the trusted-author gate, a throwaway sandbox, a fake canary credential, the finding rule and the rerun rule. The channel and attacker lists of a PR live in that PR's trail, never in the skill. (On #24, each review fix added one more case to these lanes, and they drew 14 of its 21 Codex findings over six rounds without converging.)

## Code Review Rules

### thomas-mode credential and input lanes

- Do not add a trigger, channel, attacker or probe step to the threat-model rule, the canary lane or the input lane in `skills/thomas-mode/SKILL.md`. Safe path: when a lane can miss a case, sharpen its outcome sentence so that it covers the case.
- Flag lane text that lets a probe hold the real credential or act on a real target.
