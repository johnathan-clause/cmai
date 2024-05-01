---------------------------------------------------------------------------
--- The Creation Come From: A Beginner AI
--- Author: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
---------------------------------------------------------------------------
-- 有多少人工, 才有多么智能
-- How much artificial, how many intelligence.
------------------------------------------------------2017.08.20

local X = {}
local bDebugMode = ( 1 == 10 )
local sSelectHero = "npc_dota_hero_zuus"
local fLastSlectTime, fLastRand, nRand = -100, 0, 0
local nDelayTime = nil
local nHumanCount = 0
local sBanList = {}
local sSelectList = {}
local tSelectPoolList = {}
local tRecommendSelectPoolList = {}
local tLaneAssignList = {}
local bInitLineupDone = false

local bUserMode = false
local bLaneAssignActive = true  --默认手动分路
local bLineupActive = false
local bLineupReserve = false
local bLineupNotRepeated = false


--夜魇有玩家时AI也走中路补丁
local nDireFirstLaneType = 1 --夜魇默认一楼1中路, 2是下路, 3是上路
if pcall( require,  'game/bot_dire_first_lane_type' )
then
	nDireFirstLaneType = require( 'game/bot_dire_first_lane_type' )
end


local Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
local Chat = require( GetScriptDirectory()..'/FunLib/aba_chat' )
local HeroSet = {}
local sHeroSetLineupList = {}
local sHeroSetLaneAssignList = {}
local sUserKeyDir = Chat.GetUserKeyDir()

--[[
'npc_dota_hero_abaddon',
'npc_dota_hero_abyssal_underlord',
'npc_dota_hero_alchemist',
'npc_dota_hero_ancient_apparition',
'npc_dota_hero_antimage',
'npc_dota_hero_arc_warden',
'npc_dota_hero_axe',
'npc_dota_hero_bane',
'npc_dota_hero_batrider',
'npc_dota_hero_beastmaster',
'npc_dota_hero_bloodseeker',
'npc_dota_hero_bounty_hunter',
'npc_dota_hero_brewmaster',
'npc_dota_hero_bristleback',
'npc_dota_hero_broodmother',
'npc_dota_hero_centaur',
'npc_dota_hero_chaos_knight',
'npc_dota_hero_chen',
'npc_dota_hero_clinkz',
'npc_dota_hero_crystal_maiden',
'npc_dota_hero_dark_seer',
'npc_dota_hero_dark_willow',
'npc_dota_hero_dazzle',
'npc_dota_hero_disruptor',
'npc_dota_hero_death_prophet',
'npc_dota_hero_doom_bringer',
'npc_dota_hero_dragon_knight',
'npc_dota_hero_drow_ranger',
'npc_dota_hero_earth_spirit',
'npc_dota_hero_earthshaker',
'npc_dota_hero_elder_titan',
'npc_dota_hero_ember_spirit',
'npc_dota_hero_enchantress',
'npc_dota_hero_enigma',
'npc_dota_hero_faceless_void',
'npc_dota_hero_furion',
'npc_dota_hero_grimstroke',
'npc_dota_hero_gyrocopter',
'npc_dota_hero_huskar',
'npc_dota_hero_invoker',
'npc_dota_hero_jakiro',
'npc_dota_hero_juggernaut',
'npc_dota_hero_keeper_of_the_light',
'npc_dota_hero_kunkka',
'npc_dota_hero_legion_commander',
'npc_dota_hero_leshrac',
'npc_dota_hero_lich',
'npc_dota_hero_life_stealer',
'npc_dota_hero_lina',
'npc_dota_hero_lion',
'npc_dota_hero_lone_druid',
'npc_dota_hero_luna',
'npc_dota_hero_lycan',
'npc_dota_hero_magnataur',
'npc_dota_hero_mars',
'npc_dota_hero_medusa',
'npc_dota_hero_meepo',
'npc_dota_hero_mirana',
'npc_dota_hero_morphling',
'npc_dota_hero_monkey_king',
'npc_dota_hero_naga_siren',
'npc_dota_hero_necrolyte',
'npc_dota_hero_nevermore',
'npc_dota_hero_night_stalker',
'npc_dota_hero_nyx_assassin',
'npc_dota_hero_obsidian_destroyer',
'npc_dota_hero_ogre_magi',
'npc_dota_hero_omniknight',
'npc_dota_hero_oracle',
'npc_dota_hero_pangolier',
'npc_dota_hero_phantom_lancer',
'npc_dota_hero_phantom_assassin',
'npc_dota_hero_phoenix',
'npc_dota_hero_puck',
'npc_dota_hero_pudge',
'npc_dota_hero_pugna',
'npc_dota_hero_queenofpain',
'npc_dota_hero_rattletrap',
'npc_dota_hero_razor',
'npc_dota_hero_riki',
'npc_dota_hero_rubick',
'npc_dota_hero_sand_king',
'npc_dota_hero_shadow_demon',
'npc_dota_hero_shadow_shaman',
'npc_dota_hero_shredder',
'npc_dota_hero_silencer',
'npc_dota_hero_skeleton_king',
'npc_dota_hero_skywrath_mage',
'npc_dota_hero_slardar',
'npc_dota_hero_slark',
"npc_dota_hero_snapfire",
'npc_dota_hero_sniper',
'npc_dota_hero_spectre',
'npc_dota_hero_spirit_breaker',
'npc_dota_hero_storm_spirit',
'npc_dota_hero_sven',
'npc_dota_hero_techies',
'npc_dota_hero_terrorblade',
'npc_dota_hero_templar_assassin',
'npc_dota_hero_tidehunter',
'npc_dota_hero_tinker',
'npc_dota_hero_tiny',
'npc_dota_hero_treant',
'npc_dota_hero_troll_warlord',
'npc_dota_hero_tusk',
'npc_dota_hero_undying',
'npc_dota_hero_ursa',
'npc_dota_hero_vengefulspirit',
'npc_dota_hero_venomancer',
'npc_dota_hero_viper',
'npc_dota_hero_visage',
'npc_dota_hero_void_spirit',
'npc_dota_hero_warlock',
'npc_dota_hero_weaver',
'npc_dota_hero_windrunner',
'npc_dota_hero_winter_wyvern',
'npc_dota_hero_wisp',
'npc_dota_hero_witch_doctor',
'npc_dota_hero_zuus',
'npc_dota_hero_hoodwink',
'npc_dota_hero_dawnbreaker',
'npc_dota_hero_marci',
'npc_dota_hero_primal_beast',
--]]


local sHasDevelopmentHeroList = {

  "npc_dota_hero_abaddon",
	"npc_dota_hero_antimage",
  "npc_dota_hero_arc_warden",
  "npc_dota_hero_axe",
  "npc_dota_hero_bane",
  "npc_dota_hero_bloodseeker",
  "npc_dota_hero_bounty_hunter",
  "npc_dota_hero_bristleback",
  "npc_dota_hero_chaos_knight",
  "npc_dota_hero_clinkz",
  "npc_dota_hero_crystal_maiden",
  "npc_dota_hero_dazzle",
  "npc_dota_hero_death_prophet",
  --"npc_dota_hero_disruptor",
  "npc_dota_hero_dragon_knight",
  "npc_dota_hero_drow_ranger",
  "npc_dota_hero_earthshaker",
  "npc_dota_hero_gyrocopter",
  "npc_dota_hero_jakiro",
  "npc_dota_hero_juggernaut",
  "npc_dota_hero_kunkka",
  "npc_dota_hero_legion_commander",
  "npc_dota_hero_lich",
  "npc_dota_hero_lina",
  "npc_dota_hero_lion",
  "npc_dota_hero_luna",
  "npc_dota_hero_medusa",
  "npc_dota_hero_mirana",
  "npc_dota_hero_naga_siren",
  "npc_dota_hero_nevermore",
  "npc_dota_hero_necrolyte",
  "npc_dota_hero_ogre_magi",
  "npc_dota_hero_omniknight",
  "npc_dota_hero_oracle",
  "npc_dota_hero_phantom_assassin",
  "npc_dota_hero_phantom_lancer",
  "npc_dota_hero_pugna",
  "npc_dota_hero_queenofpain",
  "npc_dota_hero_razor",
  "npc_dota_hero_riki",
  "npc_dota_hero_sand_king",
  "npc_dota_hero_shadow_shaman",
  "npc_dota_hero_skeleton_king",
  "npc_dota_hero_skywrath_mage",
  "npc_dota_hero_slardar",
  "npc_dota_hero_slark",
  "npc_dota_hero_sniper",
  "npc_dota_hero_sven",
  "npc_dota_hero_templar_assassin",
  "npc_dota_hero_tidehunter",
  "npc_dota_hero_tiny",
  "npc_dota_hero_vengefulspirit",
  "npc_dota_hero_viper",
  "npc_dota_hero_warlock",
  "npc_dota_hero_witch_doctor",
  "npc_dota_hero_zuus"





}


local sFirstList = {

	"npc_dota_hero_silencer",
	"npc_dota_hero_warlock",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_oracle",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_lich",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_lion",
	"npc_dota_hero_dazzle",

	
}

local sSecondList = {
	
	"npc_dota_hero_crystal_maiden",
  "npc_dota_hero_vengefulspirit",
	"npc_dota_hero_zuus",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_lina",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_pugna",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_bane",
	"npc_dota_hero_earthshaker",
	
}

local sThirdList = {

	"npc_dota_hero_sven",
	"npc_dota_hero_luna",
	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_huskar",
	"npc_dota_hero_riki",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_axe",
	"npc_dota_hero_slark",
	"npc_dota_hero_juggernaut",

}

local sFourthList = {
  
  "npc_dota_hero_abaddon",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_skeleton_king", 
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_slardar",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_omniknight",
	
}

local sFifthList = {

	"npc_dota_hero_sniper",
	"npc_dota_hero_viper",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_medusa", 
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_razor",
	"npc_dota_hero_mirana",
	
}

---------------------------------------------------------
---------------------------------------------------------

local sPriestList = {

  	"npc_dota_hero_dazzle",
  	"npc_dota_hero_necrolyte",
  	"npc_dota_hero_omniknight",
  	"npc_dota_hero_oracle",
  	"npc_dota_hero_pugna",
  	"npc_dota_hero_warlock",
  	--"npc_dota_hero_witch_doctor",

}

local sMageList = {

	"npc_dota_hero_bane",
  "npc_dota_hero_crystal_maiden",
  "npc_dota_hero_dazzle",
  "npc_dota_hero_death_prophet",
  "npc_dota_hero_earthshaker",
  "npc_dota_hero_jakiro",
  "npc_dota_hero_lich",
  "npc_dota_hero_lina",
  "npc_dota_hero_lion",
  "npc_dota_hero_necrolyte",
  "npc_dota_hero_ogre_magi",
  "npc_dota_hero_omniknight",
  "npc_dota_hero_oracle",
  "npc_dota_hero_pugna",
  "npc_dota_hero_queenofpain",
  "npc_dota_hero_shadow_shaman",
  "npc_dota_hero_silencer",
  "npc_dota_hero_skywrath_mage",
  "npc_dota_hero_vengefulspirit",
  "npc_dota_hero_warlock",
  "npc_dota_hero_witch_doctor",
  "npc_dota_hero_zuus",

}

local sCarryList = {

	--[["npc_dota_hero_abaddon",
	--"npc_dota_hero_antimage",
  	--"npc_dota_hero_arc_warden",
  	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bristleback",
  	"npc_dota_hero_chaos_knight",
  	"npc_dota_hero_clinkz",
  	"npc_dota_hero_drow_ranger",
  	--"npc_dota_hero_gyrocopter",
  	"npc_dota_hero_huskar",
  	"npc_dota_hero_juggernaut",
	"npc_dota_hero_legion_commander",
  	"npc_dota_hero_lina",
  	"npc_dota_hero_luna",
  	--"npc_dota_hero_medusa",
  	--"npc_dota_hero_mirana",
  	"npc_dota_hero_naga_siren",
  	"npc_dota_hero_nevermore",
  	"npc_dota_hero_phantom_assassin",
  	"npc_dota_hero_phantom_lancer",
  	"npc_dota_hero_razor",
  	"npc_dota_hero_riki",
  	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_slardar",
  	"npc_dota_hero_slark",
  	"npc_dota_hero_sniper",
  	"npc_dota_hero_sven",
  	"npc_dota_hero_templar_assassin",]]
	"npc_dota_hero_tiny",
  	"npc_dota_hero_viper",

}


local sTankList = {

  "npc_dota_hero_abaddon",
  "npc_dota_hero_axe",
  "npc_dota_hero_bristleback",
  "npc_dota_hero_chaos_knight",
  "npc_dota_hero_death_prophet",
  "npc_dota_hero_dragon_knight",
  "npc_dota_hero_kunkka",
  "npc_dota_hero_legion_commander",
  "npc_dota_hero_ogre_magi",
  "npc_dota_hero_omniknight",
  "npc_dota_hero_sand_king",
  "npc_dota_hero_skeleton_king",
  "npc_dota_hero_slardar",
  "npc_dota_hero_tidehunter",

}


local sMidList = {

	"npc_dota_hero_antimage",
	"npc_dota_hero_arc_warden",
  "npc_dota_hero_bounty_hunter",
  "npc_dota_hero_bristleback",
  "npc_dota_hero_clinkz",
  "npc_dota_hero_death_prophet",
  "npc_dota_hero_dragon_knight",
  "npc_dota_hero_earthshaker",
  "npc_dota_hero_huskar",
  "npc_dota_hero_jakiro",
  "npc_dota_hero_kunkka",
  "npc_dota_hero_legion_commander",
  "npc_dota_hero_lich",
  "npc_dota_hero_lina",
  "npc_dota_hero_medusa",
  "npc_dota_hero_mirana",
  "npc_dota_hero_necrolyte",
  "npc_dota_hero_nevermore",
  "npc_dota_hero_ogre_magi",
  "npc_dota_hero_oracle",
  "npc_dota_hero_phantom_assassin",
  "npc_dota_hero_phantom_lancer",
  "npc_dota_hero_pugna",
  "npc_dota_hero_queenofpain",
  "npc_dota_hero_razor",
  "npc_dota_hero_silencer",
  "npc_dota_hero_skywrath_mage",
  "npc_dota_hero_sniper",
  "npc_dota_hero_templar_assassin",
  "npc_dota_hero_viper",
  "npc_dota_hero_zuus",
	
}


tSelectPoolList = {
	[1] = sMidList,
	[2] = sTankList,
	[3] = sCarryList,
	[4] = sMageList,
	[5] = sPriestList,
}

tRecommendSelectPoolList = {
	[1] = sFifthList,
	[2] = sFourthList,
	[3] = sThirdList,
	[4] = sSecondList,
	[5] = sFirstList,
}


--For Mid Version Random Lineup-------------
local sBotVersion = Role.GetBotVersion()
if sBotVersion == 'Mid'
then
	tSelectPoolList = {
		[1] = sHasDevelopmentHeroList,
		[2] = sHasDevelopmentHeroList,
		[3] = sHasDevelopmentHeroList,
		[4] = sHasDevelopmentHeroList,
		[5] = sHasDevelopmentHeroList,
	}
end


--预挑选阵容
sSelectList = {
	[1] = tSelectPoolList[1][RandomInt( 1, #tSelectPoolList[1] )],
	[2] = tSelectPoolList[2][RandomInt( 1, #tSelectPoolList[2] )],
	[3] = tSelectPoolList[3][RandomInt( 1, #tSelectPoolList[3] )],
	[4] = tSelectPoolList[4][RandomInt( 1, #tSelectPoolList[4] )],
	[5] = tSelectPoolList[5][RandomInt( 1, #tSelectPoolList[5] )],
}





if pcall( function( sDir ) require( sDir ) end, sUserKeyDir )
then
		
	local sUserKey = require( sUserKeyDir )

	Role.SetUserKey( sUserKey )

	local sHeroSetDir = Chat.GetHeroSetDir()
	
	if Role.GetKeyLV() >= 2
		and pcall( function( sDir ) require( sDir ) end, sHeroSetDir )
	then		
		
		bUserMode = true
		
		HeroSet = require( sHeroSetDir )	

		Role["nUserModeLevel"] = Chat.GetRawGameWord( HeroSet['JiHuoCeLue'] ) == true and Role.GetKeyLV() or 1
		Role["sUserName"] = HeroSet['ZhanDuiJunShi']

		if Role["nUserModeLevel"] <= 1 then bUserMode = false end

		if bUserMode
		then
			
			bLineupActive = true 
			sHeroSetLineupList = Chat.GetHeroSelectList( HeroSet['ZhenRong'] )
			
			if Chat.GetRawGameWord( HeroSet['FenLuShengXiao'] ) == false then bLaneAssignActive = false end
				
			sHeroSetLaneAssignList = Chat.GetLaneAssignList( HeroSet['FenLu'] )
					
			if Chat.GetRawGameWord( HeroSet['NeiBuTiaoXuan'] ) == true then bLineupReserve = true end	
			
			local sRadomHeroPoolDir = Chat.GetRandomHeroPoolDir()
						
			if pcall( function( sDir ) require( sDir ) end, sRadomHeroPoolDir )
			then
				local RandomHeroPool = require( sRadomHeroPoolDir )
				if Chat.GetRawGameWord( RandomHeroPool['JiHuoSuiJi'] ) == true
				then
					
					tSelectPoolList = {
								[1] = Chat.GetHeroSelectList( RandomHeroPool['1'] ),
								[2] = Chat.GetHeroSelectList( RandomHeroPool['2'] ),
								[3] = Chat.GetHeroSelectList( RandomHeroPool['3'] ),
								[4] = Chat.GetHeroSelectList( RandomHeroPool['4'] ),
								[5] = Chat.GetHeroSelectList( RandomHeroPool['5'] ),
					}
					
					if Chat.GetRawGameWord( RandomHeroPool['JiHuoZhenRongChi'] ) == true
					then
						bLineupNotRepeated = true
						sHeroSetLineupList = Chat.GetRandomLineupFromHeroPool( RandomHeroPool['ZhenRongChi'] )
					end
				end
			end
		end
		
	end
end

------------------------------------------------
------------------------------------------------
--初始化阵容和英雄池完毕
------------------------------------------------
------------------------------------------------


--初始分路
if GetTeam() == TEAM_RADIANT
then
	local nRadiantLane = {
							[1] = LANE_MID,
							[2] = LANE_TOP,
							[3] = LANE_BOT,
							[4] = LANE_BOT,
							[5] = LANE_TOP,
						}

	tLaneAssignList = nRadiantLane

else
	local nDireLane = {
						[1] = LANE_MID,
						[2] = LANE_BOT,
						[3] = LANE_TOP,
						[4] = LANE_TOP,
						[5] = LANE_BOT,
					  }				

	tLaneAssignList = nDireLane
end



--如果安装了夜魇有玩家时AI也走中路补丁(不为2), 交换预选阵容和分路
if nDireFirstLaneType == 2 and GetTeam() == TEAM_DIRE
then
	sSelectList[1], sSelectList[2] = sSelectList[2], sSelectList[1]
	tSelectPoolList[1], tSelectPoolList[2] = tSelectPoolList[2], tSelectPoolList[1]
	tLaneAssignList[1], tLaneAssignList[2] = tLaneAssignList[2], tLaneAssignList[1]
end

if nDireFirstLaneType == 3 and GetTeam() == TEAM_DIRE
then
	sSelectList[1], sSelectList[3] = sSelectList[3], sSelectList[1]
	tSelectPoolList[1], tSelectPoolList[3] = tSelectPoolList[3], tSelectPoolList[1]
	tLaneAssignList[1], tLaneAssignList[3] = tLaneAssignList[3], tLaneAssignList[1]
end




--根据用户配置初始列表
--初始化英雄池, 英雄表, 英雄分路
--tSelectPoolList, sSelectList, tLaneAssignList
function X.SetLineupInit()

	if bInitLineupDone then return end

	if bLineupActive 
	then 
		sSelectList = sHeroSetLineupList 
		tLaneAssignList = sHeroSetLaneAssignList
	end
	
	bInitLineupDone = true
	
	

end


function X.GetMoveTable( nTable )

	local nLenth = #nTable
	local temp = nTable[nLenth]

	table.remove( nTable, nLenth )
	table.insert( nTable, 1, temp )

	return nTable

end


function X.IsExistInTable( sString, sStringList )

	for _, sTemp in pairs( sStringList )
	do
		if sString == sTemp then return true end
	end

	return false

end


function X.IsHumanNotReady( nTeam )

	if GameTime() > 20 or bLineupReserve then return false end

	local humanCount, readyCount = 0, 0
	local nIDs = GetTeamPlayers( nTeam )
	for i, id in pairs( nIDs )
	do
        if not IsPlayerBot( id )
		then
			humanCount = humanCount + 1
			if GetSelectedHeroName( id ) ~= ""
			then
				readyCount = readyCount + 1
			end
		end
    end

	if( readyCount >= humanCount )
	then
		return false
	end

	return true

end


function X.GetNotRepeatHero( nTable )

	local sHero = nTable[1]
	local maxCount = #nTable
	local nRand = 0
	local bRepeated = false

	for count = 1, maxCount
	do
		nRand = RandomInt( 1, #nTable )
		sHero = nTable[nRand]
		bRepeated = false
		for id = 0, 20
		do
			if ( IsTeamPlayer( id ) and GetSelectedHeroName( id ) == sHero )
				or ( IsCMBannedHero( sHero ) )
				or ( X.IsBanByChat( sHero ) )
				--or ( sHero == 'sRandomHero' )
			then
				bRepeated = true
				table.remove( nTable, nRand )
				break
			end
		end
		if not bRepeated then break end
	end

	return sHero
	
end




function X.IsRepeatHero( sHero )

	for id = 0, 20
	do
		if ( IsTeamPlayer( id ) and GetSelectedHeroName( id ) == sHero )
			or ( IsCMBannedHero( sHero ) )
			or ( X.IsBanByChat( sHero ) )
		then
			return true
		end
	end

	return false

end


if bUserMode and HeroSet['JinYongAI'] ~= nil
then
	sBanList = Chat.GetHeroSelectList( HeroSet['JinYongAI'] )
end



function X.SetChatHeroBan( sChatText )

	sBanList[#sBanList + 1] = string.lower( sChatText )

end


function X.IsBanByChat( sHero )

	for i = 1, #sBanList
	do
		if sBanList[i] ~= nil
		   and string.find( sHero, sBanList[i] )
		then
			return true
		end
	end

	return false
end


local sTianStarList =
{
--[["天罡星",
"天魁星",
"天机星",
"天闲星",
"天勇星",
"天雄星",
"天猛星",
"天英星",
"天贵星",
"天富星",
"天满星",
"天孤星",
"天伤星",
"天立星",
"天捷星",
"天暗星",
"天佑星",
"天空星",
"天速星",
"天异星",
"天杀星",
"天微星",
"天究星",
"天退星",
"天寿星",
"天剑星",
"天平星",
"天罪星",
"天损星",
"天牢星",
"天慧星",
"天暴星",
"天巧星",
"天威星",
--"天哭星",
--"天败星",]]
"Ksh",
"YoungPH",
"KoBoo",
"Boyka",
"RapRap",
}


local sDiStarsList =
{
--[["地煞星",
"地魁星",
"地勇星",
"地杰星",
"地雄星",
"地英星",
"地奇星",
"地猛星",
"地文星",
"地正星",
"地阔星",
"地阖星",
"地强星",
"地暗星",
"地轴星",
"地会星",
"地佐星",
"地佑星",
"地灵星",
"地兽星",
"地微星",
"地慧星",
"地暴星",
"地然星",
"地猖星",
"地狂星",
"地飞星",
"地走星",
"地巧星",
"地明星",
"地进星",
"地退星",
"地满星",
"地遂星",
"地周星",
"地隐星",
"地异星",
"地理星",
"地俊星",
"地乐星",
"地捷星",
"地速星",
"地镇星",
"地嵇星",
"地魔星",
"地妖星",
"地幽星",
"地伏星",
"地僻星",
"地空星",
"地孤星",
"地全星",
"地短星",
"地角星",
"地平星",
"地察星",
"地数星",
"地阴星",
"地刑星",
"地壮星",
"地健星",
"地耗星",
--"地贼星",
--"地狗星",
--"地威星",
--"地劣星",
--"地损星",
--"地奴星",
--"地囚星",
--"地藏星",]]
"Kenji",
"Insane",
"Mice",
"Kalay99",
"ShowTi",
}

function X.GetRandomNameList( sStarList )

	
	local sNameList = {sStarList[1]}
	table.remove( sStarList, 1 )

	for i = 1, 4
	do
	    local nRand = RandomInt( 1, #sStarList )
		table.insert( sNameList, sStarList[nRand] )
		table.remove( sStarList, nRand )
	end
	

	return sNameList

end


function Think()


	if not bInitLineupDone then X.SetLineupInit() return end

	if GetGameState() == GAME_STATE_HERO_SELECTION then
		InstallChatCallback( function ( tChat ) X.SetChatHeroBan( tChat.string ) end )
	end
	

	if ( GameTime() < 3.0 and not bLineupReserve )
	   or fLastSlectTime > GameTime() - fLastRand
	   or X.IsHumanNotReady( GetTeam() )
	   or X.IsHumanNotReady( GetOpposingTeam() )
	then 
		if GetGameMode() ~= 23 then return end  --非加速则延迟挑选, 加速模式延迟挑选有BUG
	end

	if nDelayTime == nil then nDelayTime = GameTime() fLastRand = RandomInt( 12, 34 )/10 end
	if nDelayTime ~= nil and nDelayTime > GameTime() - fLastRand then return end
	
	--自定义挑选
	if bLineupActive
	then
		local nIDs = GetTeamPlayers( GetTeam() )
		
		for i, id in pairs( nIDs )
		do
			if ( IsPlayerBot( id ) or bLineupReserve )
				and ( GetSelectedHeroName( id ) == "" )
			then
				sSelectHero = sSelectList[i]

				if sSelectHero == "sRandomHero"
					or ( bLineupNotRepeated and X.IsRepeatHero( sSelectHero ) )
				then
					sSelectHero = X.GetNotRepeatHero( tSelectPoolList[i] )
					if not IsPlayerBot( id ) then sSelectHero = Chat['sAllHeroList'][RandomInt( 2, 121 )] end
				end

				SelectHero( id, sSelectHero )
				
				if Role["bLobbyGame"] == false then Role["bLobbyGame"] = true end

				fLastSlectTime = GameTime()
				fLastRand = RandomInt( 3, 9 )/10
				break
			end
		end
		return
	end

	--常规挑选
	local nIDs = GetTeamPlayers( GetTeam() )
	
	for i, id in pairs( nIDs )
	do
		if IsPlayerBot( id ) and GetSelectedHeroName( id ) == ""
		then

			if X.IsRepeatHero( sSelectList[i] ) 
				or ( nHumanCount == 0 --无玩家时阵容更偏向预设值
					 and RandomInt( 1, 99 ) <= 75
					 and not X.IsExistInTable( sSelectList[i], tRecommendSelectPoolList[i] ) )
			then
				sSelectHero = X.GetNotRepeatHero( tSelectPoolList[i] )
			else
				sSelectHero = sSelectList[i]
			end

			-------******************************-----------------------------------------------
			-- if GetTeam() ~= TEAM_DIRE and i == 2 then sSelectHero = "npc_dota_hero_lina" end 
			-- if GetTeam() ~= TEAM_DIRE and i == 1 then sSelectHero = "npc_dota_hero_antimage" end 
		
			
			------------------------------------------------------------------------------------

			SelectHero( id, sSelectHero )
			
			if Role["bLobbyGame"] == false then Role["bLobbyGame"] = true end

			fLastSlectTime = GameTime()
			fLastRand = RandomInt( 8, 28 )/10
			break
		end
	end


end


function GetBotNames()

	if bUserMode then return HeroSet['ZhanDuiMing'] end

 	return GetTeam() == TEAM_RADIANT and X.GetRandomNameList( sTianStarList ) or X.GetRandomNameList( sDiStarsList )

end



local bPvNLaneAssignDone = false

-- if bLaneAssignActive
-- then
function UpdateLaneAssignments()

	if DotaTime() > 0
		and nHumanCount == 0
		and Role.IsPvNMode()
		and not bLaneAssignActive
		and not bPvNLaneAssignDone
	then
		if RandomInt( 1, 8 ) > 4 then tLaneAssignList[4] = LANE_MID else tLaneAssignList[5] = LANE_MID end
		bPvNLaneAssignDone = true
	end

	return tLaneAssignList

end
-- end


-- dota2jmz@163.com QQ:2462331592..
local CMAI = require(GetScriptDirectory() .. '\\cmai\\cmai');
Think = GetGameMode() == GAMEMODE_CM and CMAI.Think or Think; 
UpdateLaneAssignments = GetGameMode() == GAMEMODE_CM and CMAI.UpdateLaneAssignments or UpdateLaneAssignments;