# Robot Framework Test Automation - AI Agent Guide

## Architecture Overview

This is a **Robot Framework** test automation suite for Greenshades Online (GO) product testing, following the **Page Object Model (POM)** pattern. The codebase tests a multi-tenant web application across multiple environments (www, staging, avocado, martian, moss, soylent).

### Core Structure
```
_setup/          # Global test configuration, variables, listeners
_util/           # Shared custom keywords and Python helpers
_pipelines/      # Azure DevOps pipeline definitions
[product]_[module]/  # Product-specific test suites
  ├── pages/     # Page Object Model resources (.resource files)
  ├── tests/     # Test cases (.robot files)
  └── *.resource # Module-specific helper keywords
```

Products follow naming: `core_*`, `ee_*` (employee), `payroll_*`, `tax_*`, `internal_*`

## Critical Workflows

### Running Tests Locally
```powershell
# Install dependencies (prefer pyproject.toml)
uv sync  # or: pip install -r requirements.txt

# Run with environment selection
python -m robot -v env:www ./path/to/test.robot

# Run with tags
python -m robot -i smoke -v env:staging ./tests/
```

Environment variable `${ENVIRONMENT}` is set globally via `_GlobalVariables.py` using `-v env:value` argument.

### Azure Pipeline Execution
Tests run via `_suite_template.yml` which:
1. Installs dependencies from `requirements.txt`
2. Detects test tags via dry run (`--dryrun`)
3. Executes tests with `TestListen.py` listener (captures results to network share)
4. Publishes xUnit results and artifacts

**Tag system**: Tests use tags like `core`, `employee`, `payroll`, `tax` for selective execution.

## Test Development Patterns

### Suite Setup Structure
**ALWAYS** start test files with:
```robot
*** Settings ***
Test Timeout         ${BASELINE_TEST_TIMEOUT} minutes
Resource             ../pages/YourPage.resource

Suite Setup          Start admin test
Test Teardown        Go to    https://${ENVIRONMENT}.greenshadesonline.com
```

### Retry Pattern for Flaky Steps
**Use this for inconsistent operations** (GO is sensitive to rapid JS execution):
```robot
${run}=  Set Variable    ${True}
WHILE    ${run}    limit=3 min
    TRY
        # Your steps here
        ${run}=  Set Variable    ${False}
    EXCEPT    AS    ${error_message}
        Capture Page Screenshot
        Reload page
        Log    ${error_message}
    END
END
```

### Custom Keywords - Performance Optimizations
**Prefer JavaScript-based keywords** from `CustomKeywords.resource` over standard SeleniumLibrary:
- `Get element count JS and Xpath` - faster than `Get Element Count`
- `Faster Wait Until Page Contains` - uses JS DOM search vs Selenium wait
- `Faster element should exist/not exist` - JS validation vs polling
- `Has text via JS` - instant text search

**When to use**: High-volume checks, tight loops, or when standard keywords cause timeouts.

### Environment-Specific Timeouts
Defined in `_GlobalVariables.py`:
- **www (prod)**: `BASELINE_TEST_TIMEOUT` = 5 min, `PROD_TIMEOUT` = 60s
- **Non-prod**: `BASELINE_TEST_TIMEOUT` = 7 min, `NON_PROD_TIMEOUT` = 120s

Use `${ENVIRONMENT}` variable to build URLs: `https://${ENVIRONMENT}.greenshadesonline.com`

## Page Object Model Conventions

### Resource File Structure
```robot
*** Settings ***
Resource    ../../_setup/TestSetup.resource  # Always include

*** Variables ***
${PageElement}    xpath://locator

*** Keywords ***
Action Keyword Name
    [Arguments]    ${param}
    Wait Until Element Is Visible    ${PageElement}
    Click Element    ${PageElement}
```

### Naming Conventions
- **Variables**: PascalCase with module prefix (e.g., `${AHP_EmployeesTab}` for Admin Home Page)
- **Keywords**: Space-separated sentence case (e.g., `Login as admin`)
- **Files**: PascalCase for pages, PascalCase for tests

### Personnel Data
Test employee accounts defined in `_util/Personnel.resource`:
```robot
${ElwoodGarrettEmail}=    c2275507@nwytg.net
${ElwoodGarrettId}=       AFSEG001
${PrimaryAdminLogin}=     qaautomation@greenshades.com
${PrimaryPassword}=       Grshades1
```
**Never hardcode credentials** - use these variables.

## Browser Configuration

### Headless Mode Detection
`Set Browser Options` in `TestSetup.resource` detects Azure build agent via `TF_BUILD` environment variable and automatically enables headless Chrome:
```robot
Open Chrome Browser    ${url}    ${override_headless}=${False}
```

### Chrome Options
- Download directory: `${DownloadDirectory}` (EXECDIR by default)
- Safe browsing disabled for test file downloads
- Auto-open PDFs externally enabled
- Custom window size for headless: 1920x1080

## Python Helper Libraries

### GsSelenium.py
Custom Selenium extensions:
- `Find Element In Table` - searches table cells for text
- `Select Option From Dropdown` - handles both standard `<select>` and custom GS dropdowns (`gs-dropdown`, `gsr-dropdown`)
- `Enter Date In Calendar` - works with PrimeNG calendar widgets

**Use when**: Standard SeleniumLibrary keywords fail with custom controls.

### Other Utilities
- `SpreadsheetKit.py` - Excel validation (`should_contain_text`, `count_rows`, `edit_cell`)
- `PDFKit.py` - PDF comparison and text extraction
- `OutlookLiveEmailHelper.py` - Email verification for auth flows
- `GsTwilio.py` - SMS verification (Twilio integration)

## Key Gotchas

1. **Page Load Auth Block**: Check for `${PageLoadBlockedByAuth}` (empty body) after navigation - indicates SSO redirect issue
2. **Navigation Timing**: Always include `Sleep` after `Mouse Over` for nav menus (0.5-3s depending on environment)
3. **Input Clearing**: Use `Force Clear Input` from CustomKeywords when `Clear Element Text` fails
4. **Mobile View**: Set window width to `${MOBILE_VIEW_WINDOW_SIZE}` (1130px) for responsive testing
5. **Workspace Switching**: Use `Switch workspace` keyword (not direct navigation) to avoid session issues

## Integration Points

### SSO Authentication
Login flow via `core_sso/pages/AdminLogin.resource`:
```robot
Login as admin    ${email}    ${password}
```
Handles retry logic and verification of homepage load.

### Test Listeners
`TestListen.py` (ROBOT_LISTENER_API_VERSION 2):
- Captures suite status
- Copies reports to network share (`\\\\parks\\shares\\QAAutomationFiles`)
- Sends Slack alerts on failure (to channel C05PPFHDM0X)
- Requires `-v send:True` for notifications

### API Testing
Use `RequestsLibrary` for API validation (example in `CustomKeywords.resource` - `Get api request token`):
```robot
Create Session    alias    ${endpoint}
${response}    POST On Session    alias    /path    data=${payload}
Status Should Be    200    ${response}
```

## MCP Integration

The project includes Robot Framework MCP server configuration (`.vscode/mcp.json`):
```json
{
  "servers": {
    "robotmcp": {
      "type": "stdio",
      "command": "uv",
      "args": ["run", "python", "-m", "robotmcp.server"]
    }
  }
}
```

This enables AI-powered Robot Framework assistance via `rf-mcp` library (declared in `pyproject.toml`).

## Common Test Patterns

### Navigation Verification
```robot
Verify nav link    ${AHP_EmployeesTab}    Employee List    Inactive
```
Hovers tab, clicks link text, verifies page text.

### Date Input Pattern
```robot
Alternative Date Picker    ${targetInput}    01/15/2024    ${saveButton}
```
Use when standard date pickers fail (sends keys directly).

### Multi-Window Handling
```robot
Switch to window tab    ${indexOfTab}  # Uses window handles list
Close Current Tab                       # From GsSelenium
```

## When Creating New Tests

1. **Structure**: Create `pages/*.resource` for elements/keywords, `tests/*.robot` for test cases
2. **Import**: Include `TestSetup.resource` in pages, page resources in tests
3. **Setup**: Use `Suite Setup    Start admin test` for admin context tests
4. **Teardown**: Navigate back to homepage or close browsers explicitly
5. **Tags**: Add appropriate product/module tags for pipeline filtering
6. **Timeouts**: Set `Test Timeout    ${BASELINE_TEST_TIMEOUT} minutes`
7. **Screenshots**: Automatic on failure; manual via `Capture Page Screenshot`

---

*Last updated: 2025-11-01*
