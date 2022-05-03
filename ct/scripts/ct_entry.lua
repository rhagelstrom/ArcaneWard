--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/

function onInit()
	if super and super.onInit() then
		super.onInit()
	end
    onLinkChanged()
	OptionsManager.registerCallback("ARCANE_WARD_SHOW_CT", showArcaneWard)

	showArcaneWard()
end

function onClose()
    if super and super.onInit then
        super.onInit();
    end
    OptionsManager.unregisterCallback("ARCANE_WARD_SHOW_CT", showArcaneWard)
end

function onLinkChanged()
	if super and super.onLinkChanged() then
    	super.onLinkChanged()
	end

--	 If a PC, then set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
	onIDChanged();
end

function onIDChanged()
	if super and super.onIDChanged() then
		super.onIDChanged()
	end
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		arcanewardhp.setLink(nodeChar.createChild("hp.arcaneward", "number"));
	end
	if super and super.linkPCFields() then
    	super.linkPCFields()
	end
end

function showArcaneWard()
	local sShowAW = OptionsManager.getOption("ARCANE_WARD_SHOW_CT");
    local bShow = (sShowAW == "on")
	arcanewardhp.setVisible(bShow)
	if bShow then
		if ArcaneWard.hasCA() then
			--initresult.setAnchor("right", "rightanchor", "left", "absolute", -395)
			--wounds.setAnchor("right", "rightanchor", "left", "absolute", -350)
			--hptotal.setAnchor("right", "rightanchor", "left", "absolute", -310)
			--hptemp.setAnchor("right", "rightanchor", "left", "absolute", -270)

			--initresult.setAnchor("right", "rightanchor", "left", "relative", -15)
			--hptotal.setAnchor("right", "rightanchor", "left", "relative", -10)
			--wounds.setAnchor("right", "rightanchor", "left", "relative", -10)
			hptemp.setAnchor("right", "rightanchor", "left", "relative", -50)
			--arcaneward.setAnchor("right", "wounds", "left", "relative", -10)
			arcanewardhp.setAnchor("right", "rightanchor", "left", "absolute", -230)
		end
	else
		if ArcaneWard.hasCA() then
			--initresult.setAnchor("right", "rightanchor", "left", "absolute", -395)
			--wounds.setAnchor("right", "rightanchor", "left", "absolute", -350)
			--hptotal.setAnchor("right", "rightanchor", "left", "absolute", -310)
			--hptemp.setAnchor("right", "rightanchor", "left", "absolute", -270)

			--initresult.setAnchor("right", "rightanchor", "left", "relative", -15)
			--hptotal.setAnchor("right", "rightanchor", "left", "relative", -10)
			--wounds.setAnchor("right", "rightanchor", "left", "relative", -10)
			hptemp.setAnchor("right", "rightanchor", "left", "relative", -10)
			--arcaneward.setAnchor("right", "wounds", "left", "relative", -10)
			arcanewardhp.setAnchor("right", "rightanchor", "left", "absolute", -230)
		end
	end
end