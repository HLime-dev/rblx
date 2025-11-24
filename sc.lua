---------------------------------------------------------------------
-- Furniture (Market + Bunker)
---------------------------------------------------------------------

local selected = nil
local selectedBunkerFurniture = nil

-- List furniture di MARKET
local function ReturnFurniture()
    local list = {}
    for _, x in ipairs(workspace.Wyposazenie:GetChildren()) do
        if x:IsA("Folder") then
            for _, md in ipairs(x:GetChildren()) do
                if md:IsA("Model") and not table.find(list, md.Name) then
                    table.insert(list, md.Name)
                end
            end
        elseif x:IsA("Model") then
            if not table.find(list, x.Name) then
                table.insert(list, x.Name)
            end
        end
    end
    return list
end

-- List furniture di BUNKER pemain
local function GetBunkerFurnitureList()
    local list = {}
    if not bunkerName then return list end

    local bunkersFolder = workspace:FindFirstChild("Bunkers")
    if not bunkersFolder then return list end

    local myBunker = bunkersFolder:FindFirstChild(bunkerName)
    if not myBunker then return list end

    local furnFolder = myBunker:FindFirstChild("Wyposazenie")
    if not furnFolder then return list end

    for _, item in ipairs(furnFolder:GetChildren()) do
        if item:IsA("Model") and not table.find(list, item.Name) then
            table.insert(list, item.Name)
        end
    end

    return list
end

---------------------------------------------------------------------
-- Get Furniture From Market
---------------------------------------------------------------------
local function GetFurniture()
    if not selected then return false end

    local hrp = GetHRP()
    if not hrp then return false end

    local originalPos = hrp.CFrame
    local MARKET_POS = CFrame.new(143, 5, -118)

    hrp.CFrame = MARKET_POS
    task.wait(0.4)

    for _, folder in ipairs(workspace.Wyposazenie:GetChildren()) do
        if folder:IsA("Folder") then
            for _, model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") and model.Name == selected then
                    pcall(function()
                        game.ReplicatedStorage.PickupItemEvent:FireServer(model)
                    end)
                    task.wait(0.3)
                    GetHRP().CFrame = originalPos
                    return true
                end
            end
        elseif folder:IsA("Model") and folder.Name == selected then
            pcall(function()
                game.ReplicatedStorage.PickupItemEvent:FireServer(folder)
            end)
            task.wait(0.3)
            GetHRP().CFrame = originalPos
            return true
        end
    end

    return false
end

---------------------------------------------------------------------
-- UI: Dropdown Market Furniture
---------------------------------------------------------------------
m:Dropdown("Market Furniture", ReturnFurniture(), function(option)
    selected = option
end)

m:Button("Bring Market Furniture", function()
    if selected then
        GetFurniture()
    end
end)

---------------------------------------------------------------------
-- UI: Dropdown Bunker Furniture
---------------------------------------------------------------------
m:Dropdown("Bunker Furniture", GetBunkerFurnitureList(), function(option)
    selectedBunkerFurniture = option
end)

m:Button("Take Bunker Furniture", function()
    if not selectedBunkerFurniture then return end
    if not bunkerName then return end

    local bunkersFolder = workspace:FindFirstChild("Bunkers")
    if not bunkersFolder then return end

    local myBunker = bunkersFolder:FindFirstChild(bunkerName)
    if not myBunker then return end

    local furnFolder = myBunker:FindFirstChild("Wyposazenie")
    if not furnFolder then return end

    for _, model in ipairs(furnFolder:GetChildren()) do
        if model:IsA("Model") and model.Name == selectedBunkerFurniture then

            pcall(function()
                game.ReplicatedStorage.PickupItemEvent:FireServer(model)
            end)

            if lib.Notification then
                lib:Notification("Success", "Berhasil mengambil furniture dari bunker!", 3)
            end

            return
        end
    end

    if lib.Notification then
        lib:Notification("Error", "Furniture tidak ditemukan di bunker!", 3)
    end
end)
