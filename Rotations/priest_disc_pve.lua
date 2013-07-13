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
  local defaultAggro = ( UnitThreatSituation(default) == 3 )
  
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
    { "Void Shift", IsInGroup() and defaultHP < .25 and jps.hp() > .75, default },
    { jps.useBagItem("Healthstone"), jps.hp() < .3 }, -- Healthstone

    -- CDs
    { "Hymn of Hope", IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
    { "Power Infusion", jps.UseCDs },
    { "Inner Focus" },
    { "Mindbender", jps.UseCDs and jps.mana() < .8, "target" },
    { "Archangel", jps.buffStacks("Evangelism") == 5 and ( defaultHP < .4 or unitsNeedHealing >= 3 ) },
    
    { jps.useSynapseSprings(), jps.UseCDs }, -- Requires engineering
    { "Lifeblood", jps.UseCDs }, -- Requires herbalism
    { jps.useTrinket(1), jps.UseCDs }, -- Use your second trinket

    -- Dispell
    { "Purify",  purify ~= nil, purify },

    -- Aggro
    { "Fade", IsInGroup() and UnitThreatSituation("player") == 3, "player" },

    -- Solo
    { "Power Word: Shield", not IsInGroup() and not jps.debuff("Weakened Soul") and not jps.buff("Power Word: Shield"), "player" },
    { "Shadow Word: Death", not IsInGroup() },
    { "Shadow Word: Pain", not IsInGroup() and not jps.debuff("Shadow Word: Pain", "target") },
    
    -- Shields
    { "Power Word: Shield", tankHP < .98 and not jps.buff("Power Word: Shield", tank) and not jps.debuff("Weakened Soul", tank), tank },
    { "Power Word: Shield", defaultHP < .8 and defaultAggro and not jps.buff("Power Word: Shield", default) and not jps.debuff("Weakened Soul", default), default },
    { "Spirit Shell", defaultHP > .7 and unitsNeedHealing >= 3 },

    -- Heals
    { "Prayer of Mending", tankHP < .95, tank }, -- always on the tank
    { "Prayer of Mending", defaultHP < .85 and defaultAggro, default }, -- has aggro

    { "Holy Fire", "target" },
    { "Penance", defaultHP < .8 and not jps.Moving, default },
    { "Penance", not jps.Moving, "target" },

    { "Cascade", unitsNeedHealing >= 3, default },
    { "Binding Heal", not jps.Moving and defaultHP < .7 and jps.hp() < .7 and not UnitIsUnit(default, "player"), default },
    { "Flash Heal", not jps.Moving and defaultHP < .8 and jps.buff("Surge of Light"), default },
    { "Flash Heal", not jps.Moving and defaultHP < .3, default },
    { "Prayer of Healing", not jps.Moving and unitsNeedHealing >= 3, default },
    { "Renew", defaultHP < .8 and jps.Moving and jps.debuff("Weakened Soul", default), default },
    { "Greater Heal", not jps.Moving and defaultHP < .5, default },
    { "Greater Heal", not jps.Moving and tankHP < .6, tank },

    -- { "Heal", defaultHP < .7, default },
    { "Smite", not jps.Moving, "target" },
  }

  spell,target = parseSpellTable(spellTable)
  return spell,target
  
end
