local _JMZ = require( GetScriptDirectory() .. '\\FunLib\\_jmz_func' );
function _JMZ.GetPosition( bot )
    local UTILS = require( GetScriptDirectory() .. '\\cmai\\utils' );
    local pos = 
    {
        ['safe'] = 1,
        ['mid'] = 2,
        ['off'] = 3,
        ['soft'] = 4,
        ['hard'] = 5,
    }
    return pos[UTILS.GetHeroRoles()[bot:GetUnitName()]] or 1
end
return _JMZ