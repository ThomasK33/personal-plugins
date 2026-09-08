---
name: deliver-reviewable-changes
description: Read before planning or executing substantial features, refactors, migrations, or other code changes spanning multiple components or behaviors, even when no PR is mentioned. Helps prevent oversized PRs and repeated review rework by defining independently shippable increments, validation, and human review decisions early. Also use when scope grows during implementation or review, or when preparing a PR or completing a stack.
---

# Deliver reviewable changes

Read this skill before planning or making substantial code changes. Make reviewability a constraint on the implementation: choose a useful delivery boundary, keep the change understandable, and establish how its consequential behavior will be checked. Carry those decisions through implementation, verification, and the human review handoff. The PR description records the resulting decision and evidence.

This skill brings together a risk-based review framework, lessons from ClawSweeper, and engineering review prompts. Read [design rationale](references/design-rationale.md) when explaining or revising the policy; the skill works without access to the original documents.

## Work within the task

Read applicable repository instructions, contribution rules, the PR template, and existing approval requirements. Identify the intended base and inspect existing local work before choosing the next increment. When changes already exist, inspect the complete candidate diff, including configuration, migrations, dependencies, generated artifacts, and uncommitted work. Use existing task context before asking for missing information.

Enter at the task's current stage. For planning only, define the increments and validation approach without starting implementation. For implementation, establish the next increment before coding, monitor its boundary as work develops, and carry authorized work through verification and review preparation. If implementation is already underway, assess the actual change and recover a useful boundary where needed. For a description-only task, describe the actual change and flag gaps without starting implementation. This skill does not itself authorize publishing, requesting reviews, posting comments, changing repository controls, or merging. When preparing a PR whose publication is not authorized or available, deliver the title and body locally and state what remains.

## Before coding: shape the next increment

State the problem and intended before/after behavior. Find the existing implementation, relevant callers, and established abstractions before adding a new concept. Confirm that the solution addresses the requirement rather than merely matching a proposed implementation.

Resolve consequential uncertainty about product behavior, interfaces, security boundaries, or architecture before building substantial code on it. Present the exact question and realistic options; continue independent work. Existing agreed decisions satisfy this step. Ordinary implementation choices do not need another approval ritual.

A phase is a milestone; a PR is one independently safe, reviewable change. For substantial work, choose delivery boundaries before implementation using [delivery slices](references/delivery-slices.md). State the next PR's behavior or invariant, immediate base, included validation, and completion boundary. Prefer the smallest useful step that can merge and leave a usable system without needing a later fix. Do not implement an entire phase first and rely on its description or commit organization to make it reviewable.

Separate behavior-preserving extraction from new scheduling, persistence, or product behavior when each can stand safely on its own. Keep a correctness prerequisite and its tests with the change that requires it, or land that prerequisite first. Put adjacent hardening on its own track unless it is necessary for the current change's safety. Split by concern, not arbitrary line or file counts; do not postpone required tests to a later PR.

Use sequential PRs or a shallow stack for dependent changes, following the task's authorization and repository workflow. Keep the active chain short, base each layer on its actual prerequisite, and put review fixes in the layer that owns the concern. Choose merge groups by phase: when a stack represents one phase, aim to merge all PRs belonging to that phase together after every member is ready. Identify the phase's PRs and its last PR. Ready members wait for that phase's completion, not later phases that may share the stack. If no phases are defined, use a bounded deliverable as the merge group. Each layer must still be independently safe after its prerequisites. Do not rewrite shared history or start additional workers merely to apply this skill.

During implementation, use the chosen boundary to decide whether each discovered concern belongs in this increment or needs a separate one. Reassess when new evidence changes its prerequisites. Prefer familiar code and narrow interfaces that make behavior traceable. Record non-obvious invariants and design reasons close to the code. Remove avoidable indirection, duplicate implementations, and scope drift. Identify the source and regeneration method for generated changes and check the output. Neither a small diff nor a generated file establishes low risk.

## Choose evidence early and gather it during implementation

Before implementing consequential behavior, identify its claims and choose evidence for each. Gather that evidence as the change develops and refresh it for the completed candidate. Use [review prompts](references/review-prompts.md) to select relevant questions; do not copy the entire checklist into every PR.

- Derive expected outcomes from the requirement or an independently established invariant. Tests that repeat the implementation's assumptions or assert that a field exists do not establish the desired behavior.
- Use the appropriate combination of inspection, static checks, targeted tests, integration exercises, and runtime observations. Reproduce a reported bug and show the changed outcome when practical. Apply repository requirements, but do not add tests for a trivial reversible edit solely to populate a template.
- Match proof to the claim. A UI screenshot can show layout; a protocol trace can show an exchange. Neither proves an unrelated authorization or concurrency property. Use a real integration when that boundary is material and accessible. If unavailable, state the gap and its consequence; do not present mocks as equivalent proof.
- Record observed results, the tested revision or local change state, and material environment limits. Distinguish passed, failed, not run, unavailable, and stale evidence. Never infer a check passed from its existence or invent a CI run, measurement, artifact, or reviewer verdict.
- Link relevant results where the intended reviewers can access them. Include concise commands and outcomes when no shared artifact exists. Exclude credentials and private customer data; do not introduce a new upload destination just to add proof.

Run checks required by the repository and those justified by the change. Once they pass, broaden testing only for a new change, failure, or unresolved concern. Coverage and agreement between agents are signals to inspect, not measured probabilities of correctness.

## Review the candidate as its author

Read the final change with surrounding code and mainline behavior in mind. Check the relevant concerns from the prompts, fix concrete problems within scope, and identify anything that still needs another person's decision. Inspect changed dependency calls and their contracts, not just the local function.

For each consequential concern, separate the supported behavior from the uncertainty and explain the possible consequence. A material item that was not assessed must remain visible. Explain consequential exclusions; routine irrelevant categories can be omitted. Mandatory company controls cannot be classified away.

Group duplicate findings, remove resolved noise from the current brief, and preserve significant dissent even when other reviewers or agents disagree. Distinguish blocking concerns, decisions, and optional suggestions. Re-read your feedback for accuracy, tone, and value. Recognize a specific useful design choice when it teaches something; avoid generic praise and self-certification.

## Put the important review work near the top

Use the repository's template and fit the information into its sections. Read [PR description examples](references/pr-descriptions.md) when drafting the body. Scale the detail: a routine change may need two sentences and validation; a consequential change needs explicit reasoning and evidence.

Lead the title and opening with the concrete problem and resulting behavior. Put unresolved decisions and consequential review priorities immediately after the summary, before a long implementation inventory. Each priority should tell the reviewer **where to look, what to judge, and why it matters**. Use verified code links or precise paths and symbols, and suggest a reading order when the diff is difficult to navigate.

Include the claims the evidence supports and its material limits. Describe exposure, compatibility, rollout, detection, or recovery where relevant. Explain irreversible effects: reverting code does not necessarily repair changed data or retract disclosed information. Identify a suitable owner or expertise only when grounded in the repository; do not invent approvals or assignments.

For one PR in a larger delivery, state what this slice establishes, what remains for later, its actual base or prerequisite, and why this intermediate state can ship safely. Explain meaningful boundaries rather than copying the whole roadmap into every body.

Write about the final implementation. Remove abandoned approaches and conversational history unless they explain a tradeoff. Avoid file-by-file narration, unsupported risk scores, blanket assurances, and empty sections. Keep detailed logs accessible behind a concise account. Do not commit review reports or other process artifacts unless the task or repository calls for them.

If no special decision remains, say so only within the scope actually examined. Make clear what changed and what was checked; a favorable assessment still needs human approval.

## Keep the review valid through revisions

Treat entering review as a scope freeze. Once implementation is complete and the PR is submitted for review, limit changes on that branch to addressing review findings, fixing CI failures, and necessary integration updates within the agreed scope. Continue new feature, refactor, or cleanup work on separate branches; an approved PR is not a place to accumulate the next increment. If a finding requires substantial redesign, explicitly reopen implementation and review the new scope instead of disguising it as a routine review fix.

After repairs or rebases, inspect the delta, refresh affected evidence and the PR body, and say what earlier conclusions became stale. In a stack, fix the owning layer and update affected descendants; check their actual bases, diffs, and validation again. Preserve prior review history in the existing review system. Do not erase a consequential disagreement or mark someone else's concern resolved solely because code was pushed.

Treat repeated substantive review corrections as a scope signal. After two such rounds, or sooner when fixes keep introducing new protocols or concerns, reassess the boundary before another broad repair pass. Narrow the slice, separate unrelated work, or explain why the remaining correction belongs here. Routine comments, infrastructure retries, and waiting for checks do not count. Reassessment guides continued work; it does not waive findings or require abandoning a still-coherent fix. Use diff size as another review-effort signal, never as a safety score.

This workflow requires human approval for every in-scope change. Treat a new head commit as needing renewed approval of the completed candidate, and flag relevant changes to its base context or evidence. An instruction to begin repairs, an agent verdict, or an agent using a person's credentials does not approve code produced afterwards. Preserve existing reviewer eligibility, independence, code-owner, and release controls.

Automation may execute an already authorized merge only when valid human approval and all repository gates cover the current candidate. Do not change controls or fabricate approval evidence. The authoring skill prepares the decision; enforcement belongs to the repository and release system.

Before merging a phase, confirm that every PR in its merge group has finished implementation, addressed blocking findings, obtained current reviewer approval, and passed all applicable CI checks. When Codex review is the designated automated reviewer, obtain its approval for each candidate and track it separately from human approval. Also validate the combined result through the phase's last PR. Scope the repository's stack merge or queue workflow to that group; follow its dependency order and actual atomicity guarantees. A new commit or invalidated gate requires refreshed readiness, even after some layers have landed. Read [delivery slices](references/delivery-slices.md) for the review and merge handoff.

Finish with the outcome appropriate to the request: a scoped delivery plan for planning work, or the prepared PR or local title/body for completed implementation and PR preparation. Include the actual validation outcome and any remaining human decision or evidence gap. The reviewer should be able to find the important question without reconstructing the entire change first.
