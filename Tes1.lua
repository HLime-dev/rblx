local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DN9",
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

-- ✅ FIXED: Drop satu-satu tool ke depan player, no kill, no parent change
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local char = GetChar()
        local hrp = GetHRP()
        local hum = GetHum()
        if not char or not hrp or not hum then return end

        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                -- Equip 1 tool
                hum:EquipTool(tool)
                task.wait(0.15)

                -- Unequip semua biar grip lepas di server
                hum:UnequipTools()
                task.wait(0.05)

                -- Pastikan handle tidak lagi nempel di tangan → taruh di depan player
                pcall(function()
                    local handle = tool.Handle
                    handle.Anchored = false
                    handle.CFrame = hrp.CFrame * CFrame.new(0, 0, -4) -- jatuhkan ke depan player
                    handle.AssemblyLinearVelocity = Vector3.new(0, 6, 0) -- sentakan fisika biar dianggap dropped
                end)

                task.wait(0.25) -- delay per drop agar tidak tergenggam semua
            end
        end

        hum:UnequipTools() -- Sapu bersih equip state
    end
})



----market furn------

MainTab:CreateButton({
    Name = "Open Market Furniture GUI",
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
        -- MARKET BOUNDARIES (POLYGON)
        -----------------------------------------------------------
        local MarketPoints = {
            Vector2.new(68.7, -149.3),
            Vector2.new(-160.4, -145.7),
            Vector2.new(-166.9, 154.8),
            Vector2.new(71.1, 158.7)
        }

        local function PointInPolygon(point, polygon)
            local inside = false
            local j = #polygon
            for i = 1, #polygon do
                local xi, zi = polygon[i].X, polygon[i].Y
                local xj, zj = polygon[j].X, polygon[j].Y
                local intersect = ((zi > point.Y) ~= (zj > point.Y)) and
                    (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 0.0001) + xi)
                if intersect then
                    inside = not inside
                end
                j = i
            end
            return inside
        end

        local function IsInsideMarket(part)
            local pos = part.Position
            local point = Vector2.new(pos.X, pos.Z)
            return PointInPolygon(point, MarketPoints)
        end

        -----------------------------------------------------------
        -- Market folder detection
        -----------------------------------------------------------
        local function GetMarketFolder()
            local candidates = {
                "MarketWyposazenie", "MarketWypo", "Wyposazenie",
                "MarketWyposzenie", "MarketWypos",
            }
            for _, name in ipairs(candidates) do
                if workspace:FindFirstChild(name) then
                    return workspace[name]
                end
            end
            for _, v in ipairs(workspace:GetChildren()) do
                if v:IsA("Folder") and v.Name:match("Wyposazenie") then
                    return v
                end
            end
            return nil
        end

        -----------------------------------------------------------
        -- Scan furniture (market boundaries enforced)
        -----------------------------------------------------------
        local function ReturnFurnitureList()
            local list, seen = {}, {}
            local market = GetMarketFolder()
            if not market then return list end

            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") then
                        local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                        if part and IsInsideMarket(part) and not seen[child.Name] then
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
        -- Find model in market & inside boundaries
        -----------------------------------------------------------
        local function FindModelInMarketByName(name)
            local market = GetMarketFolder()
            if not market then return nil end
            local found = nil

            local function search(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child.Name == name then
                        local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                        if part and IsInsideMarket(part) then
                            found = child
                            return
                        end
                    elseif child:IsA("Folder") then
                        search(child)
                        if found then return end
                    end
                end
            end

            search(market)
            return found
        end

        -----------------------------------------------------------
        -- Pickup furniture (market-bound only)
        -----------------------------------------------------------
        local function PickupFurnitureByName(name)
            local model = FindModelInMarketByName(name)
            if model then
                pcall(function() RS.PickupItemEvent:FireServer(model) end)
                return true
            end
            return false
        end

        -----------------------------------------------------------
        -- Teleport to furniture (market-bound only)
        -----------------------------------------------------------
        -----------------------------------------------------------
-- Teleport to furniture (market-bound only) lalu kembali
-----------------------------------------------------------
local function TeleportToFurnitureByName(name)
    local hrp = GetHRP()
    if not hrp then return end

    -- Simpan posisi awal sebelum teleport
    local originalCFrame = hrp.CFrame

    local model = FindModelInMarketByName(name)
    if model then
        local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if part then
            -- Teleport ke furniture
            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)

            -- Tunggu 5 detik lalu kembali ke posisi awal
            task.delay(5, function()
                if hrp and originalCFrame then
                    pcall(function()
                        hrp.CFrame = originalCFrame
                    end)
                end
            end)
        end
    else
        warn("Furniture berada di luar Market!")
    end
end


        -----------------------------------------------------------
        -- GUI Components
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
            if not selected then return warn("Pilih furniture dulu!") end
            if not PickupFurnitureByName(selected) then
                warn("Furniture tidak ditemukan atau berada di luar market!")
            end
        end)

        m:Button("Teleport to Furniture", function()
            if not selected then return warn("Pilih furniture dulu!") end
            TeleportToFurnitureByName(selected)
        end)

        m:Button("Close GUI", function()
            if m and m.Destroy then pcall(function() m:Destroy() end) end
        end)
    end
})


-- Furniture Bunker GUI (CLEAN)
MainTab:CreateButton({
    Name = "Open Bunker Furniture GUI",
    Callback = function()
        -- Load library
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        end)
        if not ok or not lib then
            warn("Gagal load Turtle-Lib")
            return
        end

        -- Jalankan GUI furniture BUNKER-mu (kode asli milikmu, tidak diubah)
        local selectedBunkerFurniture = nil

        local function ReturnBunkerFurnitureList()
            local list = {}
            local seen = {}
            local wyposFolder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
            local bunkerFolder = workspace:FindFirstChild("Bunkers")
            if not wyposFolder or not bunkerFolder then return list end

            local bunkerModel = bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
            if not bunkerModel then return list end
            local bunkerCF = bunkerModel:FindFirstChild("PrimaryPart") or bunkerModel:FindFirstChildWhichIsA("BasePart")
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

            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
                        local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                        if part and isInBunker(part) and not seen[child.Name] then
                            table.insert(list, child.Name)
                            seen[child.Name] = true
                        end
                    elseif child:IsA("Folder") then
                        scan(child)
                    end
                end
            end

            scan(wyposFolder)
            table.sort(list)
            return list
        end

        local function FindModelInBunkerByName(name)
            local wyposFolder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
            local bunkerFolder = workspace:FindFirstChild("Bunkers")
            if not wyposFolder or not bunkerFolder then return nil end

            local bunkerModel = bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
            if not bunkerModel then return nil end
            local bunkerCF = bunkerModel:FindFirstChild("PrimaryPart") or bunkerModel:FindFirstChildWhichIsA("BasePart")
            if not bunkerCF then return nil end

            local function isInBunker(part)
                local size = Vector3.new(50,50,50)
                local minBound = bunkerCF.Position - size/2
                local maxBound = bunkerCF.Position + size/2
                local pos = part.Position
                return (pos.X >= minBound.X and pos.X <= maxBound.X) and
                       (pos.Y >= minBound.Y and pos.Y <= maxBound.Y) and
                       (pos.Z >= minBound.Z and pos.Z <= maxBound.Z)
            end

            local found = nil
            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child.Name == name then
                        local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                        if part and isInBunker(part) then
                            found = child
                            return
                        end
                    elseif child:IsA("Folder") then
                        scan(child)
                        if found then return end
                    end
                end
            end

            scan(wyposFolder)
            return found
        end

        local function TeleportToFurniture(name)
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

        local ok2, _ = pcall(function()
            local m = lib:Window("Bunker Furniture GUI")

            local dropdown = m:Dropdown("Select Furniture", ReturnBunkerFurnitureList(), function(option)
                selectedBunkerFurniture = option
            end)

            m:Button("Refresh Furniture List", function()
                local newList = ReturnBunkerFurnitureList()
                pcall(function() dropdown:UpdateOptions(newList) end)
            end)

            m:Button("Bring Selected Furniture", function()
                if selectedBunkerFurniture then
                    local model = FindModelInBunkerByName(selectedBunkerFurniture)
                    if model then
                        pcall(function() RS.PickupItemEvent:FireServer(model) end)
                    else
                        warn("Furniture tidak ada di bunker!")
                    end
                else
                    warn("Pilih furniture dulu!")
                end
            end)

            m:Button("Teleport to Selected Furniture", function()
                if selectedBunkerFurniture then
                    TeleportToFurniture(selectedBunkerFurniture)
                else
                    warn("Pilih furniture dulu!")
                end
            end)

            m:Button("Close GUI", function()
                if m and m.Destroy then pcall(function() m:Destroy() end) end
            end)
        end)

        if not ok2 then warn("Gagal membuat Furniture GUI") end
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
