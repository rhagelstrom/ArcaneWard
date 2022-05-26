
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
            label_init.setAnchor("right", "header_labels", "right", "relative", -180)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -135)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -95)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -55)
            label_arcaneward.setAnchor("right", "header_labels", "right", "relative", -15)
        else
            label_init.setAnchor("right", "header_labels", "right", "relative", -180)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -135)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -95)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -55)
            label_arcaneward.setAnchor("right", "header_labels", "right", "relative", -15)
        end
    else
        if ArcaneWard.hasCA() then
            label_init.setAnchor("right", "header_labels", "right", "relative", -140)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -95)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -55)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -15)
        else
            label_init.setAnchor("right", "header_labels", "right", "relative", -140)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -95)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -55)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -15)
        end
    end
end