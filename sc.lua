--// Load Rayfield UI Library 
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window 
local Window = Rayfield:CreateWindow({
   Name = "novaRyn",
   LoadingTitle = "Nova",
   LoadingSubtitle = "by Sixeyes",
   ConfigurationSaving = { Enabled = false },
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

--// UTILITY TAB
local UtilityTab = Window:CreateTab("Utility", 4483362458)

UtilityTab:CreateButton({
    Name = "ESP",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
    end,
})

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

UtilityTab:CreateButton({
    Name = "Anti Fall Damage",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
    end,
})

UtilityTab:CreateButton({
    Name = "Fly GUI V3",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
    end,
})

--// MAIN TAB
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

-- Tambahkan semua tombol Main lainnya (Collect All Food, Drop All Food, Sound Spam, Monsters ESP, Teleport, dll)
-- sama seperti kode sebelumnya

--// CLOSE / SETTINGS TAB
local SettingsTab = Window:CreateTab("Settings", 4483362461) -- tab icon berbeda agar unik

SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

SettingsTab:CreateLabel("Press LeftControl to Hide UI", Color3.fromRGB(127, 143, 166))
SettingsTab:CreateLabel("~ t.me/arceusxscripts", Color3.fromRGB(127, 143, 166))

-- Bind Key untuk hide/show GUI
Window:BindToKey("LeftControl")
