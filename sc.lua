local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()

local m = lib:Window("Main")
local t = lib:Window("Teleport")
local s = lib:Window("Settings")

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

---------------------------------------------------------------------
-- Noclip
---------------------------------------------------------------------
m:Toggle("Noclip", false, function(state)
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

    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Tool") then
            local handle = v:FindFirstChild("Handle")
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

---------------------------------------------------------------------
-- Furniture List
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
        elseif x:IsA("Model") then
            if not table.find(list, x.Name) then
                table.insert(list, x.Name)
            end
        end
    end
    return list
end

---------------------------------------------------------------------
-- Bring Furniture + Auto Refill Furniture
---------------------------------------------------------------------
local function GetFurniture()
    local hrp = GetHRP()
    if not hrp then return false end

    local originalPos = hrp.CFrame
    local MARKET_POS = CFrame.new(143, 5, -118) -- ubah jika berbeda

    -- Teleport ke market
    hrp.CFrame = MARKET_POS
    task.wait(0.4)

    -- Cari furniture di market
    for _, folder in ipairs(workspace.Wyposazenie:GetChildren()) do

        if folder:IsA("Folder") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and model.Name == selected then

                    game.ReplicatedStorage.PickupItemEvent:FireServer(model)
                    task.wait(0.3)

                    -- kembali ke tempat semula
                    local newHRP = GetHRP()
                    if newHRP then
                        newHRP.CFrame = originalPos
                    end
                    return true
                end
            end

        elseif folder:IsA("Model") and folder.Name == selected then

            game.ReplicatedStorage.PickupItemEvent:FireServer(folder)
            task.wait(0.3)

            local newHRP = GetHRP()
            if newHRP then
                newHRP.CFrame = originalPos
            end
            return true
        end
    end

    return false
end

m:Dropdown("Selected Furniture", ReturnFurniture(), function(option)
    selected = option
end)

m:Button("Bring Selected Furniture", function()
    if selected then
        GetFurniture()
    end
end)

-----------
---------------------------------------------------------------------
-- Auto-refresh Furniture Dropdown
---------------------------------------------------------------------
---------------------------------------------------------------------
-- Auto-refresh Furniture Dropdown (diperbaiki)
---------------------------------------------------------------------
local furnitureDropdown = m:Dropdown("Selected Furniture", ReturnFurniture(), function(option)
    selected = option
end)

local function AutoRefreshFurnitureDropdown(interval)
    interval = interval or 5 -- default refresh tiap 5 detik

    task.spawn(function()
        while true do
            local furnitureList = ReturnFurniture()
            -- update options dropdown, tanpa membuat dropdown baru
            furnitureDropdown:UpdateOptions(furnitureList)
            task.wait(interval)
        end
    end)
end

-- Jalankan auto-refresh tiap 5 detik
AutoRefreshFurnitureDropdown(5)


---------------------------------------------------------------------
-- Bunker Furniture Scan
---------------------------------------------------------------------
local selectedBunkerFurniture = nil

-- Fungsi scan furnitur di bunker
local function ScanBunkerFurniture()
    local list = {}
    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers or not bunkerName then return list end

    local bunker = bunkers:FindFirstChild(bunkerName)
    if not bunker then return list end

    for _, item in ipairs(bunker:GetChildren()) do
        if item:IsA("Model") and not table.find(list, item.Name) then
            table.insert(list, item.Name)
        end
    end

    return list
end

-- Dropdown Bunker Furniture
m:Dropdown("Selected Bunker Furniture", ScanBunkerFurniture(), function(option)
    selectedBunkerFurniture = option
end)

-- Fungsi ambil furnitur dari bunker ke player
local function TakeBunkerFurniture()
    if not selectedBunkerFurniture then return false end

    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers or not bunkerName then return false end

    local bunker = bunkers:FindFirstChild(bunkerName)
    if not bunker then return false end

    local hrp = GetHRP()
    if not hrp then return false end

    local originalPos = hrp.CFrame

    for _, item in ipairs(bunker:GetChildren()) do
        if item:IsA("Model") and item.Name == selectedBunkerFurniture then
            game.ReplicatedStorage.PickupItemEvent:FireServer(item)
            task.wait(0.3)
            -- kembali ke posisi awal
            local newHRP = GetHRP()
            if newHRP then newHRP.CFrame = originalPos end
            return true
        end
    end

    return false
end

-- Tombol ambil furnitur bunker
m:Button("Take Selected Bunker Furniture", function()
    TakeBunkerFurniture()
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
-- Monsters ESP
---------------------------------------------------------------------
local function findNightFolder()
    for _, f in ipairs(workspace:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("Night") then
            return f
        end
    end
    return nil
end

m:Toggle("Monsters ESP", false, function(state)
    getgenv().esp = state

    if state then
        task.spawn(function()
            while esp do
                local f = findNightFolder()
                if f then
                    for _, m in ipairs(f:GetChildren()) do
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
            for _, m in ipairs(f:GetChildren()) do
                if m:FindFirstChild("Highlight") then
                    m.Highlight:Destroy()
                end
            end
        end
    end
end)

---------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------
t:Button("to Bunker", function()
    local hrp = GetHRP()
    if hrp and bunkerName then
        local bunkers = workspace:FindFirstChild("Bunkers")
        if bunkers and bunkers:FindFirstChild(bunkerName) then
            hrp.CFrame = bunkers[bunkerName].SpawnLocation.CFrame
        end
    end
end)

t:Button("to Market", function()
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(143,5,-118) end
end)

t:Box("to Player", function(text, enter)
    if not enter then return end
    text = text:lower()

    for _, p in ipairs(players:GetPlayers()) do
        if p ~= plr and (p.Name:lower():find(text) or p.DisplayName:lower():find(text)) then
            local hrp = GetHRP()
            local tHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and tHRP then
                hrp.CFrame = tHRP.CFrame
            end
            return
        end
    end
end)

---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
s:Label("Press LeftControl to Hide UI", Color3.fromRGB(127, 143, 166))
s:Label("~ t.me/arceusxscripts", Color3.fromRGB(127, 143, 166))
s:Button("Destroy Gui", function()
	lib:Destroy()
end)

lib:Keybind("LeftControl")
