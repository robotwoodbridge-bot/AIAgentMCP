*** Settings ***
Documentation    Contract tests for EcomBasic API (rahulshettyacademy.com).
...              Validates that each endpoint's response conforms to its agreed schema
...              — shape, required fields, and types — not business logic.
Resource         ../../keywords/api_keywords.robot

Suite Setup      Initialize Contract Suite
Suite Teardown   Delete Ecom Session

*** Variables ***
# Credentials stored in config/settings.yaml; hardcoded here only for the API contract suite
# because this API is a public practice site with shared test credentials.
${LOGIN_EMAIL}       rbridge@gmail.com
${LOGIN_PASSWORD}    Rb123456
# PRODUCT_ID is resolved at suite setup — the practice site resets its catalog,
# so hardcoded product IDs go stale and the API returns 400 "Wrong Product ID".

*** Test Cases ***
POST Login - Status Code Is 200
    [Tags]    api    contract    ecombasic    login
    ${response}=    POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    Validate Status Code    ${response}    200

POST Login - Response Conforms To Contract Schema
    [Tags]    api    contract    ecombasic    login
    ${response}=    POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    Validate Response Schema    ${response}    login_response.json

POST Login - Token And UserId Are Non-Empty Strings
    [Tags]    api    contract    ecombasic    login
    ${response}=    POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    ${body}=        Set Variable    ${response.json()}
    Should Not Be Empty    ${body}[token]
    Should Not Be Empty    ${body}[userId]

POST Create Order - Status Code Is 201
    [Tags]    api    contract    ecombasic    order
    ${login}=       POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    ${token}=       Set Variable    ${login.json()}[token]
    ${response}=    POST Ecom Create Order    ${token}    ${PRODUCT_ID}
    Validate Status Code    ${response}    201

POST Create Order - Response Conforms To Contract Schema
    [Tags]    api    contract    ecombasic    order
    ${login}=       POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    ${token}=       Set Variable    ${login.json()}[token]
    ${response}=    POST Ecom Create Order    ${token}    ${PRODUCT_ID}
    Validate Response Schema    ${response}    create_order_response.json

POST Create Order - Orders Array Contains At Least One Order ID
    [Tags]    api    contract    ecombasic    order
    ${login}=       POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    ${token}=       Set Variable    ${login.json()}[token]
    ${response}=    POST Ecom Create Order    ${token}    ${PRODUCT_ID}
    ${body}=        Set Variable    ${response.json()}
    ${orders}=      Set Variable    ${body}[orders]
    Should Not Be Empty    ${orders}
    Should Not Be Empty    ${orders}[0]

*** Keywords ***
Initialize Contract Suite
    [Documentation]    Opens the API session and resolves a live product ID once
    ...                for the whole suite.
    Create Ecom Session
    ${login}=       POST Ecom Login    ${LOGIN_EMAIL}    ${LOGIN_PASSWORD}
    ${token}=       Set Variable    ${login.json()}[token]
    ${product_id}=    Get First Available Product Id    ${token}
    Set Suite Variable    ${PRODUCT_ID}    ${product_id}
