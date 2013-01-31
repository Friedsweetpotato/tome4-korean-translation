﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local Talents = require "engine.interface.ActorTalents"
local DamageType = require "engine.DamageType"

load("/data/general/objects/egos/charms.lua")

newEntity{
	name = "arcane ", prefix=true, second=true,
	kr_display_name = "마법 ",
	keywords = {arcane=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		{100, function(self, who) return ("마나 %d 재생"):format(self:getCharmPower(true) / 5) end, function(self, who)
			who:incMana(self:getCharmPower(true) / 5)
		end},
	}
}

newEntity{
	name = "defiled ", prefix=true, second=true,
	kr_display_name = "모독 ",
	keywords = {defiled=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		{100, function(self, who) return ("원기 %d 재생"):format(self:getCharmPower(true) / 6) end, function(self, who)
			who:incVim(self:getCharmPower(true) / 6)
		end},
	}
}

newEntity{
	name = "bright ", prefix=true, second=true,
	kr_display_name = "밝은 ",
	keywords = {bright=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		{100, function(self, who) return ("양기 %d 재생"):format(self:getCharmPower(true) / 8) end, function(self, who)
			who:incPositive(self:getCharmPower(true) / 8)
		end},
	}
}

newEntity{
	name = "shadowy ", prefix=true, second=true,
	kr_display_name = "어두운 ",
	keywords = {shadow=true},
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		{100, function(self, who) return ("음기 %d 재생"):format(self:getCharmPower(true) / 8) end, function(self, who)
			who:incNegative(self:getCharmPower(true) / 8)
		end},
	}
}

newEntity{
	name = "warded ", prefix=true, second=true,
	kr_display_name = "보호 ",
	keywords = {ward=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		wards = {
			[DamageType.FIRE] = resolvers.mbonus_material(4, 1),
			[DamageType.COLD] = resolvers.mbonus_material(4, 1),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(4, 1),
			[DamageType.TEMPORAL] = resolvers.mbonus_material(4, 1),
			[DamageType.BLIGHT] = resolvers.mbonus_material(4, 1),
		},
		learn_talent = {[Talents.T_WARD] = 1},
	},
}

newEntity{
	name = "void ", prefix=true, second=true,
	kr_display_name = "공허 ",
	keywords = {void=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		talent_cd_reduction={[Talents.T_VOID_BLAST]=-6},
		learn_talent = {[Talents.T_VOID_BLAST] = resolvers.mbonus_material(4, 1)},
	},
}

newEntity{
	name = "volcanic ", prefix=true, second=true,
	kr_display_name = "화산 ",
	keywords = {volcanic=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		learn_talent = {[Talents.T_VOLCANO] = resolvers.mbonus_material(4, 1)},
	},
}

newEntity{
	name = "striking ", prefix=true, second=true,
	kr_display_name = "타격 ",
	keywords = {striking=true},
	level_range = {30, 50},
	rarity = 12,
	greater_ego = 1,
	cost = 5,

	wielder = {
		learn_talent = {[Talents.T_STRIKE] = resolvers.mbonus_material(4, 1)},
	},
}
