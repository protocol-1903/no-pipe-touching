-- local function is_generic(pipe)
--   return pipe.fluid_box and pipe.fluid_box.pipe_connections and #pipe.fluid_box.pipe_connections == 4
-- end

-- --create 15 different pipes for all different connections for all pipes
-- for p,prototype in pairs(data.raw.pipe) do
-- 	local pipeName = p
-- 	if is_generic(prototype) then --pipe without digits, create 15 pipes for it. memory is cheap
-- 		prototype.fast_replaceable_group = nil
-- 		for i = 1, 15  do
-- 			local pip = util.table.deepcopy(data.raw.pipe[pipeName])
-- 			local id = i-1
-- 			local pipname = shared.get_pipe_name(v.name, id)
-- 			pip.name = pipname
-- 			pip.localised_name = {"item-name." .. v.name}
-- 			pip.flags = {"player-creation"}
-- 			pip.placeable_by = {item = pipeName, count = 1}
-- 			--pip.randomvalue = 123456
-- 			pip.fast_replaceable_group = nil
-- 			pip.build_sound = nil
-- 			pip.items_to_place_this = {item = pipeName}
-- 			pip.fluid_box.pipe_connections = get_connections_from_hex(id)
-- 			pip.rotatable = true
-- 			data.raw.pipe[pipname] = pip
-- 		end
-- 	end
-- end

for p, prototype in pairs(data.raw.pipe) do
  if (not string.find(p, "npt-")) then
    log(string.format("creating pipes for: %s",p))

    -- note that any modifications made here before copying are also copied
    -- make sure it is fast replaceable with other pipes
    prototype.fast_replaceable_group = "pipe"



    -- create straight variant
    local straight = table.deepcopy(prototype)
    straight.name = "npt-" .. p .. "-straight"
    straight.localised_name = {"entity-name." .. p}
    straight.localised_description = {"entity-description." .. p}
    straight.type = "pipe-to-ground"
    -- pipe_connections
    straight.fluid_box.pipe_connections = {
      {
        type = "input-output",
        positions = {
          {0, -1}, {1, 0}, {0, 1}, {-1, 0}
        }
      },
      {
        type = "input-output",
        positions = {
          {0, 1}, {-1, 0}, {0, -1}, {1, 0}
        }
      }
    }
    -- replace sprites
    straight.pictures = {
      up = prototype.pictures.straight_vertical,
      right = prototype.pictures.straight_horizontal,
      down = prototype.pictures.straight_vertical,
      left = prototype.pictures.straight_horizontal
    }
    -- replace end caps
    if (prototype.fluid_box.pipe_covers) then
      straight.fluid_box.pipe_covers = prototype.fluid_box.pipe_covers
    elseif (data.raw["pipe-to-ground"][p .. "-to-ground"]) then
      straight.fluid_box.pipe_covers = data.raw["pipe-to-ground"][p .. "-to-ground"].fluid_box.pipe_covers
    else
      straight.fluid_box.pipe_covers = pipecoverspictures()
    end
    -- add entity
    data.raw["pipe-to-ground"]["npt-" .. p .. "-straight"] = straight



    -- create elbow variant
    local elbow = table.deepcopy(prototype)
    elbow.name = "npt-" .. p .. "-elbow"
    elbow.localised_name = {"entity-name." .. p}
    elbow.localised_description = {"entity-description." .. p}
    elbow.type = "pipe-to-ground"
    -- pipe_connections
    elbow.fluid_box.pipe_connections = {
      {
        type = "input-output",
        positions = {
          {0, -1}, {1, 0}, {0, 1}, {-1, 0}
        }
      },
      {
        type = "input-output",
        positions = {
          {1, 0}, {0, 1}, {-1, 0}, {0, -1}
        }
      }
    }
    -- replace sprites
    elbow.pictures = {
      up = prototype.pictures.corner_up_right,
      right = prototype.pictures.corner_down_right,
      down = prototype.pictures.corner_down_left,
      left = prototype.pictures.corner_up_left
    }
    -- replace end caps
    if (prototype.fluid_box.pipe_covers) then
      elbow.fluid_box.pipe_covers = prototype.fluid_box.pipe_covers
    elseif (data.raw["pipe-to-ground"][p .. "-to-ground"]) then
      elbow.fluid_box.pipe_covers = data.raw["pipe-to-ground"][p .. "-to-ground"].fluid_box.pipe_covers
    else
      elbow.fluid_box.pipe_covers = pipecoverspictures()
    end
    -- add entity
    data.raw["pipe-to-ground"]["npt-" .. p .. "-elbow"] = elbow



    -- create t-junction variant
    local junction = table.deepcopy(prototype)
    junction.name = "npt-" .. p .. "-junction"
    junction.localised_name = {"entity-name." .. p}
    junction.localised_description = {"entity-description." .. p}
    junction.type = "pipe-to-ground"
    -- pipe_connections
    junction.fluid_box.pipe_connections = {
      {
        type = "input-output",
        positions = {
          {-1, 0}, {0, -1}, {1, 0}, {0, 1}
        }
      },
      {
        type = "input-output",
        positions = {
          {0, -1}, {1, 0}, {0, 1}, {-1, 0}
        }
      },
      {
        type = "input-output",
        positions = {
          {1, 0}, {0, 1}, {-1, 0}, {0, -1}
        }
      }
    }
    -- replace sprites
    junction.pictures = {
      up = prototype.pictures.t_up,
      right = prototype.pictures.t_right,
      down = prototype.pictures.t_down,
      left = prototype.pictures.t_left
    }
    -- replace end caps
    if (prototype.fluid_box.pipe_covers) then
      junction.fluid_box.pipe_covers = prototype.fluid_box.pipe_covers
    elseif (data.raw["pipe-to-ground"][p .. "-to-ground"]) then
      junction.fluid_box.pipe_covers = data.raw["pipe-to-ground"][p .. "-to-ground"].fluid_box.pipe_covers
    else
      junction.fluid_box.pipe_covers = pipecoverspictures()
    end
    -- add entity
    data.raw["pipe-to-ground"]["npt-" .. p .. "-junction"] = junction
  end
end