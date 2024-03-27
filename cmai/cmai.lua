--
--      CAPTAIN'S MODE A.I. (CMAI)
--
--          cmai.lua
--

-- requires
local Roles = require(GetScriptDirectory() .. "\\cmai\\roles");
local Utils = require(GetScriptDirectory() .. "\\cmai\\utils");

-- initialization
local X = {}

-- init tables
local tPickedHeroes = {}
local tFirstPickTimer = {}
local tLastPickTimer = {}
local tPickOrder = {}
local tHeroRoles = {}
local tHeroLanes = {}

-- init vars
local iLastState;
local iTimeRemaining;
local iFirstPickState;
local iLastPickState;

-- dec tables
local tFirstPickStates = 
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
local tLastPickStates = 
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
local iCMState = -1;
local iPickCycle = 1;

-- returns the current lane assignments; CRITICAL FUNCTION! SEE 'hero_selection.lua' FOR USAGE!
function X.GetLaneAssignments(lanes)
	if GetGameMode() == GAMEMODE_CM then
		return X.CMLaneAssignment()
	else
		return lanes()
	end
end

-- returns a random hero based on draft that has not been picked or banned to pick
function X.GetNHeroPick()
	local hero = "";
	while (
        hero == ""
        or IsCMPickedHero(GetTeam(), hero) 
        or IsCMPickedHero(GetOpposingTeam(), hero) 
        or IsCMBannedHero(hero)
	) do
        hero = Roles[tPickOrder[iPickCycle]][RandomInt(1, #Roles[tPickOrder[iPickCycle]])];
	end
	return hero
end

-- returns a random hero based on draft that has not been picked or banned to ban
function X.GetNHeroBan()
	local pool = {};
	for k,v in pairs(tPickOrder) do
		if k < iPickCycle then goto skip end
		for i,n in pairs(X.GetNRoleHeroes(v)) do
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
function X.GetNRoleHeroes(role)
    local pool = {}
	if role ~= "safe" and role ~= "mid" and role ~= "off" and role ~= "soft" and role ~= "hard" then return end
	for k,v in pairs(Roles[role]) do
		table.insert(pool, v);
	end
    return pool
end

-- main function where all logic is executed; CRITICAL FUNCTION! SEE 'hero_selection.lua' FOR USAGE!
function X.CMThink(min, max, think, draft)
	if GetGameMode() == GAMEMODE_CM then
		if (GetGameState() ~= GAME_STATE_HERO_SELECTION) then return end
		if iCMState < 0 then
			tFirstPickTimer[1] = RandomInt(min, max); -- thinkTime
			tFirstPickTimer[2] = -129; -- reserveTime
			tLastPickTimer[1] = RandomInt(min, max); -- thinkTime
			tLastPickTimer[2] = -129; -- reserveTime
			X.ValidateDraft(draft);
			iCMState = 0;
		end
		if GetHeroPickState() ~= iLastState then
			iLastState = GetHeroPickState();
		end
		if GetHeroPickState() == HEROPICK_STATE_CM_CAPTAINPICK then
			X.PickCaptain();
		elseif GetHeroPickState() == HEROPICK_STATE_CM_PICK then
			iCMState = 1;
			X.SelectHeroes();
		end
		if iLastState ~= HEROPICK_STATE_CM_CAPTAINPICK and iLastState ~= HEROPICK_STATE_CM_PICK then
			iTimeRemaining = GetCMPhaseTimeRemaining();
			if iCMState == 0 then
				iFirstPickState = tFirstPickStates[iLastState];
				iLastPickState = tLastPickStates[iLastState];
				if iFirstPickState ~= 0 then
					if GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN14 and iTimeRemaining <= tFirstPickTimer[1] then
						X.BanHero();
						if iTimeRemaining < 0 then
							tFirstPickTimer[2] = tFirstPickTimer[2] - iTimeRemaining;
						end
						tFirstPickTimer[1] = RandomInt(min, max);
					elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and iTimeRemaining <= tFirstPickTimer[1] then
						X.PickHero();
						X.UpdatePickedHero();
						if iTimeRemaining < 0 then
							tFirstPickTimer[2] = tFirstPickTimer[2] - iTimeRemaining;
						end
						tFirstPickTimer[1] = RandomInt(min, max);
					end
				elseif iLastPickState ~= 0 then
					if GetHeroPickState() >= HEROPICK_STATE_CM_BAN1 and GetHeroPickState() <= HEROPICK_STATE_CM_BAN14 and iTimeRemaining <= tLastPickTimer[1] then
						X.BanHero();
						if iTimeRemaining < 0 then
							tLastPickTimer[2] = tLastPickTimer[2] - iTimeRemaining;
						end
						tLastPickTimer[1] = RandomInt(min, max);
					elseif GetHeroPickState() >= HEROPICK_STATE_CM_SELECT1 and GetHeroPickState() <= HEROPICK_STATE_CM_SELECT10 and iTimeRemaining <= tLastPickTimer[1] then
						X.PickHero();
						X.UpdatePickedHero();
						if iTimeRemaining < 0 then
							tLastPickTimer[2] = tLastPickTimer[2] - iTimeRemaining;
						end
						tLastPickTimer[1] = RandomInt(min, max);
					end
				end
			end
		end
	else
		think();
	end
end

-- ensures the draft input given, if any, is readable; otherwise, set draft data to default
function X.ValidateDraft(draft)
	local defdraft = {'hard','off','soft','mid','safe'}

	draft = draft or defdraft;
	for k,v in pairs(draft) do
		if v ~= 'safe' and v ~= 'mid' and v ~= 'off' and v ~= 'soft' and v ~= 'hard' then
			draft = defdraft;
			for k,v in pairs(draft) do
				tPickOrder[k] = v;
			end
			goto setpicks
		end
		tPickOrder[k] = v;
	end
	::setpicks::
end

-- picks a bot as a captain; always picks the first bot as captain
function X.PickCaptain()
	if not Utils.HasHumanPlayer() or DotaTime() > -1 then
		if GetCMCaptain() == -1 then
			local bot = Utils.GetFirstBot();

			if bot ~= nil then
				SetCMCaptain(bot);
			end
		end
	end
end

-- updates the the list of picked heroes when a hero is picked
function X.UpdatePickedHero()
	for k,v in pairs(Roles["heroes"]) do
		if IsCMPickedHero(GetTeam(), v) then
			for i,n in pairs(tPickedHeroes) do
				if v == n then goto g end
			end
			table.insert(tPickedHeroes, v);
			tHeroRoles[v] = tPickOrder[#tPickedHeroes];
		end
		::g::
	end
end

-- updates the list of picked heroes when a human player selects a hero
function X.UpdateSelectedHeroes(hero)
	for i = 1, #tPickedHeroes do
		if tPickedHeroes[i] == hero then
			table.remove(tPickedHeroes, i);
		end
	end
end

-- make bots select heroes once human players have selected
function X.SelectHeroes()
    local selecting = true;
	if selecting and (not Utils.IsHumanPlayerSelecting() or GetCMPhaseTimeRemaining() < 1) then
		local players = GetTeamPlayers(GetTeam());
		local hero = "";
		local bots = {}

		for k,v in pairs(players) do
			hero = GetSelectedHeroName(v);
			if hero ~= nil and hero ~= "" then
				X.UpdateSelectedHeroes(hero);
			else
				table.insert(bots, v);
			end
		end
		for i = 1, #bots do
			SelectHero(bots[i], tPickedHeroes[i]);
		end
		selecting = false;
	end
end

-- make bot pick a hero
function X.PickHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then return end
	local hero = X.GetNHeroPick();

	CMPickHero(hero);
	iPickCycle = iPickCycle + 1;
end

-- make bot ban a hero
function X.BanHero()
	if not IsPlayerBot(GetCMCaptain()) or not IsPlayerInHeroSelectionControl(GetCMCaptain()) then return end
	local hero = X.GetNHeroBan();

	CMBanHero(hero);
end

-- assign bots to lanes based on roles
function X.CMLaneAssignment()
	local players = GetTeamPlayers(GetTeam());
    
	for i = 1, #players do
		local member = GetTeamMember(i);

		if member ~= nil and member:IsHero() then
            local unit = member:GetUnitName();

			if tHeroRoles[unit] == "safe" then
				if GetTeam() == TEAM_RADIANT then
					tHeroLanes[i] = LANE_BOT;
				else
					tHeroLanes[i] = LANE_TOP;
				end
			elseif tHeroRoles[unit] == "mid" then
				tHeroLanes[i] = LANE_MID;
			elseif tHeroRoles[unit] == "off" then
				if GetTeam() == TEAM_RADIANT then
					tHeroLanes[i] = LANE_TOP;
				else
					tHeroLanes[i] = LANE_BOT;
				end
			elseif tHeroRoles[unit] == "soft" then
				if GetTeam() == TEAM_RADIANT then
					tHeroLanes[i] = LANE_TOP;
				else
					tHeroLanes[i] = LANE_BOT;
				end
			elseif tHeroRoles[unit] == "hard" then
				if GetTeam() == TEAM_RADIANT then
					tHeroLanes[i] = LANE_BOT;
				else
					tHeroLanes[i] = LANE_TOP;
				end
			end
		end
	end
	return tHeroLanes
end 
--
--
return X