local ITEM = require( GetScriptDirectory() .. '\\FunLib\\_aba_item' )
if GetGameMode() == GAMEMODE_CM then
    function ITEM.GetOutfitType( bot )
        local UTILS = require( GetScriptDirectory() .. '\\cmai\\utils' )
        local outfit = 
        {
            ['safe']    = 'outfit_carry',
            ['mid']     = 'outfit_mid',
            ['off']     = 'outfit_tank',
            ['soft']    = 'outfit_mage',
            ['hard']    = 'outfit_priest',
        }
        return outfit[UTILS.GetHeroRoles()[bot:GetUnitName()]]
    end
end
return ITEM