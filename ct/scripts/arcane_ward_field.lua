--		Author: Shane Parker
--		Copyright © 2023
--		This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--		https://creativecommons.org/licenses/by-sa/4.0/
--
-- luacheck: globals onInit updateWidget onWheel getArcaneWard setArcaneWard addTextWidget
local nodeWard;
local widgetWard;

function onInit()
    if super and super.onInit then
        super.onInit();
    end

    widgetWard = addTextWidget({font = 'sheettext', text = '0', position = 'topright', x = 3, y = 1, frame = 'tempmodmini', frameoffset = '3,1,6,3'});
    widgetWard.setVisible(false);

    local nodeActor = ActorManager.getCreatureNode(window.getDatabaseNode());
    local sNodeString = ArcaneWard.getDBString(nodeActor);
    nodeWard = DB.getChild(nodeActor, sNodeString);
    if nodeWard then
        nodeWard.onUpdate = updateWidget;
        updateWidget();
    end
end

function updateWidget()
    if nodeWard then
        local nValue = nodeWard.getValue();
        widgetWard.setText(nValue);
        widgetWard.setVisible(nValue ~= 0);
    end
end

function onWheel(notches)
    local bResult = false;
    if super and super.onWheel then
        bResult = super.onWheel(notches);
    end

    if Input.isShiftPressed() then
        setArcaneWard(getArcaneWard() + notches);
        bResult = true;
    end

    return bResult;
end

function getArcaneWard()
    if nodeWard then
        return nodeWard.getValue();
    end
    return 0;
end

function setArcaneWard(nValue)
    if nodeWard then
        nValue = math.max(0, nValue);
        nodeWard.setValue(nValue);
    end
end
