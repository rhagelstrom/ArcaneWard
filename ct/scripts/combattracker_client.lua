---  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

function onInit()
    OptionsManager.registerCallback("SHPC", updateHealthDisplayAW);
    OptionsManager.registerCallback("SHNPC", updateHealthDisplayAW);

    OptionsManager.registerCallback("ARCANE_WARD_SHOW_CT", updateHealthDisplayAW)

    if super and super.onInit() then
        super.onInit()
    end

    updateHealthDisplayAW()
end

function onClose()
    if super and super.onClose() then
        super.onClose();
    end
    OptionsManager.unregisterCallback("SHPC", updateHealthDisplayAW);
    OptionsManager.unregisterCallback("SHNPC", updateHealthDisplayAW);
    OptionsManager.unregisterCallback("ARCANE_WARD_SHOW_CT", updateHealthDisplayAW)
end

function updateHealthDisplayAW()
    local sOptSHPC = OptionsManager.getOption("SHPC")
    local sOptSHNPC = OptionsManager.getOption("SHNPC")
    local sShowAW = OptionsManager.getOption("ARCANE_WARD_SHOW_CT")
    local bShow = (sShowAW == "on")
    local bShowDetail = bShow and ((sOptSHPC == "detailed") or (sOptSHNPC == "detailed"))

    label_arcaneward.setVisible(bShowDetail)

    if bShow then
        label_status.setAnchoredWidth("159")
        if ArcaneWard.hasCA() then
            label_temp.setAnchor("right", "rightanchor", "left", "relative", -60)
            label_arcaneward.setAnchor("right", "rightanchor", "left", "relative", 110)
        else
            label_wounds.setAnchor("right", "rightanchor", "left", "relative", -10)
            label_arcaneward.setAnchor("right", "rightanchor", "left", "relative", -15)
        end
    else
        label_status.setAnchoredWidth("110")
        if ArcaneWard.hasCA() then
            label_temp.setAnchor("right", "rightanchor", "left", "relative", -15)
        else
            label_wounds.setAnchor("right", "rightanchor", "left", "relative", -15)
        end
    end
end