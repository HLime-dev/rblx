local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DN bug fixed 26",
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

--====================================================
-- MONSTER NO DAMAGE (TOGGLE)
--====================================================

local godmodeConnection1 = nil
local godmodeConnection2 = nil
local godmodeEnabled = false

UtilityTab:CreateToggle({
    Name = "Monster No Damage",
    CurrentValue = false,
    Flag = "GodmodeToggle",
    Callback = function(state)
        godmodeEnabled = state

        local hum = GetHum()
        if not hum then
            warn("Humanoid tidak ditemukan!")
            return
        end

        -- MATIKAN fitur saat toggle OFF
        if not state then
            if godmodeConnection1 then godmodeConnection1:Disconnect() end
            if godmodeConnection2 then godmodeConnection2:Disconnect() end
            godmodeConnection1 = nil
            godmodeConnection2 = nil

            Rayfield:Notify({
                Title = "Godmode",
                Content = "Monster damage kembali normal.",
                Duration = 2
            })

            return
        end

        -- === AKTIFKAN GODMODE ===
        local maxHealth = hum.Health

        godmodeConnection1 = hum.HealthChanged:Connect(function()
            if not godmodeEnabled then return end
            if hum.Health < maxHealth then
                hum.Health = maxHealth
            end
        end)

        godmodeConnection2 = hum.StateChanged:Connect(function(_, new)
            if not godmodeEnabled then return end
            if new == Enum.HumanoidStateType.FallingDown or
               new == Enum.HumanoidStateType.Ragdoll or
               new == Enum.HumanoidStateType.Physics or
               new == Enum.HumanoidStateType.Knocked then

                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)

        Rayfield:Notify({
            Title = "Godmode",
            Content = "Kamu sekarang kebal dari monster hit.",
            Duration = 2
        })
    end
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
--=== Collect All Food di Bunker Sendiri ===--
MainTab:CreateButton({
    Name = "Collect All Food in Bunker",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local plrBunkerName = plr:GetAttribute("AssignedBunkerName")
        local bunkerFolder = workspace:FindFirstChild("Bunkers")
        if not bunkerFolder then return end

        local bunkerModel = bunkerFolder:FindFirstChild(plrBunkerName)
        if not bunkerModel then return end

        local bunkerCF = bunkerModel:FindFirstChild("PrimaryPart") or bunkerModel:FindFirstChildWhichIsA("BasePart")
        if not bunkerCF then return end

        -- bounding box bunker
        local size = Vector3.new(50,50,50)
        local minBound = bunkerCF.Position - size/2
        local maxBound = bunkerCF.Position + size/2

        -- simpan posisi awal
        local originalCFrame = hrp.CFrame

        -- scan semua Tool di Workspace
        for _, tool in ipairs(Workspace:GetDescendants()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

                if handle and prompt then
                    local pos = handle.Position
                    -- hanya ambil yang ada di bunker sendiri
                    if pos.X >= minBound.X and pos.X <= maxBound.X and
                       pos.Y >= minBound.Y and pos.Y <= maxBound.Y and
                       pos.Z >= minBound.Z and pos.Z <= maxBound.Z then

                        -- teleport sebentar ke item
                        hrp.CFrame = handle.CFrame + Vector3.new(0,4,0)
                        task.wait(0.15)
                        pcall(function() fireproximityprompt(prompt) end)
                        task.wait(0.05)
                    end
                end
            end
        end

        -- kembalikan ke posisi awal
        task.wait(0.1)
        pcall(function() hrp.CFrame = originalCFrame end)
    end
})

MainTab:CreateButton({
    Name = "Collect All Food (Skip Bunkers)",
    Callback = function()

        local hrp = GetHRP()
        if not hrp then return end

        local lastPos = hrp.CFrame

        local bunkersFolder = workspace:FindFirstChild("Bunkers")
        local bunkerCenters = {}

        ----------------------------------------------------
        -- 1. Ambil data semua bunker
        ----------------------------------------------------
        if bunkersFolder then
            for _, bunker in ipairs(bunkersFolder:GetChildren()) do
                
                -- cari primarypart atau part terbesar
                local biggestPart = nil
                local maxSize = 0

                for _, obj in ipairs(bunker:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local mag = obj.Size.Magnitude
                        if mag > maxSize then
                            maxSize = mag
                            biggestPart = obj
                        end
                    end
                end

                if biggestPart then
                    table.insert(bunkerCenters, {
                        pos = biggestPart.Position,
                        radius = (biggestPart.Size.Magnitude / 2) + 20 -- radius aman
                    })
                end
            end
        end

        ----------------------------------------------------
        -- 2. Cek apakah part berada di dalam salah satu bunker
        ----------------------------------------------------
        local function IsInsideAnyBunker(part)
            if not part then return false end

            for _, bunker in ipairs(bunkerCenters) do
                if (part.Position - bunker.pos).Magnitude <= bunker.radius then
                    return true
                end
            end

            return false
        end

        ----------------------------------------------------
        -- 3. Scan & collect food di map (skip dalam bunker)
        ----------------------------------------------------
        for _, tool in ipairs(Workspace:GetDescendants()) do
            if tool:IsA("Tool") then

                local handle = tool:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")

                if handle and prompt then
                    
                    -- SKIP JIKA FOOD BERADA DI DALAM BUNKER
                    if IsInsideAnyBunker(handle) then
                        continue
                    end

                    -- COLLECT FOOD DI LUAR BUNKER
                    hrp.CFrame = handle.CFrame + Vector3.new(0,4,0)
                    task.wait(0.15)
                    pcall(function() fireproximityprompt(prompt) end)
                    task.wait(0.05)
                end
            end
        end

        task.wait(0.1)
        pcall(function()
            hrp.CFrame = lastPos
        end)
    end
})

--------------
--=== DROP SAME NAME TOOLS + REFRESH ===--

local selectedTool = nil

-- FUNCTION UNTUK AMBIL DAFTAR TOOL DI BACKPACK
local function getToolNameList()
    local list = {}
    local unique = {}
    for _, tool in ipairs(plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") and not unique[tool.Name] then
            unique[tool.Name] = true
            table.insert(list, tool.Name)
        end
    end
    return list
end

-- BUAT DROPDOWN AWAL
local toolDropdown = MainTab:CreateDropdown({
    Name = "Select Tool to Drop",
    Options = getToolNameList(),
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(opt)
        selectedTool = opt[1]
    end,
})

-- TOMBOL REFRESH DROPDOWN
MainTab:CreateButton({
    Name = "Refresh Tool List",
    Callback = function()
        selectedTool = nil
        -- Update isi dropdown dengan daftar terbaru
        toolDropdown:Refresh({
            Options = getToolNameList(),
            CurrentOption = {},
        })
    end
})

-- TOMBOL DROP SEMUA TOOL NAMA SAMA
MainTab:CreateButton({
    Name = "Drop All Selected Tools",
    Callback = function()
        if not selectedTool then
            warn("Pilih Tool dulu di dropdown!")
            return
        end

        local hum = GetHum()
        local dropEvent = RS:FindFirstChild("DropToolEvent")
        if not dropEvent then
            warn("DropToolEvent tidak ditemukan")
            return
        end

        for _, tool in ipairs(plr.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.Name == selectedTool and tool:FindFirstChild("Handle") then
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
            Vector2.new( -266, -145.7 ),
            Vector2.new( -266, 154.8  ),
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
    if pos.Y < 0 then
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

        -----------------------------------------------------------
-- IMPROVED PICKUP FURNITURE IN MARKET (TELEPORT SAFE)
-----------------------------------------------------------

local function BringAndPickupFurniture(name)
    local hrp = GetHRP()
    if not hrp then 
        return warn("HRP tidak ditemukan!")
    end

    local originalCF = hrp.CFrame
    local model = FindModelInMarketByName(name)

    if not model then
        return warn("Furniture tidak ditemukan atau di luar Market!")
    end

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part then
        return warn("Part furniture tidak ditemukan!")
    end

    -- 1. Teleport ke furniture (agar masuk jarak server)
    hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
    task.wait(0.25)

    -- 2. Jalankan event pickup
    pcall(function()
        RS.PickupItemEvent:FireServer(model)
    end)

    -- 3. Kembali ke posisi semula
    task.wait(0.25)
    hrp.CFrame = originalCF

    return true
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
        return warn("Pilih furniture terlebih dahulu!")
    end

    BringAndPickupFurniture(selected)
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

         -----------------------------------------------------------
-- IMPROVED BUNKER PICKUP (TELEPORT SAFE) ✅
-----------------------------------------------------------
local function BringAndPickupBunkerFurniture(name)
    local hrp = GetHRP()
    if not hrp then
        return warn("HRP tidak ditemukan!")
    end

    local originalCF = hrp.CFrame

    local model = FindModelInBunkerByName(name)
    if not model then
        return warn("Furniture tidak ditemukan di Bunker!")
    end

    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part then
        return warn("PrimaryPart/part di dalam furniture tidak ditemukan!")
    end

    -- 1. Teleport ke part furniture agar masuk jarak pickup server
    hrp.CFrame = part.CFrame * CFrame.new(0, 5, 0)
    task.wait(0.3)

    -- 2. Tembakkan event pickup ke server
    pcall(function()
        RS.PickupItemEvent:FireServer(model)
    end)

    -- 3. Set physics agar interactable di client (opsional)
    for _, p in model:GetDescendants() do
        if p:IsA("BasePart") then
            p.Anchored = false
            p.CanCollide = true
            p:SetNetworkOwner(plr)
        end
    end

    -- 4. IMPORTANT: reacquire HRP dulu karena mungkin diganti server
    task.wait(0.3)
    local newHrp = GetHRP()
    if newHrp then
        pcall(function()
            newHrp.CFrame = originalCF
        end)
    end

    return true
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
    if not selectedBunkerFurniture then
        return warn("Pilih furniture dulu!")
    end
    BringAndPickupBunkerFurniture(selectedBunkerFurniture)
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

------tes---------



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
    Callback = function(option)
        selectedPlayer = option  -- table: { "PlayerName" }
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

        -- FIX: Ambil nama player dari table
        local playerName = selectedPlayer[1]

        if not playerName then
            return Rayfield:Notify({
                Title = "Teleport",
                Content = "Pilihan player kosong!",
                Duration = 2
            })
        end

        local target = Players:FindFirstChild(playerName)

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
                Content = "Berhasil teleport ke " .. playerName,
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

--====================================================
-- TELEPORT DROPDOWN FIXED
--====================================================
local TeleportSection = TeleportTab:CreateSection("Teleport")

local teleportLocations = {
    ["My Bunker"] = function()
        local hrp = GetHRP()
        local bunkers = workspace:FindFirstChild("Bunkers")
        local bunkerName = plr:GetAttribute("AssignedBunkerName")

        if hrp and bunkers and bunkerName and bunkers:FindFirstChild(bunkerName) then
            local spawn = bunkers[bunkerName]:FindFirstChild("SpawnLocation")
            if spawn then
                hrp.CFrame = spawn.CFrame
            end
        end
    end,

    ["Market"] = function()
        local hrp = GetHRP()
        if hrp then
            hrp.CFrame = CFrame.new(143, 5, -118)
        end
    end,

    ["Pintu Kecil"] = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(147.8, 6, 152.3) end
    end,

    ["Palette 2"] = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(68.5, 6, 141.9) end
    end,

    ["Gudang"] = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(-177.9, 6, 42.3) end
    end,

    ["Palette 1"] = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(71.4, 6, -59.4) end
    end,

    ["Kolam 1"] = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(295.1, 32.1, 14.2) end
    end,

    ["Bundaran 1"] = function()
        local hrp = GetHRP()
        if hrp then hrp.CFrame = CFrame.new(412.1, 32.7, 152.8) end
    end
}

local selectedTP = nil

local teleportDropdown = TeleportTab:CreateDropdown({
    Name = "Select Teleport Location",
    Options = {"My Bunker", "Market", "Pintu Kecil", "Palette 2", "Gudang", "Palette 1", "Kolam 1", "Bundaran 1"},
    CurrentOption = nil,
    Callback = function(option)
        selectedTP = option   -- "option" = { "My Bunker" } (table)
    end
})

TeleportTab:CreateButton({
    Name = "Teleport",
    Callback = function()
        if not selectedTP then
            return Rayfield:Notify({
                Title = "Teleport",
                Content = "Pilih lokasi dulu!",
                Duration = 2
            })
        end

        -- FIX: Ambil elemen pertama dari table
        local key = selectedTP[1]

        local func = teleportLocations[key]

        if func then
            func()
        else
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Lokasi tidak ditemukan: " .. tostring(key),
                Duration = 2
            })
        end
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

-----------------------------------------------------------------------
------------------------Tes Tab----------------------------------------

local TestingTab = Window:CreateTab("Testing", 4483362458)

--------------------------------------------------------------------
--==================== BUNKER FURNITURE GUI (FIXED) =================
--------------------------------------------------------------------

local FurnitureSection = Testing:CreateSection("Furniture Bunker")

Testing:CreateButton({
    Name = "Open Bunker Furniture GUI",
    Callback = function()
        -----------------------------------------------------------
        -- Load Turtle-Lib
        -----------------------------------------------------------
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        end)

        if not ok or not lib then
            warn("Gagal load Turtle-Lib")
            return
        end

        local selected = nil

        -----------------------------------------------------------
        -- BOUNDARY BUNKER (tidak diubah sesuai permintaanmu)
        -----------------------------------------------------------
        local function IsInsideBunker(part)
            if not part then return false end

            local pos = part.Position
            local bunkerFolder = workspace:FindFirstChild("Bunkers")
            if not bunkerFolder then return false end

            local bunkerModel = bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
            if not bunkerModel then return false end

            local bunkerCF = bunkerModel:FindFirstChild("PrimaryPart") or bunkerModel:FindFirstChildWhichIsA("BasePart")
            if not bunkerCF then return false end

            -- BOUNDARY tetap pakai yang kamu buat
            local size = Vector3.new(50,50,50)
            local minBound = bunkerCF.Position - size/2
            local maxBound = bunkerCF.Position + size/2

            return (pos.X >= minBound.X and pos.X <= maxBound.X) and
                   (pos.Y >= minBound.Y and pos.Y <= maxBound.Y) and
                   (pos.Z >= minBound.Z and pos.Z <= maxBound.Z)
        end

        -----------------------------------------------------------
        -- Get Wyposazenie Folder (mirip seperti contohmu)
        -----------------------------------------------------------
        local function GetWyposFolder()
            local possible = {
                "Wyposazenie", "MarketWyposazenie", "MarketWypo", "Wypo"
            }

            for _, name in ipairs(possible) do
                if workspace:FindFirstChild(name) then
                    return workspace[name]
                end
            end

            for _, v in workspace:GetChildren() do
                if v:IsA("Folder") and v.Name:match("Wypo") then
                    return v
                end
            end

            return nil
        end

        -----------------------------------------------------------
        -- Scan Furniture di Bunker (sama seperti contohmu)
        -----------------------------------------------------------
        local function ReturnBunkerFurnitureList()
            local wypos = GetWyposFolder()
            if not wypos then return {} end

            local list = {}
            local seen = {}

            local function scan(folder)
                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        if part and IsInsideBunker(part) and not seen[obj.Name] then
                            table.insert(list, obj.Name)
                            seen[obj.Name] = true
                        end
                    elseif obj:IsA("Folder") then
                        scan(obj)
                    end
                end
            end

            scan(wypos)
            table.sort(list)
            return list
        end

        -----------------------------------------------------------
        -- Find Model By Name di Bunker (pattern sama seperti contoh)
        -----------------------------------------------------------
        local function FindModelInBunkerByName(name)
            local wypos = GetWyposFolder()
            if not wypos then return nil end

            local result = nil

            local function search(folder)
                if result then return end

                for _, obj in ipairs(folder:GetChildren()) do
                    if obj:IsA("Model") and obj.Name == name then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        if part and IsInsideBunker(part) then
                            result = obj
                            return
                        end
                    end

                    if obj:IsA("Folder") then
                        search(obj)
                    end
                end
            end

            search(wypos)
            return result
        end

        -----------------------------------------------------------
        -- Bring & Pickup Furniture (flow SAMA seperti contohmu)
        -----------------------------------------------------------
        local function BringAndPickupBunkerFurniture(name)
            local hrp = GetHRP()
            if not hrp then 
                return warn("HRP tidak ditemukan!")
            end

            local originalCF = hrp.CFrame
            local model = FindModelInBunkerByName(name)

            if not model then
                return warn("Furniture tidak ditemukan atau di luar Bunker!")
            end

            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            if not part then
                return warn("Part furniture tidak ditemukan!")
            end

            -- 1. Teleport ke furniture (agar masuk jarak server)
            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            task.wait(0.25)

            -- 2. Jalankan event pickup
            pcall(function()
                RS.PickupItemEvent:FireServer(model)
            end)

            -- 3. Teleport kembali ke posisi semula
            task.wait(0.25)
            local newHrp = GetHRP()
            if newHrp then
                pcall(function()
                    newHrp.CFrame = originalCF
                end)
            end

            return true
        end

        -----------------------------------------------------------
        -- Teleport ke Furniture + return otomatis 5 detik (SAMA seperti contoh)
        -----------------------------------------------------------
        local function TeleportToFurnitureByName(name)
            local hrp = GetHRP()
            if not hrp then return end

            local original = hrp.CFrame
            local model = FindModelInBunkerByName(name)

            if not model then
                warn("Furniture di luar Bunker boundary!")
                return
            end

            local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
            if not part then return end

            hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)

            task.delay(5, function()
                local hrp2 = GetHRP()
                if hrp2 then
                    pcall(function()
                        hrp2.CFrame = original
                    end)
                end
            end)
        end

        -----------------------------------------------------------
        -- GUI COMPONENTS (DROPDOWN & BUTTON SAMA PERSIS seperti contoh)
        -----------------------------------------------------------
        local m = lib:Window("Bunker Furniture GUI")
        local furnOptions = ReturnBunkerFurnitureList()

        local furnDropdown = m:Dropdown("Selected Furniture", furnOptions, function(option)
            selected = option
        end)

        m:Button("Refresh Furniture List", function()
            local newList = ReturnBunkerFurnitureList()
            pcall(function()
                furnDropdown:UpdateOptions(newList)
            end)
        end)

        m:Button("Bring Selected Furniture", function()
            if not selected then
                return warn("Pilih furniture terlebih dahulu!")
            end

            BringAndPickupBunkerFurniture(selected)
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

