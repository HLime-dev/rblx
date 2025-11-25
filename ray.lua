--// Load Rayfield UI Library 
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window 
local Window = Rayfield:CreateWindow({
   Name = "novaRyn",
   LoadingTitle = "Nova",
   LoadingSubtitle = "by Sixeyes",
   ConfigurationSaving = { Enabled = false },
})

local players = game:GetService("Players")
local plr = players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-------------------------------------------------------
--==================== UTILITY TAB ==================--
-------------------------------------------------------
local UtilityTab = Window:CreateTab("Utility", 4483362458)

-- ESP
UtilityTab:CreateButton({
    Name = "ESP",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
    end,
})

-- WalkSpeed
UtilityTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local char = plr.Character
        if char then char.Humanoid.WalkSpeed = val end
    end,
})

-- JumpPower
UtilityTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(val)
        local char = plr.Character
        if char then char.Humanoid.JumpPower = val end
    end,
})

-- NDS - Anti Fall Damage
UtilityTab:CreateButton({
    Name = "Anti Fall Damage",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
    end,
})

-- Fly GUI
UtilityTab:CreateButton({
    Name = "Fly GUI V3",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
    end,
})

-------------------------------------------------------
--==================== MAIN TAB =====================--
-------------------------------------------------------
local MainTab = Window:CreateTab("Main", 4483362460)

-- Helper functions
local function GetChar() return plr.Character or plr.CharacterAdded:Wait() end
local function GetHRP() local char = GetChar() return char:WaitForChild("HumanoidRootPart", 2) end
local function GetHum() local char = GetChar() return char:WaitForChild("Humanoid", 2) end
local bunkerName = plr:GetAttribute("AssignedBunkerName")

-- Noclip
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(state)
        getgenv().noclip = state
        if state then
            if getgenv().noclipConn then getgenv().noclipConn:Disconnect() end
            getgenv().noclipConn = game:GetService("RunService").Stepped:Connect(function()
                local char = GetChar()
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if getgenv().noclipConn then getgenv().noclipConn:Disconnect() getgenv().noclipConn = nil end
        end
    end
})

-- Collect All Food
MainTab:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local lastPos = hrp.CFrame
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("Tool") then
                local handle = v:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if handle and prompt then
                    hrp.CFrame = handle.CFrame + Vector3.new(0,5,0)
                    task.wait(0.2)
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end
        task.wait(0.2)
        hrp.CFrame = lastPos
    end
})

-- Drop All Food
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local lastPos = hrp.CFrame
        for _, v in ipairs(plr.Backpack:GetChildren()) do
            v.Parent = GetChar()
        end
        task.wait(0.2)
        local hum = GetHum()
        if hum then hum.Health = 0 end
        plr.CharacterAdded:Wait()
        task.wait(0.4)
        local newHRP = GetHRP()
        if newHRP then newHRP.CFrame = lastPos end
    end
})

-- Bring Furniture
-- Bring Selected Furniture
-- Bring Selected Furniture
local selectedFurniture = nil

local function ReturnFurniture()
    local Names = {}
    for _, item in pairs(workspace.Wyposazenie:GetChildren()) do
        if item:IsA("Folder") then
            for _, interno in pairs(item:GetChildren()) do
                if interno:IsA("Model") and not table.find(Names, interno.Name) then
                    table.insert(Names, interno.Name)
                end
            end
        elseif item:IsA("Model") and not table.find(Names, item.Name) then
            table.insert(Names, item.Name)
        end
    end
    return Names
end

local function GetFurniture()
    for _, furniture in pairs(workspace.Wyposazenie:GetChildren()) do
        if furniture:IsA("Folder") then
            for _, interno in pairs(furniture:GetChildren()) do
                if interno:IsA("Model") and interno.Name == selectedFurniture then
                    game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(interno)
                    return true
                end
            end
        elseif furniture:IsA("Model") and furniture.Name == selectedFurniture then
            game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(furniture)
            return true
        end
    end
    return false
end

-- Dropdown
MainTab:CreateDropdown({
    Name = "Selected Furniture",
    Options = ReturnFurniture(),
    Callback = function(option)
        selectedFurniture = option
    end
})

-- Button untuk ambil furniture
MainTab:CreateButton({
    Name = "Bring Selected Furniture",
    Callback = function()
        if selectedFurniture ~= nil then
            GetFurniture()
        end
    end
})

-- Sound Spam
MainTab:CreateToggle({
    Name = "Sound Spam",
    CurrentValue = false,
    Callback = function(state)
        getgenv().sound_spam = state
        task.spawn(function()
            while getgenv().sound_spam do
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("SoundEvent"):FireServer("Drink")
                    game:GetService("ReplicatedStorage"):WaitForChild("SoundEvent"):FireServer("Eat")
                end)
                task.wait()
            end
        end)
    end
})


-- Monsters ESP
MainTab:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().esp = state
        if state then
            task.spawn(function()
                while getgenv().esp do
                    local nightFolder
                    for _, f in ipairs(workspace:GetChildren()) do
                        if f:IsA("Folder") and f.Name:match("Night") then nightFolder = f break end
                    end
                    if nightFolder then
                        for _, m in ipairs(nightFolder:GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("Highlight") then
                                Instance.new("Highlight", m)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, f in ipairs(workspace:GetChildren()) do
                if f:IsA("Folder") and f.Name:match("Night") then
                    for _, m in ipairs(f:GetChildren()) do
                        if m:FindFirstChild("Highlight") then m.Highlight:Destroy() end
                    end
                end
            end
        end
    end
})

-- Teleport
MainTab:CreateButton({
    Name = "Teleport to Bunker",
    Callback = function()
        local hrp = GetHRP()
        if hrp and bunkerName then
            local bunkers = workspace:FindFirstChild("Bunkers")
            if bunkers and bunkers:FindFirstChild(bunkerName) then
                hrp.CFrame = bunkers[bunkerName].SpawnLocation.CFrame
            end
        end
    end
})

MainTab:CreateButton({
    Name = "Teleport to Market",
    Callback = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(143,5,-118) end
    end
})

MainTab:CreateTextBox({
    Name = "Teleport to Player",
    PlaceholderText = "Player Name",
    Callback = function(text)
        text = text:lower()
        for _, p in ipairs(players:GetPlayers()) do
            if p ~= plr and (p.Name:lower():find(text) or p.DisplayName:lower():find(text)) then
                local hrp = GetHRP()
                local tHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp and tHRP then hrp.CFrame = tHRP.CFrame end
                return
            end
        end
    end
})

-------------------------------------------------------
--==================== CLOSE TAB ====================--
-------------------------------------------------------
local CloseTab = Window:CreateTab("Close", 4483362461)

-- Close GUI
CloseTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Rejoin Server
CloseTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, plr)
    end
})
