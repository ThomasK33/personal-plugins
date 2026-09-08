# Learn and remember a repository's review policy

Use this when the repository's review gates or merge authority are not yet known, or when a saved policy conflicts with current instructions. Onboarding configures the workflow once per repository; it is not a per-PR human-approval step.

## Read before asking

Identify the repository by its canonical host, owner, and repository name, with the relevant target branch or branch class. Load its saved policy and read applicable repository instructions, contribution rules, and available branch protection or ruleset settings. Use choices already supplied in the task. A fork or another repository does not automatically inherit the same policy.

Ask only about missing or conflicting choices. If the user has already said that a completed Codex review reporting no issues permits the agent to merge, record that choice rather than asking them to repeat it. Missing protection settings alone do not establish merge authority.

## Ask a compact onboarding question

Adapt this question to the known facts:

> What review and merge policy should I use and remember for this repository? I found these existing gates: [observed rules]. Please confirm the reviewer and passing result, any additional required checks, and whether I should merge automatically once those gates pass or leave merging to you.

The answers should establish:

- The designated review source and the result that passes, such as a completed Codex code review explicitly reporting no issues.
- Required CI or other checks, including any requirements beyond enforced repository settings.
- Whether the agent may merge automatically after the gates pass, needs separate per-change merge authorization, or should leave merging to a person. Keep this separate from who reviews: a repository can require human review and still authorize the agent to merge afterward.
- Any repository-specific merge method or phase grouping rule that differs from the existing task context.

Offer a known policy as a suggested answer when useful. Do not turn this into a mandatory questionnaire or re-ask facts already established. Continue independent planning or implementation while awaiting an answer, but do not perform a merge whose authority is unresolved. A timeout is not an answer.

## Persist the confirmed policy

Use the agent's supported persistent memory, scoped to the canonical repository identity and applicable branches. Record the confirmed choices, their source, and confirmation date so a later task can reuse them. If memory writes require explicit consent in the current environment, collect it within the same onboarding exchange. Do not store an inferred preference as a confirmed answer.

A compact policy note can contain:

```text
Repository and target branches: [canonical identity and scope]
Review gate: [review source and exact passing outcome]
Other gates: [repository checks and any additional requirements]
Merge authority: [automatic after gates / per-change merge authorization / human executes]
Merge grouping and method: [phase boundary and repository workflow]
Confirmed by: [user response or authoritative repository instruction, date]
Sources to recheck: [relevant instruction files and repository settings]
```

Store policy, not credentials, tokens, or fabricated approval records. Permission to merge automatically under named conditions can be remembered; a human approval of one PR must not become blanket approval of future revisions. Do not generalize one company's human-approval requirement to unrelated personal repositories.

If persistent memory is unavailable, say so and provide a compact reusable policy note. Do not claim it was saved, silently commit a personal policy file to the repository, or modify branch protections as part of onboarding.

## Reuse without adding friction

On subsequent tasks, apply the saved choices without repeating onboarding. Check for relevant changes in repository instructions and effective gates before merging. Current user instructions and enforced controls take precedence over stale memory. Ask a focused question only when a material conflict or missing decision remains, then update the saved policy with the confirmed change.

For the policy "Codex reports no issues, required checks pass, then the agent merges," a completed clean review of the current candidate and passing applicable checks are sufficient. Do not add a separate human confirmation or require a formal GitHub `APPROVED` review event unless the repository actually requires it. An absent, unfinished, failed, or stale review is not a clean result.

For a repository that requires human approval, retain that requirement and verify it for the candidate being merged. The workflow is tailored to the repository; its review and merge evidence must still reflect the actual candidate.
