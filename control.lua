-- get the type of pipe
local function getType(entity)
  log("get type")
  -- if not pipe
  if not entity then return; end
  -- get name from ghost or normal
  local name = entity.type == "entity-ghost" and entity.ghost_name or entity.type == "pipe" and entity.name
	if not name then return; end
  log(entity.type .. ": " .. name)
  -- if npt
  if name:find("-npt") then
    return name:sub(1, -9)
  -- else
  else
    return name
  end
end

---------------------------------------------------------------------------------------------------
-- find number of blocked entities based on the position and type of pipe
local function findBlocked(entity, surface, skip)
  log("find blocked")
	local blocked = 0
  local fluid
  for i, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
    log("looking for blocking at" .. entity.position.x + offset[1] .. ", " .. entity.position.y + offset[2])
    if not skip or (entity.position.x + offset[1] ~= skip.x and entity.position.y + offset[2] ~= skip.y) then
      -- find pipe (?)
      local pipe = surface.find_entities_filtered({type = 'pipe', position = {entity.position.x + offset[1], entity.position.y + offset[2]}})[1]
      -- check pipe material
      log("found entity (?) at" .. entity.position.x + offset[1] .. ", " .. entity.position.y + offset[2])
      local type = getType(pipe)  
      if type and type ~= getType(entity) then
        log("found blocking at" .. entity.position.x + offset[1] .. ", " .. entity.position.y + offset[2])
        blocked = blocked + 2^(i - 1)
      else
        -- check fluid contents
        if pipe and not fluid and pipe.fluidbox[1] then
          fluid = pipe.fluidbox[1].name
        elseif pipe and pipe.fluidbox[1] then
          if pipe.fluidbox[1].name ~= fluid then
            return -1
          end
        end
      end
    end
  end
  return blocked
end

---------------------------------------------------------------------------------------------------
-- check the amount of blocked for a pipe entity, based on number
local function getPipeBlocked(entity)
  -- return if nil
  if not entity then return; end
  -- get name from ghost or normal
  local name = entity.type == "entity-ghost" and entity.ghost_name or entity.type == "pipe" and entity.name
	if not name then return; end
  -- if npt
  if name:find("-npt") then
    return name:sub(-3, -2)
  -- else
  else
    return name
  end
end

---------------------------------------------------------------------------------------------------
local function cancelConstruction(event)
  local player = game.get_player(event.player_index)
  -- return if nil
  if not player then return; end
  -- tell the player no
  player.create_local_flying_text{
    text = "Cannot place pipe",
    create_at_cursor = true
  }
  player.play_sound{
    path = "utility/cannot_build",
    position = event.created_entity.position
  }
  -- if pipe, place in inventory
  if event.created_entity.type == "pipe" then
    -- put item back into player's inventory
    player.insert({name = getType(event.created_entity)})
  end
  -- delete old entity
  event.created_entity.destroy()
end

---------------------------------------------------------------------------------------------------
local function updateAdjacent(position, surface, skip)
  log("update adjacent")
  for o, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
    local adjacent_pipe = surface.find_entities_filtered({type = "pipe", position = {position.x + offset[1], position.y + offset[2]}})[1]
    if adjacent_pipe then
      log("found adjacent at" .. position.x + offset[1] .. ", " .. position.y + offset[2])

      -- find blocked
      local adj_blocked
      if skip then
        log("skip " .. position.x .. ", " .. position.y)
        adj_blocked = findBlocked(adjacent_pipe, surface, position)
      else
        log("no skip")
        adj_blocked = findBlocked(adjacent_pipe, surface, nil)
      end

      -- update the pipe if something is different
      if adj_blocked ~= getPipeBlocked(adjacent_pipe) and not adjacent_pipe.to_be_deconstructed() then
        log("creating new pipe")
        -- create some local variables
        local fluidbox = adjacent_pipe.fluidbox[1]
        local adj_position = adjacent_pipe.position
        local force = adjacent_pipe.force
        local last_user = adjacent_pipe.last_user
        local to_be_upgraded = adjacent_pipe.to_be_upgraded()
        local upgrade_target
        if to_be_upgraded then upgrade_target = adjacent_pipe.get_upgrade_target() end
        local name
        local type = getType(adjacent_pipe)
        adjacent_pipe.destroy()
        if adj_blocked ~= 0 then
          name = string.format("%s-npt[%02d]", type, 15 - adj_blocked)
        else
          name = type
        end
        local new_pipe = surface.create_entity({
          name = name,
          position = adj_position,
          force = force,
          player = last_user,
          create_build_effect_smoke = false
        })
        new_pipe.fluidbox[1] = fluidbox
        if to_be_upgraded then new_pipe.order_upgrade{force = force, player = last_user, target = upgrade_target} end
      end
    end
  end
end

---------------------------------------------------------------------------------------------------
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function (event)
  log("on place")
  local entity = event.created_entity
  
  -- check if pipe, otherwise return
  if entity.type ~= "pipe" and entity.type ~= "entity-ghost" then return; end
	local pipeType = getType(entity)

  -- check if valid, otherwise return
	if not pipeType then return; end

  -- create local variables
  local surface = entity.surface
  local type = entity.type
	local force = entity.force
  local position = entity.position

  -- find adjacent pipes
  local blocked = findBlocked(entity, surface, nil)

  -- if different fluidboxes have different fluids, cancel construction
  if blocked == -1 then
    cancelConstruction(event)
    -- return so nothing else happens
    return
  end
  
  -- skip the rest if not a ghost
  if entity.type == "entity-ghost" then return; end

  -- update adjacent pipes
  updateAdjacent(position, surface, false)

  -- if nothing is blocked, replace with the basic pipe
  if blocked == 0 then
    -- destroy the old entity
    if not entity.destroy() then return; end -- return if something breaks
    surface.create_entity({
      name = pipeType,
      position = position,
      force = force
    }).last_user = event.player_index
    return
  end

  -- destroy the old entity
  if not entity.destroy() then return; end -- return if something breaks
  
  -- replace old entity
  local pipe = surface.create_entity({
    name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
    position = position,
    force = force
  })
  if pipe and event.player_index then pipe.last_user = event.player_index; end
end)

---------------------------------------------------------------------------------------------------
script.on_event({defines.events.on_cancelled_deconstruction}, function (event)
  log("on cancel deconstruct")
  local entity = event.entity
  
  -- check if pipe, otherwise return
  if entity.type ~= "pipe" then return; end
	local pipeType = getType(entity)

  -- check if valid, otherwise return
	if not pipeType then return; end

  -- create local variables
  local surface = entity.surface
  local type = entity.type
	local force = entity.force
  local position = entity.position
  -- update adjacent pipes
  updateAdjacent(position, surface, false)

  -- find adjacent pipes
  local blocked = findBlocked(entity, surface, nil)

  -- if nothing is blocked, return
  if blocked == 0 then return; end

  -- destroy the old entity
  if not entity.destroy() then return; end -- return if something breaks
  
  -- replace old entity
  surface.create_entity({
    name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
    position = position,
    force = force
  }).last_user = event.player_index
end)

---------------------------------------------------------------------------------------------------
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function (event)
  log("on mined")
  local entity = event.entity
  -- check if pipe, otherwise return
  if entity.type ~= "pipe" then return; end
  log("destroy pipe")
	local pipeType = getType(entity)
  -- check if valid, otherwise return
	if not pipeType then return; end
  log("updating adjacent")
  -- update adjacent pipes
  updateAdjacent(entity.position, entity.surface, true)
end)
-- script.on_event({defines.events.on_player_setup_blueprint}, on_player_setup_blueprint)
--script.on_event({defines.events.on_pre_ghost_deconstructed}, on_pre_ghost_deconstructed)
-- script.on_event({defines.events.on_pre_player_mined_item}, on_pre_player_mined_item)
--script.on_event({defines.events.on_selected_entity_changed}, on_selected_entity_changed)