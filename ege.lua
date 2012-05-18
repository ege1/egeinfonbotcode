b

debug = true
--
--------------------------------------------------------------------------
-- ToDo
--------------------------------------------------------------------------
-- if enemy is same type and has better health, fleeeeee
-- if koth is not walkable and we get fly, convert back to worker to kill other flies
-- if we have mum and worker and we are not koth with worker, send mum to koth to kill the others
-- If we have to flee, forget at least for the next 10 Secs to walk koth....
-- if we have a fly or a second one if koth is not walkable, explore and find some food
-- if walk koth dont forget to kill or eat on the way to koth
--
-- Feed mum...., problem is, mum should wait for "slave" therefor 
--             self:begin_feeding()
--             while self:is_feeding() do
--                 self:wait_for_next_round()
--             end
-- get fly which searches for good food places, but only if we have at least one mum
-- Remember some good food places 
-- Flee bevor attack like tpe

-- Done
-- Kill koth 

--------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------
--
--set food coords if food is bigger min_food
min_food = 2000 -- was 5000 -- one point holds max 9999
-- if we stand on a place with food, we heal/eat all the time, so set min_heal_food
min_heal_food = 700
min_heal_food_mum = 1200
near_search_distance = 350
default_nearby_count = 7
min_was_food = 10
-- max food distance we walk if someone reports food
max_food_distance = 5000
--begin heal below that value
heal_health = 75
end_heal_health = 100
-- when mum starts to kill
kill_health = 30
-- be koth only when health is over that
koth_walk_health = 50 --70
koth_leave_health = 25
-- convert only if over the following values
convert_health = 85 --difficult, now values none, lets try (was 95).-
convert_food = 8500 --typ1 8000 typ2 5000
-- birth
birth = true -- should we spawn?
birth_health = 45 -- min 20
birth_food = 5500  -- min 5000
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
-- changed decision, it makes more sence if decide convertion on by whome koth is walkable
get_typ1 = true
get_typ2 = true
-- convert to type only if min typ_min creatures present
-- thats nonsense: typ1_min = 1
typ2_min = 2
typ2_min_typ1 = 1
typ2_min_typ0 = 1
max_flys = 2
koth_walkable_fly = true
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
walking_koth = false
-- reset values, get resettet every reset_wait msecs
-- reset some variables to default values if r is pressed or every below msecs
reset_wait = 50000
future = reset_wait
reset_wait2 = 100000
future2 = reset_wait2
reset_wait3 = 40000
future3 = reset_wait3
--reset_king = false
reset_koth_walkable = true
reset_koth_walkable_fly = true
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
function Creature:getRandomCoords()
  local x1, y1, x2, y2 = world_size()
--[[  self.new_x = math.random(x1,x2)
  self.new_y = math.random(y1,y2)
  while not self:set_path(self.new_x, self.new_y) do
    self.new_x = math.random(x1,x2)
    self.new_y = math.random(y1,y2)
  end]]
  while not self:set_path(math.random(x2 - x1) + x1,math.random(y2 - y1) + y1) do
  end                            
--   return self.new_x, self.new_y
end

-- get coords nearby which fit on map
function Creature:getNearbyCoords()
  local x1, y1, x2, y2 = world_size()
  self.nearx, self.neary = get_pos(self.id)
  self.nearx1 = self.nearx - near_search_distance
  self.nearx2 = self.nearx + near_search_distance
  self.neary1 = self.neary - near_search_distance
  self.neary2 = self.neary + near_search_distance
  if self.nearx1 < x1 then
	self.nearx1 = x1
  end
  if self.nearx2 > x2 then
	self.nearx2 = x2
  end
  if self.neary1 < y1 then
	self.neary1 = y1
  end
  if self.neary2 > y2 then
	self.neary2 = y2
  end
--   print("DEBUG: x1,y1,x2,y2 " .. x1,y1,x2,y2 .. "near " .. self.nearx1,self.neary1,self.nearx2,self.neary2)
  self.near_count = 0
  while not self:set_path(math.random(self.nearx2 - self.nearx1) + self.nearx1,math.random(self.neary2 - self.neary1) + self.neary1) do
	self.near_count = self.near_count + 1
	if self.near_count > 1000 then
	  self:getRandomCoords()
	  break
	end
  end                            
  self.was_food = 0
  set_message(self.id, "s:near")
end

-- search for food
function Creature:search_food()
  self.bex, self.bey = get_pos(self.id)
  if not self.was_food then
	 self.was_food = 0
  end
  if get_state(self.id) ~= CREATURE_WALK then
    if self.nearby_count and self.nearby_count > 0 then
      self.nearby_count = self.nearby_count - 1
      if self.was_food > min_was_food then
		self.nearby_count = default_nearby_count
      end
      self:getNearbyCoords()
    elseif self.was_food > min_was_food then
	  self.nearby_count = default_nearby_count
      self:getNearbyCoords()
    else
      self:getRandomCoords()
    end
  end
--   set_message(self.id, "sfood")
  if food_koordx and food_koordy and food_koord_val > 1 and food_reporter then
    if get_distance(self.id, food_reporter) < max_food_distance then
      self.walkx = food_koordx
      self.walky = food_koordy
      set_path( self.id, self.walkx, self.walky )
      set_state( self.id, CREATURE_WALK )
      set_message(self.id, "kfood") 
    end
  end
  if get_state(self.id) ~= CREATURE_WALK then
--     set_path( self.id, self.walkx, self.walky )
    set_state( self.id, CREATURE_WALK )
  end
end

-- eat
function Creature:eat()
  self.was_food = get_tile_food(self.id)
  set_message(self.id, "eating")
  set_state( self.id, CREATURE_EAT )
end

-- heal
function Creature:heal()
  while get_health(self.id) < end_heal_health and get_food(self.id) > 0 and not get_state(self.id) ~= CREATURE_ATTACK and not get_state(self.id) ~= CREATURE_CONVERT do
    set_state(self.id, CREATURE_HEAL)
    set_message(self.id, "HEAL")
    self:wait_for_next_round()
  end
end

-- convert, but decide convert to what
function Creature:convert()
-- first only one fly, 
  if get_typ2 and my_creatures >= typ2_min and my_flys < 1 and not koth_walkable and not getting_fly then
	print ("get fly, cause creatures = " .. my_creatures .. " and my_mums = " .. my_mums .. " and koth seems not walkable")
--[[	if koth_walkable then
	  print("koth walkable")
	else
	  print("koth not walkable")
	end]]
	getting_fly = true
	self.become = "c:fly"
	set_convert( self.id, fly )
--	my_flys = my_flys + 1
  elseif get_typ2 and my_creatures >= typ2_min and my_mums >= typ2_min_typ1 and my_workers > typ2_min_typ0 and my_flys < max_flys and not getting_fly then
	print("get fly, cause more than one mum")
	getting_fly = true
	self.become = "c:fly"
	set_convert( self.id, fly )
  elseif get_typ1 then
	print ("creature " .. self.id .. " converting to mum")
	self.become = "c:mum"
	set_convert( self.id, mum )
--	my_mums = my_mums + 1
  else
	print ("No clue what to do now, called creature convert, but no conversion chosen")
	return
  end
  set_state( self.id, CREATURE_CONVERT )
  set_message(self.id, self.become)
  while get_state( self.id ) == CREATURE_CONVERT do
    self:wait_for_next_round()
  end
  getting_fly = false
  set_message(self.id, "converted")
end

-- become koth
function Creature:become_koth()
  kothx,kothy = get_koth_pos()
  if get_king and not king then
	set_message (self.id, "WalkKoth")
	walking_koth = self.id
	lauf = set_path( self.id, kothx, kothy )
	if not lauf then
	  koth_walkable = false
	  walking_koth = false
	  print("koth seams not walkable")
	  self:search_food()
	else
	  -- do we need to set path here again?
	  set_path(self.id, kothx,kothy)
	  set_state( self.id, CREATURE_WALK )
	  set_message (self.id, "WalkKoth")
	  self.mex,self.mey = get_pos(self.id)
	  while self.mex ~= kothx and self.mey ~= kothy do
	    self.health = get_health(self.id)
	    self.food = get_food(self.id)
	    self.mex,self.mey = get_pos(self.id)
	    self.here_food = get_tile_food(self.id)
	    if self.here_food >= min_food and self.here_food > food_koord_val then
		  food_koordx = self.mex
		  food_koordy = self.mey
		  food_koord_val = self.here_food
		  food_reporter = self.id
	    elseif self.here_food <= 1 and self.mex == food_koordx and self.mey == food_koordy then
		  food_koord_val = 0
		  food_reporter = false
	    end
	    self:wait_for_next_round()
	  end
	  if king_player() == creature_player(self.id) then
	    king = self.id
	    set_message(self.id, "KING!")
	  end
	end
  else
	print ("Called become_koth but get_king not set or king already exists")
  end
end

-- Kill koth if there is someone, just walk there...
function Creature:walk_koth()
  kothx,kothy = get_koth_pos()
  self.mex,self.mey = get_pos(self.id)
  if self.mex == kothx and self.mey == kothy then
    walk_to_koth = false
    set_message(self.id, "BKoth")
    lauf = false
    --self:search_food()
  else
    set_message (self.id, "KKoth")
    lauf = set_path( self.id, kothx, kothy )
  end
  if not lauf then
    koth_walkable = false
    self:search_food()
  else
    set_path(self.id, kothx,kothy)
    set_state( self.id, CREATURE_WALK )
--     set_message (self.id, "KKoth")
  end
end

-- attack enemy
function Creature:attack(enemyid)
	self.enemyid = enemyid
	if self.id == walking_koth then
	  walking_koth = false
	end
	if get_type(self.id) == 0 then
	  self.attack_range = typ0_attack_range
	else
	  self.attack_range = typ1_attack_range
	end
	if not self.on_attack then
	  while self.enemyid and self.enemydist < self.attack_range do
  -- 	  if not self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id) then
  -- 		return
  -- 	  end
		self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id)
		set_target( self.id, self.enemyid )
	  -- 	print("DEBUG: self.id, enemyid" .. self.id .. ":" .. self.enemyid)
		set_state( self.id, CREATURE_ATTACK )
		set_message(self.id, "KILL")
-- 		print("Attack-range: " .. self.enemydist)
		self:wait_for_next_round()
		self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id)
	  end
-- 	  print ("Enemy dist: " .. self.enemydist)
	  set_message(self.id, "Oohh :(")
	  self.on_attack = false
	  self:search_food()
	elseif self.enemydist < self.attack_range then
		set_target( self.id, self.enemyid )
		set_state( self.id, CREATURE_ATTACK )
		set_message(self.id, "KILL")
	end
	self.on_attack = false
end

-- flee until far enough
function Creature:fleeing(attacker)
  self.forget_koth = game_time() + 10000
  if not creature_exists(attacker) then
    self.flee = false
  else
    self.attacker = attacker
--     self.walkx, self.walky = self:getRandomCoords()
    self:getRandomCoords()
    while get_distance(self.id, self.attacker) < flee_min_range and self.flee do
      if not creature_exists(self.attacker) then
		self.flee = false
		break
      end
      if get_state(self.id) ~= CREATURE_WALK then
-- 	self.walkx, self.walky = self:getRandomCoords()
	self:getRandomCoords()
      end
--       set_path(self.id, self.walkx,self.walky)
      set_state( self.id, CREATURE_WALK )
      set_message(self.id, "fleee")
  -- 	print("flee, line 395")
      self:wait_for_next_round()
    end
--     print("Stopped to flee: " .. self.id)
    self.flee = false
  end
end

function Creature:birth()
  self:begin_spawning()
  while self:is_spawning() do
	self:wait_for_next_round()
  end
  print("new worker born")
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
	food_koord_val = self.here_food
	food_reporter = self.id
	print("here_food: " .. food_koord_val)
  elseif self.here_food <= 1 and self.mex == food_koordx and self.mey == food_koordy then
	food_koord_val = 0
	food_reporter = false
  end
  self.state = get_state(self.id)
  self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id)
  -- flee if enemy is typ1 and near flee_min_range
  if self.enemyid then
    if get_type(self.enemyid) == 1 and self.enemydist < flee_min_range then
      self.flee = self.enemyid
      self:fleeing(self.flee)
    else
      self.flee = false
    end
  end
  kothx,kothy = get_koth_pos()
  self.now_food = convert_food + 500
  if king then
    if king == self.id and kothx == self.mex and kothy == self.mey then
      self.am_king = true
	  set_message(self.id, "KING")
    elseif king == self.id then
      king = false
      self.am_king = false
    end
  end
  if self.flee then
	if king == self.id then
	  king = false
	end
	self:fleeing(self.flee)
  elseif self.health <= convert_health and self.food > self.now_food and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
-- 	print("line 486")
	self:heal()
  elseif self.health > convert_health and self.food > convert_food and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:convert()
-- 	return
  elseif self.health < heal_health and self.food > min_heal_food and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:heal()
  elseif self.here_food > 0 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" and self.food < worker_max_food then
	self:eat()
  elseif self.enemyid and self.enemydist and self.enemydist < typ0_attack_range and typ0_kill == true and get_type(self.enemyid) == 2 then
	self.enemy_type = get_type(self.enemyid)
	self:attack(self.enemyid)
  elseif self.am_king then
	while king_player == creature_player(self.id) do
	  self.food = get_food(self.id)
	  self.health = get_health(self.id)
	  print("am king an health is: " .. self.health)
	  -- even if king, check health and heal if needed
	  if self.health < heal_health and self.food > 0 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
		print("creature " .. self.id .. " called heal health: " .. self.health)
		self.am_king = false
		self:heal()
	  elseif get_health(self.id) < koth_leave_health then
		print("leaving KING")
		king = false
		walking_koth = false
		self.am_king = false
		set_message(self.id, "sfood")
		self:search_food()
		break
	  else
		king = self.id
	  end
	  self:wait_for_next_round()
	end
	self.am_king = false
	if get_health(self.id) < koth_leave_health then
 		print("leaving KING")
		king = false
		walking_koth = false
		self.am_king = false
		set_message(self.id, "sfood")
		self:search_food()
	end
  elseif self.health > koth_walk_health and koth_walkable and get_king and not king and walking_koth == self.id and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" and game_time() > self.forget_koth then
	self:become_koth()
  elseif self.health > koth_walk_health and koth_walkable and get_king and not king and not walking_koth and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" and game_time() > self.forget_koth then
	self:become_koth()
  else
    if king == self.id then
      king = false
    end
    set_message(self.id, "sfood")
    self:search_food()
  end
end

--------------------------------------------------------------------------
-- Main Mum
--------------------------------------------------------------------------

function Creature:main_mum()
  self.health = get_health(self.id)
  self.food = get_food(self.id)
  self.mex,self.mey = get_pos(self.id)
  self.here_food = get_tile_food(self.id)
  if self.here_food >= min_food and self.here_food > food_koord_val then
	food_koordx = self.mex
	food_koordy = self.mey
	food_koord_val = self.here_food
	food_reporter = self.id
	print("here_food: " .. food_koord_val)
  elseif self.here_food <= 1 and self.mex == food_koordx and self.mey == food_koordy then
	food_koord_val = 0
	food_koordx = false
	food_koordy = false
  end
  self.state = get_state(self.id)
  self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id)
  kothx,kothy = get_koth_pos()
  if king then
    if king == self.id and kothx == self.mex and kothy == self.mey then
      self.am_king = true
	  set_message(self.id, "KING")
    elseif king == self.id then
      king = false
      self.am_king = false
    end
  end
  self.now_food = birth_food + 500
  if self.enemyid and self.enemydist and self.enemydist < typ1_attack_range and self.state ~= "CREATURE_CONVERT" and typ1_kill == true then
	self:attack(self.enemyid)
  elseif self.health < birth_health and self.food > self.now_food and not self:is_spawning() and self.state ~= "CREATURE_ATTACK" then
	self:heal()
  elseif self.health > birth_health and self.food > birth_food and self.state ~= "CREATURE_ATTACK" then
	self:birth()
  elseif self.health < heal_health and self.food > min_heal_food_mum and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:heal()
  elseif self.here_food > 0 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" and self.food < worker_max_food then
	self:eat()
  elseif self.am_king then
	while king_player() == creature_player(self.id) do
	  self.health = get_health(self.id)
	  self.food = get_food(self.id)
	  -- even if king, check health and heal if needed
	  if self.health < heal_health and self.food > 0 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
		self.am_king = false
		self:heal()
	  elseif self.health < koth_leave_health then
		print("leaving king")
		king = false
		walking_koth = false
		self.am_king = false
		self:search_food()
		break
	  else
		king = self.id
		set_message(self.id, "KING")
	  end
	  self:wait_for_next_round()
	end
	self.am_king = false
	king = false
	if get_health(self.id) < koth_leave_health then
 		print("leaving KING")
		king = false
		walking_koth = false
		self.am_king = false
		set_message(self.id, "sfood")
		self:search_food()
	end
  elseif self.health > koth_walk_health and koth_walkable and get_king and not king and walking_koth == self.id and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:become_koth()
  elseif self.health > koth_walk_health and koth_walkable and get_king and not king and not walking_koth and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:become_koth()
  elseif walk_to_koth and koth_walkable and self.health > kill_health and not king then
	self:walk_koth()
  else
    set_message(self.id, "sfood")
    self:search_food()
  end
end

--------------------------------------------------------------------------
-- Main Fly
--------------------------------------------------------------------------
function Creature:main_fly()
  -- get some infos of me
  self.health = get_health(self.id)
  self.food = get_food(self.id)
  self.mex,self.mey = get_pos(self.id)
  self.here_food = get_tile_food(self.id)
  if self.here_food >= min_food and self.here_food > food_koord_val then
	food_koordx = self.mex
	food_koordy = self.mey
	food_koord_val = self.here_food
	food_reporter = self.id
	print("here_food: " .. food_koord_val)
  elseif self.here_food <= 1 and self.mex == food_koordx and self.mey == food_koordy then
	food_koord_val = 0
	food_koordx = false
	food_koordy = false
	food_reporter = false
  end
  self.state = get_state(self.id)
  self.enemyid, self.enemyx, self.enemyy, self.enemynum, self.enemydist = get_nearest_enemy(self.id)
  -- flee if enemy is typ1 and near flee_min_range
  if self.enemyid then
      if self.enemydist < flee_min_range and get_type(self.enemyid) ~= 2 then
      self.flee = self.enemyid
      print("fleeeeeeee self.enemydist:flee_min_range enemy_type" .. self.enemydist .. ":" .. flee_min_range .. ":" .. get_type(self.enemyid))
      self:fleeing(self.flee)
    else
      self.flee = false
    end
  end
  kothx,kothy = get_koth_pos()
  self.now_food = convert_food + 500
  if king then
    if king == self.id and kothx == self.mex and kothy == self.mey then
      self.am_king = true
	  set_message(self.id, "KING")
    elseif king == self.id then
      print("not king cause not on king pos")
      king = false
      self.am_king = false
    end
  end
  if self.flee then
	if king == self.id then
	  king = false
	end
	self:fleeing(self.flee)
  elseif self.health < heal_health and self.food > min_heal_food and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" then
	self:heal()
  elseif self.here_food > 0 and self.state ~= "CREATURE_CONVERT" and self.state ~= "CREATURE_ATTACK" and self.food < fly_max_food then
	self:eat()
  elseif self.am_king then
	while king_player() == creature_player(self.id) do
	  self.health = get_health(self.id)
	  self.food = get_food(self.id)
	  -- even if king, check health and heal if needed
	  if self.health < heal_health and self.food > 0 then
		self.am_king = false
		self:heal()
	  elseif get_health(self.id) < koth_leave_health then
		print("leaving king")
		king = false
		walking_koth = false
		self.am_king = false
		self:search_food()
		break
	  else
		king = self.id
		set_message(self.id, "KING")
	  end
	  self:wait_for_next_round()
	end
	self.am_king = false
	if get_health(self.id) < koth_leave_health then
 		print("leaving KING")
		king = false
		walking_koth = false
		self.am_king = false
		set_message(self.id, "sfood")
		self:search_food()
	end
	-- should we geht koth?
  elseif self.health > koth_walk_health and koth_walkable_fly and get_king and not king and walking_koth == self.id and self.state ~= "CREATURE_CONVERT" and game_time() > self.forget_koth then
	print("become_koth")
	self:become_koth()
  elseif self.health > koth_walk_health and koth_walkable_fly and get_king and not king and not walking_koth and self.state ~= "CREATURE_CONVERT" and game_time() > self.forget_koth then
	print("become_koth")
	self:become_koth()
  else
    if get_king then
      print("get_king true")
      print("gametime : forget koth" ..  game_time() .. ":" .. self.forget_koth)
    end
    if not get_king then
      print("not get_king")
    end
    if koth_walkable_fly then
      print("walkable_fly")
    end
    if walking_koth then
      print("walking_koth = " .. walking_koth)
    end
    set_message(self.id, "sfood")
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
  self.was_food = 0
  koth_walkable = reset_koth_walkable
  self.flee = false
  self.forget_koth = 0
end


-- Called each round for every attacker on this
-- creature. No long-running methods here!
function Creature:onAttacked(attacker)
  self.attacker = attacker
  self.am_king = false
  local attacker_type = get_type(self.attacker)
  local my_type = get_type(self.id)
  if my_type == worker and attacker_type == fly then
	self.on_attack = true
	self:attack(self.attacker)
  elseif my_type == mum then
	self.on_attack = true
	self:attack(self.attacker)
  elseif my_type == fly then
	self.attacker = attacker
	self.flee = self.attacker
	if get_state(self.id) ~= CREATURE_WALK then
	  self:getRandomCoords()
	end
	set_state( self.id, CREATURE_WALK )
	set_message(self.id, "fleee")
  else
	self.flee = self.attacker
	if get_state(self.id) ~= CREATURE_WALK then
	  self:getRandomCoords()
	  set_state( self.id, CREATURE_WALK )
	  set_message(self.id, "fleee")
	end
  end
end

-- ege second reset for some values like koth_walkable
function reset2()
  future2 = now + reset_wait2
  koth_walkable = reset_koth_walkable
  koth_walkable_fly = reset_koth_walkable_fly
  
end  

-- Called by typing 'r' in the console, after creation (after
-- onSpawned) or by calling self:restart(). No long-running
-- methods calls here!
function Creature:onRestart()
  --reset some variables all reset_wait msecs
  future = now + reset_wait
  koth_walkable = reset_koth_walkable
  local chkd=0
  for id, creature in pairs(creatures) do
	local posx,posy=get_pos(id)
	print(id .. ": " ..get_type(id) .. " on "..posx..":"..posy .. "==> hp:"..get_health(id)..". food:"..get_food(id) .." state:" .. get_state(id).." punkte: "..player_score(player_number))
	chkd=chkd+1
  end
  if king then
	print("king: " .. king )
  end
  print ("Wir haben " .. my_creatures .. " Kreaturen")
  print ("Wir haben " .. my_workers .. " Worker")
  print ("Wir haben " .. my_mums .. " Mums")
  print ("Wir haben " .. my_flys .. " Flies")
  time = game_time()
  COUNT=chkd
  self.was_food = 0
  -- when resetting set last food koords to food again, should have grown again now
  food_koord_val = 5000
  self.flee = false
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
  if self.id == food_reporter then
    food_reporter = false
  end
  if walking_koth == self.id then
     walking_koth = false
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
--   me = player_number()
--   print("me: " .. self.me)
--[[  if king then
    print("KING " .. king)
	if not creature_exists(king) then
	  print("King does not exist any more, unsetting king")
	  king = false
	end
  end]]
--[[  if self.nearby_count then
    print("nearby_count player: " .. self.id .. " ist " .. self.nearby_count)
  end]]
  if not self.forget_koth then
    self.forget_koth = 0
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
  now = game_time()
  if now >= future then
	Creature:onRestart()
  end
  if now >= future2 then
    reset2()
  end
  if now >= future3 then
    future3 = now + reset_wait3
    walk_to_koth = true
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
.
s
c
34

