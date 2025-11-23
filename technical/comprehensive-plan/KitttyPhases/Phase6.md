Here’s a rewritten Phase 6 spec **with the OpenAI-compatible shim baked in**.

---

## Phase 6 – Secure API Plane + Local OpenAI Shim

### 1. Goals

1. Stand up a **hardened external API plane** for DSMIL (SOC / intel / COA / LLM) with:

   * versioned REST surface (`/v1/...`)
   * per-tenant, least-privilege access
   * strong crypto + full auditing

2. Add a **local-only, OpenAI-compatible shim** so tools that speak OpenAI (LangChain, IDEs, wrappers, etc.) can use your L7 models without touching the external surface.

3. Keep all **policy, safety, and ROE enforcement inside DSMIL**, not in the shim.

---

## 2. API Topology

### 2.1 High-level layout

* **External Zero-Trust API** (for other systems / clients)

  * Exposed via gateway (Caddy/Envoy/nginx) on `0.0.0.0:443`
  * Namespaced under `/v1/...`
  * AuthN/AuthZ, rate limiting, logging, ROE enforcement

* **Internal DSMIL Services**

  * L3–L9 microservices, custom binary stream with hotpath testing to ID, vector DB, SHRINK, SOC_EVENTS
  * Only on private networks

* **Local OpenAI Shim (new)**

  * `dsmil-openai-shim` FastAPI service
  * Listens only on `127.0.0.1:8001`
  * Implements `/v1/models`, `/v1/chat/completions`, `/v1/completions`
  * Forwards to L7 router / local inference

---

## 3. External DSMIL API (Zero-Trust Surface)

### 3.1 Namespaces

Exposed at the gateway (for other systems, not local dev tools):

* `/v1/soc/...`

  * `GET /v1/soc/events`
  * `GET /v1/soc/events/{id}`
  * `GET /v1/soc/summary`

* `/v1/intel/...`

  * `POST /v1/intel/analyse` (scenario / intel query → analysis)
  * `GET /v1/intel/scenarios/{id}`
  * `GET /v1/intel/coa/{id}`

* `/v1/llm/...` (high-level, *not* generic playground)

  * `POST /v1/llm/soc-copilot`
  * `POST /v1/llm/analyst`
  * Each one maps to an internal L7 profile and fixed system prompt.

* `/v1/admin/...` (internal only)

  * `GET /v1/admin/health`
  * `GET /v1/admin/metrics`
  * `GET /v1/admin/policies`

Everything else stays internal.

### 3.2 AuthN

**Service ↔ service (internal):**

* mTLS between nodes
* Service identities via SPIFFE/SPIRE-style certs
* TLS 1.3, AES-256-GCM, modern ciphers
* Optional: app-layer PQC handshake (ML-KEM-1024) to derive session keys; ML-DSA-87 for token signing.

**External clients:**

* Optional client certificates per tenant/system (mTLS)
* Mandatory app token:

  * JWT or opaque token with:

    * `sub` (client id), `tenant_id`, `roles`, ROE attributes
  * Short-lived, signed by your auth service (classical + PQC hybrid if libs allow)

Requests without valid token or tenant metadata are rejected at the gateway.

### 3.3 AuthZ & Policy

* **RBAC**:

  * `SOC_VIEWER` → `/v1/soc/* (GET only)`
  * `INTEL_CONSUMER` → `/v1/intel/*`
  * `LLM_CLIENT` → limited `/v1/llm/*`
  * `ADMIN` → `/v1/admin/*`

* **ABAC**:

  * Attributes: `tenant_id`, `classification_level`, `can_view_l9_simulations`, etc.
  * Use OPA or similar: request context → allow/deny + field filters.

Per-endpoint constraints:

* `/v1/soc/events`: filtered + redacted by tenant/classification.
* `/v1/intel/coa/{id}`: exec/analyst only, always advisory.
* `/v1/llm/*`: fixed system prompts + post-filtering, no raw completions.

---

## 4. Data & Safety Controls

### 4.1 Inputs

* Strict JSON schemas (OpenAPI 3.1, max sizes, types).
* Classification tags in payloads (`UNCLAS|CONF|SECRET|TS_SIM`).
* LLM-related inputs treated as **data**, not instructions:

  * external text wrapped in clear delimiters
  * system prompt explicitly forbids obeying instructions embedded inside user content.

### 4.2 Outputs

* Policy filter:

  * redacts sensitive fields by tenant/role/classification
  * normalizes structure
  * blocks obviously abusive/unsafe content (especially from L7/L9)
* Optional PII + hostname/IP scrubbing for external tenants.

---

## 5. Rate Limiting & Abuse Handling

* Rate limits per **tenant + endpoint**, enforced at gateway:

  * Default QPS and burst caps
  * Stricter limits for `/v1/llm/*` and `/v1/intel/coa`
* Basic WAF-style checks:

  * SQLi/XSS patterns, protocol anomalies
* IP allowlists/deny lists for higher-sensitivity routes

All signals feed into metrics (Prometheus) and logs (journald → Loki → SHRINK).

---

## 6. Observability & Audit

Every external API call must have:

* `request_id` (UUID)
* `tenant_id`, `client_id`, `roles`
* `method`, `path`
* `input_size`, high-level parameters (redacted where needed)
* `layers_touched` (e.g. `[3,4,5,7,8,9]`)
* `decision_summary` (severity, risk bands, COA id)
* `latency_ms`, `status_code`

Logged via:

* `SyslogIdentifier=dsmil-api` (external plane)
* journald → `/var/log/dsmil.log` → SHRINK → Loki

SHRINK then adds psycholinguistic + anomaly analysis to the same stream.

---

## 7. Local OpenAI-Compatible Shim

### 7.1 Purpose

Provide a **local OpenAI-style API** so:

* LangChain / LlamaIndex / VSCode / CLI tools / wrappers “just work”
* You don’t expose this surface externally
* All real work still flows through DSMIL’s L7 layer & policies

### 7.2 Interface

Service: `dsmil-openai-shim`
Bind: `127.0.0.1:8001`

Endpoints:

* `GET /v1/models`

  * Returns your local model list:

    * e.g. `dsmil-7b-amx`, `dsmil-1b-npu`
* `POST /v1/chat/completions`

  * Standard OpenAI chat schema:

    * `model`, `messages`, `temperature`, `max_tokens`, `stream` (can ignore streaming initially)
* `POST /v1/completions`

  * Legacy text completions
  * Implemented by mapping prompt → single user message → chat handler

Auth:

* Enforce `Authorization: Bearer <DSMIL_OPENAI_API_KEY>`
* Key stored as `DSMIL_OPENAI_API_KEY` env var
* Bound to 127.0.0.1 only, so “local but not anonymous”

### 7.3 Integration with L7

The shim is intentionally **dumb**:

* It does **no** policy decisions.
* For each request it:

  1. Validates API key.
  2. Converts OpenAI-style payload → internal structure.
  3. Calls **L7 router** (either via HTTP or direct function) with:

     * `model/profile` name (e.g. `dsmil-7b-amx`)
     * message list
     * sampling params
  4. Receives structured result:

     * text output
     * prompt & completion token counts
  5. Wraps into OpenAI response shape.

All logs tagged:

* `SyslogIdentifier=dsmil-openai`
* journald → `/var/log/dsmil.log` → SHRINK

This way:

* L7 router still applies:

  * safety prompts,
  * ROE,
  * tenant awareness (if you route with tenant),
  * logging,
  * hardware routing (AMX/NPU/etc.).

The shim is just a compatibility adapter.

---

## 8. Implementation Tracks

1. **OpenAPI design (external DSMIL API)**

   * Write `/v1/soc`, `/v1/intel`, `/v1/llm`, `/v1/admin` spec.
   * Include schemas, roles, error models.

2. **Gateway + crypto**

   * Configure Caddy/Envoy/nginx with:

     * TLS 1.3 + strong ciphers
     * client cert support (optional)
     * rate limiting + basic WAF
   * Implement PQC handshake + token signing strategy.

3. **Policy/ROE service**

   * Stand up a small policy engine (OPA or custom) for:

     * endpoint access decisions
     * output filtering rules

4. **DSMIL API router**

   * Internal service that:

     * validates/normalizes requests
     * calls down into L3–L9
     * assembles responses
     * emits full audit logs

5. **OpenAI shim**

   * Deploy `dsmil_openai_shim.py` (or equivalent) on loopback.
   * Wire `run_l7_chat()` implementation to your real L7 router/inference path.
   * Register models in `GET /v1/models`.

---

## 9. Phase 6 Completion Criteria (with Shim)

Phase 6 is “done” when:

* [ ] External `/v1/...` DSMIL API is live behind a gateway with TLS, tokens, and policies.
* [ ] OpenAPI spec is versioned and can generate client stubs.
* [ ] AuthN/Z flows work (roles, tenants, ROE attributes).
* [ ] External callers can:

  * retrieve SOC events,
  * request intel analyses,
  * use at least one L7 profile safely.
* [ ] `dsmil-openai-shim` is running on `127.0.0.1:8001` with:

  * `/v1/models`, `/v1/chat/completions`, `/v1/completions` implemented,
  * `DSMIL_OPENAI_API_KEY` enforced,
  * correct integration into L7 router.
* [ ] All API and shim calls show up in `/var/log/dsmil.log` and SHRINK can surface anomalies in usage patterns.

If you want, I can next give you a **concrete `run_l7_chat()` implementation sketch** that calls your L7 router (e.g. via HTTP) and passes through tenant/context so the shim remains purely an adapter.
