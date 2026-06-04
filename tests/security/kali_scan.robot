*** Settings ***
Documentation    Security vulnerability scan suite — OWASP ZAP (baseline), Nikto, Nmap.
...
...              Phase 1: Scaffold — run manually, review raw findings.
...              Phase 2: Baseline run — record expected finding count.
...              Phase 3: Threshold enforcement — set fail_on_severity: HIGH in settings.yaml.
...              Phase 4: Pre-release full scan — promote ZAP scan_type to "full".
...
...              Prerequisites:
...                - Docker Desktop must be running
...                - Run from repo root with .venv active
...                - ./utils/run_security.sh [environment]
...
...              Override target: robot --variable ENVIRONMENT:production tests/security/
Resource         ../../keywords/security.robot
Library          OperatingSystem
Library          Collections

Suite Setup      Prepare Security Output Dir
Suite Teardown   Log    [INFO] [SECURITY] Scan suite complete. Review results/security/ for full reports.    level=INFO    console=True

*** Variables ***
${ENVIRONMENT}            staging
${TARGET_URL}             https://practice.expandtesting.com
${FAIL_ON_SEVERITY}       MEDIUM

*** Test Cases ***

OWASP ZAP Baseline Scan
    [Documentation]    Passive scan — detects reflected/stored XSS, missing security headers,
    ...                insecure cookies, clickjacking exposure, and similar passively-detectable issues.
    ...                Phase 4: promote ZAP scan_type to "full" in settings.yaml for active scanning.
    [Tags]    security    zap    phase1
    ${findings}=    Run ZAP Baseline Scan    ${TARGET_URL}
    FOR    ${f}    IN    @{findings}
        Log    [ZAP] [${f['severity']}] ${f['name']}    level=WARN    console=True
    END
    Assert No Critical Findings    ${findings}    ZAP    ${FAIL_ON_SEVERITY}

Nikto Web Server Scan
    [Documentation]    Checks for dangerous files, outdated server software, server
    ...                misconfigurations, and default credentials across all Nikto test groups.
    [Tags]    security    nikto    phase1
    ${findings}=    Run Nikto Scan    ${TARGET_URL}
    FOR    ${f}    IN    @{findings}
        Log    [Nikto] [${f['severity']}] ${f['name']}: ${f['description']}    level=WARN    console=True
    END
    Assert No Critical Findings    ${findings}    Nikto    ${FAIL_ON_SEVERITY}

Nmap Port And Service Recon
    [Documentation]    Default script (-sC) + version (-sV) scan of open ports.
    ...                Unexpected open ports are flagged as LOW severity findings.
    [Tags]    security    nmap    phase1
    ${findings}=    Run Nmap Scan    ${TARGET_URL}
    FOR    ${f}    IN    @{findings}
        Log    [Nmap] [${f['severity']}] ${f['name']}    level=INFO    console=True
    END
    Assert No Critical Findings    ${findings}    Nmap    ${FAIL_ON_SEVERITY}
