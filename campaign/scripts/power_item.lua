--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

function onInit()
    if super and super.onInit then
        super.onInit();
    end
    OptionsManager.registerCallback("ARCANE_WARD_SPELL_CAST_GAME", onDisplayChanged);
    OptionsManager.registerCallback("ARCANE_WARD_SPELL_CAST", onDisplayChanged);
    onDisplayChanged();
    windowlist.onChildWindowAdded(self);

    local node = getDatabaseNode()
    local sNodePath =  node.getParent().getParent().getPath()

    local aSpellParams = ArcaneWard.getUpcastRitual(node)
    if aSpellParams.bUpcast then
        for i=aSpellParams.nBaseLevel,9 do
            DB.addHandler(sNodePath ..".powermeta.spellslots" .. tostring(i) .. ".used", "onUpdate", onDisplayChanged)
            i = i + 1
        end
    else
        DB.addHandler(sNodePath ..".powermeta.spellslots".. tostring(aSpellParams.nBaseLevel) .. ".used", "onUpdate", onDisplayChanged)
    end
end

function onClose()
    if super and super.onInit then
        super.onInit();
    end
    local node = getDatabaseNode()
    local sNodePath =  node.getParent().getParent().getPath()
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST_GAME", onDisplayChanged);
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST", onDisplayChanged);

    local aSpellParams = ArcaneWard.getUpcastRitual(node)
    if aSpellParams.bUpcast then
        for i=aSpellParams.nBaseLevel,9 do
            DB.removeHandler(sNodePath ..".powermeta.spellslots" .. tostring(i) ..".used", "onUpdate", onDisplayChanged)
            i = i + 1
        end
    else
        DB.removeHandler(sNodePath ..".powermeta.spellslots".. tostring(aSpellParams.nBaseLevel) .. ".used", "onUpdate", onDisplayChanged)
    end
end

function onDisplayChanged()
    if super and super.onDisplayChanged then
        super.onDisplayChanged();
    end
    local node = getDatabaseNode()
    local sGroup = DB.getValue(node, "group", "")
    local sDisplayMode = DB.getValue(getDatabaseNode(), "...powerdisplaymode", "");
    local next = next
    if sDisplayMode == "summary"then
        header.subwindow.button_abjuration.setVisible(false);
        header.subwindow.arcaneward_text_label.setVisible(false);
    elseif sDisplayMode == "action" and sGroup == "Spells"  then
        local aSpellParams = ArcaneWard.getUpcastRitual(node)

        if OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "on") or OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "on") then
            header.subwindow.arcaneward_text_label.setVisible(true)
            header.subwindow.button_abjuration.setVisible(true)
            --if spell is not a cantrip
            if aSpellParams.nBaseLevel > 0  then
                if aSpellParams.bHasSpellSlots then
                    header.subwindow.button_abjuration.setIcons("button_cast_spell", "button_cast_spell_pressed")
                elseif aSpellParams.bRitual or (aSpellParams.bUpcast and next(aSpellParams.aSpellSlots) ~= nil) then
                    header.subwindow.button_abjuration.setIcons("button_cast_spell_no_slots", "button_cast_spell_pressed_no_slots")
                else
                    header.subwindow.button_abjuration.setIcons("button_cast_spell_off", "button_cast_spell_off")
                end
            else
                header.subwindow.button_abjuration.setVisible(false);
                header.subwindow.arcaneward_text_label.setVisible(false);
            end
        else
            header.subwindow.arcaneward_text_label.setVisible(false)
            header.subwindow.button_abjuration.setVisible(false)
        end

        -- If we are valid for arcane ward, always display it
        if aSpellParams.sSchool == "Abjuration" and aSpellParams.bHasArcaneWard then
            if aSpellParams.bHasSpellSlots then
                header.subwindow.button_abjuration.setIcons("button_arcaneward","button_arcaneward_pressed")
            elseif aSpellParams.bUpcast or aSpellParams.bRitual then
                header.subwindow.button_abjuration.setIcons("button_arcaneward_no_slots","button_arcaneward_pressed_no_slots")
            else
                header.subwindow.button_abjuration.setIcons("button_arcaneward_off","button_arcaneward_off")
            end
            header.subwindow.arcaneward_text_label.setVisible(true)
            header.subwindow.button_abjuration.setVisible(true)
        end
        --Enable/Disable button based on if can actually cast it based on resources
        if aSpellParams.bHasSpellSlots or aSpellParams.bRitual or (aSpellParams.bUpcast and next(aSpellParams.aSpellSlots) ~= nil) then
            header.subwindow.button_abjuration.setEnabled(true)
        else
            header.subwindow.button_abjuration.setEnabled(false)
        end
    else
        header.subwindow.button_abjuration.setVisible(false);
        header.subwindow.arcaneward_text_label.setVisible(false);
    end
end