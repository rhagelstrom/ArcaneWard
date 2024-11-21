--
-- Please see the license.txt file included with this distribution for
-- attribution and copyright information.
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
