if mods["Krastorio2"] then
  for p, prototype in pairs(data.raw.pipe) do
    for f, flag in pairs(prototype.flags) do
      if p == "kr-steel-pipe" and flag == "fast-replaceable-no-build-while-moving" then
        table.remove(prototype.flags, f)
      end
    end
  end
end