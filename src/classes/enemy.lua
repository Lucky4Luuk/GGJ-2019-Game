local enemy = {_TYPE='module', _NAME='enemy', _VERSION='0.1'}
local enemy_meta = {}

local tiled_loader = require("tiled_loader")

function enemy:new(x,y, type, isBoss, player)
  --Make enemy
  local body = love.physics.newBody(world, x, y, "dynamic")
  body:setFixedRotation(true)
  local shape = love.physics.newRectangleShape(-5, 0, 16, 16)
  local fixture = love.physics.newFixture(body, shape, 1)
  local e = {w=8, h=8, isDead=false, body=body, shape=shape, fixture=fixture, speed=150, grounded=false, wallRight=false, wallLeft=false, type="enemy", sprites={death={}, walking={}, walking_source=nil, death_source=nil, walking_speed=10, death_speed=1}, frame_counter=0, anim="walking", movingRight}

  if not isBoss then
    e.sprites.walking_source = love.graphics.newImage("assets/enemies/"..tostring(type).."_walking.png")
    for i=0, 1 do
      local quad = love.graphics.newQuad(i*32, 0, 32, 32, 64, 32)
      table.insert(e.sprites.walking, quad)
    end

    e.sprites.death_source = love.graphics.newImage("assets/enemies/"..tostring(type).."_death.png")
    for i=0, 2 do
      local quad = love.graphics.newQuad(i*32, 0, 32, 32, 64, 32)
      table.insert(e.sprites.death, quad)
    end
  end

  if isBoss then
    e.isBoss = true
    e.player = player
    e.sprite = love.graphics.newImage("assets/enemies/boss2.png")
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

  if isBoss then
    local nx = self.body:getX() - self.player.body:getX()
    local ny = self.body:getY() - self.player.body:getY()
    local nl = math.sqrt(nx*nx + ny*ny)
    self.body:addForce(nx/nl, ny/nl)
  else
    if self.anim == "death" then
      self.frame_counter = self.frame_counter + dt * self.sprites.death_speed
      self.frame_counter = self.frame_counter % #self.sprites.death
    elseif self.anim == "walking" then
      self.frame_counter = self.frame_counter + dt * self.sprites.walking_speed
      self.frame_counter = self.frame_counter % #self.sprites.walking
    end
    
    if self.movingRight then
      self:moveRight(dt)
      if vx == 0 then
        self.movingRight = false
        self:moveLeft(dt)
        self:moveLeft(dt)
      end
    else
      self:moveLeft(dt)
      if vx == 0 then
        self.movingRight = true
        self:moveRight(dt)
        self:moveRight(dt)
      end
    end

    for i=1, #map.spikes do
      if self.body:isTouching(map.spikes[i].body) and self.body:getY() < map.spikes[i].body:getY() then
        self.isDead = true
      end
    end
  end
end

function enemy.moveRight(self, dt)
  self.body:applyForce(self.speed * dt * 20, 0)
  if not self.grounded then
    self.anim = "walking"
  end
end

function enemy.moveLeft(self, dt)
  self.body:applyForce(-self.speed * dt * 20, 0)
  if not self.grounded then
    self.anim = "walking"
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
  if self.isBoss then
    love.graphics.draw(self.sprite, self.body:getX() - 7, self.body:getY() - 24)
  else
    if self.anim == "idle" then
      love.graphics.draw(self.sprites.idle_source, self.sprites.idle[math.floor(self.frame_counter)+1], self.body:getX() - 7, self.body:getY() - 24, 0, self.movingRight and 1 or -1, 1, 16, 0, 0, 0)
    elseif self.anim == "walking" then
      love.graphics.draw(self.sprites.walking_source, self.sprites.walking[math.floor(self.frame_counter)+1], self.body:getX() - 7, self.body:getY() - 24, 0, self.movingRight and 1 or -1, 1, 16, 0, 0, 0)
    end
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
