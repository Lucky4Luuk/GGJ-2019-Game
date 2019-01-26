local player = {_TYPE='module', _NAME='player', _VERSION='0.1'}
local player_meta = {}

local tiled_loader = require("tiled_loader")

function player:new(x,y)
  --Make player
  local p = {x=x, y=y, w=5, h=10, vel_x=0, vel_y=0, drag=0.05, speed=5000, jumpForce=5000, grounded=false, wallRight=false, wallLeft=false, type="player", sprites={}, frame_counter=0}

  --Metatable stuff
  return setmetatable(p, player_meta)
end

function player.applyForce(self, fx, fy)
  self.vel_x = self.vel_x + fx
  self.vel_y = self.vel_y + fy
end

function player.applyCollision(self, nx, ny, dx, dy)
  if nx ~= 0 then
    --self.x = self.x - self.vel_x
    self.vel_x = 0
    if nx > 0 then
      self.wallRight = true
    elseif nx < 0 then
      self.wallLeft = true
    end
    --self.x = self.x + dx
    --self.x = self.x + 0.2 * nx
  end
  if ny ~= 0 then
    --self.y = self.y - self.vel_y
    self.vel_y = 0
    if nx < 0 then
      self.grounded = true
    end
    --self.y = self.y + dy
    --self.y = self.y + 0.2
  end
end

function player.update(self, dt)
  self.x = self.x + self.vel_x * dt
  self.y = self.y + self.vel_y * dt
  self.vel_x = self.vel_x - self.drag * dt
  self.vel_y = self.vel_y - self.drag * dt
  if self.grounded==false then self:applyForce(0, 9.8) end
  self.wallRight = false
  self.wallLeft = false
  self.grounded = false
end

function player.moveRight(self, dt)
  if self.grounded and self.wallRight == false then
    self.vel_x = self.speed * dt
  end
end

function player.moveLeft(self, dt)
  if self.grounded and self.wallLeft == false then
    self.vel_x = -self.speed * dt
  end
end

function player.jump(self, dt)
  if self.grounded then
    --self.y = self.y - 5
    self.vel_y = self.vel_y - self.jumpForce * dt
    self.grounded = false
  end
end

function player.draw(self)
  --TODO: Add sprite + animation support here
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill", self.x-self.w, self.y-self.h, self.w*2, self.h*2)
  love.graphics.setColor(0,1,0,1)
  love.graphics.points(self.x, self.y)
  love.graphics.line(self.x-self.w, self.y+self.h, self.x+self.w, self.y+self.h)
end

setmetatable( player, { __call = function( ... ) return player.new( ... ) end } )

--Print print()
player_meta.__call = function(...)
  return player.print(...)
end

--Indexing
player_meta.__index = {}
for k,v in pairs(player) do
  player_meta.__index[k] = v
end

return player
