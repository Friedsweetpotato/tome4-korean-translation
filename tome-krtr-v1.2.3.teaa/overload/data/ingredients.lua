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

-------------------------------------------------------------------
-- For alchemist quests
-------------------------------------------------------------------

newIngredient{ id = "TROLL_INTESTINE",
	type = "organic",
	icon = "object/troll_intestine.png",
	name = "length of troll intestine",
	kr_name = "트롤의 창자",
	desc = [[기다란 트롤의 창자입니다. 다행스럽게도, 트롤은 요근래 먹은게 없는 모양입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "주기 전에 속의 내용물은 비워주면 고맙겠네만.",
}

newIngredient{ id = "SKELETON_MAGE_SKULL",
	type = "organic",
	icon = "object/skeleton_mage_skull.png",
	name = "skeleton mage skull",
	kr_name = "스켈레톤 마법사 두개골",
	desc = [[스켈레톤 마법사의 두개골입니다. 눈은 빛나지 않고 있습니다... 지금까지는요.]],
	min = 0, max = INFINITY,
	alchemy_text = "만약 눈이 아직도 빛나고 있다면, 희미해질 때까지 여기저기 두들겨보게나. 난 또 다른 마법사 놈이 살아나서 내 연구실에서 소동을 피우는걸 바라지 않네.",
}

newIngredient{ id = "RITCH_STINGER",
	type = "organic",
	icon = "object/ritch_stinger.png",
	name = "ritch stinger",
	kr_name = "릿치 가시",
	desc = [[릿치의 가시는 아직도 독액으로 번들거립니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "가능하다면, 독액을 보존해주게.",
}

newIngredient{ id = "ORC_HEART",
	type = "organic",
	icon = "object/orc_heart.png",
	name = "orc heart",
	kr_name = "오크의 심장",
	desc = [[오크의 심장입니다. 이 사실에 놀랄 사람도 있겠지만, 이 심장은 녹색이 아닙니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "만약 뛰고 있는 오크 심장을 가져온다면 더 좋겠지만... 내 눈에 당신이 고위 사령술사로 보이지는 않는구먼.",
}

newIngredient{ id = "NAGA_TONGUE",
	type = "organic",
	icon = "object/naga_tongue.png",
	name = "naga tongue",
	kr_name = "나가의 혀",
	desc = [[잘라낸 나가의 혀입니다. 소금물 냄새가 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "불경한 말로 오염된 적이 없는 혀가 있다면 최고라네. 그러니 만약 성스러운 나가를 알게 된다면...",
}

newIngredient{ id = "GREATER_DEMON_BILE",
	type = "organic",
	icon = "object/phial_demon_blood.png",
	name = "vial of greater demon bile",
	kr_name = "고위 악마의 담즙이 담긴 약병",
	desc = [[고위 악마의 담즙이 담긴 약병입니다. 약병의 마개가 단단히 고정되어 있는데도, 코가 상할 정도의 악취가 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그게 그러라고 말하더라도, 마시면 안 돼.",
}

newIngredient{ id = "BONE_GOLEM_DUST",
	type = "organic",
	icon = "object/pouch_bone_giant_dust.png",
	name = "pouch of bone giant dust",
	kr_name = "해골 거인의 가루 주머니",
	desc = [[해골 거인을 움직이던 마법이 사라지면, 해골 거인은 부서져 가루가 됩니다. 가루를 자세히 보고 있으면, 왠지 모르게 가끔 가루가 스스로 움직이는 것 같습니다. 뭐, 상상력이 워낙 풍부해서 그렇게 보이는 거겠죠.]],
	min = 0, max = INFINITY,
	alchemy_text = "절대로, 마늘 가루와 착각하지 말게나. 날 믿어.",
}

newIngredient{ id = "FROST_ANT_STINGER",
	type = "organic",
	icon = "object/ice_ant_stinger.png",
	name = "ice ant stinger",
	kr_name = "얼음 개미 침",
	desc = [[위협적일 정도로 뾰족하며, 아직도 빙점의 냉기가 남아있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "독액을 없애야 하는 문제점이 남아있긴 하지만, 이것은 놀랍게도 즉석에서 음료를 차갑게 마실 수 있는 빨대로 쓸 수 있다네.",
}

newIngredient{ id = "MINOTAUR_NOSE",
	type = "organic",
	icon = "object/minotaur_nose.png",
	name = "minotaur nose",
	kr_name = "미노타우루스의 코",
	desc = [[고리가 달린, 미노타우루스의 잘린 코의 앞쪽입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "되도록이면 고리가 붙어있는, 비싸보이는 놈으로 찾아주게나.",
}

newIngredient{ id = "ELDER_VAMPIRE_BLOOD",
	type = "organic",
	icon = "object/vial_elder_vampire_blood.png",
	name = "vial of elder vampire blood",
	kr_name = "흡혈귀 장로의 피가 담긴 약병",
	desc = [[짙고 응고되었으며 악취가 납니다. 약병을 만지는 것만으로도 냉기가 전해져옵니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "이걸 얻었다면, 돌아오는 길에 흐르는 물을 건너보게. 흡혈귀는 흐르는 물을 그렇게 무서워한다는데...",
}

newIngredient{ id = "MULTIHUED_WYRM_SCALE",
	type = "organic",
	icon = "object/dragon_scale_multihued.png",
	name = "multi-hued wyrm scale",
	kr_name = "무지개빛 용 비늘",
	desc = [[아름다우며, 엄청나게 튼튼합니다. 용의 비늘을 떼어내는 것은 아주 힘든 일입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "이 비늘을 모으기 힘들다면, 한번 용해시켜보게나.",
}

newIngredient{ id = "SPIDER_SPINNERET",
	type = "organic",
	icon = "object/spider_spinnarets.png",
	name = "giant spider spinneret",
	kr_name = "거대 거미의 방적돌기",
	desc = [[이상하게 생긴, 거대 거미에게서 찢어낸 한 부분입니다. 구멍에 약간의 거미줄이 튀어나와 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "너네 헛간에 있는 거미는 아냐. 마즈'에이알에서는 꽤 희귀한 종이지만, 딱 보면 저게 거대 거미라는 것을 알 수 있을거야.",
}

newIngredient{ id = "HONEY_TREE_ROOT",
	type = "organic",
	icon = "object/honey_tree_root.png",
	name = "honey tree root",
	kr_name = "벌꿀나무 뿌리",
	desc = [[벌꿀나무 뿌리의 끝부분을 잘라낸 것입니다. 가끔씩 꿈틀거리며, 언뜻 보기에는 죽은 것 같지도 않습니다... 그리고 이것은 *식물* 입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "단단히 잡고 있게. 바닥에 두면 이놈들은 알아서 땅을 파고 들어가버린다구.",
}

newIngredient{ id = "BLOATED_HORROR_HEART",
	type = "organic",
	icon = "object/bloated_horror_heart.png",
	name = "bloated horror heart",
	kr_name = "부풀어오른 공포의 심장",
	desc = [[질병의 근원처럼 보이며, 악취가 납니다. 딱 보면 알 수 있는 사실이지만, 부패했습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "터져도 걱정할거 없어. 그냥 닿지만 않으면 돼.",
}

newIngredient{ id = "ELECTRIC_EEL_TAIL",
	type = "organic",
	icon = "object/electric_eel_tail.png",
	name = "electric eel tail",
	kr_name = "전기뱀장어 꼬리",
	desc = [[미끈미끈하고 꿈틀거리며 전기가 파직거리고 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "아네, 안다구. 뱀장어의 꼬리가 어디부터인지 말이지? 그건 중요치 않아. 끝에서 25 cm 정도만 가져오라구.",
}

newIngredient{ id = "SQUID_INK",
	type = "organic",
	icon = "object/vial_squid_ink.png",
	name = "vial of squid ink",
	kr_name = "오징어 먹물이 든 약병",
	desc = [[짙고 시커멓고 불투명합니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "자네는 내가 이런걸 모으라고 시켜서 짜증나는가? 먹물 악취가 연구실에 가득 차면 나는 더 짜증이 난다네.",
}

newIngredient{ id = "BEAR_PAW",
	type = "organic",
	icon = "object/bear_paw.png",
	name = "bear paw",
	kr_name = "곰 발",
	desc = [[크고 털이 무성하며 살갗을 찢어버리는 발톱이 달려있습니다. 물고기 냄새가 조금 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "내가 마을의 사냥꾼에게서 이걸 구할 수 있다고 생각하는가? 그들은 그럴만한 운이 없다네. 자네는 곰에게 잡아먹히지 말게나.",
}

newIngredient{ id = "ICE_WYRM_TOOTH",
	type = "organic",
	icon = "object/frost_wyrm_tooth.png",
	name = "ice wyrm tooth",
	kr_name = "냉기 용 이빨",
	desc = [[세월에 의해 조금 닳았지만, 아직 그 역할을 충분히 할 수 있을 것 같은 이빨입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "냉기 용은 이빨이 자주 빠지니까, 운이 좋으면 싸우지 않고도 구할 수 있을게야. 하지만 옷은 따뜻하게 입고 가야하네.",
}

newIngredient{ id = "RED_CRYSTAL_SHARD",
	type = "organic",
	icon = "object/red_crystal_shard.png",
	name = "red crystal shard",
	kr_name = "붉은 수정 파편",
	desc = [[그 열기가 사그라들었다고 생각했지만, 아직 투명한 수정 속의 작은 불꽃은 천상의 춤을 추고 있습니다...]],
	min = 0, max = INFINITY,
	alchemy_text = "엘발라 주변의 동굴에서 찾을 수 있다고 들었네. 또한 이건 자연적으로 연소된다고 알고 있으니, 들고 있다가 화상을 입어도 나에게 그 이유를 묻지 말게.",
}

newIngredient{ id = "FIRE_WYRM_SALIVA",
	type = "organic",
	icon = "object/vial_fire_wyrm_saliva.png",
	name = "vial of fire wyrm saliva",
	kr_name = "화염 용의 타액이 든 약병",
	desc = [[투명하고 물보다 조금 짙습니다. 흔들면 거품이 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "불을 피울 때 그 물건과는 거리를 두게. 내가 자네보다 더 파릇파릇한, 새로운 모험가를 구하는 것을 보기 싫다면 말이지.",
}

newIngredient{ id = "GHOUL_FLESH",
	type = "organic",
	icon = "object/ghoul_flesh.png",
	name = "chunk of ghoul flesh",
	kr_name = "구울 살점 조각",
	desc = [[완전히 썩었으며, 악취가 납니다. 아직도 가끔씩 살점이 씰룩거립니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "자네에겐 불행한 일이겠지만, 구울에게서 자연적으로 떨어져 나간 살점은 필요없네. 싱싱한 놈에게서 잘라낸 살점이 필요하다네.",
}

newIngredient{ id = "MUMMY_BONE",
	type = "organic",
	icon = "object/mummified_bone.png",
	name = "mummified bone",
	kr_name = "미이라화된 뼈",
	desc = [[이 고대의 뼈에는 마른 피부가 약간 붙어있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "미이라화가 된 시체의 뼈라네. 사실 약간의 피부도 붙어있지만, 미이라를 걷어차서 찾을 수 있는건 거의 뼈밖에 없어. 저주받지 않은 놈으로 구해오는걸 추천하네.",
}

newIngredient{ id = "SANDWORM_TOOTH",
	type = "organic",
	icon = "object/sandworm_tooth.png",
	name = "sandworm tooth",
	kr_name = "지렁이 이빨",
	desc = [[작고 어두운 회색이며 굉장히 뾰족합니다. 뼈라기보다는 돌에 더 가까운 것 같습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그래, 지렁이도 이빨이 있지. 아주 작고, 자네가 여태껏 보아온 것들과는 많이 다르겠지만 말야.",
}

newIngredient{ id = "BLACK_MAMBA_HEAD",
	type = "organic",
	icon = "object/black_mamba_head.png",
	name = "black mamba head",
	kr_name = "검은 맘바 머리",
	desc = [[검은 맘바의 다른 부분과는 달리, 잘린 머리는 움직이지 않습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그놈한테 물려도, 머리를 갖고 돌아오면 내가 살려줄 수 있다네... 단지 일 분 안에 나한테 보여줘야 되겠지만 말야. 행운을 비네.",
}

newIngredient{ id = "SNOW_GIANT_KIDNEY",
	type = "organic",
	icon = "object/snow_giant_kidney.png",
	name = "snow giant kidney",
	kr_name = "설원 거인 신장",
	desc = [[일반적인 노출된 장기와 마찬가지로, 보기 불쾌합니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "설원 거인을 죽일 때 꿰뚫는 무기를 쓰지는 말게. 다른 놈을 또 찾아봐야 할지도 몰라.",
}

newIngredient{ id = "STORM_WYRM_CLAW",
	type = "organic",
	icon = "object/storm_wyrm_claw.png",
	name = "storm wyrm claw",
	kr_name = "폭풍 용 발톱",
	desc = [[푸르스름하고 굉장히 날카롭습니다. 팔에 닿으면 정전기가 일어난 듯 털이 곤두섭니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "뒷발에 달린 발톱을 잘라오는걸 추천하네. 제일 작고 뽑기도 쉬운데다 사용하지 않아서 날카롭거든. 그러니 찔리지 않게 주의하게. 참, 용에게 잡아먹히지도 말게나.",
}

newIngredient{ id = "GREEN_WORM",
	type = "organic",
	icon = "object/green_worm.png",
	name = "green worm",
	kr_name = "녹색 벌레",
	desc = [[엉켜있는 무리에서 힘들게 분리한, 죽은 녹색 벌레입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "주기 전에 얽힌 부분이 없도록 만들어 주게. 맨손으로 하지는 말게나.",
}

newIngredient{ id = "WIGHT_ECTOPLASM",
	type = "organic",
	icon = "object/vial_wight_ectoplasm.png",
	name = "vial of wight ectoplasm",
	kr_name = "와이트 외형질이 든 약병",
	desc = [[탁하고 짙습니다. 병에 집어넣어야 증발하는 것을 막을 수 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "조금이라도 마셨다면, 절대 여기로 다시 돌아오지 말게나. 부탁일세.",
}

newIngredient{ id = "XORN_FRAGMENT",
	type = "organic",
	icon = "object/xorn_fragment.png",
	name = "xorn fragment",
	kr_name = "쏜 파편",
	desc = [[다른 돌과 굉장히 비슷한 것 같지만, 이것은 최근까지 감각이 있었으며 당신을 죽이려고 했던 것입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "쏜의 파편과 눈은 다른 곳에 보관해야하네. 연금술 재료가 쳐다보고 있는 불쾌함은 말로 설명 못한다구.",
}

newIngredient{ id = "WARG_CLAW",
	type = "organic",
	icon = "object/warg_claw.png",
	name = "warg claw",
	kr_name = "와르그 발톱",
	desc = [[불쾌할 정도로 크고, 개과의 발톱치고는 무척이나 날카롭습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "보통 연금술 재료를 모아주는 이들도 와르그 사냥은 꺼려하더군. 돌아오는 길에 그들을 비웃어도 좋을걸세.",
}

newIngredient{ id = "FAEROS_ASH",
	type = "organic",
	icon = "object/pharao_ash.png",
	name = "pouch of faeros ash",
	kr_name = "패로스 재를 넣은 주머니",
	desc = [[평범해보이는 회색 재입니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "그들은 순수한 불꽃의 존재들이라네. 그리고  외부 차원에서 온 다른 것들과 마찬가지로, 그들의 불이 타고 남은 재는 특수한 성질을 가지게 된다네.",
}

newIngredient{ id = "WRETCHLING_EYE",
	type = "organic",
	icon = "object/wretchling_eyeball.png",
	name = "wretchling eyeball",
	kr_name = "렛츨링 눈알",
	desc = [[작고 충혈된 눈알입니다. 그 죽음의 시선은 아직도 당신의 피부를 타오르게 만듭니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "사악하고 조그만, 렛츨링이라는 놈이지. 죽일 수 있는만큼 죽여도 좋지만, 난 온전한 눈알 하나만 있으면 된다네.",
}

newIngredient{ id = "FAERLHING_FANG",
	type = "organic",
	icon = "object/faerlhing_fang.png",
	name = "faerlhing fang",
	kr_name = "패를링 송곳니",
	desc = [[아직도 독액과 마법의 힘이 흐르고 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "이놈에게 많은 모험가를 잃었지만, 자네는 괜찮을거라 믿네.",
}

newIngredient{ id = "VAMPIRE_LORD_FANG",
	type = "organic",
	icon = "object/vampire_lord_fang.png",
	name = "vampire lord fang",
	kr_name = "흡혈귀 군주 송곳니",
	desc = [[눈이 부실 정도로 하얗지만, 가장 어두운 마법이 송곳니를 감싸고 있습니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "찔리지 않게 정말 조심해야 하네.",
}

newIngredient{ id = "HUMMERHORN_WING",
	type = "organic",
	icon = "object/hummerhorn_wing.png",
	name = "hummerhorn wing",
	kr_name = "허밍뿔의 날개",
	desc = [[투명하고 얇지만, 놀랍도록 튼튼합니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "허밍뿔이 뭐냐고? 말벌과 비슷한 종류일세. 다만 아주 크고 치명적이지. 독침이 뿔이라고 생각될만큼 커서 허밍뿔, 그러니까 윙윙거리면서 날아다니는 뿔이라고 부른다네.",
}

newIngredient{ id = "LUMINOUS_HORROR_DUST",
	type = "organic",
	icon = "object/pouch_luminous_horror_dust.png",
	name = "pouch of luminous horror dust",
	kr_name = "밤에 빛나는 공포의 가루 주머니",
	desc = [[무게가 느껴지지 않고, 다른 가루들과는 다르게 빛이 납니다.]],
	min = 0, max = INFINITY,
	alchemy_text = "발광하는 공포와 혼동하지 말게나. 만약 이놈들과 헷갈린다면... 자네 말고도 내 부탁을 들어줄 모험가는 많다는걸 알아두게.",
}
