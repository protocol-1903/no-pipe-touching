local categories = { "default" }
local pipes = {}

local blacklist = {
  ["black-pipe"] = true,
  ["4-to-4-pipe"] = true
}

local function has_default_category(pipe_connection)
  if pipe_connection == nil or #pipe_connection == 0 then return true end
  for _, category in pairs(pipe_connection.connection_category or {pipe_connection.connection_category}) do
    if category == "default" then return true end
  end
  return false
end

local function contains_default_category(pipe_connections)
  for _, pipe_connection in pairs(pipe_connections) do
    if has_default_category(pipe_connection) then return true end
  end
  return false
end

if mods["plasma-duct"] then
  data.raw.pipe["plasma-duct"].npt_compat = { ignore = true }
end

if mods["RGBPipes"] then
  categories = {
    "default",
    "red-pipe-machine-connection",
    "yellow-pipe-machine-connection",
    "green-pipe-machine-connection",
    "teal-pipe-machine-connection",
    "blue-pipe-machine-connection",
    "purple-pipe-machine-connection"
  }
end

-- local category_blacklist = {
--   ["fusion-plasma"] = true
-- }

-- local fluid_blacklist = {}

for f, fluid in pairs(data.raw.fluid) do
  if fluid.npt_compat and fluid.npt_compat.blacklist then
    fluid_blacklist[f] = true
  end
  fluid.npt_compat = nil
end

-- collect pipe types
for p, pipe in pairs(data.raw.pipe) do
  if pipe.npt_compat and pipe.npt_compat.tag then
    pipes[#pipes+1] = pipe.npt_compat.mod .. "-" .. pipe.npt_compat.tag
    if not blacklist[p] then
      categories[#categories+1] = pipe.npt_compat.mod .. "-" .. pipe.npt_compat.tag
    end
  elseif not pipe.npt_compat or not pipe.npt_compat.ignore then
    pipes[#pipes+1] = p
    if not blacklist[p] and contains_default_category(pipe.fluid_box.pipe_connections) then
      categories[#categories+1] = p
    end
  end
end

-- do after pipe category collection to reduce reduntant categories
if mods["Flow Control"] then
  data.raw["storage-tank"]["pipe-junction"].npt_compat = {override = "pipe"}
  data.raw["storage-tank"]["pipe-elbow"].npt_compat = {override = "pipe"}
  data.raw["storage-tank"]["pipe-straight"].npt_compat = {override = "pipe"}
end

-- do after pipe category collection to reduce reduntant categories
if mods["pipe_plus"] then
  data.raw["pipe-to-ground"]["pipe-to-ground-2"].npt_compat = {override = "pipe", override_underground = "pipe-to-ground"}
  data.raw["pipe-to-ground"]["pipe-to-ground-3"].npt_compat = {override = "pipe", override_underground = "pipe-to-ground"}
  data.raw["pipe-to-ground"]["pipe-to-ground-north"].npt_compat = {override = "pipe", override_underground = "pipe-to-ground"}
  data.raw["pipe-to-ground"]["pipe-to-ground-east"].npt_compat = {override = "pipe", override_underground = "pipe-to-ground"}
  data.raw["pipe-to-ground"]["pipe-to-ground-south"].npt_compat = {override = "pipe", override_underground = "pipe-to-ground"}
  data.raw["pipe-to-ground"]["pipe-to-ground-west"].npt_compat = {override = "pipe", override_underground = "pipe-to-ground"}
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
  "infinity-pipe",
  "valve"
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
      if type(fluid_box) == "table" and contains_default_category(fluid_box.pipe_connections) then
        for _, pipe_connection in pairs(fluid_box.pipe_connections or {}) do
          if prototype.type ~= "infinity-pipe" and not has_default_category(pipe_connection) then
            -- ignore if an infinity pipe (should connect to everything) and doesn't have the default category (custom connections, like plasma)
            goto continue
          end
          if prototype.npt_compat == nil and has_default_category(pipe_connection) then
            local connection_category = {}
            for _, category in pairs(categories) do
              connection_category[#connection_category + 1] = category
            end
            local new_list = {}
            for c, category in pairs(connection_category) do
              local found = false
              if mods["RGBPipes"] then
                for _, blacklist in pairs({"black-pipe", "red-pipe", "yellow-pipe", "green-pipe", "teal-pipe", "blue-pipe", "purple-pipe"}) do
                  if category == blacklist or category == nil then found = true end
                end
              end
              if not found then new_list[#new_list + 1] = category end
            end
            if mods["RGBPipes"] and prototype_category == "infinity-pipe" then
              new_list[#new_list + 1] = "black-pipe"
            end
            pipe_connection.connection_category = new_list
            if pipe_connection.connection_type == "underground" then pipe_connection.connection_category = "pipe-to-ground" end
          elseif prototype.npt_compat then -- manual compat of some variety
            if prototype.npt_compat.tag then
              pipe_connection.connection_category = { prototype.npt_compat.mod .. "-" .. prototype.npt_compat.tag }
            elseif prototype.npt_compat.mod == "afh" then
              pipe_connection.connection_category = "afh-underground-" .. prototype.npt_compat.tier
            elseif prototype.npt_compat.override or prototype.npt_compat.override_underground then
              if pipe_connection.connection_type ~= "underground" then
                pipe_connection.connection_category = prototype.npt_compat.override or nil
              else
                pipe_connection.connection_category = prototype.npt_compat.override_underground or nil
              end
            end
            -- otherwise, ignore
          end
          ::continue::
        end
      end
    end
    prototype.npt_compat = nil
  end
end



for p, pipe in pairs(data.raw.pipe) do
  if pipe.npt_compat == nil and contains_default_category(pipe.fluid_box.pipe_connections) then
    for _, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
      if has_default_category(pipe_connection) then
        pipe_connection.connection_category = { p }

        if mods["RGBPipes"] and (p == "red-pipe" or p == "yellow-pipe" or p == "green-pipe" or p == "teal-pipe" or p == "blue-pipe" or p == "purple-pipe") then
          pipe_connection.connection_category[#pipe_connection.connection_category + 1] = p .. "-machine-connection"
        end
        
        if mods["RGBPipes"] and p == "black-pipe" then
          pipe_connection.connection_category = {
            "red-pipe",
            "yellow-pipe",
            "green-pipe",
            "teal-pipe",
            "blue-pipe",
            "purple-pipe",
            "black-pipe"
          }
        end
      end
    end
    for u, underground in pairs(data.raw["pipe-to-ground"]) do
      if u:sub(1,-11) == p and contains_default_category(underground.fluid_box.pipe_connections) then
        for i, pipe_connection in pairs(underground.fluid_box.pipe_connections) do
          if pipe_connection.connection_type ~= "underground" and has_default_category(pipe_connection) then
            pipe_connection.connection_category = table.deepcopy(pipe.fluid_box.pipe_connections[1].connection_category)
          elseif pipe_connection.connection_type == "underground" and has_default_category(pipe_connection) then
            pipe_connection.connection_category = u
          end
        end
        underground.solved_by_npt = true
        goto continue
      end
    end
    ::continue::
  elseif pipe.npt_compat and pipe.npt_compat.ignore then
    -- do nothing
  elseif pipe.npt_compat and pipe.npt_compat.tag then
    for _, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
      pipe_connection.connection_category = { pipe.npt_compat.mod .. "-" .. pipe.npt_compat.tag }
    end
  elseif pipe.npt_compat and (pipe.npt_compat.override or pipe.npt_compat.override_underground) then
    for _, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
      if pipe_connection.connection_type ~= "underground" then
        pipe_connection.connection_category = pipe.npt_compat.override or nil
      else
        pipe_connection.connection_category = pipe.npt_compat.override_underground or nil
      end
    end
  end
  pipe.npt_compat = nil
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
-- check for other tyoes if underground pipes
for u, underground in pairs(data.raw["pipe-to-ground"]) do
  if underground.npt_compat and underground.npt_compat.mod == "afh" then
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
      else
        pipe_connection.connection_category = "afh-underground-" .. underground.npt_compat.tier
      end
    end
  elseif underground.npt_compat and underground.npt_compat.tag then
    -- handle specific compatability
    for _, pipe_connection in pairs(underground.fluid_box.pipe_connections) do
      pipe_connection.connection_category = underground.npt_compat.mod .. "-" .. underground.npt_compat.tag
    end
  elseif underground.npt_compat and (underground.npt_compat.override or underground.npt_compat.override_underground) then
    for _, pipe_connection in pairs(underground.fluid_box.pipe_connections) do
      if pipe_connection.connection_type ~= "underground" then
        pipe_connection.connection_category = underground.npt_compat.override or nil
      else
        pipe_connection.connection_category = underground.npt_compat.override_underground or nil
      end
    end
  elseif not underground.solved_by_npt and not (underground.npt_compat and underground.npt_compat.ignore) and not contains_default_category(underground.fluid_box.pipe_connections) then
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
        pipe_connection.connection_category = "pipe-to-ground"
      end
    end
  end
    underground.solved_by_npt = nil
  if not mods["the-one-mod-with-underground-bits"] then
    underground.npt_compat = nil
  end
end