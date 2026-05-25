*** Settings ***
Library    Browser
Resource   ../data/test_data.robot

*** Keywords ***
Start Suite
    New Browser    ${BROWSER_TYPE}    headless=${HEADLESS_MODE}    args=${BROWSER_ARGS}

End Suite
    Close Browser
