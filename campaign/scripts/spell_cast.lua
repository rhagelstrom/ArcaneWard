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
    local aSpellParams = ArcaneWard.getUpcastRitual(node)
    setCastToolTip(aSpellParams)

    if ArcaneWard.hasSAI() then
        setAnchor("left", "components_text_label", "right", "relative");
    end
end

function setCastToolTip(aSpellParams)
    local sToolTip
    if aSpellParams.sSchool == "Abjuration" and aSpellParams.bHasArcaneWard then
        sToolTip = "Arcane Ward"
    else
        sToolTip = "Cast"
    end
    if bCastasRitual == true then
        sToolTip = sToolTip .. " as Ritual"
    elseif  aSpellParams.bUpcast or  aSpellParams.bRitual  then
        sToolTip = sToolTip .. " as Lvl " .. tostring(nLevel)
    end
    setTooltipText(sToolTip)
end

function onButtonPress()
    if super and super.onButtonPress() then
        super.onButtonPress()
    end

    local node = window.getDatabaseNode()
    local aSpellParams = ArcaneWard.getUpcastRitual(node)
    local sGroup = DB.getValue(node, "group", "")
    local rActor = ActorManager.resolveActor(node.getParent().getParent())

    if Input.isShiftPressed() and (aSpellParams.bUpcast or aSpellParams.bRitual) then
        setSpellSlot(aSpellParams, true)
    else
        setSpellSlot(aSpellParams, false)
        if not bCastasRitual then
            expendSpellSlot(node.getParent().getParent(), nLevel)
        end
        local nName = DB.getValue(node, "name", "")
            if sGroup == "Spells" and aSpellParams.sSchool == "Abjuration" and aSpellParams.bHasArcaneWard then
                ArcaneWard.castAbjuration(node.getParent().getParent(), nLevel, nName)
            else
                local rMessage = ChatManager.createBaseMessage(rActor, DB.getValue(nodeActor,"name"));
                -- rMessage.secret
                rMessage.icon = "ArcaneWard"
                if bCastasRitual then
                    rMessage.text = rMessage.text .."Begins [CAST] " .. nName .. " [AS RITUAL]"

                else
                    rMessage.text = rMessage.text .."Begins [CAST] " .. nName .. " [LEVEL " .. nLevel .."]"
                end
                Comm.deliverChatMessage(rMessage)
            end
        bCastasRitual = false
        nLevel = aSpellParams.nBaseLevel
        aSpellParams = ArcaneWard.getUpcastRitual(node)
        setSpellSlot(aSpellParams, false)
    end
end

function setSpellSlot(aSpellParams, bNext)
    -- Keep cast as ritual if we are not cycling
    if bCastasRitual and not bNext then
        setCastToolTip(aSpellParams)
        return
    end
    local nRet = nil
    -- Check to see if we have slots, else force cycle to something we can cast
    if  (aSpellParams.bHasSpellSlots or (aSpellParams.bUpcast and aSpellParams.aSpellSlots[nLevel])) and not bNext  then
        setCastToolTip(aSpellParams)
        return
    end

    if aSpellParams.bUpcast and next(aSpellParams.aSpellSlots) then
          --If  had cast as ritual, cycle to the next, which is base level for spell
        if bCastasRitual then
            bCastasRitual = false
            nLevel = aSpellParams.nBaseLevel
        end
        for i=nLevel,9  do
            if aSpellParams.bUpcast and aSpellParams.aSpellSlots[i] and i > nLevel then
                nRet = i
                break
            end
        end
    end
    if nRet == nil then
        nRet = aSpellParams.nBaseLevel
        if aSpellParams.bRitual then
            bCastasRitual = true
        end
    end

    nLevel = nRet
    setCastToolTip(aSpellParams)
end

function expendSpellSlot(nodeChar, nLevel)
    local nSlotsMax = DB.getValue(nodeChar, "powermeta.spellslots".. tostring(nLevel) .. ".max", 0)
    local nSlotsUsed = DB.getValue(nodeChar, "powermeta.spellslots".. tostring(nLevel) .. ".used", 0)

    if nSlotsUsed < nSlotsMax then
        DB.setValue(nodeChar, "powermeta.spellslots".. tostring(nLevel) .. ".used", "number", nSlotsUsed+1)
    end
end