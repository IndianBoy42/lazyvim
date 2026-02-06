-- Load core configuration (global O table)
_G.O = require("config.core")
_G.utils = require("utils")

-- Finally, bootstrap LazyVim
require("config.lazy")
