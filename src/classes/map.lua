local map = {_TYPE='module', _NAME='map', _VERSION='0.1'}
local map_meta = {}
local enemy = require("classes.enemy")

local tiled_loader = require("tiled_loader")

function map:new()
  --Make map
  local m = {canvas=nil, tiles={}, tileimages={}, colliders={}, tubes={}, spikes={}, victory_tiles={}, enemies={}, type="map"}

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
  return id == 67 or id == 68 or id == 81 or id == 82 or id == 83 or id == 84 or id == 97 or id == 98 or id == 99 or id == 100
end

function map.pipeFindChild(self, i, w,h, cw,ch, prev_dir, prev_id, id)
  if i == prev_id then
    return {id=id}
  end
  local left = self.tubeTiles[i-1]
  local right = self.tubeTiles[i+1]
  local up = self.tubeTiles[i-w]
  local down = self.tubeTiles[i+w]
  local dir = ""
  local type = 0
  if isPipe(left) and prev_dir ~= "right" then
    child_id = i-1
    dir = "left"
    type = left
  elseif isPipe(right) and prev_dir ~= "left" then
    child_id = i+1
    dir = "right"
    type = right
  elseif isPipe(up) and prev_dir ~= "down" then
    child_id = i-w
    dir = "up"
    type = up
  elseif isPipe(down) and prev_dir ~= "up" then
    child_id = i+w
    dir = "down"
    type = down
  end
  local x = (i%h - 1)*ch
  local y = math.floor(i/w)*cw
  local tube = {x=x, y=y, id=type}
  if child_id then
    --print(child_id)
    tube.child = self:pipeFindChild(child_id, w,h, cw,ch, dir, i, type)
  end
  return tube
end

function map.load_map(self, path, p)
  --local data = tiled_loader.load_json("assets/"..path..".json")
  local data = require("assets."..path)
  self.canvas = love.graphics.newCanvas(data.width * data.tilewidth, data.height * data.tileheight)
  for i=1, #data.tilesets do
    local cur_ts = data.tilesets[i]
    self:load_tileset(cur_ts)
  end
  for l=1, #data.layers do
    local hasCol = true
    local isSpikes = false
    local isTubeEntrance = false
    local tubeLayerIndex = -1
    if data.layers[l].name == "NoCollision" or data.layers[l].name == "Foreground" or data.layers[l].name == "Tubes" or data.layers[l].name == "Spikes" or data.layers[l].name == "Victory" or data.layers[l].name == "Spawn" or data.layers[l].name == "Enemies" or data.layers[l].name == "Boss" then
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
    elseif data.layers[l].name == "Spikes" then
      isSpikes = true
    end
    local tiles = data.layers[l].data
    love.graphics.push()
    love.graphics.setCanvas(self.canvas)
    for i=1, #tiles do
      if tiles[i] > 0 then
        local cur_tile = self.tiles[tiles[i]]
        local x = (i%data.layers[l].height - 1)*cur_tile.h
        local y = math.floor(i/data.layers[l].width)*cur_tile.w
        if data.layers[l].name == "Spawn" then
          self.spawn_x = (i%data.layers[l].height - 1)*cur_tile.h
          self.spawn_y = math.floor(i/data.layers[l].width)*cur_tile.w
        elseif data.layers[l].name == "Victory" then
          table.insert(self.victory_tiles, {x=x+16, y=y+16})
        elseif data.layers[l].name == "Enemies" then
          if tiles[i] == 249 then
            --fuckin octo lookin ass
            table.insert(self.enemies, enemy:new(x,y, "octo"))
          end
        elseif data.layers[l].name == "Boss" then
          if tiles[i] == 256 then
            table.insert(self.enemies, enemy:new(x,y, "boss2", true, p))
          end
        end
        if isTubeEntrance then
          --print(tiles[i])
          local tube = self:pipeFindChild(i, data.layers[l].width, data.layers[l].height, cur_tile.w, cur_tile.h, tiles[i], 0)
          local body = love.physics.newBody(world, x+cur_tile.w/2, y+cur_tile.h/2, "static")
          local shape = love.physics.newRectangleShape(cur_tile.w, cur_tile.h)
          local fixture = love.physics.newFixture(body, shape, 1)
          tube.body = body
          tube.shape = shape
          tube.fixture = fixture
          table.insert(self.tubes, tube)
        else
          if data.layers[l].name ~= "Enemies" then
            love.graphics.draw(self.tileimages[cur_tile.source], cur_tile.quad, x, y)
          end
          if hasCol then
            --table.insert(self.colliders, {x=x+cur_tile.w,y=y+cur_tile.h/2, w=1, h=cur_tile.h/2, nx=-1, ny=0})
            --table.insert(self.colliders, {x=x,y=y+cur_tile.h, w=1, h=cur_tile.h/2, nx=1, ny=0})
            --table.insert(self.colliders, {x=x,y=y+cur_tile.h, w=cur_tile.w, h=1, nx=0, ny=-1})
            --table.insert(self.colliders, {x=x,y=y, w=cur_tile.w, h=1, nx=0, ny=1})
            local body = love.physics.newBody(world, x+cur_tile.w/2, y+cur_tile.h/2, "static")
            local shape = love.physics.newRectangleShape(cur_tile.w, cur_tile.h)
            local fixture = love.physics.newFixture(body, shape, 1)
            table.insert(self.colliders, {body=body, shape=shape, fixture=fixture})
          elseif isSpikes then
            local body = love.physics.newBody(world, x+cur_tile.w/2, y+cur_tile.h/2, "static")
            local shape = love.physics.newRectangleShape(cur_tile.w, cur_tile.h)
            local fixture = love.physics.newFixture(body, shape, 1)
            table.insert(self.spikes, {body=body, shape=shape, fixture=fixture})
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
