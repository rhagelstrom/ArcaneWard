--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/
local bCallbacksRegistered = false
function onInit()
    if super and super.onInit then
        super.onInit()
    end
    OptionsManager.registerCallback("ARCANE_WARD_SPELL_CAST_GAME", optionChange)
    OptionsManager.registerCallback("ARCANE_WARD_SPELL_CAST", optionChange)

    windowlist.onChildWindowAdded(self)
    --Don't show button by default until we are sure we should
    header.subwindow.button_abjuration.setVisible(false)
    optionChange()
end

function onClose()
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST_GAME", optionChange)
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST", optionChange)
    optionChange(true)

    if super and super.onClose then
        super.onClose()
    end
end

function optionChange(bClose)
    local node = getDatabaseNode()
    local aCastInfo = ArcaneWard.getCurrentCastInfo(node)

    if not bCallbacksRegistered and (OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "on") or
    OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "on") or aCastInfo.bHasArcaneWard) then
        registerCallbacks(aCastInfo)
        bCallbacksRegistered = true
    elseif (not aCastInfo.bHasArcaneWard and bCallbacksRegistered and OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "off") and
    OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "off")) or (bClose and bCallbacksRegistered) then
        unRegisterCallbacks(aCastInfo)
        bCallbacksRegistered = false
    end
end

function registerCallbacks(aCastInfo)
    OptionsManager.registerCallback("ARCANE_WARD_PACT", onDisplayChanged)
    local node = getDatabaseNode()
    local sNodePath =  node.getParent().getParent().getPath()

    if aCastInfo.bSpellcasting then
        if aCastInfo.bUpcast then
            for i=aCastInfo.nLevel,9 do
                DB.addHandler(sNodePath ..".powermeta.spellslots" .. tostring(i) .. ".used", "onUpdate", onDisplayChanged)
                i = i + 1
            end
        else
            DB.addHandler(sNodePath ..".powermeta.spellslots".. tostring(aCastInfo.nLevel) .. ".used", "onUpdate", onDisplayChanged)
        end
    end

    if aCastInfo.bPactMagic then
        for i=1,5 do
            DB.addHandler(sNodePath ..".powermeta.pactmagicslots".. tostring(i) .. ".used", "onUpdate", onDisplayChanged)
        end
    end

    DB.addHandler(node.getPath() ..".arcanewardcastaspact", "onUpdate", onDisplayChanged)
    onDisplayChanged()
end

function unRegisterCallbacks(aCastInfo)
    OptionsManager.unregisterCallback("ARCANE_WARD_PACT", onDisplayChanged)

    local node = getDatabaseNode()
    local sNodePath =  node.getParent().getParent().getPath()

    if aCastInfo.bSpellcasting then
        if aCastInfo.bUpcast then
            for i=aCastInfo.nLevel,9 do
                DB.removeHandler(sNodePath ..".powermeta.spellslots" .. tostring(i) ..".used", "onUpdate", onDisplayChanged)
                i = i + 1
            end
        else
            DB.removeHandler(sNodePath ..".powermeta.spellslots".. tostring(aCastInfo.nLevel) .. ".used", "onUpdate", onDisplayChanged)
        end
    end

    if aCastInfo.bPactMagic then
        for i=1,5 do
            DB.removeHandler(sNodePath ..".powermeta.pactmagicslots".. tostring(i) .. ".used", "onUpdate", onDisplayChanged)
            i = i+1
        end
    end
    DB.removeHandler(node.getPath() ..".arcanewardcastaspact", "onUpdate", onDisplayChanged)
    onDisplayChanged()
end

function onDisplayChanged()
    if super and super.onDisplayChanged then
        super.onDisplayChanged();
    end
    local node = getDatabaseNode()
    local sGroup = DB.getValue(node, "group", "")
    local sDisplayMode = DB.getValue(getDatabaseNode(), "...powerdisplaymode", "");
    local aCastInfo = ArcaneWard.getCurrentCastInfo(node)

    if sDisplayMode == "summary"then
        header.subwindow.button_abjuration.setVisible(false);
        header.subwindow.arcaneward_text_label.setVisible(false);
    elseif sDisplayMode == "action" and sGroup == "Spells" and
    (aCastInfo.bSpellcasting or aCastInfo.bPactMagic) and aCastInfo.nLevel > 0 then
        setCastButton(aCastInfo)
    else
        header.subwindow.button_abjuration.setVisible(false);
        header.subwindow.arcaneward_text_label.setVisible(false)
    end
end

function setCastButton(aCastInfo)
    if aCastInfo.bHasArcaneWard or OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "on") or
    OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "on") then
        header.subwindow.arcaneward_text_label.setVisible(true)
        header.subwindow.button_abjuration.setVisible(true)

        header.subwindow.button_abjuration.setEnabled(true)
        if aCastInfo.bCastasPact  then
            if aCastInfo.bNoPactSlotsAvailable then
                if aCastInfo.bCastasPactRitual then
                    header.subwindow.button_abjuration.setIcons("button_pactmagic_no_slots", "button_pactmagic_no_slots_pressed")
                else
                    header.subwindow.button_abjuration.setIcons("button_pactmagic_off", "button_pactmagic_off")
                    header.subwindow.button_abjuration.setEnabled(false)
                end
            else
                header.subwindow.button_abjuration.setIcons("button_pactmagic", "button_pactmagic_pressed")
            end
        else
            if aCastInfo.bNoSpellSlotsAvailable then
                if aCastInfo.bCastasRitual then
                    header.subwindow.button_abjuration.setIcons("button_cast_spell_no_slots", "button_cast_spell_pressed_no_slots")
                else
                    header.subwindow.button_abjuration.setIcons("button_cast_spell_off", "button_cast_spell_off")
                    header.subwindow.button_abjuration.setEnabled(false)
                end
            else
                if aCastInfo.bBaseSlotAvailable then
                    header.subwindow.button_abjuration.setIcons("button_cast_spell", "button_cast_spell_pressed")
                else
                    header.subwindow.button_abjuration.setIcons("button_cast_spell_no_slots", "button_cast_spell_pressed_no_slots")
                end
            end
            if aCastInfo.bAbjuration and aCastInfo.bHasArcaneWard then
                if aCastInfo.bNoSpellSlotsAvailable then
                    if aCastInfo.bCastasRitual then
                        header.subwindow.button_abjuration.setIcons("button_arcaneward_no_slots","button_arcaneward_pressed_no_slots")
                    else
                        header.subwindow.button_abjuration.setIcons("button_arcaneward_off","button_arcaneward_off")
                        header.subwindow.button_abjuration.setEnabled(false)
                    end
                else
                    if aCastInfo.bBaseSlotAvailable then
                        header.subwindow.button_abjuration.setIcons("button_arcaneward","button_arcaneward_pressed")
                    else
                        header.subwindow.button_abjuration.setIcons("button_arcaneward_no_slots","button_arcaneward_pressed_no_slots")
                    end
                end
            end
        end
    else
        header.subwindow.arcaneward_text_label.setVisible(false)
        header.subwindow.button_abjuration.setVisible(false)
    end
end