﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.krtrUtils"

-- Unique
if game.state:doneEvent(event_id) then return end

local list = {}

local function check(x, y)
	if not game.state:canEventGrid(level, x, y) then return false end
	if not game.state:canEventGrid(level, x-1, y) or level.map(x-1, y, level.map.ACTOR) then return false end
	return true
end

for i = 1, 7 do
	local x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
	local tries = 0
	while not check(x, y) and tries < 100 do
		x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
		tries = tries + 1
	end
	if tries >= 100 then return false end
	list[#list+1] = {x=x, y=y}
end

local Talents = require("engine.interface.ActorTalents")

game.level.event_cultists = {sacrifice = 0, kill = 0}

for i, p in ipairs(list) do
	local g = game.level.map(p.x, p.y, engine.Map.TERRAIN):cloneFull()
	g.name = "monolith"
	g.kr_name = "석주"
	g.display='&' g.color_r=0 g.color_g=255 g.color_b=255 g.notice = true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/moonstone_0"..rng.range(1,8)..".png", display_y=-1, display_h=2, z=18}
	g:altered()
	g.grow = nil g.dig = nil
	g.special = true
	g.autoexplore_ignore = true
	g.is_monolith = true
	game.zone:addEntity(game.level, g, "terrain", p.x, p.y)

	local m = mod.class.NPC.new{
		type = "humanoid", subtype = "shalore", image = "npc/humanoid_shalore_elven_corruptor.png",
		name = "Cultist",
		kr_name = "광신도",
		desc = [[엘프 광신도입니다. 당신을 신경쓰지 않고 있습니다.]],
		display = "p", color=colors.ORCHID,
		faction = "unaligned",
		combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		lite = 1,
		life_rating = 11,
		rank = 3,
		size_category = 3,
		open_door = true,
		silence_immune = 0.5,
		resolvers.racial(),
		autolevel = "caster",
		ai = "tactical", ai_state = { ai_move="move_complex", talent_in=1, },
		ai_tactic = resolvers.tactic"ranged",
		stats = { str=10, dex=8, mag=20, con=16 },
		level_range = {5, nil}, exp_worth = 1,
		max_life = resolvers.rngavg(100, 110),
		resolvers.equip{
			{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
			{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
		},
		resolvers.talents{
			[Talents.T_BONE_SHIELD]={base=2, every=10, max=5},
			[Talents.T_BLOOD_SPRAY]={base=2, every=10, max=7},
			[Talents.T_DRAIN]={base=2, every=10, max=7},
			[Talents.T_SOUL_ROT]={base=2, every=10, max=7},
			[Talents.T_BLOOD_GRASP]={base=2, every=10, max=6},
			[Talents.T_BONE_SPEAR]={base=2, every=10, max=7},
		},
		resolvers.sustains_at_birth(),
		resolvers.inscriptions(1, "rune"),
		is_cultist_event = true,
		monolith_x = p.x,
		monolith_y = p.y,
		on_die = function(self)
			local g = game.level.map(self.monolith_x, self.monolith_y, engine.Map.TERRAIN)
			if not g or not g.is_monolith then return end
			if self.self_sacrifice then
				self:doEmote(rng.table{"제 영혼을 바칩니다!", "암흑 여왕이 지배할 것입니다!", "저를 바치겠습니다! 저를 데려가십시오!", "죽음에서 삶이 오는 것이니!"}, 60)
				g.add_displays[#g.add_displays].image = g.add_displays[#g.add_displays].image:gsub("/moonstone_0", "/darkgreen_moonstone_0")
				g.name = "corrupted monolith"
				game.level.event_cultists.sacrifice = game.level.event_cultists.sacrifice + 1
			else
				self:doEmote(rng.table{"이건 너무 빨라!", "안돼, 의식이 약해지고 있어!"}, 60)
				g.add_displays[#g.add_displays].image = g.add_displays[#g.add_displays].image:gsub("/moonstone_0", "/bluish_moonstone_0")
				g.name = "disrupted monolith"
				g.kr_name = "방해받은 석주"
				game.level.event_cultists.kill = game.level.event_cultists.kill + 1
			end
			g:removeAllMOs()
			game.level.map:updateMap(self.monolith_x, self.monolith_y)
			if not game.level.turn_counter then
				game.level.event_cultists.queen_x = self.monolith_x
				game.level.event_cultists.queen_y = self.monolith_y
				game.level.turn_counter = 10 * 210
				game.level.max_turn_counter = 10 * 210
				game.level.turn_counter_desc = "광신도들이 무엇인가를 소환하고 있습니다. 주의하십시오."
				require("engine.ui.Dialog"):simplePopup("광신도", "광신도의 영혼이 그가 보호하던 이상한 돌에게 흡수되는 것으로 보입니다. 무슨 일이 생길 것 같은 느낌이 듭니다...")
			end
		end,
	}
	m:resolve() m:resolve(nil, true)
	game.zone:addEntity(game.level, m, "actor", p.x-1, p.y)
end

game.zone.cultist_event_levels = game.zone.cultist_event_levels or {}
game.zone.cultist_event_levels[level.level] = true

if not game.zone.cultist_event_on_turn then game.zone.cultist_event_on_turn = game.zone.on_turn or function() end end
game.zone.on_turn = function()
	if game.zone.cultist_event_on_turn then game.zone.cultist_event_on_turn() end
	if not game.zone.cultist_event_levels[game.level.level] then return end

	if game.level.turn_counter then
		game.level.turn_counter = game.level.turn_counter - 1
		game.player.changed = true
		if game.level.turn_counter < 0 then
			game.level.turn_counter = nil

			local scale = (7 - game.level.event_cultists.kill) / 6

			local Talents = require("engine.interface.ActorTalents")
			local m = mod.class.NPC.new{
				type = "demon", subtype = "major",
				display = 'U',
				name = "Shasshhiy'Kaish", color=colors.VIOLET, unique = true,
				kr_name = "샤쉬히'카이쉬",
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_shasshhiy_kaish.png", display_h=2, display_y=-1}}},
				desc = [[그녀의 머리 위를 떠다니는 화염의 왕관과 세 가닥의 꼬리, 그리고 날카로운 손톱만 뺀다면 이 악마는 아주 매혹적으로 생겼습니다. 그녀를 보는 순간 살을 파버리고 싶은 고통이 느껴지며, 또한 그녀는 당신이 고통받기를 원합니다.]],
				killer_message = "당신은 그녀의 도착적인 욕구를 만족시키기 위해 '사용' 되었습니다.",
				level_range = {25, nil}, exp_worth = 2,
				female = 1,
				faction = "fearscape",
				rank = 4,
				size_category = 4,
				max_life = 250, life_rating = 27, fixed_rating = true,
				infravision = 10,
				stats = { str=25, dex=25, cun=32, mag=26, con=14 },
				move_others=true,

				instakill_immune = 1,
				stun_immune = 0.5,
				blind_immune = 0.5,
				combat_armor = 0, combat_def = 0,

				open_door = true,

				autolevel = "warriormage",
				ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
				ai_tactic = resolvers.tactic"melee",
				resolvers.inscriptions(3, "rune"),

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },

				resolvers.drops{chance=100, nb=math.ceil(5 * scale), {tome_drops="boss"} },

				resolvers.talents{
					[Talents.T_METEOR_RAIN]={base=4, every=5, max=7},
					[Talents.T_INNER_DEMONS]={base=4, every=5, max=7},
					[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
					[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
					[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
					[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
					[Talents.T_SPELLCRAFT]=5,
				},
				resolvers.sustains_at_birth(),

				inc_damage = {all=90},
			}
			if game.level.event_cultists.kill == 1 then
				m.on_die = function(self) world:gainAchievement("EVENT_CULTISTS", game:getPlayer(true)) end
			end
			m:resolve() m:resolve(nil, true)

			local o = mod.class.Object.new{
				define_as = "METEORIC_CROWN",
				slot = "HEAD",
				type = "armor", subtype="head",
				name = "Crown of Burning Pain", image = "object/artifact/crown_of_burning_pain.png",
				unided_name = "burning crown",
				kr_name = "타오르는 고통의 왕관", kr_unided_name = "타오르는 왕관",
				desc = [[이 순수한 불꽃으로 이루어진 왕관의 주변에는, 열에 의해 반쯤 녹은 수많은 암석들이 떠다니고 있습니다. 이 암석들 하나하나를 마치 유성처럼 떨어뜨릴 수 있습니다.]],
				add_name = " (#ARMOR#)",
				power_source = {arcane=true},
				display = "]", color=colors.SLATE,
				moddable_tile = resolvers.moddable_tile("helm"),
				require = { talent = { m.T_ARMOUR_TRAINING }, },
				encumber = 4,
				metallic = true,
				unique = true,
				require = { stat = { cun=25 } },
				level_range = {20, 35},
				cost = 300,
				material_level = 3,
				wielder = {
					inc_stats = { [m.STAT_CUN] = math.floor(scale * 6), [m.STAT_WIL] = math.floor(scale * 6), },
					combat_def = math.floor(3 + scale * 10),
					combat_armor = 0,
					fatigue = 4,
					resists = { [engine.DamageType.FIRE] = 5 + math.floor(scale * 30)},
					inc_damage = { [engine.DamageType.FIRE] = 5 + math.floor(scale * 30)},
				},
				max_power = 50, power_regen = 1,
				use_talent = { id = m.T_METEOR_RAIN, level = 2, power = 50 - math.floor(scale * 25) },
			}
			o:resolve() o:resolve(nil, true)

			local x, y = util.findFreeGrid(game.level.event_cultists.queen_x-1, game.level.event_cultists.queen_y, 10, true, {[engine.Map.ACTOR]=true})
			if x then
				m.inc_damage.all = m.inc_damage.all - 10 * (game.level.event_cultists.kill)
				m.max_life = m.max_life * (14 - game.level.event_cultists.kill) / 14
				game.zone:addEntity(game.level, o, "object")
				m:addObject(m:getInven("INVEN"), o)

				game.zone:addEntity(game.level, m, "actor", x, y)
				require("engine.ui.Dialog"):simpleLongPopup("광신도", "이 지역에 천둥과도 같은 끔찍한 외침이 들립니다 : '여기로 와요, 여기, 내가 저어어엉말로 *잘* 해줄께요!'\n이 지역에서 도망쳐야 합니다!", 400)
			end
		elseif  game.level.turn_counter == 10 * 180 or
			game.level.turn_counter == 10 * 150 or
			game.level.turn_counter == 10 * 120 or
			game.level.turn_counter == 10 * 90 or
			game.level.turn_counter == 10 * 60 or
			game.level.turn_counter == 10 * 30 then
			local cultists = {}
			for uid, e in pairs(game.level.entities) do if e.is_cultist_event then cultists[#cultists+1] = e end end
			if #cultists > 0 then
				local c = rng.table(cultists)
				game.logSeen(c, "%s 단검을 뽑아 그의 가슴을 드러내고, 단검으로 심장을 꿰뚫었습니다. 바위가 증오의 색깔로 물들기 시작합니다.", (c.kr_name or c.name):capitalize():addJosa("가"))
				c.self_sacrifice = true
				c:die()
			end
		end
	end
end

return true
