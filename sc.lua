--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
   Name = "DN SC9",
   LoadingTitle = "HaeX SC9",
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
local function GetHRP() local char = GetChar() return char:WaitForChild("HumanoidRootPart", 2) end
local function GetHum() local char = GetChar() return char:WaitForChild("Humanoid", 2) end

-------------------------------------------------------
--==================== UTILITY TAB ==================--
-------------------------------------------------------
local UtilityTab = Window:CreateTab("Utility", 4483362458)

UtilityTab:CreateButton({
    Name = "ESP",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
    end,
})

UtilityTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val)
        local char = GetChar()
        if char then char.Humanoid.WalkSpeed = val end
    end,
})

-- JumpPower fix
UtilityTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(val)
        local char = GetChar()
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
        end
        -- Pastikan juga saat respawn
        plr.CharacterAdded:Connect(function(c)
            c:WaitForChild("Humanoid").JumpPower = val
        end)
    end
})

UtilityTab:CreateButton({
    Name = "Anti Fall Damage",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
    end,
})

UtilityTab:CreateButton({
    Name = "Fly GUI V3",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
    end,
})

UtilityTab:CreateToggle({
    Name = "Wallhack / Through Walls ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().wallhack = state
        if state then
            task.spawn(function()
                while getgenv().wallhack do
                    for _, model in ipairs(workspace:GetChildren()) do
                        if model:IsA("Model") then
                            local hasHL = model:FindFirstChild("WallhackHL")
                            if not hasHL then
                                local hl = Instance.new("Highlight")
                                hl.Name = "WallhackHL"
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.FillColor = Color3.fromRGB(0,255,0)
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0
                                for _, part in ipairs(model:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        hl.Adornee = part
                                        hl.Parent = model
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            for _, model in ipairs(workspace:GetChildren()) do
                local hl = model:FindFirstChild("WallhackHL")
                if hl then hl:Destroy() end
            end
        end
    end
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
                        if part:IsA("BasePart") then part.CanCollide = false end
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
        hrp.CFrame = lastPos
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

-- Auto Eat
getgenv().autoEat = false
UtilityTab:CreateToggle({
    Name = "Auto Eat",
    CurrentValue = false,
    Callback = function(state)
        getgenv().autoEat = state
        task.spawn(function()
            while getgenv().autoEat do
                local char = GetChar()
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.Health < hum.MaxHealth then
                    -- Cari food di backpack
                    local food = nil
                    for _, item in ipairs(plr.Backpack:GetChildren()) do
                        if item:IsA("Tool") and item:FindFirstChild("Handle") then
                            food = item
                            break
                        end
                    end
                    -- Pakai food jika ada
                    if food then
                        food.Parent = char
                        task.wait(0.1)
                        if food:FindFirstChildOfClass("ProximityPrompt") then
                            fireproximityprompt(food:FindFirstChildOfClass("ProximityPrompt"))
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})


-- Furniture GUI
MainTab:CreateButton({
    Name = "Open Furniture GUI",
    Callback = function()
        local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
        local m = lib:Window("Furniture GUI")
        local selected = nil

        local function ReturnFurniture()
    local Names = {}

    -- Hanya ambil furniture yang berada DI MARKET (workspace.Wyposazenie)
    for _, category in ipairs(workspace.Wyposazenie:GetChildren()) do
        
        -- Market kategori folder
        if category:IsA("Folder") then
            for _, item in ipairs(category:GetChildren()) do
                if item:IsA("Model") and item:FindFirstChildWhichIsA("BasePart") then
                    table.insert(Names, item.Name)
                end
            end

        -- Di luar folder tetapi MASIH di Wyposazenie
        elseif category:IsA("Model") and category:FindFirstChildWhichIsA("BasePart") then
            table.insert(Names, category.Name)
        end
    end

    return Names
end


local function GetFurniture()
    -- Loop hanya pada MARKET
    for _, category in ipairs(workspace.Wyposazenie:GetChildren()) do
        
        if category:IsA("Folder") then
            for _, item in ipairs(category:GetChildren()) do
                if item:IsA("Model") and item.Name == selected then
                    -- Pastikan furniture masih ada (belum dipickup)
                    if item.Parent == category then
                        pcall(function()
                            RS.PickupItemEvent:FireServer(item)
                        end)
                        return true
                    end
                end
            end

        elseif category:IsA("Model") and category.Name == selected then
            if category.Parent == workspace.Wyposazenie then
                pcall(function()
                    RS.PickupItemEvent:FireServer(category)
                end)
                return true
            end
        end
    end

    return false
end


        m:Dropdown("Selected Furniture", ReturnFurniture(), function(option)
            selected = option
        end)

        m:Button("Bring Selected Furniture", function ()
            if selected then GetFurniture() end
        end)

         m:Button("Teleport to Selected Furniture", function()
    if not selected then return end
    local hrp = GetHRP()
    if not hrp then return end

    for _, category in ipairs(workspace.Wyposazenie:GetChildren()) do
        
        if category:IsA("Folder") then
            for _, item in ipairs(category:GetChildren()) do
                if item:IsA("Model") and item.Name == selected then
                    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    if part then hrp.CFrame = part.CFrame + Vector3.new(0,5,0) end
                    return
                end
            end
        
        elseif category:IsA("Model") and category.Name == selected then
            local part = category.PrimaryPart or category:FindFirstChildWhichIsA("BasePart")
            if part then hrp.CFrame = part.CFrame + Vector3.new(0,5,0) end
            return
        end
    end
end)



        m:Button("Close Furniture GUI", function()
            m:Destroy()
        end)
    end
})

-- Sound Spam
MainTab:CreateToggle({
    Name = "Sound Spam",
    CurrentValue = false,
    Callback = function(state)
        getgenv().sound_spam = state
        task.spawn(function()
            while getgenv().sound_spam do
                pcall(function()
                    RS:WaitForChild("SoundEvent"):FireServer("Drink")
                    RS:WaitForChild("SoundEvent"):FireServer("Eat")
                end)
                task.wait()
            end
        end)
    end
})

-- Monsters ESP
MainTab:CreateToggle({
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
                        if m:FindFirstChild("Highlight") then m.Highlight:Destroy() end
                    end
                end
            end
        end
    end
})

-- Close GUI (tetap di Main)
MainTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
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

-- Variabel untuk menyimpan player yang dipilih
-- Variabel untuk menyimpan player yang dipilih
local selectedPlayer = nil

-- Ambil daftar semua player kecuali local player
local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            table.insert(list, p.Name)
        end
    end
    return list
end

-- Dropdown untuk pilih player
local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerList(),
    Callback = function(option)
        selectedPlayer = option -- simpan player yang dipilih
    end
})

-- Tombol teleport ke player yang dipilih
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
                -- Offset sedikit agar tidak nabrak player target
                hrp.CFrame = tHRP.CFrame + Vector3.new(0,5,0)
            else
                warn("Target belum spawn atau HumanoidRootPart tidak ada.")
            end
        else
            warn("Player tidak tersedia / belum spawn.")
        end
    end
})

-- Tombol refresh dropdown untuk update player baru
TeleportTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerDropdown:UpdateOptions(GetPlayerList())
    end
})


-------------------------------------------------------
--==================== SETTINGS TAB =================--
-------------------------------------------------------
local SettingsTab = Window:CreateTab("Settings", 4483362458) -- pastikan icon unik

-- Tandai lokasi monster malam
getgenv().nightMonsterESP = false
UtilityTab:CreateToggle({
    Name = "Night Monsters ESP",
    CurrentValue = false,
    Callback = function(state)
        getgenv().nightMonsterESP = state
        if state then
            task.spawn(function()
                while getgenv().nightMonsterESP do
                    local nightFolder
                    for _, f in ipairs(workspace:GetChildren()) do
                        if f:IsA("Folder") and f.Name:match("Night") then
                            nightFolder = f
                            break
                        end
                    end
                    if nightFolder then
                        for _, m in ipairs(nightFolder:GetChildren()) do
                            if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") and not m:FindFirstChild("NM_ESP") then
                                -- Highlight
                                local hl = Instance.new("Highlight")
                                hl.Name = "NM_ESP"
                                hl.FillColor = Color3.fromRGB(255,0,0)
                                hl.FillTransparency = 0.5
                                hl.OutlineColor = Color3.fromRGB(255,255,255)
                                hl.OutlineTransparency = 0
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = m

                                -- Billboard label lokasi
                                local hrp = m:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local bill = Instance.new("BillboardGui")
                                    bill.Name = "NM_Label"
                                    bill.Adornee = hrp
                                    bill.Size = UDim2.new(0,100,0,50)
                                    bill.StudsOffset = Vector3.new(0,3,0)
                                    bill.AlwaysOnTop = true
                                    local txt = Instance.new("TextLabel")
                                    txt.Size = UDim2.new(1,0,1,0)
                                    txt.BackgroundTransparency = 1
                                    txt.Text = "Night Monster"
                                    txt.TextColor3 = Color3.fromRGB(255,0,0)
                                    txt.TextScaled = true
                                    txt.Parent = bill
                                    bill.Parent = m
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            -- Hapus semua ESP / label
            for _, f in ipairs(workspace:GetChildren()) do
                if f:IsA("Folder") and f.Name:match("Night") then
                    for _, m in ipairs(f:GetChildren()) do
                        local hl = m:FindFirstChild("NM_ESP")
                        if hl then hl:Destroy() end
                        local lbl = m:FindFirstChild("NM_Label")
                        if lbl then lbl:Destroy() end
                    end
                end
            end
        end
    end
})

-- Close GUI (tetap di Main)
SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})


