--  	Author: Ryan Hagelstrom
--	  	Copyright © 2022
--	  	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--	  	https://creativecommons.org/licenses/by-sa/4.0/
--
-- luacheck: globals ArcaneWard onInit onClose hasCA hasLA hasCG hasSAI castAbjuration parseArcaneWard hasArcaneWard arcaneWard
-- luacheck: globals removeAbsorbed getDBString customApplyDamage customMessageDamage customRest getCurrentCastInfo
-- luacheck: globals resetCastInfo getNextSpellSlot boolToNumber numberToBool customGetDamageAdjust
-- luacheck: globals getMagicTraits getPactMagicSlots expendSpellSlot getSpellSlots addNPCtoCT getEffectsByType
-- Sage Advice
-- https://dnd.wizards.com/articles/features/sageadvice_july2015
-- How does Arcane Ward interact with temporary hit points and damage resistance that an abjurer might have?
-- An Arcane Ward is not an extension of the wizard who creates it. It is a magical effect with its own hit points.
-- Any temporary hit points, immunities, or resistances that the wizard has don’t apply to the ward.
-- The ward takes damage first. Any leftover damage is taken by the wizard and goes through the following game elements in order:
--  (1) any relevant damage immunity,
--  (2) any relevant damage resistance,
--  (3) any temporary hit points, and
--  (4) real hit points.
local applyDamage = nil;
local getDamageAdjust = nil;
local messageDamage = nil;
local rest = nil;
local onNPCPostAdd = nil;
local extensions = {};

function onInit()
    applyDamage = ActionDamage.applyDamage;
    getDamageAdjust = ActionDamage.getDamageAdjust;
    messageDamage = ActionDamage.messageDamage;
    rest = CharManager.rest;

    ActionDamage.applyDamage = customApplyDamage;
    ActionDamage.getDamageAdjust = customGetDamageAdjust;
    ActionDamage.messageDamage = customMessageDamage;
    CharManager.rest = customRest;

    onNPCPostAdd = CombatRecordManager.getRecordTypePostAddCallback('npc');
    CombatRecordManager.setRecordTypePostAddCallback('npc', addNPCtoCT);
    for index, name in pairs(Extension.getExtensions()) do
        extensions[name] = index;
    end

    OptionsManager.registerOption2('ARCANE_WARD_SPELL_CAST_GAME', false, 'option_arcane_ward', 'option_spell_cast_game',
                                   'option_entry_cycler', {
        labels = 'option_val_on',
        values = 'on',
        baselabel = 'option_val_off',
        baseval = 'off',
        default = 'off'
    });

    OptionsManager.registerOption2('ARCANE_WARD_SPELL_CAST', true, 'option_arcane_ward', 'option_spell_cast',
                                   'option_entry_cycler', {
        labels = 'option_val_on',
        values = 'on',
        baselabel = 'option_val_off',
        baseval = 'off',
        default = 'off'
    });

    OptionsManager.registerOption2('ARCANE_WARD_PACT', true, 'option_arcane_ward', 'option_pact_aw', 'option_entry_cycler', {
        labels = 'option_val_on',
        values = 'on',
        baselabel = 'option_val_off',
        baseval = 'off',
        default = 'off'
    });

end

function onClose()
    ActionDamage.applyDamage = applyDamage;
    ActionDamage.getDamageAdjust = getDamageAdjust;
    ActionDamage.messageDamage = messageDamage;
    CharManager.rest = rest;
end

function hasCA()
    return extensions['ConstitutionalAmendments'];
end
function hasLA()
    return extensions['5e Legendary Assistant'];
end
function hasCG()
    return extensions['CombatGroups'];
end
function hasSAI()
    return extensions['Spell Action Info'];
end

function castAbjuration(nodeActor, nLevel, sName, bCastasPact)
    local rActor = ActorManager.resolveActor(nodeActor);
    local nActive = DB.getValue(nodeActor, 'arcaneward', 0);
    local sDBAWHP = getDBString(nodeActor);
    local nTotal;
    local nAdded;
    local sActivated = '';
    local sMax = '';

    if nActive == 1 then
        local nArcaneWardHP = DB.getValue(nodeActor, sDBAWHP, 0);
        local nMax = DB.getValue(nodeActor, 'arcanewardmax', 0);

        nAdded = nLevel * 2;
        if nAdded + nArcaneWardHP > nMax then
            nAdded = nMax - nArcaneWardHP;
            sMax = ' MAX';
        end
        nTotal = nArcaneWardHP + nAdded;

    else
        local aParsed = parseArcaneWard(rActor);
        local sClass;
        local sModifier;
        local nWizLevel = 0;
        if aParsed['class'] then
            sClass = aParsed['class'];
        else
            sClass = 'wizard';
        end
        if aParsed['modifier'] and StringManager.contains(DataCommon.abilities, aParsed['modifier']) then
            sModifier = aParsed['modifier'];
        else
            sModifier = 'intelligence';
        end
        local nBonus = DB.getValue(nodeActor, 'abilities.' .. sModifier .. '.bonus', 0);
        for _, nodeClass in ipairs(DB.getChildList(nodeActor, 'classes')) do
            local sClassName = StringManager.trim(DB.getValue(nodeClass, 'name', '')):lower();
            if sClassName == sClass then
                nWizLevel = DB.getValue(nodeClass, 'level', 0);
                sActivated = '[ACTIVATED] ';
                break
            end
        end
        nAdded = nWizLevel * 2 + nBonus;
        nTotal = nAdded;
        DB.setValue(nodeActor, 'arcaneward', 'number', 1);
        DB.setValue(nodeActor, 'arcanewardmax', 'number', nTotal);
    end
    DB.setValue(nodeActor, sDBAWHP, 'number', nTotal);

    local rMessage = ChatManager.createBaseMessage(rActor, DB.getValue(nodeActor, 'name'));
    -- rMessage.secret
    rMessage.icon = 'ArcaneWardCast';
    if bCastasPact then
        rMessage.text = rMessage.text .. 'Begins [CAST] ' .. sName .. ' [PACT LEVEL ' .. nLevel .. '] [Arcane Ward: ' ..
                            tostring(nAdded) .. sMax .. ' ] -> ' .. sActivated .. '[to ' .. DB.getValue(nodeActor, 'name') .. ']'
    else
        rMessage.text = rMessage.text .. 'Begins [CAST] ' .. sName .. ' [LEVEL ' .. nLevel .. '] [Arcane Ward: ' ..
                            tostring(nAdded) .. sMax .. ' ] -> ' .. sActivated .. '[to ' .. DB.getValue(nodeActor, 'name') .. ']'
    end
    Comm.deliverChatMessage(rMessage);
end

function parseArcaneWard(rActor)
    local nodeActor = ActorManager.getCreatureNode(rActor);
    local nodeFeatures = DB.getChild(nodeActor, 'featurelist');
    local aAWParsed = {};
    -- PCs
    if nodeFeatures and (rActor.sType == 'pc' or rActor.sType == 'charsheet') then
        local aFeatures = DB.getChildList(nodeFeatures);
        for _, nodeFeature in pairs(aFeatures) do
            local sName = DB.getValue(nodeFeature, 'name', '');
            if sName:upper() == 'ARCANE WARD' then
                local sDesc = DB.getValue(nodeFeature, 'text', ''):lower();
                local aWords = StringManager.parseWords(sDesc);
                local i = 1;
                while aWords[i] do
                    if StringManager.isWord(aWords[i], 'equal') and StringManager.isWord(aWords[i + 1], 'to') and
                        StringManager.isWord(aWords[i + 2], 'twice') and StringManager.isWord(aWords[i + 3], 'your') then
                        aAWParsed['class'] = aWords[i + 4];
                    elseif StringManager.isWord(aWords[i], '+') and StringManager.isWord(aWords[i + 1], 'your') and
                        StringManager.isWord(aWords[i + 3], 'modifier') then
                        aAWParsed['modifier'] = aWords[i + 2];
                    end
                    i = i + 1;
                end
                break
            end
        end
    end
    return aAWParsed;
end

function hasArcaneWard(rActor)
    local nodeActor = ActorManager.getCreatureNode(rActor);
    local nodeFeatures = DB.getChild(nodeActor, 'featurelist');
    -- PCs
    if nodeFeatures and (rActor.sType == 'pc' or rActor.sType == 'charsheet') then
        local aFeatures = DB.getChildList(nodeFeatures);
        for _, nodeFeature in pairs(aFeatures) do
            local sName = DB.getValue(nodeFeature, 'name', '');
            if sName:upper() == 'ARCANE WARD' then
                return true;
            end
        end
    end
    -- NPCs
    local nodeTraits = DB.getChild(nodeActor, 'traits');
    if nodeTraits and rActor.sType == 'npc' then
        local aTraits = DB.getChildList(nodeTraits);
        for _, nodeTrait in pairs(aTraits) do
            local sName = DB.getValue(nodeTrait, 'name', '');
            if sName:upper() == 'ARCANE WARD' then
                return true;
            end
        end
    end
    return false;
end

function arcaneWard(_, rTarget, rRoll)
    local nodeTarget = ActorManager.getCreatureNode(rTarget);
    local nActive = DB.getValue(nodeTarget, 'arcaneward', 0);
    local sDBAWHP = getDBString(nodeTarget);
    local nArcaneWardHP = DB.getValue(nodeTarget, sDBAWHP, 0);

    if nActive == 1 and nArcaneWardHP > 0 then
        local nTotalOrig = rRoll.nTotal;
        if rRoll.nTotal >= nArcaneWardHP then
            rRoll.nTotal = rRoll.nTotal - nArcaneWardHP;
            nArcaneWardHP = 0;
        else
            nArcaneWardHP = nArcaneWardHP - rRoll.nTotal;
            rRoll.nTotal = 0;
        end
        DB.setValue(nodeTarget, sDBAWHP, 'number', nArcaneWardHP);
        rRoll.sDesc = removeAbsorbed(rRoll.sDesc, nTotalOrig - rRoll.nTotal);
        rRoll.sDesc = '[ARCANE WARD ABSORBED: ' .. tostring(nTotalOrig - rRoll.nTotal) .. '] ' .. rRoll.sDesc;
    end
end

function removeAbsorbed(sDamage, nAbsorbed)
    local sNewDamage = sDamage:gsub('%s*%[TYPE:[^%]]*%]%s*', '');
    for sType in sDamage:gmatch('%[TYPE:[^%]]*%]') do
        local sParsedDamage = sType:match('%d+%)%]$'):gsub('%)%]$', '');
        local nDamage = tonumber(sParsedDamage);
        if nAbsorbed >= nDamage then
            nAbsorbed = nAbsorbed - nDamage;
        else
            nDamage = nDamage - nAbsorbed;
            nAbsorbed = 0;
            sType = sType:gsub('=%d+%)', '=' .. tostring(nDamage) .. ')');
            sNewDamage = sNewDamage .. ' ' .. sType;
        end
    end
    return sNewDamage;
end

function getDBString(node)
    local rActor = ActorManager.resolveActor(node);
    if ActorManager.isPC(rActor) then
        return 'hp.arcaneward';
    else
        return 'arcanewardhp';
    end
end

function customGetDamageAdjust(rSource, rTarget, nDamage, rDamageOutput, ...)
    local results = {getDamageAdjust(rSource, rTarget, nDamage, rDamageOutput, ...)};
    if OptionsManager.isOption('GAVE', '2024') then
        local aArcaneWardEffects = getEffectsByType(rTarget, 'ARCANEWARD');
        local nTotal = nDamage + results[1]
        local rRoll = {sDesc = '', nTotal = nTotal}
        if next(aArcaneWardEffects) then
            local ctEntries = CombatManager.getCombatantNodes();
            for _, nodeCT in pairs(ctEntries) do
                if not CombatManager.isCTHidden(nodeCT) then
                    local rActor = ActorManager.resolveActor(nodeCT);
                    if hasArcaneWard(rActor) then
                        for _, rEffect in pairs(aArcaneWardEffects) do
                            if rEffect.source_name == rActor.sCTNode then
                                arcaneWard(rSource, rActor, rRoll);
                                if nTotal ~= rRoll.nTotal then
                                    results[1] = rRoll.nTotal - nDamage
                                    table.insert(rDamageOutput.tNotifications, rRoll.sDesc);
                                end
                            end
                        end
                    end
                end
            end
        end
        if hasArcaneWard(rTarget) then
            arcaneWard(rSource, rTarget, rRoll);
            if nTotal ~= rRoll.nTotal then
                results[1] = rRoll.nTotal - nDamage
                table.insert(rDamageOutput.tNotifications, rRoll.sDesc);
            end
        end
    end

    return unpack(results);
end

function customApplyDamage(rSource, rTarget, rRoll)
    -- 2024 need to be here ActionDamage.getDamageAdjust(rSource, rTarget, rDamageOutput.nVal, rDamageOutput);
    if not rSource or not rTarget or not rRoll or rRoll.sType ~= 'damage' or OptionsManager.isOption('GAVE', '2024') then
        return applyDamage(rSource, rTarget, rRoll);
    end
    -- Get the effects on source, determine. is arcane ward. determine source
    local aArcaneWardEffects = getEffectsByType(rTarget, 'ARCANEWARD');
    if next(aArcaneWardEffects) then
        local ctEntries = CombatManager.getCombatantNodes();
        for _, nodeCT in pairs(ctEntries) do
            if not CombatManager.isCTHidden(nodeCT) then
                local rActor = ActorManager.resolveActor(nodeCT);
                if hasArcaneWard(rActor) then
                    for _, rEffect in pairs(aArcaneWardEffects) do
                        if rEffect.source_name == rActor.sCTNode then
                            arcaneWard(rSource, rActor, rRoll);
                        end
                    end
                end
            end
        end
    end
    if hasArcaneWard(rTarget) then
        arcaneWard(rSource, rTarget, rRoll);
    end
    return applyDamage(rSource, rTarget, rRoll);
end

function customMessageDamage(rSource, rTarget, rRoll)
    -- TODO: Think we need to loop here incase of multiple arcane wards
    local sArcaneWard = rRoll.sDesc:match('%[ARCANE WARD ABSORBED:%s*%d*]');
    if sArcaneWard then
        rRoll.sResults = sArcaneWard .. rRoll.sResults;
    end
    return messageDamage(rSource, rTarget, rRoll);
end

function customRest(nodeActor, bLong)
    local rActor = ActorManager.resolveActor(nodeActor);
    if bLong and hasArcaneWard(rActor) then
        local nActive = DB.getValue(nodeActor, 'arcaneward', 0);
        if nActive == 1 then
            DB.setValue(nodeActor, 'arcaneward', 'number', 0);
            DB.setValue(nodeActor, 'hp.arcaneward', 'number', 0);
            local rMessage = ChatManager.createBaseMessage(rActor, DB.getValue(nodeActor, 'name'));
            rMessage.icon = 'ArcaneWard';
            rMessage.text =
                rMessage.text .. '[Arcane Ward] ->' .. ' [DEACTIVATED]' .. ' [to ' .. DB.getValue(nodeActor, 'name') .. ']';
            Comm.deliverChatMessage(rMessage);
        end
    end
    rest(nodeActor, bLong);
end

-- luacheck: push ignore 561
function getCurrentCastInfo(node, bNextSlot, aCastInfo)
    local aRet = {
        bCastasPact = false,
        bPactMagic = false,
        bSpellcasting = false,
        bAbjuration = false,
        bRitual = false,
        bCastasRitual = false,
        bCastasPactRitual = false,
        bUpcast = false,
        bBaseSlotAvailable = true,
        bNoSpellSlotsAvailable = false,
        bNoPactSlotsAvailable = false,
        bHasArcaneWard = false,
        nLevel = 0,
        nCastLevel = 0,
        nPactLevel = 0
    }
    local nodeChar = DB.getChild(node, '...');
    local aPactSlots;
    local aSpellSlots;
    local aTraits = getMagicTraits(nodeChar);

    -- If passed a castinfo. Done for resetting after cast
    if aCastInfo then
        aRet = aCastInfo;
    else
        local sDescription = DB.getValue(node, 'description', '');
        aRet.nLevel = DB.getValue(node, 'level', 0);
        aRet.nCastLevel = DB.getValue(node, 'arcanewardlevel', aRet.nLevel);
        if aTraits.bRitualCaster then
            aRet.bCastasRitual = numberToBool(DB.getValue(node, 'arcanewardritual', 0));
            aRet.bCastasPactRitual = numberToBool(DB.getValue(node, 'arcanewardpactritual', 0));
        end
        aRet.bCastasPact = numberToBool(DB.getValue(node, 'arcanewardcastaspact', 0));

        aRet.bSpellcasting = aTraits.bSpellcasting;
        aRet.bPactMagic = aTraits.bPactMagic;
        aRet.bHasArcaneWard = aTraits.bArcaneWard;

        -- Don't care if we don't have spellcasting and arcane ward
        if aRet.bSpellcasting and aRet.bHasArcaneWard and (DB.getValue(node, 'school', ''):lower() == 'abjuration') then
            aRet.bAbjuration = true;
        end

        if aTraits.bRitualCaster and DB.getValue(node, 'ritual', 0) == 1 then
            aRet.bRitual = true;
        end

        if sDescription:match('At Higher Levels') then
            aRet.bUpcast = true;
        end
    end

    if aRet.bPactMagic then
        aPactSlots = getPactMagicSlots(nodeChar, aRet.nLevel);
        aRet.nPactLevel = aPactSlots.nLevel;
        if aPactSlots.nAvailable == 0 then
            aRet.bNoPactSlotsAvailable = true;
            if aRet.bRitual then
                aRet.bCastasPactRitual = true;
            end
        end
        if not aRet.bSpellcasting then
            aRet.bCastasPact = true;
        end
    end

    if aRet.bSpellcasting then
        aSpellSlots = getSpellSlots(nodeChar, aRet.nLevel);
        if aSpellSlots[aRet.nLevel] == nil then
            aRet.bBaseSlotAvailable = false;
            if not aRet.bUpcast then
                aRet.bNoSpellSlotsAvailable = true;
            end
        end
        if next(aSpellSlots) == nil then
            aRet.bNoSpellSlotsAvailable = true;
        end
    end

    -- Switch between spellcasting/pact if no slots
    if aRet.bSpellcasting and aRet.bPactMagic then
        if aRet.bCastasPact and aRet.bNoPactSlotsAvailable and not aRet.bCastasPactRitual and not aRet.bNoSpellSlotsAvailable then
            aRet.bCastasPact = false;
        elseif not aRet.bCastasPact and aRet.bNoSpellSlotsAvailable and not aRet.bCastasRitual and not aRet.bNoPactSlotsAvailable then
            aRet.bCastasPact = true;
        end
    end

    if aRet.bSpellcasting and (aSpellSlots[aRet.nCastLevel] == nil or bNextSlot) then
        getNextSpellSlot(aRet, aSpellSlots);

        if aRet.bRitual and (aRet.bNoSpellSlotsAvailable or (not aRet.bUpcast and not aRet.bBaseSlotAvailable)) then
            aRet.bCastasRitual = true;
        end
    end

    if bNextSlot and aRet.bCastasPact and aRet.bRitual then
        if aRet.bCastasPactRitual and not aRet.bNoPactSlotsAvailable then
            aRet.bCastasPactRitual = false;
        else
            aRet.bCastasPactRitual = true;
        end
    end

    DB.setValue(node, 'arcanewardlevel', 'number', aRet.nCastLevel);
    if aRet.bPactMagic then
        DB.setValue(node, 'arcanewardcastaspact', 'number', boolToNumber(aRet.bCastasPact));
    end
    if aTraits.bRitualCaster and aRet.bRitual then
        if aRet.bSpellcasting then
            DB.setValue(node, 'arcanewardritual', 'number', boolToNumber(aRet.bCastasRitual));
        end
        if aRet.bPactMagic then
            DB.setValue(node, 'arcanewardpactritual', 'number', boolToNumber(aRet.bCastasPactRitual));
        end
    end

    return aRet
end
-- luacheck: pop

function resetCastInfo(node, aCastInfo)
    aCastInfo.bCastasRitual = false;
    aCastInfo.bCastasPactRitual = false;
    aCastInfo.nCastLevel = aCastInfo.nLevel;

    if aCastInfo.bSpellcasting and aCastInfo.bPactMagic and OptionsManager.isOption('ARCANE_WARD_PACT', 'on') and
        aCastInfo.nPactLevel >= aCastInfo.nLevel then
        aCastInfo.bCastasPact = true;
    elseif not aCastInfo.bSpellcasting and aCastInfo.bPactMagic then
        aCastInfo.bCastasPact = true;
    else
        aCastInfo.bCastasPact = false;
    end
    return getCurrentCastInfo(node, nil, aCastInfo);
end

function getNextSpellSlot(aCastInfo, aSpellSlots)
    if (aCastInfo.bUpcast or aCastInfo.bRitual) and (next(aSpellSlots) ~= nil) then
        local nNextCastLevel = -1;
        if aCastInfo.bCastasRitual then
            aCastInfo.bCastasRitual = false;
            aCastInfo.nCastLevel = aCastInfo.nLevel;
            if aSpellSlots[aCastInfo.nCastLevel] ~= nil then
                return;
            end
        end
        if aCastInfo.bUpcast then
            for nSpellLevel, _ in pairs(aSpellSlots) do
                if nSpellLevel > aCastInfo.nCastLevel then
                    nNextCastLevel = nSpellLevel;
                    break
                end
            end
            if nNextCastLevel == -1 then
                aCastInfo.nCastLevel = aCastInfo.nLevel;
                if aCastInfo.bRitual then
                    aCastInfo.bCastasRitual = true;
                elseif aSpellSlots[aCastInfo.nCastLevel] == nil then
                    getNextSpellSlot(aCastInfo, aSpellSlots);
                end
            else
                aCastInfo.nCastLevel = nNextCastLevel;
            end
        elseif aCastInfo.bRitual then
            aCastInfo.bCastasRitual = true;
        end
    end
end

function boolToNumber(value)
    return value == true and 1 or value == false and 0;
end

function numberToBool(value)
    if value == 1 then
        return true;
    else
        return false;
    end
end

function getMagicTraits(nodeChar)
    local aRet = {bSpellcasting = false, bPactMagic = false, bArcaneWard = false, bRitualCaster = false};
    for _, nodeFeature in ipairs(DB.getChildList(nodeChar, 'featurelist')) do
        local sFeatureName = StringManager.trim(DB.getValue(nodeFeature, 'name', ''):lower());
        if sFeatureName:match('spellcasting') then
            aRet.bSpellcasting = true;
            local sDesc = DB.getValue(nodeFeature, 'text', ''):lower();
            if sDesc:match('ritual casting') then
                aRet.bRitualCaster = true;
            end
        elseif sFeatureName:match('pact magic') then
            aRet.bPactMagic = true;
        elseif sFeatureName:match('arcane ward') then
            aRet.bArcaneWard = true;
        elseif sFeatureName:match('ritual casting') then
            aRet.bRitualCaster = true;
        end
    end
    return aRet;
end

function getPactMagicSlots(nodeChar, nLevel)
    local aPactslots = {nAvailable = 0, nLevel = 0};
    for i = nLevel, 5 do
        local nSlotsMax = DB.getValue(nodeChar, 'powermeta.pactmagicslots' .. tostring(i) .. '.max', 0);
        local nSlotsUsed = DB.getValue(nodeChar, 'powermeta.pactmagicslots' .. tostring(i) .. '.used', 0);
        if nSlotsMax > 0 then
            aPactslots.nLevel = i;
        end
        if nSlotsUsed < nSlotsMax then
            aPactslots.nAvailable = nSlotsMax - nSlotsUsed;
            break
        end
    end
    return aPactslots;
end

function expendSpellSlot(nodeChar, nLevel, bCastasPact)
    if bCastasPact then
        local nSlotsMax = DB.getValue(nodeChar, 'powermeta.pactmagicslots' .. tostring(nLevel) .. '.max', 0);
        local nSlotsUsed = DB.getValue(nodeChar, 'powermeta.pactmagicslots' .. tostring(nLevel) .. '.used', 0);
        if nSlotsUsed < nSlotsMax then
            DB.setValue(nodeChar, 'powermeta.pactmagicslots' .. tostring(nLevel) .. '.used', 'number', nSlotsUsed + 1);
        end
    else
        local nSlotsMax = DB.getValue(nodeChar, 'powermeta.spellslots' .. tostring(nLevel) .. '.max', 0);
        local nSlotsUsed = DB.getValue(nodeChar, 'powermeta.spellslots' .. tostring(nLevel) .. '.used', 0);
        if nSlotsUsed < nSlotsMax then
            DB.setValue(nodeChar, 'powermeta.spellslots' .. tostring(nLevel) .. '.used', 'number', nSlotsUsed + 1);
        end
    end
end

function getSpellSlots(nodeChar, nLevel)
    local aSpellSlots = {};
    for i = nLevel, 9 do
        local nSlotsMax = DB.getValue(nodeChar, 'powermeta.spellslots' .. tostring(i) .. '.max', 0);
        local nSlotsUsed = DB.getValue(nodeChar, 'powermeta.spellslots' .. tostring(i) .. '.used', 0);
        if nSlotsUsed < nSlotsMax then
            aSpellSlots[i] = nSlotsMax - nSlotsUsed;
        end
    end
    return aSpellSlots;
end

function addNPCtoCT(tCustom)
    onNPCPostAdd(tCustom)
    local nodeFeatures = DB.getChild(tCustom.nodeCT, 'traits')
    if nodeFeatures then
        local aFeatures = DB.getChildList(nodeFeatures);
        for _, nodeFeature in pairs(aFeatures) do
            local sFeatureName = DB.getValue(nodeFeature, 'name', '');
            if sFeatureName:upper() == 'ARCANE WARD' then
                local sDesc = DB.getValue(nodeFeature, 'desc', '');
                local aWords = StringManager.parseWords(sDesc);
                local nArcaneWard;
                local i = 1;
                while aWords[i] do
                    if StringManager.isWord(aWords[i], 'hit') and StringManager.isWord(aWords[i + 1], 'points') then
                        nArcaneWard = tonumber(aWords[i - 1]);
                        DB.setValue(tCustom.nodeCT, 'arcaneward', 'number', 1);
                        DB.setValue(tCustom.nodeCT, 'arcanewardhp', 'number', nArcaneWard);
                        break
                    end
                    i = i + 1;
                end
            end
        end
    end
end

-- Modified from coreRPG to also return the CTNode whom applied the effect
-- 5E version is too bloated for what we need
function getEffectsByType(rActor, sEffectCompType, rFilterActor, bTargetedOnly)
    if not rActor then
        return {};
    end
    local tResults = {};
    local tEffectCompParams = {};
    tEffectCompParams[sEffectCompType] = {};
    -- Iterate through effects
    for _, v in pairs(ActorManager.getEffects(rActor)) do
        -- Check active
        local nActive = DB.getValue(v, 'isactive', 0);
        local bActive = (tEffectCompParams.bIgnoreExpire and (nActive == 1)) or
                            (not tEffectCompParams.bIgnoreExpire and (nActive ~= 0));

        if bActive then
            -- If effect type we are looking for supports targets, then check targeting
            local bTargetMatch;
            if tEffectCompParams.bIgnoreTarget then
                bTargetMatch = true;
            else
                local bTargeted = EffectManager.isTargetedEffect(v);
                if bTargeted then
                    bTargetMatch = EffectManager.isEffectTarget(v, rFilterActor);
                else
                    bTargetMatch = not bTargetedOnly;
                end
            end

            if bTargetMatch then
                local sLabel = DB.getValue(v, 'label', '');
                local aEffectComps = EffectManager.parseEffect(sLabel);
                -- Look for type/subtype match
                local nMatch = 0;
                for kEffectComp, sEffectComp in ipairs(aEffectComps) do
                    local rEffectComp = EffectManager.parseEffectCompSimple(sEffectComp);
                    if rEffectComp.type:upper() == sEffectCompType or rEffectComp.original:upper() == sEffectCompType then
                        nMatch = kEffectComp;
                        if nActive == 1 then
                            rEffectComp.source_name = DB.getValue(v, 'source_name', '');
                            table.insert(tResults, rEffectComp);
                        end
                    end
                end -- END EFFECT COMPONENT LOOP

                -- Remove one shot effects
                if (nMatch > 0) and not tEffectCompParams.bIgnoreExpire then
                    if nActive == 2 then
                        DB.setValue(v, 'isactive', 'number', 1);
                    else
                        local sApply = DB.getValue(v, 'apply', '');
                        if sApply == 'action' then
                            EffectManager.notifyExpire(v, 0);
                        elseif sApply == 'roll' then
                            EffectManager.notifyExpire(v, 0, true);
                        elseif sApply == 'single' then
                            EffectManager.notifyExpire(v, nMatch, true);
                        end
                    end
                end
            end -- END TARGET CHECK
        end -- END ACTIVE CHECK
    end -- END EFFECT LOOP

    -- RESULTS
    return tResults;
end
