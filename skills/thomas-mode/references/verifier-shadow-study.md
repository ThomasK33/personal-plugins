# Verifier shadow study

The "Shadow verifier study" rule under `Swarm-verify once` in `SKILL.md` points here. This file holds the ledger format, the terms and the final report.

## Terms

- **Primary:** the `swarm workers` verifier that the root briefs.
- **Shadow:** each of the two verifiers, on `openai:gpt-6.1-sol` and on `anthropic:claude-opus-5-5`, that get the same brief at the same head as the primary.
- **Blocker class:** the root sorts every finding of every verifier as valid blocker, valid minor or invalid. It sorts them as it sorts any review finding.
- **Correct verdict:** PASS on a head with no valid blocker, or ISSUES that names at least one valid blocker of that head as a reason for ISSUES. The root counts the `later` column when it decides whether a head has a valid blocker.
- **False block:** ISSUES on a head with no valid blocker.
- **Miss:** a PASS on a head with at least one valid blocker, or an ISSUES on such a head that names none of its valid blockers as a reason for ISSUES.
- **Full head:** a PR head where the primary and both shadows gave a `VERDICT` line, and the primary ran on the `swarm workers` model. A head whose primary was replaced by a verifier on another model (after a crash or a refusal) is not full. Its rows stay in the ledger with that model.

## Ledger

The root keeps `~/.xum/analysis/verifier-shadow/ledger.tsv`. On first use it creates the file with this header row:

```
date_utc	repo	pr	head_sha	model	task_id	verdict	cost_usd	wall_min	brief_prs	blockers	later
```

1. The root writes the rows of a verifier when its task ends for any reason: it gave its last report, after the root asked again for any missing `VERDICT` line, or the root stopped it, or it failed. It writes one row per PR head of the brief. The root writes no row for an interim report or a question.
2. `verdict` is `PASS`, `ISSUES`, or `none` when the verifier ended without a `VERDICT` line for that head.
3. `cost_usd` is the verifier's subtree cost from `session-usage.json` when its task ends. `wall_min` is the minutes from the brief to the end of the task. `brief_prs` is the number of PRs in that brief. The rows of one verifier for one brief repeat the same cost and wall time, so divide by `brief_prs` before summing.
4. `blockers` lists each finding that the verifier named, each with its blocker class, and marks the ones it gave as a reason for ISSUES.
5. Until the cutoff of a head, the root adds each blocker that a later review or commit shows on that head to `later` on every row of that head. When it writes a row after such a blocker, the row gets the same `later` value. The root leaves `blockers` as it is. The cutoff of a head is the moment someone merges or closes its PR, or the moment the root sends an early report because he ended the study, whichever comes first. A blocker found after the cutoff does not change the ledger.

## Final report

Phase 2 starts with the first verify brief after this rule adds the Opus shadow. Its cohort is the first 30 full heads of phase 2, in the order in which the root writes the last row of each head. When the root writes the last row of the 30th full head, the root sends no more briefs to shadows and stops every shadow that is still running. The heads of those shadows are not full. The root reports when the cutoff of each head in the cohort has passed. When he ends the study early, the root first stops every study verifier that is still running and writes its rows. Then it reports at once, and the moment it sends that report is the cutoff for every open PR.

The report holds:

1. Correct verdicts, false blocks and misses for each model, counted over the full heads of the cohort only.
2. Valid blockers that only one model found, on the full heads of the cohort.
3. Cost and wall time for each model, over its rows on the full heads of the cohort.
4. The heads that were not full, with the model and the reason: shadow missing, shadow stopped, shadow failed, shadow ended without a `VERDICT` line, primary stopped, failed or ended without a `VERDICT` line, or primary on another model.

Phase 1 (Sonnet and gpt-6.1-sol only) is judged in `~/.xum/analysis/verifier-shadow/phase1-2026-11-08/live_judgment.md`: over 53 heads, Sonnet 43 correct, 6 false blocks, 4 misses, and gpt-6.1-sol 38 correct, 11 false blocks, 4 misses. The earlier baseline is the replay of 17 frozen PR heads in `~/.xum/analysis/verifier-shadow/replay-2026-11-07/`. Its `JUDGE.md` and `JUDGE_W2.md` used looser terms, and `rescored-strict.json` scores it again with the terms above: Sonnet 9 correct, 3 false blocks, 5 misses, and gpt-6.1-sol 11 correct, 5 false blocks, 1 miss. After the report, the root asks him which model the verifier role uses, which shadows to keep, and whether to remove the study rule from `SKILL.md`.
