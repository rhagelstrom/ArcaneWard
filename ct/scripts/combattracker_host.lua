
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
            label_init.setAnchor("right", "header_labels", "right", "relative", -343)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -298)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -258)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -218)
            label_arcaneward.setAnchor("right", "header_labels", "right", "relative", -178)
        else
            label_init.setAnchor("right", "header_labels", "right", "relative", -343)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -298)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -258)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -218)
            label_arcaneward.setAnchor("right", "header_labels", "right", "relative", -178)
        end
    else
        if ArcaneWard.hasCA() then
            label_init.setAnchor("right", "header_labels", "right", "relative", -303)
            label_wounds.setAnchor("right", "header_labels", "right", "relative", -258)
            label_hp.setAnchor("right", "header_labels", "right", "relative", -218)
            label_temp.setAnchor("right", "header_labels", "right", "relative", -178)
        else
           label_init.setAnchor("right", "header_labels", "right", "relative", -303)
           label_hp.setAnchor("right", "header_labels", "right", "relative", -258)
           label_temp.setAnchor("right", "header_labels", "right", "relative", -218)
           label_wounds.setAnchor("right", "header_labels", "right", "relative", -178)
        end
    end
end