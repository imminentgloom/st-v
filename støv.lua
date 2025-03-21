--
--
--
--  "støv" is dust
--
--
--
-- ...
-- v1.1 / imminent gloom 
-- 
-- noise into
-- window comparator
--
-- E1: level(K2) or cutoff(K3)
-- E2: shift
-- E3: size

engine.name = "st_v"

-- setup
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local save_on_exit = true

local s = screen
local splash = false
local splash_level = 0

local fps = 15

local cutoff = 1
local shift = 0
local size = 2
local min = -1
local max = 1

-- functions
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function get_min()
   return util.clamp(shift - size, - 1, 1)
end

local function get_max()
   return util.clamp(shift + size, - 1, 1)
end

local function params_init()
   params:add_group("støv", "STØV", 6)

   params:add_option("mode", "E1", {"level", "cutoff"}, 2)
   params:set_action("mode",
      function(val)
         e1_mode = val == 1 and "level" or "cutoff"
      end
   )

   params:add_control("level", "level", controlspec.new(0, 1, "db", 0.01, 0.2))
   params:set_action("level",
      function(val)
         engine.level(val)
      end
   )

   params:add_control("cutoff", "cutoff", controlspec.new(1, 20000, "exp", 1, 20000, "hz"))
   params:set_action("cutoff",
      function(val)
         cutoff = val / 20000
         engine.cutoff(val)
      end
   )

   params:add_control("shift", "shift", controlspec.new(-1, 1, "lin", 0.01, 0))
   params:set_action("shift",
      function(val)
         shift = val
         engine.min(get_min())
         engine.max(get_max())
      end
   )

   params:add_control("size", "size", controlspec.new(0.001, 1, "exp", 0.001, 2))
   params:set_action("size",
      function(val)
         size = val
         engine.min(get_min())
         engine.max(get_max())
      end
   )
   
   params:add_number("fps", "fps", 15, 240, 15)
   params:set_action("fps",
      function(val)
         fps = val         
      end
   )
end

-- clocks
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function draw_event()
   while true do
      redraw()
      clock.sleep(1/fps)
   end
end

local function splash_event()
   splash = true
   splash_level = 15
   while splash_level > 0 do
      clock.sleep(0.1)
      splash_level = splash_level - 1
   end
   splash = false
end

-- init
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function init()
   params_init()
   
   clk_splash = clock.run(splash_event)
   clk_draw = clock.run(draw_event)

   if save_on_exit then params:read(norns.state.data .. "state.pset") end
end

-- norns: keys
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function key(n, z)
   if n == 2 and z == 1 then
      params:set("mode", 1)
   end
   
   if n == 3 and z == 1 then
      params:set("mode", 2)
   end
end

-- norns: encoders
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function enc(n, d)
   if n == 1 then
      if e1_mode == "level" then
         params:delta("level", d)
      else
         params:delta("cutoff", d)
      end
   end

   if n == 2 then
      params:delta("shift", d)
   end
   
   if n == 3 then
      params:delta("size", d)
   end
end

-- norns: drawing
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function redraw()   
   local shift = 64 + math.floor(shift * 64)
   local size = math.floor(size * 64)
   local min = util.clamp(shift - size, 0, 127)
   local max = util.clamp(shift + size, 0, 127)
   
   s.clear()
   
   s.level(15)
   for x = min, max do
      for y = 0, 63 do
         if math.random() < cutoff * 0.5 then
            s.pixel(x, y)
         end
      end
   end
   s.fill()

   if splash then
      s.blend_mode(4)
      s.level(splash_level)
      s.move(3, 48)
      s.font_face(11)
      s.font_size(60)
      s.text("støv")
   end

   s.update()
end

-- cleanup
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

function cleanup()
   if save_on_exit then params:write(norns.state.data .. "state.pset") end
end
