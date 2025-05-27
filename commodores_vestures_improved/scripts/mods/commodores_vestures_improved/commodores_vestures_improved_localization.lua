local mod = get_mod("commodores_vestures_improved")

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

return {
	mod_description = {
		en =
		"Adds a bunch of QoL features to the Commodore's Vestures (premium) shop. Including letting you preview bundles and showing items directly on your characters, without having to re-enter the store as the correct class.",
		ru =
		"Commodore's Vestures Improved - Добавляет ряд полезных функций в премиум-магазин «Одеяние от Командора». В том числе позволяет вам предварительно просматривать наборы и отображать предметы прямо на ваших персонажах, без необходимости повторно входить в магазин нужным классом.",
		["zh-cn"] = "为「准将的服装」提供一系列QOL（生活质量）功能。包含预览同捆包及直接在角色身上展示物品，且无须以正确的职业重新进入商店。",
	},
	mod_name = {
		en = "Commodore's Vestures Improved",
		ru = "Улучшенные «Одеяния от Командора»",
		["zh-cn"] = "准将的服装改进",
	}
}
