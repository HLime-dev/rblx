local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()

local m = lib:Window("Main")
local t = lib:Window("Teleport")
local s = lib:Window("Settings")

local players = game:GetService("Players")
local plr = players.LocalPlayer

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

---------------------------------------------------------------------
-- Noclip
---------------------------------------------------------------------
m:Toggle("Noclip", false, function(state)
    getgenv().noclip = state

    if state then
        if getgenv().noclipConn then
            getgenv().noclipConn:Disconnect()
        end
        
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

---------------------------------------------------------------------
-- WalkSpeed
---------------------------------------------------------------------
m:Box("WalkSpeed", function(ws)
    ws = tonumber(ws)
    if ws and GetHum() then
        GetHum().WalkSpeed = ws
    end
end)

---------------------------------------------------------------------
-- Collect All Food
---------------------------------------------------------------------
m:Button("Collect All Food", function()
    local hrp = GetHRP()
    if not hrp then return end

    local lastPos = hrp.CFrame

    for _, food in ipairs(workspace:GetChildren()) do
        if food:IsA("Tool") then
            local handle = food:FindFirstChild("Handle")
            local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

            if handle and prompt then
                hrp.CFrame = handle.CFrame + Vector3.new(0, 5, 0)
                task.wait(0.2)
                pcall(function()
                    fireproximityprompt(prompt)
                end)
            end
        end
    end

    task.wait(0.2)
    hrp.CFrame = lastPos
end)

---------------------------------------------------------------------
-- Drop All Food
---------------------------------------------------------------------
m:Button("Drop All Food", function()
    local hrp = GetHRP()
    if not hrp then return end
    local lastPos = hrp.CFrame

    -- Force equip semua food
    for _, item in ipairs(plr.Backpack:GetChildren()) do
        item.Parent = plr.Character
    end

    task.wait(0.2)
    local hum = GetHum()
    if hum then hum.Health = 0 end

    task.spawn(function()
        plr.CharacterAdded:Wait()
        local newHRP = GetHRP()
        if newHRP then
            task.wait(0.5)
            newHRP.CFrame = lastPos
        end
    end)
end)

---------------------------------------------------------------------
-- Furniture System
---------------------------------------------------------------------
local selected = nil

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

local function GetFurniture()
    for _, x in ipairs(workspace.Wyposazenie:GetChildren()) do
        if x:IsA("Folder") then
            for _, md in ipairs(x:GetChildren()) do
                if md:IsA("Model") and md.Name == selected then
                    game.ReplicatedStorage.PickupItemEvent:FireServer(md)
                    return true
                end
            end
        elseif x:IsA("Model") and x.Name == selected then
            game.ReplicatedStorage.PickupItemEvent:FireServer(x)
            return true
        end
    end
    return false
end

m:Dropdown("Selected Furniture", ReturnFurniture(), function(opt)
    selected = opt
end)

m:Button("Bring Selected Furniture", function()
    if selected then GetFurniture() end
end)

---------------------------------------------------------------------
-- Sound Spam
---------------------------------------------------------------------
m:Toggle("Sound Spam", false, function(state)
    getgenv().sound_spam = state

    task.spawn(function()
        while sound_spam do
            pcall(function()
                game.ReplicatedStorage.SoundEvent:FireServer("Drink")
                game.ReplicatedStorage.SoundEvent:FireServer("Eat")
            end)
            task.wait()
        end
    end)
end)

---------------------------------------------------------------------
-- Monster ESP
---------------------------------------------------------------------
local function findNightFolder()
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Folder") and obj.Name:match("Night") then
            return obj
        end
    end
    return nil
end

m:Toggle("Monsters ESP", false, function(state)
    getgenv().esp = state

    if state then
        task.spawn(function()
            while esp do
                local folder = findNightFolder()
                if folder then
                    for _, lurker in ipairs(folder:GetChildren()) do
                        if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                            if not lurker:FindFirstChild("Highlight") then
                                Instance.new("Highlight", lurker)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    else
        local folder = findNightFolder()
        if folder then
            for _, lurker in ipairs(folder:GetChildren()) do
                local h = lurker:FindFirstChild("Highlight")
                if h then h:Destroy() end
            end
        end
    end
end)

---------------------------------------------------------------------
-- TELEPORT MENU
---------------------------------------------------------------------
t:Button("to Bunker", function()
    local hrp = GetHRP()
    if hrp and bunkerName then
        local bunker = workspace:FindFirstChild("Bunkers")
        if bunker and bunker:FindFirstChild(bunkerName) then
            hrp.CFrame = bunker[bunkerName].SpawnLocation.CFrame
        end
    end
end)

t:Button("to Market", function()
    local hrp = GetHRP()
    if hrp then
        hrp.CFrame = CFrame.new(143, 5, -118)
    end
end)

t:Box("to Player", function(txt, enter)
    if not enter then return end
    txt = txt:lower()

    for _, p in ipairs(players:GetPlayers()) do
        if p ~= plr and (p.Name:lower():find(txt) or p.DisplayName:lower():find(txt)) then
            local hrp = GetHRP()
            local target = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and target then
                hrp.CFrame = target.CFrame
            end
            return
        end
    end
end)

---------------------------------------------------------------------
-- SETTINGS
---------------------------------------------------------------------
s:Label("Press LeftControl to Hide UI", Color3.fromRGB(127, 143, 166))
s:Label("~ t.me/arceusxscripts", Color3.fromRGB(127, 143, 166))
s:Button("Destroy Gui", function()
	lib:Destroy()
end)

lib:Keybind("LeftControl")
