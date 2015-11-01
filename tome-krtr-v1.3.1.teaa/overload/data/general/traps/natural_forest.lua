-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

newEntity{ define_as = "TRAP_NATURAL_FOREST",
	type = "natural", subtype="forest", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		self:project({type="hit",x=x,y=y}, x, y, self.damtype, self.dam or 10, self.particles and {type=self.particles})
		return true
	end,
}

newEntity{ base = "TRAP_NATURAL_FOREST",
	name = "sliding rock", auto_id = true, image = "trap/trap_slippery_rocks_01.png",
	detect_power = resolvers.clscale(6,50,8),
	disarm_power = resolvers.clscale(16,50,8),
	rarity = 3, level_range = {1, 50},
	color=colors.UMBER,
	pressure_trap = true,
	message = "@Target@ slides on a rock!",
	triggered = function(self, x, y, who)
		if who:canBe("stun") then
			who:setEffect(who.EFF_STUNNED, 4, {apply_power=self.disarm_power + 5})
		else
			game.logSeen(who, "%s resists!", who.name:capitalize())
		end
		return true
	end
}

newEntity{ base = "TRAP_NATURAL_FOREST",
	name = "poison vine", auto_id = true, image = "trap/poison_vines01.png",
	detect_power = resolvers.clscale(8,50,8),
	disarm_power = resolvers.clscale(2,50,8),
	rarity = 3, level_range = {1, 50},
	color=colors.GREEN,
	message = "A poisonous vine strikes at @Target@!",
	dam = resolvers.clscale(100, 15, 25, 0.75, 0),
	damtype = DamageType.POISON,
	combatAttack = function(self) return self.dam end
}
