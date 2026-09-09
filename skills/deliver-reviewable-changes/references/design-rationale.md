# Design rationale

This skill combines a risk-based approach to code review with practical lessons from human and agent collaboration. It is self-contained: its instructions, review prompts, and examples do not require access to the author's working documents or conversation history.

The entry point keeps the delivery decisions together: split before coding, freeze established layers, stabilize from the bottom up, parallelize against stable prerequisites, and merge a ready phase through its configured gates. Detailed prompts, evidence guidance, examples, and onboarding are loaded only for the task that needs them. An available stack-tool skill supplies mechanics; it is not a required dependency.

## Decisions carried into the skill

- **Review concerns risk and ownership.** Direct attention to consequential uncertainty, including complexity and loss of shared understanding. Lines changed indicate reading effort but do not measure the consequences of a change.
- **Claims need relevant evidence.** Evidence must address the changed behavior and the current candidate. A test can agree with an implementation because both inherited the same mistaken assumption. Distinguish a failed assessment from a defect or insufficient proof.
- **Reviewability starts before implementation.** Choose delivery boundaries and evidence early, then carry them through implementation and the PR handoff. An existing change is also a useful entry point.
- **A milestone can need several PRs.** Choose independently safe increments, keep required tests and protections with each increment, and limit dependent work awaiting review. Repeated substantive corrections trigger a scope reassessment.
- **Review needs a stable target.** Once a delivery increment is committed or its stacked PR is created, freeze its scope, including for drafts. Keep fixes with the owning layer and propagate them through the stack. Scope remains fixed even when commit hashes change.
- **Stabilize from the bottom up.** Prioritize making the lowest unfinished layer ready before extending dependent work. Independent work and upper layers with stable prerequisites can proceed in parallel; unresolved foundations should not accumulate more dependents.
- **Merge by phase.** When a stack represents a phase, review its PRs independently and merge the phase's changes together once every member and the combined result are ready. A stack can span multiple phases; later work must not expand or delay a finished phase's merge group. Apply the repository's review and merge gates to every member.
- **The author reduces reconstruction work.** Cohesive changes, explanations of invariants, a reading order, and concise evidence help a reviewer understand the consequential questions.
- **Checklists guide inquiry.** Apply engineering questions according to context, explain consequential omissions, and preserve unresolved questions. A completed checklist is not approval.
- **Learn the repository's policy once.** Read existing rules, ask about missing gates and merge authority, and remember confirmed choices per repository. Reuse them until the user or repository rules change. Do not transfer one company's controls to unrelated repositories.
- **Human approval is conditional.** A repository can authorize automatic agent merging after Codex code review reports no issues and required checks pass. Another can require a person to approve each change. The skill follows that choice without adding its own human-approval step.
- **Automation needs current evidence.** A past review does not establish a revised candidate's result. Refresh affected gates after changes and preserve enforced controls. A saved merge policy records the conditions for action, not an approval of every future revision.

## Delivery lessons

One coherent purpose can still encompass several protocols and independent correctness arguments. A compaction milestone, for example, may involve physical execution lifetime, coordinator state, continuation arbitration, and durable persistence. Review is easier when those concerns become independently usable increments with explicit prerequisites.

Extracting a coordinator can preserve timing behavior while a later PR changes scheduling. A required persistence fence, however, must accompany the behavior that depends on it or land first. The intermediate application must remain usable if subsequent PRs are delayed.

The delivery reference applies these lessons without requiring a particular framework, worker topology, or stack tool. Numerical diff targets and review-round counts are prompts for judgment, not measures of safety.

## Public influences

- [ClawSweeper decision schema](https://github.com/openclaw/clawsweeper/blob/f6b3a613c509c918875d9ad6a0959fdd05359ee8/schema/clawsweeper-decision.schema.json): structured merge concerns, proof assessments, and explicit maintainer decisions.
- [ClawSweeper automerge flow](https://github.com/openclaw/clawsweeper/blob/f6b3a613c509c918875d9ad6a0959fdd05359ee8/docs/repair/automerge-flow.md): review and repair freshness and separation of worker and merge authority.

The skill adopts these ideas selectively. It does not require ClawSweeper, its labels, a universal live-demo requirement, or a proof grade based on media format. It introduces no external tool dependency and does not assume that an author's summary can enforce repository approval controls.
