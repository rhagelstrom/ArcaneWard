--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/
local bCallbacksRegistered = false
function onInit()
    if super and super.onInit then
        super.onInit()
    end
    if ArcaneWard.hasSAI() then
        setAnchor("left", "additional_info", "right", "relative")
    end
    OptionsManager.registerCallback("ARCANE_WARD_SPELL_CAST_GAME", optionChange)
    OptionsManager.registerCallback("ARCANE_WARD_SPELL_CAST", optionChange)
    OptionsManager.registerCallback("ARCANE_WARD_PACT", defaultButton)
    optionChange()
end

function onClose()
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST_GAME", optionChange)
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST", optionChange)
    OptionsManager.unregisterCallback("ARCANE_WARD_PACT", defaultButton)
    optionChange(true)
    if super and super.onClose then
        super.onClose()
    end
end

function defaultButton()

end

function optionChange(bClose)
    local node = window.getDatabaseNode()
    local aCastInfo = ArcaneWard.getCurrentCastInfo(node)
    aCastInfo = ArcaneWard.resetCastInfo(node, aCastInfo)

    if not bCallbacksRegistered and (OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "on") or
    OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "on") or aCastInfo.bHasArcaneWard) then
        registerCallbacks(aCastInfo)
        bCallbacksRegistered = true
    end
    if (not aCastInfo.bHasArcaneWard and bCallbacksRegistered and OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "off") and
    OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "off")) or (bClose and bCallbacksRegistered) then
        unRegisterCallbacks(aCastInfo)
        bCallbacksRegistered = false
    end
end

function registerCallbacks(aCastInfo)
    OptionsManager.registerCallback("ARCANE_WARD_PACT", onUpdate)
    local node = window.getDatabaseNode()
    local sNodePath =  node.getParent().getParent().getPath()

    if aCastInfo.bSpellcasting then
        if aCastInfo.bUpcast then
            for i=aCastInfo.nLevel,9 do
                DB.addHandler(sNodePath ..".powermeta.spellslots" .. tostring(i) .. ".used", "onUpdate", onUpdate)
                i = i + 1
            end
        else
            DB.addHandler(sNodePath ..".powermeta.spellslots".. tostring(aCastInfo.nLevel) .. ".used", "onUpdate", onUpdate)
        end
    end

    if aCastInfo.bPactMagic then
        for i=1,5 do
            DB.addHandler(sNodePath ..".powermeta.pactmagicslots".. tostring(i) .. ".used", "onUpdate", onUpdate)
        end
    end

    DB.addHandler(node.getPath() ..".arcanewardcastaspact", "onUpdate", onUpdate)
    setCastToolTip(aCastInfo)
end

function unRegisterCallbacks(aCastInfo)
    OptionsManager.unregisterCallback("ARCANE_WARD_PACT", onUpdate)
    local node = window.getDatabaseNode()
    local sNodePath =  node.getParent().getParent().getPath()

    if aCastInfo.bSpellcasting then
        if aCastInfo.bUpcast then
            for i=aCastInfo.nLevel,9 do
                DB.removeHandler(sNodePath ..".powermeta.spellslots" .. tostring(i) ..".used", "onUpdate", onUpdate)
                i = i + 1
            end
        else
            DB.removeHandler(sNodePath ..".powermeta.spellslots".. tostring(aCastInfo.nLevel) .. ".used", "onUpdate", onUpdate)
        end
    end

    if aCastInfo.bPactMagic then
        for i=1,5 do
            DB.removeHandler(sNodePath ..".powermeta.pactmagicslots".. tostring(i) .. ".used", "onUpdate", onUpdate)
            i = i+1
        end
    end
    DB.removeHandler(node.getPath() ..".arcanewardcastaspact", "onUpdate", onUpdate)
end

function onUpdate()
    local node = window.getDatabaseNode()
    local aCastInfo = ArcaneWard.getCurrentCastInfo(node)
    aCastInfo = ArcaneWard.resetCastInfo(node, aCastInfo)
    setCastToolTip(aCastInfo)
end

function setCastToolTip(aCastInfo)
    local sToolTip
    if aCastInfo.bAbjuration and aCastInfo.bHasArcaneWard then
        sToolTip = "Arcane Ward"
    else
        sToolTip = "Cast"
    end
    if not aCastInfo.bCastasPact then
        if aCastInfo.bCastasRitual then
            sToolTip = sToolTip .. " as Ritual"
        elseif  aCastInfo.bUpcast or  aCastInfo.bRitual  then
            sToolTip = sToolTip .. " as Lvl " .. tostring(aCastInfo.nCastLevel)
        end
    else
        if aCastInfo.bCastasPactRitual then
            sToolTip = sToolTip .. " as Ritual"
        else
            sToolTip = sToolTip .. " Pact Lvl " .. tostring(aCastInfo.nPactLevel)
        end
    end
    setTooltipText(sToolTip)
end

function onButtonPress()
    if super and super.onButtonPress() then
        super.onButtonPress()
    end

    local node = window.getDatabaseNode()
    local rActor = ActorManager.resolveActor(node.getParent().getParent())
    local aCastInfo = ArcaneWard.getCurrentCastInfo(node)

    if Input.isShiftPressed() and (aCastInfo.bUpcast or aCastInfo.bRitual) then
            aCastInfo = ArcaneWard.getCurrentCastInfo(node, true)
    elseif aCastInfo.bSpellcasting and aCastInfo.bPactMagic and Input.isControlPressed() then
        if aCastInfo.bCastasPact and not aCastInfo.bNoSpellSlotsAvailable then
            DB.setValue(node,"arcanewardcastaspact", "number", 0)
        elseif  not aCastInfo.bCastasPact and not aCastInfo.NoPactSlotsAvailable then
            DB.setValue(node,"arcanewardcastaspact", "number", 1)
        end
        aCastInfo = ArcaneWard.getCurrentCastInfo(node)
    else
        if aCastInfo.bCastasPact and not aCastInfo.bCastasPactRitual then
            ArcaneWard.expendSpellSlot(node.getParent().getParent(), aCastInfo.nPactLevel, true)
        elseif  not aCastInfo.bCastasPact and not aCastInfo.bCastasRitual then
            ArcaneWard.expendSpellSlot(node.getParent().getParent(), aCastInfo.nCastLevel, false)
        end
        local sName = DB.getValue(node, "name", "")
        if aCastInfo.bAbjuration and aCastInfo.bHasArcaneWard then
            if aCastInfo.bCastasPact then
                ArcaneWard.castAbjuration(node.getParent().getParent(), aCastInfo.nPactLevel, sName, true)
            else
                ArcaneWard.castAbjuration(node.getParent().getParent(), aCastInfo.nCastLevel, sName, false)
            end
        else
            local rMessage = ChatManager.createBaseMessage(rActor, DB.getValue(nodeActor,"name"))
            rMessage.icon = "ArcaneWardCast"
            if aCastInfo.bCastasRitual or aCastInfo.bCastasPactRitutal then
                rMessage.text = rMessage.text .."Begins [CAST] " .. sName .. " [AS RITUAL]"
            elseif aCastInfo.bCastasPact then
                rMessage.text = rMessage.text .."Begins [CAST] " .. sName .. " [PACT LEVEL " .. tostring(aCastInfo.nPactLevel) .."]"
            else
                rMessage.text = rMessage.text .."Begins [CAST] " .. sName .. " [LEVEL " .. tostring(aCastInfo.nCastLevel) .."]"
            end
            Comm.deliverChatMessage(rMessage)
        end
        aCastInfo = ArcaneWard.resetCastInfo(node, aCastInfo)
    end
    setCastToolTip(aCastInfo)
end

