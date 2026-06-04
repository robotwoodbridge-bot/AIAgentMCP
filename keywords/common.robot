*** Settings ***
Library    Browser
Library    OperatingSystem
Resource   ../data/test_data.robot

*** Keywords ***
Start Suite
    ${hostname}=    Run    hostname
    Log    Running on host: ${hostname}    console=True
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS_MODE}    args=${BROWSER_ARGS}
    Set Browser Timeout    ${BROWSER_TIMEOUT}

End Suite
    Close Browser
