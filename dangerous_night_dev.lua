--====================================================
--  Dangerous Night Custom UI (Turtle-Lib Enhanced)
--====================================================

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()

local main = lib:Window("⚡ Dangerous Night - Main Menu")
local utility = lib:Window("🛠 Utility")
local tele = lib:Window("📍 Teleport")
local settings = lib:Window("⚙ Settings")

local players = game:GetService("Players")
local plr = players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local bunkerName = plr:GetAttribute("AssignedBunkerName")

----------------------------------------------------------------------
-- ✦ N O C L I P
----------------------------------------------------------------------

main:Label("Movement", Color3.fromRGB(200,200,255))

main:Toggle("Noclip", false, function(b)
    getgenv().noclip = b
    if b then
        Noclipping = game.RunService.Stepped:Connect(function()
            if plr.Character then
                for _, v in ipairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if Noclipping then Noclipping:Disconnect() end
    end
end)

main:Box("WalkSpeed", function(ws)
    if tonumber(ws) then
        plr.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(ws)
    end
end)

----------------------------------------------------------------------
-- ✦ F O O D  U T I L I T Y
----------------------------------------------------------------------

main:Label("Food Tools", Color3.fromRGB(255,220,200))

local lastPos

main:Button("🍎 Collect All Food", function()
    lastPos = hrp.CFrame

    for _, food in ipairs(workspace:GetChildren()) do
        if food:IsA("Tool") then
            local handle = food:FindFirstChild("Handle")
            local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

            if prompt then
                hrp.CFrame = handle.CFrame * CFrame.new(0, 5, 0)
                task.wait(.2)
                fireproximityprompt(prompt)
            end
        end
    end
    
    hrp.CFrame = lastPos
end)

main:Button("🗑 Drop All Food", function()
    lastPos = hrp.CFrame
    
    for _, f in ipairs(plr.Backpack:GetChildren()) do
        f.Parent = plr.Character
    end
    task.wait(.1)

    plr.Character.Humanoid.Health = 0

    plr.CharacterAdded:Wait()
    task.wait(.3)
    plr.Character:WaitForChild("HumanoidRootPart").CFrame = lastPos
end)

----------------------------------------------------------------------
-- ✦ F U R N I T U R E  P I C K E R
----------------------------------------------------------------------

main:Label("Furniture Tools", Color3.fromRGB(220,255,220))

local selected = nil

local function ReturnFurniture()
    local Names = {}
    for _, item in ipairs(workspace.Wyposazenie:GetChildren()) do
        if item:IsA("Folder") then
            for _, m in ipairs(item:GetChildren()) do
                if m:IsA("Model") then
                    table.insert(Names, m.Name)
                end
            end
        elseif item:IsA("Model") then
            table.insert(Names, item.Name)
        end
    end
    return Names
end

main:Dropdown("Select Furniture", ReturnFurniture(), function(option)
    selected = option
end)

main:Button("📦 Bring Selected Furniture", function()
    if not selected then return end

    for _, item in ipairs(workspace.Wyposazenie:GetChildren()) do
        if item:IsA("Folder") then
            for _, m in ipairs(item:GetChildren()) do
                if m.Name == selected then
                    game.ReplicatedStorage.PickupItemEvent:FireServer(m)
                end
            end
        elseif item.Name == selected then
            game.ReplicatedStorage.PickupItemEvent:FireServer(item)
        end
    end
end)

----------------------------------------------------------------------
-- ✦ S O U N D   &   E S P
----------------------------------------------------------------------

utility:Label("Effects", Color3.fromRGB(255,255,200))

utility:Toggle("Sound Spam", false, function(b)
    getgenv().sound_spam = b
    task.spawn(function()
        while sound_spam do
            game.ReplicatedStorage.SoundEvent:FireServer("Drink")
            game.ReplicatedStorage.SoundEvent:FireServer("Eat")
            task.wait(.1)
        end
    end)
end)

utility:Toggle("Monster ESP", false, function(b)
    getgenv().monsterESP = b

    local function findNight()
        for _, f in ipairs(workspace:GetChildren()) do
            if f:IsA("Folder") and f.Name:find("Night") then
                return f
            end
        end
    end

    if b then
        task.spawn(function()
            while monsterESP do
                local folder = findNight()
                if folder then
                    for _, mob in ipairs(folder:GetChildren()) do
                        if mob:FindFirstChild("HumanoidRootPart") then
                            if not mob:FindFirstChild("Highlight") then
                                Instance.new("Highlight", mob)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        local folder = findNight()
        if folder then
            for _, mob in ipairs(folder:GetChildren()) do
                local h = mob:FindFirstChild("Highlight")
                if h then h:Destroy() end
            end
        end
    end
end)

----------------------------------------------------------------------
-- ✦  T E L E P O R T
----------------------------------------------------------------------

tele:Label("Quick Teleport", Color3.fromRGB(200,255,255))

tele:Button("🏠 To Bunker", function()
    hrp.CFrame = workspace.Bunkers[bunkerName].SpawnLocation.CFrame
end)

tele:Button("🏪 To Market", function()
    hrp.CFrame = CFrame.new(143, 5, -118)
end)

tele:Box("Teleport to Player", function(name, done)
    if done then
        for _, p in ipairs(players:GetPlayers()) do
            if p.Name:lower():find(name:lower()) then
                hrp.CFrame = p.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)

----------------------------------------------------------------------
-- ✦  S E T T I N G S
----------------------------------------------------------------------

settings:Label("UI Settings", Color3.fromRGB(180,180,180))

settings:Button("Destroy UI", function()
    lib:Destroy()
end)

lib:Keybind("LeftControl")
