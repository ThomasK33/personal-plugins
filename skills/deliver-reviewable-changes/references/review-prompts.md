# Select review prompts by the change

Use these prompts to find the evidence and decisions relevant to this candidate. They cover code and design review through the risk framework. They are not a mandatory list of experiments or PR headings.

For a consequential question, retain a short account of the claim, supporting evidence, uncertainty, and next action. If a material question cannot be assessed, say so. Explain a non-obvious decision that a category is inapplicable. Do not create a repository tracking file just to store this working analysis.

## Before committing to a design

For new concepts, interfaces, or product rules, establish the problem and acceptance criteria. Does the proposed design solve that problem using the system's existing concepts where practical? Are the interfaces sufficient and understandable to their callers? Will a user understand the behavior and available actions? What performance or scale assumptions does the design make, and how could they be checked?

Surface unresolved intent before substantial implementation depends on it. Record the agreed reason near the relevant design or PR discussion. For an existing implementation task, use the accepted design rather than reopening settled choices without new evidence.

## Behavior and integration

Follow the changed path into its callers and dependencies. Check arguments against the actual API contract, including failure behavior and version assumptions. Examine boundary inputs, missing values, error propagation, compatibility, and whether the result solves the reported problem. Compare with mainline behavior when a regression is plausible.

For a bug fix, a reproducer with an expected outcome is useful evidence. A service starting successfully demonstrates startup only; it does not demonstrate a changed message route or permission rule.

## Concurrent or background work

When shared state or asynchronous work changes, identify the invariant and which lock or other mechanism protects it. Trace who starts, cancels, and waits for goroutines, threads, or tasks. Examine interleavings, shutdown, retries, partial failure, and resource cleanup where relevant.

Targeted tests, a race detector, or an execution trace can support this reasoning. A successful stress run does not by itself establish that every interleaving is safe. Point the human reviewer to the unresolved invariant or lifecycle question.

## Authority and data boundaries

When access, authentication, exported data, or trust boundaries change, identify the actor, resource, and permission being exercised. Examine denial paths and cross-account or cross-tenant behavior where relevant. Check what is logged or returned on failure.

A one-line authorization change can require focused review. A test that proves a permission field exists is weaker than an observation that an unauthorized actor is denied. Unspecified product policy needs a decision from its owner; an agent should not silently choose a permissive interpretation.

## Completeness and testing

Check required behavior, documentation, tests, compatibility work, and operational changes together. Choose tests at the level of the claim: isolated logic, integration boundaries, or a complete user/system path. Inspect expected outcomes and meaningful failure cases, not only test counts or coverage.

Separate insufficient proof from a test failure and from a tool that failed to run. Report the reason and the missing conclusion. If a required environment is unavailable, complete independent checks and identify the remaining integration work.

## Capacity and recovery

When a hot path, unbounded collection, fan-out, query, or external call changes, check the relevant scale assumptions and resource limits. Measure against a meaningful baseline when performance is part of the claim. Do not promise unchanged performance without appropriate evidence.

For migrations, configuration, dependencies, and deployment changes, examine compatibility during rollout and what detects a failure. Explain how to stop exposure and what cannot be undone. A rollback command is not proof that previous data or external effects will be restored.

## Maintenance and review experience

Examine names, explanations, encapsulation, clarity, extension points, complexity, size, and failure handling. Identify an existing capability before introducing an alternative. Distinguish source changes from generated output while checking both for consequences.

Read the final PR as someone who did not participate in implementation. Make the needed decision and evidence easy to locate. Remove duplicate or obsolete feedback, distinguish requirements from suggestions, and explain whether follow-up review is needed. Specific recognition of a useful pattern supports shared understanding; generic praise adds noise.
