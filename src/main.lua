local map = require("classes.map")
local player = require("classes.player")

love.physics.setMeter(32)
world = love.physics.newWorld(0, 15*32, true)
enemy = {
  x = 480,
  y = 480,
  speed = 100,
  size = 15,
  a = 125
}
local state = "platforming"

love.graphics.setDefaultFilter("nearest", "nearest", 0)

local m = map:new()
local p = player:new(15*32, 16*32)

local cam = {pos = {x = 0, y = 0}}

--Timer
local total_time = 0
local fixed_delta_time = 1/60

function love.load()
  --Generate map
  --map:load_tileset("yeetyeet")
  m:load_map("GameJam_Map3_try_out")
end

function lerp(a,b,t)
  return a + t * (b - a)
end

function love.update(dt)
  --cam.pos.x = p.body:getX() - love.graphics.getWidth()/4
  cam.pos.x = math.max(lerp(cam.pos.x, p.body:getX() - love.graphics.getWidth()/4, dt * 3.0), 0)
  cam.pos.y = math.max(lerp(cam.pos.y, p.body:getY() - love.graphics.getHeight()/4, dt * 3.0), 0)
  total_time = total_time + dt
  while total_time > fixed_delta_time do
    fixed_update()
    total_time = total_time - fixed_delta_time
  end
end

function fixed_update()
  if state == "platforming" then
    world:update(fixed_delta_time)

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
      p:moveRight(fixed_delta_time)
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
      p:moveLeft(fixed_delta_time)
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("space") or love.keyboard.isDown("up") then
      p:jump(fixed_delta_time)
    end

    p:update(fixed_delta_time)
  elseif state == "jarno" then
    --beun je update code hier neer
  end
end

function love.draw()
  if state == "platforming" then
    love.graphics.setColor(1,1,1,1)
    love.graphics.push()
    love.graphics.scale(2)
    love.graphics.translate(-cam.pos.x, -cam.pos.y)
    love.graphics.draw(m.canvas)
    p:draw()
    for i=1, #m.colliders do
      local c = m.colliders[i]
      --love.graphics.line(c.x - c.w, c.y - c.h, c.x + c.w, c.y - c.h)
      --love.graphics.line(c.x - c.w, c.y + c.h, c.x - c.w, c.y - c.h)
      --love.graphics.line(c.x + c.w, c.y + c.h, c.x + c.w, c.y - c.h)
      --love.graphics.line(c.x - c.w, c.y + c.h, c.x + c.w, c.y + c.h)
      love.graphics.polygon("line", c.body:getWorldPoints(c.shape:getPoints()))
    end
    love.graphics.pop()
    love.graphics.print(tostring(p.grounded))
  elseif state == "jarno" then
    --beun je teken code hier neer
  end
end
