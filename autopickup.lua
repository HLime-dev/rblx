--------------------------------------------------
-- FURNITURE AUTO FARM (MARKET + BUNKER)
-- SINGLE TAB | MULTI SECTION | NO FLAG
--------------------------------------------------

if getgenv().FurnitureFarmLoaded then return end
getgenv().FurnitureFarmLoaded = true

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TP = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

local function GetHRP()
    local c = plr.Character or plr.CharacterAdded:Wait()
    return c:WaitForChild("HumanoidRootPart")
end

--------------------------------------------------
-- LOAD RAYFIELD
--------------------------------------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Furniture Auto Farm222",
    LoadingTitle = "Market + Bunker",
    LoadingSubtitle = "Auto Pickup & Drop",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FurnitureFarm",
        FileName = "Unified"
    },
})

local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

--------------------------------------------------
-- SECTION
--------------------------------------------------

local MarketSection = FarmTab:CreateSection("🛒 Market Furniture")
local BunkerSection = FarmTab:CreateSection("🏠 Bunker Furniture")

--------------------------------------------------
-- SERVER HOP
--------------------------------------------------

local function ServerHop()
    local pid = game.PlaceId
    local servers = HttpService:JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/"..pid.."/servers/Public?limit=100")
    )

    for _, s in ipairs(servers.data) do
        if s.playing < s.maxPlayers then
            TP:TeleportToPlaceInstance(pid, s.id)
            return
        end
    end
end

--------------------------------------------------
-- DROP
--------------------------------------------------

local function Drop()
    if RS:FindFirstChild("DropItemEvent") then
        RS.DropItemEvent:FireServer()
    end
end

--------------------------------------------------
-- MARKET LOGIC
--------------------------------------------------

local MarketSelected = {}
local MarketHop = false

local MarketPoints = {
    Vector2.new(50, -149.3),
    Vector2.new(-266, -145.7),
    Vector2.new(-266, 145),
    Vector2.new(50, 145)
}

local function PointInPolygon(p, poly)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local xi, zi = poly[i].X, poly[i].Y
        local xj, zj = poly[j].X, poly[j].Y
        if ((zi > p.Y) ~= (zj > p.Y))
        and (p.X < (xj - xi) * (p.Y - zi) / (zj - zi + 0.0001) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function IsInsideMarket(part)
    if not part then return false end
    local p = part.Position
    return p.Y > 0 and p.Y < 20
       and PointInPolygon(Vector2.new(p.X, p.Z), MarketPoints)
end

local function GetMarketFolder()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():match("wypo") then
            return v
        end
    end
end

local function GetMarketList()
    local f = GetMarketFolder()
    if not f then return {} end
    local list, seen = {}, {}

    local function scan(folder)
        for _, o in ipairs(folder:GetChildren()) do
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideMarket(p) and not seen[o.Name] then
                    seen[o.Name] = true
                    table.insert(list, o.Name)
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(f)
    table.sort(list)
    return list
end

local function FindMarketModel(name)
    local f = GetMarketFolder()
    if not f then return end
    local found

    local function scan(folder)
        for _, o in ipairs(folder:GetChildren()) do
            if found then return end
            if o:IsA("Model") and o.Name == name then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideMarket(p) then
                    found = o
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(f)
    return found
end

local function PickupMarket(name)
    local m = FindMarketModel(name)
    if not m then return false end

    local hrp = GetHRP()
    local part = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
    local old = hrp.CFrame

    hrp.CFrame = part.CFrame + Vector3.new(0,0,5)
    task.wait(0.25)
    RS.PickupItemEvent:FireServer(m)
    task.wait(0.35)
    hrp.CFrame = old

    return true
end

--------------------------------------------------
-- BUNKER LOGIC
--------------------------------------------------

local BunkerSelected = {}
local BunkerHop = false

local function IsInsideBunker(part)
    if not part then return false end

    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers then return false end

    local name = plr:GetAttribute("AssignedBunkerName")
    if not name then return false end

    local bunker = bunkers:FindFirstChild(name)
    if not bunker then return false end

    local base = bunker.PrimaryPart or bunker:FindFirstChildWhichIsA("BasePart")
    if not base then return false end

    local size = Vector3.new(50,50,50)
    local min = base.Position - size/2
    local max = base.Position + size/2
    local p = part.Position

    return p.X>=min.X and p.X<=max.X
       and p.Y>=min.Y and p.Y<=max.Y
       and p.Z>=min.Z and p.Z<=max.Z
end

local function GetBunkerList()
    local f = GetMarketFolder()
    if not f then return {} end
    local list, seen = {}, {}

    local function scan(folder)
        for _, o in ipairs(folder:GetChildren()) do
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideBunker(p) and not seen[o.Name] then
                    seen[o.Name] = true
                    table.insert(list, o.Name)
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(f)
    table.sort(list)
    return list
end

local function FindBunkerModel(name)
    local f = GetMarketFolder()
    if not f then return end
    local found

    local function scan(folder)
        for _, o in ipairs(folder:GetChildren()) do
            if found then return end
            if o:IsA("Model") and o.Name == name then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideBunker(p) then
                    found = o
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(f)
    return found
end

local function PickupBunker(name)
    local m = FindBunkerModel(name)
    if not m then return false end

    local hrp = GetHRP()
    local part = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
    local old = hrp.CFrame

    hrp.CFrame = part.CFrame + Vector3.new(0,0,5)
    task.wait(0.25)
    RS.PickupItemEvent:FireServer(m)
    task.wait(0.35)
    hrp.CFrame = old

    return true
end

--------------------------------------------------
-- UI MARKET
--------------------------------------------------

local MarketDD = FarmTab:CreateDropdown({
    Name = "Select Market Furniture",
    SectionParent = MarketSection,
    Options = GetMarketList(),
    MultipleOptions = true,
    Callback = function(v) MarketSelected = v end
})

FarmTab:CreateButton({
    Name = "Refresh Market",
    SectionParent = MarketSection,
    Callback = function()
        MarketDD:Refresh(GetMarketList())
    end
})

FarmTab:CreateToggle({
    Name = "Server Hop if Empty",
    SectionParent = MarketSection,
    Callback = function(v) MarketHop = v end
})

FarmTab:CreateToggle({
    Name = "Auto Pickup + Drop",
    SectionParent = MarketSection,
    Callback = function(on)
        task.spawn(function()
            while on do
                local found = false
                for _, n in ipairs(MarketSelected) do
                    if not on then return end
                    if PickupMarket(n) then
                        found = true
                        Drop()
                        task.wait(0.3)
                    end
                end
                if not found then
                    if MarketHop then ServerHop() end
                    return
                end
                task.wait(0.5)
            end
        end)
    end
})

--------------------------------------------------
-- UI BUNKER
--------------------------------------------------

local BunkerDD = FarmTab:CreateDropdown({
    Name = "Select Bunker Furniture",
    SectionParent = BunkerSection,
    Options = GetBunkerList(),
    MultipleOptions = true,
    Callback = function(v) BunkerSelected = v end
})

FarmTab:CreateButton({
    Name = "Refresh Bunker",
    SectionParent = BunkerSection,
    Callback = function()
        BunkerDD:Refresh(GetBunkerList())
    end
})

FarmTab:CreateToggle({
    Name = "Server Hop if Empty",
    SectionParent = BunkerSection,
    Callback = function(v) BunkerHop = v end
})

FarmTab:CreateToggle({
    Name = "Auto Pickup + Drop",
    SectionParent = BunkerSection,
    Callback = function(on)
        task.spawn(function()
            while on do
                local found = false
                for _, n in ipairs(BunkerSelected) do
                    if not on then return end
                    if PickupBunker(n) then
                        found = true
                        Drop()
                        task.wait(0.3)
                    end
                end
                if not found then
                    if BunkerHop then ServerHop() end
                    return
                end
                task.wait(0.5)
            end
        end)
    end
})
