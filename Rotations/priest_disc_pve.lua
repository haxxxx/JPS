--TO DO : tranquility detection

function priest_disc_pve()
  jps.Tooltip = "Disc Priest (PvE) 5.3"

  local spell = nil
  local target = nil
  
  local tank = nil
  
  -- Tank is focus.
  tank = jps.findMeATank()
  
  -- Check if we should purify.
  local purify = jps.FindMeDispelTarget({"Magic"}, {"Disease"})
  
  -- Default to healing lowest party member.
  local default = jps.LowestInRaidStatus()
  
  -- Check that the tank isn't going critical, and that I'm not about to die
  if jps.canHeal(tank) and jps.hp(tank) <= .5 then
    default = tank
  elseif jps.hpInc("player") < .3 then
    default = "player"
  end
  
  --Get the health of our decided target
  local tankHP = jps.hpInc(tank)
  local defaultHP = jps.hpInc(default)
  local defaultAggro = false
  if UnitThreatSituation(default) == 3 then defaultAggro = true end
  
  -- counts the number of party members having a significant health loss
  local unitsNeedHealing = 0
  for unit, unitTable in pairs(jps.RaidStatus) do
    --Only check the relevant units
    if jps.canHeal(unit) and jps.hp(unit) < .8 then
      unitsNeedHealing = unitsNeedHealing + 1
    end
  end

  local spellTable = {

    -- Buffs
    { "Power Word: Fortitude", not jps.buff("Power Word: Fortitude"), player },
    { "Inner Fire", not jps.buff("Inner Fire"), player },
    
    -- In Trouble
    { "Desperate Prayer", defaultHP < .25, default },
    { "Pain Supression", defaultHP < .3 and defaultAggro, default },
    { "Void Shift", defaultHP < .25 and jps.hp() > .75, default },

    -- CDs
    { "Hymn of Hope", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
    { "Power Infusion", jps.UseCDs },
    { "Inner Focus" },
    { "Mindbender", jps.UseCDs and jps.mana() < .75, "target" },
    
    { jps.useSynapseSprings(), jps.UseCDs }, -- Requires engineering
    { "Lifeblood", jps.UseCDs }, -- Requires herbalism
    { jps.useTrinket(1), jps.UseCDs }, -- Use your second trinket

    -- Dispell
    { "Purify",  purify ~= nil, purify },

    -- Aggro
    { "Fade", UnitThreatSituation("player") == 3, "player" },

    -- Shields
    { "Power Word: Shield", tankHP < .95 and not jps.buff("Power Word: Shield", tank) and not jps.debuff("Weakened Soul", tank), tank },
    { "Power Word: Shield", defaultHP < .8 and defaultAggro and not jps.buff("Power Word: Shield", default) and not jps.debuff("Weakened Soul", default), default },
    { "Spirit Shell", defaultHP > .7 and unitsNeedHealing >= 3 },

    -- Multi
    { "Cascade", unitsNeedHealing >= 3, default },
    { "Prayer of Healing", unitsNeedHealing >= 3, default },

    -- Heals
    { "Prayer of Mending", tankHP < .95, tank }, -- always on the tank
    { "Prayer of Mending", defaultHP < .85 and defaultAggro, default }, -- has aggro
    { "Renew", defaultHP < .8 and jps.Moving and jps.debuff("Weakened Soul", default), default },
    { "Binding Heal", defaultHP < .7 and jps.hp() < .7 and not UnitIsUnit(default, "player"), default },
    { "Flash Heal", defaultHP < .8 and jps.buff("Surge of Light"), default },
    { "Flash Heal", defaultHP < .3, default },
    { "Greater Heal", defaultHP < .5, default },
    { "Greater Heal", tankHP < .6, tank },

    -- Damage
    { "Holy Fire", "target" },
    { "Penance", not jps.Moving, "target" },
    { "Penance", defaultHP < .9 and not jps.Moving, default },
    -- { "Heal", defaultHP < .7, default },
    { "Smite", "target" },
  }

  spell,target = parseSpellTable(spellTable)
  return spell,target
  
end
