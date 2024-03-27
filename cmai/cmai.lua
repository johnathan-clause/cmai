--
--      CAPTAIN'S MODE A.I. (CMAI)
--
--          cmai.lua
--

-- initialization
local _CMAI = {}

-- requires
local _ROLES = require(GetScriptDirectory() .. "\\cmai\\roles");
local _UTILS = require(GetScriptDirectory() .. "\\cmai\\utils");

-- init tables
local _pickedHeroes = {}
local _firstPickTimer = {}
local _lastPickTimer = {}
local _pickOrder = {}
local _heroRoles = {}
local _heroLanes = {}

-- init vars
local _lastState;
local _timeRemaining;
local _firstPickState;
local _lastPickState;

-- dec tables
local _firstPickStates = 
{
	[HEROPICK_STATE_CM_BAN1] = 1,
	[HEROPICK_STATE_CM_BAN2] = 0,
	[HEROPICK_STATE_CM_BAN3] = 0,
	[HEROPICK_STATE_CM_BAN4] = 4,
	[HEROPICK_STATE_CM_BAN5] = 0,
	[HEROPICK_STATE_CM_BAN6] = 0,
	[HEROPICK_STATE_CM_BAN7] = 7,
	[HEROPICK_STATE_CM_SELECT1] = 8,
	[HEROPICK_STATE_CM_SELECT2] = 0,
	[HEROPICK_STATE_CM_BAN8] = 10,
	[HEROPICK_STATE_CM_BAN9] = 11,
	[HEROPICK_STATE_CM_BAN10] = 0,
	[HEROPICK_STATE_CM_SELECT3] = 0,
	[HEROPICK_STATE_CM_SELECT4] = 14,
	[HEROPICK_STATE_CM_SELECT5] = 15,
	[HEROPICK_STATE_CM_SELECT6] = 0,
	[HEROPICK_STATE_CM_SELECT7] = 0,
	[HEROPICK_STATE_CM_SELECT8] = 18,
	[HEROPICK_STATE_CM_BAN11] = 19,
	[HEROPICK_STATE_CM_BAN12] = 0,
	[HEROPICK_STATE_CM_BAN13] = 0,
	[HEROPICK_STATE_CM_BAN14] = 22,
	[HEROPICK_STATE_CM_SELECT9] = 23,
	[HEROPICK_STATE_CM_SELECT10] = 0
}
local _lastPickStates = 
{
	[HEROPICK_STATE_CM_BAN1] = 0,
	[HEROPICK_STATE_CM_BAN2] = 2,
	[HEROPICK_STATE_CM_BAN3] = 3,
	[HEROPICK_STATE_CM_BAN4] = 0,
	[HEROPICK_STATE_CM_BAN5] = 5,
	[HEROPICK_STATE_CM_BAN6] = 6,
	[HEROPICK_STATE_CM_BAN7] = 0,
	[HEROPICK_STATE_CM_SELECT1] = 0,
	[HEROPICK_STATE_CM_SELECT2] = 9,
	[HEROPICK_STATE_CM_BAN8] = 0,
	[HEROPICK_STATE_CM_BAN9] = 0,
	[HEROPICK_STATE_CM_BAN10] = 12,
	[HEROPICK_STATE_CM_SELECT3] = 13,
	[HEROPICK_STATE_CM_SELECT4] = 0,
	[HEROPICK_STATE_CM_SELECT5] = 0,
	[HEROPICK_STATE_CM_SELECT6] = 16,
	[HEROPICK_STATE_CM_SELECT7] = 17,
	[HEROPICK_STATE_CM_SELECT8] = 0,
	[HEROPICK_STATE_CM_BAN11] = 0,
	[HEROPICK_STATE_CM_BAN12] = 20,
	[HEROPICK_STATE_CM_BAN13] = 21,
	[HEROPICK_STATE_CM_BAN14] = 0,
	[HEROPICK_STATE_CM_SELECT9] = 0,
	[HEROPICK_STATE_CM_SELECT10] = 24
}

-- dec vars
local _cmState = -1;
local _pickCycle = 1;

-- returns the current lane assignments; CRITICAL FUNCTION! SEE 'hero_selection_example.lua' FOR USAGE!
function _CMAI.GetLaneAssignments(lanes)
	if GetGameMode() == GAMEMODE_CM then
		return _CMAI.CMLaneAssignment()
	else
		return lanes()
	end
end

-- returns a random hero based on draft that has not been picked or banned to pick
function _CMAI.GetNHeroPick()
	local hero = "";
	while (
        hero == ""
        or IsCMPickedHero(GetTeam(), hero) 
        or IsCMPickedHero(GetOpposingTeam(), hero) 
        or IsCMBannedHero(hero)
	) do
        hero = _ROLES[_pickOrder[_pickCycle]][RandomInt(1, #_ROLES[_pickOrder[_pickCycle]])];
	end
	return hero
end

-- returns a random hero based on draft that has not been picked or banned to ban
function _CMAI.GetNHeroBan()
	local pool = {};
	for k,v in pairs(_pickOrder) do
		if k < _pickCycle then goto skip end
		for i,n in pairs(_CMAI.GetNRoleHeroes(v)) do
			table.insert(pool, n);
		end
		::skip::
	end
	::exit::
	local hero = pool[RandomInt(1, #pool)];

	while (
		IsCMPickedHero(GetTeam(), hero) 
		or IsCMPickedHero(GetOpposingTeam(), hero)
		or IsCMBannedHero(hero)
	) do
		hero = pool[RandomInt(1, #pool)];
	end
	return hero
end

-- returns a table containing all the heroes of a given role; role must be either 'safe', 'mid', 'off', 'soft', 'hard'
function _CMAI.GetNRoleHeroes(role)
    local pool = {}
	if role ~= "safe" and role ~= "mid" and role ~= "off" and role ~= "soft" and role ~= "hard" then return end
	for k,v in pairs(_ROLES[role]) do
		table.insert(pool, v);
	end
    return pool
end

-- main function where all logic is executed; CRITICAL FUNCTION! SEE 'hero_selection_example.lua' FOR USAGE!
function _CMAI.CMThink(min, max, think, draft)
	if GetGameMode() == GAMEMODE_CM then
		if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then return end
		if _cmState < 0 then
			_firstPickTimer[1] = RandomInt(min, max); -- thinkTime
			_firstPickTimer[2] = -129; -- reserveTime
			_lastPickTimer[1] = RandomInt(min, max); -- thinkTime
			_lastPickTimer[2] = -129; -- reserveTime
			_CMAI.ValidateDraft(draft);
			_cmState = 0;
		end
		if GetHeroPickState() ~= _lastState then
			_lastState = GetHeroPickState();
		end
		if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
			_CMAI.PickCaptain();
		elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
			_cmState = 1;
			_CMAI.SelectHeroes();
		end
		if _lastState ~= HEROPICK_STATE_CM_CAPTAINPICK and _lastState ~= HEROPICK_STATE_CM_PICK then
			_timeRemaining = GetCMPhaseTimeRemaining();
			if _cmState == 0 then
				_firstPickState = _firstPickStates[_lastState];
				_lastPickState = _lastPickStates[_lastState];
				if _firstPickState ~= 0 then
					if GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN14 and _timeRemaining <= _firstPickTimer[1] then
						_CMAI.BanHero();
						if _timeRemaining < 0 then
							_firstPickTimer[2] = _firstPickTimer[2] - _timeRemaining;
						end
						_firstPickTimer[1] = RandomInt(min, max);
					elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and _timeRemaining <= _firstPickTimer[1] then
						_CMAI.PickHero();
						_CMAI.UpdatePickedHero();
						if _timeRemaining < 0 then
							_firstPickTimer[2] = _firstPickTimer[2] - _timeRemaining;
						end
						_firstPickTimer[1] = RandomInt(min, max);
					end
				elseif _lastPickState ~= 0 then
					if GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN14 and _timeRemaining <= _lastPickTimer[1] then
						_CMAI.BanHero();
						if _timeRemaining < 0 then
							_lastPickTimer[2] = _lastPickTimer[2] - _timeRemaining;
						end
						_lastPickTimer[1] = RandomInt(min, max);
					elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and _timeRemaining <= _lastPickTimer[1] then
						_CMAI.PickHero();
						_CMAI.UpdatePickedHero();
						if _timeRemaining < 0 then
							_lastPickTimer[2] = _lastPickTimer[2] - _timeRemaining;
						end
						_lastPickTimer[1] = RandomInt(min, max);
					end
				end
			end
		end
	else
		think();
	end
end

-- ensures the draft input given, if any, is readable; otherwise, set draft data to default
function _CMAI.ValidateDraft(draft)
	local defDraft = {'hard','off','soft','mid','safe'}

	draft = draft or defDraft;
	for k,v in pairs(draft) do
		if v ~= 'safe' and v ~= 'mid' and v ~= 'off' and v ~= 'soft' and v ~= 'hard' then
			draft = defDraft;
			for k,v in pairs(draft) do
				_pickOrder[k] = v;
			end
			goto setpicks
		end
		_pickOrder[k] = v;
	end
	::setpicks::
end

-- picks a bot as a captain; always picks the first bot as captain
function _CMAI.PickCaptain()
	if not _UTILS.HasHumanPlayer() or DotaTime() > -1 then
		if GetCMCaptain() == -1 then
			local bot = _UTILS.GetFirstBot();

			if bot ~= nil then
				SetCMCaptain(bot);
			end
		end
	end
end

-- updates the the list of picked heroes when a hero is picked
function _CMAI.UpdatePickedHero()
	for k,v in pairs(_ROLES["hero"]) do
		if IsCMPickedHero(GetTeam(), v) then
			for i,n in pairs(_pickedHeroes) do
				if v == n then goto g end
			end
			table.insert(_pickedHeroes, v);
			_heroRoles[v] = _pickOrder[#_pickedHeroes];
		end
		::g::
	end
end

-- updates the list of picked heroes when a human player selects a hero
function _CMAI.UpdateSelectedHeroes(hero)
	for i = 1, #_pickedHeroes do
		if _pickedHeroes[i] == hero then
			table.remove(_pickedHeroes, i);
		end
	end
end

-- make bots select heroes once human players have selected
function _CMAI.SelectHeroes()
    local selecting = true;
	if selecting and (not _UTILS.IsHumanPlayerSelecting() or GetCMPhaseTimeRemaining() < 1) then
		local players = GetTeamPlayers(GetTeam());
		local hero = "";
		local bots = {}

		for k,v in pairs(players) do
			hero = GetSelectedHeroName(v);
			if hero ~= nil and hero ~= "" then
				_CMAI.UpdateSelectedHeroes(hero);
			else
				table.insert(bots, v);
			end
		end
		for i = 1, #bots do
			SelectHero(bots[i], _pickedHeroes[i]);
		end
		selecting = false;
	end
end

-- make bot pick a hero
function _CMAI.PickHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then return end
	local hero = _CMAI.GetNHeroPick();

	CMPickHero(hero);
	_pickCycle = _pickCycle + 1;
end

-- make bot ban a hero
function _CMAI.BanHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then return end
	local hero = _CMAI.GetNHeroBan();

	CMBanHero(hero);
end

-- assign bots to lanes based on roles
function _CMAI.CMLaneAssignment()
	local players = GetTeamPlayers(GetTeam());
    
	for i = 1, #players do
		local member = GetTeamMember(i);

		if member ~= nil and member:IsHero() then
            local unit = member:GetUnitName();

			if _heroRoles[unit] == "safe" then
				if GetTeam() == TEAM_RADIANT then
					_heroLanes[i] = LANE_BOT;
				else
					_heroLanes[i] = LANE_TOP;
				end
			elseif _heroRoles[unit] == "mid" then
				_heroLanes[i] = LANE_MID;
			elseif _heroRoles[unit] == "off" then
				if GetTeam() == TEAM_RADIANT then
					_heroLanes[i] = LANE_TOP;
				else
					_heroLanes[i] = LANE_BOT;
				end
			elseif _heroRoles[unit] == "soft" then
				if GetTeam() == TEAM_RADIANT then
					_heroLanes[i] = LANE_TOP;
				else
					_heroLanes[i] = LANE_BOT;
				end
			elseif _heroRoles[unit] == "hard" then
				if GetTeam() == TEAM_RADIANT then
					_heroLanes[i] = LANE_BOT;
				else
					_heroLanes[i] = LANE_TOP;
				end
			end
		end
	end
	return _heroLanes
end 
--
--
return _CMAI