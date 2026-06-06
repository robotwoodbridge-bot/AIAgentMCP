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