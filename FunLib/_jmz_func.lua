----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------


local J = {}


local sDota2Version= '7.33'
local sDebugVersion= '20230423ver1.9'
local bDebugMode = ( 1 == 10 )
local bDebugTeam = ( GetTeam() == TEAM_RADIANT )
local sDebugHero = 'npc_dota_hero_luna'
local tAllyIDList = GetTeamPlayers( GetTeam() )
local tAllyHeroList = {}
local tAllyHumanList = {}
local nAllyTotalKill = 0
local nAllyAverageLevel = 1
local tEnemyIDList = GetTeamPlayers( GetOpposingTeam() )
local tEnemyHeroList = {}
local tEnemyHumanList = {}
local nEnemyTotalKill = 0
local nEnemyAverageLevel = 1


local RB = Vector( -6619, -6336, 384 )
local DB = Vector( 6928, 6372, 392 )
local roshanRadiantLoc  = Vector(7625, -7511, 1092)
local roshanDireLoc = Vector(-7549, 7562, 1107)
local RadiantTormentorLoc = Vector(-8075, -1148, 1000)
local DireTormentorLoc = Vector(8132, 1102, 1000)
local fKeepManaPercent = 0.39


for i, id in pairs( tAllyIDList )
do

	local bHuman = not IsPlayerBot( id )
	local hHero = GetTeamMember( i )

	if hHero ~= nil
	then
		if bHuman then table.insert( tAllyHumanList, hHero ) end
		table.insert( tAllyHeroList, hHero )
	end

end


J.Site = require( GetScriptDirectory()..'/FunLib/aba_site' )
J.Item = require( GetScriptDirectory()..'/FunLib/aba_item' )
J.Buff = require( GetScriptDirectory()..'/FunLib/aba_buff' )
J.Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
J.Skill = require( GetScriptDirectory()..'/FunLib/aba_skill' )
J.Chat = require( GetScriptDirectory()..'/FunLib/aba_chat' )


if bDebugTeam
then
	print( GetTeam()..': Function Init Successful!' )
end



function J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, sBuyList, sSellList )

	local bot = GetBot()

	if J.Role.IsUserHero() 
	then

		local sBotDir = J.Chat.GetHeroDirName( bot )
		
		if J.Chat.GetNormName(bot) == '力丸'  --修复力丸的错误路径
			and xpcall( function( loadDir ) require( loadDir ) end, function( err ) print( err ) end, sBotDir ) == false
		then sBotDir = sBotDir..' '	end

		if xpcall( function( loadDir ) require( loadDir ) end, function( err ) print( err ) end, sBotDir )
		then
			local BotSet = require( sBotDir )
			if J.Chat.GetRawGameWord( BotSet['ShiFouShengXiao'] ) == true
			then
				nAbilityBuildList = BotSet['JiNeng']
				nTalentBuildList = J.Chat.GetTalentBuildList( BotSet['TianFu'] )
				sBuyList = J.Chat.GetItemBuildList( BotSet['ChuZhuang'] )
				sSellList = J.Chat.GetItemBuildList( BotSet['GuoDuZhuang'] )
				if J.Chat.GetRawGameWord( BotSet['ShiFouDaFuZhu'] ) == true
				then J.Role.SetUserSup( bot ) end
			end
		end

	end

	return nAbilityBuildList, nTalentBuildList, sBuyList, sSellList

end


local tInitList = {}
function J.PrintInitMessage( sFlag, sMessage )

	local bot = GetBot()

	if not J.IsDebugHero( bot ) or tInitList[sFlag] ~= nil then return end

	tInitList[sFlag] = true

	local botName = string.gsub( string.sub( bot:GetUnitName(), 15 ), '_', '' )

	print( 'A Beginner AI '..string.sub( botName, 1, 4 )..': '..string.sub( sFlag, 1, 5 )..' with '..sMessage..' init successful!' )

end


function J.IsDebugHero( bot )

	return bDebugMode
			and bDebugTeam
			and bot:GetUnitName() == sDebugHero

end

function J.HasQueuedAction( bot )

	if bot ~= GetBot() 
	then
		return false 
	end
	
	return bot:NumQueuedActions() > 0
	
end

function J.CanNotUseAction( bot )

	return not bot:IsAlive()
			or J.HasQueuedAction( bot )
			or bot:IsInvulnerable()
			or bot:IsCastingAbility()
			or bot:IsUsingAbility()
			or bot:IsChanneling()
			or bot:IsStunned()
			or bot:IsNightmared()
			or bot:HasModifier( 'modifier_item_forcestaff_active' )
			or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )

end

function J.CanNotUseAbility( bot )

	return not bot:IsAlive()
			or J.HasQueuedAction( bot )
			or bot:IsInvulnerable()
			or bot:IsCastingAbility()
			or bot:IsUsingAbility()
			or bot:IsChanneling()
			or bot:IsSilenced()
			or bot:IsStunned()
			or bot:IsHexed()
			or bot:IsNightmared()
			or bot:HasModifier( "modifier_doom_bringer_doom" )
			or bot:HasModifier( 'modifier_item_forcestaff_active' )

end



--友军生物数量
function J.GetUnitAllyCountAroundEnemyTarget( target, nRadius )

	local targetLoc = target:GetLocation()
	local heroCount = J.GetNearbyAroundLocationUnitCount( false, true, nRadius, targetLoc )
	local creepCount = J.GetNearbyAroundLocationUnitCount( false, false, nRadius, targetLoc )

	return heroCount + creepCount

end


--敌军生物数量
function J.GetAroundTargetEnemyUnitCount( target, nRadius )

	local targetLoc = target:GetLocation()
	local heroCount = J.GetNearbyAroundLocationUnitCount( true, true, nRadius, targetLoc )
	local creepCount = J.GetNearbyAroundLocationUnitCount( true, false, nRadius, targetLoc )

	return heroCount + creepCount

end


--敌军英雄数量
function J.GetAroundTargetEnemyHeroCount( target, nRadius )

	return J.GetNearbyAroundLocationUnitCount( true, true, nRadius, target:GetLocation() )

end


--通用数量
function J.GetNearbyAroundLocationUnitCount( bEnemy, bHero, nRadius, vLoc )

	local bot = GetBot()
	local nCount = 0
	local unitList = {}

	if bHero
	then
		unitList = bot:GetNearbyHeroes( 1600, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyCreeps( 1600, bEnemy )
	end

	for _, u in pairs( unitList )
	do
		if u:IsAlive()
			and GetUnitToLocationDistance( u, vLoc ) <= nRadius
		then
			nCount = nCount + 1
		end
	end

	return nCount

end


function J.GetAttackEnemysAllyCreepCount( target, nRadius )

	local bot = GetBot()
	local nAllyCreeps = bot:GetNearbyCreeps( nRadius, false )
	local nAttackEnemyCount = 0
	for _, creep in pairs( nAllyCreeps )
	do
		if creep:IsAlive()
			and creep:CanBeSeen()
			and creep:GetAttackTarget() == target
		then
			nAttackEnemyCount = nAttackEnemyCount + 1
		end
	end

	return nAttackEnemyCount

end


function J.GetVulnerableWeakestUnit( bot, bHero, bEnemy, nRadius )

	local unitList = {}
	local weakest = nil
	local weakestHP = 10000
	if bHero
	then
		unitList = bot:GetNearbyHeroes( nRadius, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	end

	for _, u in pairs( unitList )
	do
		if u:GetHealth() < weakestHP
			and J.CanCastOnNonMagicImmune( u )
		then
			weakest = u
			weakestHP = u:GetHealth()
		end
	end

	return weakest

end


function J.GetVulnerableUnitNearLoc( bot, bHero, bEnemy, nCastRange, nRadius, vLoc )

	local unitList = {}
	local weakest = nil
	local weakestHP = 10000

	if bHero
	then
		unitList = bot:GetNearbyHeroes( nCastRange, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nCastRange, bEnemy )
	end

	for _, u in pairs( unitList )
	do
		if GetUnitToLocationDistance( u, vLoc ) < nRadius
			and u:GetHealth() < weakestHP
			and J.CanCastOnNonMagicImmune( u )
		then
			weakest = u
			weakestHP = u:GetHealth()
		end
	end

	return weakest

end


function J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, nCount )

	local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )

	if nAoe.count >= nCount
	then
		local nEnemyHeroList = J.GetEnemyList( bot, 1600 )
		local nTrueCount = 0
		for _, enemy in pairs( nEnemyHeroList )
		do
			if GetUnitToLocationDistance( enemy, nAoe.targetloc ) <= nRadius
				and not enemy:IsMagicImmune()
			then
				nTrueCount = nTrueCount + 1
			end
		end

		if nTrueCount >= nCount
		then
			return nAoe.targetLoc
		end
	end

	return nil

end


function J.IsWithoutTarget( bot )

	return bot:CanBeSeen()
			and bot:GetAttackTarget() == nil
			and ( bot:GetTeam() == GetBot():GetTeam() and bot:GetTarget() == nil ) 
end


function J.GetProperTarget( bot )

	local target = nil
	
	if ( bot:GetTeam() == GetBot():GetTeam() )
	then
		target = bot:GetTarget()
	end

	if target == nil and bot:CanBeSeen()
	then
		target = bot:GetAttackTarget()
	end

	if target ~= nil
		and target:GetTeam() == bot:GetTeam()
		and ( target:IsHero() or target:IsBuilding() )
	then
		target = nil
	end

	return target

end


function J.IsAllyCanKill( target )

	if target:GetHealth() / target:GetMaxHealth() > 0.38
	then
		return false
	end

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nTeamMember = GetTeamPlayers( GetTeam() )
	for i = 1, #nTeamMember
	do
		local ally = GetTeamMember( i )
		if ally ~= nil and ally:IsAlive() and ally:CanBeSeen()
			and ( ally:GetAttackTarget() == target )
			and GetUnitToUnitDistance( ally, target ) <= ally:GetAttackRange() + 50
		then
			nTotalDamage = nTotalDamage + ally:GetAttackDamage()
		end
	end

	nTotalDamage = nTotalDamage * 2.44 + J.GetAttackProjectileDamageByRange( target, 1200 )

	if J.CanKillTarget( target, nTotalDamage, nDamageType )
	then
		return true
	end

	return false

end


function J.IsOtherAllyCanKillTarget( bot, target )

	if target:GetHealth() / target:GetMaxHealth() > 0.38
	then
		return false
	end

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nTeamMember = GetTeamPlayers( GetTeam() )

	for i = 1, #nTeamMember
	do
		local ally = GetTeamMember( i )
		if ally ~= nil
			and ally ~= bot
			and ally:IsAlive()
			and not J.IsDisabled( ally )
			and ally:GetHealth() / ally:GetMaxHealth() > 0.15
			and ally:IsFacingLocation( target:GetLocation(), 20 )
			and GetUnitToUnitDistance( ally, target ) <= ally:GetAttackRange() + 50
		then
			local allyTarget = J.GetProperTarget( ally )
			if allyTarget == nil or allyTarget == target or J.IsHumanPlayer( ally )
			then
				local allyDamageTime = J.IsHumanPlayer( ally ) and 6.0 or 2.0
				nTotalDamage = nTotalDamage + ally:GetEstimatedDamageToTarget( true, target, allyDamageTime, DAMAGE_TYPE_PHYSICAL )
			end
		end
	end

	if nTotalDamage > target:GetHealth()
	then
		return true
	end

	return false
end


function J.GetAlliesNearLoc( vLoc, nRadius )

	local allies = {}
	for i = 1, 5
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToLocationDistance( member, vLoc ) <= nRadius
		then
			table.insert( allies, member )
		end
	end

	return allies

end

function J.GetEnemiesNearLoc(vLoc, nRadius)
	local enemies = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsMeepoClone(enemyHero)
		and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
		then
			table.insert(enemies, enemyHero)
		end
	end

	return enemies
end


function J.IsAllyHeroBetweenAllyAndEnemy( hAlly, hEnemy, vLoc, nRadius )

	local vStart = hAlly:GetLocation()
	local vEnd = vLoc
	local heroList = hAlly:GetNearbyHeroes( 1600, false, BOT_MODE_NONE )
	for i, hero in pairs( heroList )
	do
		if hero ~= hAlly
		then
			local tResult = PointToLineDistance( vStart, vEnd, hero:GetLocation() )
			if tResult ~= nil
				and tResult.within
				and tResult.distance <= nRadius + 50
			then
				return true
			end
		end
	end

	heroList = hEnemy:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	for i, hero in pairs( heroList )
	do
		if hero ~= hAlly
		then
			local tResult = PointToLineDistance( vStart, vEnd, hero:GetLocation() )
			if tResult ~= nil
				and tResult.within
				and tResult.distance <= nRadius + 50
			then
				return true
			end
		end
	end

	return false

end


function J.IsSandKingThere( bot, nCastRange, fTime )

	return false

end


function J.GetUltimateAbility( bot )

	return bot:GetAbilityInSlot( 5 )

end


function J.CanUseRefresherShard( bot )

	local ult = J.GetUltimateAbility( bot )

	if ult ~= nil
		and ult:IsPassive() == false
	then
		local ultCD = ult:GetCooldown()
		local manaCost = ult:GetManaCost()
		if bot:GetMana() >= manaCost * 2
			and ult:GetCooldownTimeRemaining() >= ultCD / 2
		then
			return true
		end
	end

	return false

end


function J.GetMostUltimateCDUnit()

	local unit = nil
	local maxCD = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if member ~= nil and member:IsAlive()
				and member:GetUnitName() ~= "npc_dota_hero_nevermore"
				and member:GetUnitName() ~= "npc_dota_hero_arc_warden"
			then
				if member:GetUnitName() == "npc_dota_hero_silencer" or member:GetUnitName() == "npc_dota_hero_warlock"
				then
					return member
				end
				local ult = J.GetUltimateAbility( member )
				if ult ~= nil
					and ult:IsPassive() == false
					and ult:GetCooldown() >= maxCD
				then
					unit = member
					maxCD = ult:GetCooldown()
				end
			end
		end
	end

	return unit

end


function J.GetPickUltimateScepterUnit()

	local unit = nil
	local maxNetWorth = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if member ~= nil and member:IsAlive()
				and not member:HasScepter()
				and ( member:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
					 or not member:IsBot() )
			then
				if not member:IsBot()
				then
					return member
				end

				if member:GetUnitName() ~= "npc_dota_hero_warlock"
					and member:GetUnitName() ~= "npc_dota_hero_zuus"
					and ( member:GetItemInSlot( 8 ) == nil or member:GetItemInSlot( 7 ) == nil )
				then
					local mNetWorth = member:GetNetWorth()
					if mNetWorth >= maxNetWorth
					then
						unit = member
						maxNetWorth = mNetWorth
					end
				end
			end
		end
	end

	return unit

end


function J.CanUseRefresherOrb( bot )

	local ult = J.GetUltimateAbility( bot )

	if ult ~= nil
		and ult:IsPassive() == false
	then
		local ultCD = ult:GetCooldown()
		local manaCost = ult:GetManaCost()
		if bot:GetMana() >= manaCost + 375
			and ult:GetCooldownTimeRemaining() >= ultCD / 2
		then
			return true
		end
	end

	return false
end


function J.IsSuspiciousIllusion( npcTarget )

	if not npcTarget:IsHero()
		or npcTarget:IsCastingAbility()
		or npcTarget:IsUsingAbility()
		or npcTarget:IsChanneling()
		-- or npcTarget:HasModifier( "modifier_item_satanic_unholy" )
		-- or npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
		-- or npcTarget:HasModifier( "modifier_black_king_bar_immune" )
		-- or npcTarget:HasModifier( "modifier_rune_doubledamage" )
		-- or npcTarget:HasModifier( "modifier_rune_regen" )
		-- or npcTarget:HasModifier( "modifier_rune_haste" )
		-- or npcTarget:HasModifier( "modifier_rune_arcane" )
		-- or npcTarget:HasModifier( "modifier_item_phase_boots_active" )
	then
		return false
	end

	local bot = GetBot()

	if npcTarget:GetTeam() == bot:GetTeam()
	then
		return npcTarget:IsIllusion() or npcTarget:HasModifier( "modifier_arc_warden_tempest_double" )
	elseif npcTarget:GetTeam() == GetOpposingTeam()
	then

		if npcTarget:HasModifier( 'modifier_illusion' )
			or npcTarget:HasModifier( 'modifier_phantom_lancer_doppelwalk_illusion' )
			or npcTarget:HasModifier( 'modifier_phantom_lancer_juxtapose_illusion' )
			or npcTarget:HasModifier( 'modifier_darkseer_wallofreplica_illusion' )
			or npcTarget:HasModifier( 'modifier_terrorblade_conjureimage' )
		then
			return true
		end

		local tID = npcTarget:GetPlayerID()

		if not IsHeroAlive( tID )
		then
			return true
		end

		if GetHeroLevel( tID ) > npcTarget:GetLevel()
		then
			return true
		end
		--[[
		if GetSelectedHeroName( tID ) ~= "npc_dota_hero_morphling"
			and GetSelectedHeroName( tID ) ~= npcTarget:GetUnitName()
		then
			return true
		end
		--]]
	end

	return false

end


function J.CanCastAbilityOnTarget( npcTarget, bIgnoreMagicImmune )

	return npcTarget:CanBeSeen()
			and ( bIgnoreMagicImmune or not npcTarget:IsMagicImmune() )
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			-- and not J.IsAllyCanKill( npcTarget )

end


function J.CanCastOnMagicImmune( npcTarget )

	return npcTarget:CanBeSeen()
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			and not J.IsAllyCanKill( npcTarget )

end


function J.CanCastOnNonMagicImmune( npcTarget )

	return npcTarget:CanBeSeen()
			and (not npcTarget:IsMagicImmune() or (not npcTarget:IsMagicImmune() and J.IsInEtherealForm( npcTarget )))
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			and not J.IsAllyCanKill( npcTarget )

end

function J.IsInEtherealForm( npcTarget )
	return npcTarget:HasModifier( "modifier_ghost_state" )
    or npcTarget:HasModifier( "modifier_item_ethereal_blade_ethereal" )
    or npcTarget:HasModifier( "modifier_necrolyte_death_seeker" )
    or npcTarget:HasModifier( "modifier_necrolyte_sadist_active" )
    or npcTarget:HasModifier( "modifier_pugna_decrepify" )
end

function J.CanCastOnTargetAdvanced( npcTarget )

	if npcTarget:GetUnitName() == 'npc_dota_hero_antimage' --and npcTarget:IsBot()
	then

		if npcTarget:HasModifier( "modifier_antimage_spell_shield" )
			and J.GetModifierTime( npcTarget, "modifier_antimage_spell_shield" ) > 0.27
		then
			return false
		end

		if npcTarget:IsSilenced()
			or npcTarget:IsStunned()
			or npcTarget:IsHexed()
			or npcTarget:IsNightmared()
			or npcTarget:IsChanneling()
			or J.IsTaunted( npcTarget )
			or npcTarget:GetMana() < 45
			or ( npcTarget:HasModifier( "modifier_antimage_spell_shield" )
				and J.GetModifierTime( npcTarget, "modifier_antimage_spell_shield" ) < 0.27 )
		then
			if not npcTarget:HasModifier( "modifier_item_sphere_target" )
				and not npcTarget:HasModifier( "modifier_item_lotus_orb_active" )
				and not npcTarget:HasModifier( "modifier_item_aeon_disk_buff" )
				and ( not npcTarget:HasModifier( "modifier_dazzle_shallow_grave" ) or npcTarget:GetHealth() > 300 )
			then
				return true
			end
		end

		return false
	end

	return not npcTarget:HasModifier( "modifier_item_sphere_target" )
			and not npcTarget:HasModifier( "modifier_antimage_spell_shield" )
			and not npcTarget:HasModifier( "modifier_item_lotus_orb_active" )
			and not npcTarget:HasModifier( "modifier_item_aeon_disk_buff" )
			and ( not npcTarget:HasModifier( "modifier_dazzle_shallow_grave" ) or npcTarget:GetHealth() > 300 )

end


--加入时间后的进阶函数
function J.CanCastUnitSpellOnTarget( npcTarget, nDelay )

	for _, modifier in pairs( J.Buff["hero_has_spell_shield"] )
	do
		if npcTarget:HasModifier( modifier )
			and J.GetModifierTime( npcTarget, modifier ) >= nDelay
		then
			return false
		end
	end

	return true

end


function J.CanKillTarget( npcTarget, dmg, dmgType )

	return npcTarget:GetActualIncomingDamage( dmg, dmgType ) >= npcTarget:GetHealth()

end


--未计算技能增强
function J.WillKillTarget( npcTarget, dmg, dmgType, nDelay )

	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * nDelay + 0.8

	local nRealBonus = J.GetTotalAttackWillRealDamage( npcTarget, nDelay )

	local nTotalDamage = npcTarget:GetActualIncomingDamage( dmg, dmgType ) + nRealBonus

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1

end


--未计算技能增强
function J.WillMixedDamageKillTarget( npcTarget, nPhysicalDamge, nMagicalDamage, nPureDamage, nDelay )

	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * nDelay + 0.8

	local nRealBonus = J.GetTotalAttackWillRealDamage( npcTarget, nDelay )

	local nRealPhysicalDamge = npcTarget:GetActualIncomingDamage( nPhysicalDamge, DAMAGE_TYPE_PHYSICAL )

	local nRealMagicalDamge = npcTarget:GetActualIncomingDamage( nMagicalDamage, DAMAGE_TYPE_MAGICAL )

	local nRealPureDamge = npcTarget:GetActualIncomingDamage( nPureDamage, DAMAGE_TYPE_PURE )

	local nTotalDamage = nRealPhysicalDamge + nRealMagicalDamge + nRealPureDamge + nRealBonus

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1

end

--计算了技能增强
function J.WillMagicKillTarget( bot, npcTarget, dmg, nDelay )

	local nDamageType = DAMAGE_TYPE_MAGICAL

	local MagicResistReduce = 1 - npcTarget:GetMagicResist()

	if MagicResistReduce < 0.05 then MagicResistReduce = 0.05 end

	local HealthBack = npcTarget:GetHealthRegen() * nDelay

	local EstDamage = dmg * ( 1 + bot:GetSpellAmp() ) - HealthBack / MagicResistReduce

	if npcTarget:HasModifier( "modifier_medusa_mana_shield" )
	then
		local EstDamageMaxReduce = EstDamage * 0.98
		if npcTarget:GetMana() * 2.8 >= EstDamageMaxReduce
		then
			EstDamage = EstDamage * 0.04
		else
			EstDamage = EstDamage * 0.02 + EstDamageMaxReduce - npcTarget:GetMana() * 2.8
		end
	end

	if npcTarget:GetUnitName() == "npc_dota_hero_bristleback"
		and not npcTarget:IsFacingLocation( bot:GetLocation(), 120 )
	then
		EstDamage = EstDamage * 0.7
	end

	if npcTarget:HasModifier( "modifier_kunkka_ghost_ship_damage_delay" )
	then
		local buffTime = J.GetModifierTime( npcTarget, "modifier_kunkka_ghost_ship_damage_delay" )
		if buffTime >= nDelay then EstDamage = EstDamage * 0.55 end
	end

	if npcTarget:HasModifier( "modifier_templar_assassin_refraction_absorb" )
	then
		local buffTime = J.GetModifierTime( npcTarget, "modifier_templar_assassin_refraction_absorb" )
		if buffTime >= nDelay then EstDamage = 0 end
	end

	local nRealDamage = npcTarget:GetActualIncomingDamage( EstDamage, nDamageType )

	return nRealDamage >= npcTarget:GetHealth() --, nRealDamage

end


function J.HasForbiddenModifier( npcTarget )

	for _, mod in pairs( J.Buff['enemy_is_immune'] )
	do
		if npcTarget:HasModifier( mod )
		then
			return true
		end
	end

	if npcTarget:IsHero()
	then
		local enemies = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE )
		if enemies ~= nil and #enemies >= 2
		then
			for _, mod in pairs( J.Buff['enemy_is_undead'] )
			do
				if npcTarget:HasModifier( mod )
				then
					return true
				end
			end
		end
		
		if not npcTarget:IsBot()
		then
			
			local nID = npcTarget:GetPlayerID()
			local nKillCount = GetHeroKills( nID )
			local nDeathCount = GetHeroDeaths( nID )
			
			if nDeathCount >= 6 
				and nKillCount <= 6
				and nKillCount / nDeathCount <= 0.5
			then
				return true
			end
		
		end
		
	else
		if npcTarget:HasModifier( "modifier_crystal_maiden_frostbite" )
			or npcTarget:HasModifier( "modifier_fountain_glyph" )
		then
			return true
		end
	end
	
	return false
end


function J.ShouldEscape( bot )

	local tableNearbyAttackAllies = bot:GetNearbyHeroes( 800, false, BOT_MODE_ATTACK )

	if #tableNearbyAttackAllies > 0 and J.GetHP( bot ) > 0.16 then return false end

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE )
	if bot:WasRecentlyDamagedByAnyHero( 2.0 )
		or bot:WasRecentlyDamagedByTower( 2.0 )
		or #tableNearbyEnemyHeroes >= 2
	then
		return true
	end
end


function J.IsDisabled( npcTarget )

	if npcTarget:GetTeam() ~= GetTeam()
	then
		return npcTarget:IsRooted()
				or npcTarget:IsStunned()
				or npcTarget:IsHexed()
				or npcTarget:IsNightmared()
				or J.IsTaunted( npcTarget )
	else

		if npcTarget:IsStunned() and J.GetRemainStunTime( npcTarget ) > 0.8
		then
			return true
		end

		if npcTarget:IsSilenced()
			and not npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
			and J.IsWithoutTarget( npcTarget )
		then
			return true
		end

		return npcTarget:IsRooted()
				or npcTarget:IsHexed()
				or npcTarget:IsNightmared()
				or J.IsTaunted( npcTarget )

	end

end


function J.IsTaunted( npcTarget )

	return npcTarget:HasModifier( "modifier_axe_berserkers_call" )
		or npcTarget:HasModifier( "modifier_legion_commander_duel" )
		or npcTarget:HasModifier( "modifier_winter_wyvern_winters_curse" )
		or npcTarget:HasModifier( "modifier_winter_wyvern_winters_curse_aura" )

end


function J.IsInRange( bot, npcTarget, nRadius )

	return GetUnitToUnitDistance( bot, npcTarget ) <= nRadius

end


function J.IsInLocRange( npcTarget, nLoc, nRadius )

	return GetUnitToLocationDistance( npcTarget, nLoc ) <= nRadius

end


function J.IsInTeamFight( bot, nRadius )

	if nRadius == nil or nRadius > 1600 then nRadius = 1600 end

	local attackModeAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_ATTACK )

	return #attackModeAllyList >= 2 -- and bot:GetActiveMode() ~= BOT_MODE_RETREAT

end


function J.IsRetreating( bot )

	local mode = bot:GetActiveMode()
	local modeDesire = bot:GetActiveModeDesire()
	local bDamagedByAnyHero = bot:WasRecentlyDamagedByAnyHero( 2.0 )

	return ( mode == BOT_MODE_RETREAT and modeDesire > BOT_MODE_DESIRE_MODERATE and bot:DistanceFromFountain() > 0 )
		 or ( mode == BOT_MODE_EVASIVE_MANEUVERS and bDamagedByAnyHero )
		 or ( bot:HasModifier( 'modifier_bloodseeker_rupture' ) and bDamagedByAnyHero )
		 or ( mode == BOT_MODE_FARM and modeDesire > BOT_MODE_DESIRE_ABSOLUTE )
		
end


function J.IsGoingOnSomeone( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_ROAM
		or mode == BOT_MODE_TEAM_ROAM
		or mode == BOT_MODE_GANK
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY

end


function J.IsDefending( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT

end


function J.IsPushing( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_PUSH_TOWER_TOP
		or mode == BOT_MODE_PUSH_TOWER_MID
		or mode == BOT_MODE_PUSH_TOWER_BOT

end


function J.IsLaning( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_LANING

end


function J.IsDoingRoshan( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_ROSHAN

end


function J.IsFarming( bot )

	local mode = bot:GetActiveMode()
	local nTarget = J.GetProperTarget( bot )

	return mode == BOT_MODE_FARM
			or ( nTarget ~= nil
					and nTarget:IsAlive()
					and nTarget:GetTeam() == TEAM_NEUTRAL
					and not J.IsRoshan( nTarget ) )
end


function J.IsShopping( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_RUNE
		or mode == BOT_MODE_SECRET_SHOP
		or mode == BOT_MODE_SIDE_SHOP

end


function J.GetTeamFountain()

	local Team = GetTeam()
	if Team == TEAM_DIRE
	then
		return DB
	else
		return RB
	end

end


function J.GetEnemyFountain()

	local Team = GetTeam()

	if Team == TEAM_DIRE
	then
		return RB
	else
		return DB
	end

end


function J.GetComboItem( bot, sItemName )

	local Slot = bot:FindItemSlot( sItemName )

	if Slot >= 0 and Slot <= 5
	then
		return bot:GetItemInSlot( Slot )
	end

end


function J.HasItem( bot, sItemName )

	local Slot = bot:FindItemSlot( sItemName )

	if Slot >= 0 and Slot <= 5 then	return true end

	return false

end


function J.IsItemAvailable( sItemName )

	local bot = GetBot()

	local slot = bot:FindItemSlot( sItemName )

	if slot >= 0 and slot <= 5
	then
		return bot:GetItemInSlot( slot )
	end

end


function J.GetMostHpUnit( unitList )

	local mostHpUnit = nil
	local maxHP = 0
	for _, unit in pairs( unitList )
	do
		local uHp = unit:GetHealth()
		if uHp > maxHP
		then
			mostHpUnit = unit
			maxHP = uHp
		end
	end

	return mostHpUnit

end


function J.GetLeastHpUnit( unitList )

	local leastHpUnit = nil
	local minHP = 999999

	for _, unit in pairs( unitList )
	do
		local uHp = unit:GetHealth()
		if uHp < minHP
		then
			leastHpUnit = unit
			minHP = uHp
		end
	end

	return leastHpUnit

end


function J.IsAllowedToSpam( bot, nManaCost )

	if bot:HasModifier( "modifier_silencer_curse_of_the_silent" ) then return false end

	if bot:HasModifier( "modifier_rune_regen" ) then return true end

	return ( bot:GetMana() - nManaCost ) / bot:GetMaxMana() >= fKeepManaPercent

end


function J.IsAllyUnitSpell( sAbilityName )

	return J.Skill['sAllyUnitAbilityIndex'][sAbilityName] == true

end


function J.IsProjectileUnitSpell( sAbilityName )

	return J.Skill['sProjectileAbilityIndex'][sAbilityName] == true


end


function J.IsOnlyProjectileSpell( sAbilityName )

	return J.Skill['sOnlyProjectileAbilityIndex'][sAbilityName] == true

end


function J.IsStunProjectileSpell( sAbilityName )

	return J.Skill['sStunProjectileAbilityIndex'][sAbilityName] == true

end


function J.IsWillBeCastUnitTargetSpell( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local enemyList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 20 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
				and nAbility:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
			then
				local sAbilityName = nAbility:GetName()
				if not J.IsAllyUnitSpell( sAbilityName )
				then
					if J.IsInRange( npcEnemy, bot, 330 )
						or not J.IsProjectileUnitSpell( sAbilityName )
					then
						if not J.IsHumanPlayer( npcEnemy )
						then
							return true
						else
							local nCycle = npcEnemy:GetAnimCycle()
							local nPoint = nAbility:GetCastPoint()
							if nCycle > 0.1 and nPoint * ( 1 - nCycle ) < 0.27 --极限时机0.26
							then
								return true
							end
						end
					end
				end
			end
		end
	end

	return false

end


function J.IsWillBeCastPointSpell( bot, nRadius )

	local enemyList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )

	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 50 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				if nAbility:GetBehavior() == ABILITY_BEHAVIOR_POINT
					or nAbility:GetBehavior() == ABILITY_BEHAVIOR_NO_TARGET
					or nAbility:GetBehavior() == 48
				then
					return true
				end
			end
		end
	end

	return false

end


--可躲避敌方非攻击弹道
function J.IsProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_dodgeable
			and not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil or p.caster:GetTeam() ~= GetTeam() )
			and ( p.ability ~= nil
					and not J.IsOnlyProjectileSpell( p.ability:GetName() )
					and ( p.ability:GetName() ~= "medusa_mystic_snake"
							or p.caster == nil
							or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
		then
			return true
		end
	end

	return false

end


--可反弹敌方非攻击弹道
function J.IsUnitTargetProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil
				 or ( p.caster:GetTeam() ~= bot:GetTeam()
					 and p.caster:IsHero()
					 and p.caster:GetUnitName() ~= "npc_dota_hero_antimage"
					 and p.caster:GetUnitName() ~= "npc_dota_hero_templar_assassin" ) )
			and ( p.ability ~= nil
				 and ( p.ability:GetName() ~= "medusa_mystic_snake"
						or p.caster == nil
						or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
			and ( p.ability:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
				 or not J.IsOnlyProjectileSpell( p.ability:GetName() ) )
		then
			return true
		end
	end

	return false

end


--将被眩晕的弹道
function J.IsStunProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and p.ability ~= nil
			and J.IsStunProjectileSpell( p.ability:GetName() )
		then
			return true
		end
	end

	return false

end


--攻击弹道
function J.IsAttackProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
		then
			return true
		end
	end

	return false

end


--非攻击敌方弹道
function J.IsNotAttackProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil or p.caster:GetTeam() ~= bot:GetTeam() )
			and ( p.ability ~= nil
					and ( p.ability:GetName() ~= "medusa_mystic_snake"
							or p.caster == nil
							or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
		then
			return true
		end
	end

	return false

end


--以下可少算但不可多算
function J.GetAttackProDelayTime( bot, nCreep )

	local botName = bot:GetUnitName()
	local botAttackRange = bot:GetAttackRange()
	local botAttackPoint = bot:GetAttackPoint()
	local botAttackSpeed = bot:GetAttackSpeed()
	local botProSpeed = bot:GetAttackProjectileSpeed()
	local botMoveSpeed = bot:GetCurrentMovementSpeed()
	local botAttackPointTime = botAttackPoint / botAttackSpeed
	local botAttackIdleTime = bot:GetSecondsPerAttack() - botAttackPointTime
	local nLastAttackRemainIdleTime = 0

	if GameTime() - bot:GetLastAttackTime() < botAttackIdleTime
	then
		nLastAttackRemainIdleTime = botAttackIdleTime - ( GameTime() - bot:GetLastAttackTime() )
	end

	local nAttackDamageDelayTime = botAttackPointTime + nLastAttackRemainIdleTime * 0.98
	local nDist = GetUnitToUnitDistance( bot, nCreep )

	if bot:CanBeSeen()
		and bot:GetAttackTarget() == nCreep
		and bot:GetAnimActivity() == 1503
		and bot:GetAnimCycle() < botAttackPoint
	then
		nAttackDamageDelayTime = 0.9 * ( botAttackPoint - bot:GetAnimCycle() ) / botAttackSpeed
	end

	if botAttackRange > 320 or botName == "npc_dota_hero_templar_assassin"
	then

		local ignoreDist = 39
		if bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT then ignoreDist = 59 end

		local projectMoveDist = nDist - ignoreDist

		if projectMoveDist < 0 then projectMoveDist = 0 end

		if projectMoveDist > botAttackRange then projectMoveDist = botAttackRange - 32 end

		nAttackDamageDelayTime = nAttackDamageDelayTime + projectMoveDist / botProSpeed

		if nDist > botAttackRange + ignoreDist / 1.2 and botName ~= "npc_dota_hero_sniper"
		then
			nAttackDamageDelayTime = nAttackDamageDelayTime + ( nDist - botAttackRange - ignoreDist / 1.2 ) / botMoveSpeed
		end

	end

	if botAttackRange < 326
		and nDist > botAttackRange + 50
		and botName ~= "npc_dota_hero_templar_assassin"
	then
		nAttackDamageDelayTime = nAttackDamageDelayTime + ( nDist - botAttackRange - 50 ) / botMoveSpeed
	end

	return nAttackDamageDelayTime

end


--当前点 * 攻击间隔 / 1.0 = 当前时
function J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )

	local bot = GetBot()
	local botLV = bot:GetLevel()
	local gameTime = GameTime()
	local nDamage = 0
	local othersBeEnemy = true

	if nUnit:GetTeam() ~= bot:GetTeam() then othersBeEnemy = false end

	local nCreeps = bot:GetNearbyLaneCreeps( 1600, othersBeEnemy )
	for _, creep in pairs( nCreeps )
	do
		if creep:CanBeSeen()
			and creep:GetAttackTarget() == nUnit
			and creep:GetAnimActivity() == 1503
			and creep:GetLastAttackTime() < gameTime - 0.2
		then
			local attackPoint	= creep:GetAttackPoint()
			local animCycle	 = creep:GetAnimCycle()
			local attackPerTime = creep:GetSecondsPerAttack()

			if J.IsKeyWordUnit( 'melee', creep )
				and animCycle < attackPoint
				and ( attackPoint - animCycle ) * attackPerTime < nTime * ( 0.99 - botLV / 300 )
			then
				nDamage = nDamage + creep:GetAttackDamage() * 1
			end

			if J.IsKeyWordUnit( 'ranged', creep )
				and animCycle < attackPoint
			then
				local nDist = GetUnitToUnitDistance( creep, nUnit ) - 22
				local nProjectSpeed = creep:GetAttackProjectileSpeed()
				local nProjectTime = nDist / ( nProjectSpeed + 1 )
				if ( attackPoint - animCycle ) * attackPerTime + nProjectTime < nTime * ( 0.98 - botLV / 200 )
				then
					nDamage = nDamage + creep:GetAttackDamage() * 1
				end
			end

			if J.IsKeyWordUnit( 'siege', creep )
				and animCycle < 0.292 --0.285
			then
				local nDist = GetUnitToUnitDistance( creep, nUnit ) - 28
				local nProjectSpeed = creep:GetAttackProjectileSpeed()
				local nProjectTime = nDist / ( nProjectSpeed + 1 )
				if ( 0.292 - animCycle ) * 0.699 / 0.292 + nProjectTime < nTime * ( 0.9 - botLV / 150 )
				then
					nDamage = nDamage + creep:GetAttackDamage() * 1
				end
			end

		end
	end

	return nUnit:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )

end


function J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime )

	local nDamage = 0
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack
			and p.caster ~= nil
		then
			local nProjectSpeed = p.caster:GetAttackProjectileSpeed()
			if p.caster:IsTower() then nProjectSpeed = nProjectSpeed * 0.93 end
			local nProjectDist = nProjectSpeed * nTime * 0.95
			local nDistance	 = GetUnitToLocationDistance( nUnit, p.location )
			if nProjectDist > nDistance * 1.02
			then
				nDamage = nDamage + p.caster:GetAttackDamage() * 1
			end
		end
	end

	return nUnit:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )

end


function J.GetTotalAttackWillRealDamage( nUnit, nTime )

	 return J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime ) + J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )

end


function J.GetAttackProjectileDamageByRange( nUnit, nRadius )

	local nDamage = 0
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack and p.caster ~= nil
			and GetUnitToLocationDistance( nUnit, p.location ) < nRadius
		then
			nDamage = nDamage + p.caster:GetAttackDamage() * 1
		end
	end

	return nDamage

end


function J.GetCorrectLoc( npcTarget, fDelay )

	local nStability = npcTarget:GetMovementDirectionStability()

	local vFirst = npcTarget:GetLocation()
	local vFuture = npcTarget:GetExtrapolatedLocation( fDelay )
	local vMidFutrue = ( vFirst + vFuture ) * 0.5
	local vLowFutrue = ( vFirst + vMidFutrue ) * 0.5
	local vHighFutrue = ( vFuture + vMidFutrue ) * 0.5


	if nStability < 0.5
	then
		return vLowFutrue
	elseif nStability < 0.7
	then
		return vMidFutrue
	elseif nStability < 0.9
	then
		return vHighFutrue
	end

	return vFuture
end


function J.GetEscapeLoc()

	local bot = GetBot()
	local team = GetTeam()

	if bot:DistanceFromFountain() > 2500
	then
		return GetAncient( team ):GetLocation()
	else
		if team == TEAM_DIRE
		then
			return DB
		else
			return RB
		end
	end

end


function J.IsStuck2( bot )

	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil
	then
		local EAd = GetUnitToUnitDistance( bot, GetAncient( GetOpposingTeam() ) )
		if DotaTime() > bot.stuckTime + 5.0 and GetUnitToLocationDistance( bot, bot.stuckLoc ) < 25
			and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and EAd > 2200
		then
			print( bot:GetUnitName().." is stuck" )
			--DebugPause()
			return true
		end
	end

	return false

end


function J.IsStuck( bot )

	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil and bot:CanBeSeen()
	then
		local attackTarget = bot:GetAttackTarget()
		local EAd = GetUnitToUnitDistance( bot, GetAncient( GetOpposingTeam() ) )
		local TAd = GetUnitToUnitDistance( bot, GetAncient( GetTeam() ) )
		local Et = bot:GetNearbyTowers( 450, true )
		local At = bot:GetNearbyTowers( 450, false )
		if bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO
			and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0
			and DotaTime() > bot.stuckTime + 5.0
			and GetUnitToLocationDistance( bot, bot.stuckLoc ) < 25
		then
			print( bot:GetUnitName().." is stuck" )
			return true
		end
	end

	return false

end


function J.IsExistInTable( u, tUnit )

	for _, t in pairs( tUnit )
	do
		if u == t
		then
			return true
		end
	end

	return false

end


function J.CombineTwoTable( tableA, tableB )

	local targetTable = tableA
	local Num = #tableA

	for i, u in pairs( tableB )
	do
		targetTable[Num + i] = u
	end

	return targetTable
end


function J.GetInvUnitInLocCount( bot, nRadius, nFindRadius, vLocation, pierceImmune )

	local nUnits = 0
	if nRadius > 1600 then nRadius = 1600 end
	local unitList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	for _, u in pairs( unitList ) do
		if ( ( pierceImmune and J.CanCastOnMagicImmune( u ) )
			 or ( not pierceImmune and J.CanCastOnNonMagicImmune( u ) ) )
			and GetUnitToLocationDistance( u, vLocation ) <= nFindRadius
		then
			nUnits = nUnits + 1
		end
	end

	return nUnits

end


function J.GetInLocLaneCreepCount( bot, nRadius, nFindRadius, vLocation )

	local nUnits = 0
	if nRadius > 1600 then nRadius = 1600 end
	local unitList = bot:GetNearbyLaneCreeps( nRadius, true )
	for _, u in pairs( unitList ) do
		if GetUnitToLocationDistance( u, vLocation ) <= nFindRadius
		then
			nUnits = nUnits + 1
		end
	end

	return nUnits

end


function J.GetInvUnitCount( pierceImmune, unitList )

	local nUnits = 0
	if unitList ~= nil
	then
		for _, u in pairs( unitList )
		do
			if ( pierceImmune and J.CanCastOnMagicImmune( u ) )
				or ( not pierceImmune and J.CanCastOnNonMagicImmune( u ) )
			then
				nUnits = nUnits + 1
			end
		end
	end

	return nUnits

end


--------------------------------------------------ew functions 2018.12.7

function J.GetDistanceFromEnemyFountain( bot )

	local EnemyFountain = J.GetEnemyFountain()
	local Distance = GetUnitToLocationDistance( bot, EnemyFountain )

	return Distance

end


function J.GetDistanceFromAllyFountain( bot )

	local OurFountain = J.GetTeamFountain()
	local Distance = GetUnitToLocationDistance( bot, OurFountain )

	return Distance

end


function J.GetDistanceFromAncient( bot, bEnemy )

	local targetAncient = GetAncient( GetTeam() )

	if bEnemy then targetAncient = GetAncient( GetOpposingTeam() ) end

	return GetUnitToUnitDistance( bot, targetAncient )

end


function J.GetAroundTargetAllyHeroCount( target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )

	return #heroList

end


function J.GetAroundTargetOtherAllyHeroCount( bot, target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )

	if GetUnitToUnitDistance( bot, target ) <= nRadius
	then
		return #heroList - 1
	end

	return #heroList

end


function J.GetAllyCreepNearLoc( bot, vLoc, nRadius )

	local AllyCreepsAll = bot:GetNearbyCreeps( 1600, false )
	local allyCreepList = { }

	for _, creep in pairs( AllyCreepsAll )
	do
		if creep ~= nil
			and creep:IsAlive()
			and GetUnitToLocationDistance( creep, vLoc ) <= nRadius
		then
			table.insert( allyCreepList, creep )
		end
	end

	return allyCreepList

end


function J.GetAllyUnitCountAroundEnemyTarget( bot, target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )
	local creepList = J.GetAllyCreepNearLoc( bot, target:GetLocation(), nRadius )

	return #heroList + #creepList

end


function J.GetAroundBotUnitList( bot, nRadius, bEnemy )

	if nRadius > 1600 then nRadius = 1600 end

	local heroList = bot:GetNearbyHeroes( nRadius, bEnemy, BOT_MODE_NONE )
	local creepList = bot:GetNearbyCreeps( nRadius, bEnemy )
	local unitList = {}

	if #heroList > 0 and #creepList > 0
	then
		unitList = heroList
		for i = 1, #creepList
		do
			table.insert( unitList, creepList[1] )
		end
	elseif #heroList == 0
	then
		unitList = creepList
	elseif #creepList == 0
	then
		unitList = heroList
	end

	return unitList

end


function J.GetLocationToLocationDistance( fLoc, sLoc )

	local x1 = fLoc.x
	local x2 = sLoc.x
	local y1 = fLoc.y
	local y2 = sLoc.y

	return math.sqrt( math.pow( ( y2-y1 ), 2 ) + math.pow( ( x2-x1 ), 2 ) )

end


function J.GetUnitTowardDistanceLocation( bot, towardTarget, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardTarget:GetLocation() - npcBotLocation ) / GetUnitToUnitDistance( bot, towardTarget )

	return npcBotLocation + nDistance * tempVector

end


function J.GetLocationTowardDistanceLocation( bot, towardLocation, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardLocation - npcBotLocation ) / GetUnitToLocationDistance( bot, towardLocation )

	return npcBotLocation + nDistance * tempVector

end


function J.GetFaceTowardDistanceLocation( bot, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempRadians = bot:GetFacing() * math.pi / 180
	local tempVector = Vector( math.cos( tempRadians ), math.sin( tempRadians ) )

	return npcBotLocation + nDistance * tempVector

end


function J.SetBotPing( vLoc )

	GetBot():ActionImmediate_Ping( vLoc.x, vLoc.y, false )

end


function J.SetBotPrint( sMessage, vLoc, bReport, bPing )

	local bot = GetBot()

	local nTime = J.GetOne( DotaTime() / 10 )* 10
	local sTime = ( J.GetOne( nTime / 600 )* 10 )..":"..( nTime%60 )
	local sTeam = GetTeam() == TEAM_DIRE and "夜魇" or "天辉"

	if bDebugMode
	then

		print( sTeam..sTime.." "..J.Chat.GetNormName( bot ).." "..sMessage )

		if bReport then bot:ActionImmediate_Chat( sTime.."_"..sMessage, true ) end

		if bPing then bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false ) end

	end

end


function J.SetReportMotive( bDebugFile, sMotive )

	if bDebugMode and bDebugFile and sMotive ~= nil
	then

		local nTime = J.GetOne( DotaTime() / 10 ) * 10
		local sTime = ( J.GetOne( nTime / 600 ) * 10 )..":"..( nTime%60 )
		local sTeam = GetTeam() == TEAM_DIRE and "夜魇 " or "天辉 "

		GetBot():ActionImmediate_Chat( sTime.."_"..sMotive, true )

		print( sTeam..sTime.." "..J.Chat.GetNormName( GetBot() ).." "..sMotive )

	end

end


function J.GetCastLocation( bot, npcTarget, nCastRange, nRadius )

	local nDistance = GetUnitToUnitDistance( bot, npcTarget )

	if nDistance <= nCastRange
	then
		return npcTarget:GetLocation()
	end

	if nDistance <= nCastRange + nRadius - 120
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange )
	end

	if nDistance < nCastRange + nRadius - 18
		and ( ( J.IsDisabled( npcTarget ) or npcTarget:GetCurrentMovementSpeed() <= 160 )
				or npcTarget:IsFacingLocation( bot:GetLocation(), 45 )
				or ( bot:IsFacingLocation( npcTarget:GetLocation(), 45 ) and npcTarget:GetCurrentMovementSpeed() <= 220 ) )
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange +18 )
	end

	if nDistance < nCastRange + nRadius + 28
		and npcTarget:IsFacingLocation( bot:GetLocation(), 30 )
		and bot:IsFacingLocation( npcTarget:GetLocation(), 30 )
		and npcTarget:GetMovementDirectionStability() > 0.95
		and npcTarget:GetCurrentMovementSpeed() >= 300
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange + 18 )
	end

	return nil

end


function J.GetDelayCastLocation( bot, npcTarget, nCastRange, nRadius, nTime )

	local nFutureLoc = J.GetCorrectLoc( npcTarget, nTime )
	local nDistance = GetUnitToLocationDistance( bot, nFutureLoc )

	if nDistance > nCastRange + nRadius - 16
	then
		return nil
	end

	if nDistance > nCastRange - nRadius * 0.38
	then
		return J.GetLocationTowardDistanceLocation( bot, nFutureLoc, nCastRange +8 )
	end

	return nFutureLoc

end


function J.GetOne( number )

	return math.floor( number * 10 ) / 10

end


function J.GetTwo( number )

	return math.floor( number * 100 ) / 100

end


function J.SetQueueToInvisible( bot )

	if bot:IsAlive()
		and not bot:IsInvisible()
		and not bot:HasModifier( "modifier_item_dustofappearance" )
	then
		local enemyTowerList = bot:GetNearbyTowers( 888, true )

		if enemyTowerList[1] ~= nil then return end

		local itemAmulet = J.IsItemAvailable( 'item_shadow_amulet' )
		if itemAmulet ~= nil
			and itemAmulet:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( itemAmulet, bot )
			return
		end
	
		local itemGlimer = J.IsItemAvailable( 'item_glimmer_cape' )
		if itemGlimer ~= nil and itemGlimer:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( itemGlimer, bot )
			return
		end

		local itemInvisSword = J.IsItemAvailable( 'item_invis_sword' )
		if itemInvisSword ~= nil and itemInvisSword:IsFullyCastable()
		then
			bot:ActionQueue_UseAbility( itemInvisSword )
			return
		end

		local itemSilverEdge = J.IsItemAvailable( 'item_silver_edge' )
		if itemSilverEdge ~= nil and itemSilverEdge:IsFullyCastable()
		then
			bot:ActionQueue_UseAbility( itemSilverEdge )
			return
		end

	end


end


function J.SetQueueSwitchPtToINT( bot )

	local pt = J.IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() == ATTRIBUTE_INTELLECT
		then
			bot:ActionQueue_UseAbility( pt )
			bot:ActionQueue_UseAbility( pt )
			return
		elseif pt:GetPowerTreadsStat() == ATTRIBUTE_STRENGTH
			then
				bot:ActionQueue_UseAbility( pt )
				return
		end
	end

end


function J.SetQueueUseSoulRing( bot )

	local sr = J.IsItemAvailable( "item_soul_ring" )

	if sr ~= nil and sr:IsFullyCastable()
	then
		local nEnemyCount = J.GetEnemyCount( bot, 1600 )
		local botHP = J.GetHP( bot )
		local botMP = J.GetMP( bot )
		if botHP > 0.35 + 0.1 * nEnemyCount
			and botMP < 0.99 - 0.1 * nEnemyCount
			and ( nEnemyCount <= 2 or botHP > botMP * 2.5 )
		then
			bot:ActionQueue_UseAbility( sr )
			return
		end
	end

end


function J.SetQueuePtToINT( bot, bSoulRingUsed )

	bot:Action_ClearActions( true )

	if bSoulRingUsed then J.SetQueueUseSoulRing( bot ) end

	if not J.IsPTReady( bot, ATTRIBUTE_INTELLECT )
	then
		J.SetQueueSwitchPtToINT( bot )
	end

end


function J.IsPTReady( bot, status )

	if not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsChanneling()
		or bot:IsInvisible()
		or bot:GetHealth() / bot:GetMaxHealth() < 0.2
	then
		return true
	end

	if status == ATTRIBUTE_INTELLECT
	then
		status = ATTRIBUTE_AGILITY
	elseif status == ATTRIBUTE_AGILITY
		then
			status = ATTRIBUTE_INTELLECT
	end

	local pt = J.IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() ~= status
		then
			return false
		end
	end

	return true

end


function J.ShouldSwitchPTStat( bot, pt )

	local ptStatus = pt:GetPowerTreadsStat()
	local botAttribute = bot:GetPrimaryAttribute()
	
	
	if ptStatus == ATTRIBUTE_INTELLECT
	then
		ptStatus = ATTRIBUTE_AGILITY
	elseif ptStatus == ATTRIBUTE_AGILITY
		then
			ptStatus = ATTRIBUTE_INTELLECT
	end
	
	if botAttribute ~= ATTRIBUTE_INTELLECT
		and botAttribute ~= ATTRIBUTE_STRENGTH
		and botAttribute ~= ATTRIBUTE_AGILITY
	then
		return ptStatus ~= ATTRIBUTE_STRENGTH
	end

	return botAttribute ~= ptStatus

end


function J.IsOtherAllysTarget( unit )

	local bot = GetBot()
	local hAllyList = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE )

	if #hAllyList <= 1 then return false end

	for _, ally in pairs( hAllyList )
	do
		if J.IsValid( ally )
			and ally ~= bot
			and not ally:IsIllusion()
			and ( J.GetProperTarget( ally ) == unit
					or ( not ally:IsBot() and ally:IsFacingLocation( unit:GetLocation(), 20 ) ) )
		then
			return true
		end
	end

	return false

end


function J.IsAllysTarget( unit )

	local bot = GetBot()
	local hAllyList = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE )

	for _, ally in pairs( hAllyList )
	do
		if J.IsValid( ally )
			and not ally:IsIllusion()
			and ( J.GetProperTarget( ally ) == unit
					or ( not ally:IsBot() and ally:IsFacingLocation( unit:GetLocation(), 12 ) ) )
		then
			return true
		end
	end

	return false

end


function J.IsKeyWordUnit( keyWord, uUnit )

	if string.find( uUnit:GetUnitName(), keyWord ) ~= nil
	then
		return true
	end

	return false
end


function J.IsHumanPlayer( nUnit )

	return not nUnit:IsBot() -- or IsPlayerBot( nUnit:GetPlayerID() )

end


function J.IsValid( nTarget )

	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and not nTarget:IsBuilding()

end


function J.IsValidHero( nTarget )

	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and nTarget:IsHero()
end


function J.IsValidBuilding( nTarget )

	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and nTarget:IsBuilding()

end


function J.IsRoshan( nTarget )

	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and string.find( nTarget:GetUnitName(), "roshan" ) ~= nil

end


function J.IsMoving( bot )

	if not bot:IsAlive() then return false end

	local vLocation = bot:GetExtrapolatedLocation( 0.6 )
	if GetUnitToLocationDistance( bot, vLocation ) > bot:GetCurrentMovementSpeed() * 0.45
	then
		return true
	end

	return false

end


function J.IsRunning( bot )

	if not bot:IsAlive() then return false end

	return bot:GetAnimActivity() == ACTIVITY_RUN

end


function J.IsAttacking( bot )

	local nAnimActivity = bot:GetAnimActivity()

	if nAnimActivity ~= ACTIVITY_ATTACK
		and nAnimActivity ~= ACTIVITY_ATTACK2
	then
		return false
	end

	if bot:GetAttackPoint() > bot:GetAnimCycle() * 0.99
	then
		return true
	end

	return false
end


function J.IsChasingTarget( bot, nTarget )

	if J.IsRunning( bot )
		and J.IsRunning( nTarget )
		and bot:IsFacingLocation( nTarget:GetLocation(), 20 )
		and not nTarget:IsFacingLocation( bot:GetLocation(), 150 )
	then
		return true
	end

	return false

end


function J.IsRealInvisible( bot )

	local enemyTowerList = bot:GetNearbyTowers( 880, true )

	if bot:IsInvisible()
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
		and not bot:HasModifier( 'modifier_bloodseeker_thirst_vision' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_sniper_assassinate' )
		and not bot:HasModifier( 'modifier_bounty_hunter_track' )
		and not bot:HasModifier( 'modifier_faceless_void_chronosphere_freeze' )
		and #enemyTowerList == 0
	then
		return true
	end


	return false

end


function J.GetModifierTime( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			return bot:GetModifierRemainingDuration( i )
		end
	end

	return 0

end


function J.GetModifierCount( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			return bot:GetModifierStackCount( i )
		end
	end

	return 0

end




function J.GetRemainStunTime( bot )

	if not bot:HasModifier( "modifier_stunned" ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == "modifier_stunned"
		then
			return bot:GetModifierRemainingDuration( i )
		end
	end

	return 0

end


function J.IsTeamActivityCount( bot, nCount )

	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if J.GetAllyCount( member, 1600 ) >= nCount
			then
				return true
			end
		end
	end

	return false

end


function J.GetSpecialModeAllies( bot, nDistance, nMode )

	local allyList = {}
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if member:GetActiveMode() == nMode
				and GetUnitToUnitDistance( member, bot ) <= nDistance
			then
				table.insert( allyList, member )
			end
		end
	end

	return allyList

end


function J.GetSpecialModeAlliesCount( nMode )

	local allyList = J.GetSpecialModeAllies( GetBot(), 99999, nMode )

	return #allyList

end


function J.GetTeamFightLocation( bot )

	local targetLocation = nil
	local numPlayer = GetTeamPlayers( GetTeam() )

	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and J.IsInTeamFight( member, 1500 )
			and J.GetEnemyCount( member, 1400 ) >= 2
		then
			local allyList = J.GetSpecialModeAllies( member, 1400, BOT_MODE_ATTACK )
			targetLocation = J.GetCenterOfUnits( allyList )
			break
		end
	end

	return targetLocation

end


function J.GetTeamFightAlliesCount( bot )

	local numPlayer = GetTeamPlayers( GetTeam() )
	local nCount = 0
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and J.IsInTeamFight( member, 1200 )
			and J.GetEnemyCount( member, 1400 ) >= 2
		then
			nCount = J.GetSpecialModeAlliesCount( BOT_MODE_ATTACK )
			break
		end
	end

	return nCount

end


function J.GetCenterOfUnits( nUnits )

	if #nUnits == 0
	then
		return Vector( 0.0, 0.0 )
	end

	local sum = Vector( 0.0, 0.0 )
	local num = 0

	for _, unit in pairs( nUnits )
	do
		if unit ~= nil
			and unit:IsAlive()
		then
			sum = sum + unit:GetLocation()
			num = num + 1
		end
	end

	if num == 0 then return Vector( 0.0, 0.0 ) end

	return sum / num

end


function J.GetMostFarmLaneDesire()

	local nTopDesire = GetFarmLaneDesire( LANE_TOP )
	local nMidDesire = GetFarmLaneDesire( LANE_MID )
	local nBotDesire = GetFarmLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end


function J.GetMostDefendLaneDesire()

	local nTopDesire = GetDefendLaneDesire( LANE_TOP )
	local nMidDesire = GetDefendLaneDesire( LANE_MID )
	local nBotDesire = GetDefendLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end


function J.GetMostPushLaneDesire()

	local nTopDesire = GetPushLaneDesire( LANE_TOP )
	local nMidDesire = GetPushLaneDesire( LANE_MID )
	local nBotDesire = GetPushLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end


function J.GetNearestLaneFrontLocation( nUnitLoc, bEnemy, fDeltaFromFront )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	local nTopLoc = GetLaneFrontLocation( nTeam, LANE_TOP, fDeltaFromFront )
	local nMidLoc = GetLaneFrontLocation( nTeam, LANE_MID, fDeltaFromFront )
	local nBotLoc = GetLaneFrontLocation( nTeam, LANE_BOT, fDeltaFromFront )

	local nTopDist = J.GetLocationToLocationDistance( nUnitLoc, nTopLoc )
	local nMidDist = J.GetLocationToLocationDistance( nUnitLoc, nMidLoc )
	local nBotDist = J.GetLocationToLocationDistance( nUnitLoc, nBotLoc )

	if nTopDist < nMidDist and nTopDist < nBotDist
	then
		return nTopLoc
	end

	if nBotDist < nMidDist and nBotDist < nTopDist
	then
		return nBotLoc
	end

	return nMidLoc

end


function J.GetAttackableWeakestUnit( bot, nRadius, bHero, bEnemy )

	local unitList = {}
	local weakest = nil
	local weakestHP = 10000

	if bHero
	then
		unitList = bot:GetNearbyHeroes( nRadius, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	end

	for _, unit in pairs( unitList )
	do
		if J.IsValid( unit )
			and unit:GetHealth() < weakestHP
			and not unit:IsAttackImmune()
			and not unit:IsInvulnerable()
			and not J.HasForbiddenModifier( unit )
			and not J.IsSuspiciousIllusion( unit )
			--and not J.IsAllyCanKill( unit )
		then
			weakest = unit
			weakestHP = unit:GetHealth()
		end
	end

	return weakest

end


function J.CanBeAttacked( unit )
	return  unit ~= nil
			and not J.HasForbiddenModifier( unit )
			and unit:IsAlive()
			and unit:CanBeSeen()
			and not unit:IsNull()
			and not unit:IsAttackImmune()
			and not unit:IsInvulnerable()
			and not unit:HasModifier("modifier_fountain_glyph")
			and (unit:GetTeam() == GetTeam() 
					or not unit:HasModifier("modifier_crystal_maiden_frostbite") )
			and (unit:GetTeam() ~= GetTeam() 
			     or ( unit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior" 
					  and unit:GetHealth()/unit:GetMaxHealth() < 0.5 ) )
end


function J.GetHP( bot )

	return bot:GetHealth() / bot:GetMaxHealth()

end


function J.GetMP( bot )

	return bot:GetMana() / bot:GetMaxMana()

end


function J.GetAllyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local nRealAllyList = {}
	local nCandidate = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE )
	if #nCandidate <= 1 then return nCandidate end

	for _, ally in pairs( nCandidate )
	do
		if ally ~= nil and ally:IsAlive()
			and not ally:IsIllusion()
		then
			table.insert( nRealAllyList, ally )
		end
	end

	return nRealAllyList

end


function J.GetAllyCount( bot, nRadius )

	local nRealAllyList = J.GetAllyList( bot, nRadius )

	return #nRealAllyList

end


function J.GetAroundEnemyHeroList( nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	return GetBot():GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )

end


function J.GetAroundCreepList( nRadius, bEnemy, bNeutral, bLaneCreep )

	local bot = GetBot()
	if nRadius > 1600 then nRadius = 1600 end
	local creepList = {}

	if bNeutral
	then
		creepList = bot:GetNearbyNeutralCreeps( nRadius )
	elseif bLaneCreep
	then
		creepList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	else
		creepList = bot:GetNearbyCreeps( nRadius, bEnemy )
	end

	return creepList

end


function J.GetAroundBuildingList( nRadius, bEnemy, bTower, bShrine, bFiller, bBarrack, bAcient )

	local bot = GetBot()
	if nRadius > 1600 then nRadius = 1600 end
	local buildingList = {}

	-- GetNearbyBarracks( nRadius, bEnemies )
	-- GetNearbyTowers( nRadius, bEnemies )
	-- GetNearbyShrines( nRadius, bEnemies )
	-- GetNearbyFillers( nRadius, bEnemies )
	-- GetAncient( nTeam )

	return buildingList

end


function J.GetEnemyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nRealEnemyList = {}
	local nCandidate = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	if nCandidate[1] == nil then return nCandidate end

	for _, enemy in pairs( nCandidate )
	do
		if enemy ~= nil and enemy:IsAlive()
			and not J.IsSuspiciousIllusion( enemy )
		then
			table.insert( nRealEnemyList, enemy )
		end
	end

	return nRealEnemyList

end


function J.GetEnemyCount( bot, nRadius )

	local nRealEnemyList = J.GetEnemyList( bot, nRadius )

	return #nRealEnemyList

end

function J.ConsiderTarget()

	local bot = GetBot()

	if not J.IsRunning( bot )
		or bot:HasModifier( "modifier_item_hurricane_pike_range" )
	then return end

	local npcTarget = J.GetProperTarget( bot )
	if not J.IsValidHero( npcTarget ) then return end

	local nAttackRange = bot:GetAttackRange() + 69
	if nAttackRange > 1600 then nAttackRange = 1600 end
	if nAttackRange < 300 then nAttackRange = 350 end

	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange, true, true )

	if J.IsValidHero( nInAttackRangeWeakestEnemyHero )
		and ( GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange or J.HasForbiddenModifier( npcTarget ) )
	then
		bot:SetTarget( nInAttackRangeWeakestEnemyHero )
		return
	end

end


function J.IsHaveAegis( bot )

	return bot:FindItemSlot( "item_aegis" ) >= 0

end

function J.DoesTeamHaveAegis( units )
	for _, allies in pairs(units)
	do
		if allies:FindItemSlot("item_aegis") >= 0
		then
			return true
		end
	end

	return false
end


function J.IsLocHaveTower( nRadius, bEnemy, nLoc )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	if ( not bEnemy and J.GetLocationToLocationDistance( nLoc, J.GetTeamFountain() ) < 2500 )
		or ( bEnemy and J.GetLocationToLocationDistance( nLoc, J.GetEnemyFountain() ) < 2500 )
	then
		return true
	end

	for i = 0, 10
	do
		local tower = GetTower( nTeam, i )
		if tower ~= nil and GetUnitToLocationDistance( tower, nLoc ) <= nRadius
		then
			 return true
		end
	end

	return false

end


function J.GetNearbyLocationToTp( nLoc )

	local nTeam = GetTeam()
	local nFountain = J.GetTeamFountain()

	if J.GetLocationToLocationDistance( nLoc, nFountain ) <= 2500
	then
		return nLoc
	end

	local targetTower = nil
	local minDist = 99999
	for i=0, 10, 1 do
		local tower = GetTower( nTeam, i )
		if tower ~= nil
			and GetUnitToLocationDistance( tower, nLoc ) < minDist
		then
			 targetTower = tower
			 minDist = GetUnitToLocationDistance( tower, nLoc )
		end
	end

	local watchTowerList = J.Site.GetAllWatchTower()
	for _, watchTower in pairs( watchTowerList )
	do
		if watchTower ~= nil
			and watchTower:GetTeam() == nTeam
			and GetUnitToLocationDistance( watchTower, nLoc ) < minDist - 1300
			and ( not J.IsEnemyHeroAroundLocation( watchTower:GetLocation(), 600 )
					or J.IsAllyHeroAroundLocation( watchTower:GetLocation(), 600 ) )
		then
			 targetTower = watchTower
			 minDist = GetUnitToLocationDistance( watchTower, nLoc ) + 1300
		end
	end

	if targetTower ~= nil
	then
		return J.GetLocationTowardDistanceLocation( targetTower, nLoc, 575 )
	end

	return nFountain

end


function J.IsEnemyFacingUnit( bot, nRadius, nDegrees )

	local nLoc = bot:GetLocation()

	if nRadius > 1600 then nRadius = 1600 end
	local nEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValid( enemy )
			and enemy:IsFacingLocation( nLoc, nDegrees )
		then
			return true
		end
	end

	return false

end


function J.IsAllyFacingUnit( bot, nRadius, nDegrees )

	local nLoc = bot:GetLocation()
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member ~= bot
			and GetUnitToUnitDistance( member, bot ) <= nRadius
			and member:IsFacingLocation( nLoc, nDegrees )
		then
			return true
		end
	end

	return false

end


function J.IsEnemyTargetUnit( nUnit, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nEnemyHeroes = GetBot():GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValid( enemy )
			and J.GetProperTarget( enemy ) == nUnit
		then
			return true
		end
	end

	return false

end


function J.IsCastingUltimateAbility( bot )

	if bot:IsCastingAbility() or bot:IsUsingAbility()
	then
		local nAbility = bot:GetCurrentActiveAbility()
		if nAbility ~= nil
			and nAbility:IsUltimate()
		then
			return true
		end
	end

	return false

end


function J.IsInAllyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hAllyAcient ) + 768 < GetUnitToUnitDistance( bot, hEnemyAcient )
	then
		return true
	end
	
	return false

end


function J.IsInEnemyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hEnemyAcient ) + 1280 < GetUnitToUnitDistance( bot, hAllyAcient )
	then
		return true
	end
	
	return false

end


function J.IsAllyHeroAroundLocation( vLoc, nRadius )

	for i = 1, 5
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and GetUnitToLocationDistance( npcAlly, vLoc ) <= nRadius
		then
			return true
		end
	end

	return false

end


function J.IsEnemyHeroAroundLocation( vLoc, nRadius )

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id ) then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
					and J.GetLocationToLocationDistance( vLoc, dInfo.location ) <= nRadius
					and dInfo.time_since_seen < 2.0
				then
					return true
				end
			end
		end
	end

	return false

end


function J.GetNumOfAliveHeroes( bEnemy )

	local count = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		if IsHeroAlive( id )
		then
			count = count + 1
		end
	end

	return count

end


function J.GetAverageLevel( bEnemy )

	local count = 0
	local sum = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		sum = sum + GetHeroLevel( id )
		count = count + 1
	end

	return sum / count

end


function J.GetNumOfTeamTotalKills( bEnemy )

	local count = 0
	local nTeam = GetOpposingTeam()
	if bEnemy then nTeam = GetTeam() end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		count = count + GetHeroDeaths( id )
	end

	return count

end


function J.ConsiderForMkbDisassembleMask( bot )

	if bot.maskDismantleDone == nil then bot.maskDismantleDone = false end
	if bot.staffUnlockDone == nil then bot.staffUnlockDone = false end
	if bot.lifestealUnlockDone == nil then bot.lifestealUnlockDone = false end
	if bot.dismantleCheckTime == nil then bot.dismantleCheckTime = 600 end

	if bot.staffUnlockDone then return end

	if bot.dismantleCheckTime < DotaTime() + 1.0
	then
		bot.dismantleCheckTime = DotaTime()

		local mask	 = bot:FindItemSlot( "item_mask_of_madness" )
		local claymore = bot:FindItemSlot( "item_claymore" )
		local reaver	= bot:FindItemSlot( "item_reaver" )

		if not bot.maskDismantleDone
			and ( bot:GetItemInSlot( 6 ) == nil or bot:GetItemInSlot( 7 ) == nil or bot:GetItemInSlot( 8 ) == nil )
		then

			if mask >= 0 and mask <= 8
				and ( ( reaver >= 0 and reaver <= 8 ) or ( claymore >= 0 and claymore <= 8 ) )
				and ( bot:GetGold() >= 1400 or bot:GetStashValue() >= 1400 or bot:GetCourierValue() >= 1400 )
			then
				if bDebugMode then print( bot:GetUnitName().." mask Dismantle1" ) end
				bot.maskDismantleDone = true
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot( mask ) )
				return
			end

			if mask >= 0 and mask <= 8
				and claymore >= 0 and reaver >= 0
			then
				if bDebugMode then print( bot:GetUnitName().." mask Dismantle2" ) end
				bot.maskDismantleDone = true
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot( mask ) )
				return
			end
		end

		if not bot.maskDismantleDone then return end

		local lifesteal = bot:FindItemSlot( "item_lifesteal" )
		local staff = bot:FindItemSlot( "item_quarterstaff" )

		if lifesteal >= 0
			and not bot.lifestealUnlockDone
		then
			if bDebugMode then print( bot:GetUnitName().." lifestealUnlockDone" ) end
			bot.lifestealUnlockDone = true
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot( lifesteal ), false )
			return
		end

		local satanic = bot:FindItemSlot( "item_satanic" )

		if satanic >= 0 and staff >= 0 and not bot.staffUnlockDone
		then
			if bDebugMode then print( bot:GetUnitName().." staffUnlockDone" ) end
			bot.staffUnlockDone = true
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot( staff ), false )
			return
		end

	end
end


local LastActionTime = {}
function J.HasNotActionLast( nCD, nNumber )

	if LastActionTime[nNumber] == nil then LastActionTime[nNumber] = -90 end

	if DotaTime() > LastActionTime[nNumber] + nCD
	then
		LastActionTime[nNumber] = DotaTime()
		return true
	end

	return false

end


function J.GetCastDelay( bot, unit, nPointTime, nProjectSpeed )

	local nDist = GetUnitToUnitDistance( bot, unit )

	local nDistTime = 0
	if nProjectSpeed ~= 0 then nDistTime = nDist / nProjectSpeed end

	return nPointTime + nDistTime

end


function J.CanBreakTeleport( bot, unit, nPointTime, nProjectSpeed )

	if unit:HasModifier( "modifier_teleporting" )
	then
		return J.GetCastPoint( bot, unit, nPointTime, nProjectSpeed ) < J.GetModifierTime( unit, "modifier_teleporting" )
	end

	return true

end

-- NEWLY ADDED FUNCTIONS FOR NEW HEROES AND BEHAVIOUR

function J.CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
end

function J.CanSpamSpell(bot, manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(3*30) );
end

local maxAddedRange = 200
local maxGetRange = 1600
function J.GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + maxAddedRange;
	elseif abilityCR + maxAddedRange <= maxGetRange then
		return abilityCR + maxAddedRange;
	elseif abilityCR > maxGetRange then
		return maxGetRange;
	else
		return abilityCR;
	end
end

function J.IsValidTarget(npcTarget)
	return npcTarget ~= nil and npcTarget:IsAlive() and npcTarget:IsHero(); 
end

function J.GetLowestHPUnit(tUnits, bIgnoreImmune)
	local lowestHP   = 100000;
	local lowestUnit = nil; 
	for _,unit in pairs(tUnits)
	do
		local hp = unit:GetHealth()
		if hp < lowestHP and ( bIgnoreImmune or ( not bNotMagicImmune and not unit:IsMagicImmune() ) ) then
			lowestHP   = hp;
			lowestUnit = unit;
		end
	end
	return lowestUnit;
end

local maxLevel = 30
function J.AllowedToSpam(bot, manaCost)
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( 1.0 - bot:GetLevel()/(2*maxLevel) );
end

function J.CountVulnerableUnit(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() then
				count = count + 1;
			end
		end
	end
	return count;
end

function J.GetProperLocation(hUnit, nDelay)
	if hUnit:GetMovementDirectionStability() >= 0 then
		return hUnit:GetExtrapolatedLocation(nDelay);
	end
	return hUnit:GetLocation();
end

function J.CountNotStunnedUnits(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() and not J.IsDisabled(unit) then
				count = count + 1;
			end
		end
	end
	return count;
end

function J.CountInvUnits(pierceImmune, units)
	local nUnits = 0;
	if units ~= nil then
		for _,u in pairs(units) do
			if ( pierceImmune and J.CanCastOnMagicImmune(u) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) )  then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end

function J.GetMostHPPercent(listUnits, magicImmune)
	local mostPHP = 0;
	local mostPHPUnit = nil;
	for _,unit in pairs(listUnits)
	do
		local uPHP = unit:GetHealth() / unit:GetMaxHealth()
		if ( ( magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit) ) ) 
			and uPHP > mostPHP  
		then
			mostPHPUnit = unit;
			mostPHP = uPHP;
		end
	end
	return mostPHPUnit;
end

function J.HasAghanimsShard(bot)
	return bot:HasModifier("modifier_item_aghanims_shard")
end

function J.GetCanBeKilledUnit(units, nDamage, nDmgType, magicImmune)
	local target = nil
	for _,unit in pairs(units)
	do
		if ((magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit)))
			   and J.CanKillTarget(unit, nDamage, nDmgType)
		then
			target = unit
		end
	end
	return target
end

function J.GetClosestUnit(units)
	local target = nil;
	if units ~= nil and #units >= 1 then
		return units[1];
	end
	return target;
end

function J.IsModeTurbo()
	for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if  u ~= nil
		and u:GetUnitName() == 'npc_dota_courier'
		then
			if u:GetCurrentMovementSpeed() == 1100
			then
				return true
			end
		end
	end

    return false
end

function J.IsCore(bot)

	local heroID = GetTeamPlayers(GetTeam())

	if GetSelectedHeroName(heroID[1]) == bot:GetUnitName()
	or GetSelectedHeroName(heroID[2]) == bot:GetUnitName()
	or GetSelectedHeroName(heroID[3]) == bot:GetUnitName()
	then
		return true
	end

	return false
end

function J.GetCoresTotalNetworth()
	local totalNetworth = GetTeamMember(1):GetNetWorth()
				  	    + GetTeamMember(2):GetNetWorth()
				  		+ GetTeamMember(3):GetNetWorth()
	return totalNetworth
end

function J.GetPosition(bot)
	local heroID = GetTeamPlayers(GetTeam())
	local pos

	if GetSelectedHeroName(heroID[1]) == bot:GetUnitName() then
		pos = 2
	elseif GetSelectedHeroName(heroID[2]) == bot:GetUnitName() then
		pos = 3
	elseif GetSelectedHeroName(heroID[3]) == bot:GetUnitName() then
		pos = 1
	elseif GetSelectedHeroName(heroID[4]) == bot:GetUnitName() then
		pos = 5
	elseif GetSelectedHeroName(heroID[5]) == bot:GetUnitName() then
		pos = 4
	end

	return pos
end

function J.WeAreStronger(bot, radius)

    local mates = bot:GetNearbyHeroes(radius, false, BOT_MODE_NONE);
    local enemies = bot:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
  
    local ourPower = 0;
    local enemyPower = 0;
  
    for _, h in pairs(mates) do
        ourPower = ourPower + h:GetOffensivePower();
    end
  
    for _, h in pairs(enemies) do
        enemyPower = enemyPower + h:GetRawOffensivePower();
    end
  
    return #mates > #enemies and ourPower > enemyPower;
end

function J.RandomForwardVector(length)

    local offset = RandomVector(length)

    if GetTeam() == TEAM_RADIANT then
        offset.x = offset.x > 0 and offset.x or -offset.x
        offset.y = offset.y > 0 and offset.y or -offset.y
    end

    if GetTeam() == TEAM_DIRE then
        offset.x = offset.x < 0 and offset.x or -offset.x
        offset.y = offset.y < 0 and offset.y or -offset.y
    end

    return offset
end

function J.GetUnitWithMinDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local minUnit = cUnits;
	local minVal = fMinDist;
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and J.CanCastOnNonMagicImmune(hUnits[i]) 
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc);
			if dist < minVal then
				minVal = dist;
				minUnit = hUnits[i];	
			end
		end	
	end
	
	return minVal, minUnit;
end

function J.GetUnitWithMaxDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local maxUnit = cUnits
	local maxVal = fMinDist
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and J.CanCastOnNonMagicImmune(hUnits[i])
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc)
			if dist > maxVal then
				maxVal = dist
				maxUnit = hUnits[i]
			end
		end	
	end
	
	return maxVal, maxUnit
end

function J.GetFurthestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = hUnit:GetNearbyHeroes(nRange, false, BOT_MODE_NONE)
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE)
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false)
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true)

	local botDist = GetUnitToLocationDistance(hUnit, vLoc)
	local furthestUnit = hUnit
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, aHeroes, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, eHeroes, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, aCreeps, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, eCreeps, furthestUnit, botDist, vLoc)

	if furthestUnit ~= hUnit then
		return furthestUnit
	end

	return nil

end

function J.GetClosestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = hUnit:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local closestUnit = hUnit;
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= hUnit then
		return closestUnit;
	end
	
	return nil;
	
end

function J.GetClosestUnitToLocationFrommAll2(hUnit, nRange, vLoc)
	local aHeroes = hUnit:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = 10000;
	local closestUnit = nil;
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= nil then
		return closestUnit;
	end
	
	return nil;
	
end

function J.CheckTimeOfDay()
    local cycle = 600
    local time = DotaTime() % cycle
    local night = 300

    if time < night then return "day", time
    else return "night", time
    end
end

function J.GetArmorReducers(hero)
	local reducedArmor = 0

	-- Items (Passives for now)
	if J.HasItem(hero, "item_desolator")
	and (hero:GetItemInSlot (6) ~= "item_desolator" or hero:GetItemInSlot(7) ~= "item_desolator" or hero:GetItemInSlot(8) ~= "item_desolator")
	then
		reducedArmor = reducedArmor + 6
	end

	if J.HasItem(hero, "item_assault")
	and (hero:GetItemInSlot (6) ~= "item_assault" or hero:GetItemInSlot(7) ~= "item_assault" or hero:GetItemInSlot(8) ~= "item_assault")
	then
		reducedArmor = reducedArmor + 5
	end

	if J.HasItem(hero, "item_blight_stone")
	and (hero:GetItemInSlot (6) ~= "item_blight_stone" or hero:GetItemInSlot(7) ~= "item_blight_stone" or hero:GetItemInSlot(8) ~= "item_blight_stone")
	then
		reducedArmor = reducedArmor + 2
	end

	-- Abilities (Passives for now)
	local NevermoreDarkLord = hero:GetAbilityByName("nevermore_dark_lord")
	if hero:GetUnitName() == "npc_dota_hero_nevermore"
	and NevermoreDarkLord ~= nil
	and NevermoreDarkLord:GetLevel() > 0
	then
		reducedArmor = reducedArmor + NevermoreDarkLord:GetSpecialValueInt("presence_armor_reduction")
	end

	local NagaSirenRiptide = hero:GetAbilityByName("naga_siren_rip_tide")
	if hero:GetUnitName() == "npc_dota_hero_naga_siren"
	and NagaSirenRiptide ~= nil
	and NagaSirenRiptide:GetLevel() > 0 then
		reducedArmor = reducedArmor + NagaSirenRiptide:GetSpecialValueInt("armor_reduction")
	end

	return reducedArmor
end

local killTime = 0.0
function J.IsRoshanAlive()
	if GetRoshanKillTime() > killTime
    then
        killTime = GetRoshanKillTime()
    end

    if DotaTime() - GetRoshanKillTime() >= (J.IsModeTurbo() and (6 * 60) or (11 * 60))
    then
        return true
    end

    return false
end

function J.HasEnoughDPSForRoshan(heroes)
    local DPS = 0
    local DPSThreshold = 0
    local plannedTimeToKill = 60

    -- Roshan Stats
    local baseHealth = 6000
    local baseArmor = 30
    local armorPerInterval = 0.375
    local maxHealthBonusPerInterval = 130 * 2

    local roshanHealth = baseHealth + maxHealthBonusPerInterval * math.floor(DotaTime() / 60)

    for _, h in pairs(heroes) do
        local roshanArmor = baseArmor + armorPerInterval * math.floor(DotaTime() / 60) - J.GetArmorReducers(h)

        -- Only right click damage for now
        local attackDamage = h:GetAttackDamage()
        local attackSpeed = h:GetAttackSpeed()

        local dps = attackDamage * attackSpeed * (1 - roshanArmor / (roshanArmor + 20))
        DPS = DPS + dps
    end

    DPS =  DPS / #heroes

    DPSThreshold = roshanHealth / plannedTimeToKill
    return DPS >= DPSThreshold
end

function J.IsNotSelf(bot, ally)
	if bot:GetUnitName() ~= ally:GetUnitName()
	then
		return true
	end

	return false
end

function J.IsThereCoreNearby(nRadius)
    local nAllyHeroes = GetBot():GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)

    for _, ally in pairs(nAllyHeroes) do
        if J.IsCore(ally)
        then
            return true
        end
    end

    return false
end

function J.GetAliveAllyCoreCount()
	local count = 0
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if  J.IsValidHero(allyHero)
		and J.IsCore(allyHero)
		and not allyHero:IsIllusion()
		then
			count = count + 1
		end
	end

	return count
end

function J.GetStrongestUnit(nRange, hUnit, bEnemy, bMagicImune, fTime)
	local units = hUnit:GetNearbyHeroes(nRange, bEnemy, BOT_MODE_NONE)
	local strongest = nil
	local maxPower = 0

	for i = 1, #units do
		if J.IsValidTarget(units[i])
		and ((bMagicImune == true and J.CanCastOnMagicImmune(units[i]) == true) or (bMagicImune == false and J.CanCastOnNonMagicImmune(units[i]) == true))
		then
			local power = units[i]:GetEstimatedDamageToTarget(true, hUnit, fTime, DAMAGE_TYPE_ALL)

			if power > maxPower
			then
				maxPower = power
				strongest = units[i]
			end
		end
	end
	return strongest
end

function J.GetDistance(s, t)
    return math.sqrt((s[1] - t[1]) * (s[1]-t[1]) + (s[2] - t[2]) * (s[2] - t[2]))
end

function J.IsHeroBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if  tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if  tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsEnemyBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if  tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyHeroes = hSource:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if allyHero ~= hTarget and allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if  tResult ~= nil and tResult.within == true and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyHeroes = hSource:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hTarget and enemyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if  tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsCreepBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nAllyLaneCreeps)
    do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if  tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nEnemyLaneCreeps)
    do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())

		if  tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	return false
end

function J.IsNonSiegeCreepBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nAllyLaneCreeps)
    do
		if  J.IsValid(creep)
		and not J.IsKeyWordUnit('siege', creep)
		then
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nEnemyLaneCreeps)
    do
		if  J.IsValid(creep)
		and not J.IsKeyWordUnit('siege', creep)
		then
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end

function J.IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	if not J.IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	then
		return J.IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	end

	return false
end

function J.IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyLaneCreeps = hTarget:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nAllyLaneCreeps)
	do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	local nEnemyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nEnemyLaneCreeps)
	do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	return false
end

function J.IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nAllyLaneCreeps)
	do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance < nRadius then
			return true
		end
	end

	local nEnemyLaneCreeps = hTarget:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nEnemyLaneCreeps)
	do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance < nRadius then
			return true
		end
	end

	return false
end

function J.IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyHeroes = hSource:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then return true end
		end
	end

	local nEnemyHeroes = hTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then return true end
		end
	end

	return false
end

local sIgnoreAbilityIndex = {
	["antimage_blink"] = true,
	["arc_warden_magnetic_field"] = true,
	["arc_warden_spark_wraith"] = true,
	["arc_warden_tempest_double"] = true,
	["chaos_knight_phantasm"] = true,
	["clinkz_burning_army"] = true,
	["death_prophet_exorcism"] = true,
	["dragon_knight_elder_dragon_form"] = true,
	["juggernaut_healing_ward"] = true,
	["necrolyte_death_pulse"] = true,
	["necrolyte_sadist"] = true,
	["omniknight_guardian_angel"] = true,
	["phantom_assassin_blur"] = true,
	["pugna_nether_ward"] = true,
	["skeleton_king_mortal_strike"] = true,
	["sven_warcry"] = true,
	["sven_gods_strength"] = true,
	["templar_assassin_refraction"] = true,
	["templar_assassin_psionic_trap"] = true,
	["windrunner_windrun"] = true,
	["witch_doctor_voodoo_restoration"] = true,
}
function J.DidEnemyCastAbility()
	local bot = GetBot()
	local nEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nEnemyHeroes)
	do
		if  npcEnemy ~= nil and npcEnemy:IsAlive()
		and npcEnemy:IsFacingLocation(bot:GetLocation(), 30)
		and (npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility())
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				local nAbilityBehavior = nAbility:GetBehavior()
				local sAbilityName = nAbility:GetName()

				if nAbilityBehavior ~= ABILITY_BEHAVIOR_UNIT_TARGET
				and (npcEnemy:IsBot() or npcEnemy:GetLevel() >= 5)
				and not sIgnoreAbilityIndex[sAbilityName]
				then
					return true
				end

				if  nAbilityBehavior == ABILITY_BEHAVIOR_UNIT_TARGET
				and npcEnemy:GetLevel() >= 6
				and not npcEnemy:IsBot()
				and not J.IsAllyUnitSpell(sAbilityName)
				and (not J.IsProjectileUnitSpell(sAbilityName) or J.IsInRange(bot, npcEnemy, 400))
				then
					return true
				end
			end
		end
	end

	return false
end

function J.GetWeakestUnit(nEnemyUnits)
	local nWeakestUnit = nil
	local nWeakestUnitLowestHealth = 10000

	for _, unit in pairs(nEnemyUnits)
	do
		if 	unit:IsAlive()
        and J.CanCastOnNonMagicImmune(unit)
        and J.CanCastOnTargetAdvanced(unit)
		then
			if unit:GetHealth() < nWeakestUnitLowestHealth
			then
				nWeakestUnitLowestHealth = unit:GetHealth()
				nWeakestUnit = unit
			end
		end
	end

	return nWeakestUnit, nWeakestUnitLowestHealth
end

function J.AdjustLocationWithOffset(vLoc, offset, target)
	local targetLoc = vLoc

	local facingDir = target:GetFacing()
	local offsetX = offset * math.cos(facingDir)
	local offsetY = offset * math.sin(facingDir)

	targetLoc = targetLoc + Vector(offsetX, offsetY)

	return targetLoc
end

function J.IsInLaningPhase()
	return (J.IsModeTurbo() and DotaTime() < 8 * 60) or DotaTime() < 12 * 60
end

function J.IsTormentor(nTarget)
	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and string.find(nTarget:GetUnitName(), 'miniboss') ~= nil
end

function J.IsDoingTormentor(bot)
	return bot:GetActiveMode() == BOT_MODE_SIDE_SHOP
end

function J.IsLocationInChrono(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			return true
		end
	end

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if  J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and GetUnitToLocationDistance(allyHero, loc) < 300
		and (allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze'))
		then
			return true
		end
	end

	return false
end

function J.IsLocationInBlackHole(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and (enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			or enemyHero:HasModifier('modifier_enigma_black_hole_pull_scepter'))
		then
			return true
		end
	end

	return false
end

function J.IsLocationInArena(loc, radius)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if  J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < radius
		and (enemyHero:HasModifier('modifier_mars_arena_of_blood_leash')
			or enemyHero:HasModifier('modifier_mars_arena_of_blood_animation'))
		then
			return true
		end
	end

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if  J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and GetUnitToLocationDistance(allyHero, loc) < radius
		and (allyHero:HasModifier('modifier_mars_arena_of_blood_animation'))
		then
			return true
		end
	end

	return false
end

function J.GetMeepos()
	local Meepos = {}

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if  J.IsValidHero(allyHero)
		and allyHero:GetUnitName() == 'npc_dota_hero_meepo'
		and not J.IsSuspiciousIllusion(allyHero)
		then
			table.insert(Meepos, allyHero)
		end
	end

	return Meepos
end

function J.IsMeepoClone(hero)
	if  J.IsValidHero(hero)
	and hero:GetUnitName() == 'npc_dota_hero_meepo'
	then
		for i = 0, 5
		do
			local hItem = hero:GetItemInSlot(i)

			if  hItem ~= nil
			and not (hItem:GetName() == 'item_boots'
					or hItem:GetName() == 'item_tranquil_boots'
					or hItem:GetName() == 'item_arcane_boots'
					or hItem:GetName() == 'item_power_treads'
					or hItem:GetName() == 'item_phase_boots'
					or hItem:GetName() == 'item_travel_boots'
					or hItem:GetName() == 'item_boots_of_bearing'
					or hItem:GetName() == 'item_guardian_greaves'
					or hItem:GetName() == 'item_travel_boots_2'
				)  
			then
				return false
			end
		end

		return true
    end
end

function J.DoesSomeoneHaveModifier(nUnitList, modifierName)
	for _, unit in pairs(nUnitList)
	do
		if  J.IsValid(unit)
		and unit:HasModifier(modifierName)
		then
			return true
		end
	end

	return false
end

function J.IsHumanPlayerInTeam()
	for _, member in pairs(GetTeamPlayers(GetTeam()))
	do
		if not IsPlayerBot(member)
		then
			return true
		end
	end

	return false
end

function J.GetCreepsAroundAncient(team, enemy)
	local nCreepList = {}

	local list = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
	if enemy
	then
		list = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
	end

	for _, creep in pairs(list)
	do
		if  J.IsValid(creep)
		and GetUnitToUnitDistance(creep, GetAncient(team)) < 1600
		then
			table.insert(nCreepList, creep)
		end
	end

	return nCreepList
end

function J.GetCurrentRoshanLocation()
	local timeOfDay = J.CheckTimeOfDay()

	if timeOfDay == 'day'
	then
		return roshanRadiantLoc
	else
		return roshanDireLoc
	end
end

function J.GetTormentorLocation(team)
	if team == TEAM_RADIANT
	then
		return RadiantTormentorLoc
	else
		return DireTormentorLoc
	end
end

local AllyPIDs = nil
function J.IsClosestToDustLocation(bot, loc)
	if AllyPIDs == nil then AllyPIDs = GetTeamPlayers(GetTeam()) end

	local closest = nil
	local closestDist = 100000

	for _, id in pairs(AllyPIDs)
	do
		local member = GetTeamMember(id)

		if  J.IsValidHero(member)		
		and member:GetItemSlotType(member:FindItemSlot('item_dust')) == ITEM_SLOT_TYPE_MAIN
		and member:GetItemInSlot(member:FindItemSlot('item_dust')):IsFullyCastable()
		and not J.IsSuspiciousIllusion(member)
		then
			local dist = GetUnitToLocationDistance(member, loc)

			if dist < closestDist
			then
				closest = member
				closestDist = dist
			end
		end
	end

	if closest ~= nil
	then
		return closest == bot
	end
end

function J.GetXUnitsTowardsLocation2(iLoc, tLoc, nUnits)
    local dir = (tLoc - iLoc):Normalized()
    return iLoc + dir * nUnits
end

function J.IsUnitWillGoInvisible(unit)
	return unit:HasModifier('modifier_sandking_sand_storm')
		or unit:HasModifier('modifier_bounty_hunter_wind_walk')
		or unit:HasModifier('modifier_clinkz_wind_walk')
		or unit:HasModifier('modifier_weaver_shukuchi')
		or (unit:HasModifier('modifier_oracle_false_promise') and unit:HasModifier('modifier_oracle_false_promise_invis'))
		or (unit:HasModifier('modifier_windrunner_windrun') and unit:HasModifier('modifier_windrunner_windrun_invis'))
		or unit:HasModifier('modifier_item_invisibility_edge')
		or unit:HasModifier('modifier_item_invisibility_edge_windwalk')
		or unit:HasModifier('modifier_item_silver_edge')
		or unit:HasModifier('modifier_item_silver_edge_windwalk')
		or unit:HasModifier('modifier_item_glimmer_cape_fade')
		or unit:HasModifier('modifier_item_glimmer_cape')
		or unit:HasModifier('modifier_item_shadow_amulet')
		or unit:HasModifier('modifier_item_shadow_amulet_fade')
		or unit:HasModifier('modifier_item_trickster_cloak_invis')
end

function J.HasInvisCounterBuff(unit)
	if unit:HasModifier('modifier_item_dustofappearance')
	or unit:HasModifier('modifier_bounty_hunter_track')
	or unit:HasModifier('modifier_bloodseeker_thirst_vision')
	or unit:HasModifier('modifier_slardar_amplify_damage')
	or unit:HasModifier('modifier_sniper_assassinate')
	or unit:HasModifier( 'modifier_faceless_void_chronosphere_freeze' )
	then
		return true
	end

	return false
end

function J.GetUnderlordPortal()
	local portal = {}

	for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if u:GetUnitName() == 'npc_dota_unit_underlord_portal'
		then
			if  #portal == 1
			and portal[1] ~= u
			then
				table.insert(portal, u)
			end

			if #portal == 2
			then
				break
			end

			table.insert(portal, u)
		end
	end

	if #portal == 2
	then
		return portal
	end

	return nil
end

function J.GetTotalEstimatedDamageToTarget(nUnits, target)
	local dmg = 0

	for _, unit in pairs(nUnits)
	do
		if  J.IsValidHero(unit)
		and not J.IsSuspiciousIllusion(unit)
		then
			dmg = dmg + unit:GetEstimatedDamageToTarget(true, target, 5, DAMAGE_TYPE_ALL)
		end
	end

	return dmg
end

function J.GetAliveCoreCount(nEnemy)
	local team = GetTeam()
	local count = 0

	if nEnemy
	then
		team = GetOpposingTeam()
	end

	local heroID = GetTeamPlayers(team)
	if IsHeroAlive(heroID[1]) then count = count + 1 end
	if IsHeroAlive(heroID[2]) then count = count + 1 end
	if IsHeroAlive(heroID[3]) then count = count + 1 end

	return count
end

function J.GetEnemyCountInLane(lane)
	local count = 0
	for _, id in pairs( GetTeamPlayers( GetOpposingTeam()))
	do
		if IsHeroAlive(id)
		then
			local info = GetHeroLastSeenInfo(id)

			if info ~= nil
			then
				local dInfo = info[1]

				if  dInfo ~= nil
				and J.GetDistance(GetLaneFrontLocation(GetTeam(), lane, 0), dInfo.location) < 1600
				and dInfo.time_since_seen < 10
				then
					count = count + 1
				end
			end
		end
	end

	return count
end

function J.GetManaAfter(manaCost)
	local bot = GetBot()
	return (bot:GetMana() - manaCost) / bot:GetMaxMana()
end

function J.ConsolePrintActiveMode(bot)
	local mode = bot:GetActiveMode()

	if mode == BOT_MODE_NONE then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: NONE")
	elseif mode == BOT_MODE_LANING then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: LANING")
	elseif mode == BOT_MODE_ATTACK then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: ATTACK")
	elseif mode == BOT_MODE_ROAM then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: ROAM")
	elseif mode == BOT_MODE_RETREAT then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: RETREAT")
	elseif mode == BOT_MODE_SECRET_SHOP then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: SECRET SHOP")
	elseif mode == BOT_MODE_SIDE_SHOP then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: SIDE SHOP")
	elseif mode == BOT_MODE_PUSH_TOWER_TOP then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: PUSH TOWER TOP")
	elseif mode == BOT_MODE_PUSH_TOWER_MID then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: PUSH TOWER MID")
	elseif mode == BOT_MODE_PUSH_TOWER_BOT then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: PUSH TOWER BOT")
	elseif mode == BOT_MODE_DEFEND_TOWER_TOP then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: DEFEND TOWER TOP")
	elseif mode == BOT_MODE_DEFEND_TOWER_MID then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: DEFEND TOWER MID")
	elseif mode == BOT_MODE_DEFEND_TOWER_BOT then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: DEFEND TOWER BOT")
	elseif mode == BOT_MODE_ASSEMBLE then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: ASSEMBLE")
	elseif mode == BOT_MODE_TEAM_ROAM then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: TEAM ROAM")
	elseif mode == BOT_MODE_FARM then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: FARM")
	elseif mode == BOT_MODE_DEFEND_ALLY then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: DEFEND ALLY")
	elseif mode == BOT_MODE_EVASIVE_MANEUVERS then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: EVASIVE MANEUVERS")
	elseif mode == BOT_MODE_ROSHAN then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: ROSHAN")
	elseif mode == BOT_MODE_ITEM then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: ITEM")
	elseif mode == BOT_MODE_WARD then
		print(string.gsub( bot:GetUnitName(), "npc_dota_", "" ).."'s current mode is: WARD")
	end
end

return J

--[[

[[
CanAbilityBeUpgraded(): bool
CanBeDisassembled(): bool
GetAOERadius(): int
GetAbilityDamage(): int
GetAutoCastState(): bool
GetBehavior(): int
GetCastPoint(): float
GetCastRange(): int
GetCaster(): handle
GetChannelTime(): float
GetChannelledManaCostPerSecond(): int
GetCooldown(): float
GetCooldownTimeRemaining(): float
GetCurrentCharges(): int
GetDamageType(): int
GetDuration(): float
GetEstimatedDamageToTarget( handlehTarget, floatfDuration, intnDamageTypes ): int
GetHeroLevelRequiredToUpgrade(): int
GetInitialCharges(): int
GetLevel(): int
GetManaCost(): int
GetMaxLevel(): int
GetName(): cstring
GetPowerTreadsStat(): int
GetSecondaryCharges(): int
GetSpecialValueFloat( cstringpszKey ): float
GetSpecialValueInt( cstringpszKey ): int
GetTargetFlags(): int
GetTargetTeam(): int
GetTargetType(): int
GetToggleState(): bool
IsActivated(): bool
IsChanneling(): bool
IsCombineLocked(): bool
IsCooldownReady(): bool
IsFullyCastable(): bool
IsHidden(): bool
IsInAbilityPhase(): bool
IsItem(): bool
IsOwnersManaEnough(): bool
IsPassive(): bool
IsStealable(): bool
IsStolen(): bool
IsTalent(): bool
IsToggle(): bool
IsTrained(): bool
IsUltimate(): bool
ProcsMagicStick(): bool
ToggleAutoCast(): void
ActionImmediate_Buyback(): void
ActionImmediate_Chat( cstringpszMessage, boolbAllChat ): void
ActionImmediate_Courier( handlehCourier, inteAction ): bool
ActionImmediate_DisassembleItem( handlehItem ): void
ActionImmediate_Glyph(): void
ActionImmediate_LevelAbility( cstringpszAbilityName ): void
ActionImmediate_Ping( floatx, floaty, boolbNormalPing ): void
ActionImmediate_PurchaseItem( cstringpszItemName ):
ActionImmediate_SellItem( handlehItem ): void
ActionImmediate_SetItemCombineLock( handlehItem, boolbLocked ): void
ActionImmediate_SwapItems( intnSlot1, intnSlot2 ): void
ActionPush_AttackMove( vectorlocation ): void
ActionPush_AttackUnit( handlehTarget, boolbOnce ): void
ActionPush_Delay( floatfDelay ): void
ActionPush_DropItem( handlehItem, vectorlocation ): void
ActionPush_MoveDirectly( vectorlocation ): void
ActionPush_MovePath( handlehPathTable ): void
ActionPush_MoveToLocation( vectorlocation ): void
ActionPush_MoveToUnit( handlehTarget ): void
ActionPush_PickUpItem( handlehItem ): void
ActionPush_PickUpRune( intnRune ): void
ActionPush_UseAbility( handlehAbility ): void
ActionPush_UseAbilityOnEntity( handlehAbility, handlehTarget ): void
ActionPush_UseAbilityOnLocation( handlehAbility, vectorlocation ): void
ActionPush_UseAbilityOnTree( handlehAbility, intiTree ): void
ActionPush_UseShrine( handlehShrine ): void
ActionQueue_AttackMove( vectorlocation ): void
ActionQueue_AttackUnit( handlehTarget, boolbOnce ): void
ActionQueue_Delay( floatfDelay ): void
ActionQueue_DropItem( handlehItem, vectorlocation ): void
ActionQueue_MoveDirectly( vectorlocation ): void
ActionQueue_MovePath( handlehPathTable ): void
ActionQueue_MoveToLocation( vectorlocation ): void
ActionQueue_MoveToUnit( handlehTarget ): void
ActionQueue_PickUpItem( handlehItem ): void
ActionQueue_PickUpRune( intnRune ): void
ActionQueue_UseAbility( handlehAbility ): void
ActionQueue_UseAbilityOnEntity( handlehAbility, handlehTarget ): void
ActionQueue_UseAbilityOnLocation( handlehAbility, vectorlocation ): void
ActionQueue_UseAbilityOnTree( handlehAbility, intiTree ): void
ActionQueue_UseShrine( handlehShrine ): void
Action_AttackMove( vectorlocation ): void
Action_AttackUnit( handlehTarget, boolbOnce ): void
Action_ClearActions( boolbStop ): void
Action_Delay( floatfDelay ): void
Action_DropItem( handlehItem, vectorlocation ): void
Action_MoveDirectly( vectorlocation ): void
Action_MovePath( handlehPathTable ): void
Action_MoveToLocation( vectorlocation ): void
Action_MoveToUnit( handlehTarget ): void
Action_PickUpItem( handlehItem ): void
Action_PickUpRune( intnRune ): void
Action_UseAbility( handlehAbility ): void
Action_UseAbilityOnEntity( handlehAbility, handlehTarget ): void
Action_UseAbilityOnLocation( handlehAbility, vectorlocation ): void
Action_UseAbilityOnTree( handlehAbility, intiTree ): void
Action_UseShrine( handlehShrine ): void
CanBeSeen(): bool
DistanceFromFountain(): int
DistanceFromSecretShop(): int
DistanceFromSideShop(): int
FindAoELocation( boolbEnemies, boolbHeroes, vectorvBaseLocation, intnMaxDistanceFromBase, intnRadius, floatfTimeInFuture, intnMaxHealth ): variant
FindItemSlot( cstringpszItemName ): int
GetAbilityByName( cstringpszAbilityName ): handle
GetAbilityInSlot( intiAbility ): handle
GetAbilityPoints(): int
GetAbilityTarget(): handle
GetAcquisitionRange(): int
GetActiveMode(): int
GetActiveModeDesire(): float
GetActualIncomingDamage( intnDamage, inteDamageType ): int
GetAnimActivity(): int
GetAnimCycle(): float
GetArmor(): float
GetAssignedLane(): int
GetAttackCombatProficiency( handlehTarget ): float
GetAttackDamage(): float
GetAttackPoint(): float
GetAttackProjectileSpeed(): int
GetAttackRange(): int
GetAttackSpeed(): float
GetAttackTarget(): handle
GetAttributeValue( intnAttribute ): int
GetBaseDamage(): float
GetBaseDamageVariance(): float
GetBaseHealthRegen(): float
GetBaseManaRegen(): float
GetBaseMovementSpeed(): int
GetBoundingRadius(): float
GetBountyGoldMax(): int
GetBountyGoldMin(): int
GetBountyXP(): int
GetBuybackCooldown(): float
GetBuybackCost(): int
GetCourierValue(): int
GetCurrentActionType(): int
GetCurrentActiveAbility(): handle
GetCurrentMovementSpeed(): int
GetCurrentVisionRange(): int
GetDayTimeVisionRange(): int
GetDefendCombatProficiency( handlehAttacker ): float
GetDenies(): int
GetDifficulty(): int
GetEstimatedDamageToTarget( boolbCurrentlyAvailable, handlehTarget, floatfDuration, intnDamageTypes ): int
GetEvasion(): float
GetExtrapolatedLocation( floatfDelay ): vector
GetFacing(): int
GetGold(): int
GetGroundHeight(): int
GetHealth(): int
GetHealthRegen(): float
GetHealthRegenPerStr(): float
GetIncomingTrackingProjectiles(): variant
GetItemInSlot( intnSlot ): handle
GetItemSlotType( intnSlot ): int
GetLastAttackTime(): float
GetLastHits(): int
GetLevel(): int
GetLocation(): vector
GetMagicResist(): float
GetMana(): int
GetManaRegen(): float
GetManaRegenPerInt(): float
GetMaxHealth(): int
GetMaxMana(): int
GetModifierAuxiliaryUnits( intnModifier ): variant
GetModifierByName( cstringpszModifierName ): int
GetModifierList(): variant
GetModifierName( intnModifier ): cstring
GetModifierRemainingDuration( intnModifier ): float
GetModifierStackCount( intnModifier ): int
GetMostRecentPing(): variant
GetMovementDirectionStability(): float
GetNearbyBarracks( intnRadius, boolbEnemies ): variant
GetNearbyCreeps( intnRadius, boolbEnemies ): variant
GetNearbyFillers( intnRadius, boolbEnemies ): variant
GetNearbyHeroes( intnRadius, boolbEnemies, inteBotMode ): variant
GetNearbyLaneCreeps( intnRadius, boolbEnemies ): variant
GetNearbyNeutralCreeps( intnRadius ): variant
GetNearbyShrines( intnRadius, boolbEnemies ): variant
GetNearbyTowers( intnRadius, boolbEnemies ): variant
GetNearbyTrees( intnRadius ): variant
GetNetWorth(): int
GetNextItemPurchaseValue(): int
GetNightTimeVisionRange(): int
GetOffensivePower(): float
GetPlayerID(): int
GetPrimaryAttribute(): int
GetQueuedActionType( intnQueuedAction ): int
GetRawOffensivePower(): float
GetRemainingLifespan(): float
GetRespawnTime(): float
GetSecondsPerAttack(): float
GetSlowDuration( boolbCurrentlyAvailable ): float
GetSpellAmp(): float
GetStashValue(): int
GetStunDuration( boolbCurrentlyAvailable ): float
GetTalent( intnLevel, intnSide ): handle
GetTarget(): handle
GetTeam(): int
GetUnitName(): cstring
GetVelocity(): vector
GetXPNeededToLevel(): int
HasBlink( boolbCurrentlyAvailable ): bool
HasBuyback(): bool
HasInvisibility( boolbCurrentlyAvailable ): bool
HasMinistunOnAttack(): bool
HasModifier( cstringpszModifierName ): bool
HasScepter(): bool
HasSilence( boolbCurrentlyAvailable ): bool
IsAlive(): bool
IsAncientCreep(): bool
IsAttackImmune(): bool
IsBlind(): bool
IsBlockDisabled(): bool
IsBot(): bool
IsBuilding(): bool
IsCastingAbility(): bool
IsChanneling(): bool
IsCourier(): bool
IsCreep(): bool
IsDisarmed(): bool
IsDominated(): bool
IsEvadeDisabled(): bool
IsFacingLocation( vectorvLocation, intnDegrees ): bool
IsFort(): bool
IsHero(): bool
IsHexed(): bool
IsIllusion(): bool
IsInvisible(): bool
IsInvulnerable(): bool
IsMagicImmune(): bool
IsMinion(): bool
IsMuted(): bool
IsNightmared(): bool
IsRooted(): bool
IsSilenced(): bool
IsSpeciallyDeniable(): bool
IsStunned(): bool
IsTower(): bool
IsUnableToMiss(): bool
IsUsingAbility(): bool
NumModifiers(): int
NumQueuedActions(): int
SetNextItemPurchaseValue( intnGold ): void
SetTarget( handle ): void
TimeSinceDamagedByAnyHero(): float
TimeSinceDamagedByCreep(): float
TimeSinceDamagedByHero( handlehHero ): float
TimeSinceDamagedByPlayer( intnPlayerID ): float
TimeSinceDamagedByTower(): float
UsingItemBreaksInvisibility(): bool
WasRecentlyDamagedByAnyHero( floatfTime ): bool
WasRecentlyDamagedByCreep( floatfTime ): bool
WasRecentlyDamagedByHero( handlehHero, floatfTime ): bool
WasRecentlyDamagedByPlayer( intnPlayerID, floatfTime ): bool
WasRecentlyDamagedByTower( floatfTime ): bool
CDOTA_TeamCommander
AddAvoidanceZone( vector, float ): int
AddConditionalAvoidanceZone( vector, handle ): int
CMBanHero( cstring ): void
CMPickHero( cstring ): void
Clamp( float, float, float ): float
CreateHTTPRequest( cstring ): handle
CreateRemoteHTTPRequest( cstring ): handle
DebugDrawCircle( vector, float, int, int, int ): void
DebugDrawLine( vector, vector, int, int, int ): void
DebugDrawText( float, float, cstring, int, int, int ): void
DebugPause(): void
DotaTime(): float
GameTime(): float
GeneratePath( vector, vector, handle, handle ): int
GetAllTrees(): variant
GetAmountAlongLane( int, vector ): variant
GetAncient( int ): handle
GetAvoidanceZones(): variant
GetBarracks( int, int ): handle
GetBot(): handle
GetBotAbilityByHandle( uint ): handle
GetBotByHandle( uint ): handle
GetCMCaptain(): int
GetCMPhaseTimeRemaining(): float
GetCourier( int ): handle
GetCourierState( handle ): int
GetDefendLaneDesire( int ): float
GetDroppedItemList(): variant
GetFarmLaneDesire( int ): float
GetGameMode(): int
GetGameState(): int
GetGameStateTimeRemaining(): float
GetGlyphCooldown(): float
GetHeightLevel( vector ): int
GetHeroAssists( int ): int
GetHeroDeaths( int ): int
GetHeroKills( int ): int
GetHeroLastSeenInfo( int ): variant
GetHeroLevel( int ): int
GetHeroPickState(): int
GetIncomingTeleports(): variant
GetItemComponents( cstring ): variant
GetItemCost( cstring ): int
GetItemStockCount( cstring ): int
GetLaneFrontAmount( int, int, bool ): float
GetLaneFrontLocation( int, int, float ): vector
GetLinearProjectileByHandle( int ): variant
GetLinearProjectiles(): variant
GetLocationAlongLane( int, float ): vector
GetNeutralSpawners(): variant
GetNumCouriers(): int
GetOpposingTeam(): int
GetPushLaneDesire( int ): float
GetRoamDesire(): float
GetRoamTarget(): handle
GetRoshanDesire(): float
GetRoshanKillTime(): float
GetRuneSpawnLocation( int ): vector
GetRuneStatus( int ):
GetRuneTimeSinceSeen( int ): float
GetRuneType( int ): int
GetScriptDirectory(): cstring
GetSelectedHeroName( int ): cstring
GetShopLocation( int, int ): vector
GetShrine( int, int ): handle
GetShrineCooldown( handle ): float
GetTeam(): int
GetTeamForPlayer( int ): int
GetTeamMember( int ): handle
GetTeamPlayers( int ): variant
GetTimeOfDay(): float
GetTower( int, int ): handle
GetTowerAttackTarget( int, int ): handle
GetTreeLocation( int ): vector
GetUnitList( int ): variant
GetUnitPotentialValue( handle, vector, float ): int
GetUnitToLocationDistance( handle, vector ): float
GetUnitToLocationDistanceSqr( handle, vector ): float
GetUnitToUnitDistance( handle, handle ): float
GetUnitToUnitDistanceSqr( handle, handle ): float
GetWorldBounds(): variant
InstallCastCallback( int, handle ): void
InstallChatCallback( handle ): void
InstallCourierDeathCallback( handle ): void
InstallDamageCallback( int, handle ): void
InstallRoshanDeathCallback( handle ): void
IsCMBannedHero( cstring ): bool
IsCMPickedHero( int, cstring ): bool
IsCourierAvailable(): bool
IsFlyingCourier( handle ): bool
IsHeroAlive( int ): bool
IsInCMBanPhase(): bool
IsInCMPickPhase(): bool
IsItemPurchasedFromSecretShop( cstring ): bool
IsItemPurchasedFromSideShop( cstring ): bool
IsLocationPassable( vector ): bool
IsLocationVisible( vector ): bool
IsPlayerBot( int ): bool
IsPlayerInHeroSelectionControl( int ): bool
IsRadiusVisible( vector, float ): bool
IsShrineHealing( handle ): bool
IsTeamPlayer( int ): bool
Max( float, float ): float
Min( float, float ): float
PointToLineDistance( vector, vector, vector ): variant
RandomFloat( float, float ): float
RandomInt( int, int ): int
RandomVector( float ): vector
RealTime(): float
RemapVal( float, float, float, float, float ): float
RemapValClamped( float, float, float, float, float ): float
RemoveAvoidanceZone( int ): void
RollPercentage( int ): bool
SelectHero( int, cstring ): void
SetCMCaptain( int ): void
]]


--[[
BOT_MODE_NONE
BOT_MODE_LANING
BOT_MODE_ATTACK
BOT_MODE_ROAM
BOT_MODE_RETREAT
BOT_MODE_RUNE
BOT_MODE_SECRET_SHOP
BOT_MODE_SIDE_SHOP
BOT_MODE_PUSH_TOWER_TOP
BOT_MODE_PUSH_TOWER_MID
BOT_MODE_PUSH_TOWER_BOT
BOT_MODE_DEFEND_TOWER_TOP
BOT_MODE_DEFEND_TOWER_MID
BOT_MODE_DEFEND_TOWER_BOT
BOT_MODE_ASSEMBLE
BOT_MODE_TEAM_ROAM
BOT_MODE_FARM
BOT_MODE_DEFEND_ALLY
BOT_MODE_EVASIVE_MANEUVERS
BOT_MODE_ROSHAN
BOT_MODE_ITEM
BOT_MODE_WARD
BOT_ACTION_DESIRE_NONE - 0.0
BOT_ACTION_DESIRE_VERYLOW - 0.1
BOT_ACTION_DESIRE_LOW - 0.25
BOT_ACTION_DESIRE_MODERATE - 0.5
BOT_ACTION_DESIRE_HIGH - 0.75
BOT_ACTION_DESIRE_VERYHIGH - 0.9
BOT_ACTION_DESIRE_ABSOLUTE - 1.0
BOT_MODE_DESIRE_NONE - 0
BOT_MODE_DESIRE_VERYLOW - 0.1
BOT_MODE_DESIRE_LOW - 0.25
BOT_MODE_DESIRE_MODERATE - 0.5
BOT_MODE_DESIRE_HIGH - 0.75
BOT_MODE_DESIRE_VERYHIGH - 0.9
BOT_MODE_DESIRE_ABSOLUTE - 1.0
DAMAGE_TYPE_PHYSICAL
DAMAGE_TYPE_MAGICAL
DAMAGE_TYPE_PURE
DAMAGE_TYPE_ALL
UNIT_LIST_ALL
UNIT_LIST_ALLIES
UNIT_LIST_ALLIED_HEROES
UNIT_LIST_ALLIED_CREEPS
UNIT_LIST_ALLIED_WARDS
UNIT_LIST_ALLIED_BUILDINGS
UNIT_LIST_ENEMIES
UNIT_LIST_ENEMY_HEROES
UNIT_LIST_ENEMY_CREEPS
UNIT_LIST_ENEMY_WARDS
UNIT_LIST_NEUTRAL_CREEPS
UNIT_LIST_ENEMY_BUILDINGS
DIFFICULTY_INVALID
DIFFICULTY_PASSIVE
DIFFICULTY_EASY
DIFFICULTY_MEDIUM
DIFFICULTY_HARD
DIFFICULTY_UNFAIR
ATTRIBUTE_INVALID
ATTRIBUTE_STRENGTH
ATTRIBUTE_AGILITY
ATTRIBUTE_INTELLECT
PURCHASE_ITEM_SUCCESS
PURCHASE_ITEM_OUT_OF_STOCK
PURCHASE_ITEM_DISALLOWED_ITEM
PURCHASE_ITEM_INSUFFICIENT_GOLD
PURCHASE_ITEM_NOT_AT_HOME_SHOP
PURCHASE_ITEM_NOT_AT_SIDE_SHOP
PURCHASE_ITEM_NOT_AT_SECRET_SHOP
PURCHASE_ITEM_INVALID_ITEM_NAME
GAMEMODE_NONE
GAMEMODE_AP
GAMEMODE_CM
GAMEMODE_RD
GAMEMODE_SD
GAMEMODE_AR
GAMEMODE_REVERSE_CM
GAMEMODE_MO
GAMEMODE_CD
GAMEMODE_ABILITY_DRAFT
GAMEMODE_ARDM
GAMEMODE_1V1MID
GAMEMODE_ALL_DRAFT
TEAM_RADIANT
TEAM_DIRE
TEAM_NEUTRAL
TEAM_NONE
LANE_NONE
LANE_TOP
LANE_MID
LANE_BOT
GAME_STATE_INIT
GAME_STATE_WAIT_FOR_PLAYERS_TO_LOAD
GAME_STATE_HERO_SELECTION
GAME_STATE_STRATEGY_TIME
GAME_STATE_PRE_GAME
GAME_STATE_GAME_IN_PROGRESS
GAME_STATE_POST_GAME
GAME_STATE_DISCONNECT
GAME_STATE_TEAM_SHOWCASE
GAME_STATE_CUSTOM_GAME_SETUP
GAME_STATE_WAIT_FOR_MAP_TO_LOAD
GAME_STATE_LAST
HEROPICK_STATE_NONE
HEROPICK_STATE_AP_SELECT
HEROPICK_STATE_SD_SELECT
HEROPICK_STATE_CM_INTRO
HEROPICK_STATE_CM_CAPTAINPICK
HEROPICK_STATE_CM_BAN1
HEROPICK_STATE_CM_BAN2
HEROPICK_STATE_CM_BAN3
HEROPICK_STATE_CM_BAN4
HEROPICK_STATE_CM_BAN5
HEROPICK_STATE_CM_BAN6
HEROPICK_STATE_CM_BAN7
HEROPICK_STATE_CM_BAN8
HEROPICK_STATE_CM_BAN9
HEROPICK_STATE_CM_BAN10
HEROPICK_STATE_CM_SELECT1
HEROPICK_STATE_CM_SELECT2
HEROPICK_STATE_CM_SELECT3
HEROPICK_STATE_CM_SELECT4
HEROPICK_STATE_CM_SELECT5
HEROPICK_STATE_CM_SELECT6
HEROPICK_STATE_CM_SELECT7
HEROPICK_STATE_CM_SELECT8
HEROPICK_STATE_CM_SELECT9
HEROPICK_STATE_CM_SELECT10
HEROPICK_STATE_CM_PICK
HEROPICK_STATE_AR_SELECT
HEROPICK_STATE_MO_SELECT
HEROPICK_STATE_FH_SELECT
HEROPICK_STATE_CD_INTRO
HEROPICK_STATE_CD_CAPTAINPICK
HEROPICK_STATE_CD_BAN1
HEROPICK_STATE_CD_BAN2
HEROPICK_STATE_CD_BAN3
HEROPICK_STATE_CD_BAN4
HEROPICK_STATE_CD_BAN5
HEROPICK_STATE_CD_BAN6
HEROPICK_STATE_CD_SELECT1
HEROPICK_STATE_CD_SELECT2
HEROPICK_STATE_CD_SELECT3
HEROPICK_STATE_CD_SELECT4
HEROPICK_STATE_CD_SELECT5
HEROPICK_STATE_CD_SELECT6
HEROPICK_STATE_CD_SELECT7
HEROPICK_STATE_CD_SELECT8
HEROPICK_STATE_CD_SELECT9
HEROPICK_STATE_CD_SELECT10
HEROPICK_STATE_CD_PICK
HEROPICK_STATE_BD_SELECT
HERO_PICK_STATE_ABILITY_DRAFT_SELECT
HERO_PICK_STATE_ARDM_SELECT
HEROPICK_STATE_ALL_DRAFT_SELECT
HERO_PICK_STATE_CUSTOMGAME_SELECT
HEROPICK_STATE_SELECT_PENALTY
RUNE_INVALID ( used as return value )
RUNE_DOUBLEDAMAGE
RUNE_HASTE
RUNE_ILLUSION
RUNE_INVISIBILITY
RUNE_REGENERATION
RUNE_BOUNTY
RUNE_ARCANE
RUNE_STATUS_UNKNOWN
RUNE_STATUS_AVAILABLE
RUNE_STATUS_MISSING
RUNE_POWERUP_1
RUNE_POWERUP_2
RUNE_BOUNTY_1
RUNE_BOUNTY_2
RUNE_BOUNTY_3
RUNE_BOUNTY_4
ITEM_SLOT_TYPE_INVALID
ITEM_SLOT_TYPE_MAIN
ITEM_SLOT_TYPE_BACKPACK
ITEM_SLOT_TYPE_STASH
BOT_ACTION_TYPE_NONE
BOT_ACTION_TYPE_IDLE
BOT_ACTION_TYPE_MOVE_TO
BOT_ACTION_TYPE_MOVE_TO_DIRECTLY
BOT_ACTION_TYPE_ATTACK
BOT_ACTION_TYPE_ATTACKMOVE
BOT_ACTION_TYPE_USE_ABILITY
BOT_ACTION_TYPE_PICK_UP_RUNE
BOT_ACTION_TYPE_PICK_UP_ITEM
BOT_ACTION_TYPE_DROP_ITEM
BOT_ACTION_TYPE_SHRINE
BOT_ACTION_TYPE_DELAY
COURIER_ACTION_BURST
COURIER_ACTION_ENEMY_SECRET_SHOP
COURIER_ACTION_RETURN
COURIER_ACTION_SECRET_SHOP
COURIER_ACTION_SIDE_SHOP
COURIER_ACTION_SIDE_SHOP2
COURIER_ACTION_TAKE_STASH_ITEMS
COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS
COURIER_ACTION_TRANSFER_ITEMS
COURIER_STATE_IDLE - 0
COURIER_STATE_AT_BASE - 1
COURIER_STATE_MOVING - 2
COURIER_STATE_DELIVERING_ITEMS - 3
COURIER_STATE_RETURNING_TO_BASE - 4
COURIER_STATE_DEAD
TOWER_TOP_1
TOWER_TOP_2
TOWER_TOP_3
TOWER_MID_1
TOWER_MID_2
TOWER_MID_3
TOWER_BOT_1
TOWER_BOT_2
TOWER_BOT_3
TOWER_BASE_1
TOWER_BASE_2
BARRACKS_TOP_MELEE
BARRACKS_TOP_RANGED
BARRACKS_MID_MELEE
BARRACKS_MID_RANGED
BARRACKS_BOT_MELEE
BARRACKS_BOT_RANGED
SHRINE_JUNGLE_1
SHRINE_JUNGLE_2
SHOP_HOME
SHOP_SIDE
SHOP_SECRET
SHOP_SIDE2
SHOP_SECRET2
ABILITY_TARGET_TEAM_NONE
ABILITY_TARGET_TEAM_FRIENDLY
ABILITY_TARGET_TEAM_ENEMY
ABILITY_TARGET_TYPE_NONE
ABILITY_TARGET_TYPE_HERO
ABILITY_TARGET_TYPE_CREEP
ABILITY_TARGET_TYPE_BUILDING
ABILITY_TARGET_TYPE_COURIER
ABILITY_TARGET_TYPE_OTHER
ABILITY_TARGET_TYPE_TREE
ABILITY_TARGET_TYPE_BASIC
ABILITY_TARGET_TYPE_ALL
ABILITY_TARGET_FLAG_NONE
ABILITY_TARGET_FLAG_RANGED_ONLY
ABILITY_TARGET_FLAG_MELEE_ONLY
ABILITY_TARGET_FLAG_DEAD
ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
ABILITY_TARGET_FLAG_INVULNERABLE
ABILITY_TARGET_FLAG_FOW_VISIBLE
ABILITY_TARGET_FLAG_NO_INVIS
ABILITY_TARGET_FLAG_NOT_ANCIENTS
ABILITY_TARGET_FLAG_PLAYER_CONTROLLED
ABILITY_TARGET_FLAG_NOT_DOMINATED
ABILITY_TARGET_FLAG_NOT_SUMMONED
ABILITY_TARGET_FLAG_NOT_ILLUSIONS
ABILITY_TARGET_FLAG_NOT_ATTACK_IMMUNE
ABILITY_TARGET_FLAG_MANA_ONLY
ABILITY_TARGET_FLAG_CHECK_DISABLE_HELP
ABILITY_TARGET_FLAG_NOT_CREEP_HERO
ABILITY_TARGET_FLAG_OUT_OF_WORLD
ABILITY_TARGET_FLAG_NOT_NIGHTMARED
ABILITY_TARGET_FLAG_PREFER_ENEMIES
ABILITY_BEHAVIOR_NONE
ABILITY_BEHAVIOR_HIDDEN
ABILITY_BEHAVIOR_PASSIVE
ABILITY_BEHAVIOR_NO_TARGET
ABILITY_BEHAVIOR_UNIT_TARGET
ABILITY_BEHAVIOR_POINT
ABILITY_BEHAVIOR_AOE
ABILITY_BEHAVIOR_NOT_LEARNABLE
ABILITY_BEHAVIOR_CHANNELLED
ABILITY_BEHAVIOR_ITEM
ABILITY_BEHAVIOR_TOGGLE
ABILITY_BEHAVIOR_DIRECTIONAL
ABILITY_BEHAVIOR_IMMEDIATE
ABILITY_BEHAVIOR_AUTOCAST
ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
ABILITY_BEHAVIOR_OPTIONAL_POINT
ABILITY_BEHAVIOR_OPTIONAL_NO_TARGET
ABILITY_BEHAVIOR_AURA
ABILITY_BEHAVIOR_ATTACK
ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
ABILITY_BEHAVIOR_ROOT_DISABLES
ABILITY_BEHAVIOR_UNRESTRICTED
ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
ABILITY_BEHAVIOR_IGNORE_CHANNEL
ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT
ABILITY_BEHAVIOR_DONT_ALERT_TARGET
ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN
ABILITY_BEHAVIOR_IGNORE_BACKSWING
ABILITY_BEHAVIOR_RUNE_TARGET
ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL
ABILITY_BEHAVIOR_VECTOR_TARGETING
ABILITY_BEHAVIOR_LAST_RESORT_POINT
GLYPH_COOLDOWN
ACTIVITY_IDLE - 1500
ACTIVITY_IDLE_RARE - 1501
ACTIVITY_RUN - 1502
ACTIVITY_ATTACK - 1503
ACTIVITY_ATTACK2 - 1504
ACTIVITY_ATTACK_EVENT - 1505
ACTIVITY_DIE - 1506
ACTIVITY_FLINCH - 1507
ACTIVITY_FLAIL - 1508
ACTIVITY_DISABLED - 1509
ACTIVITY_CAST_ABILITY_1 - 1510
ACTIVITY_CAST_ABILITY_2 - 1511
ACTIVITY_CAST_ABILITY_3 - 1512
ACTIVITY_CAST_ABILITY_4 - 1513
ACTIVITY_CAST_ABILITY_5 - 1514
ACTIVITY_CAST_ABILITY_6 - 1515
ACTIVITY_OVERRIDE_ABILITY_1 - 1516
ACTIVITY_OVERRIDE_ABILITY_2 - 1517
ACTIVITY_OVERRIDE_ABILITY_3 - 1518
ACTIVITY_OVERRIDE_ABILITY_4 - 1519
ACTIVITY_CHANNEL_ABILITY_1 - 1520
ACTIVITY_CHANNEL_ABILITY_2 - 1521
ACTIVITY_CHANNEL_ABILITY_3 - 1522
ACTIVITY_CHANNEL_ABILITY_4 - 1523
ACTIVITY_CHANNEL_ABILITY_5 - 1524
ACTIVITY_CHANNEL_ABILITY_6 - 1525
ACTIVITY_CHANNEL_END_ABILITY_1 - 1526
ACTIVITY_CHANNEL_END_ABILITY_2 - 1527
ACTIVITY_CHANNEL_END_ABILITY_3 - 1528
ACTIVITY_CHANNEL_END_ABILITY_4 - 1529
ACTIVITY_CHANNEL_END_ABILITY_5 - 1530
ACTIVITY_CHANNEL_END_ABILITY_6 - 1531
ACTIVITY_CONSTANT_LAYER - 1532
ACTIVITY_CAPTURE - 1533
ACTIVITY_SPAWN - 1534
ACTIVITY_KILLTAUNT - 1535
ACTIVITY_TAUNT - 1536
--]]


--[[
J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, sBuyList, sSellList )
J.PrintInitMessage( sFlag, sMessage )
J.IsDebugHero( bot )
J.CanNotUseAbility( bot )
J.GetVulnerableWeakestUnit( bot, bHero, bEnemy, nRadius )
J.GetUnitAllyCountAroundEnemyTarget( target, nRadius )
J.GetAroundTargetEnemyUnitCount( target, nRadius )
J.GetAroundTargetEnemyHeroCount( target, nRadius )
J.GetNearbyAroundLocationUnitCount( bEnemy, bHero, nRadius, vLoc )
J.GetAttackEnemysAllyCreepCount( target, nRadius )
J.GetVulnerableUnitNearLoc( bot, bHero, bEnemy, nCastRange, nRadius, vLoc )
J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, nCount )
J.IsWithoutTarget( bot )
J.GetProperTarget( bot )
J.IsAllyCanKill( target )
J.IsOtherAllyCanKillTarget( bot, target )
J.GetAlliesNearLoc( vLoc, nRadius )
J.IsAllyHeroBetweenAllyAndEnemy( hAlly, hEnemy, vLoc, nRadius )
J.IsSandKingThere( bot, nCastRange, fTime )
J.GetUltimateAbility( bot )
J.CanUseRefresherShard( bot )
J.GetMostUltimateCDUnit()
J.GetPickUltimateScepterUnit()
J.CanUseRefresherOrb( bot )
J.IsSuspiciousIllusion( npcTarget )
J.CanCastAbilityOnTarget( npcTarget, bIgnoreMagicImmune )
J.CanCastOnMagicImmune( npcTarget )
J.CanCastOnNonMagicImmune( npcTarget )
J.CanCastOnTargetAdvanced( npcTarget )
J.CanCastUnitSpellOnTarget( npcTarget, nDelay )
J.CanKillTarget( npcTarget, dmg, dmgType )
J.WillKillTarget( npcTarget, dmg, dmgType, dTime )
J.WillMixedDamageKillTarget( npcTarget, nPhysicalDamge, nMagicalDamage, nPureDamage, nDelay )
J.WillMagicKillTarget( bot, npcTarget, dmg, nDelay )
J.HasForbiddenModifier( npcTarget )
J.ShouldEscape( bot )
J.IsDisabled( npcTarget )
J.IsTaunted( npcTarget )
J.IsInRange( bot, npcTarget, nCastRange )
J.IsInLocRange( npcTarget, nLoc, nCastRange )
J.IsInTeamFight( bot, range )
J.IsRetreating( bot )
J.IsGoingOnSomeone( bot )
J.IsDoingRoshan( bot )
J.IsDefending( bot )
J.IsPushing( bot )
J.IsLaning( bot )
J.IsFarming( bot )
J.IsShopping( bot )
J.GetTeamFountain()
J.GetEnemyFountain()
J.GetComboItem( bot, sItemName )
J.HasItem( bot, sItemName )
J.IsItemAvailable( sItemName )
J.GetMostHpUnit( unitList )
J.GetLeastHpUnit( unitList )
J.IsAllowedToSpam( bot, nManaCost )
J.IsAllyUnitSpell( sAbilityName )
J.IsProjectileUnitSpell( sAbilityName )
J.IsOnlyProjectileSpell( sAbilityName )
J.IsStunProjectileSpell( sAbilityName )
J.IsWillBeCastUnitTargetSpell( bot, nRadius )
J.IsWillBeCastPointSpell( bot, nRadius )
J.IsProjectileIncoming( bot, range )
J.IsUnitTargetProjectileIncoming( bot, range )
J.IsStunProjectileIncoming( bot, range )
J.IsAttackProjectileIncoming( bot, range )
J.IsNotAttackProjectileIncoming( bot, range )
J.GetAttackProDelayTime( bot, nCreep )
J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )
J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime )
J.GetTotalAttackWillRealDamage( nUnit, nTime )
J.GetAttackProjectileDamageByRange( nUnit, nRadius )
J.GetCorrectLoc( target, delay )
J.GetEscapeLoc()
J.IsStuck2( bot )
J.IsStuck( bot )
J.IsExistInTable( u, tUnit )
J.CombineTwoTable( tableA, tableB )
J.GetInvUnitInLocCount( bot, nRadius, nFindRadius, vLocation, pierceImmune )
J.GetInLocLaneCreepCount( bot, nRadius, nFindRadius, vLocation )
J.GetInvUnitCount( pierceImmune, unitList )
J.GetDistanceFromEnemyFountain( bot )
J.GetDistanceFromAllyFountain( bot )
J.GetDistanceFromAncient( bot, bEnemy )
J.GetAroundTargetAllyHeroCount( target, nRadius )
J.GetAroundTargetOtherAllyHeroCount( bot, target, nRadius )
J.GetAllyCreepNearLoc( bot, vLoc, nRadius )
J.GetAllyUnitCountAroundEnemyTarget( bot, target, nRadius )
J.GetAroundBotUnitList( bot, nRadius, bEnemy )
J.GetLocationToLocationDistance( fLoc, sLoc )
J.GetUnitTowardDistanceLocation( bot, towardTarget, nDistance )
J.GetLocationTowardDistanceLocation( bot, towardLocation, nDistance )
J.GetFaceTowardDistanceLocation( bot, nDistance )
J.SetBotPing( vLoc )
J.SetBotPrint( sMessage, vLoc, bReport, bPing )
J.SetReportMotive( bDebugFile, sMotive )
J.GetCastLocation( bot, npcTarget, nCastRange, nRadius )
J.GetDelayCastLocation( bot, npcTarget, nCastRange, nRadius, nTime )
J.GetOne( number )
J.GetTwo( number )
J.SetQueueToInvisible( bot )
J.SetQueueSwitchPtToINT( bot )
J.SetQueueUseSoulRing( bot )
J.SetQueuePtToINT( bot, bSoulRingUsed )
J.IsPTReady( bot, status )
J.ShouldSwitchPTStat( bot, pt )
J.IsOtherAllysTarget( unit )
J.IsAllysTarget( unit )
J.IsKeyWordUnit( keyWord, Unit )
J.IsHumanPlayer( nUnit )
J.IsValid( nTarget )
J.IsValidHero( nTarget )
J.IsValidBuilding( nTarget )
J.IsRoshan( nTarget )
J.IsMoving( bot )
J.IsRunning( bot )
J.IsAttacking( bot )
J.IsChasingTarget( bot, nTarget )
J.IsRealInvisible( bot )
J.GetModifierTime( bot, sModifierName )
J.GetModifierCount( bot, sModifierName )
J.GetRemainStunTime( bot )
J.IsTeamActivityCount( bot, nCount )
J.GetSpecialModeAllies( bot, nDistance, nMode )
J.GetSpecialModeAlliesCount( nMode )
J.GetTeamFightLocation( bot )
J.GetTeamFightAlliesCount( bot )
J.GetCenterOfUnits( nUnits )
J.GetMostFarmLaneDesire()
J.GetMostDefendLaneDesire()
J.GetMostPushLaneDesire()
J.GetNearestLaneFrontLocation( nUnitLoc, bEnemy, fDeltaFromFront )
J.GetAttackableWeakestUnit( bot, nRadius, bHero, bEnemy )
J.CanBeAttacked( npcTarget )
J.GetHP( bot )
J.GetMP( bot )
J.GetAllyList( bot, nRadius )
J.GetAllyCount( bot, nRadius )
J.GetEnemyList( bot, nRadius )
J.GetEnemyCount( bot, nRadius )
J.GetAroundEnemyHeroList( nRadius )
J.GetAroundCreepList( nRadius, bNeutral, bLaneCreep, bEnemy )
J.ConsiderTarget()
J.IsHaveAegis( bot )
J.IsLocHaveTower( nRadius, bEnemy, nLoc )
J.GetNearbyLocationToTp( nLoc )
J.IsEnemyFacingUnit( bot, nRadius, nDegrees )
J.IsAllyFacingUnit( bot, nRadius, nDegrees )
J.IsEnemyTargetUnit( nUnit, nRadius )
J.IsCastingUltimateAbility( bot )
J.IsInAllyArea( bot )
J.IsInEnemyArea( bot )
J.IsEnemyHeroAroundLocation( vLoc, nRadius )
J.GetNumOfAliveHeroes( bEnemy )
J.GetAverageLevel( bEnemy )
J.GetNumOfTeamTotalKills( bEnemy )
J.ConsiderForMkbDisassembleMask( bot )
J.HasNotActionLast( nCD, nNumber )
J.GetCastDelay( bot, unit, nPointTime, nProjectSpeed )
J.CanBreakTeleport( bot, unit, nPointTime, nProjectSpeed )
J.GetMagicToPhysicalDamage( bot, nUnit, nMagicDamage )
--]]


--]]
-- dota2jmz@163.com QQ:2462331592..