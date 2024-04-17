--
--      CMAI CONFIG
--
--          config.lua
--


-- initialization
local _CONFIG = {}

-- minimum seconds bot can take to think
-- default: 0
_CONFIG["MINIMUM_THINK_TIME"] = 0

-- maximum seconds bot can take to think 
-- default: 0
_CONFIG["MAXIMUM_THINK_TIME"] = 0

-- print the opponents draft to the console also
-- default: false
_CONFIG["LOG_OPPONENT_DRAFT"] = false

-- the order in which what roles will be picked for the radiant team
-- e.g. {'mid', 'off', 'safe', 'soft', 'hard'}
-- default: {} (random)
_CONFIG["RADIANT_DRAFT"] = {}

-- the order in which what roles will be picked for the dire team
-- e.g. {'mid', 'off', 'safe', 'soft', 'hard'}
-- default: {} (random)
_CONFIG["DIRE_DRAFT"] = {}
--
--
return _CONFIG