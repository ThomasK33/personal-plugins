# PR descriptions that support a decision

Use the repository template when present. Put these elements into its existing sections; do not add duplicate headings. Without a template, the following is a useful shape, with sections omitted or combined when they add no information:

1. **Problem and behavior:** the concrete trigger, before/after outcome, and reason for this implementation.
2. **Review focus or decision:** exact location, question, possible consequence, and relevant evidence or gap. Put unresolved consequential decisions here.
3. **Evidence:** the claims established, actual results, tested candidate, and material limitations. A compact table is useful only when several claims need comparison.
4. **Integration and recovery:** compatibility, rollout, detection, or irreversible effects when relevant.

A risk label cannot replace a review question. Instead of "high-risk concurrency change," explain: "Review `Worker.stop`: it now waits for the child task before releasing the lease. Confirm that cancellation can complete while the caller holds the registry lock; otherwise shutdown can deadlock."

Use actual paths, symbols, commits, and results from the task. Do not fabricate links or fill examples with assumed success. The examples below are fictional and illustrate structure only; none of their facts or test outcomes are evidence for a real PR.

## Routine change

**Title:** Clarify when the export starts

**Body:**

> Changes the button text from "Continue" to "Start export" so the action is clear before submission. The diff contains only the label change.
>
> Validation: inspected the rendered dialog at desktop and narrow widths; the label fits. No automated tests added for this copy change. Human review and approval are pending.

Use such a body only if those observations were made and repository checks are satisfied. If the screen was not viewed, state that limitation instead. No standard requires this exact wording or a fixed number of sentences.

## Consequential change with an unresolved decision

**Title:** Add a customer data export endpoint

**Body:**

> Adds an export route using the existing serializer, so customers can download the same record format already used by the reporting service.
>
> **Decision needed before approval:** Product policy does not specify whether suspended accounts may export. Review `authorizeExport` in `src/export/access.ts` and decide which behavior is intended. The current draft denies suspended accounts; that provisional choice requires agreement and matching evidence before this candidate is ready for approval.
>
> **Review order:** Start with the authorization rule, then `handleExport`, then the denial-path tests. The serializer is reused, so the new boundary is who can request an export and how that request is bounded.
>
> **Evidence for the current draft:** Cross-tenant requests were denied in the integration environment; representative output matched the existing format. Capacity at the largest supported account size has not been measured, so this PR does not establish that bound. Attach the actual commands, revision, and accessible results here.
>
> **Recovery limit:** Disabling the route stops future downloads but cannot retract data already downloaded. Human approval is pending the policy decision, resulting changes, and relevant validation.

The important feature is that the unresolved decision appears before implementation details. The example's provisional policy is not permission for an agent to choose product behavior in a real task.

## One slice of a larger delivery

Explain the increment's boundary and prerequisite without making the reviewer reconstruct the whole milestone. For example, when supported by the actual change:

> Keeps an execution lease while the eager compaction promise is running, so shutdown can still find and await that work after a semantic reset.
>
> Review the lease acquisition and release around `startEagerCompaction`, then the held-work reset/shutdown tests. This PR preserves turn admission and continuation scheduling. Coordinator extraction and durable persistence changes are separate increments.
>
> Base: the current main branch. The fix uses the existing lease contract and can ship without the later extraction. Validation and human approval must cover this candidate.

For a dependent layer, identify its actual parent PR and what contract it consumes. Include its own required tests. Do not claim the whole milestone is delivered, or that the layer is safe, solely because the parent passed review.

## Revision after review

Keep the current body accurate and preserve the earlier discussion in the review system. When an update is authorized, a concise delta can read:

> Since the reviewed candidate, cancellation now waits for the export worker to release its lease. Please re-review `ExportJob.cancel` and the shutdown test. The earlier shutdown result is stale; the focused test passed on the new candidate, while full integration validation is still pending. The new commit needs renewed human approval.

Replace this with the actual delta and observed state. Permission to address feedback does not authorize erasing a reviewer's concern, declaring their approval current, or posting an otherwise unauthorized message.

## Avoid common ways to hide work

- Do not lead with a list of files when the reviewer needs a behavioral explanation.
- Do not bury a failing check, an untested migration, or a product decision beneath successful checks.
- Do not claim "safe," "fully tested," or "low risk" solely from a short diff, generated code, green CI, or agreeing agents.
- Do not paste every prompt, log, or internal implementation step into the body.
- Do not add a boilerplate security, rollback, or performance claim when that property was not examined.

Any significant limitation should name its consequence and next action. A brief with explicit limits is more useful than a confident summary the evidence cannot support.
