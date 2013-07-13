function druid_guardian()
	-- attempted by jpganis, fixed by Attip, updated by peanutbird
	
	local spell = nil
	local target = nil
	
	-- Other stuff
	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("lacerate")
	local lacDuration = jps.debuffDuration("lacerate")
	local thrashDuration = jps.debuffDuration("thrash")
	
	local spellTable = {
		-- Buffs
		-- { "mark of the wild", not jps.buff("mark of the wild") },

		-- Bear Form
		{ "Bear Form", not jps.buff("Bear Form") },
		
		{nil, IsSpellInRange("lacerate","target") ~= 1 },
	
		-- Interrupts
		{"skull bash", jps.Interrupts and jps.shouldKick() },
		{"mighty bash", jps.Interrupts and jps.shouldKick() },
		
		-- Healing / Support
		{"heart of the wild", IsControlKeyDown() ~= nil},
		{"rejuvenation", jps.buff("heart of the wild") and jps.hp() < .75 and not jps.buff("rejuvenation")},
		-- {"rejuvenation", jps.buff("heart of the wild") and IsControlKeyDown() ~= nil and IsSpellInRange("rejuvenation", "mouseover"), "mouseover" },
		
		-- Defense
		{"barkskin", jps.hp() < .5 and jps.UseCDs},
		{"survival instincts", jps.hp() < .5 and jps.UseCDs},
		{"might of ursoc", jps.hp() < .25 and jps.UseCDs},
		{"frenzied regeneration",	jps.hp() < .6 and jps.buff("savage defense")},
		{"savage defense", jps.hp() < .9 and rage >= 60},
		{"renewal", jps.hp() < .2 and jps.UseCDs },
		{"nature’s swiftness", jps.hp() < .2 and jps.UseCDs },
		{"healing touch", jps.hp() < .2 and jps.buff("nature's swiftness") and jps.UseCDs },
		{"nature’s vigil", jps.hp() < .3 and jps.UseCDs },
		{"enrage", rage <= 10 and jps.hp() > .95},
		
		-- Offense
		{"berserk", jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},
	
		-- Multi-Target
		{"thrash", jps.MultiTarget and not jps.debuff("thrash")},
		{"mangle", jps.MultiTarget },
		{"swipe", jps.MultiTarget },
		
		-- Single Target
		{"mangle" },
		{"maul", rage > 90 and jps.hp() >= .85 },	
		{"faerie fire", not jps.debuff("weakened armor") },
		{"thrash", not jps.debuff("thrash") or thrashDuration < 3 },
		{"lacerate", lacCount < 3 or lacDuration < 1 },
		{"faerie fire" },
	}

	spell,target = parseSpellTable(spellTable)
	return spell,target
end
