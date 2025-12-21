--------------------------------------------------------------------
--====================== SERVICES ================================
--------------------------------------------------------------------
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TP = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

--------------------------------------------------------------------
--====================== RAYFIELD LOAD ===========================
--------------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "DN HaeX — Furniture Hub",
    LoadingTitle = "DN HaeX",
    LoadingSubtitle = "Furniture Automation",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "DN HaeX"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

--------------------------------------------------------------------
--====================== UTILS ===================================
--------------------------------------------------------------------
local function GetHRP()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local function SafeTP(cf)
    local hrp = GetHRP()
    hrp.CFrame = cf
end

--------------------------------------------------------------------
--====================== MARKET DETECTION =========================
--------------------------------------------------------------------
local MarketPoints = {
    Vector2.new(50, -149.3),
    Vector2.new(-266, -145.7),
    Vector2.new(-266, 145),
    Vector2.new(50, 145)
}

local function PointInPolygon(point, polygon)
    local inside = false
    local j = #polygon
    for i = 1, #polygon do
        local xi, zi = polygon[i].X, polygon[i].Y
        local xj, zj = polygon[j].X, polygon[j].Y
        if ((zi > point.Y) ~= (zj > point.Y)) and
           (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 0.0001) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function IsInsideMarket(part)
    if not part then return false end
    local pos = part.Position
    if pos.Y < 0 or pos.Y > 20 then return false end
    return PointInPolygon(Vector2.new(pos.X, pos.Z), MarketPoints)
end

local function GetMarketFolder()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():find("wypo") then
            return v
        end
    end
end

--------------------------------------------------------------------
--====================== BUNKER DETECTION =========================
--------------------------------------------------------------------
local function IsInsideBunker(part)
    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers then return false end

    local bunker = bunkers:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
    if not bunker then return false end

    local ref = bunker.PrimaryPart or bunker:FindFirstChildWhichIsA("BasePart")
    if not ref then return false end

    local size = Vector3.new(50,50,50)
    local min = ref.Position - size/2
    local max = ref.Position + size/2
    local p = part.Position

    return p.X>=min.X and p.X<=max.X and
           p.Y>=min.Y and p.Y<=max.Y and
           p.Z>=min.Z and p.Z<=max.Z
end

--------------------------------------------------------------------
--====================== SCAN FUNCTION ============================
--------------------------------------------------------------------
local function ScanFurniture(checkFunc)
    local folder = GetMarketFolder()
    if not folder then return {} end
    local list, seen = {}, {}

    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and checkFunc(p) and not seen[o.Name] then
                    table.insert(list, o.Name)
                    seen[o.Name] = true
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(folder)
    table.sort(list)
    return list
end

local function FindFurnitureByName(name, checkFunc)
    local folder = GetMarketFolder()
    if not folder then return end
    for _, o in ipairs(folder:GetDescendants()) do
        if o:IsA("Model") and o.Name == name then
            local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
            if p and checkFunc(p) then
                return o
            end
        end
    end
end

--------------------------------------------------------------------
--====================== PICKUP CORE ==============================
--------------------------------------------------------------------
local function PickupModel(model)
    local hrp = GetHRP()
    local old = hrp.CFrame
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end

    SafeTP(part.CFrame + Vector3.new(0,0,5))
    task.wait(0.25)

    pcall(function()
        RS.PickupItemEvent:FireServer(model)
    end)

    task.wait(0.4)
    SafeTP(old)
end

--------------------------------------------------------------------
--====================== AUTO DROP ================================
--------------------------------------------------------------------
local function DropAll()
    pcall(function()
        RS.DropItemEvent:FireServer()
    end)
end

--------------------------------------------------------------------
--====================== UI ======================================
--------------------------------------------------------------------
local FurnitureTab = Window:CreateTab("Furniture", 4483362458)
local ServerTab = Window:CreateTab("Server", 4483362458)

---------------- MARKET ----------------
local MarketSection = FurnitureTab:CreateSection("Market Furniture")

local marketSelected
local marketLoop = false

local MarketDropdown = FurnitureTab:CreateDropdown({
    Name = "Market Furniture",
    Options = ScanFurniture(IsInsideMarket),
    Callback = function(v)
        marketSelected = v
    end
})

FurnitureTab:CreateButton({
    Name = "Pickup Selected (Once)",
    Callback = function()
        if marketSelected then
            local m = FindFurnitureByName(marketSelected, IsInsideMarket)
            if m then PickupModel(m) end
        end
    end
})

FurnitureTab:CreateToggle({
    Name = "Pickup Loop Until Empty",
    CurrentValue = false,
    Callback = function(v)
        marketLoop = v
        task.spawn(function()
            while marketLoop do
                local list = ScanFurniture(IsInsideMarket)
                if #list == 0 then break end
                for _, name in ipairs(list) do
                    if not marketLoop then break end
                    local m = FindFurnitureByName(name, IsInsideMarket)
                    if m then PickupModel(m) end
                    task.wait(0.15)
                end
            end
            DropAll()
        end)
    end
})

FurnitureTab:CreateButton({
    Name = "Drop All Items",
    Callback = DropAll
})

---------------- BUNKER ----------------
local BunkerSection = FurnitureTab:CreateSection("Bunker Furniture")

local bunkerSelected
local bunkerLoop = false

local BunkerDropdown = FurnitureTab:CreateDropdown({
    Name = "Bunker Furniture",
    Options = ScanFurniture(IsInsideBunker),
    Callback = function(v)
        bunkerSelected = v
    end
})

FurnitureTab:CreateButton({
    Name = "Pickup Selected (Once)",
    Callback = function()
        if bunkerSelected then
            local m = FindFurnitureByName(bunkerSelected, IsInsideBunker)
            if m then PickupModel(m) end
        end
    end
})

FurnitureTab:CreateToggle({
    Name = "Pickup Loop Until Empty",
    CurrentValue = false,
    Callback = function(v)
        bunkerLoop = v
        task.spawn(function()
            while bunkerLoop do
                local list = ScanFurniture(IsInsideBunker)
                if #list == 0 then break end
                for _, name in ipairs(list) do
                    if not bunkerLoop then break end
                    local m = FindFurnitureByName(name, IsInsideBunker)
                    if m then PickupModel(m) end
                    task.wait(0.15)
                end
            end
            DropAll()
        end)
    end
})

---------------- SERVER ----------------
local hop = false

ServerTab:CreateToggle({
    Name = "Auto Server Hop",
    CurrentValue = false,
    Callback = function(v)
        hop = v
        task.spawn(function()
            while hop do
                TP:Teleport(game.PlaceId, plr)
                task.wait(8)
            end
        end)
    end
})
