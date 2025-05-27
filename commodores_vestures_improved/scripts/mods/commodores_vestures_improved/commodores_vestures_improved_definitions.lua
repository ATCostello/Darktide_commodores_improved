local menu_zoom_out = "loc_inventory_menu_zoom_out"
local menu_zoom_in = "loc_inventory_menu_zoom_in"
local menu_preview_with_gear_off = "loc_inventory_menu_preview_with_gear_off"
local menu_preview_with_gear_on = "loc_inventory_menu_preview_with_gear_on"
local weapon_preview_skin_off = "loc_premium_store_preview_weapon_no_skin_button"
local weapon_preview_skin_on = "loc_premium_store_preview_weapon_with_skin_button"

local grid_height = 840
local grid_margin = 30
local item_grid_width = 542
local grid_width = item_grid_width + grid_margin * 2

local legend_inputs = {
	{
		alignment = "left_alignment",
		display_name = "loc_settings_menu_close_menu",
		input_action = "back",
		on_pressed_callback = "cb_on_close_pressed",
	},
	{
		alignment = "right_alignment",
		display_name = "loc_rotate",
		input_action = "navigate_controller_right",
		visibility_function = function(parent)
			return not parent._using_cursor_navigation and (parent._is_dummy_showing or parent._is_weapon_showing) and
			not parent._aquilas_showing
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_premium_store_inspect_item",
		input_action = "hotkey_item_inspect",
		on_pressed_callback = "cb_on_inspect_pressed",
		visibility_function = function(parent)
			return not parent._aquilas_showing and parent._valid_inspect
		end,
	},
	{
		alignment = "right_alignment",
		input_action = "hotkey_menu_special_1",
		on_pressed_callback = "cb_on_weapon_skin_preview_pressed",
		display_name = weapon_preview_skin_off,
		visibility_function = function(parent, id)
			local display_name = parent._weapon_preview_show_original and weapon_preview_skin_on or
			weapon_preview_skin_off

			parent._input_legend_element:set_display_name(id, display_name)

			return parent._selected_element and parent._selected_element.item and
			parent._selected_element.item.item_type == "WEAPON_SKIN" and not parent._aquilas_showing
		end,
	},
	{
		alignment = "right_alignment",
		input_action = "hotkey_menu_special_1",
		on_pressed_callback = "cb_on_preview_with_gear_toggled",
		display_name = menu_preview_with_gear_off,
		visibility_function = function(parent, id)
			local display_name = parent._previewed_with_gear and menu_preview_with_gear_off or menu_preview_with_gear_on

			parent._input_legend_element:set_display_name(id, display_name)

			return parent._can_preview_with_gear and parent._selected_element and not parent._aquilas_showing
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_inventory_menu_zoom_in",
		input_action = "hotkey_menu_special_2",
		on_pressed_callback = "cb_on_camera_zoom_toggled",
		visibility_function = function(parent, id)
			if parent:_can_zoom() and not parent._aquilas_showing then
				local display_name = parent._camera_zoomed_in and menu_zoom_out or menu_zoom_in
				local input_legend = parent:_element("input_legend")

				if input_legend then
					input_legend:set_display_name(id, display_name)
				end

				return parent._on_enter_animation_triggered
			end

			return false
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_preview_voice",
		input_action = "hotkey_item_inspect",
		on_pressed_callback = "cb_preview_voice",
		visibility_function = function(parent, id)
			return parent:_can_preview_voice()
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_CVI_swap_operative",
		input_action = "cycle_chat_channel",
		on_pressed_callback = "cycle_preview_operative",
		visibility_function = function(parent, id)
			return parent:has_multiple_operatives() and not parent._weapon_preview
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_CVI_toggle_equipment",
		input_action = "character_create_randomize",
		on_pressed_callback = "toggle_equipment",
		visibility_function = function(parent, id)
			return parent._valid_equipment and not parent._weapon_preview
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_CVI_toggle_view_bundle",
		input_action = "hotkey_toggle_item_tooltip",
		on_pressed_callback = "toggle_view_bundle",
		visibility_function = function(parent, id)
			return parent._valid_bundle and not parent._weapon_preview
		end,
	}
}


local scenegraph_definition = {
	side_panel_area = {
		horizontal_alignment = "left",
		parent = "canvas",
		vertical_alignment = "bottom",
		size = {
			300,
			0,
		},
		position = {
			grid_width + 100,
			-200,
			1,
		},
	}
}


local legend_inputs_cosmetics_inspect_view = {
	{
		alignment = "left_alignment",
		display_name = "loc_settings_menu_close_menu",
		input_action = "back",
		on_pressed_callback = "cb_on_close_pressed",
	},
	{
		alignment = "right_alignment",
		input_action = "hotkey_menu_special_1",
		on_pressed_callback = "cb_on_preview_with_gear_toggled",
		display_name = menu_preview_with_gear_off,
		visibility_function = function(parent, id)
			local display_name = parent._previewed_with_gear and menu_preview_with_gear_off or menu_preview_with_gear_on

			parent._input_legend_element:set_display_name(id, display_name)

			local visible = parent:_can_preview()
			if parent.hide_character and parent.hide_character == true then
				visible = false
			end

			return visible
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_inventory_menu_swap_weapon",
		input_action = "hotkey_menu_special_1",
		on_pressed_callback = "cb_on_weapon_swap_pressed",
		store_appearance_option = true,
		visibility_function = function(parent)
			return parent:_can_swap_weapon()
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_inventory_menu_zoom_in",
		input_action = "hotkey_menu_special_2",
		on_pressed_callback = "cb_on_camera_zoom_toggled",
		visibility_function = function(parent, id)
				local display_name = parent._camera_zoomed_in and menu_zoom_out or menu_zoom_in

				parent._input_legend_element:set_display_name(id, display_name)

				local visible = true
				if parent.hide_character and parent.hide_character == true then
					visible = false
				end

				return visible

		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_preview_voice",
		input_action = "hotkey_item_inspect",
		on_pressed_callback = "cb_preview_voice",
		visibility_function = function(parent, id)
			return parent:_can_preview_voice()
		end,
	},
	{
		alignment = "right_alignment",
		display_name = "loc_exit_to_main_menu_display_name",
		input_action = "cycle_chat_channel",
		on_pressed_callback = "cycle_preview_operative",
		visibility_function = function(parent, id)
			return parent:has_multiple_operatives()
		end,
	}
}
return {
	legend_inputs = legend_inputs,
	legend_inputs_cosmetics_inspect_view = legend_inputs_cosmetics_inspect_view,
	scenegraph_definition = scenegraph_definition
}
