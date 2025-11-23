Phase 5 is where you stop “big-brain lab rig” and start **real distributed, multi-tenant deployment + hardening**, *still* without a full MLOps stack.

---

## Phase 5 – Distributed Deployment & Hardening (No MLOps)

### 1. Objectives

**Goal:** Turn DSMIL (L3–L9 + SHRINK) into a **resilient, multi-node, multi-tenant platform**:

* Split services across **several machines/VMs** (SOC node, AI node, storage node, etc.).
* Add **strong isolation** between tenants/missions.
* Tighten **SLOs, autoscaling, and failover** for inference services.
* Solidify the **operator UX** (CLI, kitty cockpit, dashboards) so this feels like a product, not a science project.

Still **no training pipeline**: models are updated manually/out-of-band; Phase 5 is **deployment + governance**, not model lifecycle.

---

## 2. Success Criteria

You can call Phase 5 “done” when:

* DSMIL is running across **≥3 nodes** with clear roles (e.g. `SOC`, `AI`, `DATA`).
* Critical services (L3–L8 + SHRINK) have:

  * **HA story** (restart policy + at least warm standby, if not active/active).
  * Documented **SLOs** (latency / availability) and live **Grafana dashboards**.
* At least **two tenants/missions** are isolated:

  * clean data separation,
  * separate auth domains / API keys,
  * no cross-tenant leakage in logs or vector DB.
* Operators can:

  * see status with one command (`dsmilctl status`),
  * open a kitty cockpit pre-wired to the right nodes,
  * view SOC/L8/L9 summaries in dashboards without SSHing everywhere.

---

## 3. Workstream A – Multi-Node Layout & Orchestration

### A1. Logical node roles

A minimal 3-node layout:

* **NODE-A (SOC / Control)**

  * L3, L4, SOC routers, L8 services, L9 COA
  * SHRINK
  * Kitty terminals + dashboards

* **NODE-B (AI / Inference)**

  * L5, L6, L7 router, L7 agents
  * Vector DB (Qdrant)
  * Any GPU/NPU-heavy workloads

* **NODE-C (Data / Logging)**

  * Redis, Postgres/archive, Loki, Promtail, Grafana

You can keep **tmpfs SQLite** local on each node for hot-path state.

### A2. Containerization (without MLOps)

Standardize each service as a **Docker container**:

* `dsmil-l3`, `dsmil-l4`, `dsmil-l5`, `dsmil-l6`, `dsmil-l7-router`, `dsmil-l7-agent`,
* `dsmil-soc-*` (advml, analytics, crypto, soar),
* `dsmil-l8-*`, `dsmil-l9-coa`,
* `shrink-dsmil`.

Use **docker-compose / Portainer stacks** per node, not K8s:

* One compose file per node describing which DSMIL services run there.
* Shared overlays:

  * `dsmil_net` (internal network),
  * `metrics_net` (Prometheus/Loki),
  * `public_api_net` (only for exposed APIs).

Everything still plugs into Redis + vector DB + archive DB via internal hostnames.

---

## 4. Workstream B – Tenant / Mission Isolation

### B1. Namespaces by tenant

Define at least two tenants:

* `TENANT_ALPHA`
* `TENANT_BRAVO`

Implement isolation at 3 layers:

1. **Data paths**

   * Separate DB schemas or databases (`dsmil_alpha`, `dsmil_bravo`).
   * Redis stream names prefixed per tenant: `ALPHA_L3_IN`, `BRAVO_L3_IN`, etc.
   * Vector DB collections separated: `alpha_events`, `bravo_events`.

2. **Auth / API**

   * Per-tenant API keys / JWT issuers.
   * L7 router / L8 / L9 always attach `tenant_id` to logs + decisions.

3. **Logging**

   * Journald tags include tenant where applicable (e.g. `SYSLOG_IDENTIFIER=dsmil-l8-ALPHA` for per-tenant containers).
   * SHRINK can either:

     * track all logs but tag by tenant, or
     * run **one SHRINK per tenant** if you want stricter separation.

### B2. Policy segregation

Policy / ROE per tenant:

* Each tenant has its own **policy bundle** (OPA or custom JSON) for:

  * allowed actions,
  * allowed tools,
  * notification channels.
* L8/L9 always load a **tenant-specific policy** before returning any proposal.

---

## 5. Workstream C – SLOs, Autoscaling & Fault Tolerance

### C1. SLOs per layer

Define explicit SLOs (examples, tune later):

* L3: p99 < 50 ms, 99.9% uptime.
* L4: p99 < 100 ms.
* L5: p99 < 200 ms.
* L6: p99 < 300 ms.
* L7 (router): p99 < 500 ms for short prompts.
* L8: p99 < 200 ms for event enrichment.
* L9 COA: p99 < 2–3 s per scenario.

Expose:

* Prometheus metrics per service: `request_count`, `latency_histogram`, `error_rate`.
* Dashboards in Grafana per layer + per tenant.

### C2. Autoscaling (simple version)

Without MLOps/K8s, use:

* **Horizontal scaling via multiple containers**:

  * e.g. 2× `dsmil-l7-router` on AI node, behind a local load-balancer (Caddy or HAProxy).
* Autoscaling trigger:

  * Cron / small controller reading Prometheus metrics:

    * if p95 latency > threshold or queue > N, start another container;
    * when idle, scale down.

Everything done via simple scripts or Portainer API, not K8s operators.

### C3. Fault tolerance

* All critical services:

  * `Restart=always` in systemd (if you still use mixed bare-metal).
  * Health checks + `/healthz` endpoints.
* Redis / Postgres / Loki:

  * At least backups + snapshot scripts.
  * Optional: a replica node for data services.

---

## 6. Workstream D – Operator UX & Tooling

This phase should leave you with **clean human interfaces**:

### D1. `dsmilctl` grown-up

Extend CLI to:

* `dsmilctl status` – multi-node status with colours and SLO markers.
* `dsmilctl soc top` – shows hottest SOC events and L8 flags.
* `dsmilctl l7 test` – smoke test L7 profiles.
* `dsmilctl tenant list/show` – quick view of tenants, isolation status.

Implementation: one binary that talks to a small control API on each node (or reads from service registry).

### D2. Kitty cockpit multi-node

Update your kitty session(s):

* One tab per node:

  * Node A: SOC/L8/L9 logs + SOC events.
  * Node B: L5/L6/L7 logs + hardware metrics.
  * Node C: Redis/Loki/Postgres health.
* Hotkeys for:

  * `dsmilctl status`,
  * L7 test prompt,
  * tailing `/var/log/dsmil.log` filtered by tenant or layer.

### D3. Dashboards

Grafana boards:

* “Global Overview” – traffic, latencies, errors across nodes.
* “SOC View” – SOC_EVENTS, severities, L8 flags, SHRINK risk.
* “Exec View” – L9 COAs, risk levels, scenario heatmap.

---

## 7. Workstream E – Security & Red-Teaming in Distributed Mode

Now that it’s multi-node:

* Lock down **inter-node links**:

  * mTLS between nodes,
  * PQC or at least strong TLS, as your stack allows.
* Run **internal red-team drills**:

  * tenant escape attempts,
  * log tampering attempts,
  * model misuse attempts (prompt injection, overreach of L8/L9).

Feed findings back into:

* L8 advml rules,
* policy engine rules,
* SHRINK thresholds.

---

## 8. Phase 5 Checklist

Phase 5 is done when:

* [ ] Services are split across ≥3 nodes (SOC, AI, DATA) with clear boundaries.
* [ ] Containerized stacks run reliably; service restarts and health checks proven.
* [ ] Tenants/missions are isolated at data, auth, and logging layers.
* [ ] SLOs are defined and reflected in Grafana; violations are alerting.
* [ ] L7/L8/L9 can scale horizontally where needed.
* [ ] `dsmilctl` + kitty cockpit workflows cover 90% of operator actions.
* [ ] Initial red-team tests on the distributed setup completed, with findings fed into policy/L8.

If you want to keep going, the **next phase** after this would usually be:
**productization / external API contracts + documentation** (turning DSMIL into something you can give to other teams/clients).
