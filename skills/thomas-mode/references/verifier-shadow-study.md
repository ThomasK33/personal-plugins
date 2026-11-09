# Verifier shadow study

The "Shadow verifier study" rule under `Swarm-verify once` in `SKILL.md` points here. This file holds the ledger format, the terms and the final report.

## Terms

- **Primary:** the `swarm workers` verifier that the root briefs.
- **Shadow:** one of the two verifiers that get the same brief at the same head as the primary. `SKILL.md` sets their models.
- **Blocker class:** the root sorts every finding of every verifier as valid blocker, valid minor or invalid. It sorts them as it sorts any review finding.
- **Correct verdict:** PASS on a head with no valid blocker, or ISSUES that names at least one valid blocker of that head as a reason for ISSUES. The root counts the `later` column when it decides whether a head has a valid blocker.
- **False block:** ISSUES on a head with no valid blocker.
- **Miss:** a PASS on a head with at least one valid blocker, or an ISSUES on such a head that names none of its valid blockers as a reason for ISSUES.
- **Full head:** a PR head where the primary and both shadows gave a `VERDICT` line in one brief (one `brief_id`), and the primary ran on the `swarm workers` model. When the root replaces the primary with a verifier on another model (after a crash or a refusal), that brief does not make the head full. Its rows stay in `ledger-phase2.tsv` with that model.

## Ledger

Phase 2 starts with the first brief that the root sends under the two-shadow rule in `SKILL.md`. Each brief that the root sends from then on is a phase 2 brief, also when a shadow is missing. Each earlier brief is a phase 1 brief.

Phase 2 has its own ledger, `~/.xum/analysis/verifier-shadow/ledger-phase2.tsv`. The root writes no row of a phase 2 brief to the phase 1 file, `ledger.tsv`. The root creates the phase 2 file on first use with this header row:

```
date_utc	repo	pr	head_sha	brief_id	role	model	task_id	verdict	cost_usd	wall_min	brief_prs	blockers	later
```

`brief_id` is the task ID of the first primary of that brief, and all verifiers of one brief share it, a replacement primary included. `role` is `primary` or `shadow`. When a phase 1 brief ends after phase 2 starts, the root writes its rows to `ledger.tsv` with that file's own columns.

1. The root writes the rows of a verifier when its task ends for any reason: it gave its last report, after the root asked again for any missing `VERDICT` line, or the root stopped it, or it failed. It writes one row per PR head of the brief. The root writes no row for an interim report or a question.
2. `verdict` is `PASS`, `ISSUES`, or `none` when the verifier ended without a `VERDICT` line for that head.
3. `cost_usd` is the verifier's subtree cost from `session-usage.json` when its task ends. `wall_min` is the minutes from the brief to the end of the task. `brief_prs` is the number of PRs in that brief. The rows of one verifier for one brief repeat the same cost and wall time, so divide by `brief_prs` before summing.
4. `blockers` lists each finding that the verifier named, each with its blocker class, and marks the ones it gave as a reason for ISSUES.
5. Until the cutoff of a head, the root adds each blocker that a later review or commit shows on that head to `later` on every row of that head. When it writes a row after such a blocker, the row gets the same `later` value. The root leaves `blockers` as it is. The cutoff of a head is the moment someone merges or closes its PR, or the moment the root sends an early report because he ended the study, whichever comes first. A blocker found after the cutoff does not change the ledger.

## Final report

The report counts one brief per head: the first brief that makes the head full. Its rows are the counted rows of that head, and the report uses no other rows of that head. The phase 2 cohort is the first 30 full heads in `ledger-phase2.tsv`, in the order in which the root writes the row that makes each head full. When the root writes that row for the 30th full head, the root sends no more briefs to shadows and stops every shadow that is still running. A brief whose shadow the root stopped does not make its head full, and an earlier full brief of that head still counts. The root reports when the cutoff of each head in the cohort has passed. When he ends the study early, the root first stops every shadow that is still running and writes its rows. Then it reports at once, and the moment it sends that report is the cutoff for every open PR. The report uses only the rows that the root wrote before it. A primary that is still running keeps checking its PR, and its brief does not make its head full.

The report holds:

1. Correct verdicts, false blocks and misses for each model, over the counted rows of the cohort.
2. Valid blockers that only one model found, and for each shadow the valid blockers that it found and the primary missed, in the counted rows of the cohort.
3. Cost and wall time for each model, over its counted rows of the cohort.
4. The heads in `ledger-phase2.tsv` that were not full, with the role, the model and the reason: shadow missing, shadow stopped, shadow failed, shadow ended without a `VERDICT` line, primary stopped, failed or ended without a `VERDICT` line, primary still running at an early report, or primary on another model.

For phase 1 (Sonnet and gpt-6.1-sol only, `ledger.tsv`), `~/.xum/analysis/verifier-shadow/phase1-2026-11-08/live_judgment.md` gives the judgment of its 125-row snapshot `ledger-snapshot.tsv`. Over 53 scored head checks, it gives Sonnet 43 correct, 6 false blocks, 4 misses, and gpt-6.1-sol 38 correct, 11 false blocks, 4 misses. The earlier baseline is the replay of 17 frozen PR heads in `~/.xum/analysis/verifier-shadow/replay-2026-11-07/`. Its `JUDGE.md` and `JUDGE_W2.md` used looser terms, and `rescored-strict.json` scores it again with the terms above: Sonnet 9 correct, 3 false blocks, 5 misses, and gpt-6.1-sol 11 correct, 5 false blocks, 1 miss. After the report, the root asks him which model the verifier role uses, which shadows to keep, and whether to remove the study rule from `SKILL.md`.
