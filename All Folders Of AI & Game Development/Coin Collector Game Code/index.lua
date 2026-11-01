local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
 
-- ================= CONFIGURATION =================
local NUM_COINS = 10          -- how many coins to spawn
local SPAWN_RADIUS = 40       -- how far from the center coins can spawn
local SPAWN_HEIGHT = 3        -- height above the baseplate
local RESPAWN_DELAY = 5       -- seconds before a collected coin respawns
local COIN_VALUE = 1          -- coins earned per pickup
local COIN_COLOR = Color3.fromRGB(255, 215, 0) -- gold
 
-- ================= LEADERSTATS =================
Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
 
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats
end)
 
-- ================= COIN CREATION =================
local function createCoinPart(position)
    local coin = Instance.new("Part")
    coin.Name = "Coin"
    coin.Shape = Enum.PartType.Cylinder
    coin.Size = Vector3.new(0.5, 2, 2)
    coin.Orientation = Vector3.new(0, 0, 90) -- stand it upright like a coin
    coin.Position = position
    coin.Anchored = true
    coin.CanCollide = false
    coin.Material = Enum.Material.Neon
    coin.Color = COIN_COLOR
    coin.Parent = Workspace
 
    -- Sound effect
    local sound = Instance.new("Sound")
    sound.Name = "CollectSound"
    sound.SoundId = "rbxassetid://6518811702" -- generic coin pickup sound
    sound.Volume = 1
    sound.Parent = coin
 
    return coin
end
 
-- ================= COIN SPIN ANIMATION =================
local function spinCoin(coin)
    task.spawn(function()
        while coin and coin.Parent do
            coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(4), 0)
            task.wait(0.03)
        end
    end)
end
 
-- ================= COIN COLLECTION + RESPAWN =================
local function setupCoin(position)
    local coin = createCoinPart(position)
    spinCoin(coin)
 
    local debounce = false
 
    coin.Touched:Connect(function(hit)
        if debounce then return end
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
 
        if player then
            debounce = true
 
            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                local coinsStat = leaderstats:FindFirstChild("Coins")
                if coinsStat then
                    coinsStat.Value = coinsStat.Value + COIN_VALUE
                end
            end
 
            -- Play sound, then hide and destroy the coin
            local sound = coin:FindFirstChild("CollectSound")
            if sound then
                sound.Parent = Workspace -- detach so it can finish playing after coin is destroyed
                sound.Position = coin.Position
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 2)
            end
 
            coin:Destroy()
 
            -- Respawn a new coin at the same location after a delay
            task.delay(RESPAWN_DELAY, function()
                setupCoin(position)
            end)
        end
    end)
end
 
-- ================= INITIAL COIN SPAWNING =================
local function getRandomSpawnPosition()
    local angle = math.random() * math.pi * 2
    local distance = math.random() * SPAWN_RADIUS
    local x = math.cos(angle) * distance
    local z = math.sin(angle) * distance
    return Vector3.new(x, SPAWN_HEIGHT, z)
end
 
for i = 1, NUM_COINS do
    local position = getRandomSpawnPosition()
    setupCoin(position)
end
 
print("Coin Collector Game loaded! " .. NUM_COINS .. " coins spawned.")
 