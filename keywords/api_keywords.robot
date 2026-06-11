*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    jsonschema    WITH NAME    JsonSchema

*** Variables ***
${ECOM_BASE_URL}    https://rahulshettyacademy.com/api/ecom
${SCHEMA_DIR}       ${CURDIR}/../tests/api/schemas

*** Keywords ***
Create Ecom Session
    [Documentation]    Creates a persistent requests session for the ecom API.
    Create Session    ecom    ${ECOM_BASE_URL}    verify=True

Delete Ecom Session
    Delete All Sessions

POST Ecom Login
    [Documentation]    Authenticates and returns the full response object.
    [Arguments]    ${email}    ${password}
    ${body}=    Create Dictionary    userEmail=${email}    userPassword=${password}
    ${response}=    POST On Session    ecom    /auth/login    json=${body}
    RETURN    ${response}

Get First Available Product Id
    [Documentation]    Fetches the product catalog and returns the first product's ID.
    ...                The practice site resets its catalog periodically, so product
    ...                IDs must be resolved at runtime — never hardcoded.
    [Arguments]    ${token}
    ${headers}=     Create Dictionary    Authorization=${token}
    ${response}=    POST On Session    ecom    /product/get-all-products    json=&{EMPTY}    headers=${headers}
    ${products}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${products}    msg=Product catalog returned no products
    RETURN    ${products}[0][_id]

POST Ecom Create Order
    [Documentation]    Places an order and returns the full response object.
    [Arguments]    ${token}    ${product_id}    ${country}=India
    ${headers}=    Create Dictionary    Authorization=${token}
    ${order}=      Create Dictionary    country=${country}    productOrderedId=${product_id}
    ${orders}=     Create List    ${order}
    ${body}=       Create Dictionary    orders=${orders}
    ${response}=   POST On Session    ecom    /order/create-order    json=${body}    headers=${headers}
    RETURN    ${response}

Validate Status Code
    [Documentation]    Asserts the HTTP status code matches expected.
    [Arguments]    ${response}    ${expected_code}
    Should Be Equal As Integers    ${response.status_code}    ${expected_code}
    ...    msg=Expected status ${expected_code}, got ${response.status_code}

Validate Response Schema
    [Documentation]    Validates a response body against a JSON Schema file.
    [Arguments]    ${response}    ${schema_filename}
    ${schema_path}=    Set Variable    ${SCHEMA_DIR}/${schema_filename}
    ${schema_raw}=     Get File    ${schema_path}
    ${schema}=         Evaluate    __import__('json').loads($schema_raw)
    ${body}=           Set Variable    ${response.json()}
    Run Keyword And Continue On Failure
    ...    Evaluate
    ...    __import__('jsonschema').validate(instance=$body, schema=$schema)

Response Body Field Should Equal
    [Documentation]    Asserts a top-level field in the response JSON equals expected value.
    [Arguments]    ${response}    ${field}    ${expected_value}
    ${body}=    Set Variable    ${response.json()}
    Should Be Equal As Strings    ${body}[${field}]    ${expected_value}
