local map = {_TYPE='module', _NAME='map', _VERSION='0.1'}
local map_meta = {}

local tiled_loader = require("tiled_loader")

function map:new()
  --Make map
  local m = {canvas=nil, tiles={}, tileimages={}, colliders={}, tubes={}, type="map"}

  --Metatable stuff
  return setmetatable(m, map_meta)
end

function map.load_tileset(self, data)
  local img = love.graphics.newImage("assets/"..data.image)
  self.tileimages[data.image] = img

  local img_w = data.imagewidth
  local img_h = data.imageheight
  local spacing = data.spacing
  local tile_w = data.tilewidth
  local tile_h = data.tileheight

  for i=0, (img_w / tile_w) * (img_h / tile_h) do
    local x = i%(img_w/tile_w)*tile_w
    local y = math.floor(i/(img_h/tile_h))*tile_h
    local cur_tile = love.graphics.newQuad(x,y, tile_w,tile_h, img_w, img_h)
    self.tiles[data.firstgid + i] = {source=data.image, quad=cur_tile, w=tile_w, h=tile_h}
  end
  --local tileset = {img=img, tiles=tiles}
  --self.tilesets[data.name] = tileset
end

function isPipe(id)
  return left == 66 or left == 67 or left == 80 or left == 81 or left == 82 or left == 83 or left == 96 or left == 97 or left == 98 or left == 99
end

function map.load_map(self, path)
  --local data = tiled_loader.load_json("assets/"..path..".json")
  local data = require("assets."..path)
  self.canvas = love.graphics.newCanvas(data.width * data.tilewidth, data.height * data.tileheight)
  for i=1, #data.tilesets do
    local cur_ts = data.tilesets[i]
    self:load_tileset(cur_ts)
  end
  for l=1, #data.layers do
    local hasCol = true
    local isTubeEntrance = false
    local tubeLayerIndex = -1
    if data.layers[l].name == "NoCollision" or data.layers[l].name == "Foreground" then
      hasCol = false
    end
    if data.layers[l].name == "TubeEntrance" then
      isTubeEntrance = true
      for l2=1, #data.layers do
        if data.layers[l2].name == "Tubes" then
          tubeLayerIndex = l2
        end
      end
      self.tubeTiles = data.layers[tubeLayerIndex].data
    end
    local tiles = data.layers[l].data
    love.graphics.push()
    love.graphics.setCanvas(self.canvas)
    for i=1, #tiles do
      if tiles[i] > 0 then
        local cur_tile = self.tiles[tiles[i]]
        local x = (i%data.layers[l].height - 1)*cur_tile.h
        local y = math.floor(i/data.layers[l].width)*cur_tile.w
        if isTubeEntrance then
          local tube = {x=x, y=y}
          local left = self.tubeTiles[i-1]
          local right = self.tubeTiles[i+1]
          local up = self.tubeTiles[i-data.layers[l].width]
          local down = self.tubeTiles[i+data.layers[l].height]
          if isPipe(left) then
            tube.child = left
          elseif isPipe(right) then
            tube.child = right
          elseif isPipe(up) then
            tube.child = up
          elseif isPipe(down) then
            tube.child = down
          end
          table.insert(self.tubes, tube)
        else
          love.graphics.draw(self.tileimages[cur_tile.source], cur_tile.quad, x, y)
          if hasCol then
            --table.insert(self.colliders, {x=x+cur_tile.w,y=y+cur_tile.h/2, w=1, h=cur_tile.h/2, nx=-1, ny=0})
            --table.insert(self.colliders, {x=x,y=y+cur_tile.h, w=1, h=cur_tile.h/2, nx=1, ny=0})
            --table.insert(self.colliders, {x=x,y=y+cur_tile.h, w=cur_tile.w, h=1, nx=0, ny=-1})
            --table.insert(self.colliders, {x=x,y=y, w=cur_tile.w, h=1, nx=0, ny=1})
            local body = love.physics.newBody(world, x+cur_tile.w/2, y+cur_tile.h/2, "static")
            local shape = love.physics.newRectangleShape(cur_tile.w, cur_tile.h)
            local fixture = love.physics.newFixture(body, shape, 1)
            table.insert(self.colliders, {body=body, shape=shape, fixture=fixture})
          end
        end
      end
    end
    --for i=1, #self.tiles do
    --  local cur_tile = self.tiles[i]
    --  love.graphics.draw(self.tileimages[cur_tile.source], cur_tile.quad, math.floor(i/32)*32, (i%33)*32)
    --end
    love.graphics.setCanvas()
    love.graphics.pop()
  end
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
