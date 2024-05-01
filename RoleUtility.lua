local ROLE = require(GetScriptDirectory() .. '\\_RoleUtility')
if GetGameMode() == GAMEMODE_CM then
    function ROLE.GetCurrentSuitableRole(bot, hero)
        local UTIL = require(GetScriptDirectory() .. '\\cmai\\utils')
        local role = 
        {
            ['safe']    = 'carry',
            ['mid']     = 'midlaner',
            ['off']     = 'offlaner',
            ['soft']    = 'support',
            ['hard']    = 'support',
        }
        return role[UTIL.GetHeroRoles()[hero]]
    end
end
return ROLE