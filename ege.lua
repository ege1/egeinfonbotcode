debug = true
--
--------------------------------------------------------------------------
-- ToDo
--------------------------------------------------------------------------
-- if food here, search around
-- if food here, remember Position
-- write main_mum (attack, koth_walk if not worker which does this, eat, heal)
-- while for attack, only stop if health is too low
-- start heal for mum erlier, if we have food at half and heal beneth 75, heal with while
-- attack king if present
-- if we are king with other creature and no enemy nearby, birth

--------------------------------------------------------------------------
-- Done
--------------------------------------------------------------------------
-- set variable if one creature is walking koth, no need for all to run there
-- 
--------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------
--
--set food coords if food is bigger min_food
min_food = 4000 -- one point holds max 9999
--begin heal below that value
heal_health = 25
end_heal_health = 100
-- be koth only when health is over that
koth_walk_health = 70
koth_leave_health = 15
walking_koth = false
-- convert only if over the following values
convert_health = 85 --difficult, now values none, lets try (was 95).-
convert_food = 8000 --typ1 8000 typ2 5000
-- birth
birth = true -- should we spawn?
birth_health = 25 -- min 20
birth_food = 6000  -- min 5000
-- reset some variables to default values if r is pressed or every below msecs
reset_wait = 10000
--types
worker = 0
mum = 1
fly = 2
-- values for types
worker_max_food = 10000
mum_max_food = 20000
fly_max_food = 5000
-- kill current koth
kill_koth = true
-- become koth
get_king = true
-- kill if enemy nearby
typ0_kill = true
typ1_kill = true
typ2_kill = true
-- typ values
typ0_attack_range = 768
typ1_attack_range = 512
-- become koth
typ0_become_king = true
typ1_become_king = true
typ2_become_king = true

-- convert options
get_typ1 = true
get_typ2 = true

-- convert to type only if min typ_min creatures present
-- thats nonsense: typ1_min = 1
typ2_min = 2
typ2_min_typ1 = 1
max_flys = 1

-- if fleeing, we need to flee more than enemy can reach
flee_min_range = 1000

-- predefined
-- how many creatures do I have
my_creatures = 0
-- what type are they
my_workers = 0
my_mums = 0
my_flys = 0
king = false
food_koord_val = 0
here_food = 0
food_koordx = false
food_koordy = false
koth_walkable = true

-- reset values, get resettet every reset_wait msecs

--reset_king = false
reset_koth_walkable = true

--
--------------------------------------------------------------------------
-- Knowledge
--------------------------------------------------------------------------

-- typ0
-- can kill typ2
-- can convert to type1 (using 8000 food) or type2 (using 5000 food)
-- can feed 400

-- typ1
-- can kill all
-- can birth/spawn

-- typ2
-- can convert typ0 (5000 food)

--------------------------------------------------------------------------
-- Start own functions
--------------------------------------------------------------------------

-- get random koords which fit on map
function getRandomCoords ()
  local x1, y1, x2, y2 = world_size()
  return math.random(x1,x2), math.random(y1,y2)
end
function getKothCoords ()
  kothx, kothy = get_koth_pos()
  return kothx, kothy
end


-- search for food
function Creature:search_food()
  set_message(self.id, "hungry")
  self.bex, self.bey = get_pos(self.id)
  self.walkx, self.walky = getRandomCoords()
  if food_koordx and food_koordy and food_koord_val > 1 then
    self.walkx = food_koordx
    self.walky = food_koordy
    set_message(self.id, "kfood") 
  elseif self.walkx ~= self.bex or self.walky ~= self.bey then
    set_message(self.id, "sfood")
  end
  if get_state(self.id) ~= CREATURE_WALK then
    set_path( self.id, self.walkx, self.walky )
    set_state( self.id, CREATURE_WALK )
  end
end


-- eat
function Creature:eat()
  set_message(self.id, "eating")
  set_state( self.id, CREATURE_EAT )
end

-- heal
function Creature:heal()
  while get_health(self.id) < end_heal_health and get_food(self.id) > 1 and not get_state(self.id) ~= CREATURE_ATTACK and not get_state(self.id) ~= CREATURE_CONVERT do
    set_state(self.id, CREATURE_HEAL)
    set_message(self.id, "HEAL")
    self:wait_for_next_round()
  end
end
-- convert, but decide convert to what
function Creature:convert()
  if get_typ1 and get_typ2 and my_creatures >= typ2_min and my_mums >= typ2_min_typ1 and my_flys <= my_mums and my_flys <= max_flys then
	set_convert( self.id, fly )
	my_flys = my_flys + 1
  elseif get_typ1 then
	print ("get_type1")
	set_convert( self.id, mum )
	my_mums = my_mums + 1
  else
	print ("No clue what to do now, called creature convert, but no conversion chosen")
	return
  end
  set_state( self.id, CREATURE_CONVERT )
  set_message(self.id, "converting")
  while get_state( self.id ) == CREATURE_CONVERT do
    self:wait_for_next_round()
  end
  set_message(self.id, "converted")
end

-- become koth
function Creature:become_koth()
  local kothx,kothy = get_koth_pos()
  if get_king and not king and not walking_koth then
	set_message (self.id, "WalkKoth")
	walking_koth = self.id
	lauf = set_path( self.id, kothx, kothy )
	if not lauf then
	  koth_walkable = false
	  print("koth seams not walkable")
	  self:search_food()
	else
	  -- do we need to set path here again?
	  set_path(self.id, kothx,kothy)
	  set_state( self.id, CREATURE_WALK )
	  set_message (self.id, "WalkKoth")
	end
  else
	print ("Called become_koth but get_king not set or king already exists")
  end
end
-- attack enemy
function Creature:attack(enemy)
	set_target( self.id, enemy )
	set_state( self.id, CREATURE_ATTACK )
	set_message(self.id, "KILL")
end

-- flee until far enough
function Creature:flee(attacker)
--flee_min_range = 1000
--flee only if we are fly and attacker is mum or worker or
-- if we are worker or fly and attacker is mum
-- flee until attacker is farer then flee_min_range
-- get_nearest_enemy and his coordinates and flee in the opposit direction
end

-- main for workers
function Creature:main_worker()
  -- get some infos of me
  self.health = get_health(self.id)
  self.food = get_food(self.id)
  self.mex,self.mey = get_pos(self.id)
  self.here_food = get_tile_food(self.id)
  if self.here_food >= min_food and self.here_food > food_koord_val then
	food_koordx = self.mex
	food_koordy = self.mey
	food_koord_val = here_food
  elseif self.here_food <= 1 and selfmex == food_koordx and self.mey == food_koordy then
	food_koord_val = 0
	food_koordx = false
	food_koordy = false
  end
  self.state = get_state(self.id)
  self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id)
  king_id = king_player()
  if king then
	while king_id == self.id do
	  -- even if king, check health and heal if needed
	  if self.health < heal_health and self.food > 1 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
		self:heal()
		return
	  elseif self.health < koth_leave_health then
		king = false
		self:search_food()
		return
	  else
		king = self.id
	  end
	  set_message(self.id, "KING")
	  self:wait_for_next_round()
	end
  end
  if self.enemyid then
    if get_type(self.enemyid) ~= 2 then
	  self.enemyid = false
    end
  end
  self.now_food = convert_food + 500
  if self.health <= convert_health and self.food > self.now_food and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:heal()
  end
--  print("health " .. health .. " > " .. koth_walk_health .. " and koth_walkable and get_king and not king and state ~= ")
  -- make some decisions
  if self.health > convert_health and self.food > convert_food and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:convert()
  elseif self.health < heal_health and self.food > 1 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:heal()
  elseif here_food > 0 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" and self.food < worker_max_food then
	self:eat()
  elseif enemyid and enemydist and enemydist < typ0_attack_range and self.state ~= "CREATURE_CONVERT" and typ0_kill == true then
    print ("main before attack")
	self:attack(enemyid)
	-- should we geht koth?
  elseif self.health > koth_walk_health and koth_walkable and get_king and not king and not walking_koth and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	print ("before become koth")
	self:become_koth()
	-- something missing?
  else
	self:search_food()
  end
end

--------------------------------------------------------------------------
-- Main Mum
--------------------------------------------------------------------------

function Creature:main_mum()
  return
end

--------------------------------------------------------------------------
-- Default Code
--------------------------------------------------------------------------

-- Called after the Creature was created. You cannot
-- call long-running methods (like moveto) here.
function Creature:onSpawned(parent)
  if parent then
	print("Creature " .. self.id .. " spawned by " .. parent)
  else
	print("Creature " .. self.id .. " spawned")
  end
  my_creatures = my_creatures + 1
  my_workers = my_workers + 1
end


-- Called each round for every attacker on this
-- creature. No long-running methods here!
function Creature:onAttacked(attacker)
  -- print("Help! Creature " .. self.id .. " is attacked by Creature " .. attacker)
  local attacker_type = get_type(attacker)
  local my_type = get_type(self.id)
  if my_type == worker and attacker_type == fly then
	self.attack(attacker)
  elseif my_type == mum then
	self.attack(attacker)
  elseif my_type == fly then
	self.flee(attacker)
  else
	self.flee(attacker)
  end
end
  

-- Called by typing 'r' in the console, after creation (after
-- onSpawned) or by calling self:restart(). No long-running
-- methods calls here!
function Creature:onRestart()
  --reset some variables all reset_wait msecs
  future = now + reset_wait
  koth_walkable = reset_koth_walkable
--  food_koordx = false
--  food_koordy = false
end
  

-- Called after being killed. Since the creature is already
-- dead, self.id cannot be used to call the Lowlevel API.
function Creature:onKilled(killer)
  if killer == self.id then
	print("Creature " .. self.id .. " suicided")
  elseif killer then
	print("Creature " .. self.id .. " killed by Creature " .. killer)
  else
	print("Creature " .. self.id .. " died")
  end
  my_creatures = my_creatures - 1
--  local type = get_type(self.id)
  if self.id == king then
	king = false
  end
end

--[[function info()
  local chkd=0
  for id, creature in pairs(creatures) do
	local posx,posy=get_pos(id)
	print(id .. ": " ..get_type(id) .. " on "..posx..":"..posy .. "==> hp:"..get_health(id)..". food:"..get_food(id) .." state:" .. get_state(id).." punkte: "..player_score(player_number))
	chkd=chkd+1
  end
  if king then
	print("king" .. king )
  end
--]]
--[[  print ("Wir haben " .. my_creatures .. " Kreaturen")
  print ("Wir haben " .. my_workers .. " Worker")
  print ("Wir haben " .. my_mums .. " Mums")
  print ("Wir haben " .. my_flys .. " Flies")
  --]]
--  print("Workers: " .. my_workers .. " Mums " .. my_mums .. " Flys " .. my_flys .. " Creatures: " .. my_creatures)

--[[  time = game_time()
  COUNT=chkd
end
--]]	                                                                                                                                         
-- Your Creature Logic here :-)
function Creature:main()
  -- just for security
  if king then
	if not player_exists(king) then
	  king = false
	end
  end
  self.chkd = 0
  self.workers = 0
  self.mums = 0
  self.flys = 0
  for id, creature in pairs(creatures) do
    self.chkd = self.chkd + 1
    if get_type(id) == worker then
      self.workers = self.workers + 1
    elseif get_type(id) == mum then
      self.mums = self.mums + 1
    elseif get_type(id) == fly then
      self.flys = self.flys + 1
    end
  end
  my_workers = self.workers
  my_mums = self.mums
  my_flys = self.flys
  my_creatures = self.chkd
--  print("Workers: " .. my_workers .. " Mums " .. my_mums .. " Flys " .. my_flys .. " Creatures: " .. my_creatures)
  now = game_time()
  if now >= future then
	Creature:onRestart()
  end
  self.type = get_type(self.id)
  if self.type == worker then
	self:main_worker()
  elseif self.type == mum then
	self:main_mum()
  elseif self.type == fly then
	self:main_fly()
  else
	print ("FATAL: unknown type " .. type)
  end
--should not be needed here  self:wait_for_next_round()
end
