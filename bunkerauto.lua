--------------------------------------------------
-- BUNKER FURNITURE AUTO FARM (RAYFIELD)
--------------------------------------------------

if getgenv().BunkerFurnitureRayfieldLoaded then return end
getgenv().BunkerFurnitureRayfieldLoaded = true

--------------------------------------------------
-- SERVICES
--------------------------------------------------

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
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
    Name = "Bunker Furniture Auto Farm",
    LoadingTitle = "Bunker Furniture",
    LoadingSubtitle = "Auto Pickup + Drop",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FurnitureFarm",
        FileName = "BunkerConfig"
    },
})

local Tab = Window:CreateTab("Bunker Auto Farm", 4483362458)

--------------------------------------------------
-- BUNKER BOUNDARY
--------------------------------------------------

local function IsInsideBunker(part)
    if not part then return false end

    local bunkers = workspace:FindFirstChild("Bunkers")
    if not bunkers then return false end

    local bunkerName = plr:GetAttribute("AssignedBunkerName")
    if not bunkerName then return false end

    local bunker = bunkers:FindFirstChild(bunkerName)
    if not bunker then return false end

    local center = bunker.PrimaryPart or bunker:FindFirstChildWhichIsA("BasePart")
    if not center then return false end

    -- boundary SAMA seperti permintaanmu
    local size = Vector3.new(50,50,50)
    local min = center.Position - size/2
    local max = center.Position + size/2
    local p = part.Position

    return (p.X >= min.X and p.X <= max.X)
       and (p.Y >= min.Y and p.Y <= max.Y)
       and (p.Z >= min.Z and p.Z <= max.Z)
end

--------------------------------------------------
-- WYPO SCAN
--------------------------------------------------

local function GetWyposFolder()
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():match("wypo") then
            return v
        end
    end
end

local function ReturnBunkerFurnitureList()
    local wypos = GetWyposFolder()
    if not wypos then return {} end

    local list, seen = {}, {}

    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
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

    scan(wypos)
    table.sort(list)
    return list
end

local function FindModelInBunker(name)
    local wypos = GetWyposFolder()
    if not wypos then return end
    local found

    local function scan(f)
        for _, o in ipairs(f:GetChildren()) do
            if found then return end
            if o:IsA("Model") and o.Name == name then
                local p = o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart", true)
                if p and IsInsideBunker(p) then
                    found = o
                    return
                end
            elseif o:IsA("Folder") then
                scan(o)
            end
        end
    end

    scan(wypos)
    return found
end

--------------------------------------------------
-- PICKUP + DROP
--------------------------------------------------

local function PickupBunkerFurniture(name)
    local model = FindModelInBunker(name)
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
-- UI CONTROLS
--------------------------------------------------

local SelectedFurniture = {}
local AutoFarm = false

local FurnitureDropdown = Tab:CreateDropdown({
    Name = "Select Bunker Furniture",
    Options = ReturnBunkerFurnitureList(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(opts)
        SelectedFurniture = opts
    end,
})

Tab:CreateButton({
    Name = "Refresh Furniture List",
    Callback = function()
        FurnitureDropdown:Refresh(ReturnBunkerFurnitureList())
    end,
})

Tab:CreateToggle({
    Name = "Auto Pickup + Drop (Bunker)",
    CurrentValue = false,
    Callback = function(v)
        AutoFarm = v

        if v then
            task.spawn(function()
                task.wait(2)

                while AutoFarm do
                    for _, name in ipairs(SelectedFurniture) do
                        if PickupBunkerFurniture(name) then
                            task.wait(0.3)
                            Drop()
                            task.wait(0.3)
                        end
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
            Title = "Bunker Auto Farm",
            Content = "Config loaded — auto farm resumed",
            Duration = 4
        })
    end
end)
