Phase 4 is where you **light up Layer 8 + Layer 9 for real** and flip from “AI-assisted ops” to **AI-backed security + executive decision support** – still strictly *analysis-only* and policy-gated, no kinetic anything.

I’ll structure it the same way as the earlier phases.

---

## Phase 4 – L8 / L9 Activation & Governance Plane

### 1. Objectives

**Primary goals:**

1. **Bring Layer 8 online as a real SOC/defence plane**

   * Adversarial ML, security analytics, crypto AI, threat intel, biometrics, enclave monitoring, network AI, SOAR.
   * Backed by the fast fabric (Redis + tmpfs SQLite + SHRINK + SOC_EVENTS).
2. **Bring Layer 9 online as an executive / strategic overlay**

   * Strategic planning, course-of-action (COA) generation, NC3-style “red team brain” – but strictly analysis-only.
3. **Embed ROE / governance / safety**

   * Hard technical limits on what L8/L9 can *do* (no direct actions; only recommendations, tickets, playbooks).
   * 2-person integrity + token gates for any “high consequence” flows.
4. **End-to-end loop**

   * L3–7 + SHRINK + L8 + L9 form a full decision loop:

     * detect → analyse → predict → explain → recommend → (human) decide.

---

## 2. Success Criteria

You can call Phase 4 “done” when:

* **L8:**

  * At least **3–4 concrete microservices** for devices 51–58 are live:

    * Adversarial ML defence
    * Security analytics fusion
    * Crypto/PKI/PQC watcher
    * SOAR orchestrator (ticket/response proposals)
  * SOC can see **L8 severity + rationale** on each high-value event.
  * L8 can **propose** actions (block, isolate, escalate), but cannot execute them without human approval.

* **L9:**

  * At least **one strategic “COA generator”** service live, using L7 + L5/L6 context.
  * L9 outputs:

    * are fully logged + auditable;
    * are clearly tagged as **advisory**;
    * require 2-person approval + ROE tokens for any downstream action.

* **Governance & Safety:**

  * Clear **policy layer** (OPA or custom) in front of any effectors.
  * SHRINK monitors L8+L9 logs; anomalies in “tone / intention” are surfaced back into SOC_EVENTS.
  * No path exists from AI → direct system change without explicit, logged human action.

---

## 3. Workstream A – Layer 8: Security AI Microservices

Layer 8 was already “proto” in Phase 1F/2 via SOC router + SHRINK. Now you promote it into **first-class devices**:

### A1. Event model – finalise `SOC_EVENT`

Lock in a JSON schema that everything uses:

```json
{
  "ts": "...",
  "source_layer": 3,
  "id": "uuid",
  "severity": "LOW|MEDIUM|HIGH|CRITICAL",
  "category": "AUTH|NETWORK|SYSTEM|APP|INTEL",
  "signals": {
    "l3": { "decision": "...", "score": 0.87 },
    "l4": { "label": "...", "confidence": 0.91 },
    "l5": { "forecast": "...", "risk_band": "RISING" },
    "l6": { "risk_level": 3, "policy_flags": ["TREATY_ANALOG_BREACH"] },
    "l7": { "summary": "...", "rationale": "..." },
    "shrink": { "risk_acute": 0.72, "lbi": 0.61 }
  },
  "l8": {
    "advml_flags": [],
    "analytics_flags": [],
    "crypto_flags": [],
    "soar_proposals": []
  }
}
```

All L8 services read/write `SOC_EVENTS` with this shape.

### A2. Device 51 – Adversarial ML Defence (`dsmil-l8-advml`)

Role:

* Detect attempts to:

  * poison logs,
  * evade detectors,
  * manipulate LLMs / agents.

Inputs:

* `SOC_EVENTS` stream.
* SHRINK metrics (esp. entropy, sentiment vs event content).
* L3/L4 discrepancies (e.g. event says “OK”, but anomaly scores spike).

Outputs:

* `l8.advml_flags` in the `SOC_EVENT` (e.g. `["POSSIBLE_LOG_TAMPER", "PROMPT_INJECTION_PATTERN"]`).
* Elevated severity where appropriate.

### A3. Device 52 – Security Analytics Fusion (`dsmil-l8-analytics`)

Role:

* Aggregate across events to detect:

  * campaigns,
  * multi-vector attacks,
  * slow-burn trends.

Inputs:

* `SOC_EVENTS` + L5/L6 forecasts.
* Qdrant similarity queries (“have we seen this pattern before?”).

Outputs:

* `l8.analytics_flags`: e.g. `["CAMPAIGN_SUSPECTED", "NEW_PATTERN"]`.
* Optionally create synthetic “META_SOC_EVENT” summarizing a cluster.

### A4. Device 53 – Crypto / PQC Watcher (`dsmil-l8-crypto`)

Role:

* Watch cert/PKI events, key rolls, PQC usage.
* Ensure all security-critical flows use ML-KEM/ML-DSA (in your own stack).
* Detect anomalies like:

  * keys rolled without reason,
  * fallback to classical crypto where PQC expected.

Outputs:

* `l8.crypto_flags`: e.g. `["NON_PQC_CHANNEL", "UNEXPECTED_KEY_ROTATION"]`.

### A5. Device 58 – SOAR / Response Orchestrator (`dsmil-l8-soar`)

This is **proposal-only** in Phase 4.

Role:

* For CRITICAL events, compile all context (L3–7 + L8 flags + SHRINK).
* Use L7 SOC Copilot profile to generate:

  * recommended actions (block IP, isolate host, notify human).
  * a structured “playbook” entry.

Outputs:

* `l8.soar_proposals`: list of structured actions.
* Optional: create tickets in Jira/Mattermost, but **only as drafts**.

Everything L8 does is logged (`SyslogIdentifier=dsmil-l8-*`) and passes through journald → `/var/log/dsmil.log` → SHRINK.

---

## 4. Workstream B – Layer 9: Executive Command & COA Engine

Layer 9 is your **strategic overlay**. In Phase 4 it’s still “analysis-only COA engine”.

### B1. L9 access model

Before code, define gatekeeping:

* L9 endpoints always require:

  * `role in { EXEC, STRAT_ANALYST }`,
  * valid **session token**,
  * per-request **ROE token** (like a one-time capability) for specific domains.
* 2-person integrity: high-impact scenarios only proceed if **two distinct identities** sign off.

### B2. COA Engine (`dsmil-l9-coa`)

Role:

* Convert complex situations into **courses of action** with pros/cons, risk scoring, and justifications.

Inputs:

* Hand-picked `SOC_EVENTS` (highest severity or flagged by L6).
* L5/L6 scenario summaries.
* Operator context (“What’s the question?”).

Implementation:

* Orchestrator service:

  * builds a structured prompt from all context.
  * calls L7 (general_7b_amx profile) with an L9-specific system prompt (“You are a strategic advisor bound by ROE…”).
  * applies OPA/policy filters to outputs (e.g. no illegal actions, no violence, no personal targeting).
* Outputs:

  * `coa_options`: 2–4 options, each with:

    * steps,
    * risks,
    * assumptions.
  * `preferred_coa`: labelled but **not auto-executed**.

Everything is stored in:

* `L9_OUT` stream.
* `l9_coa` table in archive DB for later audit.

### B3. NC3 / ATOMAL Overlay

Build on your ATOMAL sandbox from Phase 2:

* Tag specific L6 scenarios as **“NC3-analog”**.
* When those hit certain thresholds:

  * they are forwarded to `dsmil-l9-coa`.
  * additional ROE checks:

    * explicit text about “NC3-ANALOG – TRAINING ONLY”.
    * extra token requirement.
* Outputs are labelled clearly as:

  * training/simulation only;
  * not actionable outside lab.

---

## 5. Workstream C – Governance, ROE & Policy Layer

This is where you harden **what AI is allowed to *change***.

### C1. Policy Engine

Use something like OPA, or a custom filter, but implement:

* **Input constraints:**

  * Which event types can L9 touch?
  * Who can request what?
* **Output constraints (L8/L9):**

  * Allowed action verbs (e.g. “RECOMMEND”, “SUGGEST”, “SUMMARISE”).
  * Forbidden actions (e.g. “DELETE LOGS”, “SCAN OUTSIDE SCOPE”, “EXPLOIT VULNS”).
* **Channel constraints:**

  * Some COAs must only go to specific channels (e.g. exec report, not direct SOC chat).

Everything from L8/L9 to the outside world passes through this filter.

### C2. Human confirmation workflow

For any `soar_proposal` or `coa_option` with high risk:

* Must be **displayed to humans** in a UI/CLI (kitty view, web dashboard).
* Execution path:

  * operator confirms,
  * second person optionally confirms,
  * an **external tool** (Ansible/SSH/whatever) performs changes – *not* DSMIL directly.
* DSMIL only logs:

  * what it suggested,
  * what was approved,
  * what was executed by external systems.

---

## 6. Workstream D – Resilience & Testing

Before you trust L8/L9, you fuzz and red-team them.

### D1. Adversarial testing

* Prompt-injection / jailbreak tests against L7 when called from L8/L9.
* Synthetic “rogue agent” scenarios to see if:

  * L8 advml flags them,
  * policy engine blocks inappropriate outputs.

### D2. Chaos / scenario drills

* Run periodic simulations:

  * flood SOC_EVENTS with synthetic campaigns,
  * raise SHRINK risk artificially,
  * see how L5–L9 react.
* Verify:

  * no system meltdown,
  * no policy violations,
  * humans remain in the loop.

---

## 7. Phase 4 Checklist

Mark Phase 4 complete when:

* [ ] L8 microservices (advml, analytics, crypto, SOAR) are running and enriching `SOC_EVENTS`.
* [ ] L9 COA engine is live with ROE/2-person integrity and only produces **advisory** outputs.
* [ ] Policy layer enforced on all L8/L9 outputs; blocked attempts are logged & visible.
* [ ] SHRINK sees and scores L8/L9 logs, and anomalies get fed back into SOC.
* [ ] At least one end-to-end **tabletop scenario** was run:

  * synthetic incident → L3–7 → L8 analysis → L9 COA → human decision,
  * with everything auditable.

If you want, next step I can zoom into *one* piece (e.g. L8 device map, or the COA engine prompt + JSON schema) and write it out in actual code/JSON you can drop into the repo.
