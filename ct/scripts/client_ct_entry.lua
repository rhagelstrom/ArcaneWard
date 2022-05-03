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


function updateHealthDisplay()
    if super and super.updateHealthDisplay() then
        super.updateHealthDisplay()
    end
	local sOption;
	if friendfoe.getStringValue() == "friend" then
		sOption = OptionsManager.getOption("SHPC");
	else
		sOption = OptionsManager.getOption("SHNPC");
	end

	if sOption == "detailed" then
        arcanewardhp.setVisible(true);
        showArcaneWard()
	elseif sOption == "status" then
        arcanewardhp.setVisible(false);
	else
        arcanewardhp.setVisible(false);
	end
end

function showArcaneWard()
    local sShowAW = OptionsManager.getOption("ARCANE_WARD_SHOW_CT");
    local bShow = (sShowAW == "on")
    arcanewardhp.setVisible(bShow)

    if bShow then
        if ArcaneWard.hasCA() then
            initresult.setAnchor("right", "rightanchor", "left", "relative", -15)
            wounds.setAnchor("right", "healthbase", "left", "absolute", 30)
            hptotal.setAnchor("right", "healthbase", "left", "absolute", 70)
            hptemp.setAnchor("right", "healthbase", "left", "absolute", 110)
            arcanewardhp.setAnchor("right", "healthbase", "left", "absolute", 150)
        else
            initresult.setAnchor("right", "rightanchor", "left", "relative", -15)
            hptotal.setAnchor("right", "healthbase", "left", "absolute", 30)
            hptemp.setAnchor("right", "healthbase", "left", "absolute", 70)
            wounds.setAnchor("right", "healthbase", "left", "absolute", 110)
            arcanewardhp.setAnchor("right", "healthbase", "left", "absolute", 150)
        end
    else
        if ArcaneWard.hasCA() then
            initresult.setAnchor("right", "rightanchor", "left", "relative", 25)
            wounds.setAnchor("right", "healthbase", "left", "absolute", 70)
            hptotal.setAnchor("right", "healthbase", "left", "absolute", 110)
            hptemp.setAnchor("right", "healthbase", "left", "absolute", 150)
        else
            initresult.setAnchor("right", "rightanchor", "left", "relative", 25)
            hptotal.setAnchor("right", "healthbase", "left", "absolute", 70)
            hptemp.setAnchor("right", "healthbase", "left", "absolute", 110)
            wounds.setAnchor("right", "healthbase", "left", "absolute", 150)
        end
    end
end