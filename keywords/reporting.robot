*** Settings ***
Documentation    Allure reporting helpers and structured logging keywords.
...              Import this resource in any test suite that needs rich reporting.
Library          Collections
Library          String

*** Keywords ***
# =============================================================================
# Allure tagging keywords
# These set metadata that Allure uses to categorise and filter test results.
# =============================================================================

Set Test Epic
    [Documentation]    Tag the current test with a top-level epic label.
    [Arguments]    ${epic_name}
    Set Tags    allure.label.epic:${epic_name}

Set Test Feature
    [Documentation]    Tag the current test with a feature label.
    [Arguments]    ${feature_name}
    Set Tags    allure.label.feature:${feature_name}

Set Test Story
    [Documentation]    Tag the current test with a user story label.
    [Arguments]    ${story_name}
    Set Tags    allure.label.story:${story_name}

Set Test Severity
    [Documentation]    Set the Allure severity. Valid values: blocker critical normal minor trivial
    [Arguments]    ${severity}
    Set Tags    allure.label.severity:${severity}

Set Test Owner
    [Documentation]    Assign an owner label visible in the Allure report.
    [Arguments]    ${owner}
    Set Tags    allure.label.owner:${owner}

# =============================================================================
# Structured logging keywords
# Produce clean, parseable log lines that Loki can query easily.
# Format: [LEVEL] [CONTEXT] message
# =============================================================================

Log Step
    [Documentation]    Log an informational step in a structured format.
    [Arguments]    ${message}    ${context}=TEST
    Log    [INFO] [${context}] ${message}    level=INFO    console=True

Log Warning
    [Documentation]    Log a warning in a structured format.
    [Arguments]    ${message}    ${context}=TEST
    Log    [WARN] [${context}] ${message}    level=WARN    console=True

Log Failure Details
    [Documentation]    Log detailed failure context — call this in teardown on failure.
    [Arguments]    ${message}    ${context}=TEST
    Log    [FAIL] [${context}] ${message}    level=ERROR    console=True

# =============================================================================
# Screenshot on failure
# Add to Suite/Test Teardown so every failure captures visual evidence.
# =============================================================================

Capture Screenshot On Failure
    [Documentation]    Take a browser screenshot if the current test failed.
    ...                Add as a test teardown: [Teardown]  Capture Screenshot On Failure
    Run Keyword If Test Failed    Take Screenshot    fullPage=True
