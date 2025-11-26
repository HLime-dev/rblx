--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
   Name = "DN SC6",
   LoadingTitle = "HaeX SC6",
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
        -- pastikan saat respawn
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

-- Furniture GUI (CLEAN)
MainTab:CreateButton({
    Name = "Open Furniture GUI",
    Callback = function()
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        end)
        if not ok or not lib then
            warn("Gagal load Turtle-Lib")
            return
        end

        local m = lib:Window("Furniture GUI")
        local selected = nil

        -----------------------------------------------------------
        -- Market folder detection (flexible)
        -----------------------------------------------------------
        local function GetMarketFolder()
            -- Prioritas nama yang umum
            local candidates = {
                "MarketWyposazenie",
                "MarketWypo",
                "Wyposazenie",
                "MarketWyposzenie",
                "MarketWypos",
            }

            for _, name in ipairs(candidates) do
                if workspace:FindFirstChild(name) then
                    return workspace:FindFirstChild(name)
                end
            end

            -- Cari folder yang mengandung "Wyposazenie" atau berakhiran "_Wyposazenie" (multiple maps)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Folder") and v.Name:match("Wyposazenie") then
                    return v
                end
            end

            -- fallback: cari folder dengan banyak model (kemungkinan market)
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Folder") then
                    local modelCount = 0
                    for _, c in ipairs(v:GetChildren()) do
                        if c:IsA("Model") then modelCount = modelCount + 1 end
                    end
                    if modelCount >= 3 then
                        return v
                    end
                end
            end

            return nil
        end

        -----------------------------------------------------------
        -- Return unique list of furniture names in market (recursive)
        -----------------------------------------------------------
        local function ReturnFurnitureList()
            local list = {}
            local seen = {}
            local market = GetMarketFolder()
            if not market then return list end

            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") then
                        local hasPart = child:FindFirstChildWhichIsA("BasePart", true)
                        if hasPart and not seen[child.Name] then
                            table.insert(list, child.Name)
                            seen[child.Name] = true
                        end
                    elseif child:IsA("Folder") then
                        scan(child)
                    end
                end
            end

            scan(market)
            table.sort(list)
            return list
        end

        -----------------------------------------------------------
        -- Find target model recursively (market only)
        -----------------------------------------------------------
        local function FindModelInMarketByName(name)
            local market = GetMarketFolder()
            if not market then return nil end
            local found = nil

            local function find(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child.Name == name then
                        found = child
                        return
                    elseif child:IsA("Folder") then
                        find(child)
                        if found then return end
                    end
                end
            end

            find(market)
            return found
        end

        -----------------------------------------------------------
        -- Pickup furniture
        -----------------------------------------------------------
        local function PickupFurnitureByName(name)
            if not name then return false end
            local model = FindModelInMarketByName(name)
            if model then
                pcall(function() RS.PickupItemEvent:FireServer(model) end)
                return true
            end
            return false
        end

        -----------------------------------------------------------
        -- Teleport to furniture
        -----------------------------------------------------------
        local function TeleportToFurnitureByName(name)
            if not name then return end
            local hrp = GetHRP()
            if not hrp then return end
            local model = FindModelInMarketByName(name)
            if model then
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end

        -----------------------------------------------------------
        -- GUI components & interactions
        -----------------------------------------------------------
        local furnOptions = ReturnFurnitureList()
        local furnDropdown = m:Dropdown("Selected Furniture", furnOptions, function(option)
            selected = option
        end)

        m:Button("Refresh Furniture List", function()
            local newList = ReturnFurnitureList()
            pcall(function() furnDropdown:UpdateOptions(newList) end)
        end)

        m:Button("Bring Selected Furniture", function()
            if selected then
                local ok = PickupFurnitureByName(selected)
                if not ok then warn("Furniture tidak ditemukan atau sudah diambil.") end
            else
                warn("Pilih furniture dulu!")
            end
        end)

        m:Button("Teleport to Furniture", function()
            if selected then
                TeleportToFurnitureByName(selected)
            else
                warn("Pilih furniture dulu!")
            end
        end)

        m:Button("Close GUI", function()
            if m and m.Destroy then
                pcall(function() m:Destroy() end)
            end
        end)
    end
})

-- Sound Spam
MainTab:CreateToggle({
    Name = "Sound Spam",
    CurrentValue = false,
    Callback = function(state)
        getgenv().sound_spam = state
        task.spawn(function()
            while getgenv().sound_spam do
                pcall(function()
                    RS:WaitForChild("SoundEvent"):FireServer("Drink")
                    RS:WaitForChild("SoundEvent"):FireServer("Eat")
                end)
                task.wait()
            end
        end)
    end
})

-- Monsters ESP
MainTab:CreateToggle({
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

-- Close GUI (tetap di Main)
MainTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
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
--==================== BUNKER FURNITURE TAB ==================--
-------------------------------------------------------
-------------------------------------------------------
--==================== BUNKER FURNITURE GUI ==================--
-------------------------------------------------------
local BunkerTab = Window:CreateTab("Bunker Furniture", 4483362458)

local selectedBunkerFurniture = nil

-- Scan furniture bunker yang bisa diambil
local function ReturnPickupableBunkerFurniture()
    local list = {}
    local seen = {}
    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers or not bunkerName or not bunkers:FindFirstChild(bunkerName) then return list end
    local bunkerFolder = bunkers[bunkerName]

    local function scan(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
                -- Cek apakah bisa di-pickup (Market furniture)
                local ok = pcall(function() RS.PickupItemEvent:FireServer(child) end)
                if ok and not seen[child.Name] then
                    table.insert(list, child.Name)
                    seen[child.Name] = true
                end
            elseif child:IsA("Folder") then
                scan(child)
            end
        end
    end

    scan(bunkerFolder)
    table.sort(list)
    return list
end

-- Cari model di bunker by name
local function FindModelInBunkerByName(name)
    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers or not bunkerName or not bunkers:FindFirstChild(bunkerName) then return nil end
    local bunkerFolder = bunkers[bunkerName]
    local found = nil

    local function find(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("Model") and child.Name == name then
                found = child
                return
            elseif child:IsA("Folder") then
                find(child)
                if found then return end
            end
        end
    end

    find(bunkerFolder)
    return found
end

-- Teleport ke furniture di bunker
local function TeleportToBunkerFurniture(name)
    local hrp = GetHRP()
    if not hrp then return end
    local model = FindModelInBunkerByName(name)
    if model then
        local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if part then
            hrp.CFrame = part.CFrame + Vector3.new(0,5,0)
        end
    end
end

-- GUI components
local ok, lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
end)
if not ok or not lib then warn("Gagal load Turtle-Lib") return end

local m = lib:Window("Bunker Furniture GUI")

-- Dropdown furniture
local bunkerDropdown = m:Dropdown("Select Furniture", ReturnPickupableBunkerFurniture(), function(option)
    selectedBunkerFurniture = option
end)

-- Tombol Refresh
m:Button("Refresh Furniture List", function()
    local newList = ReturnPickupableBunkerFurniture()
    pcall(function() bunkerDropdown:UpdateOptions(newList) end)
end)

-- Tombol Bring / Pickup
m:Button("Bring Selected Furniture", function()
    if selectedBunkerFurniture then
        local model = FindModelInBunkerByName(selectedBunkerFurniture)
        if model then
            pcall(function() RS.PickupItemEvent:FireServer(model) end)
        end
    else
        warn("Pilih furniture dulu!")
    end
end)

-- Tombol Teleport
m:Button("Teleport to Selected Furniture", function()
    if selectedBunkerFurniture then
        TeleportToBunkerFurniture(selectedBunkerFurniture)
    else
        warn("Pilih furniture dulu!")
    end
end)

-- Tombol Close GUI
m:Button("Close GUI", function()
    if m and m.Destroy then pcall(function() m:Destroy() end) end
end)


-------------------------------------------------------
--==================== SETTINGS TAB =================--
-------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458)

getgenv().nightMonsterESP = false
UtilityTab:CreateToggle({
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
                            nightFolder = f
                            break
                        end
                    end
                    if nightFolder then
                        for _, m in ipairs(nightFolder:GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("NM_ESP") then
                                local hl = Instance.new("Highlight")
                                hl.Name = "NM_ESP"
                                hl.FillColor = Color3.fromRGB(255,0,0)
                                hl.FillTransparency = 0.5
                                hl.OutlineColor = Color3.fromRGB(255,255,255)
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = m

                                local hrp = m:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local bill = Instance.new("BillboardGui")
                                    bill.Name = "NM_Label"
                                    bill.Adornee = hrp
                                    bill.Size = UDim2.new(0,100,0,50)
                                    bill.StudsOffset = Vector3.new(0,3,0)
                                    bill.AlwaysOnTop = true
                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.new(1,0,1,0)
                                    txt.BackgroundTransparency = 1
                                    txt.Text = "Night Monster"
                                    txt.TextColor3 = Color3.fromRGB(255,0,0)
                                    txt.TextScaled = true
                                    txt.Parent = bill
                                    bill.Parent = m
                                end
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
                        local hl = m:FindFirstChild("NM_ESP")
                        if hl then pcall(function() hl:Destroy() end) end
                        local lbl = m:FindFirstChild("NM_Label")
                        if lbl then pcall(function() lbl:Destroy() end) end
                    end
                end
            end
        end
    end
})

-- Close GUI (tetap di Main)
SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})
