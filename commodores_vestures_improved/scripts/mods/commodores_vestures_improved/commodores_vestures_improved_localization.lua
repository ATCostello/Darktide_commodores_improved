local mod = get_mod("commodores_vestures_improved")
mod.version = "1.6.09"
mod:info("Commodore's Vestures Improved is installed, using version: " .. tostring(mod.version))

local colours = {
	title = "200,140,20",
	subtitle = "226,199,126",
	text = "169,191,153",
}

mod:add_global_localize_strings({

	loc_CVI_swap_operative = {
		en = "Change Operative",
		ru = "Сменить оперативника",
		["zh-cn"] = "变更特工",
	},
	loc_CVI_toggle_equipment = {
		en = "Toggle Equipment",
		ru = "Переключить снаряжение",
		["zh-cn"] = "切换装备",
	},
	loc_CVI_toggle_view_bundle = {
		en = "Toggle Bundle View",
		ru = "Переключить вид наборов",
		["zh-cn"] = "切换同捆包预览",
	},
	loc_CVI_currently_showing = {
		en = "Currently showing on Operative:",
		ru = "Сейчас на оперативнике отображается:",
		["zh-cn"] = "已在特工身上显示",
	},
	slot_head = {
		en = "Head",
		ru = "Голова",
		["zh-cn"] = "头部",
	},
	slot_body = {
		en = "Body",
		ru = "Тело",
		["zh-cn"] = "上半身",
	},
	slot_legs = {
		en = "Legs",
		ru = "Ноги",
		["zh-cn"] = "下半身",
	},
	slot_extra = {
		en = "Extra",
		ru = "Аксессуары",
		["zh-cn"] = "配件",
	},
	slot_weapon = {
		en = "Weapon",
		ru = "Оружие",
		["zh-cn"] = "武器",
	},
	slot_weapon_trinket = {
		en = "Weapon Trinket",
	},
})

local function lerp(a, b, t)
	return a + (b - a) * t
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local length = #text
	local visibleIndex = 0

	-- Count visible characters
	for i = 1, length do
		local char = text:sub(i, i)
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for i = 1, length do
		local char = text:sub(i, i)

		if not colorSpaces and char == " " then
			result = result .. char
		else
			currentIndex = currentIndex + 1
			local t = (visibleIndex <= 1) and 0 or (currentIndex - 1) / (visibleIndex - 1)

			local r = math.floor(lerp(startColor[1], endColor[1], t))
			local g = math.floor(lerp(startColor[2], endColor[2], t))
			local b = math.floor(lerp(startColor[3], endColor[3], t))

			result = result .. string.format("{#color(%d,%d,%d)}%s", r, g, b, char)
		end
	end

	result = "{#color(" .. colours.title .. ")} " .. result .. "{#reset()}"
	return result
end

local mod_name = {
	en = "Commodore's Vestures Improved",
	ru = "Улучшенные «Одеяния от Командора»",
	["zh-cn"] = "准将的服装改进",
}

mod.localisation = {
	mod_description = {
		en = "{#color("
			.. colours.text
			.. ")}"
			.. "Preview bundles, show items directly on any character and more, to improve the commodore's vestures screen."
			.. "{#reset()}\n\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Author: "
			.. "{#color("
			.. colours.text
			.. ")}Alfthebigheaded\n"
			.. "{#color("
			.. colours.subtitle
			.. ")}Version: {#color("
			.. colours.text
			.. ")}"
			.. mod.version
			.. "{#reset()}",
		ru = "Commodore's Vestures Improved - Добавляет ряд полезных функций в премиум-магазин «Одеяние от Командора». В том числе позволяет вам предварительно просматривать наборы и отображать предметы прямо на ваших персонажах, без необходимости повторно входить в магазин нужным классом.",
		["zh-cn"] = "为「准将的服装」提供一系列QOL（生活质量）功能。包含预览同捆包及直接在角色身上展示物品，且无须以正确的职业重新进入商店。",
	},
	mod_name = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
	},
	mod_name_pizazz = {
		en = mod.gradientText(mod_name["en"], { 223, 39, 255 }, { 255, 141, 38 }, true),
		ru = mod.gradientText(mod_name["ru"], { 223, 39, 255 }, { 255, 141, 38 }, true),
		["zh-cn"] = mod.gradientText(mod_name["zh-cn"], { 223, 39, 255 }, { 255, 141, 38 }, true),
	},
	mod_name_boring = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
	},
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
	},
	general_settings = {
		en = "{#color(" .. colours.title .. ")}General Settings{#reset()}",
	},
	placeholder = {
		en = "",
	},
	placeholder_tooltip = {
		en = "A placeholder entry to initialise the mod menu, does not do anything yet.\nMore features may be added at some point.",
	},
}

mod.toggle_pizazz = function()
	for key, values in pairs(mod.localisation) do
		if key == "mod_name" then
			for language, text in pairs(values) do
				if mod:get("mod_name_pizazz_toggle") then
					mod.localisation[key][language] = mod.localisation["mod_name_pizazz"][language]
				else
					mod.localisation[key][language] = mod.localisation["mod_name_boring"][language]
				end
			end
		end
	end
end

mod.toggle_pizazz()

return mod.localisation
