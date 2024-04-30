local _ROLE = require( GetScriptDirectory() .. '\\_RoleUtility' );
local _getCurrentSuitableRole = _ROLE.GetCurrentSuitableRole;
function _ROLE.GetCurrentSuitableRole(bot, hero)
    local UTIL = require( GetScriptDirectory() .. '\\cmai\\utils' );
    local role = 
    {
        ['safe']    = 'carry',
        ['mid']     = 'midlaner',
        ['off']     = 'offlaner',
        ['soft']    = 'support',
        ['hard']    = 'support',
    }
    return GetGameMode() == GAMEMODE_CM and role[UTIL.GetHeroRoles()[hero]]
        or _getCurrentSuitableRole(bot, hero)
end
return _ROLE