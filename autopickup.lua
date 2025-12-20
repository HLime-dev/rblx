--------------------------------------------------
-- MARKET + BUNKER AUTO FARM (RAYFIELD PERSISTENT)
--------------------------------------------------

if getgenv().FurnitureAllLoaded then return end
getgenv().FurnitureAllLoaded = true

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
-- RAYFIELD
--------------------------------------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Furniture Auto Farm111",
    LoadingTitle = "Market + Bunker",
    LoadingSubtitle = "Persistent Config",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FurnitureFarm",
        FileName = "AllConfig"
    },
})

local MarketTab = Window:CreateTab("Market", 4483362458)
local BunkerTab = Window:CreateTab("Bunker", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

--------------------------------------------------
-- SETTINGS FLAGS
--------------------------------------------------

local EnableServerHop = false
local EnableBunkerDrop = true

--------------------------------------------------
-- MARKET FUNCTIONS
--------------------------------------------------

local MarketPoints = {
    Vector2.new(50, -149.3),
    Vector2.new(-266, -145.7),
    Vector2.new(-266, 145),
    Vector2.new(50, 145)
}

local function PointInPolygon(point, poly)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local xi, zi = poly[i].X, poly[i].Y
        local xj, zj = poly[j].X, poly[j].Y
        if ((zi > point.Y) ~= (zj > point.Y))
        and (point.X < (xj-xi)*(point.Y-zi)/(zj-zi+0.0001)+xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function IsInsideMarket(part)
    if not part then return false end
    local p = part.Position
    if p.Y < 0 or p.Y > 20 then return false end
    return PointInPolygon(Vector2.new(p.X, p.Z), MarketPoints)
end

local function GetMarketFolder()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():match("wypo") then
            return v
        end
    end
end

local function GetMarketList()
    local m = GetMarketFolder()
    if not m then return {} end
    local list, seen = {}, {}
    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideMarket(p) and not seen[o.Name] then
                    seen[o.Name] = true
                    table.insert(list, o.Name)
                end
            elseif o:IsA("Folder") then scan(o) end
        end
    end
    scan(m)
    table.sort(list)
    return list
end

local function FindMarketModel(name)
    local m = GetMarketFolder()
    if not m then return end
    local found
    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if found then return end
            if o:IsA("Model") and o.Name == name then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideMarket(p) then found = o end
            elseif o:IsA("Folder") then scan(o) end
        end
    end
    scan(m)
    return found
end

--------------------------------------------------
-- BUNKER FUNCTIONS
--------------------------------------------------

local function GetWypos()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:match("Wypo") then
            return v
        end
    end
end

local function IsInsideBunker(part)
    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers then return false end
    local bunker = bunkers:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
    if not bunker then return false end
    local base = bunker.PrimaryPart or bunker:FindFirstChildWhichIsA("BasePart")
    if not base then return false end

    local size = Vector3.new(50,50,50)
    local minB = base.Position - size/2
    local maxB = base.Position + size/2
    local p = part.Position

    return p.X>=minB.X and p.X<=maxB.X
       and p.Y>=minB.Y and p.Y<=maxB.Y
       and p.Z>=minB.Z and p.Z<=maxB.Z
end

local function GetBunkerList()
    local w = GetWypos()
    if not w then return {} end
    local list, seen = {}, {}
    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if o:IsA("Model") then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideBunker(p) and not seen[o.Name] then
                    seen[o.Name] = true
                    table.insert(list, o.Name)
                end
            elseif o:IsA("Folder") then scan(o) end
        end
    end
    scan(w)
    table.sort(list)
    return list
end

local function FindBunkerModel(name)
    local w = GetWypos()
    if not w then return end
    local found
    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if found then return end
            if o:IsA("Model") and o.Name == name then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideBunker(p) then found = o end
            elseif o:IsA("Folder") then scan(o) end
        end
    end
    scan(w)
    return found
end

--------------------------------------------------
-- PICKUP / DROP
--------------------------------------------------

local function PickupModel(model)
    local hrp = GetHRP()
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part then return false end
    local old = hrp.CFrame
    hrp.CFrame = part.CFrame + Vector3.new(0,0,5)
    task.wait(0.3)
    RS.PickupItemEvent:FireServer(model)
    task.wait(0.25)
    hrp.CFrame = old
    return true
end

local function Drop()
    if RS:FindFirstChild("DropItemEvent") then
        RS.DropItemEvent:FireServer()
    end
end

--------------------------------------------------
-- SERVER HOP
--------------------------------------------------

local function ServerHop()
    if not EnableServerHop then return end
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
-- UI : MARKET
--------------------------------------------------

local MarketSelected, MarketRun = {}, false

MarketTab:CreateDropdown({
    Name = "Market Furniture",
    Options = GetMarketList(),
    MultipleOptions = true,
    Flag = "MarketSelect",
    Callback = function(v) MarketSelected = v end
})

MarketTab:CreateToggle({
    Name = "Auto Farm Market",
    Flag = "MarketToggle",
    Callback = function(v)
        MarketRun = v
        if v then
            task.spawn(function()
                while MarketRun do
                    local found
                    for _, n in ipairs(MarketSelected) do
                        local m = FindMarketModel(n)
                        if m then
                            found = true
                            PickupModel(m)
                            Drop()
                        end
                    end
                    if not found then ServerHop() break end
                    task.wait(0.4)
                end
            end)
        end
    end
})

--------------------------------------------------
-- UI : BUNKER
--------------------------------------------------

local BunkerSelected, BunkerRun = {}, false

BunkerTab:CreateDropdown({
    Name = "Bunker Furniture",
    Options = GetBunkerList(),
    MultipleOptions = true,
    Flag = "BunkerSelect",
    Callback = function(v) BunkerSelected = v end
})

BunkerTab:CreateToggle({
    Name = "Auto Farm Bunker",
    Flag = "BunkerToggle",
    Callback = function(v)
        BunkerRun = v
        if v then
            task.spawn(function()
                while BunkerRun do
                    local found
                    for _, n in ipairs(BunkerSelected) do
                        local m = FindBunkerModel(n)
                        if m then
                            found = true
                            PickupModel(m)
                            if EnableBunkerDrop then Drop() end
                        end
                    end
                    if not found then ServerHop() break end
                    task.wait(0.4)
                end
            end)
        end
    end
})

--------------------------------------------------
-- UI : SETTINGS
--------------------------------------------------

SettingsTab:CreateToggle({
    Name = "Enable Server Hop",
    Flag = "EnableServerHop",
    CurrentValue = false,
    Callback = function(v) EnableServerHop = v end
})

SettingsTab:CreateToggle({
    Name = "Bunker Auto Drop",
    Flag = "BunkerAutoDrop",
    CurrentValue = true,
    Callback = function(v) EnableBunkerDrop = v end
})

--------------------------------------------------
-- AUTO RESUME
--------------------------------------------------

task.delay(3, function()
    local f = Rayfield.Flags
    MarketSelected = f.MarketSelect or {}
    BunkerSelected = f.BunkerSelect or {}
    EnableServerHop = f.EnableServerHop or false
    EnableBunkerDrop = f.BunkerAutoDrop ~= false
end)
