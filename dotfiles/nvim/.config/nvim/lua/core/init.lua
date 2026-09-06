-- sets.lua first: it sets mapleader, and <leader> in a mapping is resolved at
-- definition time. With remaps.lua first, every <leader> mapping here bound to
-- the default backslash while plugin mappings - loaded later - used space.
require('core.sets')
require('core.remaps')
