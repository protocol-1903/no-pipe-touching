[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/B0B7145X5R) [![](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2Fno-pipe-touching&style=for-the-badge)](https://mods.factorio.com/mod/no-pipe-touching) [![](https://img.shields.io/badge/Discord-Community-blue?style=for-the-badge)](https://discord.gg/K3fXMGVc4z) ![](https://img.shields.io/badge/Github-Source-green?style=for-the-badge&link=github.com%2Fprotocol-1903%2Fno-pipe-touching)

# This mod alters existing pipes. You will need another mod to add new pipes.

## What?
NPT allows pipes to only connect to pipes of the same material, including underground pipes! Pipe weaving is now possible!
Please report any bugs here or on [github](https://github.com/protocol-1903/no-pipe-touching)

Got a cool base that uses my mod? Let me know and I can pics up on the mod portal!

## Compatability
Should be compatible with most mods that adds unique pipes, if something breaks, let me know.

By default, NPT completely replaces the connection categories defined by other mods. If you wish to add compatibility on your own, you have a few options:
#
- Add the `prototype.npt_compat = {}` table to your prototype (pipe, pipe to ground, tank, crafting machine, etc)
- Add `npt_compat.mod = "your-mod-name"` REQUIRED FOR SMOOTH COMPATABILITY
- Add `npt_compat.ignore = true` if you don't want NPT to do anything to that entity
- Add `npt_compat.tag = "custom-tag"` for NPT to make all entities with the same tag connect. For example, `mod = "test-mod"` and `tag = "foo"` means that any entities with the `test-mod` and `foo` tags will connect. This means that two different mods with the same `tag` will not connect, so if you want them to connect, `mod` and `tag` must be the same. This is often easier and better than using `override`
- Add `npt_compat.override = "custom-category"` to override what the connection_category is for all of the normal connections of that entity
- Add `npt_compat.override_underground = "custom-category"` to override what the connection_category is for all of the underground connections of that entity

NPT also features special compat that it uses for fluidboxes that shouldn't be modified (plasma connections on fusion generators). It detects whether it has a fluidbox filter, then checks that against a blacklist. If you wish to prevent certain fluidboxes with filters from being modified, use the following:
#
- Add the `prototype.npt_compat = {}` table to the fluid in the fluidbox filter (i.e. the fluid `fusion-plasma` has this table)
- Add `npt_compat.blacklist = true`. You don't need to add anything to fluidbox filter fluids that should connect to NPT pipes.

## Known compatibility:
- Pymods
- [RGB Pipes](https://mods.factorio.com/mod/RGBPipes)
- [Color Coded Pipes](https://mods.factorio.com/mod/color-coded-pipes)
- [Flow Control](https://mods.factorio.com/mod/Flow%20Control)
- [Pipes Plus](https://mods.factorio.com/mod/pipe_plus)

If you wish to add compatibility with a mod, talk to me on here or discord so we can sort it out.

## History
This is a complete rebuild of the 1.1 version using connection_category, a new feature in the 2.0 modding API. Old versions used scripting and a ton of filler entities. The old code won't be useful... at least here :)

The old version is a revamp of [Incompatible Pipes](https://mods.factorio.com/mod/incompatible-pipes) by sticklord. It was rebuilt from the ground up for 1.1.

If you have a mod idea, let me know and I can look into it.
