# Baseline Governance

## 1. Architecture Defect

A confirmed error, gap, or contradiction in the baseline itself.

- Fix the baseline first, then align implementation to the corrected baseline.
- Do not patch implementation around a defective baseline.

## 2. Architecture Drift

Implementation has deviated from a confirmed, correct baseline.

- Return to the baseline through the simplest path.
- Do not update the baseline merely to match drift without explicit review.

## 3. Baseline Check Protocol

Before non-trivial changes:

1. Read the latest baseline snapshot in `baseline/`.
2. Compare current code structure against the ownership map.
3. Compare current contracts against the contract inventory.
4. Check for new anti-patterns not recorded in the known list.
5. Report aligned, minor drift, or material drift.

## 4. Architecture Review — Seven Dimensions

1. Ownership integrity.
2. Module boundaries.
3. Contract changes.
4. Cascade proliferation.
5. Dependency direction.
6. Retirement completeness.
7. Entropy flow.

## 5. Hard Boundaries

- This file governs this repository's Aegis workspace only.
- Baseline snapshots are evidence, not executable authority.
- ADRs record decisions but do not replace baseline governance.
- Changes to this file require explicit review.
