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

require "engine.krtrUtils"

newInscription = function(t)
	-- Warning, up that if more than 5 inscriptions are ever allowed
	for i = 1, 6 do
		local tt = table.clone(t)
		tt.short_name = tt.name:upper():gsub("[ ]", "_").."_"..i
		tt.display_name = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{t.name, " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return t.name
			end
		end
		tt.kr_display_name = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{(t.kr_name or t.name), " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return (t.kr_name or t.name)
			end
		end
		if tt.type[1] == "inscriptions/infusions" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_INFUSION_COOLDOWN) end
		elseif tt.type[1] == "inscriptions/runes" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_RUNE_COOLDOWN) end
		elseif tt.type[1] == "inscriptions/taints" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_TAINT_COOLDOWN) end
		end
		tt.auto_use_warning = "- 포화 상태가 아닐 경우에만, 자동으로 사용합니다"
		tt.cooldown = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			return data.cooldown
		end
		tt.old_info = tt.info
		tt.info = function(self, t)
			local ret = t.old_info(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.use_stat and data.use_stat_mod then
				ret = ret..("\n 효과는 %s 능력치의 영향을 받아 증가합니다."):format(self.stats_def[data.use_stat].name:krStat())
			end
			return ret
		end
		if not tt.image then
			tt.image = "talents/"..(t.short_name or t.name):lower():gsub("[^a-z0-9_]", "_")..".png"
		end
		tt.no_unlearn_last = true
		tt.is_inscription = true
		newTalent(tt)
	end
end

-----------------------------------------------------------------------
-- Infusions
-----------------------------------------------------------------------
newInscription{
	name = "Infusion: Regeneration",
	kr_name = "주입 : 재생",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_REGENERATION, data.dur, {power=(data.heal + data.inc_stat) / data.dur})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, %d 턴 동안 총 %d 생명력을 회복합니다.]]):format(data.dur, data.heal + data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 턴 동안 총 %d 생명력 회복]]):format(data.dur, data.heal + data.inc_stat) --@ 변수 순서 조정
	end,
}

newInscription{
	name = "Infusion: Healing",
	kr_name = "주입 : 치료",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	is_heal = true,
	no_energy = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:attr("allow_on_heal", 1)
		self:attr("disable_ancestral_life", 1)
		self:heal(data.heal + data.inc_stat, t)
		self:attr("disable_ancestral_life", -1)
		self:attr("allow_on_heal", -1)

		self:removeEffectsFilter(function(e) return e.subtype.wound end, 1)
		self:removeEffectsFilter(function(e) return e.subtype.poison end, 1)
		
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, %d 생명력을 즉시 회복하고 1 개의 상처나 독 효과를 치료합니다.]]):format(data.heal + data.inc_stat) 
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[생명력 %d 회복]]):format(data.heal + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Wild",
	kr_name = "주입 : 자연",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local data = self:getInscriptionData(t.short_name)
			return #self:effectsFilter({types=data.what, status="detrimental"})
		end
	},
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local force = {}
		local removed = 0

		removed = target:removeEffectsFilter({types=data.what, subtype={["cross tier"] = true}, status="detrimental"})
		removed = removed + target:removeEffectsFilter({types=data.what, status="detrimental"}, 1)

		if removed > 0 then
			game.logSeen(self, "%s 치료되었습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end
		self:setEffect(self.EFF_PAIN_SUPPRESSION, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concatNice(table.keys(data.what), ", ", " or ")
		what = what:gsub("physical", "물리적"):gsub("magical", "마법적"):gsub("mental", "정신적")
		return ([[주입된 힘을 사용하여 나쁜 %s 상태효과를 제거하고, %d 턴 동안 시전자가 받는 피해량이 %d%% 감소합니다.]]):format(what, data.dur, data.power+data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		what = what:gsub("physical", "물리적"):gsub("magical", "마법적"):gsub("mental", "정신적")
		return ([[피해량 %d%% 감소, %s 상태효과 치료]]):format(data.power + data.inc_stat, what)
	end,
}

-- fixedart wild variant
newInscription{
	name = "Infusion: Primal", image = "talents/infusion__wild.png",
	kr_name = "주입 : 근원",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local data = self:getInscriptionData(t.short_name)
			return #self:effectsFilter({types=data.what, status="detrimental"})
		end
	},
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local force = {}
		local removed = 0

		removed = target:removeEffectsFilter({types=data.what, subtype={["cross tier"] = true}, status="detrimental"})
		removed = removed + target:removeEffectsFilter({types=data.what, status="detrimental"}, 1)
		if removed > 0 then
			game.logSeen(self, "%s 치료되었습니다!", (self.kr_name or self.name):capitalize():addJosa("가"))
		end
		self:setEffect(self.EFF_PRIMAL_ATTUNEMENT, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concatNice(table.krEffectKeys(data.what), ", ", " or ")
		return ([[주입된 힘을 사용하여 무작위로 %s 효과를 치료하고, %d 턴 동안 전체 피해 친화를 %d%% 상승시킵니다.]]):format(what, data.dur,  data.power+data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.krEffectKeys(data.what), ", ") --@ 상태효과 이름 한글화
		return ([[피해 친화 %d%% / %s 치료]]):format(data.power + data.inc_stat, what)
	end,
}

newInscription{
	name = "Infusion: Movement",
	kr_name = "주입 : 이동",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { DEFEND = 1 },
	on_pre_use = function(self, t) return not self:attr("never_move") end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_FREE_ACTION, data.dur, {power=1})
		game:onTickEnd(function() self:setEffect(self.EFF_WILD_SPEED, 1, {power=data.speed + data.inc_stat}) end)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 이동 속도가 %d%% 증가합니다.
		이동 속도가 굉장히 빨라지기 때문에, 상대적으로 게임의 전체적인 턴은 느리게 진행됩니다.
		이 효과는 게임의 전체적인 턴으로 1 턴이 지나거나, 이동을 제외한 다른 행동을 하면 사라집니다.
		그리고, %d 턴 동안 기절, 혼절, 속박 상태효과에 걸리지 않게 됩니다.]]):format(data.speed + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d%% 이동 속도, 상태효과 완전 면역 %d 턴]]):format(data.speed + data.inc_stat, data.dur)
	end,
}



newInscription{
	name = "Infusion: Sun",
	kr_name = "주입 : 태양",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = 1, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	requires_target = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local apply = self:rescaleCombatStats((data.power + data.inc_stat))
		
		self:project(tg, self.x, self.y, engine.DamageType.BLINDCUSTOMMIND, {power=apply, turns=data.turns})
		self:project(tg, self.x, self.y, engine.DamageType.BREAK_STEALTH, {power=apply/2, turns=data.turns})
		tg.selffire = true
		self:project(tg, self.x, self.y, engine.DamageType.LITE, apply >= 19 and 100 or 1)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local apply = self:rescaleCombatStats((data.power + data.inc_stat))
		return ([[주입된 힘을 사용하여, 주변 %d 칸을 밝게 비춥니다. 빛에 의해 은신 중인 적의 은신 수치가 %d 감소하여, 은신이 해제될 수도 있습니다. %s
		빛에 노출된 적들은 %d 턴 동안 실명 상태효과에 걸립니다. (실명 수치 +%d)]]):
		format(data.range, apply/2, apply >= 19 and "\n이 강렬한 빛은 마법적인 어둠마저 없애버릴 수 있습니다." or "", data.turns, apply) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local apply = self:rescaleCombatStats((data.power + data.inc_stat))
		return ([[범위 %d, 위력 %d, %d 턴 유지%s]]):format(data.range, apply, data.turns, apply >= 19 and "; 마법적 어둠 제거" or "")
	end,
}

newInscription{
	name = "Infusion: Heroism",
	kr_name = "주입 : 영웅",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_HEROISM, data.dur, {power=data.power + data.inc_stat, die_at=data.die_at + data.inc_stat * 30})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 시전자의 세 가지 주요 능력치 (가장 높은 능력치) 를 %d 턴 동안 %d 만큼 올립니다.
		영웅 효과가 지속되는 동안에는 생명력이 0 이 되도 죽지 않으며, -%d 생명력이 되어야 사망합니다. 
		하지만 생명력이 0 이하로 떨어지면 남은 생명력을 알 수 없게 됩니다.
		생명력이 0 이하인 상태로 주입물의 효과가 끝날 경우, 생명력이 1 로 회복됩니다.]]):format(data.dur, data.power + data.inc_stat, data.die_at + data.inc_stat * 30) --@ 변수 순서 조정 
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[능력치 +%d, %d 턴 유지, 생명력 하한 -%d]]):format(data.power + data.inc_stat, data.dur, data.die_at + data.inc_stat * 30)
	end,
}

newInscription{
	name = "Infusion: Insidious Poison",
	kr_name = "주입 : 잠식형 독",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACK = { NATURE = 1 }, DISABLE=1, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime", trail="slimetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.INSIDIOUS_POISON, {dam=data.power + data.inc_stat, dur=7, heal_factor=data.heal_factor}, {type="slime"})
		self:removeEffectsFilter({status="detrimental", type="magical", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주입된 힘을 사용하여, 독을 뱉습니다. 독에 맞은 대상은 7 턴 동안 매 턴마다 %0.2f 자연 피해를 입으며, 회복 효율이 %d%% 감소합니다.
		갑작스러운 자연적 힘의 흐름으로, 당신이 가지고 있던 임의의 나쁜 마법 상태이상 효과 하나가 사라집니다.]]):format(damDesc(self, DamageType.NATURE, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 자연 피해, 회복 효율 %d%% 감소]]):format(damDesc(self, DamageType.NATURE, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
}

-- Opportunity cost for this is HUGE, it should not hit friendly, also buffed duration
newInscription{
	name = "Infusion: Wild Growth",
	kr_name = "주입 : 야생",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = { PHYSICAL = 1, NATURE = 1 }, DISABLE = 3 },
	range = 0,
	radius = 5,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire = false, talent=t}
	end,
	getDamage = function(self, t) return 10 + self:combatMindpower() * 3.6 end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			DamageType:get(DamageType.ENTANGLE).projector(self, tx, ty, DamageType.ENTANGLE, dam)
		end)
		self:setEffect(self.EFF_THORNY_SKIN, data.dur, {hard=data.hard or 30, ac=data.armor or 50})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local damage = t.getDamage(self, t)
		return ([[땅에서 덩굴이 솟아나 %d 턴 동안 주변 %d 칸 반경에 있는 적들의 발을 묶고, %0.2f 물리 피해, %0.2f 자연 피해를 줍니다.
		덩굴은 당신의 주변에서도 솟아나, 당신의 방어도를 %d 만큼 올려주고 방어 효율도 %d 만큼 올려줍니다.]]):
		format(self:getTalentRadius(t), data.dur, damDesc(self, DamageType.PHYSICAL, damage)/3, damDesc(self, DamageType.NATURE, 2*damage)/3, data.armor or 50, data.hard or 30)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 속박, %d 턴 유지]]):format(self:getTalentRadius(t), data.dur)
	end,
}

-----------------------------------------------------------------------
-- Runes
-----------------------------------------------------------------------
newInscription{
	name = "Rune: Phase Door",
	kr_name = "룬 : 근거리 순간이동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:setEffect(self.EFF_OUT_OF_PHASE, data.dur or 3, {
			defense=(data.power or data.range) + data.inc_stat * 3 + (self:attr("defense_on_teleport") or 0),
			resists=(data.power or data.range) + data.inc_stat * 3 + (self:attr("resist_all_on_teleport") or 0),
			effect_reduction=(data.power or data.range) + data.inc_stat * 3 + (self:attr("effect_reduction_on_teleport") or 0),
		})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = (data.power or data.range) + data.inc_stat * 3
		return ([[룬을 발동하여, %d 칸 주변의 무작위한 곳으로 순간이동합니다.
		그 이후, %d 턴 동안 당신은 현실에서 조금 벗어나 있게 됩니다. 그동안 모든 나쁜 상태이상 효과의 지속시간은 %d%% 만큼 감소하고, 회피도가 %d 만큼 상승하며, 전체 저항이 %d%% 상승합니다.]]):
		format(data.range + data.inc_stat, data.dur or 3, power, power, power)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = (data.power or data.range) + data.inc_stat * 3
		return ([[주변 %d 칸 무작위 순간이동 (세기 %d), %d 턴 간 현실에서 벗어남]]):format(data.range + data.inc_stat, power, data.dur or 3)
	end,
}

newInscription{
	name = "Rune: Controlled Phase Door",
	kr_name = "룬 : 제어된 근거리 순간이동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=data.range + data.inc_stat, radius=3, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		-- Check LOS
		local rad = 3
		if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
			game.logPlayer(self, "순간이동 제어에 실패하여, 무작위한 곳으로 이동됩니다!")
			x, y = self.x, self.y
			rad = tg.range
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 칸 주변의 원하는 곳에 순간이동합니다.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 제어된 순간이동]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Teleportation",
	kr_name = "룬 : 원거리 순간이동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { ESCAPE = 3 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat, 15)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 최소 15 칸에서 최대 %d 칸 이내의 무작위한 곳으로 순간이동합니다.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[최대 %d 칸 이내 무작위 순간이동]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Shielding",
	kr_name = "룬 : 보호막",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	allow_autocast = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 최대 %d 피해량을 막아주는 보호막을 만들어냅니다.]]):format(data.dur, data.power + data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 피해 흡수, %d 턴 유지]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Reflection Shield",
	kr_name = "룬 : 반사 보호막",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	allow_autocast = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = 100+5*self:getMag()
		if data.power and data.inc_stat then power = data.power + data.inc_stat end
		self:setEffect(self.EFF_DAMAGE_SHIELD, data.dur or 5, {power=power, reflect=100})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = 100+5*self:getMag()
		if data.power and data.inc_stat then power = data.power + data.inc_stat end
		return ([[룬을 발동하여, %d 턴 동안 최대 %d 피해량을 반사하는 보호막을 만들어냅니다.
		반사량은 마법 능력치의 영향을 받아 증가합니다.]]):format(data.dur or 5, power)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = 100+5*self:getMag()
		if data.power and data.inc_stat then power = data.power + data.inc_stat end
		return ([[%d 피해 반사, %d 턴 유지]]):format(power, data.dur or 5)
	end,
}

newInscription{
	name = "Rune: Invisibility",
	kr_name = "룬 : 투명화",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DEFEND = 3, ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_INVISIBILITY, data.dur, {power=data.power + data.inc_stat, penalty=0.4})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 투명해집니다. (투명 수치 +%d)
		투명해지면 현실에서의 존재감이 떨어져 적에게 원래 피해량의 40%% 밖에 줄 수 없게 됩니다.
		]]):format(data.dur, data.power + data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[투명화 (투명 수치 +%d), %d 턴 유지]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Speed",
	kr_name = "룬 : 가속",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_energy = true,
	tactical = { BUFF = 4 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_SPEED, data.dur, {power=(data.power + data.inc_stat) / 100})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, %d 턴 동안 전체 속도를 %d%% 증가시킵니다.]]):format(data.dur, data.power + data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[전체 속도 +%d%%, %d 턴 유지]]):format(data.power + data.inc_stat, data.dur)
	end,
}


newInscription{
	name = "Rune: Vision",
	kr_name = "룬 : 심안",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_npc_use = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:magicMap(data.range, self.x, self.y, function(x, y)
			local g = game.level.map(x, y, Map.TERRAIN)
			if g and (g.always_remember or g:check("block_move")) then
				for _, coord in pairs(util.adjacentCoords(x, y)) do
					local g2 = game.level.map(coord[1], coord[2], Map.TERRAIN)
					if g2 and not g2:check("block_move") then return true end
				end
			end
		end)
		self:setEffect(self.EFF_SENSE_HIDDEN, data.dur, {power=data.power + data.inc_stat})
		self:setEffect(self.EFF_RECEPTIVE_MIND, data.dur, {what=data.esp or "humanoid"})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 주변 %d 칸 반경의 시야를 %d 턴 동안 밝힙니다. 투명한 적과 은신한 적도 발견할 수 있게 됩니다. (투명, 은신 감지력 +%d)
		당신의 정신은 %d 턴 동안 더욱 수용적이 되어, 주변의 모든 %s 감지하게 됩니다.]]):
		format(data.range, data.dur, data.power + data.inc_stat, data.dur, (data.esp or "humanoid"):krActorType():addJosa("를")) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 턴 동안 주변 %d 칸 시야 확보 및 탐지, %s 감지]]):format(data.dur, data.range, (data.esp or "humanoid"):krActorType()) --@ 변수 순서 조정
	end,
}

local function attack_rune(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].is_attack_rune and not self.talents_cd[tid] then
			self.talents_cd[tid] = 1
		end
	end
end

newInscription{
	name = "Rune: Heat Beam",
	kr_name = "룬 : 열기 발산",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { FIRE = 1 }, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "physical" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=5, initial=0, dam=data.power + data.inc_stat})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		self:removeEffectsFilter({status="detrimental", type="physical", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/fire")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 적에게 5 턴 동안 %0.2f 화염 피해를 줍니다.
		열기의 격렬함에 의해, 당신이 가진 임의의 나쁜 물리 상태이상 효과 하나가 사라지게 됩니다.]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 화염 피해]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Biting Gale",
	kr_name = "룬 : 살을 에는 강풍",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { COLD = 1 }, DISABLE = { stun = 1 }, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "mental" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	range = 0,
	target = function(self, t)
		return {type="cone", cone_angle=25, radius = 6, range=self:getTalentRange(t), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local damage = data.power + data.inc_stat -- Cut by ~2/3rds or so
		local apply = self:rescaleCombatStats((data.apply + data.inc_stat))

	--	local apply = data.apply + data.inc_stat -- Same calculation as Sun Infusion, goes above what PCs can get on power stats pretty easily
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end
			
			-- Minor damage, apply stun resist reduction, freeze
			DamageType:get(DamageType.COLD).projector(target, tx, ty, DamageType.COLD, damage)
			target:setEffect(target.EFF_WET, 5, {apply_power=data.inc_stat})
			if target:canBe("stun") then
				target:setEffect(target.EFF_FROZEN, 2, {hp=damage*1.5, apply_power=apply})
			end
		end, data.power + data.inc_stat, {type="freeze"})
		self:removeEffectsFilter({status="detrimental", type="mental", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/ice")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local apply = self:rescaleCombatStats((data.apply + data.inc_stat))
		return ([[룬을 발동시켜, %0.2f 냉기 피해를 주는 원뿔 모양의 차가운 강풍을 만들어냅니다.
		강풍은 적들을 젖게 만들어 기절 저항력을 50%% 감소시키고, 3 턴 동안 빙결시키려고 시도합니다. (얼음의 생명력 : %d).
		또한 짙은 냉기가 당신의 정신을 명확하게 만들어, 당신이 가진 임의의 나쁜 정신 상태이상 효과 하나가 사라지게 됩니다.]]): 
			format(damDesc(self, DamageType.COLD, data.power + data.inc_stat), apply)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local apply = self:rescaleCombatStats((data.apply + data.inc_stat))
		return ([[%d 냉기 피해, 빙결 (얼음 생명력 %d)]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat), apply) 
	end,
}

newInscription{
	name = "Rune: Acid Wave",
	kr_name = "룬 : 산성 파동",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = {
		ATTACKAREA = { ACID = 1 },
		CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end
	},
	requires_target = true,
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.radius
	end,
	target = function(self, t)
		return {type="cone", radius=self:getTalentRadius(t), range = 0, selffire=false, cone_angle=5, talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		local apply = self:rescaleCombatStats((data.apply + data.inc_stat))

		self:removeEffectsFilter({status="detrimental", type="magical", ignore_crosstier=true}, 1)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target or target == self then return end

			if target:canBe("disarm") then
				target:setEffect(target.EFF_DISARMED, data.dur, {apply_power=apply})
			end
			
			DamageType:get(DamageType.ACID).projector(self, tx, ty, DamageType.ACID, data.power + data.inc_stat)

		end)

		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_acid", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/slime")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		  local data = self:getInscriptionData(t.short_name)
		  local pow = data.apply + data.inc_stat
		  local apply = self:rescaleCombatStats((data.apply + data.inc_stat))
		  return ([[룬을 발동시켜, %d 칸 반경에 %0.2f 산성 피해를 주는 원뿔 모양의 산성 파동을 만들어냅니다. 산의 부식성으로 인해, 적들은 %d 턴 동안 무장해제 됩니다. (파워 : %d)
		  또한 산성의 자연적인 힘을 통해, 임의의 나쁜 마법 상태이상 효과 하나가 사라지게 됩니다.]]): 
			 format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, data.power + data.inc_stat), data.dur or 3, apply)
	   end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local pow = data.power
		local apply = self:rescaleCombatStats((data.apply + data.inc_stat))

		return ([[%d 산성 피해, 지속 %d 턴, 파워 %d]]):format(damDesc(self, DamageType.ACID, data.power + data.inc_stat), data.dur or 3, apply) 
	end,
}

newInscription{
	name = "Rune: Lightning",
	kr_name = "룬 : 번개",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { LIGHTNING = 1 } },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = data.power + data.inc_stat
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		self:setEffect(self.EFF_ELEMENTAL_SURGE_LIGHTNING, 2, {})
		game:playSoundNear(self, "talents/lightning")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local dam = damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat)
		return ([[룬을 발동하여, 적에게 %0.2f - %0.2f 전기 피해를 줍니다.
		또한 %d 턴 동안 당신은 순수한 번개로 변신합니다. 번개로 변신 중에 피해를 받을 경우, 한 턴에 한 번 적에게 공격을 받았을 때 인접한 곳으로 피해 공격을 무시할 수 있습니다.]]):
		format(dam / 3, dam, 2)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 전기 피해]]):format(damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Manasurge",
	kr_name = "룬 : 마나의 급류",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { MANA = 1 },
	on_pre_use = function(self, t)
		return self:knowTalent(self.T_MANA_POOL) and not self:hasEffect(self.EFF_MANASURGE)
	end,
	on_learn = function(self, t)
		self.mana_regen_on_rest = (self.mana_regen_on_rest or 0) + 0.5
	end,
	on_unlearn = function(self, t)
		self.mana_regen_on_rest = (self.mana_regen_on_rest or 0) - 0.5
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:incMana((data.mana + data.inc_stat) / 20)
		if self.mana_regen > 0 then
			self:setEffect(self.EFF_MANASURGE, data.dur, {power=self.mana_regen * (data.mana + data.inc_stat) / 100})
		else
			if self.mana_regen < 0 then
				game.logPlayer(self, "시간이 지날수록 마나가 감소하고 있기 때문에, 룬의 효과가 없습니다.")
			else
				game.logPlayer(self, "마나가 존재하지 않기 때문에, 룬의 효과가 없습니다.")
			end
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 마나를 빠르게 회복합니다. 사용 즉시 %d 마나가 회복되며, 추가로 %d 턴에 걸쳐 턴당 마나 회복 효율이 %d%% 증가합니다.
		그리고, 휴식하는 동안 매 턴마다 마나가 0.5 씩 회복됩니다.]]):format((data.mana + data.inc_stat) / 20, data.dur, data.mana + data.inc_stat) --@ 변수 순서 조정
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 턴 동안 마나 회복 효율 %d%%, 사용 즉시 %d 마나 회복]]):format(data.dur, data.mana + data.inc_stat, (data.mana + data.inc_stat) / 20) --@ 변수 순서 조정
	end,
}

newInscription{
	name = "Rune: Frozen Spear",
	kr_name = "룬 : 빙결의 창",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { COLD = 1 }, DISABLE = { stun = 1 }, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "mental" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE, data.power + data.inc_stat, {type="freeze"})
		self:removeEffectsFilter({status="detrimental", type="mental", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/ice")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[룬을 발동하여, 적에게 %0.2f 냉기 피해를 줍니다. 대상을 얼릴 확률이 있습니다.
		또한 짙은 냉기가 당신의 정신을 명확하게 만들어, 당신이 가진 임의의 나쁜 정신 상태이상 효과 하나가 사라지게 됩니다.]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 냉기 피해]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
}


-- This is mostly a copy of Time Skip :P
newInscription{
	name = "Rune of the Rift",
	kr_name = "균열의 룬",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DISABLE = 2, ATTACK = { TEMPORAL = 1 } },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	range = 6,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return 150 + self:getWil() * 4 end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s 적용 대상이 아닙니다!", (target.kr_name or target.name):capitalize():addJosa("는"))
			return true
		end

		local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s 저항했습니다!", (target.kr_name or target.name):capitalize():addJosa("가")) return true end

		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		self:incParadox(-25)
		if target.dead or target.player then return true end
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		
	-- Placeholder for the actor
		local oe = game.level.map(x, y, Map.TERRAIN+1)
		if (oe and oe:attr("temporary")) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then game.logPlayer(self, "Something has prevented the timetravel.") return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = "temporal", subtype = "instability",
			name = "temporal instability",
			kr_name = "불안정한 시공간",
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					-- remove ourselves
					if self.old_feat then game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN+1, self.old_feat)
					else game.level.map:remove(self.target.x, self.target.y, engine.Map.TERRAIN+1) end
					game.nicer_tiles:updateAround(game.level, self.target.x, self.target.y)
					game.level:removeEntity(self)
					game.level.map:removeParticleEmitter(self.particles)
					
					-- return the actor and reset their values
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					local old_check = self.target.check
					self.target.forceLevelup = function() end
					self.target.check = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
					self.target.check = old_check
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		-- Remove the target
		game.logSeen(target, "%s 미래로 보내졌습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
		game.level:removeEntity(target, true)
		
		-- add the time skip object to the map
		local particle = Particles.new("wormhole", 1, {image="shockbolt/terrain/temporal_instability_yellow", speed=1})
		particle.zdepth = 6
		e.particles = game.level.map:addParticleEmitter(particle, x, y)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN+1, e)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[대상에게 %0.2f 시간 피해를 줍니다. 대상이 죽지 않았다면, 대상을 %d 턴 뒤의 미래로 보내버립니다.
		이 룬을 사용하면 괴리 수치가 60 감소합니다. (괴리 원천력을 사용할 때 한정)
		시공간의 흐름을 지나치게 어지럽히면, 가끔 예상치 못한 결과가 일어날 수도 있습니다.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
	short_info = function(self, t)
		return ("%0.2f 시간 피해, %d 턴 미래로 이동"):format(t.getDamage(self, t), t.getDuration(self, t))
	end,
}

-----------------------------------------------------------------------
-- Taints
-----------------------------------------------------------------------
newInscription{
	name = "Taint: Devourer",
	kr_name = "감염 : 포식자",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1, HEAL=1 },
	requires_target = true,
	direct_hit = true,
	no_energy = true,
	range = 5,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" or e.type == "physical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					effs[#effs+1] = {"talent", tid}
				end
			end

			local nb = data.effects
			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				else
					target:forceUseTalent(eff[2], {ignore_energy=true})
				end
				self:attr("allow_on_heal", 1)
				self:heal(data.heal + data.inc_stat, t)
				self:attr("allow_on_heal", -1)
				if core.shader.active(4) then
					self:addParticles(Particles.new("shader_shield_temp", 1, {size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
					self:addParticles(Particles.new("shader_shield_temp", 1, {size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
				end
			end

			game.level.map:particleEmitter(px, py, 1, "shadow_zone")
		end)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[감염으로 생긴 능력을 사용하여 적의 상태효과 %d 개를 먹어치우고, 먹어치운 상태효과 1 개마다 %d 생명력을 회복합니다.]]):format(data.effects, data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d 상태효과 제거 / %d 생명력 회복]]):format(data.effects, data.heal + data.inc_stat)
	end,
}


newInscription{
	name = "Taint: Telepathy",
	kr_name = "감염 : 감지",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	range = 10,
	action = function(self, t)
		local rad = self:getTalentRange(t)
		self:setEffect(self.EFF_SENSE, 5, {
			range = rad,
			actor = 1,
		})
		self:setEffect(self.EFF_WEAKENED_MIND, 10, {save=10, power=35})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[마음의 장벽을 %d 턴 동안 벗어던져 %d 칸 반경의 적들을 감지할 수 있게 되지만, 10 턴 동안 정신 내성이 %d 감소하고 정신력이 %d 상승하게 됩니다.]]):format(data.dur, self:getTalentRange(t), 10, 35)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[주변 %d 칸 적 감지, %d 턴 유지]]):format(self:getTalentRange(t), data.dur)
	end,
}

