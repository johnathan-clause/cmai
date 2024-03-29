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

-- dec const
local _CMAI_STATE_PRE 		= 1;
local _CMAI_STATE_CAPTAIN	= 2;
local _CMAI_STATE_DRAFT 	= 3;
local _CMAI_STATE_PICK		= 4;
local _CMAI_STATE_POST	 	= 5;

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
local _cmaiStates = 
{
	[_CMAI_STATE_PRE] 		= 1,
	[_CMAI_STATE_CAPTAIN]	= 2,
	[_CMAI_STATE_DRAFT] 	= 4,
	[_CMAI_STATE_PICK]	 	= 8,
	[_CMAI_STATE_POST] 		= 16,

}
local _defaultDraft = 
{
	"safe",
	"mid",
	"off",
	"soft",
	"hard"
}

-- dec vars
local _pickCycle = 1;
local _cmaiState = _cmaiStates[_CMAI_STATE_PRE];


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

-- returns a random hero that has not been picked or banned to ban
function _CMAI.GetNHeroBan()
	local hero = "";

	while (
        hero == ""
        or IsCMPickedHero(GetTeam(), hero) 
        or IsCMPickedHero(GetOpposingTeam(), hero) 
        or IsCMBannedHero(hero)
	) do
        hero = _ROLES["hero"][RandomInt(1, #_ROLES["hero"])];
	end
	return hero
end

-- main function where all logic is executed; CRITICAL FUNCTION! SEE 'hero_selection_example.lua' FOR USAGE!
function _CMAI.CMThink(min, max, think, logRadiant, logDire, radiantDraft, direDraft)
	if GetGameMode() == GAMEMODE_CM then
		if GetGameState() ~= GAME_STATE_HERO_SELECTION then return end

		if _cmaiState == _cmaiStates[_CMAI_STATE_PRE] then
			_firstPickTimer[1] = RandomInt(min, max);
			_firstPickTimer[2] = -129;
			_lastPickTimer[1] = RandomInt(min, max);
			_lastPickTimer[2] = -129;
			_cmaiState = _cmaiStates[_CMAI_STATE_CAPTAIN];
		end
		if GetHeroPickState() ~= _lastState then
			_lastState = GetHeroPickState();
		end
		if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
			_CMAI.PickCaptain();
			if _cmaiState == _cmaiStates[_CMAI_STATE_CAPTAIN] and DotaTime() > -1 then 
					_cmaiState = _cmaiStates[_CMAI_STATE_DRAFT] end
		elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
			_CMAI.SelectHeroes();
			_cmaiState = _cmaiStates[_CMAI_STATE_POST];
		end
		if _cmaiState == _cmaiStates[_CMAI_STATE_DRAFT] then
			_CMAI.ValidateDrafts(radiantDraft, direDraft, logRadiant, logDire);
			_cmaiState = _cmaiStates[_CMAI_STATE_PICK];
		end
		if _lastState ~= HEROPICK_STATE_CM_CAPTAINPICK and _lastState ~= HEROPICK_STATE_CM_PICK then
			_timeRemaining = GetCMPhaseTimeRemaining();
			if _cmaiState == _cmaiStates[_CMAI_STATE_PICK] then
				local pickState = _firstPickStates[_lastState] == 0 and _lastPickStates[_lastState] or _firstPickStates[_lastState];
				local pickTimer = _firstPickStates[_lastState] == 0 and _lastPickTimer or _firstPickTimer;

				if pickState ~= 0 then
					if GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN14 and _timeRemaining <= pickTimer[1] then
						_CMAI.BanHero();
						if _timeRemaining < 0 then
							pickTimer[2] = pickTimer[2] - _timeRemaining;
						end
						pickTimer[1] = RandomInt(min, max);
					elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and _timeRemaining <= pickTimer[1] then
						_CMAI.PickHero();
						_CMAI.UpdatePickedHero();
						if _timeRemaining < 0 then
							pickTimer[2] = pickTimer[2] - _timeRemaining;
						end
						pickTimer[1] = RandomInt(min, max);
					end
				end 
			end
		end
	else
		think();
	end
end

-- ensures the draft input given, if any, is readable; otherwise, set draft data to default
function _CMAI.ValidateDrafts(radiantDraft, direDraft, logRadiant, logDire)	
	local draft
	local team = GetTeam() == TEAM_RADIANT and "RADIANT" or "DIRE";
	local log = GetTeam() == TEAM_RADIANT 
		and (logRadiant and (_UTILS.HasHumanPlayer() and GetOpposingTeam() == TEAM_DIRE) or 
		(logRadiant and (not _UTILS.HasHumanPlayer() and GetOpposingTeam() == TEAM_DIRE))) 
		or (logDire and (_UTILS.HasHumanPlayer() and GetOpposingTeam() == TEAM_RADIANT) or 
		(logDire and (not _UTILS.HasHumanPlayer() and GetOpposingTeam() == TEAM_RADIANT)));
	if GetTeam() == TEAM_RADIANT then draft = radiantDraft end
	if GetTeam() == TEAM_DIRE then draft = direDraft end
	draft = draft or _UTILS.GetShuffledTable(_defaultDraft);
	for k,v in pairs(draft) do
		if v ~= 'safe' and v ~= 'mid' and v ~= 'off' and v ~= 'soft' and v ~= 'hard' and #draft ~= 5 then goto a end
		_pickOrder[k] = v;
		if log then print("\n>>" .. team .. " DRAFT[" .. k .. "] = " .. v) end
	end
	goto b
	::a::
	draft = _UTILS.GetShuffledTable(_defaultDraft);
	for k,v in pairs(draft) do
		_pickOrder[k] = v;
		if log then print("\n>>" .. team .. " DRAFT[" .. k .. "] = " .. v) end
	end
	::b::
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
			for n,x in pairs(_pickedHeroes) do
				if v == x then goto a end
			end
			table.insert(_pickedHeroes, v);
			_heroRoles[v] = _pickOrder[#_pickedHeroes];
		end
		::a::
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
		local bots = {}
		local players = GetTeamPlayers(GetTeam());
		local hero = "";

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

			if _heroRoles[unit] == "safe" or  _heroRoles[unit] == "hard" then _heroLanes[i] = GetTeam() == TEAM_RADIANT and LANE_BOT or LANE_TOP end
			if _heroRoles[unit] == "off" or _heroRoles[unit] == "soft" then _heroLanes[i] = GetTeam() == TEAM_RADIANT and LANE_TOP or LANE_BOT end
			if _heroRoles[unit] == "mid" then _heroLanes[i] = LANE_MID end
		end
	end
	return _heroLanes
end
--
--
return _CMAI