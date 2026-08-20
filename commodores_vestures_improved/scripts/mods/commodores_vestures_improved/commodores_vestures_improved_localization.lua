local mod = get_mod("commodores_vestures_improved")
mod.version = "1.6.10"
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
		["zh-tw"] = "變更特工",
	},
	loc_CVI_toggle_equipment = {
		en = "Toggle Equipment",
		ru = "Переключить снаряжение",
		["zh-cn"] = "切换装备",
		["zh-tw"] = "切換裝備",
	},
	loc_CVI_toggle_view_bundle = {
		en = "Toggle Bundle View",
		ru = "Переключить вид наборов",
		["zh-cn"] = "切换同捆包预览",
		["zh-tw"] = "切換同捆包預覽",
	},
	loc_CVI_currently_showing = {
		en = "Currently showing on Operative:",
		ru = "Сейчас на оперативнике отображается:",
		["zh-cn"] = "已在特工身上显示",
		["zh-tw"] = "已在特工身上顯示",
	},
	slot_head = {
		en = "Head",
		ru = "Голова",
		["zh-cn"] = "头部",
		["zh-tw"] = "頭部",
	},
	slot_body = {
		en = "Body",
		ru = "Тело",
		["zh-cn"] = "上半身",
		["zh-tw"] = "上半身",
	},
	slot_legs = {
		en = "Legs",
		ru = "Ноги",
		["zh-cn"] = "下半身",
		["zh-tw"] = "下半身",
	},
	slot_extra = {
		en = "Extra",
		ru = "Аксессуары",
		["zh-cn"] = "配件",
		["zh-tw"] = "配件",
	},
	slot_weapon = {
		en = "Weapon",
		ru = "Оружие",
		["zh-cn"] = "武器",
		["zh-tw"] = "武器",
	},
	slot_weapon_trinket = {
		en = "Weapon Trinket",
		ru = "Безделушка оружия",
		["zh-cn"] = "武器饰品",
		["zh-tw"] = "武器飾品",
	},
})

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function utf8_chars(s)
	local chars = {}
	for char in string.gmatch(s, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(chars, char)
	end
	return chars
end

mod.gradientText = function(text, startColor, endColor, colorSpaces)
	local result = ""
	local chars = utf8_chars(text)
	local visibleIndex = 0

	for _, char in ipairs(chars) do
		if colorSpaces or char ~= " " then
			visibleIndex = visibleIndex + 1
		end
	end

	local currentIndex = 0

	for _, char in ipairs(chars) do
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

	result = "{#color(" .. colours.title .. ")}" .. result .. "{#reset()}"
	return result
end

local mod_name = {
	en = "Commodore's Vestures Improved",
	ru = "Улучшенные «Одеяния от Командора»",
	["zh-cn"] = "准将的服装改进",
	["zh-tw"] = "準將的服裝改進",
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
		["zh-tw"] = "為「準將的服裝」提供一系列QOL（生活品質）功能。包含預覽同捆包及直接在角色身上展示物品，且無須以正確的職業重新進入商店。",
	},
	mod_name = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
		["zh-tw"] = mod_name["zh-tw"],
	},
	mod_name_pizazz = {
		en = mod.gradientText(mod_name["en"], { 223, 39, 255 }, { 255, 141, 38 }, true),
		ru = mod.gradientText(mod_name["ru"], { 223, 39, 255 }, { 255, 141, 38 }, true),
		["zh-cn"] = mod.gradientText(mod_name["zh-cn"], { 223, 39, 255 }, { 255, 141, 38 }, true),
		["zh-tw"] = mod.gradientText(mod_name["zh-tw"], { 223, 39, 255 }, { 255, 141, 38 }, true),
	},
	mod_name_boring = {
		en = mod_name["en"],
		ru = mod_name["ru"],
		["zh-cn"] = mod_name["zh-cn"],
		["zh-tw"] = mod_name["zh-tw"],
	},
	mod_name_pizazz_toggle = {
		en = "Enable Name Pizazz",
		ru = "Включить красочное название",
		["zh-cn"] = "启用名称特效",
		["zh-tw"] = "啟用名稱特效",
	},
	mod_name_pizazz_tooltip = {
		en = "Toggles the rainbow colours effect on the mod name text. Requires a reload.\nIf enabled, you will get a small euphoric experience everytime you scroll through the mod menu, \nIf disabled - you will be a John Darktide and have no rainbow sprinkles (but I'll love you anyway).",
		ru = "Включает радужный эффект на тексте названия мода. Требуется перезагрузка.\nЕсли включено, вы получите небольшой эйфорический опыт каждый раз, когда прокручиваете меню модов,\nЕсли выключено - вы будете Джоном Дарктайдом и не будете иметь радужных посыпок (но я всё равно буду любить вас).",
		["zh-cn"] = "切换模组名称文本上的彩虹颜色效果。需要重新加载。\n启用后，每次滚动模组菜单时您都会获得小小的愉悦体验，\n禁用后 - 您将是一个普通暗潮玩家，没有彩虹糖（但我仍然爱您）。",
		["zh-tw"] = "切換模組名稱文字上的彩虹顏色效果。需要重新載入。\n啟用後，每次滾動模組選單時您都會獲得小小的愉悅體驗，\n停用後 - 您將是一個普通暗潮玩家，沒有彩虹糖（但我仍然愛您）。",
	},
	general_settings = {
		en = "{#color(" .. colours.title .. ")}General Settings{#reset()}",
		ru = "{#color(" .. colours.title .. ")}Основные настройки{#reset()}",
		["zh-cn"] = "{#color(" .. colours.title .. ")}常规设置{#reset()}",
		["zh-tw"] = "{#color(" .. colours.title .. ")}常規設定{#reset()}",
	},
	placeholder = {
		en = "",
	},
	placeholder_tooltip = {
		en = "A placeholder entry to initialise the mod menu, does not do anything yet.\nMore features may be added at some point.",
		ru = "Заполнитель для инициализации меню модов, пока ничего не делает.\nВозможно, в будущем будут добавлены дополнительные функции.",
		["zh-cn"] = "用于初始化模组菜单的占位项，目前没有任何功能。\n未来可能会添加更多功能。",
		["zh-tw"] = "用於初始化模組選單的占位項，目前沒有任何功能。\n未來可能會新增更多功能。",
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
