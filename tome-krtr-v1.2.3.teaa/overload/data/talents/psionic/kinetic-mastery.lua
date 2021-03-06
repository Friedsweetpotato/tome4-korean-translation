﻿-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newTalent{
	name = "Transcendent Telekinesis",
	kr_name = "초월 - 염동력",
	type = {"psionic/kinetic-mastery", 1},
	require = psi_wil_high1,
	points = 5,
	psi = 20,
	cooldown = 30,
	tactical = { BUFF = 3 },
	getPower = function(self, t) return self:combatTalentMindDamage(t, 10, 30) end,
	getPenetration = function(self, t) return self:combatLimit(self:combatTalentMindDamage(t, 10, 20), 100, 4.2, 4.2, 13.4, 13.4) end, -- Limit < 100%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 30, 5, 10)) end, --Limit < 30
	action = function(self, t)
		self:setEffect(self.EFF_TRANSCENDENT_TELEKINESIS, t.getDuration(self, t), {power=t.getPower(self, t), penetration = t.getPenetration(self, t)})
		self:removeEffect(self.EFF_TRANSCENDENT_PYROKINESIS)
		self:removeEffect(self.EFF_TRANSCENDENT_ELECTROKINESIS)
		self:alterTalentCoolingdown(self.T_KINETIC_LEECH, -1000)
		self:alterTalentCoolingdown(self.T_KINETIC_STRIKE, -1000)
		self:alterTalentCoolingdown(self.T_KINETIC_AURA, -1000)
		self:alterTalentCoolingdown(self.T_KINETIC_SHIELD, -1000)
		self:alterTalentCoolingdown(self.T_MINDLASH, -1000)
		return true
	end,
	info = function(self, t)
		return ([[%d 턴 동안, 한계를 뛰어넘은 초월적인 염동력을 다룰 수 있게 됩니다.
		- 물리 피해량이 %d%% / 물리 저항 관통력이 %d%% 상승합니다.
		- 동역학적 보호막, 동역학적 오러 발산, 염력 채찍, 동역학적 흡수 기술의 재사용 대기 시간이 초기화됩니다.
		- 동역학적 보호막의 흡수 효율이 100%% 가 되며, 최대 흡수 가능량이 2 배 증가합니다.
		- 동역학적 오러 발산이 주변 2 칸 범위에 영향을 미치며, 피해량 추가가 적용 가능한 모든 무기에 적용됩니다.
		- 염력 채찍이 기절 효과를 추가로 부여합니다.
		- 동역학적 흡수가 적에게 수면 효과를 추가로 부여합니다.
		- 동역학적 타격이 휩쓸기 공격으로 변해, 대상 옆의 적 2 명을 동시에 공격합니다.
		피해량 증가와 저항 관통력은 정신력의 영향을 받아 증가합니다.
		한번에 하나의 '초월' 기술만을 사용할 수 있습니다.]]):format(t.getDuration(self, t), t.getPower(self, t), t.getPenetration(self, t))
	end,
}


newTalent{
	name = "Kinetic Surge", image = "talents/telekinetic_throw.png",
	kr_name= "동역학적 쇄도",
	type = {"psionic/kinetic-mastery", 2},
	require = psi_wil_high2,
	points = 5,
	random_ego = "attack",
	cooldown = 15,
	psi = 20,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 2 }, ESCAPE = 2 },
	range = function(self, t) return self:combatTalentLimit(t, 10, 6, 9) end,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 20, 180))
	end,
	getKBResistPen = function(self, t) return self:combatTalentLimit(t, 100, 25, 45) end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=2, selffire=false, talent=t} end,
	action = function(self, t)
		local tg = {type="hit", range=1, nowarning=true }
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end
		local dam = self:mindCrit(t.getDamage(self, t))
				
		if self:reactionToward(target) < 0 then
			local tg = self:getTalentTarget(t)
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end

			if target:canBe("knockback") or rng.percent(t.getKBResistPen(self, t)) then
				self:project({type="hit", range=tg.range}, target.x, target.y, DamageType.PHYSICAL, dam) --Direct Damage
				
				local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
				if tx and ty then
					local ox, oy = target.x, target.y
					target:move(tx, ty, true)
					if config.settings.tome.smooth_move > 0 then
						target:resetMoveAnim()
						target:setMoveAnim(ox, oy, 8, 5)
					end
				end
				self:project(tg, target.x, target.y, DamageType.SPELLKNOCKBACK, dam/2) --AOE damage
				if target:canBe("stun") then
					target:setEffect(target.EFF_STUNNED, math.floor(self:getTalentRange(t) / 2), {apply_power=self:combatMindpower()})
				else
					game.logSeen(target, "%s 기절하지 않았습니다!", (target.kr_name or target.name):capitalize():addJosa("가"))
				end
			else --If the target resists the knockback, do half damage to it.
				target:logCombat(self, "#YELLOW##Source1# #Target#의 던지기를 저항했습니다!")
				self:project({type="hit", range=tg.range}, target.x, target.y, DamageType.PHYSICAL, dam/2)
			end
		else
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if core.fov.distance(self.x, self.y, x, y) > tg.range then return nil end

			for i = 1, math.floor(self:getTalentRange(t) / 2) do
				self:project(tg, x, y, DamageType.DIG, 1)
			end
			self:project(tg, x, y, DamageType.MINDKNOCKBACK, dam)
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")

			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, engine.Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or block_actor(_, lx, ly) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			--self:move(tx, ty, true)
			local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not fx then
				self:move(fx, fy, true)
			end
			return true
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local dam = damDesc(self, DamageType.PHYSICAL, t.getDamage(self, t))
		return ([[염동력으로 인접한 존재나 스스로를 밀어냅니다. 
		발사된 자는 목표 지점을 중심으로 반경 %d 칸 안쪽에 떨어지게 됩니다. 
		
		적을 발사한 경우, 상대는 땅에 떨어진 충격으로 %0.1f 물리 피해를 받고, %d 턴 동안 기절하게 됩니다.  
		낙하 지점으로부터 2 칸 이내에 있는 모든 존재는 %0.1f 물리 피해를 받고, 당신과 반대편으로 밀려나게 됩니다.
		이 기술은 대상의 밀어내기 면역력을 %d%% 만큼 무시합니다. 던지기에 실패한 경우에는 피해를 절반만 주게 됩니다.
		
		스스로를 발사한 경우, 직선으로 날아가게 됩니다. 날아가는 동안 경로에 있는 적들은 각각 %0.1f 물리 피해를 받고 밀려나게 됩니다.
		이렇게 날아가는 동안 %d 개의 벽을 파괴하여 뚫고 지나갈 수 있습니다.
		피해량은 정신력의 영향을 받아 증가하고, 사정거리는 정신력과 힘 능력치의 영향을 받아 증가합니다.]]):
		format(range, dam, math.floor(range/2), dam/2, t.getKBResistPen(self, t), dam, math.floor(range/2))
	end,
}


newTalent{
	name = "Deflect Projectiles",
	kr_name = "투사체 편향",
	type = {"psionic/kinetic-mastery", 3},
	require = psi_wil_high3, 
	points = 5,
	mode = "sustained", no_sustain_autoreset = true,
	sustain_psi = 25,
	cooldown = 10,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 3, 5, "log")) end, 
	radius = 10,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), selffire=false, talent=t}
	end,
	getEvasion = function(self, t) return self:combatTalentLimit(t, 100, 17, 45), self:getTalentLevel(t) >= 4 and 2 or 1 end, -- Limit chance <100%
	activate = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return {
			chance = self:addTemporaryValue("projectile_evasion", chance),
			spread = self:addTemporaryValue("projectile_evasion_spread", spread),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("projectile_evasion", p.chance)
		self:removeTemporaryValue("projectile_evasion_spread", p.spread)
		if self:attr("save_cleanup") then return true end
		
		local tg = self:getTalentTarget(t)
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRadius(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local i = 0
			local p = game.level.map(x, y, Map.PROJECTILE+i)
			while p do
				if p.project and p.project.def.typ.source_actor ~= self then
					p.project.def.typ.line_function = core.fov.line(p.x, p.y, tx, ty)
				end
				
				i = i + 1
				p = game.level.map(x, y, Map.PROJECTILE+i)
			end
		end end

		game.level.map:particleEmitter(self.x, self.y, self:getTalentRadius(t), "shout", {additive=true, life=10, size=3, distorion_factor=0.0, radius=self:getTalentRadius(t), nb_circles=4, rm=0.8, rM=1, gm=0, gM=0, bm=0.8, bM=1.0, am=0.4, aM=0.6})
		
		return true
	end,
	info = function(self, t)
		local chance, spread = t.getEvasion(self, t)
		return ([[투사체를 붙잡고 튕겨내는 등, 투사체를 편향시키는데 정신을 집중합니다.
		시전자를 대상으로 한 모든 투사체는 %d%% 확률로 주변 %d 칸 반경의 다른 곳에 명중하게 됩니다.
		유지 중인 기술을 해제하는 것으로, 주변 10 칸 반경의 모든 투사체를 붙잡아 주변 %d 칸 반경의 특정 위치에 내꽂을 수도 있습니다.
		하지만 이를 사용할 경우 집중력이 흐트러지게 됩니다.]]):
		format(chance, spread, self:getTalentRange(t))
	end,
}

newTalent{
	name = "Implode",
	kr_name = "내파",
	type = {"psionic/kinetic-mastery", 4},
	require = psi_wil_high4,
	points = 5,
	random_ego = "attack",
	cooldown = 20,
	psi = 35,
	tactical = { ATTACK = { PHYSICAL = 2 }, DISABLE = 2 },
	range = 5,
	getDuration = function (self, t)
		return math.ceil(self:combatTalentMindDamage(t, 2, 6))
	end,
	getDamage = function (self, t)
		return math.floor(self:combatTalentMindDamage(t, 66, 132))
	end,
	requires_target = true,
	target = function(self, t) return {type="ball", range=self:getTalentRange(t), radius=0, selffire=false, talent=t} end,
	action = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.IMPLOSION, {dur=dur, dam=dam})
		local target = game.level.map(x, y, Map.ACTOR)
		if target then
			target:setEffect(self.EFF_PSIONIC_BIND, dur, {power=1, apply_power=self:combatMindpower()})
		end
		return true
	end,
	info = function(self, t)
		local dur = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		return ([[대상에게 극도의 압력을 지속적으로 불어넣어, 매 턴마다 %0.1f 물리 피해를 주고 속박 및 50%% 만큼 감속시킵니다.
		지속 시간과 피해량은 정신력의 영향을 받아 증가합니다.]]):
		format(damDesc(self, DamageType.PHYSICAL, dam), dur)
	end,
}
