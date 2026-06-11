// k6 load test — login transaction (concurrency counterpart to login_performance.robot).
//
// Flow per iteration (mirrors a real user):
//   1. GET  /login         — load the login page
//   2. POST /authenticate  — submit credentials (expect 302 → /secure)
//   3. GET  /secure        — verify the session is actually valid
//
// Profiles (select with -e PROFILE=<name>, default: smoke):
//   smoke  — 2 VUs, 30s. Sanity check, safe to run anytime.
//   load   — ramp to 5 VUs, hold 2m. Normal-traffic baseline.
//   stress — ramp to 15 VUs, hold 2m. Find the knee of the curve.
//
// NOTE: staging is a shared public demo site — keep VU counts modest and do
// not run the stress profile repeatedly. Point BASE_URL at your own
// environment before scaling up.
//
// Usage:
//   ./utils/run_k6.sh                 # smoke profile
//   ./utils/run_k6.sh load            # load profile
//   k6 run -e PROFILE=load -e BASE_URL=https://staging.example.com tests/performance/k6/login_load_test.js

import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Trend, Rate } from 'k6/metrics';

const BASE_URL = __ENV.BASE_URL || 'https://practice.expandtesting.com';
const USERNAME = __ENV.LOGIN_USERNAME || 'practice';
const PASSWORD = __ENV.LOGIN_PASSWORD || 'SuperSecretPassword!';
const PROFILE = __ENV.PROFILE || 'smoke';

// Custom metrics — these are what we trend over time in Grafana.
const loginDuration = new Trend('login_transaction_duration', true);
const loginSuccess = new Rate('login_success_rate');

const profiles = {
  smoke: {
    stages: [{ duration: '30s', target: 2 }],
  },
  load: {
    stages: [
      { duration: '30s', target: 5 },  // ramp up
      { duration: '2m', target: 5 },   // sustain
      { duration: '15s', target: 0 },  // ramp down
    ],
  },
  stress: {
    stages: [
      { duration: '30s', target: 5 },
      { duration: '1m', target: 15 },
      { duration: '2m', target: 15 },
      { duration: '30s', target: 0 },
    ],
  },
};

if (!profiles[PROFILE]) {
  throw new Error(`Unknown PROFILE "${PROFILE}" — use smoke, load, or stress`);
}

export const options = {
  stages: profiles[PROFILE].stages,
  thresholds: {
    http_req_failed: ['rate<0.01'],                  // <1% transport-level errors
    http_req_duration: ['p(95)<3000'],               // p95 of any single request
    login_transaction_duration: ['p(95)<5000'],      // full login flow, matches LOGIN_SLA_MS in the RF suite
    login_success_rate: ['rate>0.99'],               // functional success under load
    checks: ['rate>0.99'],
  },
};

export default function () {
  group('login transaction', () => {
    const start = Date.now();

    const loginPage = http.get(`${BASE_URL}/login`, {
      tags: { step: 'login_page' },
    });
    check(loginPage, {
      'login page returns 200': (r) => r.status === 200,
      'login page has form': (r) => r.body.includes('action="/authenticate"'),
    });

    const auth = http.post(
      `${BASE_URL}/authenticate`,
      { username: USERNAME, password: PASSWORD },
      { redirects: 0, tags: { step: 'authenticate' } },
    );
    const authenticated = check(auth, {
      'authenticate returns 302': (r) => r.status === 302,
      'redirects to secure area': (r) => (r.headers['Location'] || '').includes('/secure'),
    });

    const secure = http.get(`${BASE_URL}/secure`, {
      tags: { step: 'secure_area' },
    });
    const sessionValid = check(secure, {
      'secure area returns 200': (r) => r.status === 200,
      'secure area shows success flash': (r) => r.body.includes('You logged into a secure area!'),
    });

    loginDuration.add(Date.now() - start);
    loginSuccess.add(authenticated && sessionValid);
  });

  // Think time between iterations so VU count ≈ concurrent users, not raw RPS.
  sleep(1);
}
