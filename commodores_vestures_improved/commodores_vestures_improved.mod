return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`commodores_vestures_improved` encountered an error loading the Darktide Mod Framework.")

		new_mod("commodores_vestures_improved", {
			mod_script       = "commodores_vestures_improved/scripts/mods/commodores_vestures_improved/commodores_vestures_improved",
			mod_data         = "commodores_vestures_improved/scripts/mods/commodores_vestures_improved/commodores_vestures_improved_data",
			mod_localization = "commodores_vestures_improved/scripts/mods/commodores_vestures_improved/commodores_vestures_improved_localization",
		})
	end,
	packages = {},
}
