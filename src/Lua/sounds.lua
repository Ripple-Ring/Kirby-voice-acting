
-- worst mod ever >:(
-- -pac

---@class mobj_t
---@field laststate statenum_t

---@class player_t
---@field kvars table
---@field lastkvars table
---@field lastpflags playerflags_t
---@field lastexiting tic_t

sfxinfo[freeslot("sfx_krbwin")].caption = "Kirby Victory"
sfxinfo[freeslot("sfx_krbclr")].caption = "Yes!"
sfxinfo[freeslot("sfx_krbdie")].caption = "Desperate times call for desperate meahsurs"
sfxinfo[freeslot("sfx_krbgov")].caption = "Kirby Crying"
sfxinfo[freeslot("sfx_krbjmp")].caption = "Kirby Jump"
sfxinfo[freeslot("sfx_krbkil")].caption = "That is one dead Waedle Dee"
for i = 1, 3 do
    sfxinfo[freeslot("sfx_krbht"+i)].caption = "Kirby Hurt"
end
sfxinfo[freeslot("sfx_krbinv")].caption = "I am now ready to rumble"
sfxinfo[freeslot("sfx_krbbat")].caption = "Take this!"
sfxinfo[freeslot("sfx_krbbst")].caption = "Quit while you're ahead"

sfxinfo[freeslot("sfx_krbfst")].caption = "Kirby Floating"
sfxinfo[freeslot("sfx_krbinh")].caption = "Kirby Inhaling"
sfxinfo[freeslot("sfx_krbswa")].caption = "Kirby Swallowing"
sfxinfo[freeslot("sfx_krbcpa")].caption = "Let's do this!"
sfxinfo[freeslot("sfx_krbbsp")].caption = "Kirby Spitting"
sfxinfo[freeslot("sfx_krbspt")].caption = "Kirby Spitting"

---@param name string
local function getConstant(name)
    local success, value = pcall(function()
        return constants[name]
    end)

    if success then
        return value
    end
end

---@param p player_t
addHook("PlayerThink", function(p)
    if not (p.mo and p.mo.valid)
    or p.mo.skin ~= "kirby" then return end

    if p.mo.state ~= p.mo.laststate then
        if p.mo.state == getConstant("S_KIRBY_FLOATSTART") then
            S_StartSound(p.mo, sfx_krbfst)
        elseif p.mo.state == getConstant("S_KIRBYSUCKS") then
            S_StartSound(p.mo, sfx_krbinh)
        elseif p.mo.state == getConstant("S_KIRBY_CONSUME") then
            if p.lastkvars and p.lastkvars.toability then
                S_StartSound(p.mo, sfx_krbcpa)
            else
                S_StartSound(p.mo, sfx_krbswa)
            end
        elseif p.mo.state == getConstant("S_KIRBY_SPIT") then
            if p.lastkvars and p.lastkvars.suckedmultiple then
                S_StartSound(p.mo, sfx_krbbsp)
            else
                S_StartSound(p.mo, sfx_krbspt)
            end
        end
    end

    if p.lastpflags ~= nil then
        if (p.pflags & PF_FINISHED)
        and not (p.lastpflags & PF_FINISHED)
        or p.exiting
        and p.lastexiting == 0 then
            S_StartSound(p.mo, sfx_krbwin + P_RandomRange(0, 1))
        end

        if (p.pflags & PF_JUMPED)
        and not (p.lastpflags & PF_JUMPED) then
            S_StartSound(p.mo, sfx_krbjmp)
        end
    end

    if p.powers[pw_invulnerability] == invulntics-1 then
        S_StartSound(p.mo, sfx_krbinv)
    end

    p.lastpflags = p.pflags
    p.lastexiting = p.exiting
    p.lastkvars = p.kvars
    p.mo.laststate = p.mo.state
end)

---@param pmo mobj_t
---@param dmgtype integer
addHook("MobjDamage", function(pmo, _, _, _, dmgtype)
    if pmo.skin ~= "kirby"
    or (dmgtype & DMG_DEATHMASK) then return end

    local p = pmo.player
    if p.rings == 0
    and p.powers[pw_shield] == 0 then return end

    S_StartSound(pmo, constants["sfx_krbht"+P_RandomRange(1, 3)])
end, MT_PLAYER)

---@param pmo mobj_t
addHook("MobjDeath", function(pmo)
    if pmo.skin == "kirby" then
        if pmo.player.lives == 0 then
            S_StartSound(pmo, sfx_krbgov)
        else
            S_StartSound(pmo, sfx_krbdie)
        end
    end
end, MT_PLAYER)

addHook("MobjDamage", function(mo, _, pmo)
    if (mo.flags & MF_BOSS)
    and (pmo and pmo.valid)
    and (pmo.player and pmo.player.valid)
    and pmo.skin == "kirby" then
        S_StartSound(pmo, sfx_krbbat)
    end
end)

addHook("MobjDeath", function(mo, _, pmo)
    if (mo.flags & MF_ENEMY)
    and (pmo and pmo.valid)
    and (pmo.player and pmo.player.valid)
    and pmo.skin == "kirby" then
        S_StartSound(pmo, sfx_krbkil)
    end
end)

addHook("MapLoad", function(id)
    if mapheaderinfo[id]
    and mapheaderinfo[id].bonustype == 2
    and mapheaderinfo[id].bonustype == 3 then
        for p in players.iterate do
            if (p.mo and p.mo.valid)
            and p.mo.skin == "kirby" then
                S_StartSound(p.mo, sfx_krbbst)
            end
        end
    end
end)