--// Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

Rayfield:Notify({
    Title = "Loaded",
    Content = "Dangerous Night Utility Loaded Successfully!",
    Duration = 5
})

local Window = Rayfield:CreateWindow({
   Name = "Dangerous Night | Utility",
   LoadingTitle = "Dangerous Night",
   LoadingSubtitle = "Rayfield UI",
})

local m = Window:CreateTab("Main")
local t = Window:CreateTab("Teleport")
local s = Window:CreateTab("Settings")

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local bunkerName = plr:GetAttribute("AssignedBunkerName")

--// Noclip
m:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(b)
        getgenv().noclip = b
        if b then
            Noclipping = game:GetService("RunService").Stepped:Connect(function()
                if plr.Character then
                    for _, v in pairs(plr.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            if Noclipping then Noclipping:Disconnect() end
        end
    end,
})

--// Walkspeed
m:CreateInput({
    Name = "WalkSpeed",
    PlaceholderText = "16",
    OnEnter = true,
    Callback = function(ws)
        if tonumber(ws) and plr.Character then
            plr.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(ws)
        end
    end,
})

--// Collect All Food
m:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local lastPos = plr.Character.HumanoidRootPart.CFrame

        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Tool") then
                local handle = v:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

                if prompt then
                    plr.Character.HumanoidRootPart.CFrame = handle.CFrame * CFrame.new(0, 5, 0)
                    task.wait(0.25)
                    fireproximityprompt(prompt)
                end
            end
        end

        task.wait(0.2)
        plr.Character.HumanoidRootPart.CFrame = lastPos
    end,
})

--// Drop Food
m:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local lastPos = plr.Character.HumanoidRootPart.CFrame

        for _, tool in pairs(plr.Backpack:GetChildren()) do
            tool.Parent = plr.Character
        end

        task.wait(0.2)
        plr.Character:FindFirstChildOfClass("Humanoid").Health = 0

        plr.CharacterAdded:Wait()
        task.wait(0.4)
        plr.Character:WaitForChild("HumanoidRootPart").CFrame = lastPos
    end,
})

--// Furniture System
local selected = nil

local function ReturnFurniture()
    local Names = {}
    for _, item in pairs(workspace.Wyposazenie:GetChildren()) do
        if item:IsA("Folder") then
            for _, model in pairs(item:GetChildren()) do
                if model:IsA("Model") then
                    table.insert(Names, model.Name)
                end
            end
        elseif item:IsA("Model") then
            table.insert(Names, item.Name)
        end
    end
    return Names
end

local function GetFurniture()
    for _, folder in pairs(workspace.Wyposazenie:GetChildren()) do
        if folder:IsA("Folder") then
            for _, model in pairs(folder:GetChildren()) do
                if model:IsA("Model") and model.Name == selected then
                    game.ReplicatedStorage.PickupItemEvent:FireServer(model)
                    return true
                end
            end
        elseif folder:IsA("Model") and folder.Name == selected then
            game.ReplicatedStorage.PickupItemEvent:FireServer(folder)
            return true
        end
    end
    return false
end

m:CreateDropdown({
    Name = "Select Furniture",
    Options = ReturnFurniture(),
    Callback = function(v)
        selected = v
    end,
})

m:CreateButton({
    Name = "Bring Selected Furniture",
    Callback = function()
        if selected then GetFurniture() end
    end,
})

--// Sound Spam
m:CreateToggle({
    Name = "Sound Spam",
    CurrentValue = false,
    Callback = function(b)
        getgenv().sound_spam = b
        task.spawn(function()
            while sound_spam do
                local snd = game.ReplicatedStorage:WaitForChild("SoundEvent")
                snd:FireServer("Drink")
                snd:FireServer("Eat")
                task.wait()
            end
        end)
    end,
})

--// Monster ESP
m:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Callback = function(b)
        getgenv().lurker_esp = b

        local function findNightFolder()
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Folder") and obj.Name:find("Night") then
                    return obj
                end
            end
        end

        if b then
            task.spawn(function()
                while lurker_esp do
                    local f = findNightFolder()
                    if f then
                        for _, m in pairs(f:GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then
                                if not m:FindFirstChild("Highlight") then
                                    Instance.new("Highlight", m)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            local f = findNightFolder()
            if f then
                for _, m in pairs(f:GetChildren()) do
                    local h = m:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end,
})

--// TELEPORT
t:CreateButton({
    Name = "To Bunker",
    Callback = function()
        plr.Character.HumanoidRootPart.CFrame =
            workspace.Bunkers[bunkerName].SpawnLocation.CFrame
    end,
})

t:CreateButton({
    Name = "To Market",
    Callback = function()
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(143, 5, -118)
    end,
})

t:CreateInput({
    Name = "Teleport To Player",
    PlaceholderText = "Player Name",
    OnEnter = true,
    Callback = function(name)
        local lower = name:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():find(lower) or p.DisplayName:lower():find(lower) then
                plr.Character.HumanoidRootPart.CFrame =
                    p.Character.HumanoidRootPart.CFrame
                return
            end
        end
    end,
})

--// SETTINGS
s:CreateLabel("Press LeftControl to Hide UI")
s:CreateLabel("~ t.me/arceusxscripts")

s:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

Rayfield:LoadConfiguration()
