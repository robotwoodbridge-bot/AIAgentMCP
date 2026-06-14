---
name: qa-review-assistant
description: >
  Analyze Azure DevOps Pull Requests and Work Items to produce a QA-focused review: a prioritized list of areas of concern and a set of non-redundant, high-level test case suggestions. Use this skill whenever a QA engineer (or anyone) provides an ADO PR link, PR ID, Work Item ID, or asks to review code changes for testing purposes. Trigger on phrases like "review this PR", "what should I test", "analyze this work item", "QA review", "test cases for this change", "areas of concern for", "what are the risks in this PR", or any time someone wants to understand the testing implications of a code change. Always use this skill even if the user just pastes an ADO link or ID with no extra context.
---

# QA Review Assistant

Helps QA engineers quickly understand the risk profile and testing surface of a code change by pulling data directly from Azure DevOps and producing a structured, actionable review.

## What this skill produces

1. **Areas of Concern** — ranked Critical / High / Medium / Low, focused on non-obvious risks (data integrity, auth/permission boundaries, edge inputs, regression surfaces, integration points)
2. **Suggested Test Cases** — high-level, non-redundant cases written in plain English AND formatted for Azure DevOps Test Case import
3. **Downloadable ADO Test Case file** — an `.xlsx` ready to import into Azure DevOps Test Plans

---

## Step 1: Fetch ADO Context

Use the ADO MCP tools to gather context. Always fetch both the work item AND the PR when possible.

### If given a PR ID or PR link:
```
ado:repo_get_pull_request_by_id  → get PR title, description, linked work items, reviewers
ado:repo_list_pull_request_threads → get review comments (often contain context about intent or known risks)
```

Then resolve linked work items:
```
ado:wit_get_work_item  → for each linked work item ID, get title, description, acceptance criteria, repro steps
```

### If given only a Work Item ID:
```
ado:wit_get_work_item  → title, description, acceptance criteria, repro steps, state
ado:search_workitem    → find related items if the description references them
```

Then **always attempt to find linked PRs**, even if only given a Work Item ID:
```
ado:repo_list_pull_requests_by_commits  → check if any PRs are linked via commits
ado:repo_list_pull_requests_by_repo_or_project (filter by work item) → find associated PRs
```

If a linked PR is found, fetch it fully:
```
ado:repo_get_pull_request_by_id        → PR title, description, changed files, author
ado:repo_list_pull_request_threads     → reviewer comments — often surface risks the AC misses
```

### What to look for in PR data that AC often misses:

PRs frequently reveal implementation choices that create testable risks not captured in acceptance criteria. Specifically look for:

- **Files/services changed beyond the stated scope** — e.g. AC says "update the download button" but the PR touches shared auth middleware or a base service class. This is a regression signal.
- **Database or schema changes** — migrations, new columns, index changes, or query modifications that could affect data integrity or performance.
- **New configuration flags or feature toggles** — need to test both on/off states and the default.
- **Shared utility or helper changes** — any change to a method/class used in multiple places needs regression consideration for all call sites.
- **Error handling gaps** — look for missing try/catch, unhandled promise rejections, or places where failure paths aren't considered.
- **Permission/role checks added inline** — if a dev adds a role check inside a method rather than at the API boundary, it may be bypassable.
- **Hard-coded values or magic strings** — dates, limits, IDs that could break in different environments or time zones.
- **Reviewer comments flagging concerns** — anything a reviewer questioned or asked to revisit is a test target.
- **TODO or FIXME comments in the diff** — known incomplete work that QA should watch.

When PR data is available, add a dedicated section to the Areas of Concern output:
> **⚠️ PR-Specific Concerns** — risks identified from the code changes that are NOT covered by the acceptance criteria.

### ⚠️ If ADO connection fails or times out:

Do NOT silently fail or produce a generic review. Instead:

1. Clearly tell the user: _"I wasn't able to connect to Azure DevOps (the connection timed out / returned an error). To continue, please paste the relevant details below."_
2. Ask them to provide any combination of:
   - PR title and description
   - Work item title, description, and acceptance criteria
   - A summary of what files/services/areas were changed
   - Any reviewer comments worth noting
3. Once they paste the info, proceed with Steps 2–5 using that manually provided context. Note at the top of the review: _"Note: Based on manually provided context — ADO connection unavailable."_

Common ADO connection fixes to suggest to the user:
- Reconnect ADO in **Settings → Integrations** (disconnect + reconnect)
- Verify the organization URL is correct (e.g. `https://dev.azure.com/your-org`)
- If using a local MCP server, restart it

### What to extract and hold in context:
- **Intent**: What is this change supposed to do? (from PR description + work item title/description)
- **Acceptance criteria**: What "done" looks like per the story/bug
- **Changed areas**: What files, services, APIs, or components are touched (from PR diff summary / description)
- **Review comments**: Any concerns already raised by reviewers
- **Work item type**: Bug fix vs. new feature vs. refactor — affects risk profile

---

## Step 2: Analyze for Areas of Concern

Think like a senior QA engineer reviewing the change cold. Focus on **non-obvious** risks. Skip trivially obvious things (e.g. "make sure the button renders") in favor of things a developer might not think to test.

Run two passes:

**Pass 1 — AC-based concerns**: What risks exist in fulfilling the stated acceptance criteria? What edge cases does the AC not account for? What could break in the scenarios the AC describes?

**Pass 2 — PR-based concerns** (only if PR data is available): What does the actual code change reveal that the AC doesn't mention? Look at changed files, reviewer comments, schema changes, shared code touched, and error handling. Surface anything that could affect behavior outside the scope of what QA would naturally think to test based on the AC alone.

Keep these two passes clearly separated in the output — this helps QA engineers quickly see what's "expected testing" vs. "hidden risks from the implementation."

### Concern categories to consider:
- **Regression risk** — what existing behavior could this break? Look for shared utilities, common services, or data models being modified
- **Edge cases** — null/empty inputs, boundary values, large data volumes, concurrent users, timezone/locale issues
- **Security / Auth** — permission checks, role-based access, data exposure, injection risks, token handling
- **Integration points** — downstream services, external APIs, event queues, database constraints
- **Data integrity** — migrations, schema changes, state transitions, rollback behavior
- **Performance** — loops over large sets, N+1 queries, unbounded results
- **PR-specific** *(only when PR data available)* — implementation choices visible in the diff that create risk not mentioned in AC: scope creep in changed files, missing error handling, feature flag states, shared code side effects

### Severity ratings:
| Severity | Meaning |
|----------|---------|
| 🔴 Critical | Could cause data loss, security breach, or production outage |
| 🟠 High | Likely to affect users in a significant or frequent scenario |
| 🟡 Medium | Affects edge cases or less-common paths |
| 🟢 Low | Minor UX or cosmetic risk |

---

## Step 3: Generate Test Cases

Write test cases that are:
- **High-level** — describe the scenario and expected behavior, not step-by-step UI clicks
- **Non-redundant** — don't write 5 variations of the same happy path; cover distinct scenarios
- **Targeted** — tied to the specific change, not generic boilerplate
- **Prioritized** — order by severity (Critical first)

### Plain English format (for inline display):
```
TC-01 | [Severity] | [Short Title]
Scenario: [What is being tested and why it matters]
Given: [Starting state / preconditions]
When: [The action or trigger]
Then: [Expected outcome]
Concern addressed: [Which area of concern this covers]
```

### ADO Test Case format (for the downloadable file):
See Step 4 for the Excel schema.

Aim for **5–15 test cases** depending on the complexity of the change. Quality over quantity.

---

## Step 4: Create the Downloadable ADO Test Case File

Use `openpyxl` to generate an `.xlsx` file importable into Azure DevOps Test Plans.

### Required columns (in this order):
| Column | Notes |
|--------|-------|
| ID | Leave blank (ADO assigns on import) |
| Work Item Type | Always `"Test Case"` |
| Title | Short descriptive name |
| Test Step | Step number (1, 2, 3...) |
| Step Action | What to do |
| Step Expected Result | What should happen |
| Priority | 1=Critical, 2=High, 3=Medium, 4=Low |
| Area Path | Leave blank unless user specifies |
| Assigned To | Leave blank unless user specifies |
| State | Leave null/blank by default (ADO sets on import) |
| Tags | Comma-separated: e.g. `regression; security; edge-case` |

Each test case gets its own rows (one row per step). For high-level cases, 1–3 steps is fine. AC and PR test cases are written as continuous rows with no separator — use the `[AC]` and `[PR]` prefixes in the Title column to distinguish them.

### Python generation script pattern:
```python
import openpyxl
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

wb = openpyxl.Workbook()
ws = wb.active
ws.title = "Test Cases"

headers = ["ID", "Work Item Type", "Title", "Test Step", "Step Action", 
           "Step Expected Result", "Priority", "Area Path", "Assigned To", "Tags"]

# Style header row
header_fill = PatternFill(start_color="1F4E79", end_color="1F4E79", fill_type="solid")
header_font = Font(color="FFFFFF", bold=True)
for col, header in enumerate(headers, 1):
    cell = ws.cell(row=1, column=col, value=header)
    cell.fill = header_fill
    cell.font = header_font
    cell.alignment = Alignment(horizontal="center")

# Add test cases...
# Priority mapping: Critical=1, High=2, Medium=3, Low=4

# Auto-size columns
for col in range(1, len(headers) + 1):
    ws.column_dimensions[get_column_letter(col)].auto_size = True

wb.save("/mnt/user-data/outputs/test_cases_PR<ID>.xlsx")
```

Install if needed: `pip install openpyxl --break-system-packages --quiet`

---

## Step 5: Present the Review

Structure the inline response as follows:

```
## QA Review: [PR/Work Item Title]

**Source**: PR #XXXX | Work Item #YYYY
**Change summary**: [1–2 sentence plain English summary of what changed]

---

### 🔍 Areas of Concern — Based on Acceptance Criteria

| # | Severity | Area | Description |
|---|----------|------|-------------|
| 1 | 🔴 Critical | [Category] | [What could go wrong and why] |
...

---

### ⚠️ PR-Specific Concerns — Risks Not Covered by Acceptance Criteria
*(Only include this section if PR data was available. If no PR was found, note: "No linked PR found — concerns based on AC and work item context only.")*

| # | Severity | Area | Description |
|---|----------|------|-------------|
| 1 | 🟠 High | [Category] | [Risk surfaced from the diff/reviewer comments, not the AC] |
...

---

### 🧪 Suggested Test Cases

[Plain English test cases, TC-01 through TC-N. Tag each with "(AC)" or "(PR)" to indicate source.]

---

### 📥 Download

Test cases are ready to import into Azure DevOps Test Plans.
[present the .xlsx file]
```

---

## Tips & guardrails

- **Don't restate the obvious.** If the work item says "add a Save button", don't write "TC-01: Verify the Save button exists." Focus on what could go wrong.
- **Infer from context.** If a PR touches an auth middleware, flag auth bypass risks even if the work item doesn't mention security.
- **Be concise.** QA engineers are busy. Tight, scannable output beats thorough-but-long.
- **If ADO data is sparse**, note what's missing (e.g. "No acceptance criteria found — test cases based on PR description only") and proceed with what's available.
- **One file per review.** Name the output file `test_cases_PR<ID>.xlsx` or `test_cases_WI<ID>.xlsx`.