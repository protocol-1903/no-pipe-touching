for p, prototype in pairs(data.raw.pipe) do
  if (not string.find(p, "npt-") and prototype.fluid_box and prototype.fluid_box.pipe_connections
  and #prototype.fluid_box.pipe_connections == 4) then
    -- log(string.format("creating pipes for: %s", p))
    -- note that any modifications made here before copying are also copied
    -- make sure it is fast replaceable with other pipes
    prototype.placeable_by = {item = p, count = 1}
    -- prototype.fast_replaceable_group = "pipe"
    -- create variations
    for i = 0, 14 do
      local pip = util.table.deepcopy(prototype)
			pip.name = string.format("%s-npt[%02d]", p, i)
			-- pip.localised_name = {"item-name." .. p}
			-- pip.placeable_by = {item = p, count = 1}
      -- pip.fast_replaceable_group = "pipe"
			pip.build_sound = nil
			pip.fluid_box.pipe_connections = {}
      for j, pos in pairs({{0, -1}, {1, 0}, {0, 1}, {-1, 0}}) do
        if bit32.band(2^(j - 1), i) ~= 0 then
          table.insert(pip.fluid_box.pipe_connections, {position = {pos[1], pos[2]}})
        end
      end
      -- add entity
			data.raw.pipe[string.format("%s-npt[%02d]", p, i)] = pip
    end
    data.raw.item[p].place_result = string.format("%s-npt[00]", p)
  end
end