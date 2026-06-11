*** Settings ***
Documentation    Performance suite — login page load and login transaction budgets.
...
...              Measures three things:
...              1. Page load metrics (TTFB, DOMContentLoaded, full load) via the
...                 browser Navigation Timing API.
...              2. Single login transaction time (submit click → flash message visible).
...              3. Repeated-sample login baseline — average and p90 across N iterations,
...                 each in a fresh browser context so cache/session state cannot skew results.
...
...              Thresholds are suite variables — override per-run, e.g.:
...              robot --variable LOGIN_SLA_MS:3000 tests/performance/
Resource         ../../data/test_data.robot
Resource         ../../keywords/common.robot
Resource         ../../pages/login_page.robot
Resource         ../../keywords/reporting.robot
Library          DateTime
Library          Collections

Suite Setup       Start Suite
Suite Teardown    End Suite

*** Variables ***
# Performance budgets (milliseconds). Staging is a public demo site, so
# budgets are deliberately lenient — tighten them once a baseline is established.
${TTFB_BUDGET_MS}               2000
${DOM_CONTENT_LOADED_BUDGET_MS}    5000
${PAGE_LOAD_BUDGET_MS}          8000
${LOGIN_SLA_MS}                 5000
${LOGIN_P90_BUDGET_MS}          6000
${BASELINE_ITERATIONS}          5

*** Test Cases ***
Login Page Load Meets Performance Budget
    [Documentation]    The login page must meet TTFB, DOMContentLoaded, and full
    ...                page load budgets, measured by the Navigation Timing API.
    [Tags]    performance    login    page-load
    ...       allure.label.epic:Performance    allure.label.severity:critical
    [Teardown]    Capture Screenshot On Failure
    Set Test Feature    Login Performance
    Set Test Story      Page load stays within budget
    Navigate To Login Page
    Wait For Load State    load    timeout=${BROWSER_TIMEOUT}
    ${metrics}=    Get Navigation Timing Metrics
    Log Step    TTFB: ${metrics}[ttfb] ms | DOMContentLoaded: ${metrics}[domContentLoaded] ms | Load: ${metrics}[loadComplete] ms | Transfer: ${metrics}[transferSize] bytes    context=PERF
    Should Be True    ${metrics}[ttfb] < ${TTFB_BUDGET_MS}
    ...    TTFB ${metrics}[ttfb] ms exceeded budget of ${TTFB_BUDGET_MS} ms
    Should Be True    ${metrics}[domContentLoaded] < ${DOM_CONTENT_LOADED_BUDGET_MS}
    ...    DOMContentLoaded ${metrics}[domContentLoaded] ms exceeded budget of ${DOM_CONTENT_LOADED_BUDGET_MS} ms
    Should Be True    ${metrics}[loadComplete] < ${PAGE_LOAD_BUDGET_MS}
    ...    Page load ${metrics}[loadComplete] ms exceeded budget of ${PAGE_LOAD_BUDGET_MS} ms

Login Transaction Completes Within SLA
    [Documentation]    A single valid login (submit click → success flash visible)
    ...                must complete within the login SLA.
    [Tags]    performance    login    transaction
    ...       allure.label.epic:Performance    allure.label.severity:critical
    [Teardown]    Capture Screenshot On Failure
    Set Test Feature    Login Performance
    Set Test Story      Login transaction meets SLA
    ${duration_ms}=    Measure Login Transaction
    Log Step    Login transaction took ${duration_ms} ms (SLA: ${LOGIN_SLA_MS} ms)    context=PERF
    Should Be True    ${duration_ms} < ${LOGIN_SLA_MS}
    ...    Login transaction ${duration_ms} ms exceeded SLA of ${LOGIN_SLA_MS} ms

Login Transaction Baseline Under Repeated Samples
    [Documentation]    Runs the login transaction ${BASELINE_ITERATIONS} times in
    ...                fresh browser contexts and asserts average and p90 against
    ...                budget. Establishes the baseline for future trend comparison.
    [Tags]    performance    login    baseline
    ...       allure.label.epic:Performance    allure.label.severity:normal
    [Teardown]    Capture Screenshot On Failure
    Set Test Feature    Login Performance
    Set Test Story      Repeated logins stay within p90 budget
    ${durations}=    Create List
    FOR    ${i}    IN RANGE    ${BASELINE_ITERATIONS}
        ${duration_ms}=    Measure Login Transaction
        Append To List    ${durations}    ${duration_ms}
        Log Step    Iteration ${i + 1}/${BASELINE_ITERATIONS}: ${duration_ms} ms    context=PERF
    END
    ${avg}=    Evaluate    round(sum($durations) / len($durations), 1)
    ${p90}=    Evaluate    sorted($durations)[min(len($durations) - 1, math.ceil(len($durations) * 0.9) - 1)]    modules=math
    ${min_ms}=    Evaluate    min($durations)
    ${max_ms}=    Evaluate    max($durations)
    Log Step    Baseline over ${BASELINE_ITERATIONS} runs — min: ${min_ms} ms | avg: ${avg} ms | p90: ${p90} ms | max: ${max_ms} ms    context=PERF
    Should Be True    ${avg} < ${LOGIN_SLA_MS}
    ...    Average login time ${avg} ms exceeded SLA of ${LOGIN_SLA_MS} ms
    Should Be True    ${p90} < ${LOGIN_P90_BUDGET_MS}
    ...    p90 login time ${p90} ms exceeded budget of ${LOGIN_P90_BUDGET_MS} ms

*** Keywords ***
Get Navigation Timing Metrics
    [Documentation]    Returns a dict of page load metrics (ms) from the
    ...                Navigation Timing API for the current page.
    ${metrics}=    Evaluate JavaScript    ${None}
    ...    () => {
    ...        const nav = performance.getEntriesByType('navigation')[0];
    ...        return {
    ...            ttfb: Math.round(nav.responseStart - nav.requestStart),
    ...            domContentLoaded: Math.round(nav.domContentLoadedEventEnd - nav.startTime),
    ...            loadComplete: Math.round(nav.loadEventEnd - nav.startTime),
    ...            transferSize: nav.transferSize
    ...        };
    ...    }
    RETURN    ${metrics}

Measure Login Transaction
    [Documentation]    Performs a full valid login in a fresh browser context and
    ...                returns the time in ms from submit click to success flash
    ...                visible. The fresh context prevents cache and session
    ...                carry-over between samples.
    New Context
    Navigate To Login Page
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    ${start}=    Get Current Date    result_format=epoch
    Click Submit Button
    Wait For Elements State    ${FLASH_MESSAGE}    visible    timeout=${BROWSER_TIMEOUT}
    ${end}=    Get Current Date    result_format=epoch
    ${duration_ms}=    Evaluate    round(($end - $start) * 1000)
    Close Context
    RETURN    ${duration_ms}
