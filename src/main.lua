local map = require("classes.map")
local player = require("classes.player")

love.physics.setMeter(32)
world = love.physics.newWorld(0, 15*32, true)

love.graphics.setDefaultFilter("nearest", "nearest", 0)

local state = "intro1"
local intro_frame = 0
local intro1 = love.graphics.newImage("assets/start1.png") --512x288
local intro1_quads = {}
for i=0, 28 do
  table.insert(intro1_quads, love.graphics.newQuad(i*512, 0, 512, 288, 29*512, 288))
end

local intro2 = love.graphics.newImage("assets/start2.png")
local intro2_quads = {}
for i=0, 22 do
  table.insert(intro2_quads, love.graphics.newQuad(i*512, 0, 512, 288, 23*512, 288))
end

local intro3 = love.graphics.newImage("assets/start2.2.png")
local intro3_quads = {}
for i=0, 22 do
  table.insert(intro3_quads, love.graphics.newQuad(i*512, 0, 512, 288, 23*512, 288))
end

local intro4 = love.graphics.newImage("assets/start2.3.png")
local intro4_quads = {}
for i=0, 14 do
  table.insert(intro4_quads, love.graphics.newQuad(i*512, 0, 512, 288, 15*512, 288))
end

local m = map:new()
local p = player:new(2*32, 2*32)

local cam = {pos = {x = 0, y = 0}}

--Timer
local total_time = 0
local fixed_delta_time = 1/60

function love.load()
  --Generate map
  --map:load_tileset("yeetyeet")
  m:load_map("yaesteas")
  p.spawn_x = 2*32
  p.spawn_y = 8*32
  p.level = 1
  p.body:setPosition(p.spawn_x, p.spawn_y)
end

function lerp(a,b,t)
  return a + t * (b - a)
end

function love.update(dt)
  --cam.pos.x = p.body:getX() - love.graphics.getWidth()/4
  if state == "platforming" then
    cam.pos.x = math.max(lerp(cam.pos.x, p.body:getX() - love.graphics.getWidth()/4, dt * 3.0), 0)
    cam.pos.y = math.max(lerp(cam.pos.y, p.body:getY() - love.graphics.getHeight()/4, dt * 3.0), 0)
  end
  total_time = total_time + dt
  while total_time > fixed_delta_time do
    fixed_update()
    total_time = total_time - fixed_delta_time
  end
end

function fixed_update()
  if state == "intro1" then
    local speed = 8
    if math.floor(intro_frame)+1 == 7 or math.floor(intro_frame)+1 == 13 or math.floor(intro_frame)+1 == 20 then
      speed = 0.5
    end
    intro_frame = intro_frame + fixed_delta_time * speed
    if math.floor(intro_frame)+1 == #intro1_quads then
      intro_frame = 0
      state = "intro2"
    end
  elseif state == "intro2" then
    local speed = 8
    intro_frame = intro_frame + fixed_delta_time * speed
    if math.floor(intro_frame)+1 == #intro2_quads then
      intro_frame = 0
      state = "intro3"
    end
  elseif state == "intro3" then
    local speed = 8
    intro_frame = intro_frame + fixed_delta_time * speed
    if math.floor(intro_frame)+1 == #intro3_quads then
      intro_frame = 0
      state = "intro4"
    end
  elseif state == "intro4" then
    local speed = 8
    intro_frame = intro_frame + fixed_delta_time * speed
    if math.floor(intro_frame)+1 == #intro4_quads then
      intro_frame = 0
      state = "platforming"
    end
  elseif state == "platforming" then
    world:update(fixed_delta_time)

    if love.keyboard.isDown("d") then
      p:moveRight(fixed_delta_time, m)
    end
    if love.keyboard.isDown("a") then
      p:moveLeft(fixed_delta_time, m)
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("space") then
      p:jump(fixed_delta_time)
    end

    p:update(fixed_delta_time, m)
    for i=1, #m.enemies do
      m.enemies[i]:update(fixed_delta_time, m)
    end
  elseif state == "jarno" then
    --beun je update code hier neer
  end
end

function love.draw()
  if state == "intro1" then
    local q = math.floor(intro_frame)+1
    love.graphics.draw(intro1, intro1_quads[q], 0,0)
  elseif state == "intro2" then
    local q = math.floor(intro_frame)+1
    love.graphics.draw(intro2, intro2_quads[q], 0,0)
  elseif state == "intro3" then
    local q = math.floor(intro_frame)+1
    love.graphics.draw(intro3, intro3_quads[q], 0,0)
  elseif state == "intro4" then
    local q = math.floor(intro_frame)+1
    love.graphics.draw(intro4, intro4_quads[q], 0,0)
  elseif state == "platforming" then
    love.graphics.setColor(1,1,1,1)
    love.graphics.push()
    love.graphics.scale(2)
    love.graphics.translate(-cam.pos.x, -cam.pos.y)
    love.graphics.draw(m.canvas)
    p:draw()
    for i=1, #m.enemies do
      m.enemies[i]:draw()
    end
    love.graphics.pop()
  elseif state == "jarno" then
    --beun je teken code hier neer
  end
  --love.graphics.print(tostring(math.floor(intro_frame)+1))
  --love.graphics.print(state)
end
