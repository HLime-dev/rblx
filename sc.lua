--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
   Name = "DN SC11",
   LoadingTitle = "HaeX SC11",
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

UtilityTab:CreateButton({
    Name = "ESP",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
        end)
    end,
})

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

UtilityTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(val)
        local char = GetChar()
        if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = val end
        plr.CharacterAdded:Connect(function(c)
            local ok, hum = pcall(function() return c:WaitForChild("Humanoid", 5) end)
            if ok and hum then
                hum.JumpPower = val
            end
        end)
    end
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
    Name = "Wallhack / Through Walls ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().wallhack = state
        if state then
            task.spawn(function()
                while getgenv().wallhack do
                    for _, model in ipairs(workspace:GetChildren()) do
                        if model:IsA("Model") then
                            if not model:FindFirstChild("WallhackHL") then
                                local ok, part = pcall(function()
                                    return model:FindFirstChildWhichIsA("BasePart", true)
                                end)
                                if ok and part then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "WallhackHL"
                                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    hl.FillColor = Color3.fromRGB(0,255,0)
                                    hl.FillTransparency = 0.5
                                    hl.OutlineTransparency = 0
                                    hl.Adornee = part
                                    hl.Parent = model
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, model in ipairs(workspace:GetChildren()) do
                local hl = model:FindFirstChild("WallhackHL")
                if hl then pcall(function() hl:Destroy() end) end
            end
        end
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

-- Auto Eat
getgenv().autoEat = false
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

--==================== FURNITURE GUI ====================--
local selectedBunkerFurniture, selectedMarketFurniture, furnitureGUIWindow

local function SafeReturnTable(func)
    local ok, result = pcall(func)
    return (ok and result) or {}
end

local function ReturnAllMarketFurniture()
    return SafeReturnTable(function()
        local list, seen = {}, {}
        local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
        if folder then
            local function scan(f)
                for _, c in ipairs(f:GetChildren()) do
                    if c:IsA("Model") and not seen[c.Name] then
                        table.insert(list, c.Name)
                        seen[c.Name] = true
                    elseif c:IsA("Folder") then scan(c) end
                end
            end
            scan(folder)
        end
        table.sort(list)
        return list
    end)
end

local function ReturnBunkerFurnitureList()
    return SafeReturnTable(function()
        local list, seen = {}, {}
        local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
        local bunkerFolder = workspace:FindFirstChild("Bunkers")
        local bunkerModel = bunkerFolder and bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
        local bunkerCF = bunkerModel and (bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart"))
        if not folder or not bunkerCF then return list end

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
                if c:IsA("Model") and not seen[c.Name] then
                    local part = c.PrimaryPart or c:FindFirstChildWhichIsA("BasePart", true)
                    if part and isInBunker(part) then
                        table.insert(list, c.Name)
                        seen[c.Name] = true
                    end
                elseif c:IsA("Folder") then scan(c) end
            end
        end
        scan(folder)
        table.sort(list)
        return list
    end)
end

local function FindModelByName(name, onlyInBunker)
    local folder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
    local bunkerFolder = workspace:FindFirstChild("Bunkers")
    local bunkerModel = bunkerFolder and bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
    local bunkerCF = bunkerModel and (bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart"))
    local found
    if not folder then return nil end

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
            elseif c:IsA("Folder") then scan(c) if found then return end end
        end
    end
    scan(folder)
    return found
end

local function TeleportToFurniture(model)
    local hrp = GetHRP()
    if not hrp or not model then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if part then hrp.CFrame = part.CFrame + Vector3.new(0,5,0) end
end

local function PickupFurniture(model)
    if model then pcall(function() RS.PickupItemEvent:FireServer(model) end) end
end

local function CreateFurnitureGUI()
    if furnitureGUIWindow and furnitureGUIWindow.Destroy then furnitureGUIWindow:Destroy() end
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
            if model then PickupFurniture(model) else warn("Furniture tidak ada di bunker!") end
        else warn("Pilih furniture bunker dulu!") end
    end)

    furnitureGUIWindow:Button("Teleport to Selected Bunker Furniture", function()
        if selectedBunkerFurniture then
            local model = FindModelByName(selectedBunkerFurniture, true)
            TeleportToFurniture(model)
        else warn("Pilih furniture bunker dulu!") end
    end)

    furnitureGUIWindow:Button("Bring Selected Market Furniture", function()
        if selectedMarketFurniture then
            local model = FindModelByName(selectedMarketFurniture, false)
            if model then PickupFurniture(model) else warn("Furniture market tidak ditemukan!") end
        else warn("Pilih furniture market dulu!") end
    end)

    furnitureGUIWindow:Button("Teleport to Selected Market Furniture", function()
        if selectedMarketFurniture then
            local model = FindModelByName(selectedMarketFurniture, false)
            TeleportToFurniture(model)
        else warn("Pilih furniture market dulu!") end
    end)

    furnitureGUIWindow:Button("Close GUI", function()
        if furnitureGUIWindow and furnitureGUIWindow.Destroy then furnitureGUIWindow:Destroy() end
        furnitureGUIWindow = nil
    end)
end

MainTab:CreateButton({
    Name = "Open Furniture GUI (Bunker + Market)",
    Callback = CreateFurnitureGUI
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

local selectedPlayer = nil
local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then table.insert(list, p.Name) end
    end
    return list
end

local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    Callback = function(option) selectedPlayer = option end
})

TeleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if not selectedPlayer then warn("Belum memilih player.") return end
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character then
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            local hrp = GetHRP()
            if tHRP and hrp then hrp.CFrame = tHRP.CFrame + Vector3.new(0,5,0)
            else warn("Target belum spawn atau HumanoidRootPart tidak ada.") end
        else warn("Player tidak tersedia / belum spawn.") end
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

getgenv().nightMonsterESP = false
SettingsTab:CreateToggle({
    Name = "Night Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().nightMonsterESP = state
        if state then
            task.spawn(function()
                while getgenv().nightMonsterESP do
                    local nightFolder
                    for _, f in ipairs(workspace:GetChildren()) do
                        if f:IsA("Folder") and f.Name:match("Night") then
                            nightFolder = f break
                        end
                    end
                    if nightFolder then
                        for _, m in ipairs(nightFolder:GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("NM_ESP") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "NM_ESP"
                                hl.FillColor = Color3.fromRGB(255,0,0)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                                hl.Adornee = m:FindFirstChild("HumanoidRootPart")
                                hl.Parent = m
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, f in ipairs(workspace:GetChildren()) do
                for _, m in ipairs(f:GetChildren()) do
                    local hl = m:FindFirstChild("NM_ESP")
                    if hl then pcall(function() hl:Destroy() end) end
                end
            end
        end
    end
})
