local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "DN",
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

-- Drop All Food
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local hrp = GetHRP()
        if not hrp then return end
        local lastPos = hrp.CFrame
        for _, v in ipairs(plr.Backpack:GetChildren()) do
            v.Parent = GetChar()
        end
        task.wait(0.2)
        local hum = GetHum()
        if hum then hum.Health = 0 end
        plr.CharacterAdded:Wait()
        task.wait(0.4)
        local newHRP = GetHRP()
        if newHRP then newHRP.CFrame = lastPos end
    end
})

-- Bring Selected Furniture
MainTab:CreateButton({
    Name = "Open Furniture GUI",
    Callback = function()
        local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        local m = lib:Window("Furniture")
        local selected = nil

        local function ReturnFurniture()
            local Names = {}
            for _, item in pairs(workspace.Wyposazenie:GetChildren()) do
                if item:IsA("Folder") then
                    for _, interno in pairs(item:GetChildren()) do
                        if interno:IsA("Model") and not table.find(Names, interno.Name) then
                            table.insert(Names, interno.Name)
                        end
                    end
                elseif item:IsA("Model") and not table.find(Names, item.Name) then
                    table.insert(Names, item.Name)
                end
            end
            return Names
        end

        local function GetFurniture()
            for _, furniture in pairs(workspace.Wyposazenie:GetChildren()) do
                if furniture:IsA("Folder") then
                    for _, interno in pairs(furniture:GetChildren()) do
                        if interno:IsA("Model") and interno.Name == selected then
                            RS.PickupItemEvent:FireServer(interno)
                            return true
                        end
                    end
                elseif furniture:IsA("Model") and furniture.Name == selected then
                    RS.PickupItemEvent:FireServer(furniture)
                    return true
                end
            end
            return false
        end

        m:Dropdown("Selected Furniture", ReturnFurniture(), function(option)
            selected = option
        end)

        m:Button("Bring Selected Furniture", function ()
            if selected then
                GetFurniture()
            end
        end)

        -- Tombol Close Turtle GUI
        m:Button("Close Furniture GUI", function()
            if m then
                m:Destroy()
            end
        end)
    end
})

--==================== BUNKER FURNITURE GUI (Muncul Setelah Tombol Ditekan) ==================--

MainTab:CreateButton({
    Name = "Open Bunker Furniture GUI",
    Callback = function()

        -- Load Turtle Lib saat tombol ditekan
        local ok, lib = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        end)
        if not ok or not lib then
            warn("Gagal load Turtle-Lib")
            return
        end

        -- Buat window baru
        local m = lib:Window("Bunker Furniture")

        local selectedBunkerFurniture = nil

        -- Ambil furniture yang hanya ada di dalam bunker
        local function ReturnBunkerFurniture()
            local list = {}
            local seen = {}
            
            local bunkerFolder = workspace:FindFirstChild("Bunkers")
            if not bunkerFolder then return list end

            local bunkerModel = bunkerFolder:FindFirstChild(plr:GetAttribute("AssignedBunkerName"))
            if not bunkerModel then return list end
            
            local bunkerPart = bunkerModel.PrimaryPart or bunkerModel:FindFirstChildWhichIsA("BasePart")
            if not bunkerPart then return list end

            local wyposFolder = workspace:FindFirstChild("Wyposazenie")
            if not wyposFolder then return list end

            local function isInBunker(pos)
                local size = Vector3.new(50,50,50) -- Sesuaikan jika perlu
                local minBound = bunkerPart.Position - size/2
                local maxBound = bunkerPart.Position + size/2
                return (pos.X >= minBound.X and pos.X <= maxBound.X)
                   and (pos.Y >= minBound.Y and pos.Y <= maxBound.Y)
                   and (pos.Z >= minBound.Z and pos.Z <= maxBound.Z)
            end

            for _, item in pairs(wyposFolder:GetDescendants()) do
                if item:IsA("Model") and item.Name and not seen[item.Name] then
                    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
                    if part and isInBunker(part.Position) then
                        table.insert(list, item.Name)
                        seen[item.Name] = true
                    end
                end
            end

            table.sort(list)
            return list
        end

        -- Cari furniture di bunker lalu pickup
        local function BringFurniture()
            if not selectedBunkerFurniture then return end
            
            local wyposFolder = workspace:FindFirstChild("Wyposazenie")
            if not wyposFolder then return end

            for _, item in pairs(wyposFolder:GetDescendants()) do
                if item:IsA("Model") and item.Name == selectedBunkerFurniture then
                    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        RS.PickupItemEvent:FireServer(item)
                        return
                    end
                end
            end

            warn("Furniture tidak ditemukan di bunker!")
        end

        -- Dropdown furniture bunker
        m:Dropdown("Select Furniture", ReturnBunkerFurniture(), function(option)
            selectedBunkerFurniture = option
        end)

        -- Tombol Bring/Pickup
        m:Button("Bring Selected Furniture", function()
            BringFurniture()
        end)

        -- Teleport ke furniture
        m:Button("Teleport to Selected", function()
            if selectedBunkerFurniture then
                local hrp = GetHRP()
                local wyposFolder = workspace:FindFirstChild("Wyposazenie")
                if not hrp or not wyposFolder then return end

                for _, item in pairs(wyposFolder:GetDescendants()) do
                    if item:IsA("Model") and item.Name == selectedBunkerFurniture then
                        local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true)
                        if part then
                            hrp.CFrame = part.CFrame + Vector3.new(0,5,0)
                            return
                        end
                    end
                end
            else
                warn("Pilih furniture dulu!")
            end
        end)

        -- Tombol Close GUI
        m:Button("Close Bunker Furniture GUI", function()
            if m and m.Destroy then
                pcall(function() m:Destroy() end)
            end
        end)

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
