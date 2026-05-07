if not mods["Flow Control"] then return end

data.raw["storage-tank"]["pipe-junction"].npt_compat = {override = "pipe"}
data.raw["storage-tank"]["pipe-elbow"].npt_compat = {override = "pipe"}
data.raw["storage-tank"]["pipe-straight"].npt_compat = {override = "pipe"}