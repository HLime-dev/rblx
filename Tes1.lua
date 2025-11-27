local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DN bug fixed 4",
   LoadingTitle = "Dangerous Night",
   LoadingSubtitle = "by Haex",
   ConfigurationSaving = { Enabled = false },
})

--==============================================================
--== FIXED CORE SERVICES & STANDARDIZED FUNCTIONS
--==============================================================
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local bunkerName = plr:GetAttribute("AssignedBunkerName")

--=== Character Helper (TIDAK ADA DUPLIKASI LAGI) ===--
local function GetChar()
    return plr.Character or plr.CharacterAdded:Wait()
end

local function GetHum()
    local char = GetChar()
    return char:WaitForChild("Humanoid", 2)
end

local function GetHRP()
    local char = GetChar()
    return char:WaitForChild("HumanoidRootPart", 2)
end

-- Function untuk HRP player lain (tidak bentrok)
local function GetPlayerHRP(player)
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end



--==============================================================
--=========================  UTILITY TAB  =======================
--==============================================================

local UtilityTab = Window:CreateTab("Utility", 4483362458)

UtilityTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local hum = GetHum()
        if hum then hum.WalkSpeed = val end
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



--==============================================================
--=========================== MAIN TAB =========================
--==============================================================

local MainTab = Window:CreateTab("Main", 4483362458)

-------------------------------------------------------
-- Noclip (FIXED: disconnect safe + restore colliders)
-------------------------------------------------------
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(state)
        getgenv().noclip = state

        if state then
            if getgenv().noclipConn then
                getgenv().noclipConn:Disconnect()
            end

            getgenv().noclipConn = game:GetService("RunService").Stepped:Connect(function()
                if not getgenv().noclip then return end
                local char = GetChar()
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanQuery = false
                    end
                end
            end)

        else
            if getgenv().noclipConn then
                getgenv().noclipConn:Disconnect()
                getgenv().noclipConn = nil
            end

            -- restore karakter
            local char = GetChar()
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.CanQuery = true
                end
            end
        end
    end
})


-------------------------------------------------------
--============ FOOD COLLECT SYSTEM (FIXED) ============
-------------------------------------------------------

local FoodSection = MainTab:CreateSection("Food")

--=== FIXED: scanning lebih aman ===--
MainTab:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end

        local lastPos = hrp.CFrame

        for _, tool in ipairs(Workspace:GetDescendants()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

                if handle and prompt then
                    hrp.CFrame = handle.CFrame + Vector3.new(0,4,0)
                    task.wait(0.15)
                    pcall(function() fireproximityprompt(prompt) end)
                    task.wait(0.05)
                end
            end
        end

        task.wait(0.1)
        pcall(function() hrp.CFrame = lastPos end)
    end
})



--=== DROP FOOD FIXED ===--
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local hum = GetHum()
        local dropEvent = RS:FindFirstChild("DropToolEvent")

        if not dropEvent then
            warn("DropToolEvent not ditemukan")
            return
        end

        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                hum:EquipTool(tool)
                task.wait(0.15)

                pcall(function()
                    dropEvent:FireServer(tool)
                end)

                task.wait(0.2)
                hum:UnequipTools()
            end
        end

        hum:UnequipTools()
    end
})


-----------------------------------------------------------------
-- BUNKER BOUNDARY FOOD COLLECT (fixed kedeteksian & scan folder)
-----------------------------------------------------------------

local function getMyBunkerPart()
    local bunkers = Workspace:FindFirstChild("Bunkers")
    if not bunkers then return nil end

    local my = bunkers:FindFirstChild(bunkerName)
    return my and (my.PrimaryPart or my:FindFirstChildWhichIsA("BasePart"))
end

local function isPartInMyBunker(part)
    local bunkerPart = getMyBunkerPart()
    if not bunkerPart or not part then return false end
    if not part:IsA("BasePart") then return false end

    local half = bunkerPart.Size / 2
    local localPos = bunkerPart.CFrame:PointToObjectSpace(part.Position)

    return (
        math.abs(localPos.X) <= half.X and
        math.abs(localPos.Y) <= half.Y and
        math.abs(localPos.Z) <= half.Z
    )
end


MainTab:CreateButton({
    Name = "Collect All Food in Bunker",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end

        if not getMyBunkerPart() then
            return Rayfield:Notify({Title="Food", Content="Bunker tidak ditemukan!", Duration=2})
        end

        local lastPos = hrp.CFrame

        for _, tool in ipairs(Workspace:GetDescendants()) do
            if tool:IsA("Tool") and tool.Name:match("Food") then
                local handle = tool:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

                if handle and prompt and isPartInMyBunker(handle) then
                    hrp.CFrame = handle.CFrame + Vector3.new(0,4,0)
                    task.wait(0.1)
                    pcall(function() fireproximityprompt(prompt) end)
                end
            end
        end

        pcall(function() hrp.CFrame = lastPos end)
        Rayfield:Notify({Title="Food", Content="Collect selesai!", Duration=2})
    end
})

--------------------------------------------------------------------
--==================== FURNITURE — MARKET GUI ======================
--------------------------------------------------------------------

local FurnitureSection = MainTab:CreateSection("Furniture")

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
        -- FIXED MARKET BOUNDARY POLYGON
        -----------------------------------------------------------

        local MarketPoints = {
            Vector2.new(  68.7, -149.3 ),
            Vector2.new( -160.4, -145.7 ),
            Vector2.new( -166.9, 154.8  ),
            Vector2.new(  71.1, 158.7  )
        }

        local function PointInPolygon(point, polygon)
            local inside = false
            local j = #polygon

            for i = 1, #polygon do
                local xi, zi = polygon[i].X, polygon[i].Y
                local xj, zj = polygon[j].X, polygon[j].Y

                local intersect = ((zi > point.Y) ~= (zj > point.Y))
                  and (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 0.0001) + xi)

                if intersect then
                    inside = not inside
                end

                j = i
            end

            return inside
        end

       local function IsInsideMarket(part)
    if not part then return false end

    local pos = part.Position

    -- REQUIREMENT: harus berada di atas Y = 6
    if pos.Y < 6 then
        return false
    end

    return PointInPolygon(Vector2.new(pos.X, pos.Z), MarketPoints)
end


        -----------------------------------------------------------
        -- FIXED MARKET FOLDER DETECTION
        -----------------------------------------------------------

        local function GetMarketFolder()
            local possible = {
                "MarketWyposazenie", "MarketWypo", "Wyposazenie",
                "MarketWypos", "Wyposzenie"
            }

            for _, name in ipairs(possible) do
                if Workspace:FindFirstChild(name) then
                    return Workspace[name]
                end
            end

            -- fallback: cari folder yang mirip
            for _, v in ipairs(Workspace:GetChildren()) do
                if v:IsA("Folder") and v.Name:match("Wypo") then
                    return v
                end
            end

            return nil
        end


        -----------------------------------------------------------
        -- SCAN FURNITURE MARKET (FIXED)
        -----------------------------------------------------------

        local function ReturnFurnitureList()
            local market = GetMarketFolder()
            if not market then return {} end

            local list = {}
            local seen = {}

            local function scan(folder)
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)

                        if part and IsInsideMarket(part) and not seen[obj.Name] then
                            table.insert(list, obj.Name)
                            seen[obj.Name] = true
                        end

                    elseif obj:IsA("Folder") then
                        scan(obj)
                    end
                end
            end

            scan(market)
            table.sort(list)
            return list
        end


        -----------------------------------------------------------
        -- FIND FURNITURE IN MARKET (FIXED)
        -----------------------------------------------------------

        local function FindModelInMarketByName(name)
            local market = GetMarketFolder()
            if not market then return nil end

            local result = nil

            local function search(folder)
                if result then return end

                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == name then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)

                        if part and IsInsideMarket(part) then
                            result = obj
                            return
                        end
                    end

                    if obj:IsA("Folder") then
                        search(obj)
                    end
                end
            end

            search(market)
            return result
        end


        -----------------------------------------------------------
        -- PICKUP FURNITURE IN MARKET (FIXED)
        -----------------------------------------------------------

        local function PickupFurnitureByName(name)
            local model = FindModelInMarketByName(name)

            if model then
                pcall(function()
                    RS.PickupItemEvent:FireServer(model)
                end)
                return true
            end

            return false
        end


        -----------------------------------------------------------
        -- TELEPORT TO FURNITURE (WITH RETURN)
        -----------------------------------------------------------

        local function TeleportToFurnitureByName(name)
            local hrp = GetHRP()
            if not hrp then return end

            local original = hrp.CFrame
            local model = FindModelInMarketByName(name)

            if not model then
                warn("Furniture berada di luar boundary market!")
                return
            end

            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            if not part then return end

            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)

            task.delay(5, function()
                if hrp then
                    pcall(function()
                        hrp.CFrame = original
                    end)
                end
            end)
        end


        -----------------------------------------------------------
        -- GUI UI COMPONENTS (DROPDOWN FIXED)
        -----------------------------------------------------------

        local furnOptions = ReturnFurnitureList()

        local furnDropdown = m:Dropdown("Selected Furniture", furnOptions, function(option)
            selected = option
        end)

        m:Button("Refresh Furniture List", function()
            local newList = ReturnFurnitureList()
            pcall(function()
                furnDropdown:UpdateOptions(newList)
            end)
        end)

        m:Button("Bring Selected Furniture", function()
            if not selected then
                warn("Pilih furniture terlebih dahulu!")
                return
            end

            if not PickupFurnitureByName(selected) then
                warn("Tidak ditemukan atau di luar Market!")
            end
        end)

        m:Button("Teleport to Furniture", function()
            if not selected then
                warn("Pilih furniture terlebih dahulu!")
                return
            end

            TeleportToFurnitureByName(selected)
        end)

        m:Button("Close GUI", function()
            pcall(function()
                if m and m.Destroy then m:Destroy() end
            end)
        end)
    end
})



--------------------------------------------------------------------
--==================== BUNKER FURNITURE GUI =======================
--------------------------------------------------------------------

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
    if not selectedBunkerFurniture then
        return warn("Pilih furniture dulu!")
    end

    local hrp = GetHRP()
    if not hrp then
        return warn("HRP tidak ditemukan!")
    end

    -- Simpan posisi awal
    local originalCFrame = hrp.CFrame

    -- Teleport ke furniture
    TeleportToFurniture(selectedBunkerFurniture)

    -- Setelah 5 detik kembali ke posisi awal
    task.delay(5, function()
        local hrp2 = GetHRP()
        if hrp2 then
            pcall(function()
                hrp2.CFrame = originalCFrame
            end)
        end
    end)
end)


            m:Button("Close GUI", function()
                if m and m.Destroy then pcall(function() m:Destroy() end) end
            end)
        end)

        if not ok2 then warn("Gagal membuat Furniture GUI") end
    end
})


--------------------------------------------------------------------
--=========================  TELEPORT TAB ==========================
--------------------------------------------------------------------

local TeleportTab = Window:CreateTab("Teleport", 4483362458)

TeleportTab:CreateButton({
    Name = "Teleport to Bunker",
    Callback = function()
        local hrp = GetHRP()
        local bunkers = Workspace:FindFirstChild("Bunkers")

        if hrp and bunkers and bunkerName and bunkers:FindFirstChild(bunkerName) then
            local spawn = bunkers[bunkerName]:FindFirstChild("SpawnLocation")
            if spawn then
                hrp.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Market",
    Callback = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(143, 5, -118)
        end
    end
})


--------------------------------------------------------------------
--========================= PLAYER TELEPORT ========================
--------------------------------------------------------------------

local PlayerSection = TeleportTab:CreateSection("Player")

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
    CurrentOption = nil,
    Flag = "PlayerSelectDropdown",
    Callback = function(option)
        selectedPlayer = option
    end
})

TeleportTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if not selectedPlayer then
            return Rayfield:Notify({
                Title = "Teleport",
                Content = "Belum memilih player!",
                Duration = 2
            })
        end

        local target = Players:FindFirstChild(selectedPlayer)

        if not target then
            return Rayfield:Notify({
                Title = "Teleport",
                Content = "Player tidak ditemukan!",
                Duration = 2
            })
        end

        if not target.Character then
            target.CharacterAdded:Wait()
            task.wait(0.2)
        end

        local tHRP = GetPlayerHRP(target)
        local myHRP = GetHRP()

        if tHRP and myHRP then
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 5, 0)
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Berhasil teleport ke " .. selectedPlayer,
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Target belum spawn!",
                Duration = 2
            })
        end
    end
})

TeleportTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        pcall(function()
            playerDropdown:UpdateOptions(GetPlayerList())
        end)

        Rayfield:Notify({
            Title = "Teleport",
            Content = "Player list diperbarui!",
            Duration = 2
        })
    end
})


--------------------------------------------------------------------
--============================= SETTINGS TAB =======================
--------------------------------------------------------------------

local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateButton({
    Name = "ESP Player",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
        end)
    end
})


--------------------------------------------------------------------
--======================== MONSTER ESP (FIXED) =====================
--------------------------------------------------------------------

SettingsTab:CreateToggle({
    Name = "Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().esp = state

        if state then
            -- Loop ESP
            task.spawn(function()
                while getgenv().esp do
                    local nightFolder = nil

                    for _, f in ipairs(Workspace:GetChildren()) do
                        if f:IsA("Folder") and f.Name:match("Night") then
                            nightFolder = f
                            break
                        end
                    end

                    if nightFolder then
                        for _, monster in ipairs(nightFolder:GetChildren()) do
                            if monster:IsA("Model") and monster:FindFirstChild("HumanoidRootPart") then

                                -- Tidak double ESP
                                if not monster:FindFirstChild("Highlight") then
                                    local hl = Instance.new("Highlight")
                                    hl.FillColor = Color3.new(1, 0, 0)
                                    hl.OutlineColor = Color3.new(1, 1, 1)
                                    hl.Parent = monster
                                end
                            end
                        end
                    end

                    task.wait(1)
                end
            end)

        else
            -- Remove ESP saat dimatikan
            for _, f in ipairs(Workspace:GetChildren()) do
                if f:IsA("Folder") and f.Name:match("Night") then
                    for _, monster in ipairs(f:GetChildren()) do
                        local hl = monster:FindFirstChild("Highlight")
                        if hl then
                            pcall(function()
                                hl:Destroy()
                            end)
                        end
                    end
                end
            end
        end
    end
})


--------------------------------------------------------------------
--============================ CLOSE GUI ==========================
--------------------------------------------------------------------

SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        pcall(function()
            Rayfield:Destroy()
        end)
    end
})
