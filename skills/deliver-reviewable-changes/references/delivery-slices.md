# Deliver a milestone through small PRs

Read this when the work spans several concerns, a branch is growing difficult to review, review fixes keep widening its scope, or a stack is approaching review and merge. A broad task can have one purpose and still need several independent review decisions.

## Choose the next safe increment

Before substantial implementation, sketch the likely delivery sequence in the existing plan or task discussion. For the next PR, identify:

- The single behavior, invariant, or behavior-preserving extraction it establishes.
- Its immediate base and the prerequisite contract it actually relies on.
- The production change, required callers, tests, and operational work needed for that increment.
- The adjacent concerns deferred to another PR and why their absence leaves this increment safe.
- The evidence and approval needed to land it, and where implementation should stop adding scope.

For phased work, identify which PRs complete the current phase and its last PR. That phase defines the coordinated merge group; the branch stack records dependencies. If there are no named phases, use a bounded deliverable as the group rather than assuming every branch in a stack must merge together.

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

Use sequential PRs when later work cannot proceed reliably until the prerequisite lands. Use a shallow stack when a validated prerequisite provides a stable base and dependent review is useful. A practical starting point is two or three unmerged layers. Define the current phase's merge group before adding dependent work, bring each layer through review promptly, and hold ready members for that phase's coordinated merge. A stack spanning later phases must not delay a finished phase solely because it has more branches. Reconsider adding depth when changes at the bottom repeatedly invalidate work above it.

Independent concerns do not need to wait in the same stack. Avoid starting downstream implementation against unresolved interfaces; independent investigation can continue. Plan and branch by concern before writing the whole milestone into one branch.

For each layer, inspect the diff against its immediate parent. Check its expected integrated state as well: a small layer diff does not prove that the cumulative result is safe. Put review fixes in the owning layer, propagate the update, and refresh affected evidence and human approvals. After a lower PR merges, reconcile the remaining branches with the actual merged result using the repository's workflow. Do not assume a rebase or a nominal base label produced the intended diff.

Follow available repository tooling for stack mechanics. This skill does not require a particular CLI, install extensions, or grant permission to push, merge, or rewrite shared history.

## Freeze implementation scope when review starts

After implementation is complete and a PR enters review, its author focuses on review findings, CI failures, and necessary integration updates for that agreed change. A draft opened for visibility is still in implementation until the author declares it ready for review. New capabilities and discretionary cleanup belong on other branches, not in the review candidate.

Other authorized agents may continue the remaining PRs in the phase against a stable prerequisite. Work on later phases belongs on separate branches and does not extend the current phase's merge group, even if those branches share its stack. Changing the phase boundary is an explicit scope decision, not an incidental branch addition.

Keep valid correctness findings with the layer that owns them, even during the freeze. If a fix changes the prerequisite contract, notify dependent work, update affected layers, and refresh their evidence and approvals. Substantial redesign returns the affected PR to implementation; update its scope and re-enter review when complete. The freeze protects the review target and never excuses an unresolved defect.

## Finish and merge the phase together

When a stack represents an entire phase, aim to merge that phase's changes in one coordinated operation after every PR is ready. Preparing one member for merge does not mean merging it while the remaining PRs in that phase are still being implemented. If the stack also contains later phases, stop at the current phase's last PR. Preserve dependency order and ensure all prerequisites are already landed or included in the approved merge group. Every intermediate state must remain safe if integration pauses.

Use the existing stack or PR record to make readiness visible. For each layer, identify its current head, immediate base, implementation status, blocking findings, reviewer approval, human approval, and CI result. When Codex review is the agreed automated gate, require its current approval; unavailable review is a visible gap. Agent review does not satisfy this workflow's separate human-approval requirement.

Before beginning the merge, confirm all PRs in the phase's group are ready and that the combined result through its last PR has the relevant integration evidence. A green last PR does not establish the review or CI status of earlier members. Freeze that set for the merge attempt and scope the repository's stack merge or queue operation to it. An unready later phase is not a blocker for this group unless it exposes a missing correctness prerequisite.

Follow the tool's documented ordering and atomicity. Some tools can merge a set atomically; a queue or sequential workflow may land it in parts. If a later candidate changes, loses valid approval, or fails a gate, pause further merges and refresh readiness. Report any layers already landed; do not force the remainder to preserve the appearance of a single operation. This is why each increment still needs a safe intermediate state.

## Notice when the boundary is failing

Signals include unrelated reviewer expertise, several independent invariants, growing compatibility protocols, fixes that repeatedly expose different races, and a body that needs to explain much of the future architecture. Repeated substantive review rounds are a reason to reassess, not proof that a reviewer is wrong.

After two substantive correction rounds, examine what changed and why. Keep necessary fixes with their owner, move separable work into another slice, or state why a focused correction is still the right next step. Ignore retry counts caused only by unavailable infrastructure, check polling, or cosmetic feedback. Do not discard valid findings to reduce the round count.

A team may aim for a few hundred production lines as a review-effort heuristic. Choose that threshold from the system and reviewer context; it is not a universal cap or risk measure. Examine production, tests, generated output, and mechanical churn separately. Preserve meaningful tests and complete protocols even when that makes a PR larger. A tiny authority change can deserve more attention than a large mechanical edit.

## Recover an oversized branch

Preserve committed and uncommitted work before restructuring. Account for useful changes, tests, and outstanding findings by concern; old review-fix commits are often poor PR boundaries. Rebuild the next safe slice from its intended base and verify it independently. Track what was transferred or deferred in the existing coordination record.

Close, supersede, force-push, or delete the old branch only when authorized. Keep enough history to avoid losing a correctness fix during extraction. The goal is a sequence that can land incrementally, not the same coupled change spread across more PRs.
