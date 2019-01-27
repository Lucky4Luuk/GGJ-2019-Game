local player = {_TYPE='module', _NAME='player', _VERSION='0.1'}
local player_meta = {}

local tiled_loader = require("tiled_loader")

function player:new(x,y)
  --Make player
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setFixedRotation(true)
  local shape = love.physics.newRectangleShape(-5, 0, 16, 16)
  local fixture = love.physics.newFixture(body, shape, 1)
  local p = {w=8, h=8, isDead=false, victory=false, bossfight=false, body=body, shape=shape, fixture=fixture, speed=500, jumpForce=16000, inTube=false, grounded=false, wallRight=false, wallLeft=false, type="player", sprites={idle={}, walking={}, walking_source=nil, idle_source=nil, walking_speed=10, idle_speed=1}, frame_counter=0, anim="idle", movingRight}

  p.sprites.walking_source = love.graphics.newImage("assets/bit_walking.png")
  for i=0, 7 do
    local quad = love.graphics.newQuad(i*32, 0, 32, 32, 320, 32)
    table.insert(p.sprites.walking, quad)
  end

  p.sprites.idle_source = love.graphics.newImage("assets/bit_idle.png")
  for i=0, 5 do
    local quad = love.graphics.newQuad(i*32, 0, 32, 32, 6*32, 32)
    table.insert(p.sprites.idle, quad)
  end

  p.sprites.in_pipe = love.graphics.newImage("assets/boop_pipe.png")

  p.pipe_timer = 0

  --Metatable stuff
  return setmetatable(p, player_meta)
end

function player.enter_tube(self, tube)
  if tube.x and tube.y then
    self.body:setX(tube.x + 16)
    self.body:setY(tube.y + 16)
    self.inTube = true
    self.prev_tube = self.tube
    self.tube = tube
  else
    --Reached the end lol
    --shitty code ftw
    print(self.prev_tube.id)
    if self.prev_tube.id == 82 then
      self.body:setX(self.body:getX() + 32)
      self.inTube = false
      self.prev_tube = nil
      self.tube = nil
    elseif self.prev_tube.id == 98 then
      self.body:setX(self.body:getX() - 32)
      self.inTube = false
      self.prev_tube = nil
      self.tube = nil
    elseif self.prev_tube.id == 81 then
      self.body:setY(self.body:getY() - 32)
      self.inTube = false
      self.prev_tube = nil
      self.tube = nil
    elseif self.prev_tube.id == 97 then
      self.body:setY(self.body:getY() + 32)
      self.inTube = false
      self.prev_tube = nil
      self.tube = nil
    end
  end
end

function lerp(a,b,t)
  return a + t * (b - a)
end

function player.update(self, dt, map)
  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(vx*0.95, vy)
  if not (love.keyboard.isDown("a") or love.keyboard.isDown("d")) then
    self.anim = "idle"
  end
  if self.anim == "idle" then
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
    if self.body:isTouching(map.spikes[i].body) then
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

function player.death (self)
  if self.isDead == true then
    self:setPosition(2*32,2*32)
  end
end

function player.moveRight(self, dt, map)
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

function player.moveLeft(self, dt, map)
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

function player.jump(self, dt)
  local vx, vy = self.body:getLinearVelocity()
  if vy == 0 then
    self.body:applyForce(0, -self.jumpForce * dt * 15)
    self.grounded = false
  end
end

function player.draw(self)
  love.graphics.setColor(1,1,1,1)
  if self.inTube then
    love.graphics.draw(self.sprites.in_pipe, self.body:getX() - 7, self.body:getY() - 20)
  elseif self.anim == "idle" then
    love.graphics.draw(self.sprites.idle_source, self.sprites.idle[math.floor(self.frame_counter)+1], self.body:getX() - 7, self.body:getY() - 24, 0, self.movingRight and 1 or -1, 1, 16, 0, 0, 0)
  elseif self.anim == "walking" then
    love.graphics.draw(self.sprites.walking_source, self.sprites.walking[math.floor(self.frame_counter)+1], self.body:getX() - 7, self.body:getY() - 24, 0, self.movingRight and 1 or -1, 1, 16, 0, 0, 0)
  end
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
