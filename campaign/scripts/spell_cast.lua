--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

local nLevel
local bCastasRitual = false

function onInit()
    if super and super.onInit then
        super.onInit();
    end
    local node = window.getDatabaseNode()
    nLevel = DB.getValue(node, "level", 0)
    setCastToolTip(nLevel)
end

function setCastToolTip(bRitual)
    local sToolTip
    local node = window.getDatabaseNode()
    local sDescription = DB.getValue(node, "description", "")
    local sSchool = DB.getValue(node, "school", "")
    local nRitual = DB.getValue(node, "ritual", 0)
    local rActor = ActorManager.resolveActor(node.getParent().getParent())
    if sSchool == "Abjuration" and ArcaneWard.hasArcaneWard(rActor) then
        sToolTip = "Arcane Ward"
    else
        sToolTip = "Cast"
    end
    if bRitual == true then
        sToolTip = sToolTip .. " as Ritual"
    elseif sDescription:match("At Higher Levels") or nRitual == 1 then
        sToolTip = sToolTip .. " as lvl " .. tostring(nLevel)
    end
    setTooltipText(sToolTip)
end

function onButtonPress()
    if super and super.onButtonPress() then
        super.onButtonPress()
    end
    local node = window.getDatabaseNode()
    local nRitual = DB.getValue(node, "ritual", 0)
    local sGroup = DB.getValue(node, "group", "")
    local sSchool = DB.getValue(node, "school", "")
    local nBaseLevel = DB.getValue(node, "level", 0)
    local rActor = ActorManager.resolveActor(node.getParent().getParent())
    local sDescription = DB.getValue(node, "description", "")

    if Input.isShiftPressed() and (sDescription:match("At Higher Levels") or nRitual == 1) then
        if nRitual == 1 then
            if bCastasRitual then
                bCastasRitual = false
            else
                bCastasRitual = true
            end
        else
            local aSpellslots = getSpellSlots(node.getParent().getParent())
            for i=nLevel,9  do
                if aSpellslots[i] and i > nLevel then
                    nLevel = i
                    break
                else
                    nLevel = nBaseLevel
                end
            end
        end
        setCastToolTip(bCastasRitual)
    else
        if not bCastasRitual then
            expendSpellSlot(node.getParent().getParent(), nLevel)
        end
        local nName = DB.getValue(node, "name", "")
        if sGroup == "Spells" and sSchool == "Abjuration" and ArcaneWard.hasArcaneWard(rActor) then
            ArcaneWard.castAbjuration(node.getParent().getParent(), nLevel, nName)
        else
            local rMessage = ChatManager.createBaseMessage(rActor, DB.getValue(nodeActor,"name"));
			-- rMessage.secret
			rMessage.icon = "ArcaneWard"
			rMessage.text = rMessage.text .."Begins [CAST] " .. nName .. " [LVL " .. nLevel .."]"
			Comm.deliverChatMessage(rMessage)
        end
        bCastasRitual = false
        nLevel = nBaseLevel
        setCastToolTip()
    end
end

function getSpellSlots(nodeChar)
    local aSpellSlots = {}
    for i=1,9 do
        local nSlotsMax = DB.getValue(nodeChar, "powermeta.spellslots".. tostring(i) .. ".max", 0)
        local nSlotsUsed = DB.getValue(nodeChar, "powermeta.spellslots".. tostring(i) .. ".used", 0)
        if nSlotsUsed < nSlotsMax then
            aSpellSlots[i] =  nSlotsUsed
        end
    end
    return aSpellSlots
end

function expendSpellSlot(nodeChar, nLevel)
    local sSlotUsedString = "powermeta.spellslots".. tostring(nLevel) .. ".used"
    local nSlotsMax = DB.getValue(nodeChar, "powermeta.spellslots".. tostring(nLevel) .. ".max", 0)
    local nSlotsUsed = DB.getValue(nodeChar, sSlotUsedString, 0)

    if nSlotsUsed < nSlotsMax then
        DB.setValue(nodeChar, sSlotUsedString, "number", nSlotsUsed+1)
    end
end