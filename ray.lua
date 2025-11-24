--// Load Rayfield UI Library 
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window 
local Window = Rayfield:CreateWindow({
   Name = "novaRyn",
   LoadingTitle = "Nova",
   LoadingSubtitle = "by Sixeyes",
   ConfigurationSaving = {
      Enabled = false,
   },
})

-------------------------------------------------------
--================== UTILITY TAB ====================--
-------------------------------------------------------

local UtilityTab = Window:CreateTab("Utility", 4483362458)

-- ESP
UtilityTab:CreateButton({
   Name = "ESP",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
   end,
})

-- Walkspeed
UtilityTab:CreateSlider({
   Name = "Walkspeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "ws",
   Callback = function(val)
      local char = game.Players.LocalPlayer.Character
      if char then
         char.Humanoid.WalkSpeed = val
      end
   end,
})

-- JumpPower
UtilityTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "jp",
   Callback = function(val)
      local char = game.Players.LocalPlayer.Character
      if char then
         char.Humanoid.JumpPower = val
      end
   end,
})

-- Anti Fall Damage
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

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
local MainTab = Window:CreateTab("Main", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local players = game:GetService("Players")
local plr = players.LocalPlayer

-- Helper
local function GetChar()
    return plr.Character or plr.CharacterAdded:Wait()
end

local function GetHRP()
    local char = GetChar()
    return char:WaitForChild("HumanoidRootPart", 2)
end

local function GetHum()
    local char = GetChar()
    return char:WaitForChild("Humanoid", 2)
end

local bunkerName = plr:GetAttribute("AssignedBunkerName")

-- Noclip
MainTab:CreateToggle("Noclip", false, function(state)
    getgenv().noclip = state
    if state then
        if getgenv().noclipConn then getgenv().noclipConn:Disconnect() end
        getgenv().noclipConn = game:GetService("RunService").Stepped:Connect(function()
            local char = plr.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if getgenv().noclipConn then
            getgenv().noclipConn:Disconnect()
            getgenv().noclipConn = nil
        end
    end
end)

-- WalkSpeed
MainTab:CreateBox("WalkSpeed", function(ws)
    ws = tonumber(ws)
    if ws and GetHum() then
        GetHum().WalkSpeed = ws
    end
end)

-- Collect All Food
MainTab:CreateButton("Collect All Food", function()
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
end)

-- Drop All Food
MainTab:CreateButton("Drop All Food", function()
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
end)

-- Furniture List
local selectedFurniture = nil
local function ReturnFurniture()
    local list = {}
    for _, x in ipairs(workspace.Wyposazenie:GetChildren()) do
        if x:IsA("Folder") then
            for _, md in ipairs(x:GetChildren()) do
                if md:IsA("Model") and not table.find(list, md.Name) then
                    table.insert(list, md.Name)
                end
            end
        elseif x:IsA("Model") and not table.find(list, x.Name) then
            table.insert(list, x.Name)
        end
    end
    return list
end

MainTab:CreateDropdown("Selected Furniture", ReturnFurniture(), function(option)
    selectedFurniture = option
end)

MainTab:CreateButton("Bring Selected Furniture", function()
    if not selectedFurniture then return end
    local hrp = GetHRP()
    if not hrp then return end
    local originalPos = hrp.CFrame
    local MARKET_POS = CFrame.new(143,5,-118)
    hrp.CFrame = MARKET_POS
    task.wait(0.4)

    for _, folder in ipairs(workspace.Wyposazenie:GetChildren()) do
        if folder:IsA("Folder") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and model.Name == selectedFurniture then
                    game.ReplicatedStorage.PickupItemEvent:FireServer(model)
                    task.wait(0.3)
                    hrp.CFrame = originalPos
                    return
                end
            end
        elseif folder:IsA("Model") and folder.Name == selectedFurniture then
            game.ReplicatedStorage.PickupItemEvent:FireServer(folder)
            task.wait(0.3)
            hrp.CFrame = originalPos
            return
        end
    end
end)

-- Sound Spam
MainTab:CreateToggle("Sound Spam", false, function(state)
    getgenv().sound_spam = state
    task.spawn(function()
        while getgenv().sound_spam do
            pcall(function()
                game.ReplicatedStorage.SoundEvent:FireServer("Drink")
                game.ReplicatedStorage.SoundEvent:FireServer("Eat")
            end)
            task.wait()
        end
    end)
end)

-- Monsters ESP
MainTab:CreateToggle("Monsters ESP", false, function(state)
    getgenv().esp = state
    if state then
        task.spawn(function()
            while getgenv().esp do
                local nightFolder = nil
                for _, f in ipairs(workspace:GetChildren()) do
                    if f:IsA("Folder") and f.Name:match("Night") then
                        nightFolder = f
                        break
                    end
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
                    if m:FindFirstChild("Highlight") then
                        m.Highlight:Destroy()
                    end
                end
            end
        end
    end
end)

-- Teleport
TeleportTab:CreateButton("to Bunker", function()
    local hrp = GetHRP()
    if hrp and bunkerName then
        local bunkers = workspace:FindFirstChild("Bunkers")
        if bunkers and bunkers:FindFirstChild(bunkerName) then
            hrp.CFrame = bunkers[bunkerName].SpawnLocation.CFrame
        end
    end
end)

TeleportTab:CreateButton("to Market", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(143,5,-118) end
end)

TeleportTab:CreateBox("to Player", function(text, enter)
    if not enter then return end
    text = text:lower()
    for _, p in ipairs(players:GetPlayers()) do
        if p ~= plr and (p.Name:lower():find(text) or p.DisplayName:lower():find(text)) then
            local hrp = GetHRP()
            local tHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and tHRP then hrp.CFrame = tHRP.CFrame end
            return
        end
    end
end)

-- Settings
SettingsTab:CreateLabel("Press LeftControl to Hide UI", Color3.fromRGB(127, 143, 166))
SettingsTab:CreateLabel("~ t.me/arceusxscripts", Color3.fromRGB(127, 143, 166))
SettingsTab:CreateButton("Destroy Gui", function()
    lib:Destroy()
end)

lib:Keybind("LeftControl")
