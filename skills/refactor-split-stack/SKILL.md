---
name: refactor-split-stack
description: Splits long methods or a large file into small named steps with no behaviour change, delivered as stacked PRs that sub-agent workers write and the parent lands. Use when planning or running a behaviour-preserving refactor across several stacks, such as lowering cyclomatic complexity method by method, or splitting a service into owners.
---

# Refactor split stacks

One stack per method. The parent writes briefs, applies patches, opens and lands the PRs. Workers only commit.

## Pipeline per stack

1. **Map** (read-only sub-agent, at a named commit): phases in order, same-tick and lock-order invariants with their comments, mutable locals shared across phases, the proposed steps with their CC, line coverage per step, and the changed-line estimate per PR.
2. **Plan** with the `html-plan` skill. A suspected bug that the map finds gets reproduced before it becomes a decision. A confirmed one is fixed in its own PR before the stack.
3. **Test PR first.** Characterization tests cover every uncovered path of the method and pass on the base. Over 500 changed lines, split it into two test PRs.
4. **Split PRs, tail first.** Each at most 500 changed lines, each green on its own, and every new function CC 8 or less.
5. **Hand-mutation pass** of the new steps against the suites that drive the method. The repo's mutation gate picks suites by import, which can miss the method. Report each survivor as killed, equivalent, or a gap. A gap becomes one extra tests-only commit below the split.
6. **Review.** Codex on every PR, then one clean-context advisor before the stack's merge decision (the AGENTS.md advisor rule; the stack is the unit you decide): a fresh `exec` on a judgment-tier model, given the goal, the diff, the findings and the test results only.
7. **Land** with `gh stack link` and `gh stack merge <stack#> --yes`. Watch every member until it is merged or removed from the queue.

## Briefs

- One shared brief of hard rules plus one brief per layer. After each stack, add its lessons to the shared brief as hard rules.
- Put every plan limit in the brief as a command whose output the worker reports: `git show --numstat`, `make crap-check BASE=<parent>`, the targeted test list, the typecheck, `make static-check`. A limit that lives only in the plan gets broken.
- Use absolute paths. A child cannot read the parent's scratch folder.
- The worker commits and does not push. The parent applies the patch, rebuilds each branch on a fresh `origin/main` by cherry-pick, and opens the PRs.
- A worker's optional commit built with `git commit-tree` has no ref. Pin it with a branch before you remove the worker.

## Splitting async code without a behaviour change

- Every await stays where it was. A step with no await is a sync function, because an `async` wrapper adds a microtask.
- Each step calls the next one directly after its own last await.
- Inside a lock or `await using` scope, every step call is `return await` or returns a plain value. A bare `return promise` releases the lock early.
- Shared mutable locals go on one record passed by reference. Snapshots go in readonly records.
- Keep the instance calls that tests spy on, by name.
- Prove it with an old-versus-new trace over the test scenarios: calls, reads, awaits and lock events, each with its microtask stamp. Report every drift, such as a later release.
- A timeout in a suite that a timing-shifting split touched needs a base-versus-head rerun before you call it a flake.
