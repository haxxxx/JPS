function warrior_arms_pve()
--Gocargo
	
	local targetHealth = UnitHealth("target") / UnitHealthMax("target")
	local nRage = jps.buff("Berserker Rage", "player")
	local nPower = UnitPower("Player", 1) -- Rage est PowerType 1

	local spellTable = {
		{ "Recklessness", jps.UseCDs and (jps.debuffDuration("Colossus Smash") >= 5 or jps.cooldown("Colossus Smash") <= 4 ) and targetHealth < 20 },
		{ "Berserker Rage", jps.UseCDs and not nRage },
		{ "Deadly Calm", jps.UseCDs and nPower >= 40 },
		{ "Lifeblood", jps.UseCDs },
		{ "Heroic Strike", (((jps.buff("taste for blood") and jps.buffDuration("taste for blood") <= 2) or (jps.buffStacks("taste for blood") == 5) or (jps.buff("Taste for Blood") and jps.debuffDuration("Colossus Smash") <= 2 and jps.cooldown("Colossus Smash") > 0) or jps.buff("Deadly Calm") or nPower >= 110)) and targetHealth >= 20 and jps.debuff("Colossus Smash") , "target" },
		{ "Mortal Strike" },
		{ "Colossus Smash", jps.debuffDuration("Colossus Smash") <= 1.5 },
		{ "Execute" },
		{ "Overpower", jps.buff("taste for blood") },
		{ "Dragon Roar" },
		{ "Slam", (nPower >= 70 or jps.debuff("Colossus Smash")) and targetHealth >= 20 },
		{ "Heroic Throw" },
		{ "Battle Shout", nPower <= 70 and not jps.debuff("Colossus Smash") },
		{ "Slam", targetHealth >= 20 },
		{ "Impending Victory", targetHealth >= 20 },
		{ "Battle Shout", nPower <= 70 },
		{ {"macro","/startattack"}, true },
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end