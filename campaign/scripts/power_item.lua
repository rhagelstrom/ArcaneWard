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
end

function onClose()
    if super and super.onInit then
        super.onInit();
    end
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST_GAME", onDisplayChanged);
    OptionsManager.unregisterCallback("ARCANE_WARD_SPELL_CAST", onDisplayChanged);
end

function onDisplayChanged()
    if super and super.onDisplayChanged then
        super.onDisplayChanged();
    end
    local node = getDatabaseNode()

    local sGroup = DB.getValue(node, "group", "")
    local sSchool = DB.getValue(node, "school", "")
    local nLevel = DB.getValue(node, "level", 0)
    local rActor = ActorManager.resolveActor(node.getParent().getParent())

    local sDisplayMode = DB.getValue(getDatabaseNode(), "...powerdisplaymode", "");

    if sDisplayMode == "summary"then
        header.subwindow.button_abjuration.setVisible(false);
        header.subwindow.arcaneward_text_label.setVisible(false);
    elseif sDisplayMode == "action" and sGroup == "Spells"  then
        if OptionsManager.isOption("ARCANE_WARD_SPELL_CAST_GAME", "on") or OptionsManager.isOption("ARCANE_WARD_SPELL_CAST", "on") then
            header.subwindow.arcaneward_text_label.setVisible(true)
            header.subwindow.button_abjuration.setVisible(true)
        else
            header.subwindow.arcaneward_text_label.setVisible(false)
            header.subwindow.button_abjuration.setVisible(false)
        end

        if sSchool == "Abjuration" and ArcaneWard.hasArcaneWard(rActor) then
            header.subwindow.button_abjuration.setIcons("button_arcaneward","button_arcaneward_pressed")
            header.subwindow.arcaneward_text_label.setVisible(true)
            header.subwindow.button_abjuration.setVisible(true)
        elseif nLevel > 0  then
            header.subwindow.button_abjuration.setIcons("button_cast_spell", "button_cast_spell_pressed")
        else
            header.subwindow.button_abjuration.setVisible(false);
            header.subwindow.arcaneward_text_label.setVisible(false);
        end
    else
        header.subwindow.button_abjuration.setVisible(false);
        header.subwindow.arcaneward_text_label.setVisible(false);
    end
end