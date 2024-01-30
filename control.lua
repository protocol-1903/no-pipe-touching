local function getType(entity)
  -- if not pipe
  if not entity then return; end
  -- get name from ghost or normal
  local name = entity.type == "entity-ghost" and entity.ghost_name or entity.type == "pipe" and entity.name
	if not name then return; end
  -- if npt
  if name:find("-npt") then
    return name:sub(1, #name - 8)
  -- else
  else
    return name
  end
end

local function findBlocked(entity, surface)
	local blocked = 0
  for i, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
    -- find pipe (?)
    local pipe = surface.find_entities_filtered({type = 'pipe', position = {entity.position.x + offset[1], entity.position.y + offset[2]}})[1]
    if not pipe then pipe = surface.find_entities_filtered({ghost_type = 'pipe', position = {entity.position.x + offset[1], entity.position.y + offset[2]}})[1] end
    -- check pipe material
    local type = getType(pipe)
    if type and type ~= getType(entity) then
      blocked = blocked + 2^(i - 1)
    end
  end
  return blocked
end

-- on-built-entity                 done
-- on-robot-built-entity           n
-- on-pre-ghost-updated            n
-- on-pre-ghost-deconstructed      n
-- on-cancelled-deconstruction     n
-- on-marked-for-deconstruction    n
-- on-player-deconstructed-area    n
-- on-robot-mined-entity           n
-- quick replacement               n

-- update entities on place pipe
-- check robot interactions
-- deconstruction
-- update entities on remove pipe
-- look into fast replacing while running
-- fix bots placing in illegal places
-- filter items on ghost placement


script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function (event)
  local entity = event.created_entity

  -- check if pipe, otherwise return
  if entity.type ~= "pipe" and entity.type ~= "entity-ghost" then return; end
	local pipeType = getType(entity)

  -- check if valid, otherwise return
	if not pipeType then return; end
  local surface = entity.surface

  -- find adjacent pipes
  local blocked = findBlocked(entity, surface)

  -- if nothing is blocked, return
  if blocked == 0 then return; end

  -- create local variables
  local type = entity.type
	local force = entity.force
  local x, y = entity.position.x, entity.position.y

  -- if everything is blocked, prevent placement
  if blocked == 15 then
    local player = game.get_player(event.player_index)
    -- tell the player no
    player.create_local_flying_text({
      text = "Cannot place pipe",
      create_at_cursor = true
    })    
    player.play_sound({
      path = "utility/cannot_build",
      position = {x, y}
    })
    -- if pipe, place in inventory
    if entity.type == "pipe" then
      -- put item back into player's inventory
      player.insert({name = entity.name})
    end
    -- delete old entity
    entity.destroy()
    -- return so nothing else happens
    return
  end

  -- destroy the old entity
  if not entity.destroy() then return; end -- return if something breaks

  -- replace old entity
  -- log("creating new pipe entity: " .. entity.type)
  local pipe
  if type == "pipe" then
    pipe = surface.create_entity({
      name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
      position = {x, y},
      force = force
    })
  else
    pipe = surface.create_entity({
      name = "entity-ghost",
      inner_name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
      position = {x, y},
      force = force
  })
  end
  if pipe and event.player_index then pipe.last_user = event.player_index; end

  for o, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
    local adjacent_pipe = surface.find_entities_filtered({type = "pipe", position = {x + offset[1], y + offset[2]}})
  end
  -- for i = 1, 4 do
  --   local adjacent_pipe = surface.find_entities_filtered({type = "pipe", position = {x + (i - 2) % 2, y + (i - 3) % 2}})
  --   if not adjacent_pipe then
  --     adjacent_pipe = surface.find_entities_filtered({type = "pipe-to-ground", position = {x + (i - 2) % 2, y + (i - 3) % 2}})
  --   end

  -- end
end)



-- script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, on_mined_entity)
-- script.on_event({defines.events.on_player_setup_blueprint}, on_player_setup_blueprint)
--script.on_event({defines.events.on_pre_ghost_deconstructed}, on_pre_ghost_deconstructed)
-- script.on_event({defines.events.on_pre_player_mined_item}, on_pre_player_mined_item)
--script.on_event({defines.events.on_selected_entity_changed}, on_selected_entity_changed)