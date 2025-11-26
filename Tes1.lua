local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DN2",
   LoadingTitle = "Dangerous Night",
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

-- Collect All Food
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

-- Drop All Food
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

-------------------------------------------------------
--==================== TELEPORT FURNITURE WITH RETURN 5 DETIK ==================--
-------------------------------------------------------
local function TeleportToFurnitureWithReturn(model)
    local hrp = GetHRP()
    if not hrp or not model then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if part then
        local originalCFrame = hrp.CFrame
        hrp.CFrame = part.CFrame + Vector3.new(0,5,0)
        task.spawn(function()
            task.wait(5)
            if hrp then
                hrp.CFrame = originalCFrame
            end
        end)
    end
end

-- Pickup furniture
local function PickupFurniture(model)
    if model then
        pcall(function() RS.PickupItemEvent:FireServer(model) end)
    end
end

-- Helper untuk Wyposazenie / Bunker
local function FindModelByName(name, onlyInBunker)
    local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
    if not folder then return nil end

    local bunkerFolder = workspace:FindFirstChild("Bunkers")
    local bunkerModel = bunkerFolder and bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
    local bunkerCF = bunkerModel and (bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart"))

    local function isInBunker(part)
        if not bunkerCF then return false end
        local size = Vector3.new(50,50,50)
        local minBound = bunkerCF.Position - size/2
        local maxBound = bunkerCF.Position + size/2
        local pos = part.Position
        return (pos.X >= minBound.X and pos.X <= maxBound.X) and
               (pos.Y >= minBound.Y and pos.Y <= maxBound.Y) and
               (pos.Z >= minBound.Z and pos.Z <= maxBound.Z)
    end

    local found = nil
    local function scan(f)
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") and c.Name == name then
                local part = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    if onlyInBunker then
                        if isInBunker(part) then found = c return end
                    else
                        found = c return
                    end
                end
            elseif c:IsA("Folder") then
                scan(c)
                if found then return end
            end
        end
    end
    scan(folder)
    return found
end

-------------------------------------------------------
--==================== FURNITURE GUI (Bunker + Market) ==================--
-------------------------------------------------------
local selectedBunkerFurniture = nil
local selectedMarketFurniture = nil
local furnitureGUIWindow = nil

local function ReturnAllMarketFurniture()
    local list, seen = {}, {}
    local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
    if not folder then return list end

    local function scan(f)
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") and c:FindFirstChildWhichIsA("BasePart", true) then
                if not seen[c.Name] then
                    table.insert(list, c.Name)
                    seen[c.Name] = true
                end
            elseif c:IsA("Folder") then
                scan(c)
            end
        end
    end

    scan(folder)
    table.sort(list)
    return list
end

local function ReturnBunkerFurnitureList()
    local list, seen = {}, {}
    local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
    if not folder then return list end

    local bunkerFolder = workspace:FindFirstChild("Bunkers")
    local bunkerModel = bunkerFolder and bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
    local bunkerCF = bunkerModel and (bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart"))
    if not bunkerCF then return list end

    local function isInBunker(part)
        local size = Vector3.new(50,50,50)
        local minBound = bunkerCF.Position - size/2
        local maxBound = bunkerCF.Position + size/2
        local pos = part.Position
        return (pos.X >= minBound.X and pos.X <= maxBound.X) and
               (pos.Y >= minBound.Y and pos.Y <= maxBound.Y) and
               (pos.Z >= minBound.Z and pos.Z <= maxBound.Z)
    end

    local function scan(f)
        for _, c in ipairs(f:GetChildren()) do
            if c:IsA("Model") and c:FindFirstChildWhichIsA("BasePart", true) then
                local part = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart", true)
                if part and isInBunker(part) and not seen[c.Name] then
                    table.insert(list, c.Name)
                    seen[c.Name] = true
                end
            elseif c:IsA("Folder") then
                scan(c)
            end
        end
    end

    scan(folder)
    table.sort(list)
    return list
end

local function CreateFurnitureGUI()
    if furnitureGUIWindow and furnitureGUIWindow.Destroy then
        furnitureGUIWindow:Destroy()
        furnitureGUIWindow = nil
    end

    local ok, lib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
    end)
    if not ok or not lib then warn("Gagal load Turtle-Lib") return end

    furnitureGUIWindow = lib:Window("Furniture GUI (Bunker + Market)")

    local bunkerDropdown = furnitureGUIWindow:Dropdown("Bunker Furniture", ReturnBunkerFurnitureList(), function(option)
        selectedBunkerFurniture = option
    end)

    local marketDropdown = furnitureGUIWindow:Dropdown("Market Furniture", ReturnAllMarketFurniture(), function(option)
        selectedMarketFurniture = option
    end)

    furnitureGUIWindow:Button("Refresh Furniture Lists", function()
        pcall(function()
            bunkerDropdown:UpdateOptions(ReturnBunkerFurnitureList())
            marketDropdown:UpdateOptions(ReturnAllMarketFurniture())
        end)
    end)

    furnitureGUIWindow:Button("Bring Selected Bunker Furniture", function()
        if selectedBunkerFurniture then
            local model = FindModelByName(selectedBunkerFurniture, true)
            PickupFurniture(model)
        else warn("Pilih furniture bunker dulu!") end
    end)

    furnitureGUIWindow:Button("Teleport to Selected Bunker Furniture", function()
        if selectedBunkerFurniture then
            local model = FindModelByName(selectedBunkerFurniture, true)
            TeleportToFurnitureWithReturn(model)
        else warn("Pilih furniture bunker dulu!") end
    end)

    furnitureGUIWindow:Button("Bring Selected Market Furniture", function()
        if selectedMarketFurniture then
            local model = FindModelByName(selectedMarketFurniture, false)
            PickupFurniture(model)
        else warn("Pilih furniture market dulu!") end
    end)

    furnitureGUIWindow:Button("Teleport to Selected Market Furniture", function()
        if selectedMarketFurniture then
            local model = FindModelByName(selectedMarketFurniture, false)
            TeleportToFurnitureWithReturn(model)
        else warn("Pilih furniture market dulu!") end
    end)

    furnitureGUIWindow:Button("Close GUI", function()
        if furnitureGUIWindow and furnitureGUIWindow.Destroy then pcall(function() furnitureGUIWindow:Destroy() end) end
        furnitureGUIWindow = nil
    end)
end

MainTab:CreateButton({
    Name = "Open Furniture GUI (Bunker + Market)",
    Callback = function()
        CreateFurnitureGUI()
    end
})

-------------------------------------------------------
--==================== TELEPORT TAB ==================--
-------------------------------------------------------
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

TeleportTab:CreateButton({
    Name = "Teleport to Bunker",
    Callback = function()
        local hrp = GetHRP()
        local bunkers = workspace:FindFirstChild("Bunkers")
        if hrp and bunkers and bunkerName and bunkers:FindFirstChild(bunkerName) then
            hrp.CFrame = bunkers[bunkerName].SpawnLocation.CFrame
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Market",
    Callback = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(143,5,-118) end
    end
})

-- Player teleport dropdown
local selectedPlayer = nil
local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(list, p.Name)
        end
    end
    return list
end

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    Callback = function(option)
        selectedPlayer = option
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if not selectedPlayer then
            warn("Belum memilih player.")
            return
        end
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local hrp = GetHRP()
            if tHRP and hrp then
                hrp.CFrame = tHRP.CFrame + Vector3.new(0,5,0)
            else
                warn("Target belum spawn atau HumanoidRootPart tidak ada.")
            end
        else
            warn("Player tidak tersedia / belum spawn.")
        end
    end
})

TeleportTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        pcall(function() playerDropdown:UpdateOptions(GetPlayerList()) end)
    end
})

-------------------------------------------------------
--==================== SETTINGS TAB =================--
-------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
    Name = "ESP Player",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
        end)
    end,
})

-- Monsters ESP
SettingsTab:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().esp = state
        if state then
            task.spawn(function()
                while getgenv().esp do
                    local nightFolder
                    for _, f in ipairs(workspace:GetChildren()) do
                        if f:IsA("Folder") and f.Name:match("Night") then nightFolder = f break end
                    end
                    if nightFolder then
                        for _, m in ipairs(nightFolder:GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("Highlight") then
                                Instance.new("Highlight", m)
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
                        if m:FindFirstChild("Highlight") then pcall(function() m.Highlight:Destroy() end) end
                    end
                end
            end
        end
    end
})

SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})
