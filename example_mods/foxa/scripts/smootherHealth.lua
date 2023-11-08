--[[
    GhostUtil v0.1.5 - Smoother Health Bars

    Now includes:
        Health Drain!
        Advanced Options!
        Configurations!

    If you found ANY bugs please do report to the owner of this script (Ghost)
        Include these details:
        -  What's the bug? *
        -  What's causing it? (Depends on option)
        -  Did you change anything on the script? *

    MADE BY GHOST (don't you dare remove this)
]]

-- Only edit this if you don't know what you're doing!
local config = {
    enabled = true, -- Enables the Smoother Health Bar. (Enabled by Default)
    bfGainAmount = 0.005, -- How many health should BF gain per frames (Default: 0.005)
    bfMissAmount = 0.0015, -- How many damage should BF take from a miss per frames (Default: 0.0015)

    -- Smoother Health Bar with Health Drain
    healthDrain = false, -- Enables Health Drain (Disabled by Default) (ONLY WORKS IF THE SMOOTHER HEALTH BAR IS ALSO TURNED ON!)
    drainWithMult = false, -- Drains the health with the health gain's multiplier (Disabled by Default)
    dadDrainAmount = 0.0035, -- How many health should "dad" drain from BF per frames (Default: 0.0035)
    minHealth = 0.4, -- At what point should the health drain stop? (0 - 2) (Default: 0.4)

    -- ADVANCED
    bfGainAmountSustain = 0.003, -- How many health should BF gain with sustain notes per frames (Default: 0.003)
    bfMissAmountSustain = 0.0005, -- How many damage should BF take from a sustain note miss per frames (Default: 0.0007)

    -- Making these number higher also affects how the gain and drain amounts gives.
    bfGainTime = 0.07, -- The higher the number, the more time it gives for the player to gain health smooth-ly (Default: 0.07)
    dadDrainTime = 0.07 -- The higher the number, the more time it gives for the dad to drain health smooth-ly (Default: 0.07)
}

function onCreate()
    -- Enabled for tracing error(s) and warning(s)
    luaDebugMode = true
    luaDeprecatedWarnings = true
end

-- Do NOT edit any of these if you DO NOT know what you're doing!

-- Variables
local gain = false
local drain = false
local miss = false
local gainSustain = false
local missSustain = false

-- Gains and Drains
local gainAmount = 0
local gainAmountSustain = 0
local missAmount = 0
local drainAmount = (config.dadDrainAmount)

-- Fake health, lmao
local fakeHealth = 1

function onCreatePost()
    if config.drainWithMult then
        drainAmount = (drainAmount * healthGainMult)
    else
        drainAmount = (drainAmount)
    end
    gainAmount = (config.bfGainAmount * healthGainMult)
    gainAmountSustain = (config.bfGainAmountSustain * healthGainMult)
    missAmount = (config.bfMissAmount * healthLossMult)
    missAmountSustain = (config.bfMissAmount * healthLossMult)
end

function opponentNoteHit(id, nd, nt, s)
    if config.healthDrain and config.enabled and fakeHealth >= config.minHealth then
        drain = true
        runTimer("ghostUtil.smootherHealth-Drain_Timer", config.dadDrainTime)
    end
end

function goodNoteHit(id, nd, nt, s)
    if config.enabled then
        if s then
            gainSustain = true
            runTimer("ghostUtil.smootherHealth-GainSustain_Timer", config.bfGainTime)
        else
            gain = true
            runTimer("ghostUtil.smootherHealth-Gain_Timer", config.bfGainTime)
        end
    end
end

function noteMissPress(id)
    if config.enabled then
        miss = true
        runTimer("ghostUtil.smootherHealth-Miss_Timer", 0.05)
    end
end

function noteMiss(id, nd, nt, s)
    if config.enabled then
        if s then
            missSustain = true
            runTimer("ghostUtil.smootherHealth-MissSustain_Timer", 0.05)
        else
            miss = true
            runTimer("ghostUtil.smootherHealth-Miss_Timer", 0.05)
        end
    end
end

function onUpdate()
    if drain then
        fakeHealth = fakeHealth - drainAmount;
    elseif gain then
        fakeHealth = fakeHealth + gainAmount;
    elseif miss then
        fakeHealth = fakeHealth - missAmount;
    elseif gainSustain then
        fakeHealth = fakeHealth + gainAmountSustain
    elseif missSustain then
        fakeHealth = fakeHealth - missAmountSustain
    end
    setProperty("health", fakeHealth)

    if fakeHealth >= 2 then
        fakeHealth = 2
    end
end

function onTimerCompleted(t, l, ll)
    local prefix = "ghostUtil.smootherHealth-"
    local suffix = "_Timer"
    if t == prefix.."Drain"..suffix then
        drain = false
    elseif t == prefix.."Gain"..suffix then
        gain = false
    elseif t == prefix.."Miss"..suffix then
        miss = false
    elseif t == prefix.."GainSustain"..suffix then
        gainSustain = false
    elseif t == prefix.."MissSustain"..suffix then
        missSustain = false
    end
end
