local ITEM = require( GetScriptDirectory() .. '\\FunLib\\_aba_item' )
if GetGameMode() == GAMEMODE_CM then
	function _ITEM.GetRoleItemsBuyList( bot )
		local UTILS = require( GetScriptDirectory() .. '\\cmai\\utils' )
		local role = 
		{
			['safe']    = 'pos_1',
			['mid']     = 'pos_2',
			['off']     = 'pos_3',
			['soft']    = 'pos_4',
			['hard']    = 'pos_5',
		}
		return role[UTILS.GetHeroRoles()[bot:GetUnitName()]] or 'pos_1'
	end
end
return ITEM