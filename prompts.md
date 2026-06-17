### Test the Agents - Prompt ###
Act as the QE Lead Agent.

Review this feature:
"As a payroll administrator,
I can bulk import employees
from CSV."

Delegate work to:
- API Specialist
- Security Specialist
- Automation Specialist
- Observability Specialist

Provide a consolidated testing strategy.


========================================================= 
                 Human QE 
                        │
                        ▼
                Claude (Orchestrator) or QE Lead Agent
                        │
        ┌───────────────┼────────────────┐
        ▼               ▼                ▼
   QA Engineer AI   Automation AI      API AI
      (coworker)     (coworker)       (coworker)
        │               │                │
        ▼               ▼                ▼
      Claude        Nemotron       Ollama / local LLM
        │               │
        └─────── Skills / MCP    ────────┘
              │        │         │
            Robot     Docker   CI/CD
             Tests    Control  Pipeline
======================================================== 


### Run All Playwright tests - Prompt ###
Act as the QE Lead Agent

If Terraform already running, skip the start terraform play step.
Start up the local Terraform by executing Terraform play
Wait for the IaC fully ready
then,
Run all the Playwright tests inside the test/ folder against the Terraform IAC environment, for the following browsers
Do not run tests in headless mode; I like to see the steps.
Chrome,
Firefox,

Tear down when done:  using the following command 
`cd infra/terraform && terraform destroy -auto-approve`

**Test Case write to Azure via MCP**
Act as the QE Lead Agent.

Review this requirement and generate manual test cases with steps for automation later.
https://dev.azure.com/robotwoodbridge/robotkali/_workitems/edit/2/

The environment is:
https://practice.expandtesting.com

Delegate work 
- quality engineer Specialist
and other sub-agents

Write the test to Azure test plan modules via ADO MCP

**Review Test Strategy**
Review this quality engineering testing strategy. Compare it against industry standards and best practices. Be direct — flag gaps, weaknesses, and specific improvements I should make. Also assess how practical it is for everyday team usage."

**Email to stakeholder about upcoming release**
Write a professional email to a stakeholder. Keep it concise — no more than 3 short paragraphs, with a professional but direct tone. I'm a Quality Engineering Leader on an HR/Payroll SaaS project, writing to a business stakeholder to communicate an upcoming release that includes a critical payroll fix.

**TODO**
**Artifacts**
1. Risk-Based Quality Gate Matrix = not ready, need rework...
2. Release Readiness Dashboard
3. Incident RCA Template
4. Executive Quality Health Dashboard
5. Quality Gate Simulator = POC

**Release Readiness Report**
Create an artifact that serves as a Release Readiness Dashboard for daily production releases.

**Risk-Based Testing Matrix**
Build an editable artifact containing a 2×2 Risk vs Quality Gate matrix for daily releases.


**Executive Quality Health Dashboard**
Build a React artifact showing executive quality KPIs.

**Incident RCA report**
Create an artifact template for production incident RCA.

**Quality Gate Simulator**
Create an artifact for Quality Gate Simulator for release readiness
