--// Load Rayfield
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
local bunkerName = plr:GetAttribute("AssignedBunkerName")

-- Helper function untuk HumanoidRootPart
local function GetHRP()
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        return plr.Character.HumanoidRootPart
    else
        return nil
    end
end

-- Helper function untuk Noclip
local function StartNoclip()
    return game:GetService("RunService").Stepped:Connect(function()
        if plr.Character then
            for _, child in pairs(plr.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end)
end

--// Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Noclip Toggle
local noclipConnection
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(value)
        getgenv().noclip = value
        if value then
            noclipConnection = StartNoclip()
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end
})

-- WalkSpeed Input
MainTab:CreateInput({
    Name = "WalkSpeed",
    PlaceholderText = "Enter WalkSpeed",
    RemoveTextAfterFocusLost = false,
    Callback = function(ws)
        local hrp = GetHRP()
        if hrp and tonumber(ws) then
            pcall(function()
                hrp.Parent:FindFirstChildOfClass("Humanoid").WalkSpeed = tonumber(ws)
            end)
        end
    end
})

-- Collect All Food Button
MainTab:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local lastPos = hrp.CFrame
        for _, food in pairs(game:GetService("Workspace"):GetChildren()) do
            if food:IsA("Tool") then
                local handle = food:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if handle and prompt then
                    pcall(function()
                        hrp.CFrame = handle.CFrame * CFrame.new(0,5,0)
                        task.wait(0.25)
                        fireproximityprompt(prompt, prompt.MaxActivationDistance)
                    end)
                end
            end
        end
        task.wait(0.25)
        hrp.CFrame = lastPos
    end
})

-- Drop All Food Button
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local lastPos = hrp.CFrame
        for _, food in pairs(plr.Backpack:GetChildren()) do
            food.Parent = plr.Character
        end
        task.wait(0.25)
        pcall(function()
            plr.Character:FindFirstChildOfClass("Humanoid").Health = 0
        end)
        task.spawn(function()
            local function onCharacterAdded(char)
                local newHRP = char:WaitForChild("HumanoidRootPart",5)
                if newHRP and lastPos then
                    task.wait(0.5)
                    newHRP.CFrame = lastPos
                end
            end
            if not plr.Character or plr.Character:FindFirstChildOfClass("Humanoid").Health == 0 then
                plr.CharacterAdded:Wait()
                onCharacterAdded(plr.Character)
            end
        end)
    end
})

-- Furniture Dropdown + Bring Button
local selectedFurniture
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
                    pcall(function()
                        game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(interno)
                    end)
                    return true
                end
            end
        elseif furniture:IsA("Model") and furniture.Name == selectedFurniture then
            pcall(function()
                game:GetService("ReplicatedStorage").PickupItemEvent:FireServer(furniture)
            end)
            return true
        end
    end
    return false
end

MainTab:CreateDropdown({
    Name = "Selected Furniture",
    Options = ReturnFurniture(),
    Callback = function(option)
        selectedFurniture = option
    end
})

MainTab:CreateButton({
    Name = "Bring Selected Furniture",
    Callback = function()
        if selectedFurniture then
            GetFurniture()
        end
    end
})

-- Sound Spam Toggle
MainTab:CreateToggle({
    Name = "Sound Spam",
    CurrentValue = false,
    Callback = function(value)
        getgenv().sound_spam = value
        task.spawn(function()
            while getgenv().sound_spam do
                pcall(function()
                    game:GetService("ReplicatedStorage").SoundEvent:FireServer("Drink")
                    game:GetService("ReplicatedStorage").SoundEvent:FireServer("Eat")
                end)
                task.wait()
            end
        end)
    end
})

-- Monsters ESP Toggle
MainTab:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Callback = function(value)
        getgenv().lurker_esp = value

        local function findNightFolder()
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Folder") and string.find(obj.Name, "Night") then
                    return obj
                end
            end
            return nil
        end

        if value then
            task.spawn(function()
                while getgenv().lurker_esp do
                    local nightFolder = findNightFolder()
                    if nightFolder then
                        for _, lurker in pairs(nightFolder:GetChildren()) do
                            if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                                if not lurker:FindFirstChild("Highlight") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "Highlight"
                                    highlight.Parent = lurker
                                end
                            end
                        end
                    else
                        repeat task.wait() until findNightFolder() or not getgenv().lurker_esp
                    end
                    task.wait(1)
                end
            end)
        else
            local nightFolder = findNightFolder()
            if nightFolder then
                for _, lurker in pairs(nightFolder:GetChildren()) do
                    local highlight = lurker:FindFirstChild("Highlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        end
    end
})

--// Teleport Tab
local TeleTab = Window:CreateTab("Teleport", 4483362459)

TeleTab:CreateButton({
    Name = "to Bunker",
    Callback = function()
        local hrp = GetHRP()
        if hrp and workspace:FindFirstChild("Bunkers") and workspace.Bunkers:FindFirstChild(bunkerName) then
            hrp.CFrame = workspace.Bunkers[bunkerName].SpawnLocation.CFrame
        end
    end
})

TeleTab:CreateButton({
    Name = "to Market",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(143, 5, -118)
        end
    end
})

TeleTab:CreateInput({
    Name = "to Player",
    PlaceholderText = "Player Name",
    RemoveTextAfterFocusLost = false,
    Callback = function(name)
        local hrp = GetHRP()
        if not hrp then return end
        local lowerName = name:lower()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and (string.find(player.Name:lower(), lowerName) or string.find(player.DisplayName:lower(), lowerName)) then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    hrp.CFrame = targetHRP.CFrame
                    return
                end
            end
        end
    end
})

--// Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362460)

SettingsTab:CreateLabel("Press LeftControl to Hide UI", Color3.fromRGB(127, 143, 166))
SettingsTab:CreateLabel("~ t.me/arceusxscripts", Color3.fromRGB(127, 143, 166))

-- Close GUI Button
SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Hide/Show GUI keybind
Window:BindToKey("LeftControl")
