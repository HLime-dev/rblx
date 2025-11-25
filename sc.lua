--// Load Rayfield
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
local bunkerName = plr:GetAttribute("AssignedBunkerName")

--// Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)       -- tab icon 1

-- Noclip Toggle
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(b)
        getgenv().noclip = b
        if noclip then
            local function NoclipLoop()
                if plr.Character then
                    for _, child in pairs(plr.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide then
                            child.CanCollide = false
                        end
                    end
                end
            end
            Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)
        else
            if Noclipping then
                Noclipping:Disconnect()
                Noclipping = nil
            end
        end
    end
})

-- WalkSpeed Box
MainTab:CreateInput({
    Name = "WalkSpeed",
    PlaceholderText = "Enter WalkSpeed",
    RemoveTextAfterFocusLost = false,
    Callback = function(ws)
        if tonumber(ws) then
            plr.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(ws)
        end
    end
})

-- Collect All Food Button
MainTab:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
        for _, food in pairs(game:GetService("Workspace"):GetChildren()) do
            if food:IsA("Tool") then
                local handle = food:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if handle and prompt then
                    plr.Character.HumanoidRootPart.CFrame = handle.CFrame * CFrame.new(0,5,0)
                    task.wait(0.25)
                    fireproximityprompt(prompt, prompt.MaxActivationDistance)
                end
            end
        end
        task.wait(0.25)
        plr.Character.HumanoidRootPart.CFrame = lastPos
    end
})

-- Drop All Food Button
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local lastPos = plr.Character.HumanoidRootPart.CFrame
        for _, food in pairs(plr.Backpack:GetChildren()) do
            food.Parent = plr.Character
        end
        task.wait(0.25)
        plr.Character:FindFirstChildOfClass("Humanoid").Health = 0

        task.spawn(function()
            local function onCharacterAdded(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp and lastPos then
                    task.wait(0.5)
                    hrp.CFrame = lastPos
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
    Flag = "SoundSpamToggle",
    Callback = function(b)
        getgenv().sound_spam = b
        task.spawn(function()
            while sound_spam do
                game:GetService("ReplicatedStorage").SoundEvent:FireServer("Drink")
                game:GetService("ReplicatedStorage").SoundEvent:FireServer("Eat")
                task.wait()
            end
        end)
    end
})

-- Monsters ESP Toggle
MainTab:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Flag = "MonstersESP",
    Callback = function(b)
        getgenv().lurker_esp = b

        local function findNightFolder()
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Folder") and string.find(obj.Name, "Night") then
                    return obj
                end
            end
            return nil
        end

        if lurker_esp then
            task.spawn(function()
                while lurker_esp do
                    local nightFolder = findNightFolder()
                    if nightFolder then
                        for _, lurker in pairs(nightFolder:GetChildren()) do
                            if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                                local highlight = lurker:FindFirstChild("Highlight")
                                if not highlight then
                                    highlight = Instance.new("Highlight")
                                    highlight.Name = "Highlight"
                                    highlight.Parent = lurker
                                end
                            end
                        end
                    else
                        repeat task.wait() until findNightFolder() or not lurker_esp
                    end
                    task.wait(1)
                end
            end)
        else
            local nightFolder = findNightFolder()
            if nightFolder then
                for _, lurker in pairs(nightFolder:GetChildren()) do
                    if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                        local highlight = lurker:FindFirstChild("Highlight")
                        if highlight then
                            highlight:Destroy()
                        end
                    end
                end
            end
        end
    end
})


local TeleTab = Window:CreateTab("Teleport", 4483362459)   -- tab icon 2

TeleTab:CreateButton({
    Name = "to Bunker",
    Callback = function()
        plr.Character.HumanoidRootPart.CFrame = workspace.Bunkers[bunkerName].SpawnLocation.CFrame
    end
})

TeleTab:CreateButton({
    Name = "to Market",
    Callback = function()
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(143, 5, -118)
    end
})

TeleTab:CreateInput({
    Name = "to Player",
    PlaceholderText = "Player Name",
    RemoveTextAfterFocusLost = false,
    Callback = function(name)
        local lowerName = name:lower()
        for _, player in pairs(players:GetPlayers()) do
            if string.find(player.Name:lower(), lowerName) or string.find(player.DisplayName:lower(), lowerName) then
                plr.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                return
            end
        end
    end
})

local SettingsTab = Window:CreateTab("Settings", 4483362460) -- tab icon 3

SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})
