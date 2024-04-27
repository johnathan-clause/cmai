
#  **CAPTAIN'S MODE A.I. (CMAI)**

## WHAT IS CMAI?
CMAI is a lua module for Defense of the Ancients 2 (DotA 2) bot scripts. CMAI gives bots the capability to pick, ban, and select heroes in Captain's Mode.
Users can give custom parameters to alter think time for bots and pick order for drafting.

## USAGE
To use CMAI, add the following code to the bottom of the 'hero_selection.lua' script of your desired bot script!
`
local CMAI = require(GetScriptDirectory() .. '\\cmai\\cmai');
Think = GetGameMode() == GAMEMODE_CM and CMAI.Think or Think; 
UpdateLaneAssignments = GetGameMode() == GAMEMODE_CM and CMAI.UpdateLaneAssignments or UpdateLaneAssignments;
`

## ROLES
Modifying the roles to match those of the bot script you are using CMAI with is highly recommended. Roles can be customized in the '\cmai\roles' lua script.
