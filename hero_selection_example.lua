--
--      CAPTAIN'S MODE A.I. (CMAI)
--
--          hero_selection_example.lua
--

--
-- TO USE CMAI, REQUIRE THE CMAI SCRIPT AS SHOWN HERE!
--

-- assign the cmai script to a variable so we can use it
local CMAI = require(GetScriptDirectory() .. "\\cmai\\cmai");

--
-- TO USE CMAI, CALL 'CMThink' AS SHOWN HERE!
--

-- preserve the original 'Think' function by renaming it
function _Think()
    -- some logic from the
    -- original 'Think' function
    -- we want to preserve
end

-- the function we will be calling 'CMAI.CMThink' from
function Think()
    -- CMThink ( origThink, minThinkTime, maxThinkTime, logOpponent, radiantDraft, direDraft )
    -- func origThink:      The original think function to be run when not captains mode.
    -- int minThinkTime:    (optional)(default:0) Minimum seconds bot can take to think. 
    -- int maxThinkTime:    (optional)(default:0) Maximum seconds bot can take to think.
    -- bool logOpponent:    (Optional)(default: false) Should client print the opponents draft in the console/chat? 
    -- table radiantDraft:  (Optional)(default: random) If provided, the pick order for roles will be in the given 
    --                      order. Use the strings 'safe','mid','off','soft', and 'hard' to denote roles. (1)(2)
    -- table direDraft:     See radiantDraft.
    -- (1) { firstpick, secondpick, thirdpick, fourthpick, fifthpick }
    -- (2) { 'hard', 'off', 'soft', 'mid', 'safe' }
    
    CMAI.CMThink(_Think);
    -- CMAI.CMThink(_Think, 4, 48, true, {'safe','soft','hard','mid','off'}, {'mid', 'off', 'hard', 'soft', 'safe'};
end

--
-- TO USE CMAI, CALL 'GetLaneAssignments' AS SHOWN HERE!
--

-- preserve the original 'UpdateLaneAssignments' function by renaming it
function _UpdateLaneAssignments()
    -- some logic from the original
    -- 'UpdateLaneAssignments'
    -- function we want to preserve
end

-- the function we will be calling 'CMAI.GetLaneAssignments' from
function UpdateLaneAssignments()
    -- GetLanesAssignments ( origLanes )
    -- origLanes:       The original lane assignment function to be run when not captains mode.
    return CMAI.GetLaneAssignments(_UpdateLaneAssignments)
end

--
-- BOTH 'CMThink' AND 'GetLaneAssignments' MUST BE CALLED WHERE AND HOW THEY ARE STATED TO ACHIEVE FUNCTIONALITY!
-- EVEN THEN, THERE MAY BE CASES WHEN FUNCTIONALITY CANNOT BE ACHIEVED! IN THESE CASES, MORE MODIFICATIONS TO THE
-- BASE CODE MAY BE MADE TO ACHIEVE FUNCTIONALITY, DO SO AT YOUR OWN RISK!
--

--
--