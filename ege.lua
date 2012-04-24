--
--------------------------------------------------------------------------
-- ToDo
--------------------------------------------------------------------------
-- If food nearby look how much and inform others
-- if food here, search around
-- if food here, remember Position
--------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------
--
--set food coords if food is bigger min_food
min_food = 5
--begin heal below that value
heal_health = 25
-- be koth only when health is over that
koth_walk_health = 70
koth_leave_health = 15
-- convert only if over the following values
convert_health = 85 --difficult, now values none, lets try (was 95)
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
food_koord_val = false
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
  if food_koordx and food_koordy and food_koord_val > 1 then
	self.walkx = food_koordx
	self.walky = food_koordy
	set_message(self.id, "kfood") 
  else
	self.walkx, self.walky = getRandomCoords()
	set_message(self.id, "sfood")
  end
  set_path( self.id, self.walkx, self.walky )
  set_state( self.id, CREATURE_WALK )
end


-- eat
function Creature:eat()
  set_message(self.id, "eating")
  set_state( self.id, CREATURE_EAT )
end

-- convert, but decide convert to what
function Creature:convert()
  if get_state( self.id ) == CREATURE_CONVERT then
	return
  elseif get_typ1 and get_typ2 and my_creatures => typ2_min and mums >= typ2_min_typ1 and not flys >= mums and not flys >= max_flys then
	set_convert( self.id, fly )
	flys = flys + 1
  elseif get_typ1 then
	set_convert( self.id, mum )
	mums = mums + 1
  else
	print ("No clue what to do now, called creature convert, but no conversion chosen")
	return
  end
  set_state( self.id, CREATURE_CONVERT )
  set_message(self.id, "converting")
end

-- become koth
function Creature:become_koth()
  local x,y = get_koth_pos()
  if get_king and not king then
	set_message (self.id, "WalkKoth")
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
end

-- main for workers
function Creature:main_worker()
  -- get some infos of me
  local health = get_health(self.id)
  local food = get_food(self.id)
  local mex,mey = get_pos(self.id)
  local here_food = get_tile_food(self.id)
  if here_food >= min_food and here_food > food_koord_val then
	food_koordx = mex
	food_koordy = mey
	food_koord_val = here_food
  elseif here_food <= 1 and mex == food_koordx and mey == food_koordx then
	food_koord_val = here_food
	food_koordx = false
	food_koordy = false
  end
  local state = get_state()
  local enemyid, enemyx, enemyy, enemynum, enemydist = get_nearest_enemy(self.id)
  king_id = king_player()
  if king then
	while king_id == self.id do
	  -- even if king, check health and heal if needed
	  if health < heal_health and food > 1 and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
		self:heal()
		return
	  elseif health < koth_leave_health then
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
  if get_type(enemyid) not 2 then
	local enemyid = false
  end
  -- make some decisions
  if health > convert_health and food > convert_food and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
	self:convert()
  elseif health < heal_health and food > 1 and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
	self:heal()
  elseif here_food > 0 and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
	self:eat()
  elseif enemyid and enemydist < typ0_attack_range and state not "CREATURE_CONVERT" and typ0_kill == true then
	self:attack(enemyid)
	-- should we geht koth?
  elseif health > koth_walk_health and koth_walkable and get_king and not king and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
	self:become_koth()
	-- something missing?
  else
	self:search_food()
  end
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
  food_koordx = false
  food_koordy = false
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
  local type = get_type(self.id)
  if self.id == king then
	king = false
  end
  if type == worker then
	workers = workers - 1
  elseif type == mum then
	mums = mums - 1
  elseif type == fly then
	flys = flys - 1
  end
end

function info()
  local chkd=0
  for id, creature in pairs(creatures) do
	local posx,posy=get_pos(id)
	print(id .. ": " ..get_type(id) .. " on "..posx..":"..posy .. "==> hp:"..get_health(id)..". food:"..get_food(id) .." state:" .. get_state(id).." punkte: "..player_score(player_number))
	chkd=chkd+1
  end
  if king then
	print("king" .. king )
  end
--[[  print ("Wir haben " .. my_creatures .. " Kreaturen")
  print ("Wir haben " .. my_workers .. " Worker")
  print ("Wir haben " .. my_mums .. " Mums")
  print ("Wir haben " .. my_flys .. " Flies")
  --]]
  time = game_time()
  COUNT=chkd
end
	                                                                                                                                         
-- Your Creature Logic here :-)
function Creature:main()
  -- just for security
  if king then
	if not player_exists(king) then
	  king = false
	end
  end
  now = game_time()
  if now >= future then
	Creature:onRestart()
  end
  local type = get_type(self.id)
  if type == worker then
	self:main_worker()
  elseif type == mum then
	self:main_mum()
  elseif type == fly then
	self:main_fly()
  else
	print ("FATAL: unknown type " .. type)
  end
end
--            self:wait_for_next_round()

			                             