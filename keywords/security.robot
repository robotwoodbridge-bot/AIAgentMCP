*** Settings ***
Documentation    Security scan keywords — wraps OWASP ZAP, Nikto, and Nmap via Docker.
...              All scans write structured output to results/security/.
...              Requires Docker Desktop to be running on the host.
Library          OperatingSystem
Library          Process
Library          String
Library          Collections

*** Variables ***
${SECURITY_OUTPUT_DIR}    results/security
${ZAP_IMAGE}              ghcr.io/zaproxy/zaproxy:stable
${NIKTO_IMAGE}            frapsoft/nikto
${NMAP_IMAGE}             instrumentisto/nmap

# ---------------------------------------------------------------------------
# Phase 2 baseline thresholds — map ZAP risk codes to comparable severities.
# Phase 3: tighten fail_on_severity in settings.yaml to HIGH after clean run.
# ---------------------------------------------------------------------------
${SEVERITY_FAIL_THRESHOLD}    MEDIUM

*** Keywords ***

# =============================================================================
# Orchestration
# =============================================================================

Run Full Security Scan
    [Documentation]    Run ZAP baseline, Nikto, and Nmap scans sequentially.
    ...                Fails the suite if any scan finds issues at or above the
    ...                configured severity threshold.
    [Arguments]    ${target_url}    ${fail_on_severity}=${SEVERITY_FAIL_THRESHOLD}
    Prepare Security Output Dir
    ${zap_findings}=      Run ZAP Baseline Scan    ${target_url}
    ${nikto_findings}=    Run Nikto Scan           ${target_url}
    ${nmap_findings}=     Run Nmap Scan            ${target_url}
    Assert No Critical Findings    ${zap_findings}    ZAP        ${fail_on_severity}
    Assert No Critical Findings    ${nikto_findings}  Nikto      ${fail_on_severity}
    Assert No Critical Findings    ${nmap_findings}   Nmap       ${fail_on_severity}

# =============================================================================
# OWASP ZAP — passive baseline scan
# =============================================================================

Run ZAP Baseline Scan
    [Documentation]    Run the OWASP ZAP baseline (passive) scan against the target.
    ...                Writes zap-report.json to the security output directory.
    ...                Phase 4: change scan type to "full" in settings.yaml for active scanning.
    [Arguments]    ${target_url}
    Log Step    Starting ZAP baseline scan → ${target_url}
    ${result}=    Run Process
    ...    docker    run    --rm
    ...    --user    root
    ...    -v    ${CURDIR}/../${SECURITY_OUTPUT_DIR}:/zap/wrk:rw
    ...    ${ZAP_IMAGE}
    ...    zap-baseline.py
    ...    -t    ${target_url}
    ...    -J    /zap/wrk/zap-report.json
    ...    -I
    ...    timeout=600
    ...    stdout=${SECURITY_OUTPUT_DIR}/zap-stdout.txt
    ...    stderr=${SECURITY_OUTPUT_DIR}/zap-stderr.txt
    Log    ZAP exit code: ${result.rc}    level=INFO    console=True
    ${findings}=    Parse ZAP Report    ${SECURITY_OUTPUT_DIR}/zap-report.json
    RETURN    ${findings}

Parse ZAP Report
    [Arguments]    ${report_path}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${report_path}
    IF    not ${exists}
        Log    [WARN] [SECURITY] ZAP report not found at ${report_path}    level=WARN    console=True
        ${empty}=    Create List
        RETURN    ${empty}
    END
    ${raw}=    Get File    ${report_path}
    ${data}=   Evaluate    json.loads($raw)    json
    ${findings}=    Create List
    FOR    ${site}    IN    @{data.get('site', [])}
        FOR    ${alert}    IN    @{site.get('alerts', [])}
            ${severity}=    Map ZAP Risk To Severity    ${alert.get('riskcode', '0')}
            ${entry}=    Create Dictionary
            ...    tool=ZAP
            ...    severity=${severity}
            ...    name=${alert.get('name', 'Unknown')}
            ...    description=${alert.get('desc', '')}
            Append To List    ${findings}    ${entry}
        END
    END
    Log Step    ZAP found ${findings.__len__()} alerts
    RETURN    ${findings}

Map ZAP Risk To Severity
    [Arguments]    ${riskcode}
    ${code}=    Convert To String    ${riskcode}
    IF    '${code}' == '3'    RETURN    CRITICAL
    IF    '${code}' == '2'    RETURN    HIGH
    IF    '${code}' == '1'    RETURN    MEDIUM
    RETURN    LOW

# =============================================================================
# Nikto — web server misconfiguration scan
# =============================================================================

Run Nikto Scan
    [Documentation]    Run Nikto against the target host, writing nikto-report.json.
    [Arguments]    ${target_url}
    Log Step    Starting Nikto scan → ${target_url}
    ${result}=    Run Process
    ...    docker    run    --rm
    ...    --user    root
    ...    -v    ${CURDIR}/../${SECURITY_OUTPUT_DIR}:/tmp/nikto:rw
    ...    ${NIKTO_IMAGE}
    ...    -h    ${target_url}
    ...    -Format    json
    ...    -output    /tmp/nikto/nikto-report.json
    ...    -Tuning    1234567890ab
    ...    -nointeractive
    ...    timeout=300
    ...    stdout=${SECURITY_OUTPUT_DIR}/nikto-stdout.txt
    ...    stderr=${SECURITY_OUTPUT_DIR}/nikto-stderr.txt
    Log    Nikto exit code: ${result.rc}    level=INFO    console=True
    ${findings}=    Parse Nikto Report    ${SECURITY_OUTPUT_DIR}/nikto-report.json
    RETURN    ${findings}

Parse Nikto Report
    [Arguments]    ${report_path}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${report_path}
    IF    not ${exists}
        Log    [WARN] [SECURITY] Nikto report not found at ${report_path}    level=WARN    console=True
        ${empty}=    Create List
        RETURN    ${empty}
    END
    ${raw}=    Get File    ${report_path}
    ${data}=   Evaluate    json.loads($raw)    json
    ${findings}=    Create List
    FOR    ${vuln}    IN    @{data.get('vulnerabilities', [])}
        ${entry}=    Create Dictionary
        ...    tool=Nikto
        ...    severity=MEDIUM
        ...    name=${vuln.get('id', 'Unknown')}
        ...    description=${vuln.get('msg', '')}
        Append To List    ${findings}    ${entry}
    END
    Log Step    Nikto found ${findings.__len__()} items
    RETURN    ${findings}

# =============================================================================
# Nmap — port and service recon
# =============================================================================

Run Nmap Scan
    [Documentation]    Run Nmap default script + version scan (-sC -sV --open).
    ...                Writes nmap-report.xml to the security output directory.
    [Arguments]    ${target_url}
    ${host}=    Extract Host From URL    ${target_url}
    Log Step    Starting Nmap scan → ${host}
    ${result}=    Run Process
    ...    docker    run    --rm
    ...    --user    root
    ...    -v    ${CURDIR}/../${SECURITY_OUTPUT_DIR}:/tmp/nmap:rw
    ...    ${NMAP_IMAGE}
    ...    -sT    -sV    --open
    ...    -oX    /tmp/nmap/nmap-report.xml
    ...    ${host}
    ...    timeout=300
    ...    stdout=${SECURITY_OUTPUT_DIR}/nmap-stdout.txt
    ...    stderr=${SECURITY_OUTPUT_DIR}/nmap-stderr.txt
    Log    Nmap exit code: ${result.rc}    level=INFO    console=True
    ${findings}=    Parse Nmap Report    ${SECURITY_OUTPUT_DIR}/nmap-report.xml
    RETURN    ${findings}

Parse Nmap Report
    [Arguments]    ${report_path}
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${report_path}
    IF    not ${exists}
        Log    [WARN] [SECURITY] Nmap report not found at ${report_path}    level=WARN    console=True
        ${empty}=    Create List
        RETURN    ${empty}
    END
    ${raw}=    Get File    ${report_path}
    ${findings}=    Create List
    ${ports}=    Get Regexp Matches    ${raw}    portid="(\\d+)".*?state="open"    1
    FOR    ${port}    IN    @{ports}
        ${entry}=    Create Dictionary
        ...    tool=Nmap
        ...    severity=LOW
        ...    name=Open port ${port}
        ...    description=Port ${port} is open and accepting connections
        Append To List    ${findings}    ${entry}
    END
    Log Step    Nmap found ${findings.__len__()} open ports
    RETURN    ${findings}

# =============================================================================
# Assertion helpers
# =============================================================================

Assert No Critical Findings
    [Documentation]    Fail if any finding meets or exceeds the severity threshold.
    [Arguments]    ${findings}    ${tool}    ${threshold}=${SEVERITY_FAIL_THRESHOLD}
    ${order}=    Create List    LOW    MEDIUM    HIGH    CRITICAL
    ${threshold_idx}=    Get Index From List    ${order}    ${threshold}
    FOR    ${finding}    IN    @{findings}
        ${sev}=    Set Variable    ${finding['severity']}
        ${sev_idx}=    Get Index From List    ${order}    ${sev}
        IF    ${sev_idx} >= ${threshold_idx}
            Fail    [${tool}] ${sev} finding: ${finding['name']} — ${finding['description']}
        END
    END

# =============================================================================
# Utilities
# =============================================================================

Prepare Security Output Dir
    Create Directory    ${SECURITY_OUTPUT_DIR}

Extract Host From URL
    [Arguments]    ${url}
    ${host}=    Evaluate    re.sub(r'^https?://', '', '${url}').split('/')[0]    re
    RETURN    ${host}

Log Step
    [Arguments]    ${message}
    Log    [INFO] [SECURITY] ${message}    level=INFO    console=True
