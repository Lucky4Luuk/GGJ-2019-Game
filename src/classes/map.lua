local map = {_TYPE='module', _NAME='map', _VERSION='0.1'}
local map_meta = {}

local tiled_loader = require("tiled_loader")

function map:new()
  --Make map
  local m = {levels={}, wires={}, type="map"}

  --Metatable stuff
  return setmetatable(m, map_meta)
end

function map.load(self, path)
  local tiles, layers = tiled_loader.TiledMap_Parse(path..".tmx")
end

function map.get_wires(self) --fucking useless like me
  return self.wires
end

function map.add_wire(self, to, from)
  --return setmetatable(map_result, map_meta)
  table.insert(self.wires, {to=to, from=from})
end

setmetatable( map, { __call = function( ... ) return map.new( ... ) end } )

--Print print()
map_meta.__call = function(...)
  return map.print(...)
end

--Indexing
map_meta.__index = {}
for k,v in pairs(map) do
  map_meta.__index[k] = v
end

return map
