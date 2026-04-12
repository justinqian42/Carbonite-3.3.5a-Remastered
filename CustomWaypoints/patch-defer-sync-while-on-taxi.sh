#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import re

path = Path("CustomWaypoints/CustomWaypoints.lua")
text = path.read_text(encoding="utf-8")

if "local function SyncQueueToCarboniteRespectingTaxi(reason)" not in text:
    anchor = r'''SyncQueueToCarbonite = function()
    local map = GetMap()
    if not map then
        pr("sync failed: Carbonite map not ready")
        return false
    end

    local route, why = BuildExpandedRoute()
    if not route then
        pr("route rebuild failed: " .. tostring(why))
        return false
    end

    InstallCarboniteTravelHook()
    ClearCarboniteTargets(map)

    local syncPoints = BuildSyncPoints(route.points or {})
    local synced = 0
    STATE.syncing = true
    for i, pt in ipairs(syncPoints) do
        local ok, err = pcall(function()
            local label = BuildSyncLabel(i, pt)
            local targetType = GetTargetTypeForRoutePoint(pt)
            map:SeT3(targetType, pt.wx, pt.wy, pt.wx, pt.wy, nil, nil, label, true, pt.maI)
        end)
        if ok then
            synced = synced + 1
        else
            dbg("sync point failed: " .. tostring(err))
        end
    end
    STATE.syncing = false
    STATE.suppressClearUntil = (GetTime() or 0) + 0.75

    if synced == 0 then
        dbg("sync skipped: no route points")
        return true
    end

    dbg(format("synced %d expanded route node(s) into Carbonite", synced))
    return true
end
'''

    helper = anchor + r'''
local function SyncQueueToCarboniteRespectingTaxi(reason)
    if IsPlayerOnTaxi and IsPlayerOnTaxi() then
        STATE.pendingTaxiRouteRefresh = true
        dbg("sync deferred while on taxi: " .. tostring(reason or "unspecified"))
        return true
    end

    return SyncQueueToCarbonite()
end
'''

    if anchor not in text:
        raise SystemExit("Patch failed: SyncQueueToCarbonite block not found.")

    text = text.replace(anchor, helper, 1)

replacements = [
    (
        r'(InvalidateRoute\("waypoint added"\)\s*\n\s*if STATE\.db\.autoSyncToCarbonite then\s*\n\s*)SyncQueueToCarbonite\(\)',
        r'\1SyncQueueToCarboniteRespectingTaxi("waypoint added")'
    ),
    (
        r'(InvalidateRoute\("labeled waypoint added"\)\s*\n\s*RefreshUiHeader\(\)\s*\n\s*if STATE\.db\.autoSyncToCarbonite then\s*\n\s*)SyncQueueToCarbonite\(\)',
        r'\1SyncQueueToCarboniteRespectingTaxi("labeled waypoint added")'
    ),
    (
        r'(InvalidateRoute\("current location waypoint added"\)\s*\n\s*RefreshUiHeader\(\)\s*\n\s*if STATE\.db\.autoSyncToCarbonite then\s*\n\s*)SyncQueueToCarbonite\(\)',
        r'\1SyncQueueToCarboniteRespectingTaxi("current location waypoint added")'
    ),
]

total = 0
for pattern, repl in replacements:
    text, n = re.subn(pattern, repl, text, count=1, flags=re.MULTILINE)
    total += n

if total == 0:
    raise SystemExit("Patch failed: no waypoint sync call sites were updated.")

path.write_text(text, encoding="utf-8")
print(f"Patched successfully: inserted taxi-safe sync helper and updated {total} waypoint sync call site(s).")
PY
