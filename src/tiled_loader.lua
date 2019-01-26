local json = require("json")

local lib = {}

function lib.load_json(path)
  return json.decode(love.filesystem.read(path))
end

return lib
