local mod = get_mod("commodores_vestures_improved")

mod:add_global_localize_strings({
	loc_CVI_swap_operative = {
		en = "Change Operative"
	},
	loc_CVI_toggle_equipment = {
		en = "Toggle Original Equipment"
	},
	loc_CVI_toggle_view_bundle = {
		en = "Toggle Whole Bundle View"
	},
	loc_CVI_currently_showing = {
		en = "Currently showing on Operative:"
	}
})

return {
	mod_description = {
		en =
		"Adds a bunch of QoL features to the Commodore's Vestures (premium) shop. Including letting you preview bundles and showing items directly on your characters, without having to re-enter the store as the correct class.",
	},
	mod_name = {
		en = "Commodore's Vestures Improved"
	}
}
