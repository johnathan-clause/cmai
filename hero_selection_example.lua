--
--      CAPTAIN'S MODE A.I. (CMAI)
--
--          hero_selection_example.lua
--

--
-- TO USE CMAI, ADD THE FOLLOWING CODE TO THE BOTTOM OF THE 'hero_selection.lua' SCRIPT OF YOUR DESIRED BOT SCRIPT!
--
local CMAI = require(GetScriptDirectory() .. '\\cmai\\cmai');
Think = GetGameMode() == GAMEMODE_CM and CMAI.Think or Think; 
UpdateLaneAssignments = GetGameMode() == GAMEMODE_CM and CMAI.UpdateLaneAssignments or UpdateLaneAssignments;
--
--