# Decision: known locations UI + UISpecialFrames-only ESC handling

## Date
2026-03-31

## Problem
1. Known locations were persisted but not browseable/selectable from addon UI.
2. Transport Management did not close cleanly with ESC.
3. Main UI and tuning UI used keyboard capture for ESC, which could also close unrelated windows.

## Decision
- Add a dedicated Known Locations frame with a one-click route action.
- Reuse the Transport Management frame instead of recreating it.
- Remove keyboard-capture ESC handling from top-level addon windows and rely on `UISpecialFrames`.

## Rationale
This preserves routing semantics while improving UX and ensures ESC closes only the most recently used CustomWaypoints frame instead of cascading through unrelated addon windows.

## Non-goals
- no routing graph redesign
- no queue/history redesign
- no sync redesign


## 2026-04-03 follow-up
- ESC close order is intended to be modal/MRU within CustomWaypoints windows.
- Known Locations should close before the main CW UI when both are open.
- Routing Tuning should close directly on ESC.
- `UISpecialFrames` is not the desired primary close-order mechanism for overlapping CW windows.
