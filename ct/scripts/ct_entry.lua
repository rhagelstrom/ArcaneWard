--		Author: Ryan Hagelstrom
--		Copyright © 2022
--		This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--		https://creativecommons.org/licenses/by-sa/4.0/
--
-- luacheck: globals linkPCFields
function linkPCFields()
    local nodeChar = link.getTargetDatabaseNode();
    if nodeChar then
        arcanewardhp.setLink(nodeChar.createChild('hp.arcaneward', 'number'));
    end
    if super and super.linkPCFields then
        super.linkPCFields();
    end
end
