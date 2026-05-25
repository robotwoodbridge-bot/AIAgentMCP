*** Settings ***
Documentation    Smoke suite — core login flows that must pass on every build.
Resource         ../../data/test_data.robot
Resource         ../../keywords/common.robot
Resource         ../../pages/login_page.robot
Resource         ../../keywords/reporting.robot

Suite Setup       Start Suite
Suite Teardown    End Suite

*** Test Cases ***
Valid Login Shows Secure Area
    [Documentation]    Logging in with correct credentials should land on the secure area.
    [Tags]    smoke    login    allure.label.epic:Authentication    allure.label.severity:critical
    [Teardown]    Capture Screenshot On Failure
    Set Test Feature    Login
    Set Test Story      Valid credentials grant access
    Navigate To Login Page
    Enter Username    ${VALID_USERNAME}
    Enter Password    ${VALID_PASSWORD}
    Click Submit Button
    Verify Login Success Message    ${SUCCESS_LOGIN_MESSAGE}

Invalid Login Shows Error Message
    [Documentation]    Logging in with wrong credentials should show an error, not grant access.
    [Tags]    smoke    login    negative    allure.label.epic:Authentication    allure.label.severity:critical
    [Teardown]    Capture Screenshot On Failure
    Set Test Feature    Login
    Set Test Story      Invalid credentials are rejected
    Navigate To Login Page
    Enter Username    ${INVALID_USERNAME}
    Enter Password    ${INVALID_PASSWORD}
    Click Submit Button
    Verify Login Failure Message    ${FAILURE_LOGIN_MESSAGE}

