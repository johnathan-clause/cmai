--
--      CMAI UTILITIES
--
--          utils.lua
--

-- initialization
local _UTILS = {}

-- returns the first bot player in a team
function _UTILS.GetFirstBot(teamId)
    local bot = nil;
	local players = GetTeamPlayers(GetTeam());

	teamId = teamId or false;
	for k,v in pairs(players) do
		if IsPlayerBot(v) then
			bot = v;
			return teamId and k or bot
		end
	end
	return bot
end

-- returns true if a team  has a human player
function _UTILS.HasHumanPlayer()
	local players = GetTeamPlayers(GetTeam())

	for k,v in pairs(players) do
		if not IsPlayerBot(v) then
			return true
		end
	end
	return false
end

-- returns false if each human player has selected a hero
function _UTILS.IsHumanPlayerSelecting()
	local allies = GetTeamPlayers(GetTeam());
	local enemies = GetTeamPlayers(GetOpposingTeam());

	for k,v in pairs(allies) do
		if not IsPlayerBot(v) then
			if GetSelectedHeroName(v) == nil or GetSelectedHeroName(v) == "" then
				return true
			end
		end
	end
	for k,v in pairs(enemies) do
		if not IsPlayerBot(v) then
			if GetSelectedHeroName(v) == nil or GetSelectedHeroName(v) == "" then
				return true
			end
		end
	end
	return false
end

-- returns a table with shuffled rows of given table
function _UTILS.GetShuffledTable(original)
	local shuffled = {}

	math.randomseed(RandomInt(0,999));
	for k,v in pairs(original) do
		local pos = math.random(1, #shuffled+1)
		table.insert(shuffled, pos, v)
	end
	return shuffled
end

-- sets a bot as a captain; always picks the first bot as captain if no input given
function _UTILS.SetCaptain(botId)
	if GetCMCaptain() == -1 then
		local bot = botId or _UTILS.GetFirstBot();

		if bot ~= nil then
			SetCMCaptain(bot);
		end
	end
end

-- returns a table of heroes for a given role
function _UTILS.GetNRoleHeroes(role)
	local ROLES = require(GetScriptDirectory() .. '\\cmai\\roles');
	return ROLES[role]
end

-- returns true if the given hero is found in the given role
function _UTILS.IsHeroNRole(hero, role)
	local ROLES = require(GetScriptDirectory() .. '\\cmai\\roles');
	for k,v in pairs(ROLES[role]) do
		if hero == v then return true end
	end
	return false
end	

-- returns a table of hero counters and countered for a given hero
function _UTILS.GetNHeroSynergy(hero)
	local ROLES = require(GetScriptDirectory() .. '\\cmai\\roles');
	for k,v in pairs(ROLES['synergy']) do
		if hero == k then return v end
	end
	return nil
end
--
--
return _UTILS