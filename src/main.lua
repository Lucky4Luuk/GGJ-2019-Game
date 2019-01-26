local map = require("classes.map")
local player = require("classes.player")

local state = "jarno"

local m = map:new()
local p = player:new(48, 112)

local cam = {pos = {x = 0, y = 0}}

--Timer
local total_time = 0
local fixed_delta_time = 1/240

function love.load()
  --Generate map
  --map:load_tileset("yeetyeet")
  m:load_map("512x512")
end

function love.update(dt)
  total_time = total_time + dt
  while total_time > fixed_delta_time do
    fixed_update()
    total_time = total_time - fixed_delta_time
  end
end

function checkCollision(a, b)
  if a.x+a.w < b.x-b.w or a.x-a.w > b.x+b.w then return false end
  if a.y+a.h < b.y-b.h or a.y-a.h > b.y+b.h then return false end
  return true
end

function fixed_update()
  if state == "platforming" then
    p:update(fixed_delta_time)
    for i=1, #m.colliders do
      local col = m.colliders[i]
      if checkCollision(p, col) then
        local dx = col.x - p.x
        local dy = col.y - p.y
        local nx = 0
        local ny = 0
        if dx > 16 then
          nx = 1
        elseif dx < -16 then
          nx = -1
        end
        if dy > 16 then
          ny = 1
        elseif dy < -16 then
          ny = -1
        end
        print(nx, ny, dx, dy)
        p:applyCollision(nx, ny, dx, dy - p.h*2.5)
        p.grounded = true
      end
    end

    if love.keyboard.isDown("d") then
      p:moveRight(fixed_delta_time)
    end
    if love.keyboard.isDown("a") then
      p:moveLeft(fixed_delta_time)
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("space") then
      p:jump(fixed_delta_time)
    end
  elseif state == "jarno" then
    --beun je update code hier neer
  end
end

function love.draw()
  if state == "platforming" then
    love.graphics.setColor(1,1,1,1)
    love.graphics.push()
    love.graphics.translate(-cam.pos.x, -cam.pos.y)
    love.graphics.draw(m.canvas)
    p:draw()
    love.graphics.pop()
  elseif state == "jarno" then
    --beun je teken code hier neer
  end
end
