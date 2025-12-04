# DSMIL Documentation Index

> **Last Updated:** 2025-12-01
> **Status:** CANONICAL REFERENCE
> **Purpose:** Master index of all DSMIL documentation locations

## Quick Navigation

- [Canonical Documentation](#canonical-documentation)
- [Historical Archives](#historical-archives)
- [Deprecated Locations](#deprecated-locations)
- [Reference Documents](#reference-documents)
- [Implementation Guides](#implementation-guides)

---

## Canonical Documentation

### Architecture & Planning

**Location:** `docs/comprehensive-plan/`

| Document | Description | Status |
|----------|-------------|--------|
| `00_MASTER_PLAN_OVERVIEW_CORRECTED.md` | High-level architecture overview (104 devices, 1440 TOPS) | ✅ Canonical |
| `01_HARDWARE_INTEGRATION_LAYER_DETAILED.md` | Hardware specs (NPU, GPU, CPU) | ✅ Canonical |
| `02_QUANTUM_INTEGRATION_QISKIT.md` | Quantum computing integration | ✅ Canonical |
| `03_MEMORY_BANDWIDTH_OPTIMIZATION.md` | Memory allocation strategy | ✅ Canonical |
| `04_MLOPS_PIPELINE.md` | MLOps architecture | ✅ Canonical |
| `05_LAYER_SPECIFIC_DEPLOYMENTS.md` | Layer-by-layer deployment details | ✅ Canonical |
| `06_CROSS_LAYER_INTELLIGENCE_FLOWS.md` | Inter-layer communication | ✅ Canonical |
| `07_IMPLEMENTATION_ROADMAP.md` | Main implementation roadmap (Phases 1-9) | ✅ Canonical |

### Phase Documentation

**Location:** `docs/comprehensive-plan/Phases/`

| Document | Phase | Description |
|----------|-------|-------------|
| `00_PHASES_INDEX.md` | Index | Complete phase overview, dependencies, checklists |
| `Phase1.md` | 1 | Foundation & Hardware Validation |
| `Phase2F.md` | 2 | Core Analytics - Layers 3-5 |
| `Phase3.md` | 3 | LLM & GenAI - Layer 7 |
| `Phase4.md` | 4 | Security AI - Layer 8 |
| `Phase5.md` | 5 | Strategic Command + Quantum - Layer 9 |
| `Phase6.md` | 6 | Hardening & Production Readiness |
| `Phase6_OpenAI_Shim.md` | 6-Supp | OpenAI-compatible API adapter |
| `Phase7.md` | 7 | Quantum-Safe Internal Mesh (DBE Protocol) |
| `Phase8.md` | 8 | Advanced Analytics & ML Pipeline Hardening |
| `Phase9.md` | 9 | Continuous Optimization & Operational Excellence |
| `Phase10.md` | 10 | Exercise & Simulation Framework |
| `Phase11.md` | 11 | External Military Communications Integration |
| `Phase12.md` | 12 | Enhanced L8/L9 Access Controls |
| `Phase13.md` | 13 | Full Administrative Control |
| `14_LAYER5_FULL_ACCESS.md` | 14 | Layer 5 Full Access Implementation |

**Total:** 14 phases + index

---

## Reference Documents

**Location:** `docs/`

| Document | Purpose |
|----------|---------|
| `ARCHITECTURE_RECONCILIATION.md` | Explains DSMIL 10-layer vs CEREBRUM 15-layer architecture |
| `IMPLEMENTATION_STATUS.md` | Verification status of OGPhases components |
| `DEVICE_ID_MAPPING.md` | Maps logical IDs (0-103) to hex IDs (0x8000-0x80FF) |
| `CONSOLIDATION_PLAN.md` | Documentation consolidation analysis and options |
| `NEXT_STEPS.md` | Actionable steps for documentation cleanup |
| `SYNC_SUMMARY.md` | Files that needed syncing |
| `SYNC_COMPLETE.md` | Sync completion status |
| `DOCUMENTATION_INDEX.md` | This document |

---

## Historical Archives

### OGPhases (Original 8 Phases)

**Location:** `docs/OGPhases/`

**Status:** Historical reference - preserved for evolution tracking

| File | Description |
|------|-------------|
| `Phase1.md` | Original software brief |
| `Phase2F.md` | Original fast fabric + SHRINK |
| `Phase3.md` | Original master plan v3.1 |
| `Phase4.md` | Original L8/L9 activation |
| `Phase5.md` | Original distributed deployment |
| `Phase6.md` | Original API + OpenAI shim |
| `Phase7.md` | Original DBE protocol |
| `Phase7B.md` | Duplicate of Phase7 |
| `README.md` | Historical archive notice |

**Note:** These are the original 8 phases. Current canonical documentation has 14 phases.

---

## Deprecated Locations

### ⚠️ DO NOT USE - Redirect to Canonical Locations

| Location | Status | Redirect To |
|----------|--------|-------------|
| `technical/comprehensive-plan/Phases/` | **DEPRECATED** | `docs/comprehensive-plan/Phases/` |
| `technical/comprehensive-plan/KitttyPhases/` | **DEPRECATED** | `docs/comprehensive-plan/Phases/` |

**Note:** `technical/comprehensive-plan/` architecture docs (00-07) are kept for backward compatibility but are duplicates of `docs/comprehensive-plan/`.

---

## Implementation Guides

### Hardware & System Configuration

**Location:** `technical/Implementation/`

| Document | Purpose |
|----------|---------|
| `ATOMAL_CONFIGURATION_OVERLAYS.md` | Layer 6 (ATOMAL) configuration and compartments |
| `INTEL_GPU_SETUP.md` | Intel Arc GPU setup for AI workloads |
| `OFFSET0_BYPASS_STATUS.md` | Offset0 bypass configuration |
| `SMBIOS_STORAGE_FIX.md` | SMBIOS storage configuration fixes |

### System Activation

**Location:** `technical/System-Activation/`

| Document | Purpose |
|----------|---------|
| `COMPLETE_SYSTEM_ACTIVATION_SUMMARY.md` | Complete system activation status (104/104 devices) |
| `CONSOLIDATION_AND_ENHANCEMENT_SUMMARY.md` | System consolidation summary |

**Note:** There is also a copy of `COMPLETE_SYSTEM_ACTIVATION_SUMMARY.md` in the root directory - both are identical.

### AI Engine Documentation

**Location:** `technical/`

| Document | Purpose |
|----------|---------|
| `AI_ENGINE_V2_IMPROVEMENTS.md` | Complete V2 enhancement summary (Version 3.0.0) |
| `AI_ARCHITECTURE_PLANNING_GUIDE.md` | AI architecture planning guide |
| `ADVANCED_LAYERS_IMPLEMENTATION_GUIDE.md` | Advanced layers implementation guide |
| `COMPLETE_AI_ARCHITECTURE_LAYERS_3_9.md` | Complete AI architecture for Layers 3-9 |
| `HARDWARE_AI_CAPABILITIES_REFERENCE.md` | Hardware AI capabilities reference |
| `INTEL-API.md` | Intel API documentation |

### Hardware Documentation

**Location:** `technical/Hardware/`

| Document | Purpose |
|----------|---------|
| `DSMIL_COMPLETE_INVENTORY.md` | Complete device inventory |
| `EXISTING_HARDWARE_DEVICE_MAPPING.md` | Hardware-to-device mapping |
| `HARDWARE_SKU_MAPPING.md` | Hardware SKU reference |
| `INTERNAL_HARDWARE_MAPPING.md` | Internal hardware topology |

---

## Documentation Structure

```
KITTYVONCAN/
├── docs/                                    # CANONICAL DOCUMENTATION
│   ├── comprehensive-plan/                  # Architecture & planning
│   │   ├── 00_MASTER_PLAN_OVERVIEW_CORRECTED.md
│   │   ├── 01-07_*.md                       # Architecture docs
│   │   └── Phases/                          # Phase 1-14 (canonical)
│   ├── OGPhases/                            # Historical archive (original 8 phases)
│   └── DOCUMENTATION_INDEX.md               # This file
│
├── technical/                                # TECHNICAL DOCUMENTATION
│   ├── comprehensive-plan/                   # Duplicate (backward compat)
│   │   ├── 00-07_*.md                       # Identical to docs/
│   │   ├── Phases/                          # DEPRECATED (redirect to docs/)
│   │   └── KitttyPhases/                    # DEPRECATED (redirect to docs/)
│   ├── AI_ENGINE_V2_IMPROVEMENTS.md         # AI Engine V2 enhancements
│   ├── AI_ARCHITECTURE_PLANNING_GUIDE.md     # AI architecture planning
│   ├── COMPLETE_AI_ARCHITECTURE_LAYERS_3_9.md # Complete AI architecture
│   ├── Implementation/                      # Implementation guides
│   ├── System-Activation/                   # Activation summaries
│   └── Hardware/                            # Hardware documentation
│
└── COMPLETE_SYSTEM_ACTIVATION_SUMMARY.md    # Duplicate (same as technical/)
```

---

## Quick Reference

### Where to Find...

**Architecture Overview:**
→ `docs/comprehensive-plan/00_MASTER_PLAN_OVERVIEW_CORRECTED.md`

**Phase Documentation:**
→ `docs/comprehensive-plan/Phases/` (Phases 1-14)

**Hardware Specs:**
→ `docs/comprehensive-plan/01_HARDWARE_INTEGRATION_LAYER_DETAILED.md`
→ `technical/Hardware/DSMIL_COMPLETE_INVENTORY.md`

**Implementation Status:**
→ `docs/IMPLEMENTATION_STATUS.md`

**Device ID Mapping:**
→ `docs/DEVICE_ID_MAPPING.md`

**System Activation Status:**
→ `technical/System-Activation/COMPLETE_SYSTEM_ACTIVATION_SUMMARY.md`

**AI Engine Documentation:**
→ `technical/AI_ENGINE_V2_IMPROVEMENTS.md` (V2 enhancements, Version 3.0.0)
→ `technical/AI_ARCHITECTURE_PLANNING_GUIDE.md`
→ `technical/COMPLETE_AI_ARCHITECTURE_LAYERS_3_9.md`

---

## Migration Guide

### If You're Using Deprecated Paths

**Old:** `technical/comprehensive-plan/Phases/Phase1.md`
**New:** `docs/comprehensive-plan/Phases/Phase1.md`

**Old:** `technical/comprehensive-plan/KitttyPhases/Phase1.md`
**New:** `docs/comprehensive-plan/Phases/Phase1.md`

**Old:** `technical/comprehensive-plan/00_MASTER_PLAN_OVERVIEW_CORRECTED.md`
**New:** `docs/comprehensive-plan/00_MASTER_PLAN_OVERVIEW_CORRECTED.md` (preferred)

---

## Contributing

### Where to Edit Documentation

1. **Architecture Docs (00-07):** Edit in `docs/comprehensive-plan/`
2. **Phase Docs:** Edit in `docs/comprehensive-plan/Phases/`
3. **Reference Docs:** Edit in `docs/`
4. **Implementation Guides:** Edit in `technical/Implementation/`
5. **Hardware Docs:** Edit in `technical/Hardware/`

### Do NOT Edit

- `docs/OGPhases/` (historical archive)
- `technical/comprehensive-plan/Phases/` (deprecated)
- `technical/comprehensive-plan/KitttyPhases/` (deprecated)

---

## Version History

- **v1.0 (2025-12-01):** Initial documentation index created
  - Mapped all canonical locations
  - Documented deprecated paths
  - Created migration guide

---

**Last Updated:** 2025-12-01
**Maintainer:** DSMIL Documentation Team

