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
koth_health = 20
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
typ1_min = 1
typ2_min = 2
typ2_min_typ1 = 1

-- if fleeing, we need to flee more than enemy can reach
flee_min_range = 1000

-- predefined
king = false
-- reset values, get resettet every reset_wait msecs

reset_king = false
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

-- search for food
function Creature:search_food()
    set_message(self.id, "hungry")
end

-- convert, but decide convert to what
function Creature:convert()
 
end

-- attack enemy
function Creature:attack(enemy)
 
end
-- main for workers

function Creature:main_worker()
    -- get some infos of me
    local health = get_health(self.id)
    local food = get_food(self.id)
    local mex,mey = get_pos(self.id)
    if get_tile_food(self.id) >= min_food then
        food_koordx = mex
        food_koordy = mey
    end
    local state = get_state()
    local enemyid, enemyx, enemyy, enemynum, enemydist = get_nearest_enemy(self.id)
    if king then
        if king == self.id then
            set_message(self.id, "KING")
        else
            local otherking = true
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
    elseif get_tile_food(self.id) > 0 and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
        self:eat()
    elseif enemyid and enemydist < typ0_attack_range and state not "CREATURE_CONVERT" and typ0_kill == true then
        self:attack(enemyid)
-- should we geht koth?
    elseif health > koth_health and koth_walkable and not otherking and state not "CREATURE_CONVERT" and state not "CREATURE_ATTACK" then
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
end


-- Called each round for every attacker on this
-- creature. No long-running methods here!
function Creature:onAttacked(attacker)
    -- print("Help! Creature " .. self.id .. " is attacked by Creature " .. attacker)
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
end


-- Your Creature Logic here :-)
function Creature:main()
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

