--
--      CMAI UTILITIES
--
--          utils.lua
--

-- initialization
local _UTILS = {}

-- returns the first bot player in a team
function _UTILS.GetFirstBot()
    local bot = nil;
	local players = GetTeamPlayers(GetTeam());

	for k,v in pairs(players) do
		if IsPlayerBot(v) then
			bot = v;
			return bot
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

	math.randomseed(RandomInt(1,1000));
	for k,v in pairs(original) do
		local pos = math.random(1, #shuffled+1)
		table.insert(shuffled, pos, v)
	end
	return shuffled
end
--
--
return _UTILS