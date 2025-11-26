--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
    Name = "DN SC99",
    LoadingTitle = "HaeX SC99",
    LoadingSubtitle = "by Haex",
    ConfigurationSaving = { Enabled = false },
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local bunkerName = plr:GetAttribute("AssignedBunkerName")

-- Helper functions
local function GetChar() return plr.Character or plr.CharacterAdded:Wait() end
local function GetHRP() local char = GetChar(); return char and char:WaitForChild("HumanoidRootPart", 2) end
local function GetHum() local char = GetChar(); return char and char:WaitForChild("Humanoid", 2) end

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
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if getgenv().noclipConn then getgenv().noclipConn:Disconnect() getgenv().noclipConn = nil end
        end
    end
})

-- Market Furniture GUI
MainTab:CreateButton({
    Name = "Open Market Furniture GUI",
    Callback = function()
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        end)
        if not ok or not lib then warn("Gagal load Turtle-Lib") return end
        local m = lib:Window("Market Furniture GUI")
        local selected = nil

        -- List furniture
        local function GetMarketFolder()
            local names = {"MarketWyposazenie","MarketWypo","Wyposazenie"}
            for _, name in ipairs(names) do if workspace:FindFirstChild(name) then return workspace:FindFirstChild(name) end end
            for _, v in ipairs(workspace:GetChildren()) do if v:IsA("Folder") and v.Name:match("Wyposazenie") then return v end end
            return nil
        end

        local function ReturnFurnitureList()
            local list, seen = {}, {}
            local market = GetMarketFolder()
            if not market then return list end
            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") then
                        if child:FindFirstChildWhichIsA("BasePart", true) and not seen[child.Name] then
                            table.insert(list, child.Name)
                            seen[child.Name] = true
                        end
                    elseif child:IsA("Folder") then scan(child) end
                end
            end
            scan(market)
            table.sort(list)
            return list
        end

        local function FindModelByName(name)
            local market = GetMarketFolder()
            if not market then return nil end
            local found
            local function find(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child.Name == name then found = child return
                    elseif child:IsA("Folder") then find(child); if found then return end end
                end
            end
            find(market)
            return found
        end

        local function PickupFurnitureByName(name)
            local model = FindModelByName(name)
            if model then pcall(function() RS.PickupItemEvent:FireServer(model) end) end
        end

        local function TeleportToFurnitureByName(name)
            local hrp = GetHRP()
            local model = FindModelByName(name)
            if hrp and model then
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                if part then hrp.CFrame = part.CFrame + Vector3.new(0,5,0) end
            end
        end

        local furnOptions = ReturnFurnitureList()
        local furnDropdown = m:Dropdown("Selected Furniture", furnOptions, function(option) selected = option end)
        m:Button("Refresh Furniture List", function() furnDropdown:UpdateOptions(ReturnFurnitureList()) end)
        m:Button("Bring Selected Furniture", function() if selected then PickupFurnitureByName(selected) end end)
        m:Button("Teleport to Selected Furniture", function() if selected then TeleportToFurnitureByName(selected) end end)
        m:Button("Close GUI", function() if m.Destroy then m:Destroy() end end)
    end
})

-- Bunker Furniture GUI (dipindah ke Main)
MainTab:CreateButton({
    Name = "Open Bunker Furniture GUI",
    Callback = function()
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        end)
        if not ok or not lib then warn("Gagal load Turtle-Lib") return end
        local m = lib:Window("Bunker Furniture GUI")
        local selectedBunkerFurniture = nil

        local function ReturnBunkerFurnitureList()
            local list, seen = {}, {}
            local wyposFolder = workspace:FindFirstChild("Wyposazenie") or workspace:FindFirstChild("MarketWyposazenie")
            local bunkerFolder = workspace:FindFirstChild("Bunkers")
            if not wyposFolder or not bunkerFolder then return list end
            local bunkerModel = bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
            if not bunkerModel then return list end
            local bunkerCF = bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart")
            if not bunkerCF then return list end

            local function isInBunker(part)
                local size = Vector3.new(100,50,100)
                local minBound = bunkerCF.Position - size/2
                local maxBound = bunkerCF.Position + size/2
                local pos = part.Position
                return (pos.X>=minBound.X and pos.X<=maxBound.X) and
                       (pos.Y>=minBound.Y and pos.Y<=maxBound.Y) and
                       (pos.Z>=minBound.Z and pos.Z<=maxBound.Z)
            end

            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child:FindFirstChildWhichIsA("BasePart", true) then
                        local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                        if part and isInBunker(part) and not seen[child.Name] then
                            table.insert(list, child.Name)
                            seen[child.Name] = true
                        end
                    elseif child:IsA("Folder") then scan(child) end
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
            local bunkerCF = bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart")
            if not bunkerCF then return nil end

            local function isInBunker(part)
                local size = Vector3.new(100,50,100)
                local minBound = bunkerCF.Position - size/2
                local maxBound = bunkerCF.Position + size/2
                local pos = part.Position
                return (pos.X>=minBound.X and pos.X<=maxBound.X) and
                       (pos.Y>=minBound.Y and pos.Y<=maxBound.Y) and
                       (pos.Z>=minBound.Z and pos.Z<=maxBound.Z)
            end

            local found = nil
            local function scan(folder)
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") and child.Name==name then
                        local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                        if part and isInBunker(part) then found = child return end
                    elseif child:IsA("Folder") then scan(child); if found then return end end
                end
            end
            scan(wyposFolder)
            return found
        end

        local function TeleportToFurniture(name)
            local hrp = GetHRP()
            local model = FindModelInBunkerByName(name)
            if hrp and model then
                local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
                if part then hrp.CFrame = part.CFrame + Vector3.new(0,5,0) end
            end
        end

        local bunkerDropdown = m:Dropdown("Select Furniture", ReturnBunkerFurnitureList(), function(option) selectedBunkerFurniture = option end)
        m:Button("Refresh Furniture List", function() bunkerDropdown:UpdateOptions(ReturnBunkerFurnitureList()) end)
        m:Button("Bring Selected Furniture", function() 
            if selectedBunkerFurniture then
                local model = FindModelInBunkerByName(selectedBunkerFurniture)
                if model then pcall(function() RS.PickupItemEvent:FireServer(model) end) end
            end
        end)
        m:Button("Teleport to Selected Furniture", function() if selectedBunkerFurniture then TeleportToFurniture(selectedBunkerFurniture) end end)
        m:Button("Close GUI", function() if m.Destroy then m:Destroy() end end)
    end
})

-- Teleport ke Player (perbaikan koordinat)
local selectedPlayer = nil
local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do if p~=plr then table.insert(list,p.Name) end end
    return list
end

local playerDropdown = MainTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    Callback = function(option) selectedPlayer = option end
})

MainTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        if not selectedPlayer then warn("Belum memilih player!") return end
        local target = Players:FindFirstChild(selectedPlayer)
        local hrp = GetHRP()
        if target and target.Character then
            local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if tHRP and hrp then hrp.CFrame = tHRP.CFrame + Vector3.new(0,5,0)
            else warn("Target belum spawn atau HumanoidRootPart tidak ada.") end
        else warn("Player tidak tersedia / belum spawn.") end
    end
})

MainTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function() playerDropdown:UpdateOptions(GetPlayerList()) end
})
