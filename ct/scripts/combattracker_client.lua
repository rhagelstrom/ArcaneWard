---  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

function onInit()
    OptionsManager.registerCallback("SHPC", updateHealthDisplayAW);
    OptionsManager.registerCallback("SHNPC", updateHealthDisplayAW);

    OptionsManager.registerCallback("ARCANE_WARD_SHOW_CT", showArcaneWard)

    if super and super.onInit() then
        super.onInit()
    end

    showArcaneWard()
end

function onClose()
    if super and super.onClose() then
        super.onClose();
    end
    OptionsManager.unregisterCallback("SHPC", updateHealthDisplayAW);
    OptionsManager.unregisterCallback("SHNPC", updateHealthDisplayAW);
    OptionsManager.unregisterCallback("ARCANE_WARD_SHOW_CT", showArcaneWard)
end

function updateHealthDisplayAW()
    local sOptSHPC = OptionsManager.getOption("SHPC");
    local sOptSHNPC = OptionsManager.getOption("SHNPC");
    local bShowDetail = (sOptSHPC == "detailed") or (sOptSHNPC == "detailed");

    label_arcaneward.setVisible(bShowDetail);
    showArcaneWard()
end

function showArcaneWard()
    local sShowAW = OptionsManager.getOption("ARCANE_WARD_SHOW_CT");
    local bShow = (sShowAW == "on")
    label_arcaneward.setVisible(bShow)
    if bShow then
        if ArcaneWard.hasCA() then
            label_init.setAnchor("right", "rightanchor", "left", "absolute", -170)
            label_wounds.setAnchor("right", "rightanchor", "left", "absolute", -130)
            label_hp.setAnchor("right", "rightanchor", "left", "absolute", -90)
            label_temp.setAnchor("right", "rightanchor", "left", "absolute", -50)
            label_arcaneward.setAnchor("right", "rightanchor", "left", "absolute", -10)
        else
            label_init.setAnchor("right", "rightanchor", "left", "absolute", -170)
            label_hp.setAnchor("right", "rightanchor", "left", "absolute", -130)
            label_temp.setAnchor("right", "rightanchor", "left", "absolute", -90)
            label_wounds.setAnchor("right", "rightanchor", "left", "absolute", -50)
            label_arcaneward.setAnchor("right", "rightanchor", "left", "absolute", -10)
        end
    else
        if ArcaneWard.hasCA() then
            label_init.setAnchor("right", "rightanchor", "left", "absolute", -130)
            label_wounds.setAnchor("right", "rightanchor", "left", "absolute", -90)
            label_hp.setAnchor("right", "rightanchor", "left", "absolute", -50)
            label_temp.setAnchor("right", "rightanchor", "left", "absolute", -10)
        else
            label_init.setAnchor("right", "rightanchor", "left", "absolute", -130)
            label_hp.setAnchor("right", "rightanchor", "left", "absolute", -90)
            label_temp.setAnchor("right", "rightanchor", "left", "absolute", -50)
            label_wounds.setAnchor("right", "rightanchor", "left", "absolute", -10)
        end
    end
end