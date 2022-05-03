
--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

function onInit()
    if super and super.onInit() then
        super.onInit()
    end
    OptionsManager.registerCallback("ARCANE_WARD_SHOW_CT", showArcaneWard)

    showArcaneWard()
end

function onClose()
    if super and super.onInit then
        super.onInit();
    end
    OptionsManager.unregisterCallback("ARCANE_WARD_SHOW_CT", showArcaneWard)
end

function showArcaneWard()
    local sShowAW = OptionsManager.getOption("ARCANE_WARD_SHOW_CT");
    local bShow = (sShowAW == "on")
    label_arcaneward.setVisible(bShow)

    if bShow then
        if ArcaneWard.hasCA() then
            label_init.setAnchor("right", "label_name", "left", "relative", 265)
            label_wounds.setAnchor("right", "label_init", "left", "absolute", 75)
            label_hp.setAnchor("right", "label_init", "left", "absolute", 115)
            label_temp.setAnchor("right", "label_init", "left", "absolute", 155)
            label_arcaneward.setAnchor("right", "label_init", "left", "absolute", 195)
        else
            label_init.setAnchor("right", "label_name", "left", "relative", 265)
            label_hp.setAnchor("right", "label_init", "left", "absolute", 75)
            label_temp.setAnchor("right", "label_init", "left", "absolute", 115)
            label_wounds.setAnchor("right", "label_init", "left", "absolute", 155)
            label_arcaneward.setAnchor("right", "label_init", "left", "absolute", 195)
        end
    else
        if ArcaneWard.hasCA() then
            label_init.setAnchor("right", "label_name", "left", "relative", 305)
            label_wounds.setAnchor("right", "label_init", "left", "absolute", 75)
            label_hp.setAnchor("right", "label_init", "left", "absolute", 115)
            label_temp.setAnchor("right", "label_init", "left", "absolute", 155)
        else
            label_init.setAnchor("right", "label_name", "left", "relative", 305)
            label_hp.setAnchor("right", "label_init", "left", "absolute", 75)
            label_temp.setAnchor("right", "label_init", "left", "absolute", 115)
            label_wounds.setAnchor("right", "label_init", "left", "absolute", 155)
        end
    end
end