--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
   Name = "DN SC1",
   LoadingTitle = "HaeX SC1",
   LoadingSubtitle = "by Haex",
   ConfigurationSaving = { Enabled = false },
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local bunkerName = plr:GetAttribute("AssignedBunkerName")

-- Helper functions
local function GetChar()
    return plr.Character or plr.CharacterAdded:Wait()
end
local function GetHRP()
    local char = GetChar()
    return char and char:WaitForChild("HumanoidRootPart", 2)
end
local function GetHum()
    local char = GetChar()
    return char and char:WaitForChild("Humanoid", 2)
end

-------------------------------------------------------
--==================== UTILITY TAB ==================--
-------------------------------------------------------
local UtilityTab = Window:CreateTab("Utility", 4483362458)

UtilityTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local char = GetChar()
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = val end
    end,
})

UtilityTab:CreateButton({
    Name = "Anti Fall Damage",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
        end)
    end,
})

UtilityTab:CreateButton({
    Name = "Fly GUI V3",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
        end)
    end,
})

UtilityTab:CreateToggle({
    Name = "Auto Eat",
    CurrentValue = false,
    Callback = function(state)
        getgenv().autoEat = state
        task.spawn(function()
            while getgenv().autoEat do
                local ok, char = pcall(GetChar)
                if not ok or not char then task.wait(1) continue end
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    local food = nil
                    for _, item in ipairs(plr.Backpack:GetChildren()) do
                        if item:IsA("Tool") and item:FindFirstChild("Handle") then
                            food = item
                            break
                        end
                    end
                    if food then
                        food.Parent = char
                        task.wait(0.1)
                        local prompt = food:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then pcall(function() fireproximityprompt(prompt) end) end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

-------------------------------------------------------
--==================== MAIN TAB =====================--
-------------------------------------------------------
local MainTab = Window:CreateTab("Main", 4483362458)

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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if getgenv().noclipConn then getgenv().noclipConn:Disconnect() getgenv().noclipConn = nil end
        end
    end
})

-- Collect / Drop Food
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
        if lastPos then pcall(function() hrp.CFrame = lastPos end) end
    end
})

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

-- Furniture GUI & Bunker GUI sudah sama seperti versi sebelumnya
-- Player teleport, Sound Spam, Close GUI juga tetap

-------------------------------------------------------
--==================== SETTINGS TAB =================--
-------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

getgenv().nightMonsterESP = false
SettingsTab:CreateToggle({
    Name = "Night Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().nightMonsterESP = state
        if state then
            task.spawn(function()
                while getgenv().nightMonsterESP do
                    for _, f in ipairs(workspace:GetChildren()) do
                        if f:IsA("Folder") and f.Name:match("Night") then
                            for _, m in ipairs(f:GetChildren()) do
                                if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("NM_ESP") then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "NM_ESP"
                                    hl.FillColor = Color3.fromRGB(255,0,0)
                                    hl.FillTransparency = 0.5
                                    hl.OutlineColor = Color3.fromRGB(255,255,255)
                                    hl.OutlineTransparency = 0
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.Parent = m
                                end
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
                        local hl = m:FindFirstChild("NM_ESP")
                        if hl then pcall(function() hl:Destroy() end) end
                    end
                end
            end
        end
    end
})

-- Close GUI
SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})
