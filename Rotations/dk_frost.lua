function dk_frost()
	
	-- Talents:
	-- Tier 1: Plague Leech or Unholy Blight
	-- Tier 2: Anti-Magic Zone ( lichborne is a small dps loss , purgatory risky because of the debuff ) 
	-- Tier 3: Death's Advance  / for kiting chillbains  / asphyxiate for another kick / cc
	-- Tier 4: Death Pact 
	-- Tier 5: for 2h Runic Empowerment  (others will also work , but Runic Empowerment provides us better burst) , blood tap for DW 
	-- Tier 6: Remorseless Winter or Desecrated Ground if you need some stun/cc remove
	-- Major Glyphs: Icebound Fortitude, Anti-Magic Shell
	
	-- Usage info:
	-- left alt for battle rezz at your focus or (if focus is not death , or no focus or focus target out of range) mouseover	

	-- Cooldowns: trinkets, raise dead, synapse springs, lifeblood, pillar of frost, racials
	
	local spell = nil
	local target = nil	
	
	local runicPower = UnitPower("player")
	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local ur1 = select(3,GetRuneCooldown(3))
	local ur2 = select(3,GetRuneCooldown(4))
	local fr1 = select(3,GetRuneCooldown(5))
	local fr2 = select(3,GetRuneCooldown(6))
	local oneDr = dr1 or dr2
	local twoDr = dr1 and dr2
	local oneFr = fr1 or fr2
	local twoFr = fr1 and fr2
	local oneUr = ur1 or ur2
	local twoUr = ur1 and ur2

	local frostFeverDuration = jps.myDebuffDuration("Frost Fever")
	local bloodPlagueDuration = jps.myDebuffDuration("Blood Plague")
	local timeToDie = jps.TimeToDie("target")

	-- function for checking diseases on target for plague leech, because we need fresh dot time left
	function canCastPlagueLeech(timeLeft)  
		if not jps.mydebuff("Frost Fever") or not jps.mydebuff("Blood Plague") then return false end
		if jps.myDebuffDuration("Frost Fever") <= timeLeft then
			return true
		end
		if jps.myDebuffDuration("Blood Plague") <= timeLeft then
			return true
		end
		return false
	end
	local useItem = true;

	------------------------
	-- SPELL TABLE ---------
	------------------------
	local spellTable = {}
	spellTable[1] =
	{	
    	["ToolTip"] = "PVE 2H Simcraft",
    	{ "Frost Presence",			not jps.buff("Frost Presence") },
    	{ "Horn of Winter",			not jps.buff("Horn of Winter")  },
    	
    	--AOE
    	{ "Death and Decay",			IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget and IsLeftAltKeyDown == nil},
    	
    	-- Battle Rezz
    	{ "Raise Ally",			UnitIsDeadOrGhost("focus") == 1 and UnitPlayerControlled("focus") == true and jps.UseCds and IsLeftAltKeyDown()  ~= nil and GetCurrentKeyBoardFocus() == nil  , "focus" },
    	{ "Raise Ally",			UnitIsDeadOrGhost("mouseover") == 1 and UnitPlayerControlled("mouseover") == true and jps.UseCds and IsLeftAltKeyDown()  ~= nil  and GetCurrentKeyBoardFocus() == nil , "mouseover" },
    	
    	-- Self heal
    	{ "Death Pact",			jps.UseCDs and jps.hp() < .6 and UnitExists("pet") ~= nil },
    	-- Self heals
    	{ "Death Siphon",			jps.Defensive and jps.hp() < .8 },
    	{ "Death Strike",			jps.Defensive and jps.hp() < .7  },
    	
    	-- Interrupts
    	{ "mind freeze",				jps.shouldKick() },
    	{ "mind freeze",				jps.shouldKick("focus"), "focus" },
    	{ "Strangulate",				jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
    	{ "Strangulate",				jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
    	{ "Asphyxiate",				jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
    	{ "Asphyxiate",				jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
    	
    	--CDs + Buffs
    	{ "Pillar of Frost",			jps.UseCDs },
    	{ jps.useBagItem("Flask of Winter's Bite"), jps.targetIsRaidBoss() and not jps.playerInLFR() and not jps.buff("Flask of Winter's Bite") },
    	{ jps.useBagItem("Potion of Mogu Power"), jps.targetIsRaidBoss() and not jps.playerInLFR() and jps.bloodlusting()}, 

    	{ jps.DPSRacial,				jps.UseCDs },

    	{ "Raise Dead",			jps.UseCDs and UnitExists("pet") == nil },
    	-- On-use Trinkets.
    	{ jps.useTrinket(0), jps.UseCDs },
    	{ jps.useTrinket(1), jps.UseCDs },
    	-- Requires engineerins
    	{ jps.useSynapseSprings(), jps.UseCDs },
    	-- Requires herbalism
    	{ "Lifeblood",			jps.UseCDs },
    	
    	--simcraft 5.3 T14
    	{ "plague leech",			canCastPlagueLeech(2)},
    	{ "outbreak",			bloodPlagueDuration == 0 or frostFeverDuration == 0},
    	{ "unholy blight",			 bloodPlagueDuration == 0 or frostFeverDuration == 0},
    	{ "howling blast",			frostFeverDuration == 0},
    	{ "plague strike",			bloodPlagueDuration == 0},
    	{ "soul reaper",			jps.hp("target") <= .35},
    	{ "blood tap",			 jps.hp("target") <= .35 and jps.cooldown("soul reaper") == 0},
    	{ "howling blast",			jps.buff("Freezing Fog")},
    	{ "obliterate",			jps.buff("killing machine")},
    	{ "blood tap",			 jps.buff("killing machine")},
    	{ "blood tap",			 jps.buffStacks("blood charge")>10 and runicPower>76},
    	{ "frost strike",			runicPower > 76},
    	{ "obliterate",			twoDr or twoFr or TwoUr},
    	{ "plague leech",			 canCastPlagueLeech(3)},
    	{ "outbreak",			frostFeverDuration<3 or bloodPlagueDuration <3},
    	{ "unholy blight",			 frostFeverDuration < 3 or bloodPlagueDuration < 3 },
    	{ "frost strike",			 not oneFr},
    	{ "frost strike",			 jps.buffStacks("blood charge")<=10},
    	{ "horn of winter"},
    	{ "frost strike",			 not jps.buff("runic corruption") and jps.IsSpellKnown("runic corruption")},
    	{ "obliterate",			"onCD"},
    	{ "empower rune weapon", (jps.bloodlusting() or jps.buff("Potion of Mogu Power")) and not twoDr and not twoUr and not twoFr and runicPower < 60 and jps.UseCDs },
    	{ "blood tap",			 jps.buffStacks("blood charge")>10 and runicPower>=20},
    	{ "frost strike",			"onCD" },
    	{ "plague leech",			canCastPlagueLeech(2) },
    	{ "empower rune weapon",	jps.targetIsRaidBoss() and jps.combatTime() < 35 }, -- so it will be ready at the end of most Raid fights
	}
	
	spellTable[2] =
	{
	
		["ToolTip"] = "PVP 2h",

		{ "Horn of Winter",			not jps.buff("Horn of Winter")  },
		{ "Death and Decay",			IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and jps.MultiTarget },
				
		-- Self heal
		{ "Death Pact",			jps.UseCDs and jps.hp() < .6 and UnitExists("pet") ~= nil },
		
		-- Rune Management
		{ "Plague Leech",			canCastPlagueLeech(3) }, 
		
		{ "Pillar of Frost",			jps.UseCDs },
		{ jps.DPSRacial, jps.UseCDs },
		
		{ "Raise Dead",			jps.UseCDs and UnitExists("pet") == nil },
		
		-- If our diseases are about to fall off.
		{ "Outbreak",			frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		
		{ "Soul Reaper",			jps.hp("target") < .35 },
		
		-- Kick
		{ "mind freeze",				jps.shouldKick() },
		{ "mind freeze",				jps.shouldKick("focus"), "focus" },
		{ "Strangulate",				jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",				jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",				jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",				jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
		
		-- Unholy Blight when our diseases are about to fall off. (talent based)
		{ "Unholy Blight",			frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		
		-- On-use Trinkets.
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		
		-- Requires engineerins
		{ jps.useSynapseSprings(), jps.UseCDs },
		
		-- Requires herbalism
		{ "Lifeblood",			jps.UseCDs },
		
		-- Diseases
		{ "Necrotic Strike",			not jps.mydebuff("Necrotic Strike",target)},
		{ "Howling Blast",			frostFeverDuration <= 1 or (jps.buff("Freezing Fog") and runicPower < 88) },
		{ "Plague Strike",			bloodPlagueDuration <= 1 },
		
		-- Self heals
		{ "Death Siphon",			jps.hp() < .8 },
		{ "Death Strike",			jps.hp() < .7 },
		
		-- Dual wield specific. Disabling for now.
		-- Frost Strike when we have a Killing Machine proc.
		-- { "Frost Strike",				jps.buff("Killing Machine") },
		{ "Obliterate",			runicPower <= 76 or jps.buff("Killing Machine") or jps.bloodlusting()},
		-- Filler.
		{ "Horn of Winter",			runicPower < 20 },
		
		{ "Frost Strike",			runicPower >= 76 or jps.bloodlusting() or not oneFr}, 
		
		{ "Frost Strike",			(not jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1 ) or (jps.buff("Killing Machine") and jps.cooldown("Obliterate") > 1 ) },
		{ "Obliterate"},
		{ "Frost Strike"},
		{ "Plague Leech",			canCastPlagueLeech(2)},
		{ "Empower Rune Weapon",			jps.UseCDs and ((runicPower <= 25 and not twoDr and not twoFr and not twoUr) or (timeToDie < 60 and jps.buff("Potion of Mogu Power")) or jps.bloodlusting()) },
				
	}
	
	spellTable[3] =
	{
	
		["ToolTip"] = "Kick Buff Debuff",
		
		-- Kicks
		{ "mind freeze",				jps.shouldKick() },
		{ "mind freeze",				jps.shouldKick("focus"), "focus" },
		{ "Strangulate",				jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
		{ "Strangulate",				jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
		{ "Asphyxiate",				jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate" },
		{ "Asphyxiate",				jps.shouldKick() and jps.LastCast ~= "Mind Freeze" and jps.LastCast ~= "Strangulate", "focus" },
		-- Buffs
		{ "frost presence",				not jps.buff("frost presence") },
		{ "horn of winter",				"onCD" },
		{ "Outbreak",			frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		{ "Unholy Blight",			frostFeverDuration < 3 or bloodPlagueDuration < 3 },
		{ "Howling Blast",			frostFeverDuration <= 1 or (jps.buff("Freezing Fog") and runicPower < 88) },
		{ "Plague Strike",			bloodPlagueDuration <= 1 },
	}

	local spellTableActive = jps.RotationActive(spellTable)
	spell,target = parseSpellTable(spellTableActive)
	return spell,target
end