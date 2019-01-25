local map = require("classes.map")

local m = map:new()

--Timer
local total_time = 0
local fixed_delta_time = 1/240

function love.load()
  --Generate map
  map:load("")
end

function love.update(dt)
  total_time = total_time + dt
  while fixed_delta_time > total_time do
    fixed_update()
    total_time = total_time - fixed_delta_time
  end
end

function fixed_update()

end

function love.draw()
  --no
end
