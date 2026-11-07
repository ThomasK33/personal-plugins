# Verifier shadow study

The "Shadow verifier study" rule under `Swarm-verify once` in `SKILL.md` points here. This file holds the ledger format, the terms and the final report.

## Terms

- **Primary:** the `swarm workers` verifier that the root briefs.
- **Shadow:** the `openai:gpt-6.1-sol` verifier that gets the same brief at the same head.
- **Blocker class:** the root sorts every finding of either verifier as valid blocker, valid minor or invalid. It sorts them as it sorts any review finding.
- **Correct verdict:** PASS on a head with no valid blocker, or ISSUES that names at least one valid blocker of that head. Count the `later` column when you decide whether a head has a valid blocker.
- **False block:** ISSUES on a head with no valid blocker.
- **Miss:** PASS on a head with a valid blocker, or ISSUES that names none of its valid blockers.
- **Paired head:** a PR head where both the primary and the shadow gave a `VERDICT` line, and the primary ran on the `swarm workers` model. A head whose primary was replaced by a verifier on another model (after a crash or a refusal) is not paired. Its rows stay in the ledger with that model.

## Ledger

The root keeps `~/.xum/analysis/verifier-shadow/ledger.tsv`. On first use it creates the file with this header row:

```
date_utc	repo	pr	head_sha	model	task_id	verdict	cost_usd	wall_min	brief_prs	blockers	later
```

1. The root writes the rows of a verifier when its task ends: it gave its last `VERDICT` line, was stopped or failed. It writes one row per PR head of the brief. An interim report or a question writes no row.
2. `verdict` is `PASS`, `ISSUES`, or `none` when the verifier ended without a `VERDICT` line for that head.
3. `cost_usd` is the verifier's subtree cost from `session-usage.json` when its task ends. `wall_min` is the minutes from the brief to the end of the task. `brief_prs` is the number of PRs in that brief. Each row of a brief repeats the same cost and wall time, so divide by `brief_prs` before summing.
4. `blockers` lists each finding that the verifier named, each with its blocker class.
5. When a later review or commit shows a blocker on that head, the root adds it to `later` on both rows of that head. It leaves `blockers` as it is.

## Report at 30 paired heads

The root reports when 30 paired heads exist and the PR of each of them is merged or closed, so that the `later` column is complete. The root reports to him:

1. Correct verdicts, false blocks and misses for each model.
2. Valid blockers that only one model found.
3. Cost and wall time for each model.
4. The heads that were not paired, with the reason: shadow missing, shadow stopped, shadow failed, or primary on another model.

The baseline is the replay of 17 frozen PR heads in `~/.xum/analysis/verifier-shadow/replay-2026-11-07/`. Its `JUDGE.md` used looser terms, and `rescored-strict.json` scores it again with the terms above: Sonnet 9 correct, 3 false blocks, 5 misses, and gpt-6.1-sol 11 correct, 5 false blocks, 1 miss. After the report, the root asks him which model the verifier role uses and whether to remove the study rule from `SKILL.md`.
