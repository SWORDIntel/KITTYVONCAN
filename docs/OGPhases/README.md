# OGPhases - Historical Reference

> **Status: HISTORICAL ARCHIVE**
> **Date Archived: 2025-12-01**

## Purpose

This folder contains the **original 8 phases** of the DSMIL implementation plan as they were first written. These documents are preserved for historical reference and to understand the evolution of the architecture.

## Current Documentation

For the **current, actively maintained** phase documentation, see:

```
../comprehensive-plan/Phases/
```

The current documentation includes:
- Phases 1-14 (expanded from original 8)
- Phase index with dependencies and checklists
- Updated timelines and resource requirements

## Contents of OGPhases

| File | Description |
|------|-------------|
| Phase1.md | Software brief for DSMIL AI stack (7-layer system) |
| Phase2F.md | Fast Fabric + SHRINK-SOC Bring-Up |
| Phase3.md | Master Plan Overview v3.1 (104 devices, architecture correction) |
| Phase4.md | L8/L9 Activation & Governance Plane |
| Phase5.md | Distributed Deployment & Hardening |
| Phase6.md | Secure API Plane + Local OpenAI Shim |
| Phase7.md | Quantum-Safe Internal Mesh (DBE Protocol) |
| Phase7B.md | Duplicate of Phase7.md |

## Key Differences from Current

| Aspect | OGPhases | Current (comprehensive-plan/Phases) |
|--------|----------|-------------------------------------|
| Total Phases | 8 (1-7B) | 14 (1-14) |
| Exercise Framework | Not included | Phase 10 |
| External Military Comms | Not included | Phase 11 |
| Enhanced Access Controls | Not included | Phase 12 |
| Full Admin Control | Not included | Phase 13 |
| Layer 5 Full Access | Not included | Phase 14 |
| Phase Index | Not included | 00_PHASES_INDEX.md |

## Architecture Notes

The OGPhases describe a **10-layer architecture** (Layers 0-9) with 104 devices organized by security clearance levels:

- Layer 0-1: LOCKED/PUBLIC
- Layer 2: TRAINING
- Layer 3: SECRET (50 TOPS)
- Layer 4: TOP_SECRET (65 TOPS)
- Layer 5: COSMIC (105 TOPS)
- Layer 6: ATOMAL (160 TOPS)
- Layer 7: EXTENDED (440 TOPS) - Primary AI layer
- Layer 8: ENHANCED_SEC (188 TOPS) - Security AI
- Layer 9: EXECUTIVE (330 TOPS) - Strategic Command

This architecture coexists with the `ai/brain` CEREBRUM architecture (15 layers) which focuses on AI capabilities rather than clearance levels.

## Do Not Modify

These files are preserved as-is. Any updates should be made to the canonical documentation in `../comprehensive-plan/Phases/`.

