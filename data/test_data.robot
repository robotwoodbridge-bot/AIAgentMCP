*** Settings ***
Documentation    Centralized test data repository for all environments and variables

*** Variables ***
# Environment Configuration
${ENVIRONMENT}              staging
${STAGING_BASE_URL}         https://practice.expandtesting.com
${PRODUCTION_BASE_URL}      https://practice.expandtesting.com

# Application URLs
${LOGIN_URL}                ${STAGING_BASE_URL}/login

# Test Data - Credentials
${VALID_USERNAME}           practice
${VALID_PASSWORD}           SuperSecretPassword!
${INVALID_USERNAME}         invalid_user
${INVALID_PASSWORD}         WrongPassword123

# Expected Messages
${SUCCESS_LOGIN_MESSAGE}    You logged into a secure area!
${FAILURE_LOGIN_MESSAGE}    Your username is invalid!

# Browser Configuration
${BROWSER_TYPE}             Chromium
${HEADLESS_MODE}            False
${BROWSER_ARGS}             ["--start-maximized"]
# Timeout for Browser library element waits.
# Headed/xvfb mode needs a longer timeout than headless.
# Override per-run: --variable BROWSER_TIMEOUT:30s
${BROWSER_TIMEOUT}          30s

# Wait Times (in seconds)
${DEFAULT_WAIT_TIME}        5
${ELEMENT_TIMEOUT}          10
