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

-- find number of blocked entities based on the position and type of pipe
local function findBlocked(entity, surface, skip)
  log("find blocked")
	local blocked = 0
  for i, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
    log("looking for blocking at" .. entity.position.x + offset[1] .. ", " .. entity.position.y + offset[2])
    if not skip or (entity.position.x + offset[1] ~= skip.x and entity.position.y + offset[2] ~= skip.y) then
      -- find pipe (?)
      local pipe = surface.find_entities_filtered({type = 'pipe', position = {entity.position.x + offset[1], entity.position.y + offset[2]}})[1]
      -- if not pipe then pipe = surface.find_entities_filtered({ghost_type = 'pipe', position = {entity.position.x + offset[1], entity.position.y + offset[2]}})[1] end
      -- check pipe material
      log("found entity (?) at" .. entity.position.x + offset[1] .. ", " .. entity.position.y + offset[2])
      local type = getType(pipe)  
      if type and type ~= getType(entity) then
        log("found blocking at" .. entity.position.x + offset[1] .. ", " .. entity.position.y + offset[2])
        blocked = blocked + 2^(i - 1)
      end
    end
  end
  return blocked
end

-- check the amount of blocked for a pipe entity, based on number
local function getPipeBlocked(entity)
  -- if not pipe
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

local function cancelConstruction(event)
  local player = game.get_player(event.player_index)
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
    player.insert({name = event.created_entity.name})
  end
  -- delete old entity
  event.created_entity.destroy()
  game.print("destroyed pipe")
end

local function updateAdjacent(position, surface, skip)
  log("update adjacent")
  for o, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
    local adjacent_pipe = surface.find_entities_filtered({type = "pipe", position = {position.x + offset[1], position.y + offset[2]}})[1]
    -- if not adjacent_pipe then
    --   adjacent_pipe = surface.find_entities_filtered({ghost_type = "pipe", position = {position.x + offset[1], position.y + offset[2]}})[1]
    -- end
    if adjacent_pipe then
      log("found adjacent at" .. position.x + offset[1] .. ", " .. position.y + offset[2])
      -- skip if marked for deconstruction
      -- if adjacent_pipe.to_be_deconstructed() then goto continue; end
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
        local fluidbox = adjacent_pipe.fluidbox
        local adj_type = adjacent_pipe.type
        local adj_position = adjacent_pipe.position
        local force = adjacent_pipe.force
        local last_user = adjacent_pipe.last_user
        local name
        local type = getType(adjacent_pipe)
        adjacent_pipe.destroy()
        if adj_blocked ~= 0 then
          name = string.format("%s-npt[%02d]", type, 15 - adj_blocked)
        else
          name = type
        end
        surface.create_entity({
          name = name,
          position = adj_position,
          force = force,
          player = last_user,
          -- fast_replace = true,
          -- spill = false,
          create_build_effect_smoke = false
        }).fluidbox = fluidbox
      end
      -- ::continue::
    end
  end
end

-- on-built-entity                 done
-- on-robot-built-entity           done
-- on-pre-ghost-updated            n
-- on-pre-ghost-deconstructed      n
-- on-cancelled-deconstruction     done
-- on-marked-for-deconstruction    n
-- on-player-deconstructed-area    n
-- on-robot-mined-entity           done
-- on-player-mined-entity          done
-- quick replacement               n

-- prevent pipes completely surrounded       n
-- update entities on place pipe             done
-- update entities on remove pipe            done
-- check robot interactions                  who knows
-- deconstruction                            done
-- look into fast replacing while running    n
-- fix bots placing in illegal places        done ish
-- filter items on ghost placement           done i think
-- fix upgrade groups                        n
-- fix ghosts placing actual pipes           n
-- fix placing a ghost pipe updating adjacent ghost pipes to pipes
-- fix placing a pipe next to a pipe that is next to another pipe connecting the two other pipes regardless of material
-- swap pipe item place result to null pipe
-- check fluid contents to make sure fluids dont mix
-- removing a pipe adjacent to a pipe turns it into a basic pipe in some cases, where another pipe is across the adjacent pipe but not registered

-- do not remove fluids from updated pipes
-- prevent pipe placement if it will connect different fluids
-- prevent construction if it will be completely blocked

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function (event)
  log("on place")
  local entity = event.created_entity
  
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

  -- find adjacent pipes
  local blocked = findBlocked(entity, surface, nil)

  -- if everything is blocked, cancel construction
  -- if blocked == 15 then
  --   cancelConstruction(event)
  --   -- return so nothing else happens
  --   return
  -- end
  -- check adjacent pipes and cancel if any are fully blocked
  -- for o, offset in pairs({{0,-1}, {1,0}, {0,1}, {-1,0}}) do
  --   log(3.1)
  --   local adjacent_pipe = surface.find_entities_filtered({type = "pipe", position = {x + offset[1], y + offset[2]}})
  --   if not adjacent_pipe then
  --     adjacent_pipe = surface.find_entities_filtered({ghost_type = "pipe", position = {x + offset[1], y + offset[2]}})
  --   end
  --   if adjacent_pipe ~= nil then
  --     log(3.2)
  --     -- find blocked
  --     local adj_blocked = findBlocked(adjacent_pipe, surface)
  --     -- if fully blocked, cancel construction
  --     if adj_blocked == 15 then
  --       log(3.3)
  --       cancelConstruction(event)
  --       -- return so nothing else happens
  --       return
  --     end
  --   end
  -- end
  
  -- skip the rest if not a ghost
  if entity.type == "ghost_type" then return; end

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
  -- log("creating new pipe entity: " .. entity.type)
  local pipe = surface.create_entity({
    name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
    position = position,
    force = force
  })
  if pipe and event.player_index then pipe.last_user = event.player_index; end
end)

script.on_event({defines.events.on_cancelled_deconstruction}, function (event)
  log("on cancel deconstruct")
  local entity = event.entity
  
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
  -- update adjacent pipes
  updateAdjacent(position, surface, false)

  -- find adjacent pipes
  local blocked = findBlocked(entity, surface, nil)

  -- if nothing is blocked, return
  if blocked == 0 then return; end

  -- destroy the old entity
  if not entity.destroy() then return; end -- return if something breaks
  
  -- replace old entity
  -- log("creating new pipe entity: " .. entity.type)
  local pipe
  if type == "pipe" then
    pipe = surface.create_entity({
      name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
      position = position,
      force = force
    })
  else
    log("--------------- un deconstruct entity ghost")
    pipe = surface.create_entity({
      name = "entity-ghost",
      inner_name = string.format("%s-npt[%02d]", pipeType, 15 - blocked),
      position = position,
      force = force
  })
  end
  if pipe and event.player_index then pipe.last_user = event.player_index; end
end)

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