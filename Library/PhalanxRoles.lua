local ROLES = require( GetScriptDirectory() .. '\\Library\\_PhalanxRoles' );
function ROLES.GetPRole(bot, hero)
    local UTILS = require( GetScriptDirectory() .. '\\cmai\\utils' );
    local role = 
    {
        ['safe']    = 'SafeLane',
        ['mid']     = 'MidLane',
        ['off']     = 'OffLane',
        ['soft']    = 'SoftSupport',
        ['hard']    = 'HardSupport',
    }
    return role[UTILS.GetHeroRoles()[hero]]
end
return ROLES