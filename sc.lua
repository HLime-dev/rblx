--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
   Name = "DN SC1",
   LoadingTitle = "HaeX SC",
   LoadingSubtitle = "by Haex",
   ConfigurationSaving = { Enabled = false },
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local bunkerName = plr:GetAttribute("AssignedBunkerName")

-- Helper functions
local function GetChar() return plr.Character or plr.CharacterAdded:Wait() end
local function GetHRP() local char = GetChar() return char:WaitForChild("HumanoidRootPart", 2) end
local function GetHum() local char = GetChar() return char:WaitForChild("Humanoid", 2) end

-------------------------------------------------------
--==================== UTILITY TAB ==================--
-------------------------------------------------------
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
        local char = GetChar()
        if char then char.Humanoid.WalkSpeed = val end
    end,
})

UtilityTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(val)
        local char = GetChar()
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

UtilityTab:CreateToggle({
    Name = "Wallhack / Through Walls ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().wallhack = state
        if state then
            task.spawn(function()
                while getgenv().wallhack do
                    for _, model in ipairs(workspace:GetChildren()) do
                        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
                            if not model:FindFirstChild("Highlight") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = model
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Tembus tembok
                                hl.Parent = model
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, model in ipairs(workspace:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("Highlight") then
                    model.Highlight:Destroy()
                end
            end
        end
    end
})

-------------------------------------------------------
--==================== MAIN TAB =====================--
-------------------------------------------------------
local MainTab = Window:CreateTab("Main", 4483362458)

-- (Isi script MainTab sama seperti sebelumnya)
-- Noclip, Collect/Drop Food, Furniture GUI, Sound Spam, Monsters ESP, Teleports, Close GUI

-------------------------------------------------------
--==================== SETTINGS TAB =================--
-------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458) -- pastikan icon unik

SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

SettingsTab:CreateLabel({
    Name = "Settings Tab Ready!",
    Text = "Semua setting aktif"
})
