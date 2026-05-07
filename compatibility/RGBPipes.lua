if not mods["RGBPipes"] then return end

npt.categories["red-pipe-machine-connection"] = true
npt.categories["yellow-pipe-machine-connection"] = true
npt.categories["green-pipe-machine-connection"] = true
npt.categories["teal-pipe-machine-connection"] = true
npt.categories["blue-pipe-machine-connection"] = true
npt.categories["purple-pipe-machine-connection"] = true

data.raw.pipe["black-pipe"].npt_compat = { ignore_category = true }
data.raw.pipe["red-pipe"].npt_compat = { ignore_category = true }
data.raw.pipe["yellow-pipe"].npt_compat = { ignore_category = true }
data.raw.pipe["green-pipe"].npt_compat = { ignore_category = true }
data.raw.pipe["teal-pipe"].npt_compat = { ignore_category = true }
data.raw.pipe["blue-pipe"].npt_compat = { ignore_category = true }
data.raw.pipe["purple-pipe"].npt_compat = { ignore_category = true }

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