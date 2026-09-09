---
name: deliver-reviewable-changes
description: Use when planning or implementing code changes, including requests to implement a plan or continue existing work. Choose small, reviewable increments before coding so an entire plan does not become one oversized PR. Applies in both planning and execution, whether or not a PR is mentioned, and when preparing changes for review.
---

# Deliver reviewable changes

Read before planning or coding, including when executing an approved plan. Deliver small changes with stable review targets. A small, cohesive task may need only one PR.

Read the repository instructions and saved review/merge policy, and inspect existing work before editing. In planning mode, define the increments without implementing them. In execution, reuse agreed intent and choose any missing delivery boundaries without restarting plan approval. Follow the task's scope and existing authorization.

## 1. Split before coding

Choose each increment's purpose, prerequisite, validation, and stopping point. Stack dependent changes on their actual prerequisites; independent changes can use separate branches or stacks. Keep necessary tests and correctness protections with the behavior they support. Each layer must leave a usable system after its prerequisites land, even if later work is delayed. Do not implement the whole plan on one branch and split it afterward.

## 2. Freeze each established layer's scope

Once you commit a delivery increment or create its stacked PR, freeze that layer's scope; draft status does not waive the boundary. New functionality, refactors, and optional cleanup belong in another layer. Limit subsequent edits to review fixes, CI fixes, and necessary integration updates. If a finding requires substantial redesign, explicitly reopen that layer and refresh its review instead of quietly expanding it.

Freeze scope, not commit hashes. Fix the owning layer, propagate changes to affected descendants, inspect their resulting diffs, and refresh invalidated review and check evidence.

## 3. Stabilize from the bottom up

Prioritize the lowest unfinished layer: complete its implementation, address review findings, and get its required checks passing before spending more effort extending dependent work. Then move upward. An unresolved prerequisite design takes priority over adding more layers that depend on it. Make readiness visible in the existing PR or task record; waiting for a review or check need not stop independent work.

## 4. Parallelize where dependencies allow

When parallel work is authorized, continue independent changes or upper layers with stable prerequisite contracts. Keep clear ownership of each layer and coordinate lower-layer fixes with affected work. Avoid competing edits or stack rewrites. If a prerequisite changes, reconcile dependent work and refresh its evidence before calling it ready. Do not deepen a stack merely to keep workers busy.

## 5. Merge with the configured gates and phase boundary

Apply the repository's review and check gates to each current candidate. A completed Codex review reporting no issues can be the review gate; require human approval only where the policy requires it. When automatic merging is authorized, proceed once the applicable gates pass without another confirmation.

Stabilize PRs bottom-up, then merge the completed phase together. Identify that phase's members and last PR; later phases in the same stack do not hold it up. If no phases are named, use a bounded deliverable as the group. Confirm every member is ready and validate the combined result before merging. Follow the stack tool's dependency order and actual merge guarantees; pause when a required gate becomes invalid.

## Load supporting guidance only when needed

- **Unknown or conflicting gates/merge authority:** use [repository onboarding](references/repository-policy.md), ask only about missing choices, and remember confirmed answers for that repository.
- **A difficult split, repeated review rework, or a phase merge:** read [delivery details](references/delivery-slices.md).
- **Drafting or updating a PR body:** read [PR descriptions](references/pr-descriptions.md). Lead with the changed behavior, consequential review questions, and actual validation.
- **Consequential behavior or uncertainty about adequate evidence:** select relevant [review prompts](references/review-prompts.md).
- **Stack operations:** use the installed `gh-stack` skill when that is the repository's tooling; otherwise use its existing workflow. This skill requires no particular stack tool.
- **Explaining or revising the approach:** read [design rationale](references/design-rationale.md).

Finish with the requested outcome, observed validation, and any remaining blocker. Keep routine work light and report evidence honestly.
