local player = {_TYPE='module', _NAME='player', _VERSION='0.1'}
local player_meta = {}

local tiled_loader = require("tiled_loader")

function player:new(x,y)
  --Make player
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setFixedRotation(true)
  local shape = love.physics.newRectangleShape(-5, 0, 10, 20)
  local fixture = love.physics.newFixture(body, shape, 1)
  local p = {w=5, h=10, body=body, shape=shape, fixture=fixture, speed=500, jumpForce=12000, grounded=false, wallRight=false, wallLeft=false, type="player", sprites={}, frame_counter=0}

  --Metatable stuff
  return setmetatable(p, player_meta)
end

function player.update(self, dt)
  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(vx*0.95, vy)
  --[[
  self.x = self.x + self.vel_x * dt
  self.y = self.y + self.vel_y * dt
  self.vel_x = self.vel_x - self.drag * dt
  self.vel_y = self.vel_y - self.drag * dt
  if self.grounded == false then self:applyForce(0, 9.8) end
  if self.grounded then self.vel_x = self.vel_x * 0.05 end
  self.wallRight = false
  self.wallLeft = false
  self.grounded = false
  ]]--
end

function player.moveRight(self, dt)
  if self.wallRight == false then
    self.body:applyForce(self.speed, 0)
  end
end

function player.moveLeft(self, dt)
  if self.wallLeft == false then
    self.body:applyForce(-self.speed, 0)
  end
end

function player.jump(self, dt)
  --[[
  if self.grounded and not ((love.keyboard.isDown("a") and self.wallLeft) or (love.keyboard.isDown("d") and self.wallRight)) then
    --self.y = self.y - 5
    self.vel_y = self.vel_y - self.jumpForce * dt
    self.grounded = false
    if self.wallRight then
      self.x = self.x - 1
    end
    if self.wallLeft then
      self.x = self.x + 1
    end
  end
  ]]--
  local vx, vy = self.body:getLinearVelocity()
  if vy == 0 then
    self.body:applyForce(0, -self.jumpForce)
    self.grounded = false
  end
end

function player.draw(self)
  --TODO: Add sprite + animation support here
  love.graphics.setColor(1,0,0,1)
  --love.graphics.rectangle("fill", self.body:getX()-self.w, self.body:getY()-self.h, self.w*2, self.h*2)
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
  love.graphics.setColor(0,1,0,1)
  love.graphics.points(self.body:getX(), self.body:getY())
  love.graphics.line(self.body:getX()-self.w, self.body:getY()+self.h, self.body:getX()+self.w, self.body:getY()+self.h)
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
