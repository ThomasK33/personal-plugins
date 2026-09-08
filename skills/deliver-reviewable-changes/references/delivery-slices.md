# Deliver a milestone through small PRs

Read this when the work spans several concerns, a branch is growing difficult to review, or review fixes keep widening its scope. A broad task can have one purpose and still need several independent review decisions.

## Choose the next safe increment

Before substantial implementation, sketch the likely delivery sequence in the existing plan or task discussion. For the next PR, identify:

- The single behavior, invariant, or behavior-preserving extraction it establishes.
- Its immediate base and the prerequisite contract it actually relies on.
- The production change, required callers, tests, and operational work needed for that increment.
- The adjacent concerns deferred to another PR and why their absence leaves this increment safe.
- The evidence and approval needed to land it, and where implementation should stop adding scope.

Keep the sketch proportionate. A routine fix does not need a separate planning document. If the task already has workers, use this boundary in their briefs and require a scope check before expanding it. This guidance does not itself authorize spawning workers.

Ask whether the application remains usable if this PR and its accepted prerequisites ship while every later PR is delayed. If not, move the required protection earlier, include it here, or redesign the split. An inactive, tested protocol can sometimes land before its callers, but activation must include every caller and protection needed for correctness. A half-enabled protocol is not a safe increment.

## Example: separating a compaction refactor

A compaction milestone might combine physical execution lifetime, coordinator state, continuation arbitration, and durable persistence rules. These fit one milestone but require different correctness arguments.

A useful sequence is:

1. Retain ownership of physical compaction work until it finishes, with focused reset and shutdown regressions.
2. Extract the existing coordinator state while preserving scheduling and waiting behavior, including the tests that establish that preservation.
3. Change continuation handoff rules separately once their ownership and prerequisites are established.

Journal publication and durable cancellation can proceed on a separate dependency track when independent. If a new ownership rule needs a persistence fence to be correct, the fence must ship first or with that rule. Calling a necessary protection "later hardening" does not make the intermediate state acceptable.

This example illustrates boundaries, not a prescribed architecture. Choose boundaries from the actual system and task.

## Limit work waiting on other work

Use sequential PRs when later work cannot proceed reliably until the prerequisite lands. Use a shallow stack when a validated prerequisite provides a stable base and dependent review is useful. A practical starting point is two or three unmerged layers, with the bottom advancing through its required gates promptly. Reconsider adding depth when changes at the bottom repeatedly invalidate work above it.

Independent concerns do not need to wait in the same stack. Avoid starting downstream implementation against unresolved interfaces; independent investigation can continue. Plan and branch by concern before writing the whole milestone into one branch.

For each layer, inspect the diff against its immediate parent. Check its expected integrated state as well: a small layer diff does not prove that the cumulative result is safe. Put review fixes in the owning layer, propagate the update, and refresh affected evidence and human approvals. After a lower PR merges, reconcile the remaining branches with the actual merged result using the repository's workflow. Do not assume a rebase or a nominal base label produced the intended diff.

Follow available repository tooling for stack mechanics. This skill does not require a particular CLI, install extensions, or grant permission to push, merge, or rewrite shared history.

## Notice when the boundary is failing

Signals include unrelated reviewer expertise, several independent invariants, growing compatibility protocols, fixes that repeatedly expose different races, and a body that needs to explain much of the future architecture. Repeated substantive review rounds are a reason to reassess, not proof that a reviewer is wrong.

After two substantive correction rounds, examine what changed and why. Keep necessary fixes with their owner, move separable work into another slice, or state why a focused correction is still the right next step. Ignore retry counts caused only by unavailable infrastructure, check polling, or cosmetic feedback. Do not discard valid findings to reduce the round count.

A team may aim for a few hundred production lines as a review-effort heuristic. Choose that threshold from the system and reviewer context; it is not a universal cap or risk measure. Examine production, tests, generated output, and mechanical churn separately. Preserve meaningful tests and complete protocols even when that makes a PR larger. A tiny authority change can deserve more attention than a large mechanical edit.

## Recover an oversized branch

Preserve committed and uncommitted work before restructuring. Account for useful changes, tests, and outstanding findings by concern; old review-fix commits are often poor PR boundaries. Rebuild the next safe slice from its intended base and verify it independently. Track what was transferred or deferred in the existing coordination record.

Close, supersede, force-push, or delete the old branch only when authorized. Keep enough history to avoid losing a correctness fix during extraction. The goal is a sequence that can land incrementally, not the same coupled change spread across more PRs.
