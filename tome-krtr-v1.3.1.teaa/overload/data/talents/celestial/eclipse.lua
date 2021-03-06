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

newTalent{
	name = "Blood Red Moon",
	kr_name = "핏빛 달",
	type = {"celestial/eclipse", 1},
	mode = "passive",
	require = divi_req1,
	points = 5,
	getCrit = function(self, t) return self:combatTalentScale(t, 3, 15, 0.75) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_spellcrit", t.getCrit(self, t))
	end,
	info = function(self, t)
		return ([[마법 치명타율을 %d%% 증가시킵니다.]]):
		format(t.getCrit(self, t))
	end,
}

newTalent{
	name = "Totality",
	kr_name = "일월식",
	type = {"celestial/eclipse", 2},
	require = divi_req2,
	points = 5,
	cooldown = 30,
	tactical = { BUFF = 2 },
	positive = 10,
	negative = 10,
	fixed_cooldown = true,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9)) end,
	getResistancePenetration = function(self, t) return self:combatLimit(self:getCun()*self:getTalentLevel(t), 100, 5, 0, 55, 500) end, -- Limit to <100%
	getCooldownReduction = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	action = function(self, t)
		self:setEffect(self.EFF_TOTALITY, t.getDuration(self, t), {power=t.getResistancePenetration(self, t)})
		for tid, cd in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[1]:find("^celestial/") then
				self.talents_cd[tid] = cd - t.getCooldownReduction(self, t)
			end
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local penetration = t.getResistancePenetration(self, t)
		local cooldownreduction = t.getCooldownReduction(self, t)
		return ([[빛과 어둠 속성 저항 관통력을 %d 턴 동안 %d%% 증가시키고, 모든 천공 계열 기술의 재사용 대기시간을 %d 턴 감소시킵니다. 
 		저항 관통력은 교활함 능력치의 영향을 받아 증가합니다.]]): 
		format(duration, penetration, cooldownreduction)
	end,
}

newTalent{
	name = "Corona",
	kr_name = "코로나",
	type = {"celestial/eclipse", 3},
	mode = "sustained",
	require = divi_req3,
	points = 5,
	proj_speed = 3,
	range = 6,
	cooldown = 30,
	tactical = { BUFF = 2 },
	sustain_negative = 10,
	sustain_positive = 10,
	getTargetCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5)) end,
	getLightDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	getDarknessDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	on_crit = function(self, t)
		if self:getPositive() < 2 or self:getNegative() < 2 then
		--	self:forceUseTalent(t.id, {ignore_energy=true})
			return nil
		end
		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		for i = 1, t.getTargetCount(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

		local corona = rng.range(1, 100)
			if corona > 50 then
				local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, display={particle="bolt_light"}}
				self:projectile(tg, a.x, a.y, DamageType.LIGHT, t.getLightDamage(self, t), {type="light"})
				self:incPositive(-2)
			else
				local tg = {type="bolt", range=self:getTalentRange(t), talent=t, friendlyfire=false, display={particle="bolt_dark"}}
				self:projectile(tg, a.x, a.y, DamageType.DARKNESS, t.getDarknessDamage(self, t), {type="shadow"})
				self:incNegative(-2)
			end
		end
	end,
	activate = function(self, t)
		local ret = {}
		ret.particle = self:addParticles(Particles.new("circle", 1, {shader=true, toback=true, oversize=1.7, a=155, appear=8, speed=0, img="corona_02", radius=0}))
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local targetcount = t.getTargetCount(self, t)
		local lightdamage = t.getLightDamage(self, t)
		local darknessdamage = t.getDarknessDamage(self, t)
		return ([[주문이 치명타로 적중할 때마다, 주변 %d 칸 반경에 있는 적 %d 명에게 빛이나 어둠의 화살을 발사하여 %0.2f 빛 피해나 %0.2f 어둠 피해를 줍니다. 
 		이 효과가 발동될 때마다 양기나 음기가 2 소모되며, 양기나 음기가 부족하다면 효과가 발동되지 않습니다. 
 		피해량은 주문력의 영향을 받아 증가합니다.]]): 
		format(self:getTalentRange(t), targetcount, damDesc(self, DamageType.LIGHT, lightdamage), damDesc(self, DamageType.DARKNESS, darknessdamage))
	end,
}

newTalent{
	name = "Darkest Light",
	kr_name = "가장 어두운 빛",
	type = {"celestial/eclipse", 4},
	mode = "sustained",
	require = divi_req4,
	points = 5,
	cooldown = 30,
	sustain_negative = 10,
	tactical = { DEFEND = 2, ESCAPE = 2 },
	getInvisibilityPower = function(self, t) return self:combatScale(self:getCun() * self:getTalentLevel(t), 5, 0, 38.33, 500) end,
	getEnergyConvert = function(self, t) return math.max(0, 6 - self:getTalentLevelRaw(t)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 100) end,
	getRadius = function(self, t) return math.floor(self:combatTalentScale(t, 2.5, 4.5)) end,
	callbackOnActBase = function(self, t)
		if self.positive > self.negative then
			self:forceUseTalent(t.id, {ignore_energy=true})
			game.logSeen(self, "%s's darkness can no longer hold back the light!", self.name:capitalize())
		end
	end,
	activate = function(self, t)
		local timer = t.getEnergyConvert(self, t)
		game:playSoundNear(self, "talents/heal")
		local ret = {
			invisible = self:addTemporaryValue("invisible", t.getInvisibilityPower(self, t)),
			invisible_damage_penalty = self:addTemporaryValue("invisible_damage_penalty", 0.5),
			fill = self:addTemporaryValue("positive_regen_ref", -timer),
			drain = self:addTemporaryValue("negative_regen_ref", timer),
			pstop = self:addTemporaryValue("positive_at_rest_disable", 1),
			nstop = self:addTemporaryValue("negative_at_rest_disable", 1),
		}
		if not self.shader then
			ret.set_shader = true
			self.shader = "invis_edge"
			self.shader_args = {color1={1,1,0,1}, color2={0,0,0,1}}
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		ret.particle = self:addParticles(Particles.new("circle", 1, {shader=true, toback=true, oversize=1.7, a=155, appear=8, speed=0, img="darkest_light", radius=0}))
		self:resetCanSeeCacheOf()
		return ret
	end,
	deactivate = function(self, t, p)
		if p.set_shader then
			self.shader = nil
			self:removeAllMOs()
			game.level.map:updateMap(self.x, self.y)
		end
		self:removeTemporaryValue("invisible", p.invisible)
		self:removeTemporaryValue("invisible_damage_penalty", p.invisible_damage_penalty)
		self:removeTemporaryValue("positive_regen_ref", p.fill)
		self:removeTemporaryValue("negative_regen_ref", p.drain)
		self:removeTemporaryValue("positive_at_rest_disable", p.pstop)
		self:removeTemporaryValue("negative_at_rest_disable", p.nstop)
		self:removeParticles(p.particle)
		local tg = {type="ball", range=0, selffire=true, radius= t.getRadius(self, t), talent=t}
		self:project(tg, self.x, self.y, DamageType.LITE, 1)
		tg.selffire = false
		local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, self:spellCrit(t.getDamage(self, t) + self.positive))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y, max_alpha=80})
		game:playSoundNear(self, "talents/flame")
		self.positive = 0
		self:resetCanSeeCacheOf()
		return true
	end,
	info = function(self, t)
		local invisibilitypower = t.getInvisibilityPower(self, t)
		local convert = t.getEnergyConvert(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius(self, t)
		return ([[이 기술이 유지되는 동안 몸이 투명해지며 (투명 수치 +%d), 매 턴마다 %d 만큼의 음기가 양기로 전환됩니다.  
 		양기가 음기를 초과하게 되거나 기술의 유지를 해제하면, 기술의 효과가 끝나면서 찬란한 빛이 폭발하여 주변 %d 칸 반경에 (가지고 있던 양기의 총량 + %0.2f) 피해를 줍니다. 
 		투명화 중에는 현실 세계에서의 존재감이 옅어져, 적을 공격해도 원래 피해의 50%% 밖에 주지 못하게 됩니다. 
 		투명화 중에 등불 따위를 들고 있으면, 투명화를 한 의미가 사실상 없어지게 됩니다. 
 		투명 능력은 교활함 능력치, 폭발 피해량은 주문력의 영향을 받아 증가합니다.]]): 
 		format(invisibilitypower, convert, radius, damDesc(self, DamageType.LIGHT, damage)) --@ 변수 순서 조정 
	end,
}
