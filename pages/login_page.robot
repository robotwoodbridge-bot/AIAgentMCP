*** Settings ***
Library    Browser
Resource   ../data/test_data.robot

*** Variables ***
# Selectors - Login Page
${USERNAME_FIELD}           id=username
${PASSWORD_FIELD}           id=password
${SUBMIT_BUTTON}            id=submit-login
${FLASH_MESSAGE}            id=flash

*** Keywords ***
Navigate To Login Page
    New Page    ${LOGIN_URL}

Enter Username
    [Arguments]    ${username}
    Fill Text    ${USERNAME_FIELD}    ${username}

Enter Password
    [Arguments]    ${password}
    Fill Text    ${PASSWORD_FIELD}    ${password}

Click Submit Button
    Click    ${SUBMIT_BUTTON}
    Wait For Load State    domcontentloaded

Get Flash Message
    Wait For Elements State    ${FLASH_MESSAGE}    visible    timeout=15s
    ${message}=    Get Text    ${FLASH_MESSAGE}
    RETURN    ${message}

Verify Login Success Message
    [Arguments]    ${expected_message}
    ${message}=    Get Flash Message
    Should Contain    ${message}    ${expected_message}

Verify Login Failure Message
    [Arguments]    ${expected_message}
    ${message}=    Get Flash Message
    Should Contain    ${message}    ${expected_message}
