print([[

 _______                             __                                __    __          __       

|       \                           |  \                              |  \  |  \        |  \      
| $$$$$$$\ ______   ______   ______ | $$   __  ______   ______        | $$  | $$__    __| $$____  
| $$__/ $$/      \ /      \ |      \| $$  /  \/      \ /      \       | $$__| $|  \  |  | $$    \ 
| $$    $|  $$$$$$|  $$$$$$\ \$$$$$$| $$_/  $|  $$$$$$|  $$$$$$\      | $$    $| $$  | $| $$$$$$$\
| $$$$$$$| $$   \$| $$    $$/      $| $$   $$| $$    $| $$   \$$      | $$$$$$$| $$  | $| $$  | $$
| $$__/ $| $$     | $$$$$$$|  $$$$$$| $$$$$$\| $$$$$$$| $$            | $$  | $| $$__/ $| $$__/ $$
| $$    $| $$      \$$     \\$$    $| $$  \$$\\$$     | $$            | $$  | $$\$$    $| $$    $$
 \$$$$$$$ \$$       \$$$$$$$ \$$$$$$$\$$   \$$ \$$$$$$$\$$             \$$   \$$ \$$$$$$ \$$$$$$$ 
 - (.gg/DMNXkC6CYB)
]])

print("___________________________________________________________________________________________")


local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Wait for game to fully load
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
if not game:IsLoaded() then game.Loaded:Wait() end

-- Load UI library
local Fluent = loadstring(game:HttpGet("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/InterfaceManager.luau"))()

-- Create main window
local Window = Fluent:CreateWindow({
    Title = "Breaker Hub | Anime Rising V.2.2",
    SubTitle = ".gg/DMNXkC6CYB",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = false,
    Theme = "Green",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Create tabs
local Tabs = {
    About = Window:AddTab({ Title = "About", Icon = "circle-alert" }),
    Main = Window:AddTab({ Title = "Farm", Icon = "star" }),
    Dungeon = Window:AddTab({ Title = "Dungeon", Icon = "swords" }),
    Pets = Window:AddTab({ Title = "Pets", Icon = "egg" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window:SelectTab(1)

-- About Tab
Tabs.About:CreateParagraph("Welcome", {
    Title = "Breaker Hub",
    Content = "This script is just release will have no update since the game is... you know what? Thank you for using this script :)",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.About:CreateParagraph("Important", {
    Title = "Information",
    Content = "If you found this script requiring a key, it's not the official version. Join our Discord to get the keyless version!",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

Tabs.About:AddSection("Discord")
Tabs.About:AddButton({
    Title = "Discord Link",
    Description = "Copy the link to join the discord!",
    Callback = function()
        setclipboard("https://discord.gg/DMNXkC6CYB")
        Fluent:Notify({
            Title = "Notification",
            Content = "Link copied :3",
            Duration = 5 
        })
    end
})

-- Variables
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Auto-update character reference
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Farm variables
local selectedWorld = nil
local selectedEnemy = nil
local currentTarget = nil
local autoFarm = false
local teleported = false
local enemyDropdown = nil
local teleportDelay = 1
local lastTeleportTime = 0
local awaitingArise = false
local postDeathDelay = 1
local deathTime = 0

local RARITY_PRIORITY = {
    Common = 1, Rare = 2, Epic = 3, Legendary = 4,
    Mythical = 5, Mythical2 = 6, Secret = 7, Secret2 = 8
}
local RARITY_VALUES = { "Common", "Rare", "Epic", "Legendary", "Mythical", "Mythical2", "Secret", "Secret2" }
local selectedRarity = "Common"

-- Helper functions
local function getEnemiesFolder(worldName)
    local success, folder = pcall(function()
        return Workspace:WaitForChild("Worlds"):WaitForChild(worldName):WaitForChild("Enemies")
    end)
    if success then return folder end
    return nil
end

local function getEnemyNamesFromWorld(worldName)
    local folder = getEnemiesFolder(worldName)
    if not folder then return {} end
    local unique, added = {}, {}
    for _, enemy in ipairs(folder:GetChildren()) do
        if not added[enemy.Name] then
            table.insert(unique, enemy.Name)
            added[enemy.Name] = true
        end
    end
    return unique
end

local function updateEnemyDropdown(worldName)
    local enemyList = getEnemyNamesFromWorld(worldName)
    if enemyDropdown then enemyDropdown:SetValues(enemyList) end
end

local function isEnemyAlive(enemy)
    return enemy and enemy.Parent and enemy:FindFirstChild("HumanoidRootPart") and enemy:GetAttribute("Health") and enemy:GetAttribute("Health") > 0
end

local function getAllEnemies(folder)
    local result = {}
    if not folder then return result end
    
    for _, enemy in ipairs(folder:GetChildren()) do
        local meta = enemy:FindFirstChild("Metadata")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        if meta and root and enemy:GetAttribute("Health") and enemy:GetAttribute("Health") > 0 then
            local rarity = meta:FindFirstChild("Rarity") and meta.Rarity:GetAttribute("Value") or "Common"
            local shiny = meta:FindFirstChild("Shiny") and meta.Shiny:GetAttribute("Value") or false
            table.insert(result, {
                Model = enemy,
                Root = root,
                Distance = (humanoidRootPart.Position - root.Position).Magnitude,
                Rarity = rarity,
                RarityLevel = RARITY_PRIORITY[rarity] or 0,
                Shiny = shiny
            })
        end
    end
    return result
end

local function findBestEnemy(enemies)
    local minRarityLevel = RARITY_PRIORITY[selectedRarity] or 1
    local filtered = {}
    for _, e in ipairs(enemies) do
        if e.RarityLevel >= minRarityLevel then
            table.insert(filtered, e)
        end
    end
    table.sort(filtered, function(a, b)
        if a.RarityLevel ~= b.RarityLevel then
            return a.RarityLevel > b.RarityLevel
        elseif a.Shiny ~= b.Shiny then
            return a.Shiny
        else
            return a.Distance < b.Distance
        end
    end)
    return filtered[1]
end

-- Main farm loop
RunService.Heartbeat:Connect(function()
    if autoFarm and selectedWorld then
        local enemiesFolder = getEnemiesFolder(selectedWorld)
        if not enemiesFolder then return end

        -- Check if current target is still alive
        if currentTarget and not isEnemyAlive(currentTarget) then
            if not awaitingArise then
                awaitingArise = true
                deathTime = tick()
            elseif tick() - deathTime >= postDeathDelay then
                teleported = false
                currentTarget = nil
                awaitingArise = false
            end
            return
        end

        -- Find new target if needed
        if not teleported and tick() - lastTeleportTime >= teleportDelay then
            local allEnemies = getAllEnemies(enemiesFolder)
            local target = nil

            if selectedEnemy and selectedEnemy ~= "" then
                for _, e in ipairs(allEnemies) do
                    if e.Model.Name == selectedEnemy then
                        target = e
                        break
                    end
                end
            else
                target = findBestEnemy(allEnemies)
            end

            if target and humanoidRootPart then
                currentTarget = target.Model
                humanoidRootPart.CFrame = target.Root.CFrame * CFrame.new(0, 5, 0)
                teleported = true
                lastTeleportTime = tick()

                -- Try to set pet target
                pcall(function()
                    local petsFolder = Workspace:FindFirstChild("Pets")
                    if petsFolder then
                        local pet = petsFolder:FindFirstChild("3ZEGAOG-8")
                        if pet then
                            ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Pets"):WaitForChild("SetTarget"):FireServer(pet)
                        end
                    end
                end)
            end
        elseif currentTarget and isEnemyAlive(currentTarget) and humanoidRootPart then
            -- Stay close to target
            local distance = (humanoidRootPart.Position - currentTarget.HumanoidRootPart.Position).Magnitude
            if distance > 10 then
                humanoidRootPart.CFrame = currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
            end

            -- Trigger arise opportunity
            if currentTarget:GetAttribute("UniqueID") then
                pcall(function()
                    local args = { tostring(currentTarget:GetAttribute("UniqueID")) }
                    ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Orbs"):WaitForChild("AriseOpportunity"):FireServer(unpack(args))
                end)
            end
        end
    end
end)

-- Farm Tab UI
Tabs.Main:AddDropdown("WorldDropdown", {
    Title = "Select World",
    Description = "Choose a world",
    Values = { "Solo", "OnePiece", "DemonSlayer", "DBZ" },
    Callback = function(world)
        selectedWorld = world
        teleported = false
        currentTarget = nil
        updateEnemyDropdown(world)
    end
})

enemyDropdown = Tabs.Main:AddDropdown("EnemiesDropdown", {
    Title = "Select Enemy",
    Description = "Pick specific enemy or leave empty for auto",
    Values = {},
    Callback = function(selected)
        selectedEnemy = selected
        teleported = false
        currentTarget = nil
    end
})

Tabs.Main:AddDropdown("RarityDropdown", {
    Title = "Minimum Rarity",
    Description = "Filter minimum rarity",
    Values = RARITY_VALUES,
    Default = 1,
    Callback = function(selected)
        selectedRarity = selected
    end
})

Tabs.Main:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm",
    Description = "Teleport and attack",
    Default = false,
    Callback = function(state)
        autoFarm = state
        teleported = false
        currentTarget = nil
        Fluent:Notify({
            Title = "Auto Farm",
            Content = state and "Auto Farm Enabled" or "Auto Farm Disabled",
            Duration = 2
        })
    end
})

Tabs.Main:AddSlider("TeleportDelaySlider", {
    Title = "Teleport Delay",
    Description = "Delay between teleports (sec)",
    Default = 3,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Callback = function(value)
        teleportDelay = value
    end
})

-- Auto settings toggles
Tabs.Main:AddToggle("AutoAttackToggle", {
    Title = "Auto Attack",
    Description = "Use this for bypass auto attack",
    Default = false,
    Callback = function(state)
        pcall(function()
            ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("ValueObjects"):WaitForChild("AutoAttack").Value = state
        end)
        Fluent:Notify({
            Title = "Auto Attack",
            Content = state and "Auto Attack Enabled" or "Auto Attack Disabled",
            Duration = 2
        })
    end
})

Tabs.Main:AddToggle("AutoAriseToggle", {
    Title = "Auto Arise",
    Description = "Use this for bypass auto arise",
    Default = true,
    Callback = function(state)
        pcall(function()
            ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("ValueObjects"):WaitForChild("AutoArise").Value = state
        end)
        Fluent:Notify({
            Title = "Auto Arise",
            Content = state and "Auto Arise Enabled" or "Auto Arise Disabled",
            Duration = 2
        })
    end
})

Tabs.Main:AddToggle("AutoAbilityToggle", {
    Title = "Auto Ability",
    Description = "Use this for bypass auto ability",
    Default = false,
    Callback = function(state)
        pcall(function()
            ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("ValueObjects"):WaitForChild("AutoAbility").Value = state
        end)
        Fluent:Notify({
            Title = "Auto Ability",
            Content = state and "Auto Ability Enabled" or "Auto Ability Disabled",
            Duration = 2
        })
    end
})

-- Auto dash system
local autoDash = false
local dashLoopRunning = false

pcall(function()
    local Bindable = ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("Player")
    local AttemptDash = Bindable:WaitForChild("AttemptDash")
    local DashRecharging = Bindable:WaitForChild("DashRecharging")
    local SetDashes = Bindable:WaitForChild("SetDashes")
    local UpdateMaxDashes = Bindable:WaitForChild("UpdateMaxDashes")
    
    DashRecharging.Event:Connect(function()
        SetDashes:Fire(999)
    end)
    UpdateMaxDashes:Fire(999)

    Tabs.Main:AddToggle("AutoDashToggle", {
        Title = "Auto Dash",
        Default = false,
        Callback = function(state)
            autoDash = state
            if autoDash and not dashLoopRunning then
                dashLoopRunning = true
                spawn(function()
                    while autoDash do
                        AttemptDash:Fire()
                        task.wait(0.1)
                    end
                    dashLoopRunning = false
                end)
            end
        end
    })
end)

-- Pet Hatch Tab
Tabs.Pets:AddSection("Gacha")
Tabs.Pets:CreateParagraph("GemNotice", {
    Title = "Gem Requirement",
    Content = "You need at least 7,500 gems to hatch a pet from this banner.",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

local autoHatch = false
local bannerName = "PremiumBanner1"

local function hatchOnce()
    pcall(function()
        local args = { bannerName }
        ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Banners"):WaitForChild("PullSingle"):FireServer(unpack(args))
    end)
end

Tabs.Pets:AddButton({
    Title = "Hatch 1x",
    Description = "Hatch once from the Premium Banner",
    Callback = function()
        hatchOnce()
        Fluent:Notify({
            Title = "Pet Hatch",
            Content = "Attempted to hatch 1x",
            Duration = 2
        })
    end
})

Tabs.Pets:AddToggle("AutoHatch", {
    Title = "Auto Hatch",
    Description = "Keep hatching until this toggle is turned off",
    Default = false,
    Callback = function(state)
        autoHatch = state
        Fluent:Notify({
            Title = "Auto Hatch",
            Content = state and "Auto Hatch Enabled" or "Auto Hatch Disabled",
            Duration = 2
        })
    end
})

-- Auto hatch loop
task.spawn(function()
    while true do
        task.wait(2)
        if autoHatch then
            hatchOnce()
        end
    end
end)

Tabs.Pets:AddToggle("SkipSummonAnimation", {
    Title = "Skip Summon Animation",
    Description = "Skip cutscene when hatching pet",
    Default = true,
    Callback = function(state)
        pcall(function()
            local animFlag = ReplicatedStorage:FindFirstChild("Bindable")
                and ReplicatedStorage.Bindable:FindFirstChild("ValueObjects")
                and ReplicatedStorage.Bindable.ValueObjects:FindFirstChild("DoingSummonAnimation")
            if animFlag then
                animFlag.Value = not state
            end
            
            local orbBindable = ReplicatedStorage:FindFirstChild("Bindable")
                and ReplicatedStorage.Bindable:FindFirstChild("Orbs")
            if orbBindable then
                local runCutscene = orbBindable:FindFirstChild("RunOpeningCutscene")
                if runCutscene and runCutscene:IsA("BindableEvent") then
                    if state then
                        local dummy = Instance.new("BindableEvent")
                        dummy.Name = "RunOpeningCutscene"
                        dummy.Parent = orbBindable
                        runCutscene:Destroy()
                    end
                end
            end
        end)
        
        Fluent:Notify({
            Title = "Summon Animation",
            Content = state and "Cutscene skipped" or "Cutscene enabled",
            Duration = 2
        })
    end
})

-- Pet upgrade system
Tabs.Pets:AddSection("Upgrade")
Tabs.Pets:CreateParagraph("UpgradeNotice", {
    Title = "Upgrade",
    Content = "You need upgrade materials or resources to level up your pet slot. Make sure you have enough before enabling auto upgrade.",
    TitleAlignment = "Middle",
    ContentAlignment = Enum.TextXAlignment.Center
})

local autoUpgrade = false
local selectedSlot = 1
local failedCount = 0

Tabs.Pets:AddDropdown("SlotDropdown", {
    Title = "Select Pet Slot",
    Description = "Choose which pet slot to upgrade",
    Values = { "1", "2", "3", "4", "5" },
    Default = 1,
    Callback = function(value)
        selectedSlot = tonumber(value)
        Fluent:Notify({
            Title = "Selected Slot",
            Content = "Auto upgrade will use pet slot: " .. value,
            Duration = 2
        })
    end
})

Tabs.Pets:AddToggle("AutoUpgrade", {
    Title = "Auto Upgrade",
    Description = "Automatically upgrade selected pet slot",
    Default = false,
    Callback = function(state)
        autoUpgrade = state
        failedCount = 0
        Fluent:Notify({
            Title = "Auto Upgrade",
            Content = state and "Auto upgrade is now active" or "Auto upgrade has been disabled",
            Duration = 2
        })
    end
})

-- Auto upgrade loop
task.spawn(function()
    while true do
        task.wait(1)
        if autoUpgrade and selectedSlot then
            local success = pcall(function()
                local args = { selectedSlot }
                ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Pets"):WaitForChild("LevelUpPetSlot"):FireServer(unpack(args))
            end)

            if not success then
                failedCount = failedCount + 1
            else
                failedCount = 0
            end

            if failedCount >= 3 then
                autoUpgrade = false
                Fluent:Notify({
                    Title = "Upgrade Stopped",
                    Content = "Auto upgrade stopped. Possibly not enough resources.",
                    Duration = 4
                })
            end
        end
    end
end)

-- Dungeon Tab
local rankList = {"F", "E", "D", "C", "B", "A", "S"}
local selectedRank = "F"
local autoStartEnabled = false
local autoFarmDungeon = false

-- Dungeon helper functions
local function getDungeonEnemies()
    local folder = Workspace.Worlds:FindFirstChild("Raids")
    local enemies = folder and folder:FindFirstChild("Enemies")
    if not enemies then return {} end

    local result = {}
    for _, enemy in ipairs(enemies:GetChildren()) do
        local meta = enemy:FindFirstChild("Metadata")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local health = enemy:GetAttribute("Health")
        if meta and root and health and health > 0 then
            local isBoss = meta:FindFirstChild("Boss") and meta.Boss:GetAttribute("Value") or false
            table.insert(result, {
                Model = enemy,
                Root = root,
                IsBoss = isBoss,
                Distance = (humanoidRootPart.Position - root.Position).Magnitude
            })
        end
    end
    return result
end

local function splitEnemies(enemies)
    local regular, boss = {}, nil
    for _, e in ipairs(enemies) do
        if e.IsBoss then boss = e else table.insert(regular, e) end
    end
    table.sort(regular, function(a, b) return a.Distance < b.Distance end)
    return regular, boss
end

local function moveAndAttack(target)
    if not target or not humanoidRootPart then return end
    humanoidRootPart.CFrame = target.Root.CFrame * CFrame.new(0, 0, -5)
    task.wait(0.15)
    pcall(function()
        ReplicatedStorage:WaitForChild("Bindable"):WaitForChild("Enemies"):WaitForChild("LocalDealDamageRaw"):Fire(target.Model)
    end)
end

local function waitUntilDead(enemyModel)
    while enemyModel and enemyModel.Parent and enemyModel:GetAttribute("Health") and enemyModel:GetAttribute("Health") > 0 do
        task.wait(0.1)
    end
end

-- Dungeon UI
Tabs.Dungeon:AddDropdown("RankSelector", {
    Title = "Select Dungeon Rank",
    Values = rankList,
    Default = 1,
    Callback = function(value)
        selectedRank = value
    end
})

Tabs.Dungeon:AddToggle("AutoStartDungeon", {
    Title = "Auto Create & Start Dungeon",
    Default = false,
    Callback = function(state)
        autoStartEnabled = state
        if autoStartEnabled then
            spawn(function()
                while autoStartEnabled do
                    pcall(function()
                        local RemoteRaidLobby = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("Lobby")
                        local CreateLobby = RemoteRaidLobby:WaitForChild("CreateLobby")
                        local StartRaid = RemoteRaidLobby:WaitForChild("StartRaid")
                        
                        local args = {"RaidPortal"}
                        CreateLobby:FireServer(unpack(args))
                        StartRaid:FireServer()
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

Tabs.Dungeon:AddToggle("AutoFarmDungeon", {
    Title = "Auto Farm Dungeon",
    Default = false,
    Callback = function(state)
        autoFarmDungeon = state
    end
})

-- Dungeon farm loop
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoFarmDungeon then
            local enemies = getDungeonEnemies()
            local regular, boss = splitEnemies(enemies)

            -- Kill regular enemies first
            for _, enemy in ipairs(regular) do
                if not autoFarmDungeon then break end
                moveAndAttack(enemy)
                waitUntilDead(enemy.Model)
            end

            -- Kill boss if exists
            if boss and autoFarmDungeon then
                moveAndAttack(boss)
                waitUntilDead(boss.Model)
            end
        end
    end
end)

-- Infinity Castle section
Tabs.Dungeon:AddSection("Infinity Castle")

local selectedTower = nil
local autoFarmCastle = false

local towerAliases = {
    ["Castle"] = "Tower",
    ["Fire Tower"] = "Tower_Fire",
    ["Water Tower"] = "Tower_Water",
    ["Earth Tower"] = "Tower_Earth",
    ["Ice Tower"] = "Tower_Ice",
    ["Light Tower"] = "Tower_Light",
    ["Dark Tower"] = "Tower_Dark"
}

local towerDisplayNames = {}
for label, _ in pairs(towerAliases) do
    table.insert(towerDisplayNames, label)
end

Tabs.Dungeon:AddDropdown("TowerDropdown", {
    Title = "Select Tower",
    Description = "Choose which tower raid to start",
    Values = towerDisplayNames,
    Default = 1,
    Callback = function(value)
        selectedTower = towerAliases[value]
        Fluent:Notify({
            Title = "Tower Selected",
            Content = "Auto raid will start: " .. selectedTower,
            Duration = 2
        })
    end
})

Tabs.Dungeon:AddButton({
    Title = "Start Selected Tower",
    Callback = function()
        if selectedTower then
            pcall(function()
                ReplicatedStorage:WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("StartRaidForPlayer"):FireServer(selectedTower)
            end)
            Fluent:Notify({
                Title = "Raid Started",
                Content = "Starting raid: " .. selectedTower,
                Duration = 2
            })
        else
            Fluent:Notify({
                Title = "No Tower Selected",
                Content = "Please select a tower first!",
                Duration = 2
            })
        end
    end
})

Tabs.Dungeon:AddToggle("AutoFarmCastle", {
    Title = "AutoFarm Infinity Castle",
    Default = false,
    Callback = function(state)
        autoFarmCastle = state
        Fluent:Notify({
            Title = "AutoFarm Castle",
            Content = state and "AutoFarm Started" or "AutoFarm Stopped",
            Duration = 2
        })
    end
})

-- Castle farm loop
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoFarmCastle then
            local enemies = getDungeonEnemies()
            local regular, boss = splitEnemies(enemies)

            for _, enemy in ipairs(regular) do
                if not autoFarmCastle then break end
                moveAndAttack(enemy)
                waitUntilDead(enemy.Model)
            end
            
            if boss and autoFarmCastle then
                moveAndAttack(boss)
                waitUntilDead(boss.Model)
            end
        end
    end
end)

-- Settings and save system
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/AnimeRising")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Final notifications
Fluent:Notify({
    Title = "Stellar Hub",
    Content = "The script has been loaded.",
    Duration = 3
})

task.wait(3)
Fluent:Notify({
    Title = "Stellar Hub",
    Content = "Join the discord for more updates and keyless scripts",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
