local categories = {}
local pipes = {}

local blacklist = {
  ["black-pipe"] = true,
  ["4-to-4-pipe"] = true
}

-- collect pipe types
for p, _ in pairs(data.raw.pipe) do
  if p == "red-pipe" or p == "yellow-pipe" or p == "green-pipe" or p == "teal-pipe" or p == "blue-pipe" or p == "purple-pipe" then
    categories[#categories+1] = p .. "-machine-connection"
  elseif not blacklist[p] then
    categories[#categories+1] = p
  end
  pipes[#pipes+1] = p
end

-- all prototypes with fluidboxes
prototypes = {
  "pump",
  "storage-tank",
  "assembling-machine",
  "furnace",
  "boiler",
  "fluid-turret",
  "mining-drill",
  "offshore-pump",
  "generator",
  "fusion-generator",
  "fusion-reactor",
  "thruster",
  "inserter",
  "agricultural-tower",
  "lab",
  "radar",
  "reactor",
  "loader",
  "infinity-pipe"
} 

for _, prototype_category in pairs(prototypes) do
  for _, prototype in pairs(data.raw[prototype_category] or {}) do
    local fluid_boxes = {}
    -- multiple fluid_boxes
    for _, fluid_box in pairs(prototype.fluid_boxes or {}) do
      fluid_boxes[#fluid_boxes + 1] = fluid_box
    end
    -- single fluid_box
    if prototype.fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.fluid_box end
    -- input fluid_box
    if prototype.input_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.input_fluid_box end
    -- output fluid_box
    if prototype.output_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.output_fluid_box end
    -- fuel fluid_box
    if prototype.fuel_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.fuel_fluid_box end
    -- oxidizer fluid_box
    if prototype.oxidizer_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.oxidizer_fluid_box end
    -- energy source fluid_box
    if prototype.energy_source and prototype.energy_source.type == "fluid" then fluid_boxes[#fluid_boxes + 1] = prototype.energy_source.fluid_box end

    -- change!
    for f, fluid_box in pairs(fluid_boxes) do
      if type(fluid_box) == "table" then
        for _, pipe_connection in pairs(fluid_box.pipe_connections or {}) do
          local connection_category = pipe_connection.connection_category
          if connection_category == nil then
            connection_category = {}
          elseif type(connection_category) == "string" then
            connection_category = {connection_category}
          end
          for _, category in pairs(categories) do
            connection_category[#connection_category + 1] = category
          end
          local new_list = {}
          for c, category in pairs(connection_category) do
            local found = false
            for _, blacklist in pairs({"black-pipe", "red-pipe", "yellow-pipe", "green-pipe", "teal-pipe", "blue-pipe", "purple-pipe"}) do
              if category == blacklist or category == nil then found = true end
            end
            if not found then new_list[#new_list + 1] = category end
          end
          if pipe_connection.connection_type == "underground" then pipe_connection.connection_category = "nil" end
          if mods["RGBPipes"] and prototype_category == "infinity-pipe" then
            new_list[#new_list + 1] = "black-pipe"
          end
          pipe_connection.connection_category = new_list
        end
      end
    end
  end
end



for p, pipe in pairs(data.raw.pipe) do
  if not p:find("tomwub") then
    log("pipe-fixes: " .. p)
    for i, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
      -- compat for RGBPipes
      if mods["RGBPipes"] then
        pipe_connection.connection_category = {}
      -- if nil, make empty table
      elseif pipe_connection.connection_category == nil then
        pipe_connection.connection_category = {}
      -- if string, add to new table
      elseif type(pipe_connection.connection_category) == "string" then
        pipe_connection.connection_category = { pipe_connection.connection_category }
      end
      pipe_connection.connection_category[#pipe_connection.connection_category + 1] = p
      if p == "red-pipe" or p == "yellow-pipe" or p == "green-pipe" or p == "teal-pipe" or p == "blue-pipe" or p == "purple-pipe" then
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = p .. "-machine-connection"
      end
      if mods["RGBPipes"] and p == "black-pipe" then
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = "red-pipe"
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = "yellow-pipe"
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = "green-pipe"
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = "teal-pipe"
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = "blue-pipe"
        pipe_connection.connection_category[#pipe_connection.connection_category + 1] = "purple-pipe"
      end
    end
    if not p:find("tomwub") then
      for u, underground in pairs(data.raw["pipe-to-ground"]) do
        if u:sub(1,-11) == p then
          log("normal-fixes: " .. u)
          for i, pipe_connection in pairs(underground.fluid_box.pipe_connections) do
            if pipe_connection.connection_type ~= "underground" then
              pipe_connection.connection_category = table.deepcopy(pipe.fluid_box.pipe_connections[1].connection_category)
            elseif pipe_connection.connection_type == "underground" then
              pipe_connection.connection_category = u
            end
          end
          underground.solved_by_npt = true
          goto continue
        end
      end
      ::continue::
    end
  end
end

-- update locale
if mods["RGBPipes"] then
  data.raw.pipe["red-pipe"].localised_description = "Connects to Black pipes and machines"
  data.raw.pipe["yellow-pipe"].localised_description = "Connects to Black pipes and machines"
  data.raw.pipe["green-pipe"].localised_description = "Connects to Black pipes and machines"
  data.raw.pipe["teal-pipe"].localised_description = "Connects to Black pipes and machines"
  data.raw.pipe["blue-pipe"].localised_description = "Connects to Black pipes and machines"
  data.raw.pipe["purple-pipe"].localised_description = "Connects to Black pipes and machines"
  data.raw.pipe["pipe"].localised_description = "(White) Does not connect to colored pipes, only machines"
  data.raw["pipe-to-ground"]["red-pipe-to-ground"].localised_description = "Connects to Black pipes and machines"
  data.raw["pipe-to-ground"]["yellow-pipe-to-ground"].localised_description = "Connects to Black pipes and machines"
  data.raw["pipe-to-ground"]["green-pipe-to-ground"].localised_description = "Connects to Black pipes and machines"
  data.raw["pipe-to-ground"]["teal-pipe-to-ground"].localised_description = "Connects to Black pipes and machines"
  data.raw["pipe-to-ground"]["blue-pipe-to-ground"].localised_description = "Connects to Black pipes and machines"
  data.raw["pipe-to-ground"]["purple-pipe-to-ground"].localised_description = "Connects to Black pipes and machines"
  data.raw["pipe-to-ground"]["pipe-to-ground"].localised_description = "(White) Does not connect to colored pipes, only machines"
end

local afh_pipes = {
  ["one-to-one-forward-pipe"] = true,
  ["one-to-one-reverse-pipe"] = true,
  ["one-to-one-left-pipe"] = true,
  ["one-to-one-right-pipe"] = true,
  ["one-to-two-parallel-pipe"] = true,
  ["one-to-two-perpendicular-pipe"] = true,
  ["one-to-two-parallel-secondary-pipe"] = true,
  ["one-to-two-perpendicular-secondary-pipe"] = true,
  ["one-to-two-L-FL-pipe"] = true,
  ["one-to-two-L-FR-pipe"] = true,
  ["one-to-two-L-RL-pipe"] = true,
  ["one-to-two-L-RR-pipe"] = true,
  ["one-to-three-forward-pipe"] = true,
  ["one-to-three-reverse-pipe"] = true,
  ["one-to-three-left-pipe"] = true,
  ["one-to-three-right-pipe"] = true,
  ["one-to-one-forward-t2-pipe"] = true,
  ["one-to-one-reverse-t2-pipe"] = true,
  ["one-to-one-left-t2-pipe"] = true,
  ["one-to-one-right-t2-pipe"] = true,
  ["one-to-two-parallel-t2-pipe"] = true,
  ["one-to-two-perpendicular-t2-pipe"] = true,
  ["one-to-two-parallel-secondary-t2-pipe"] = true,
  ["one-to-two-perpendicular-secondary-t2-pipe"] = true,
  ["one-to-two-L-FL-t2-pipe"] = true,
  ["one-to-two-L-FR-t2-pipe"] = true,
  ["one-to-two-L-RL-t2-pipe"] = true,
  ["one-to-two-L-RR-t2-pipe"] = true,
  ["one-to-three-forward-t2-pipe"] = true,
  ["one-to-three-reverse-t2-pipe"] = true,
  ["one-to-three-left-t2-pipe"] = true,
  ["one-to-three-right-t2-pipe"] = true,
  ["one-to-one-forward-t3-pipe"] = true,
  ["one-to-one-reverse-t3-pipe"] = true,
  ["one-to-one-left-t3-pipe"] = true,
  ["one-to-one-right-t3-pipe"] = true,
  ["one-to-two-parallel-t3-pipe"] = true,
  ["one-to-two-perpendicular-t3-pipe"] = true,
  ["one-to-two-parallel-secondary-t3-pipe"] = true,
  ["one-to-two-perpendicular-secondary-t3-pipe"] = true,
  ["one-to-two-L-FL-t3-pipe"] = true,
  ["one-to-two-L-FR-t3-pipe"] = true,
  ["one-to-two-L-RL-t3-pipe"] = true,
  ["one-to-two-L-RR-t3-pipe"] = true,
  ["one-to-three-forward-t3-pipe"] = true,
  ["one-to-three-reverse-t3-pipe"] = true,
  ["one-to-three-left-t3-pipe"] = true,
  ["one-to-three-right-t3-pipe"] = true,
}

-- check for other tyoes if underground pipes
for u, underground in pairs(data.raw["pipe-to-ground"]) do
  if afh_pipes[u] or u:find("underground-cross-") or u:find("underground-t-") or u:find("underground-i-") then
    log("afh-fixes: " .. u)
    -- handle advanced fluid handling pipes
    for _, pipe_connection in pairs(underground.fluid_box.pipe_connections) do
      if pipe_connection.connection_type ~= "underground" then
        -- generic pipe connection, should connect to everything
        if not pipe_connection.connection_category then -- make new table
          pipe_connection.connection_category = {}
        elseif type(pipe_connection.connection_category) == "string" then -- convert string to table
          pipe_connection.connection_category = { pipe_connection.connection_category }
        end
        for _, pipe_category in pairs(pipes) do
          pipe_connection.connection_category[#pipe_connection.connection_category+1] = pipe_category
        end
      elseif pipe_connection.connection_category == "underground" and u:find("t3-pipe") then
        pipe_connection.connection_category = "t3-pipe"
      elseif pipe_connection.connection_category == "underground" and u:find("t2-pipe") then
        pipe_connection.connection_category = "t2-pipe"
      else
        pipe_connection.connection_category = "t1-pipe"
      end
    end
  elseif not underground.solved_by_npt then
    log("other-fixes: " .. u)
    for _, pipe_connection in pairs(underground.fluid_box.pipe_connections) do
      if pipe_connection.connection_type ~= "underground" then
        -- generic pipe connection, should connect to everything
        if not pipe_connection.connection_category then -- make new table
          pipe_connection.connection_category = {}
        elseif type(pipe_connection.connection_category) == "string" then -- convert string to table
          pipe_connection.connection_category = { pipe_connection.connection_category }
        end
        for _, pipe_category in pairs(pipes) do
          pipe_connection.connection_category[#pipe_connection.connection_category+1] = pipe_category
        end
      else -- type is underground
        pipe_connection.connection_category = u
      end
    end
  elseif underground.solved_by_npt then
    underground.solved_by_npt = nil
  end
end

-- for p, pipe_connection in pairs(data.raw.pipe.pipe.fluid_box.pipe_connections, data.raw["pipe-to-ground"]["pipe-to-ground"].fluid_box.pipe_connections) do
  
-- end


-- only set locale for RGB pipes if RGB pipes is enabled
-- fix extended range not doing properly
-- fix 5dims new transport