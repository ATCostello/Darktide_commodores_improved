local mod = get_mod("commodores_vestures_improved")
mod.version = "1.6.06"
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
})

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
		en = "{#color("
			.. colours.title
			.. ")} "
			.. "{#color(223,39,255)}C{#color(224,42,246)}o{#color(225,46,238)}m{#color(226,50,229)}m{#color(227,54,221)}o{#color(229,58,213)}d{#color(230,62,204)}o{#color(231,66,196)}r{#color(232,70,188)}e{#color(234,74,179)}'{#color(235,78,171)}s {#color(236,82,163)}V{#color(237,86,154)}e{#color(239,90,146)}s{#color(240,93,138)}t{#color(241,97,129)}u{#color(242,101,121)}r{#color(243,105,113)}e{#color(245,109,104)}s {#color(246,113,96)}I{#color(247,117,88)}m{#color(248,121,79)}p{#color(250,125,71)}r{#color(251,129,63)}o{#color(252,133,54)}v{#color(253,137,46)}e{#color(255,141,38)}d{#reset()}",
		ru = "Улучшенные «Одеяния от Командора»",
		["zh-cn"] = "准将的服装改进",
	},
	mod_name_boring = {
		en = "Commodore's Vestures Improved",
	},
	mod_name_pizazz = {
		en = "{#color("
			.. colours.title
			.. ")} "
			.. "{#color(223,39,255)}C{#color(224,42,246)}o{#color(225,46,238)}m{#color(226,50,229)}m{#color(227,54,221)}o{#color(229,58,213)}d{#color(230,62,204)}o{#color(231,66,196)}r{#color(232,70,188)}e{#color(234,74,179)}'{#color(235,78,171)}s {#color(236,82,163)}V{#color(237,86,154)}e{#color(239,90,146)}s{#color(240,93,138)}t{#color(241,97,129)}u{#color(242,101,121)}r{#color(243,105,113)}e{#color(245,109,104)}s {#color(246,113,96)}I{#color(247,117,88)}m{#color(248,121,79)}p{#color(250,125,71)}r{#color(251,129,63)}o{#color(252,133,54)}v{#color(253,137,46)}e{#color(255,141,38)}d{#reset()}",
		ru = "Улучшенные «Одеяния от Командора»",
		["zh-cn"] = "准将的服装改进",
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
