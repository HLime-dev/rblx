--========================================--
-- DANGEROUS NIGHT – RAYFIELD VERSION
--========================================--

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Dangerous Night | Rayfield",
    LoadingTitle = "DN Utilities",
    LoadingSubtitle = "by HLime-dev",
    ConfigurationSaving = {Enabled = false},
})

local players = game:GetService("Players")
local plr = players.LocalPlayer
local bunkerName = plr:GetAttribute("AssignedBunkerName")

--========================================--
-- MAIN TAB
--========================================--

local Main = Window:CreateTab("Main")

-- Noclip
Main:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "noclip_toggle",
    Callback = function(b)
        getgenv().noclip = b

        if b then
            if _G.noClipConn then _G.noClipConn:Disconnect() end
            _G.noClipConn = game:GetService("RunService").Stepped:Connect(function()
                if plr.Character then
                    for _, v in ipairs(plr.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        else
            if _G.noClipConn then _G.noClipConn:Disconnect() end
        end
    end,
})

-- Walkspeed
Main:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 300},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        if plr.Character then
            plr.Character:FindFirstChild("Humanoid").WalkSpeed = val
        end
    end,
})

-- Collect all food
Main:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local hrp = plr.Character.HumanoidRootPart
        local last = hrp.CFrame

        for _, food in ipairs(workspace:GetChildren()) do
            if food:IsA("Tool") then
                local handle = food:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if handle and prompt then
                    hrp.CFrame = handle.CFrame * CFrame.new(0, 5, 0)
                    task.wait(.25)
                    fireproximityprompt(prompt)
                end
            end
        end

        task.wait(.3)
        hrp.CFrame = last
    end,
})

-- Drop all food
Main:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local hrp = plr.Character.HumanoidRootPart
        local last = hrp.CFrame

        for _, v in ipairs(plr.Backpack:GetChildren()) do
            v.Parent = plr.Character
        end

        task.wait(.3)
        plr.Character.Humanoid.Health = 0

        plr.CharacterAdded:Connect(function(char)
            task.wait(.5)
            local newHrp = char:WaitForChild("HumanoidRootPart")
            newHrp.CFrame = last
        end)
    end,
})

--========================================--
-- PICKUP FURNITURE
--========================================--

local function GetAvailableFurniture()
    local list = {}
    for _, item in ipairs(workspace.Wyposazenie:GetChildren()) do
        if item:IsA("Folder") then
            for _, m in ipairs(item:GetChildren()) do
                if m:IsA("Model") and not table.find(list, m.Name) then
                    table.insert(list, m.Name)
                end
            end
        elseif item:IsA("Model") and not table.find(list, item.Name) then
            table.insert(list, item.Name)
        end
    end
    return list
end

local selectedFurniture = nil

Main:CreateDropdown({
    Name = "Select Furniture",
    Options = GetAvailableFurniture(),
    Callback = function(option)
        selectedFurniture = option
    end,
})

Main:CreateButton({
    Name = "Bring Selected Furniture",
    Callback = function()
        if not selectedFurniture then return end

        local event = game:GetService("ReplicatedStorage"):FindFirstChild("PickupItemEvent")

        for _, folder in ipairs(workspace.Wyposazenie:GetChildren()) do
            if folder:IsA("Folder") then
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == selectedFurniture then
                        event:FireServer(obj)
                    end
                end
            elseif folder:IsA("Model") and folder.Name == selectedFurniture then
                event:FireServer(folder)
            end
        end
    end,
})

--========================================--
-- ESP TAB
--========================================--

local ESP = Window:CreateTab("ESP")

ESP:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().espmon = state

        while espmon do
            for _, f in ipairs(workspace:GetChildren()) do
                if f:IsA("Folder") and f.Name:find("Night") then
                    for _, m in ipairs(f:GetChildren()) do
                        if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then
                            if not m:FindFirstChild("Highlight") then
                                Instance.new("Highlight", m)
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end

        -- Remove highlights
        for _, f in ipairs(workspace:GetChildren()) do
            if f:IsA("Folder") and f.Name:find("Night") then
                for _, m in ipairs(f:GetChildren()) do
                    local h = m:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end,
})

--========================================--
-- TELEPORT TAB
--========================================--

local Teleport = Window:CreateTab("Teleport")

Teleport:CreateButton({
    Name = "To Bunker",
    Callback = function()
        local dest = workspace.Bunkers[bunkerName].SpawnLocation.CFrame
        plr.Character.HumanoidRootPart.CFrame = dest
    end,
})

Teleport:CreateButton({
    Name = "To Market",
    Callback = function()
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(143, 5, -118)
    end,
})

Teleport:CreateInput({
    Name = "Teleport to Player",
    PlaceholderText = "Player name...",
    RemoveTextAfterFocusLost = false,
    Callback = function(txt)
        local t = txt:lower()
        for _, p in ipairs(players:GetPlayers()) do
            if p.Name:lower():find(t) or p.DisplayName:lower():find(t) then
                plr.Character.HumanoidRootPart.CFrame =
                    p.Character.HumanoidRootPart.CFrame
            end
        end
    end,
})

--========================================--
-- SETTINGS TAB
--========================================--

local Settings = Window:CreateTab("Settings")

Settings:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
    end,
})
