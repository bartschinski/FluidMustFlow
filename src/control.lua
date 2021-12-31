-- The only thing we're doing is auto-join, so don't even bother if it's not enabled
if not settings.startup["fmf-enable-duct-auto-join"].value then
  return
end

local event = require("__flib__.event")

--- Calculates the midpoint between two positions.
--- @param pos_1 Position
--- @param pos_2 Position
--- @return Position
local function get_midpoint(pos_1, pos_2)
  return {
    x = (pos_1.x + pos_2.x) / 2,
    y = (pos_1.y + pos_2.y) / 2,
  }
end

event.register(
  { defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built },
  function(e)
    --- @type LuaEntity
    local entity = e.entity or e.created_entity
    if not entity or not entity.valid then
      return
    end

    -- Straight ducts only have one fluidbox
    for _, neighbour in pairs(entity.neighbours[1]) do
      if entity.name == neighbour.name then
        local direction = entity.direction
        local force = entity.force
        local last_user = entity.last_user
        local position = get_midpoint(entity.position, neighbour.position)
        local surface = entity.surface

        entity.destroy({ raise_destroy = true })
        neighbour.destroy({ raise_destroy = true })

        surface.create_entity({
          name = entity.name == "duct-small" and "duct" or "duct-long",
          position = position,
          direction = direction,
          force = force,
          player = last_user,
          raise_built = true,
          create_build_effect_smoke = false,
        })

        -- Only do one join per build
        break
      end
    end
  end,
  { { filter = "name", name = "duct-small" }, { filter = "name", name = "duct" } }
)
