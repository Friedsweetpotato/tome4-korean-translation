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

load("/data/general/grids/basic.lua")
load("/data/general/grids/forest.lua")
load("/data/general/grids/water.lua")
load("/data/general/grids/snowy_forest.lua")
load("/data/general/grids/elven_forest.lua")
load("/data/general/grids/mountain.lua", function(e)
	if e.image == "terrain/rocky_ground.png" then
		e.image = "terrain/snowy_grass.png"
	end
end)

newEntity{ base = "FLOOR", define_as = "COBBLESTONE",
	name="cobblestone road",
	kr_name = "조약돌 포장도로",
	display='.', image="terrain/stone_road1.png",
	special_minimap = colors.DARK_GREY,
}
