--
--      CAPTAIN'S MODE A.I. (CMAI)
--
--          cmai.lua
--

-- initialization
local _CMAI = {}

-- requires
local UTILS = require(GetScriptDirectory() .. "\\cmai\\utils");

-- init tables
local _pickedHeroes = {}
local _oppPicked = {}
local _bannedHeroes = {}
local _heroSynergy = {}
local _pickTimer = {}
local _pickOrder = {}
local _heroRoles = {}
local _heroLanes = {}

-- init vars
local _lastState;
local _timeRemaining;

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
local _CMAI_STATE_PRE 		= 1;
local _CMAI_STATE_DRAFT 	= 2;
local _CMAI_STATE_CAPTAIN	= 3;
local _CMAI_STATE_PICK		= 4;
local _CMAI_STATE_POST	 	= 5;
local _cmaiStates = 
{
	[_CMAI_STATE_PRE] 		= 0,
	[_CMAI_STATE_DRAFT] 	= 1,
	[_CMAI_STATE_CAPTAIN]	= 2,
	[_CMAI_STATE_PICK]	 	= 4,
	[_CMAI_STATE_POST] 		= 8,

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

-- adds the hero synergies of the given hero to the hero synergy table
local function UpdateNHeroSynergy(hero)
	for k,v in pairs(UTILS.GetNHeroSynergy(hero)) do
		if _heroSynergy[k] == nil then 
			_heroSynergy[k] = v;
		else
			_heroSynergy[k] = _heroSynergy[k] + v;
		end
	end
end

-- returns a hero with the lowest synergy score, or a random hero, to pick for the current role
local function DraftNHeroPick()
	local hero = "";
	table.sort(_heroSynergy)
	for k,v in pairs(_heroSynergy) do
		if not IsCMPickedHero(GetTeam(), k)
		and not IsCMPickedHero(GetOpposingTeam(), k)
		and not IsCMBannedHero(k) 
		and UTILS.IsHeroNRole(k, _pickOrder[_pickCycle]) 
		and v < 0 then
			return k
		end
	end
	while (
        hero == ""
        or IsCMPickedHero(GetTeam(), hero) 
        or IsCMPickedHero(GetOpposingTeam(), hero) 
        or IsCMBannedHero(hero)
	) do
        hero = UTILS.GetNRoleHeroes(_pickOrder[_pickCycle])[RandomInt(1, #UTILS.GetNRoleHeroes(_pickOrder[_pickCycle]))];
	end
	return hero
end

-- returns a hero with the lowest synergy score, or a random hero, to be banned
local function DraftNHeroBan()
	local hero = "";
	table.sort(_heroSynergy)
	for k,v in pairs(_heroSynergy) do
		if not IsCMPickedHero(GetTeam(), k)
		and not IsCMPickedHero(GetOpposingTeam(), k)
		and not IsCMBannedHero(k) 
		and v < 0 then
			return k
		end
	end
	while (
        hero == ""
        or IsCMPickedHero(GetTeam(), hero) 
        or IsCMPickedHero(GetOpposingTeam(), hero) 
        or IsCMBannedHero(hero)
	) do
        hero = UTILS.GetNRoleHeroes("hero")[RandomInt(1, #UTILS.GetNRoleHeroes("hero"))];
	end
	return hero
end

-- updates the list of picked heroes when a human player selects a hero
local function UpdateSelectedHeroes(hero)
	for i = 1, #_pickedHeroes do
		if _pickedHeroes[i] == hero then
			table.remove(_pickedHeroes, i);
		end
	end
end

-- make bot pick a hero
local function PickHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then return end
	local hero = DraftNHeroPick();

	CMPickHero(hero);
	_pickCycle = _pickCycle + 1;
end

-- make bot ban a hero
local function BanHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then return end
	local hero = DraftNHeroBan();

	CMBanHero(hero);
end

-- make bots select heroes once human players have selected
local function SelectHeroes()
    local selecting = true;
	if selecting and (not UTILS.IsHumanPlayerSelecting() or GetCMPhaseTimeRemaining() < 1) then
		local bots = {}
		local players = GetTeamPlayers(GetTeam());
		local hero = "";
		
		for k,v in pairs(players) do
			hero = GetSelectedHeroName(v);
			if hero ~= nil and hero ~= "" then
				UpdateSelectedHeroes(hero);
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

-- updates the the list of picked heroes when a hero is picked
local function UpdateHeroes()
	for k,v in pairs(UTILS.GetNRoleHeroes('hero')) do
		if IsCMPickedHero(GetTeam(), v) then
			for n,x in pairs(_pickedHeroes) do
				if v == x then goto a end
			end
			table.insert(_pickedHeroes, v);
			UpdateNHeroSynergy(v);
			_heroRoles[v] = _pickOrder[#_pickedHeroes];
		end
		::a::
		if IsCMPickedHero(GetOpposingTeam(), v) then
			for n,x in pairs(_oppPicked) do
				if v == x then goto b end
			end
			table.insert(_oppPicked, v);
			UpdateNHeroSynergy(v);
		end
		::b::
		if IsCMBannedHero(v) then
			for n,x in pairs(_bannedHeroes) do
				if v == x then goto c end
			end
			table.insert(_bannedHeroes, v);
			UpdateNHeroSynergy(v);
		end
		::c::
	end
end

-- ensures the draft input given, if any, is readable; otherwise, set draft data to default
local function ValidateDrafts(radiantDraft, direDraft, logOpponent)	
	local draft
	local roles = {}
	local team = GetTeam() == TEAM_RADIANT and "RADIANT" or "DIRE";
	draft = (((GetTeam() == TEAM_RADIANT and (radiantDraft ~= nil and #radiantDraft == 5)) and radiantDraft) or 
			((GetTeam() == TEAM_DIRE and (direDraft ~= nil and #direDraft == 5)) and direDraft))
				or UTILS.GetShuffledTable(_defaultDraft);
	for k,v in pairs(draft) do
		if (v ~= 'safe' and v ~= 'mid' and v ~= 'off' and v ~= 'soft' and v ~= 'hard') or #draft ~= 5 then goto a end
		for n,x in pairs(roles) do if x == v then goto a end end
		_pickOrder[k] = v;
		roles[k] = v;
	end
	goto b
	::a::
	draft = UTILS.GetShuffledTable(_defaultDraft);
	for k,v in pairs(draft) do
		_pickOrder[k] = v;
	end
	::b::
	if UTILS.HasHumanPlayer() 
		and ((GetTeam() == TEAM_RADIANT and GetOpposingTeam() == TEAM_DIRE) or (GetOpposingTeam() == TEAM_RADIANT and GetTeam() == TEAM_DIRE))  
			or (logOpponent and not UTILS.HasHumanPlayer()) then 
		print('\n>>' .. team .. ' DRAFT:' .. '\n>> 1> ' .. _pickOrder[1] .. '\n>> 2> ' .. _pickOrder[2] .. '\n>> 3> ' .. _pickOrder[3] .. '\n>> 4> ' .. _pickOrder[4] .. '\n>> 5> ' .. _pickOrder[5]) end
end

-- returns the current lane assignments; CRITICAL FUNCTION! SEE 'hero_selection_example.lua' FOR USAGE!
function _CMAI.UpdateLaneAssignments()
	local players = GetTeamPlayers(GetTeam());

	for i = 1, #players do
		local member = GetTeamMember(i);

		if member ~= nil and member:IsHero() then
			local unit = member:GetUnitName();

			if _heroRoles[unit] == "safe" or _heroRoles[unit] == "hard" then _heroLanes[i] = GetTeam() == TEAM_RADIANT and LANE_BOT or LANE_TOP end
			if _heroRoles[unit] == "off" or _heroRoles[unit] == "soft" then _heroLanes[i] = GetTeam() == TEAM_RADIANT and LANE_TOP or LANE_BOT end
			if _heroRoles[unit] == "mid" then _heroLanes[i] = LANE_MID end
		end
	end
	return _heroLanes
end

-- main function where all logic is executed; CRITICAL FUNCTION! SEE 'hero_selection_example.lua' FOR USAGE!
function _CMAI.Think()
	if GetGameState() ~= GAME_STATE_HERO_SELECTION then return end
	local minThink = UTILS.GetNConfig('MINIMUM_THINK_TIME');
	local maxThink = UTILS.GetNConfig('MAXIMUM_THINK_TIME');
	local logOpponent = UTILS.GetNConfig('LOG_OPPONENT_DRAFT');
	local radiantDraft = UTILS.GetNConfig('RADIANT_DRAFT');
	local direDraft = UTILS.GetNConfig('DIRE_DRAFT');

	if _cmaiState == _cmaiStates[_CMAI_STATE_PRE] then
		_pickTimer[1] = minThink and 
			(minThink >= 0 and Clamp(20 - minThink,-130,20) or Clamp(minThink,-130,0)) 
				or 20;
		_pickTimer[2] = maxThink and 
			(maxThink >= 0 and Clamp(20 - maxThink,-130,_pickTimer[1]) or Clamp(maxThink,-130,_pickTimer[1])) 
				or Clamp(20,-130,_pickTimer[1]);
		_pickTimer[3] = RandomInt(_pickTimer[2], _pickTimer[1]);
		_pickTimer[4] = -130;
		_cmaiState = _cmaiStates[_CMAI_STATE_DRAFT];
	end
	if GetHeroPickState() ~= _lastState then
		_lastState = GetHeroPickState();
		if GetHeroPickState() > HEROPICK_STATE_CM_BAN7 and _cmaiState == _cmaiStates[_CMAI_STATE_EARLY_PICK] then
			_pickTimer[1] = minThink and 
				(minThink >= 0 and Clamp(30 - minThink,-130,30) or Clamp(minThink,-130,0)) 
					or 30;
			_pickTimer[2] = maxThink and 
				(maxThink >= 0 and Clamp(30 - maxThink,-130,_pickTimer[1]) or Clamp(maxThink,-130,_pickTimer[1])) 
					or Clamp(30,-130,_pickTimer[1]);
			_pickTimer[3] = Clamp(RandomInt(_pickTimer[2], _pickTimer[1]),_pickTimer[4],160);
			_cmaiState = _cmaiStates[_CMAI_STATE_PICK] 
		end
	end
	if _cmaiState == _cmaiStates[_CMAI_STATE_DRAFT] then
		ValidateDrafts(radiantDraft, direDraft, logOpponent) _cmaiState = _cmaiStates[_CMAI_STATE_CAPTAIN] end
		
	if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK and DotaTime() > -1 then
		if _cmaiState == _cmaiStates[_CMAI_STATE_CAPTAIN] then 		
			UTILS.SetCaptain() _cmaiState = _cmaiStates[_CMAI_STATE_EARLY_PICK] end
	end
	if GetHeroPickState() == HEROPICK_STATE_CM_PICK then
		if _cmaiState == _cmaiStates[_CMAI_STATE_PICK] then
			UpdateHeroes() _cmaiState = _cmaiStates[_CMAI_STATE_POST] end
		SelectHeroes();
		
	end
	if _lastState ~= HEROPICK_STATE_CM_CAPTAINPICK and _lastState ~= HEROPICK_STATE_CM_PICK then
		if (_cmaiState == _cmaiStates[_CMAI_STATE_EARLY_PICK] or _cmaiState == _cmaiStates[_CMAI_STATE_PICK]) then
			local pickState = _firstPickStates[_lastState] == 0 and _lastPickStates[_lastState] or _firstPickStates[_lastState];

			_timeRemaining = GetCMPhaseTimeRemaining();
			if pickState ~= 0 then
				if GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN14 and _timeRemaining <= _pickTimer[3] then
					BanHero();
					if _timeRemaining < 0 then
						_pickTimer[4] = _pickTimer[4] - _timeRemaining;
					end
					_pickTimer[3] = Clamp(RandomInt(_pickTimer[2], _pickTimer[1]),_pickTimer[4],30);
				elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and _timeRemaining <= _pickTimer[3] then
					PickHero();
					UpdateHeroes();
					if _timeRemaining < 0 then
						_pickTimer[4] = _pickTimer[4] - _timeRemaining;
					end
					_pickTimer[3] = Clamp(RandomInt(_pickTimer[2], _pickTimer[1]),_pickTimer[4],30);
				end
			end 
		end
	end
end
--
--
return _CMAI