local enemy = {_TYPE='module', _NAME='enemy', _VERSION='0.1'}
local enemy_meta = {}

local tiled_loader = require("tiled_loader")

function enemy:new(x,y, type)
  --Make enemy
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setFixedRotation(true)
  local shape = love.physics.newRectangleShape(-5, 0, 16, 16)
  local fixture = love.physics.newFixture(body, shape, 1)
  local e = {w=8, h=8, isDead=false, body=body, shape=shape, fixture=fixture, speed=150, inTube=false, grounded=false, wallRight=false, wallLeft=false, type="enemy", sprites={idle={}, walking={}, walking_source=nil, idle_source=nil, walking_speed=10, idle_speed=1}, frame_counter=0, anim="idle", movingRight}

  e.sprites.walking_source = love.graphics.newImage("assets/enemies/"..tostring(type).."_walking.png")
  for i=0, 1 do
    local quad = love.graphics.newQuad(i*32, 0, 32, 32, 320, 32)
    table.insert(e.sprites.walking, quad)
  end

  e.sprites.death_source = love.graphics.newImage("assets/enemies/"..tostring(type).."bit_death.png")
  for i=0, 1 do
    local quad = love.graphics.newQuad(i*32, 0, 32, 32, 6*32, 32)
    table.insert(e.sprites.death, quad)
  end

  --Metatable stuff
  return setmetatable(e, enemy_meta)
end

function lerp(a,b,t)
  return a + t * (b - a)
end

function enemy.update(self, dt, map)
  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(vx*0.95, vy)
  if not (love.keyboard.isDown("a") or love.keyboard.isDown("d")) then
    self.anim = "idle"
  end
  if self.anim == "death" then
    self.frame_counter = self.frame_counter + dt * self.sprites.idle_speed
    self.frame_counter = self.frame_counter % #self.sprites.idle
  elseif self.anim == "walking" then
    self.frame_counter = self.frame_counter + dt * self.sprites.walking_speed
    self.frame_counter = self.frame_counter % #self.sprites.walking
  end

  if self.inTube then
    if self.pipe_timer > 0.01 then
      if self.tube.child then
        self:enter_tube(self.tube.child)
      end
      self.pipe_timer = self.pipe_timer - 0.01
    end
    self.pipe_timer = self.pipe_timer + dt
  else
    self.pipe_timer = 0
  end

  for i=1, #map.spikes do
    if self.body:isTouching(map.spikes[i].body) and self.body:getY() < map.spikes[i].body:getY() then
      self.isDead = true
    end
  end

  for i=1, #map.victory_tiles do
    local x = self.body:getX()
    local y = self.body:getY()
    local tx = map.victory_tiles[i].x
    local ty = map.victory_tiles[i].y
    if x+16 > tx-16 and x-16 < tx+16 then
      if y+16 > ty-16 and y-16 < ty+16 then
        self.victory = true
      end
    end
  end
end

function enemy.moveRight(self, dt, map)
  if self.inTube == false then
    self.body:applyForce(self.speed * dt * 20, 0)
    self.movingRight = true
    if not self.grounded then
      self.anim = "walking"
    end

    local vx, vy = self.body:getLinearVelocity()
    if vx == 0 then
      for i=1, #map.tubes do
        local tube = map.tubes[i]
        if self.body:isTouching(tube.body) and tube.x > self.body:getX() then
          self:enter_tube(tube)
        end
      end
    end
  end
end

function enemy.moveLeft(self, dt, map)
  if self.inTube == false then
    self.body:applyForce(-self.speed * dt * 20, 0)
    self.movingRight = false
    if not self.grounded then
      self.anim = "walking"
    end

    local vx, vy = self.body:getLinearVelocity()
    if vx == 0 then
      for i=1, #map.tubes do
        local tube = map.tubes[i]
        if self.body:isTouching(tube.body) and tube.x < self.body:getX() then
          self:enter_tube(tube)
        end
      end
    end
  end
end

function enemy.jump(self, dt)
  local vx, vy = self.body:getLinearVelocity()
  if vy == 0 then
    self.body:applyForce(0, -self.jumpForce * dt * 15)
    self.grounded = false
  end
end

function enemy.draw(self)
  love.graphics.setColor(1,1,1,1)
  if self.inTube then
    love.graphics.draw(self.sprites.in_pipe, self.body:getX() - 7, self.body:getY() - 20)
  elseif self.anim == "idle" then
    love.graphics.draw(self.sprites.idle_source, self.sprites.idle[math.floor(self.frame_counter)+1], self.body:getX() - 7, self.body:getY() - 24, 0, self.movingRight and 1 or -1, 1, 16, 0, 0, 0)
  elseif self.anim == "walking" then
    love.graphics.draw(self.sprites.walking_source, self.sprites.walking[math.floor(self.frame_counter)+1], self.body:getX() - 7, self.body:getY() - 24, 0, self.movingRight and 1 or -1, 1, 16, 0, 0, 0)
  end
end

setmetatable( enemy, { __call = function( ... ) return enemy.new( ... ) end } )

--Print print()
enemy_meta.__call = function(...)
  return enemy.print(...)
end

--Indexing
enemy_meta.__index = {}
for k,v in pairs(enemy) do
  enemy_meta.__index[k] = v
end

return enemy
