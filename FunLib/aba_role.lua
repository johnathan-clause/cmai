local ROLE = require(GetScriptDirectory() .. '\\FunLib\\_aba_role')
if GetGameMode() == GAMEMODE_CM then
    function ROLE.GetCurrentSuitableRole(bot, hero)
        local UTILS = require(GetScriptDirectory() .. '\\cmai\\utils')
        local role = 
        {
            ['safe']      = 'carry',
            ['mid']       = 'midlaner',
            ['off']       = 'offlaner',
            ['soft']      = 'support',
            ['hard']      = 'support',
        }
        return role[UTILS.GetHeroRoles()[hero]]
    end
end
return ROLE