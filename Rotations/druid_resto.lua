--TO DO : tranquility detection

function druid_resto()

	local spell = nil
	local target = nil
	-- Shift-key to cast Tree of Life
	-- jps.MultiTarget to Wild Regrowth
	-- Use Innervate and Tranquility manually
	
	--healer
	local tank = nil
	local me = "player"
	
	-- Tank is focus.
	tank = jps.findMeATank()
	
	-- Check if we should cleanse
	local cleanseTarget = nil
	local hasSacredCleansingTalent = 0
	_,_,_,_,hasSacredCleansingTalent = 1 -- GetTalentInfo(1,14) JPTODO: find the resto talent
	if hasSacredCleansingTalent == 1 then
	  cleanseTarget = jps.FindMeDispelTarget({"Poison"},{"Curse"},{"Magic"})
	else
	  cleanseTarget = jps.FindMeDispelTarget({"Poison"},{"Curse"})
	end
	
	--Default to healing lowest partymember
	local defaultTarget = jps.LowestInRaidStatus()
	
	--Check that the tank isn't going critical, and that I'm not about to die
	if jps.canHeal(tank) and jps.hp(tank) <= 0.5 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end
	
	--Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)
	local tankHP = jps.hpInc(tank)
	
	-- counts the number of party members having a significant health loss
  local unitsNeedHealing = 0
  for unit, unitTable in pairs(jps.RaidStatus) do
    --Only check the relevant units
    if jps.canHeal(unit) and jps.hp(unit) < .9 then
      unitsNeedHealing = unitsNeedHealing + 1
    end
  end

	local spellTable = {
		-- rebirth Ctrl-key + mouseover
		{ "rebirth", IsControlKeyDown() ~= nil and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("rebirth", "mouseover"), "mouseover" },
		
		-- Buffs
		{ "mark of the wild", not jps.buff("mark of the wild") , player },
		
		-- CDs
		{ "barkskin", jps.hp() < .5 },
		{ "nature's swiftness", defaultHP < .6 },
		{ "tree of life", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
		
		{ "nature's swiftness", defaultHP < .4 },
		{ "remove corruption", cleanseTarget ~= nil, cleanseTarget },
		{ "swiftmend", tankHP < .85 and (jps.buff("rejuvenation", tank) or jps.buff("regrowth", tank)), tank },
		{ "healing touch", (jps.buff("nature's swiftness") or not jps.Moving) and defaultHP < 0.55, defaultTarget },
		{ "regrowth", defaultHP < .55 or jps.buff("clearcasting"), defaultTarget },
		{ "wild growth", unitsNeedHealing >= 3, defaultTarget },
		{ "rejuvenation", defaultHP < .75 and not jps.buff("rejuvenation", defaultTarget), defaultTarget },
		{ "lifebloom", jps.buffDuration("lifebloom",tank) < 3 or jps.buffStacks("lifebloom",tank) < 3, tank },
		{ "rejuvenation", jps.buffDuration("rejuvenation", tank) < 3, tank },
		{ "nourish", defaultHP < .8, defaultTarget },
		--	{ "nourish",			jps.hp(tank) < 0.9 or jps.buffDuration("lifebloom",tank) < 5, tank },
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
	
end
