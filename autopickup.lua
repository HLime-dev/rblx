--------------------------------------------------
-- FURNITURE AUTO FARM (RAYFIELD PERSISTENT)
--------------------------------------------------

if getgenv().FurnitureRayfieldLoaded then return end
getgenv().FurnitureRayfieldLoaded = true

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
-- RAYFIELD WINDOW
--------------------------------------------------

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Furniture Auto Farm",
    LoadingTitle = "Furniture Market",
    LoadingSubtitle = "Auto Pickup + Drop",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FurnitureFarm",
        FileName = "MarketConfig"
    },
})

local Tab = Window:CreateTab("Auto Farm", 4483362458)

--------------------------------------------------
-- MARKET BOUNDARY
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
        and (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 0.0001) + xi) then
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

--------------------------------------------------
-- MARKET SCAN
--------------------------------------------------

local function GetMarketFolder()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():match("wypo") then
            return v
        end
    end
end

local function ReturnFurnitureList()
    local market = GetMarketFolder()
    if not market then return {} end

    local list, seen = {}, {}

    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
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

    scan(market)
    table.sort(list)
    return list
end

local function FindModel(name)
    local market = GetMarketFolder()
    if not market then return end
    local found

    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if found then return end
            if o:IsA("Model") and o.Name == name then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideMarket(p) then
                    found = o
                    return
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(market)
    return found
end

--------------------------------------------------
-- PICKUP + DROP
--------------------------------------------------

local function Pickup(name)
    local model = FindModel(name)
    if not model then return false end

    local hrp = GetHRP()
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
    if not part then return false end

    local old = hrp.CFrame
    hrp.CFrame = part.CFrame + Vector3.new(0,0,5)
    task.wait(0.25)

    pcall(function()
        RS.PickupItemEvent:FireServer(model)
    end)

    task.wait(0.35)
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
    local pid = game.PlaceId
    local servers = HttpService:JSONDecode(
        game:HttpGet(
            "https://games.roblox.com/v1/games/"..pid.."/servers/Public?limit=100"
        )
    )

    for _, s in ipairs(servers.data) do
        if s.playing < s.maxPlayers then
            TP:TeleportToPlaceInstance(pid, s.id)
            return
        end
    end
end

--------------------------------------------------
-- UI CONTROLS
--------------------------------------------------

local SelectedFurniture = {}
local AutoFarm = false

local FurnitureDropdown = Tab:CreateDropdown({
    Name = "Select Furniture",
    Options = ReturnFurnitureList(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(opts)
        SelectedFurniture = opts
    end,
})

Tab:CreateButton({
    Name = "Refresh Furniture List",
    Callback = function()
        FurnitureDropdown:Refresh(ReturnFurnitureList())
    end,
})

Tab:CreateToggle({
    Name = "Auto Pickup + Drop",
    CurrentValue = false,
    Callback = function(v)
        AutoFarm = v

        if v then
            task.spawn(function()
                task.wait(2) -- allow config load

                while AutoFarm do
                    local foundAny = false

                    for _, name in ipairs(SelectedFurniture) do
                        if Pickup(name) then
                            foundAny = true
                            task.wait(0.5)
                            Drop()
                            task.wait(0.3)
                        end
                    end

                    if not foundAny then
                        ServerHop()
                        break
                    end

                    task.wait(0.5)
                end
            end)
        end
    end
})

--------------------------------------------------
-- AUTO RESUME INFO
--------------------------------------------------

task.delay(4, function()
    if AutoFarm then
        Rayfield:Notify({
            Title = "Furniture Auto Farm",
            Content = "Config loaded — auto farm resumed",
            Duration = 4
        })
    end
end)
