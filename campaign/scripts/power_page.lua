--
-- Please see the license.txt file included with this distribution for
-- attribution and copyright information.
--
--
-- luacheck: globals onInit turnStart optionChange updateUses onModeChanged
function onInit()
    CombatManager.setCustomTurnStart(turnStart);
    if super and super.onInit() then
        super.onInit();
    end
end

function turnStart()
    if super and super.updateUses() then
        super.updateUses();
    end
end

function onModeChanged()
    if super and super.onModeChanged() then
        super.onModeChanged();
    end
    if super and super.updateUses() then
        super.updateUses();
    end
end

function updateUses()
    local nodeChar = getDatabaseNode();
    if CharPowerManager.arePowerUsageUpdatesPaused(nodeChar) then
        return;
    end
    local tDelayedUpdates = {};
    local sMode = DB.getValue(nodeChar, 'powermode', '');

    if sMode == 'combat' then
        CharPowerManager.pausePowerUsageUpdates(nodeChar);
        for _, v in pairs(powers.getWindows()) do
            if v.getClass() ~= 'power_group_header' then
                tDelayedUpdates[v.getDatabaseNode().getPath()] = v.getFilter();
            else
                tDelayedUpdates[v.group.getValue()] = v.getFilter();
            end
        end
        CharPowerManager.resumePowerUsageUpdates(nodeChar);

        if super and super.updateUses() then
            super.updateUses();
        end

        CharPowerManager.pausePowerUsageUpdates(nodeChar);
        for _, v in pairs(powers.getWindows()) do
            if v.getClass() ~= 'power_group_header' then
                v.setFilter(v.getFilter() or tDelayedUpdates[v.getDatabaseNode().getPath()]);
            else
                v.setFilter(v.getFilter() or tDelayedUpdates[v.group.getValue()]);
            end
        end

        powers.applyFilter();
        CharPowerManager.resumePowerUsageUpdates(nodeChar);
    else
        if super and super.updateUses() then
            super.updateUses();
        end
    end
end
