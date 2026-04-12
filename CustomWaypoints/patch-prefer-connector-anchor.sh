#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

path = Path("CustomWaypoints.lua")
text = path.read_text(encoding="utf-8")

old = r'''local function CollapseMinimalTransitNoise(points)
    if type(points) ~= "table" or #points <= 2 then
        return points
    end

    local out = { points[1] }
    local runLast = nil

    local function ClonePoint(pt)
        local copy = {}
        for k, v in pairs(pt or {}) do copy[k] = v end
        return copy
    end

    for i = 2, #points do
        local pt = points[i]
        local isTransport = pt and pt.edgeType and STRAIGHT_EDGE_TYPES[pt.edgeType]
        if isTransport then
            if runLast then
                local walkAnchor = ClonePoint(runLast)
                walkAnchor.edgeType = "walk-to-transport"
                walkAnchor.label = "walk-to-transport"
                out[#out + 1] = walkAnchor
                runLast = nil
            end
            out[#out + 1] = pt
        else
            runLast = pt
        end
    end

    if runLast then
        local goalAnchor = ClonePoint(runLast)
        goalAnchor.edgeType = "node-to-goal"
        goalAnchor.label = "node-to-goal"
        out[#out + 1] = goalAnchor
    end

    return out
end
'''

new = r'''local function CollapseMinimalTransitNoise(points)
    if type(points) ~= "table" or #points <= 2 then
        return points
    end

    local out = { points[1] }
    local run = {}

    local function ClonePoint(pt)
        local copy = {}
        for k, v in pairs(pt or {}) do copy[k] = v end
        return copy
    end

    local function PushRunPoint(pt)
        if pt then
            run[#run + 1] = pt
        end
    end

    local function SelectRunAnchorForTransport()
        if #run == 0 then return nil end

        -- Minimal-mode invariant:
        -- if the graph already reached a real connector/walklink before a transport leg,
        -- sync straight to that connector rather than to an arbitrary interior same-map node.
        for i = #run, 1, -1 do
            local pt = run[i]
            if pt and (pt.edgeType == "connector" or pt.edgeType == "walklink") then
                return pt
            end
        end

        return run[#run]
    end

    local function SelectRunAnchorForGoal()
        if #run == 0 then return nil end
        return run[#run]
    end

    for i = 2, #points do
        local pt = points[i]
        local isTransport = pt and pt.edgeType and STRAIGHT_EDGE_TYPES[pt.edgeType]
        if isTransport then
            local anchor = SelectRunAnchorForTransport()
            if anchor then
                local walkAnchor = ClonePoint(anchor)
                walkAnchor.edgeType = "walk-to-transport"
                walkAnchor.label = "walk-to-transport"
                out[#out + 1] = walkAnchor
            end
            run = {}
            out[#out + 1] = pt
        else
            PushRunPoint(pt)
        end
    end

    local goalAnchorSource = SelectRunAnchorForGoal()
    if goalAnchorSource then
        local goalAnchor = ClonePoint(goalAnchorSource)
        goalAnchor.edgeType = "node-to-goal"
        goalAnchor.label = "node-to-goal"
        out[#out + 1] = goalAnchor
    end

    return out
end
'''

if old not in text:
    raise SystemExit("Patch failed: CollapseMinimalTransitNoise block not found.")

text = text.replace(old, new, 1)
path.write_text(text, encoding="utf-8")
print("Patched CollapseMinimalTransitNoise: prefer connector anchors before transport.")
PY