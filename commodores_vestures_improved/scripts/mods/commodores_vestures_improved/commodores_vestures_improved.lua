--[[
    Name: Show premium cosmetics on operatives
    Author: Alfthebigheaded
]]
local mod = get_mod("commodores_vestures_improved")

local Definitions = mod:io_dofile(
	"commodores_vestures_improved/scripts/mods/commodores_vestures_improved/commodores_vestures_improved_definitions"
)

local Archetypes = require("scripts/settings/archetype/archetypes")
local UIWidget = require("scripts/managers/ui/ui_widget")
local UIFonts = require("scripts/managers/ui/ui_fonts")
local StoreItemDetailView = require("scripts/ui/views/store_item_detail_view/store_item_detail_view")
local StoreItemDetailViewDefinitions =
	require("scripts/ui/views/store_item_detail_view/store_item_detail_view_definitions")
local CosmeticsInspectView = require("scripts/ui/views/cosmetics_inspect_view/cosmetics_inspect_view")
local UIRenderer = require("scripts/managers/ui/ui_renderer")
local ScriptWorld = require("scripts/foundation/utilities/script_world")
local current_profiles = nil
local ItemUtils = require("scripts/utilities/items")
local ScriptCamera = require("scripts/foundation/utilities/script_camera")
local UIProfileSpawner = require("scripts/managers/ui/ui_profile_spawner")
local CosmeticsInspectViewDefinitions =
	require("scripts/ui/views/cosmetics_inspect_view/cosmetics_inspect_view_definitions")
local UIWidgetGrid = require("scripts/ui/widget_logic/ui_widget_grid")
local ViewElementInputLegend = require("scripts/ui/view_elements/view_element_input_legend/view_element_input_legend")
local PlayerCharacterConstants = require("scripts/settings/player_character/player_character_constants")

local selected_profile
local hide_equipment = false
local view_whole_bundle = true

local available_companions = {
	companion_dog = "slot_companion_gear_full",
}
local COMPANION_SLOTS_BY_BREED = {}
local COMPANION_BREED_BY_SLOT = {}
local COMPANION_SLOTS = {}

for breed, main_slot in pairs(available_companions) do
	local slot_depedencies = PlayerCharacterConstants.slot_configuration[main_slot].slot_dependencies

	COMPANION_SLOTS_BY_BREED[breed] = {
		[main_slot] = true,
	}
	COMPANION_BREED_BY_SLOT[main_slot] = breed
	COMPANION_SLOTS[main_slot] = true

	if slot_depedencies then
		for i = 1, #slot_depedencies do
			local slot_depedency = slot_depedencies[i]

			COMPANION_SLOTS_BY_BREED[breed] = {
				[slot_depedency] = true,
			}
			COMPANION_BREED_BY_SLOT[slot_depedency] = breed
			COMPANION_SLOTS[slot_depedency] = true
		end
	end
end

-- Grab all account operatives on load
mod:hook_safe(CLASS.StoreView, "on_enter", function(self)
	mod._refresh_profiles(self)
end)

-- Refresh widgets when "Show on operative" is toggled
mod:hook_safe(CLASS.StoreItemDetailView, "cb_on_preview_with_gear_toggled", function(self)
	if not self._weapon_preview then
		StoreItemDetailView._setup_side_panel(self)
	end
end)

mod:hook_safe(CLASS.PenanceOverviewView, "on_enter", function(self)
	mod._refresh_profiles(self)
end)

mod:hook_safe(CLASS.CosmeticsInspectView, "on_enter", function(self)
	mod._refresh_profiles(self)
	if self._selected_slot then
		self.is_weapon_preview = true
		mod.display_cosmetics(self, hide_equipment)
	end
end)

mod:hook_safe(CLASS.CosmeticsInspectView, "on_exit", function(self)
	self.is_weapon_preview = false
end)

mod:hook_require("scripts/ui/views/cosmetics_inspect_view/cosmetics_inspect_view_definitions", function(instance)
	local grid_margin = 30
	local item_grid_width = 542
	local grid_width = item_grid_width + grid_margin * 2

	instance.scenegraph_definition.side_panel_area = {
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
end)
local Personalities = require("scripts/settings/character/personalities")
local VoiceFxPresetSettings = require("scripts/settings/dialogue/voice_fx_preset_settings")

--[[
CosmeticsInspectView.cb_preview_voice = function(self)
	local voice_fx_preset_key = self._preview_item.__master_item.voice_fx_preset


	local voice_fx_preset_rtcp = VoiceFxPresetSettings[voice_fx_preset_key]
	if not voice_fx_preset_key then
		return
	end
	local personality_key = table.nested_get(self, "_preview_profile", "lore", "backstory", "personality")
	local personality_settings = Personalities[personality_key]
	local sound_event = personality_settings and personality_settings.preview_sound_event

	if not sound_event then
		return
	end

	local ui_world = Managers.ui:world()
	local wwise_world = Managers.world:wwise_world(ui_world)

	if not wwise_world then
		return
	end

	self:_stop_current_voice()

	local source = WwiseWorld.make_auto_source(wwise_world, Vector3.zero())

	WwiseWorld.set_source_parameter(wwise_world, source, "voice_fx_preset", voice_fx_preset_rtcp)

	self._sound_event_id = WwiseWorld.trigger_resource_event(wwise_world, sound_event, source)
end]]

CosmeticsInspectView._setup_item_description = function(self, description_text, restriction_text, property_text)
	local widgets_by_name = self._widgets_by_name
	local description_background = widgets_by_name.description_background

	description_background.content.visible = false

	self:_destroy_description_grid()

	local any_text = description_text or restriction_text or property_text

	if not any_text then
		return
	end

	local widgets = {}
	local alignment_widgets = {}
	local scenegraph_id = "description_content_pivot"
	local max_width = self._ui_scenegraph.description_grid.size[1]

	local function _add_text_widget(pass_template, text)
		local widget_definition = UIWidget.create_definition(pass_template, scenegraph_id, nil, {
			max_width,
			0,
		})
		local widget = self:_create_widget(string.format("description_grid_widget_%d", #widgets), widget_definition)

		widget.content.text = text

		local widget_text_style = widget.style.text
		local _, text_height = self:_text_size(text, widget_text_style, {
			max_width,
			math.huge,
		})

		widget.content.size[2] = text_height
		widgets[#widgets + 1] = widget
		alignment_widgets[#alignment_widgets + 1] = widget
	end

	local function _add_spacing(height)
		widgets[#widgets + 1] = nil
		alignment_widgets[#alignment_widgets + 1] = {
			size = {
				max_width,
				height,
			},
		}
	end

	local desired_spacing = 50

	if description_text then
		if #widgets > 0 then
			_add_spacing(desired_spacing)
		end

		_add_text_widget(CosmeticsInspectViewDefinitions.text_description_pass_template, description_text)

		desired_spacing = 80
	end

	if property_text then
		if #widgets > 0 then
			_add_spacing(desired_spacing)
		end

		_add_text_widget(
			CosmeticsInspectViewDefinitions.item_sub_title_pass,
			Utf8.upper(Localize("loc_item_property_header"))
		)
		_add_spacing(10)
		_add_text_widget(CosmeticsInspectViewDefinitions.item_text_pass, property_text)

		desired_spacing = 50
	end

	if restriction_text then
		if #widgets > 0 then
			_add_spacing(desired_spacing)
		end

		_add_text_widget(
			CosmeticsInspectViewDefinitions.item_sub_title_pass,
			Utf8.upper(Localize("loc_item_equippable_on_header"))
		)
		_add_spacing(10)
		_add_text_widget(CosmeticsInspectViewDefinitions.item_text_pass, restriction_text)

		desired_spacing = 50

		if #widgets > 0 then
			_add_spacing(desired_spacing)
		end

		if selected_profile then
			_add_text_widget(
				CosmeticsInspectViewDefinitions.item_sub_title_pass,
				Utf8.upper(Localize("loc_CVI_currently_showing"))
			)
			_add_spacing(10)
			local text

			local archetype_name = selected_profile.archetype.name
			local archetype = Archetypes[archetype_name]
			local archetype_symbol = mod.get_archetype_symbol(archetype)

			text = string.format("%s %s", archetype_symbol, selected_profile.name)
			_add_text_widget(CosmeticsInspectViewDefinitions.item_text_pass, text)
		end
	end

	self._description_grid_widgets = widgets
	self._description_grid_alignment_widgets = alignment_widgets

	local grid_scenegraph_id = "description_grid"
	local grid_pivot_scenegraph_id = "description_content_pivot"
	local grid_spacing = {
		0,
		0,
	}
	local grid_direction = "down"
	local use_is_focused_for_navigation = true
	local grid = UIWidgetGrid:new(
		self._description_grid_widgets,
		self._description_grid_alignment_widgets,
		self._ui_scenegraph,
		grid_scenegraph_id,
		grid_direction,
		grid_spacing,
		nil,
		use_is_focused_for_navigation
	)

	self._description_grid = grid

	local scrollbar_widget = widgets_by_name.description_scrollbar

	grid:assign_scrollbar(scrollbar_widget, grid_pivot_scenegraph_id, grid_scenegraph_id)
	grid:set_scrollbar_progress(0)
	grid:set_scroll_step_length(100)

	description_background.content.visible = true
end

-- For singular store items
mod:hook_safe(CLASS.StoreItemDetailView, "_present_item", function(self, item, visual_item)
	-- Do not display character if item is a weapon skin or trinket
	local item_type = item.item_type
	local preview_on_player = item_type ~= "WEAPON_RANGED"
		and item_type ~= "WEAPON_MELEE"
		and item_type ~= "WEAPON_SKIN"
		and item_type ~= "WEAPON_TRINKET"

	local element = self._selected_element
	self._valid_bundle = mod.show_toggle_view_bundle(self, element)
	self._valid_equipment = mod.show_toggle_equipment(self, element)

	if preview_on_player then
		mod.display_cosmetics(self, hide_equipment, nil, visual_item.__master_item)
	else
	end
end)

-- For item bundles
mod:hook_safe(CLASS.StoreItemDetailView, "_present_bundle", function(self)
	-- Remove artwork image from bundle
	local widgets_by_name = self._widgets_by_name
	local bundle_background_widget = widgets_by_name.bundle_background
	bundle_background_widget.style.bundle.material_values.texture_map = nil

	-- hide png overlay of bundle character, so you can see on your actual characters...
	widgets_by_name.bundle_background.visible = false

	view_whole_bundle = true
	mod.display_cosmetics(self, hide_equipment)

	local element = self._selected_element
	self._valid_bundle = mod.show_toggle_view_bundle(self, element)
	self._valid_equipment = mod.show_toggle_equipment(self, element)

	-- change camera to full body view
	local breed_name = self._presentation_profile and self._presentation_profile.archetype.breed or "human"
	local default_camera_settings = self._breeds_default_camera_settings[breed_name]
	self:_set_initial_viewport_camera_position(default_camera_settings)
end)

mod.display_cosmetics = function(self, optional_remove_original_gear, optional_specific_profile, optional_item)
	-- Display items
	local item

	-- use passed item if present
	if optional_item then
		item = optional_item
	elseif self._items then
		if self._items[1].item and self._items[1].item.__master_item then
			item = self._items[1].item.__master_item
		elseif self._items[1].item then
			item = self._items[1].item
		end
	elseif self._context and self._context.preview_item then
		item = self._context.preview_item
	end

	-- Generate character
	if not self._bundle_data then
		mod._generate_spawn_profile(self, item, optional_specific_profile)
	end

	if not self.is_weapon_preview and not self._bundle_data then
		-- Remove character's original gear if wanted
		if optional_remove_original_gear then
			if self._gear_loadout then
				-- Remove current cosmetics to only show bundle items
				self._gear_loadout["slot_gear_extra_cosmetic"] = nil
				self._gear_loadout["slot_gear_upperbody"] = nil
				self._gear_loadout["slot_gear_lowerbody"] = nil
				self._gear_loadout["slot_gear_head"] = nil
			end
		end

		if view_whole_bundle then
			if optional_item then
				local slot_name = item.slots[1]
				self._mannequin_loadout[slot_name] = item
				local gear_loadout = self._gear_loadout
				if gear_loadout then
					gear_loadout[slot_name] = item
				end
			else
				-- Add all bundle items to preview character
				for i, items in pairs(self._items) do
					local item = items.item
					local slot_name = item.slots[1]
					self._mannequin_loadout[slot_name] = item
					local gear_loadout = self._gear_loadout
					if gear_loadout then
						gear_loadout[slot_name] = item
					end
				end
			end
		else
			local element = self._selected_element
			for i, items in pairs(self._items) do
				if items.offer.offerId == element.offer.offerId then
					local item = items.item
					local slot_name = item.slots[1]
					self._mannequin_loadout[slot_name] = item
					local gear_loadout = self._gear_loadout
					if gear_loadout then
						gear_loadout[slot_name] = item
					end
				end
			end
		end

		-- temporarily remove doggo, so that they don't spawn in with character cosmetics.
		self._gear_loadout["slot_companion_gear_full"] = nil

		StoreItemDetailView._setup_side_panel(self)
	elseif self.is_weapon_preview and not self._bundle_data then
		local slot_name = item.slots[1]
		self._mannequin_loadout[slot_name] = item
		local gear_loadout = self._gear_loadout
		if gear_loadout then
			gear_loadout[slot_name] = item
		end

		CosmeticsInspectView._start_preview_item(self)
	end

	if not self.hide_character then
		-- Show on operative not mannequin
		mod.show_on_character_by_default(self)
	end
end

mod.show_on_character_by_default = function(self)
	if self._weapon_preview then
		if not self._previewed_with_gear then
			CosmeticsInspectView.cb_on_preview_with_gear_toggled(self)
		elseif self._previewed_with_gear then
			CosmeticsInspectView.cb_on_preview_with_gear_toggled(self)
			CosmeticsInspectView.cb_on_preview_with_gear_toggled(self)
		end
	else
		if not self._previewed_with_gear then
			StoreItemDetailView.cb_on_preview_with_gear_toggled(self)
		elseif self._previewed_with_gear then
			StoreItemDetailView.cb_on_preview_with_gear_toggled(self)
			StoreItemDetailView.cb_on_preview_with_gear_toggled(self)
		end
	end
end

-- override generate spawn profile to include account's other characters for previewing
mod._generate_spawn_profile = function(self, item, optional_specific_profile)
	if item then
		local profile = StoreItemDetailView._generic_profile_from_item(self, item)

		self._preview_profile = profile
		self._mannequin_loadout = StoreItemDetailView._generate_mannequin_loadout(self, profile, item)
		self._default_mannequin_loadout = table.clone_instance(self._mannequin_loadout)
		self._mannequin_profile = table.clone_instance(profile)
		self._mannequin_profile.loadout = self._mannequin_loadout

		local player = self:_player()
		local player_profile = player:profile()

		if optional_specific_profile then
			player_profile = optional_specific_profile
		elseif current_profiles then
			for i, operator in pairs(current_profiles) do
				if operator.archetype.name == profile.archetype.name then
					player_profile = operator
				end
			end
		end

		if player_profile then
			local gear_profile = table.clone_instance(player_profile)

			self._default_gear_loadout = table.clone_instance(gear_profile.loadout)
			self._gear_loadout = table.clone_instance(gear_profile.loadout)
			gear_profile.loadout = self._gear_loadout
			gear_profile.character_id = "cosmetics_view_character"
			self._gear_profile = gear_profile
			self._can_preview_with_gear = true
		else
			self._can_preview_with_gear = false
		end

		self._profile = player_profile
		self._presentation_profile = self._profile
		self._preview_profile = self._profile
		-- self._presentation_profile = self._mannequin_profile
		self._spawned_profile = nil
		selected_profile = player_profile
	end
end

mod._refresh_profiles = function(self)
	self._wait_for_character_profiles_refresh = true

	Managers.data_service.profiles
		:fetch_all_profiles()
		:next(function(profile_data)
			self._wait_for_character_profiles_refresh = false
			local profiles = profile_data.profiles
			current_profiles = profiles
		end)
		:catch(function()
			self._wait_for_character_profiles_refresh = false
		end)
end

-- Add buttons to swap preview characters
CosmeticsInspectView._setup_input_legend = function(self)
	local context = self._context
	local use_store_appearance = context.use_store_appearance

	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 50)

	local legend_inputs = Definitions.legend_inputs_cosmetics_inspect_view

	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local valid = true

		if legend_input.store_appearance_option and not use_store_appearance then
			valid = false
		end

		if valid then
			local on_pressed_callback = legend_input.on_pressed_callback
				and callback(self, legend_input.on_pressed_callback)

			self._input_legend_element:add_entry(
				legend_input.display_name,
				legend_input.input_action,
				legend_input.visibility_function,
				on_pressed_callback,
				legend_input.alignment
			)
		end
	end
end

CosmeticsInspectView._setup_side_panel = function(self, element) end

CosmeticsInspectView._destroy_side_panel = function(self) end

mod.get_archetype_symbol = function(archetype)
	local archetype_symbol = ""
	if archetype.name == "veteran" then
		archetype_symbol = ""
	elseif archetype.name == "zealot" then
		archetype_symbol = ""
	elseif archetype.name == "psyker" then
		archetype_symbol = ""
	elseif archetype.name == "ogryn" then
		archetype_symbol = ""
	elseif archetype.name == "adamant" then
		archetype_symbol = ""
	elseif archetype.name == "broker" then
		archetype_symbol = ""
	end

	return archetype_symbol
end

local bundle_restrictions = {}
local len_bundle_restrictions = 0
StoreItemDetailView._setup_side_panel = function(self, element)
	if not self._weapon_preview then
		self:_destroy_side_panel()

		local y_offset = 0
		local scenegraph_id = "side_panel_area"
		local max_width = self._ui_scenegraph[scenegraph_id].size[1]
		local widgets = {}

		self._side_panel_widgets = widgets

		local function _add_text_widget(pass_template, text)
			local widget_definition = UIWidget.create_definition(pass_template, scenegraph_id, nil, {
				max_width,
				0,
			})
			local widget = self:_create_widget(string.format("side_panel_widget_%d", #widgets), widget_definition)

			widget.content.text = text
			widget.offset[2] = y_offset

			local widget_text_style = widget.style.text
			local _, text_height = self:_text_size(text, widget_text_style, {
				max_width,
				math.huge,
			})

			y_offset = y_offset + text_height
			widget.content.size[2] = text_height
			widgets[#widgets + 1] = widget
		end

		local function _add_spacing(height)
			y_offset = y_offset + height
		end

		local item

		if not item and element then
			item = element.item
		end

		if not item and self._items then
			item = self._items[1].item.__master_item
		end

		local is_bundle = false

		if
			element and element.sub_title and element.sub_title == "Bundle"
			or self._store_item and self._store_item.sub_title and self._store_item.sub_title == "Bundle"
		then
			is_bundle = true
		end

		if is_bundle and #self._items > 1 then
			bundle_restrictions = {}
			local restrictions_text
			local present_restrictions
			local hide_restrictions = false
			-- Go through bundle items, and get the restrictions
			for _, item_data in pairs(self._items) do
				item = item_data.item
				if item then
					local properties_text = ItemUtils.item_property_text(item, true)
					restrictions_text, present_restrictions = ItemUtils.restriction_text(item, true)

					local slot_list = {}
					if bundle_restrictions[restrictions_text] then
						slot_list = bundle_restrictions[restrictions_text]
					end

					local item_type
					if item.__master_item then
						item_type = item.__master_item.item_type
					elseif item then
						item_type = item.slot_weapon_skin.__master_item.item_type
						hide_restrictions = true
					end

					if item_type == "GEAR_HEAD" then
						slot_list[#slot_list + 1] = Localize("slot_head")
					elseif item_type == "GEAR_LOWERBODY" then
						slot_list[#slot_list + 1] = Localize("slot_legs")
					elseif item_type == "GEAR_UPPERBODY" then
						slot_list[#slot_list + 1] = Localize("slot_body")
					elseif item_type == "WEAPON_SKIN" then
						slot_list[#slot_list + 1] = Localize("slot_weapon")
					elseif item_type == "GEAR_EXTRA_COSMETIC" then
						slot_list[#slot_list + 1] = Localize("slot_extra")
					end
					bundle_restrictions[restrictions_text] = slot_list
				end
			end

			len_bundle_restrictions = 0
			local multi_restriction_text = ""

			-- setup text to show bundle restrictions
			for rest, slots in pairs(bundle_restrictions) do
				len_bundle_restrictions = len_bundle_restrictions + 1

				for i, slot in pairs(slots) do
					multi_restriction_text = "{#color(113,126,103)}" .. multi_restriction_text .. slot

					if #slots > i then
						multi_restriction_text = multi_restriction_text .. ", "
					end
				end

				multi_restriction_text = multi_restriction_text
					.. "\n{#color(169, 191, 153)}"
					.. rest
					.. "\n{#color(113,126,103)}"
			end

			-- If items in the bundle have different restrictions, then display "Item Dependendant"
			if not hide_restrictions then
				if len_bundle_restrictions > 1 then
					if #widgets > 0 then
						_add_spacing(24)
					end

					_add_text_widget(
						StoreItemDetailViewDefinitions.item_sub_title_pass,
						Utf8.upper(Localize("loc_item_equippable_on_header"))
					)
					_add_spacing(8)
					_add_text_widget(StoreItemDetailViewDefinitions.item_text_pass, multi_restriction_text)
				else
					if #widgets > 0 then
						_add_spacing(24)
					end

					_add_text_widget(
						StoreItemDetailViewDefinitions.item_sub_title_pass,
						Utf8.upper(Localize("loc_item_equippable_on_header"))
					)
					_add_spacing(8)
					_add_text_widget(StoreItemDetailViewDefinitions.item_text_pass, restrictions_text)
				end

				if self._previewed_with_gear then
					-- add current operative
					if #widgets > 0 then
						_add_spacing(24)
					end

					_add_text_widget(
						StoreItemDetailViewDefinitions.item_sub_title_pass,
						Utf8.upper(Localize("loc_CVI_currently_showing"))
					)
					_add_spacing(8)
					local text
					local archetype_name = self._presentation_profile.archetype.name

					local archetype = Archetypes[archetype_name]

					local archetype_symbol = mod.get_archetype_symbol(archetype)

					text = string.format("%s %s", archetype_symbol, self._presentation_profile.name)

					_add_text_widget(StoreItemDetailViewDefinitions.item_text_pass, text)
				end
			end
			for i = 1, #widgets do
				local widget_offset = widgets[i].offset

				widget_offset[1] = 48
				widget_offset[2] = widget_offset[2] - y_offset
			end
		end

		-- Setup text for SINGLE items
		if item and not is_bundle then
			local properties_text = ItemUtils.item_property_text(item, true)
			local restrictions_text, present_restrictions = ItemUtils.restriction_text(item, true)

			if not present_restrictions then
				restrictions_text = nil
			end

			if properties_text then
				if #widgets > 0 then
					_add_spacing(24)
				end

				_add_text_widget(
					StoreItemDetailViewDefinitions.premium_sub_title_pass,
					Utf8.upper(Localize("loc_item_property_header"))
				)
				_add_spacing(8)
				_add_text_widget(StoreItemDetailViewDefinitions.premium_text_pass, properties_text)
			end

			if restrictions_text then
				if #widgets > 0 then
					_add_spacing(24)
				end

				_add_text_widget(
					StoreItemDetailViewDefinitions.item_sub_title_pass,
					Utf8.upper(Localize("loc_item_equippable_on_header"))
				)
				_add_spacing(8)
				_add_text_widget(StoreItemDetailViewDefinitions.item_text_pass, restrictions_text)
			end

			if self._previewed_with_gear then
				-- add current operative
				if #widgets > 0 then
					_add_spacing(24)
				end

				_add_text_widget(
					StoreItemDetailViewDefinitions.item_sub_title_pass,
					Utf8.upper(Localize("loc_CVI_currently_showing"))
				)
				_add_spacing(8)
				local text
				local archetype_name = self._presentation_profile.archetype.name

				local archetype = Archetypes[archetype_name]
				local archetype_symbol = mod.get_archetype_symbol(archetype)

				text = string.format("%s %s", archetype_symbol, self._presentation_profile.name)

				_add_text_widget(StoreItemDetailViewDefinitions.item_text_pass, text)
			end

			for i = 1, #widgets do
				local widget_offset = widgets[i].offset

				widget_offset[1] = 48
				widget_offset[2] = widget_offset[2] - y_offset
			end
		end
	end
end

-- Add buttons to swap preview characters
StoreItemDetailView._setup_input_legend = function(self)
	self._input_legend_element = self:_add_element(ViewElementInputLegend, "input_legend", 10)

	local legend_inputs = Definitions.legend_inputs

	for i = 1, #legend_inputs do
		local legend_input = legend_inputs[i]
		local on_pressed_callback = legend_input.on_pressed_callback
			and callback(self, legend_input.on_pressed_callback)

		self._input_legend_element:add_entry(
			legend_input.display_name,
			legend_input.input_action,
			legend_input.visibility_function,
			on_pressed_callback,
			legend_input.alignment
		)
	end
end

local current_profile_position = 0
mod.cycle_preview_operative = function(self)
	local current_profile = self._presentation_profile
	local class_name = self._presentation_profile and self._presentation_profile.archetype.name
	local found_new_profile = false
	local new_profile

	if not current_profiles then
		mod._refresh_profiles(self)
	end

	local allowed_archetypes

	-- disable swapping operatives on bundles with different item restrictions
	local element = self._selected_element
	local is_bundle = false

	if
		element and element.sub_title and element.sub_title == "Bundle"
		or self._store_item and self._store_item.sub_title and self._store_item.sub_title == "Bundle"
	then
		is_bundle = true
	end

	-- set allowed characters for entire bundle (only characters that ALL items in the bundle can be shown on)
	if is_bundle and self._items then
		local temp_arch
		if self._items then
			if self._items[1].item and self._items[1].item.__master_item then
				temp_arch = self._items[1].item.__master_item.archetypes
			elseif self._items[1].item then
				temp_arch = self._items[1].item.archetypes
			end
		elseif self._context and self._context.preview_item then
			temp_arch = self._context.preview_item.archetypes
		end

		local common_class = {}

		-- find common class between all restricted classes
		for rest1, slots1 in pairs(bundle_restrictions) do
			local all_contain = true
			for rest, slots in pairs(bundle_restrictions) do
				if string.find(rest, rest1) then
				else
					all_contain = false
				end
			end

			if all_contain and temp_arch then
				for i, class in pairs(temp_arch) do
					if string.find(rest1:lower(), class:lower()) then
						common_class[1] = class
					end
				end
			end

			allowed_archetypes = common_class
		end
	end

	if not is_bundle then
		if self._items then
			if self._items[1].item and self._items[1].item.__master_item then
				allowed_archetypes = self._items[1].item.__master_item.archetypes
			elseif self._items[1].item then
				allowed_archetypes = self._items[1].item.archetypes
			end
		elseif self._context and self._context.preview_item then
			allowed_archetypes = self._context.preview_item.archetypes
		end
	end

	if allowed_archetypes then
		local find_in_table = function(search, table)
			for x, y in pairs(table) do
				if y == search then
					return true
				end
			end
			return false
		end

		local allowed_profiles = {}
		if current_profiles then
			for i, profile in pairs(current_profiles) do
				if find_in_table(profile.archetype.name, allowed_archetypes) then
					allowed_profiles[#allowed_profiles + 1] = profile
				end
			end
		end

		if allowed_profiles then
			if current_profile_position >= #allowed_profiles then
				current_profile_position = 1
			else
				current_profile_position = current_profile_position + 1
			end

			if allowed_profiles[current_profile_position] and current_profile then
				if
					allowed_profiles[current_profile_position].name == current_profile.name
					and allowed_profiles[current_profile_position].archetype.name == current_profile.archetype.name
				then
					if current_profile_position >= #allowed_profiles then
						current_profile_position = 1
					else
						current_profile_position = current_profile_position + 1
					end
				end

				-- find profile in list
				if not found_new_profile then
					new_profile = allowed_profiles[current_profile_position]
					found_new_profile = true
				end
			end

			if found_new_profile then
				self._preview_profile = new_profile
				mod.display_cosmetics(self, hide_equipment, new_profile)
				selected_profile = new_profile
			end
		end
	end
end

StoreItemDetailView.cycle_preview_operative = function(self)
	mod.cycle_preview_operative(self)
end

CosmeticsInspectView.cycle_preview_operative = function(self)
	mod.cycle_preview_operative(self)
	CosmeticsInspectView._start_preview_item(self)
end

mod.has_multiple_operatives = function(self)
	if not current_profiles then
		mod._refresh_profiles(self)
	end

	if self._preview_player == false then
		return false
	end

	local has_multiple_operatives_of_same_class = false
	local item
	if self._items then
		if self._items[1].item and self._items[1].item.__master_item then
			item = self._items[1].item.__master_item
		elseif self._items[1].item then
			item = self._items[1].item
		end
	elseif self._context and self._context.preview_item then
		item = self._context.preview_item
	elseif self._preview_item then
		item = self._preview_item
	end

	-- disable swapping operatives on bundles with different item restrictions
	local element = self._selected_element
	local is_bundle = false

	if
		element and element.sub_title and element.sub_title == "Bundle"
		or self._store_item and self._store_item.sub_title and self._store_item.sub_title == "Bundle"
	then
		is_bundle = true
	end

	-- set allowed characters for entire bundle (only characters that ALL items in the bundle can be shown on)
	if is_bundle and item then
		local common_class = {}
		-- find common class between all restricted classes
		for rest1, slots1 in pairs(bundle_restrictions) do
			local all_contain = true
			for rest, slots in pairs(bundle_restrictions) do
				if string.find(rest, rest1) then
				else
					all_contain = false
				end
			end

			if all_contain then
				for i, class in pairs(item.archetypes) do
					if string.find(rest1:lower(), class:lower()) then
						common_class[1] = class
					end
				end
			end
		end

		if item then
			local allowed_archetypes = common_class
			local allowed_characters = {}

			local find_in_table = function(search, table)
				for x, y in pairs(table) do
					if y == search then
						return true
					end
				end
				return false
			end

			if allowed_archetypes then
				if current_profiles then
					for i, profile in pairs(current_profiles) do
						if find_in_table(profile.archetype.name, allowed_archetypes) then
							allowed_characters[#allowed_characters + 1] = profile
						end
					end
				end

				if allowed_characters then
					if #allowed_characters > 1 then
						has_multiple_operatives_of_same_class = true
					end
				end

				local current_profile_is_allowed = false
				for i, allowed_archetype in pairs(allowed_archetypes) do
					if
						self._presentation_profile
						and self._presentation_profile.archetype.name == allowed_archetype
					then
						current_profile_is_allowed = true
					end
				end

				if current_profile_is_allowed == false then
					mod.cycle_preview_operative(self)
				end
			end
		end
	end

	-- if isn't bundle then can do by single item
	if item and not is_bundle then
		local allowed_archetypes = item.archetypes
		local allowed_characters = {}

		local find_in_table = function(search, table)
			for x, y in pairs(table) do
				if y == search then
					return true
				end
			end
			return false
		end

		if allowed_archetypes then
			if current_profiles then
				for i, profile in pairs(current_profiles) do
					if find_in_table(profile.archetype.name, allowed_archetypes) then
						allowed_characters[#allowed_characters + 1] = profile
					end
				end
			end

			if allowed_characters then
				if #allowed_characters > 1 then
					has_multiple_operatives_of_same_class = true
				end
			end
		end
	end

	return has_multiple_operatives_of_same_class
end

StoreItemDetailView.has_multiple_operatives = function(self)
	self.is_weapon_preview = false
	return mod.has_multiple_operatives(self)
end

CosmeticsInspectView.has_multiple_operatives = function(self)
	self.is_weapon_preview = true
	return mod.has_multiple_operatives(self)
end

local ANIMATION_SLOTS_MAP = {
	slot_animation_emote_1 = true,
	slot_animation_emote_2 = true,
	slot_animation_emote_3 = true,
	slot_animation_emote_4 = true,
	slot_animation_emote_5 = true,
	slot_animation_end_of_round = true,
}

StoreItemDetailView._should_show_inspect = function(self, element)
	local _inspect_on_multiple = {
		"WEAPON_SKIN",
		"GEAR_EXTRA_COSMETIC",
		"GEAR_HEAD",
		"GEAR_LOWERBODY",
		"GEAR_UPPERBODY",
	}
	local _inspect_on_single = {
		"WEAPON_SKIN",
		"GEAR_EXTRA_COSMETIC",
		"GEAR_HEAD",
		"GEAR_LOWERBODY",
		"GEAR_UPPERBODY",
	}

	local offer = element.offer
	local is_bundle = not not offer.bundleInfo

	if is_bundle then
		return true
	end

	local item = element.item
	local item_type = item and item.item_type

	if not item_type then
		return false
	end

	local multiple_items = #self._items > 1
	local appropriate_list = multiple_items and _inspect_on_multiple or _inspect_on_single

	return table.array_contains(appropriate_list, item_type)
end

CosmeticsInspectView.toggle_equipment = function(self)
	mod.toggle_equipment(self)
end

StoreItemDetailView.toggle_equipment = function(self)
	mod.toggle_equipment(self)
end

mod.toggle_equipment = function(self)
	hide_equipment = not hide_equipment
	mod.display_cosmetics(self, hide_equipment)
end

CosmeticsInspectView.toggle_view_bundle = function(self)
	mod.toggle_view_bundle(self)
end

StoreItemDetailView.toggle_view_bundle = function(self)
	mod.toggle_view_bundle(self)
end

mod.toggle_view_bundle = function(self)
	view_whole_bundle = not view_whole_bundle
	mod.display_cosmetics(self, hide_equipment)
end

CosmeticsInspectView.show_toggle_equipment = function(self)
	mod.show_toggle_equipment(self)
end

StoreItemDetailView.show_toggle_equipment = function(self)
	mod.show_toggle_equipment(self)
end

mod.show_toggle_equipment = function(self, element)
	local _inspect_on_multiple = {
		"WEAPON_SKIN",
		"GEAR_EXTRA_COSMETIC",
		"GEAR_HEAD",
		"GEAR_LOWERBODY",
		"GEAR_UPPERBODY",
	}
	local _inspect_on_single = {
		"WEAPON_SKIN",
		"GEAR_EXTRA_COSMETIC",
		"GEAR_HEAD",
		"GEAR_LOWERBODY",
		"GEAR_UPPERBODY",
	}

	local offer = element.offer
	local is_bundle = not not offer.bundleInfo

	if is_bundle then
		return true
	end

	local item = element.item
	local item_type = item and item.item_type

	if not item_type then
		return false
	end

	local multiple_items = #self._items > 1
	local appropriate_list = multiple_items and _inspect_on_multiple or _inspect_on_single

	return table.array_contains(appropriate_list, item_type)
end

CosmeticsInspectView.show_toggle_view_bundle = function(self)
	mod.show_toggle_view_bundle(self)
end

StoreItemDetailView.show_toggle_view_bundle = function(self)
	mod.show_toggle_view_bundle(self)
end

local parent_bundle_offer = {}
mod.show_toggle_view_bundle = function(self, element)
	local offer = element.offer
	local is_bundle = not not offer.bundleInfo

	if is_bundle then
		parent_bundle_offer = offer
		return false
	else
		if parent_bundle_offer then
			local isInParentBundle
			if parent_bundle_offer.bundleInfo then
				for i = 1, #parent_bundle_offer.bundleInfo do
					if parent_bundle_offer.bundleInfo[i].offerId == offer.offerId then
						isInParentBundle = true
					end
				end
				if isInParentBundle then
					return true
				else
					parent_bundle_offer = {}
				end
			else
				parent_bundle_offer = {}
			end
		end
		return false
	end
end
