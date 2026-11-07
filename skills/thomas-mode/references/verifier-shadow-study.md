# Verifier shadow study

The "Shadow verifier study" rule under `Swarm-verify once` in `SKILL.md` points here. This file holds the ledger format, the terms and the final report.

## Terms

- **Primary:** the `swarm workers` verifier that the root briefs.
- **Shadow:** the `openai:gpt-6.1-sol` verifier that gets the same brief at the same head.
- **Blocker class:** the root sorts every finding of either verifier as valid blocker, valid minor or invalid. It sorts them as it sorts any review finding.
- **Correct verdict:** ISSUES when the head has at least one valid blocker, counting the `later` column, and PASS when it has none. An ISSUES verdict that names only valid minor or invalid findings is a false block.
- **Paired head:** a PR head where both the primary and the shadow gave a `VERDICT` line, and the primary ran on the `swarm workers` model. A head whose primary was replaced by a verifier on another model (after a crash or a refusal) is not paired. Its rows stay in the ledger with that model.

## Ledger

The root keeps `~/.xum/analysis/verifier-shadow/ledger.tsv`. On first use it creates the file with this header row:

```
date_utc	repo	pr	head_sha	model	task_id	verdict	cost_usd	wall_min	brief_prs	blockers	later
```

1. The root writes one row per verifier and PR head as soon as that verifier gives its `VERDICT` line, is stopped or fails. An interim report or a question does not write a row.
2. `verdict` is `PASS`, `ISSUES`, or `none` when the verifier ended without a `VERDICT` line for that head.
3. `cost_usd` is the verifier's subtree cost from `session-usage.json` for this brief. `wall_min` is the minutes from the brief to the verdict, or to the stop. `brief_prs` is the number of PRs in that brief. A brief that covers several PRs repeats its cost and wall time on each row, so divide by `brief_prs` before summing.
4. `blockers` lists each finding that the verifier named, each with its blocker class.
5. When a later review or commit shows a blocker on that head, the root adds it to `later` on both rows of that head. It leaves `blockers` as it is.

## Report at 30 paired heads

The root reports to him:

1. Correct verdicts and false blocks for each model.
2. Valid blockers that only one model found.
3. Cost and wall time for each model.
4. The heads that were not paired, with the reason: shadow stopped, shadow failed, or primary on another model.

The baseline is the replay of 17 frozen PR heads in `~/.xum/analysis/verifier-shadow/replay-2026-11-07/`. Its `JUDGE.md` defines the same terms. After the report, the root asks him which model the verifier role uses and whether to remove the study rule from `SKILL.md`.
