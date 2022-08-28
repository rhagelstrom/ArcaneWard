--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

function onInit()
    if super and super.onInit() then
        super.onInit()
    end
    OptionsManager.registerCallback("ARCANE_WARD_SHOW_CT", updateHealthDisplay)

	updateHealthDisplay()
end

function onClose()
    if super and super.onInit then
        super.onInit();
    end
    OptionsManager.unregisterCallback("ARCANE_WARD_SHOW_CT", updateHealthDisplay)
end

function updateHealthDisplay()
    if super and super.updateHealthDisplay() then
        super.updateHealthDisplay()
    end
	local sOption;
    local sShowAW = OptionsManager.getOption("ARCANE_WARD_SHOW_CT");
    local bShow = (sShowAW == "on")
   if friendfoe.getStringValue() == "friend" then
		sOption = OptionsManager.getOption("SHPC");
	else
		sOption = OptionsManager.getOption("SHNPC");
	end

    if bShow and sOption == "detailed" then
        arcanewardhp.setVisible(true)
		arcanewardhp.setAnchor("right", "rightanchor", "left", "relative", -43)
		friendfoe.setAnchor("right", "rightanchor", "left", "relative", 60)
        healthbase.setAnchoredWidth("110")
        if ArcaneWard.hasCA() then
            wounds.setAnchor("right", "friendfoe", "left", "relative", -130)
            hptotal.setAnchor("right", "friendfoe", "left", "relative", 70)
            hptemp.setAnchor("right", "friendfoe", "left", "relative", 110)
        end
	else
        arcanewardhp.setVisible(false)
		friendfoe.setAnchor("right", "rightanchor", "left", "relative", -13)
        if ArcaneWard.hasCA() then
            wounds.setAnchor("right", "friendfoe", "left", "relative", -90)
            hptotal.setAnchor("right", "friendfoe", "left", "relative", 70)
            hptemp.setAnchor("right", "friendfoe", "left", "relative", 110)
        end
        if bShow then
            healthbase.setAnchoredWidth("150")
        else
            healthbase.setAnchoredWidth("110")
        end
    end
end
