-- Dangerous Night — Rayfield Enhanced (converted from original Turtle-Lib script)
-- Features: Noclip, WalkSpeed, Collect/Drop Food, Bring Furniture, Sound Spam, Monsters ESP, Teleports, Destroy UI
-- Usage: Place as LocalScript (StarterPlayer -> StarterPlayerScripts) or run in executor for your own game.
-- Rayfield V4 (stable)
local ok, err = pcall(function()
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local player = Players.LocalPlayer
    local function waitChar()
        return player.Character or player.CharacterAdded:Wait()
    end
    local char = waitChar()
    local function getHRP(c)
        c = c or player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local hrp = getHRP(char)
    local function getHum(c)
        c = c or player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local hum = getHum(char)

    -- safe assigned bunker attribute
    local bunkerName = player:GetAttribute("AssignedBunkerName")

    -- Optional server events (use if server provides them)
    local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    local Remote_PickupItem = ReplicatedStorage:FindFirstChild("PickupItemEvent") -- older name in original script
    local RequestPickupEV = remoteFolder and remoteFolder:FindFirstChild("PickupItemEvent") or Remote_PickupItem
    local SoundEvent = ReplicatedStorage:FindFirstChild("SoundEvent")
    local PickupItemEvent = ReplicatedStorage:FindFirstChild("PickupItemEvent") or (remoteFolder and remoteFolder:FindFirstChild("PickupItemEvent"))
    -- NOTE: If server uses different RemoteEvent names, change above.

    -- Create window
    local Window = Rayfield:CreateWindow({
        Name = "Dangerous Night | Enhanced",
        LoadingTitle = "Initializing",
        LoadingSubtitle = "Rayfield Edition",
        ConfigurationSaving = { Enabled = false }
    })

    local Main = Window:CreateTab("Main")
    local ESPtab = Window:CreateTab("ESP")
    local Teleport = Window:CreateTab("Teleport")
    local Settings = Window:CreateTab("Settings")

    -- Utility helpers
    local function safeNotify(title, content, duration)
        pcall(function() Rayfield:Notify({Title = title, Content = content or "", Duration = duration or 2}) end)
    end

    local function safeGetHRP()
        local c = player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function safeGetHum()
        local c = player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end

    local function findNightFolder()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") and string.find(obj.Name, "Night") then
                return obj
            end
        end
        return nil
    end

    local function findFurnitureNames()
        local out = {}
        local root = Workspace:FindFirstChild("Wyposazenie")
        if not root then return out end
        for _, item in ipairs(root:GetChildren()) do
            if item:IsA("Folder") then
                for _, interno in ipairs(item:GetChildren()) do
                    if interno:IsA("Model") and not table.find(out, interno.Name) then
                        table.insert(out, interno.Name)
                    end
                end
            elseif item:IsA("Model") and not table.find(out, item.Name) then
                table.insert(out, item.Name)
            end
        end
        table.sort(out)
        return out
    end

    local function findFurnitureByName(name)
        local root = Workspace:FindFirstChild("Wyposazenie")
        if not root then return nil end
        for _, item in ipairs(root:GetChildren()) do
            if item:IsA("Folder") then
                for _, interno in ipairs(item:GetChildren()) do
                    if interno:IsA("Model") and interno.Name == name then
                        return interno
                    end
                end
            elseif item:IsA("Model") and item.Name == name then
                return item
            end
        end
        return nil
    end

    -- Noclip
    do
        local noclipConn = nil
        Main:CreateToggle({
            Name = "Noclip",
            CurrentValue = false,
            Callback = function(state)
                if state then
                    if noclipConn then noclipConn:Disconnect() end
                    noclipConn = RunService.Stepped:Connect(function()
                        local c = player.Character
                        if c then
                            for _, part in ipairs(c:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                    safeNotify("Noclip", "Enabled", 2)
                else
                    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
                    safeNotify("Noclip", "Disabled", 2)
                end
            end
        })
    end

    -- WalkSpeed box (validate number)
    Main:CreateBox({
        Name = "WalkSpeed",
        Placeholder = "Enter number (e.g. 16)",
        Callback = function(val, focusLost)
            if not focusLost then return end
            local num = tonumber(val)
            if num and num > 0 and num < 1000 then
                local h = safeGetHum()
                if h then h.WalkSpeed = num end
                safeNotify("WalkSpeed set", tostring(num), 1.5)
            else
                safeNotify("Invalid value", "Enter a valid number", 2)
            end
        end
    })

    -- Collect All Food (safe, uses ProximityPrompt where available; returns player to original pos)
    Main:CreateButton({
        Name = "Collect All Food",
        Callback = function()
            spawn(function()
                local c = waitChar()
                local hrpNow = safeGetHRP()
                if not hrpNow then safeNotify("No HRP", nil, 2); return end
                local lastC = hrpNow.CFrame
                -- gather tools and models with Handle + proximity
                for _, child in ipairs(Workspace:GetChildren()) do
                    if child:IsA("Tool") or (child:IsA("Model") and child:FindFirstChild("Handle")) then
                        local handle = child:FindFirstChild("Handle") or child.PrimaryPart
                        local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                        if handle then
                            -- move near, trigger prompt if it exists
                            pcall(function()
                                hrpNow.CFrame = handle.CFrame * CFrame.new(0,5,0)
                                task.wait(0.18)
                                if prompt then
                                    -- safe prompt fire
                                    pcall(function() prompt:InputHoldBegin(); task.wait(0.03); prompt:InputHoldEnd() end)
                                    pcall(function() fireproximityprompt(prompt) end)
                                end
                                task.wait(0.06)
                            end)
                        end
                    end
                end
                task.wait(0.25)
                pcall(function() hrpNow.CFrame = lastC end)
                safeNotify("Collect All Food", "Done", 2)
            end)
        end
    })

    -- Drop All Food (move items to character -> kill -> respawn at same pos)
    Main:CreateButton({
        Name = "Drop All Food",
        Callback = function()
            spawn(function()
                local c = waitChar()
                local hrpNow = safeGetHRP()
                if not hrpNow then safeNotify("No HRP", nil, 2); return end
                local lastC = hrpNow.CFrame
                -- move all from backpack to character (so they drop on death if game behavior does)
                for _, it in ipairs(player:WaitForChild("Backpack"):GetChildren()) do
                    pcall(function() it.Parent = player.Character end)
                    task.wait(0.03)
                end
                task.wait(0.25)
                -- kill safely
                pcall(function() local hv = safeGetHum(); if hv then hv.Health = 0 end end)
                -- on respawn, try to teleport to last pos
                spawn(function()
                    local newChar = player.Character or player.CharacterAdded:Wait()
                    local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
                    if newHrp then
                        task.wait(0.6)
                        pcall(function() newHrp.CFrame = lastC end)
                    end
                end)
                safeNotify("Drop All Food", "Completed", 2)
            end)
        end
    })

    -- Furniture dropdown & bring action (uses server PickupItemEvent if exists)
    local furnitureList = findFurnitureNames()
    local selectedFurniture = nil
    Main:CreateDropdown({
        Name = "Select Furniture",
        Options = furnitureList,
        CurrentOption = furnitureList[1],
        MultipleOptions = false,
        Callback = function(option) selectedFurniture = option end
    })

    Main:CreateButton({
        Name = "Bring Selected Furniture",
        Callback = function()
            if not selectedFurniture then safeNotify("No selection", nil, 2); return end
            local target = findFurnitureByName(selectedFurniture)
            if not target then safeNotify("Not found", selectedFurniture, 2); return end
            -- prefer server event
            if PickupItemEvent then
                pcall(function() PickupItemEvent:FireServer(target) end)
                safeNotify("Requested", "Pickup event fired (server)", 2)
            else
                -- fallback: try to call ReplicatedStorage.PickupItemEvent if present
                local alt = ReplicatedStorage:FindFirstChild("PickupItemEvent") or ReplicatedStorage:FindFirstChild("PickupItem")
                if alt and alt:IsA("RemoteEvent") then
                    pcall(function() alt:FireServer(target) end)
                    safeNotify("Requested", "Pickup event fired (alt)", 2)
                else
                    safeNotify("No server event", "Can't request pickup", 2)
                end
            end
        end
    })

    -- Sound Spam toggle (uses ReplicatedStorage.SoundEvent if present)
    do
        local soundSpam = false
        local spamConn = nil
        Main:CreateToggle({
            Name = "Sound Spam (Drink/Eat)",
            CurrentValue = false,
            Callback = function(state)
                soundSpam = state
                if soundSpam then
                    if not SoundEvent then SoundEvent = ReplicatedStorage:FindFirstChild("SoundEvent") end
                    spamConn = task.spawn(function()
                        while soundSpam do
                            if SoundEvent and SoundEvent:IsA("RemoteEvent") then
                                pcall(function() SoundEvent:FireServer("Drink") end)
                                pcall(function() SoundEvent:FireServer("Eat") end)
                            end
                            task.wait(0.5)
                        end
                    end)
                    safeNotify("Sound Spam", "Started", 1.5)
                else
                    soundSpam = false
                    safeNotify("Sound Spam", "Stopped", 1.5)
                end
            end
        })
    end

    -- Monsters ESP (Highlight)
    do
        local espEnabled = false
        local espTask = nil
        ESPtab:CreateToggle({
            Name = "Monsters ESP",
            CurrentValue = false,
            Callback = function(state)
                espEnabled = state
                if espEnabled then
                    espTask = RunService.Heartbeat:Connect(function()
                        local nightFolder = findNightFolder()
                        if nightFolder then
                            for _, lurker in ipairs(nightFolder:GetChildren()) do
                                if lurker:IsA("Model") and lurker:FindFirstChild("HumanoidRootPart") then
                                    if not lurker:FindFirstChild("DN_Highlight") then
                                        local h = Instance.new("Highlight")
                                        h.Name = "DN_Highlight"
                                        h.Parent = lurker
                                    end
                                end
                            end
                        end
                    end)
                    safeNotify("ESP", "Enabled", 1.5)
                else
                    if espTask then espTask:Disconnect(); espTask = nil end
                    -- cleanup
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("Highlight") and v.Name == "DN_Highlight" then
                            pcall(function() v:Destroy() end)
                        end
                    end
                    safeNotify("ESP", "Disabled", 1.5)
                end
            end
        })
    end

    -- Teleports
    Teleport:CreateButton({
        Name = "To Bunker (Assigned)",
        Callback = function()
            bunkerName = player:GetAttribute("AssignedBunkerName")
            if not bunkerName then safeNotify("No Bunker assigned", nil, 2); return end
            local bunkers = Workspace:FindFirstChild("Bunkers")
            if not bunkers then safeNotify("No Bunkers folder", nil, 2); return end
            local bunker = bunkers:FindFirstChild(bunkerName)
            if not bunker then safeNotify("Bunker not found", bunkerName, 2); return end
            local spawnPart = bunker:FindFirstChild("SpawnLocation") or bunker:FindFirstChildWhichIsA("BasePart")
            if spawnPart and safeGetHRP() then
                safeGetHRP().CFrame = spawnPart.CFrame
            else
                safeNotify("No spawn found", nil, 2)
            end
        end
    })

    Teleport:CreateButton({
        Name = "To Market",
        Callback = function()
            local hr = safeGetHRP()
            if hr then hr.CFrame = CFrame.new(143,5,-118) end
        end
    })

    Teleport:CreateBox({
        Name = "Teleport To Player",
        Placeholder = "player name or partial",
        Callback = function(txt, focusLost)
            if not focusLost then return end
            local q = tostring(txt):lower()
            for _, pl in ipairs(Players:GetPlayers()) do
                if string.find(pl.Name:lower(), q) or string.find(pl.DisplayName:lower(), q) then
                    if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        safeGetHRP().CFrame = pl.Character.HumanoidRootPart.CFrame
                        safeNotify("Teleported", pl.Name, 1.5)
                        return
                    end
                end
            end
            safeNotify("Player not found", txt, 2)
        end
    })

    -- Quick Utilities
    Main:CreateButton({
        Name = "Collect All Food (fast scan)",
        Callback = function()
            spawn(function()
                local hr = safeGetHRP()
                if not hr then safeNotify("No HRP", nil, 2); return end
                local old = hr.CFrame
                for _, f in ipairs(Workspace:GetChildren()) do
                    if f:IsA("Tool") or (f:IsA("Model") and f:FindFirstChild("Handle")) then
                        local handle = f:FindFirstChild("Handle") or f.PrimaryPart
                        if handle then
                            pcall(function()
                                hr.CFrame = handle.CFrame * CFrame.new(0,5,0)
                                task.wait(0.14)
                                local prompt = handle:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then
                                    pcall(function() prompt:InputHoldBegin(); task.wait(0.03); prompt:InputHoldEnd() end)
                                    pcall(function() fireproximityprompt(prompt) end)
                                end
                                task.wait(0.05)
                            end)
                        end
                    end
                end
                task.wait(0.15)
                pcall(function() hr.CFrame = old end)
                safeNotify("Collect All Food", "Done", 1.5)
            end)
        end
    })

    Main:CreateButton({
        Name = "Drop All Inventory (move & die)",
        Callback = function()
            spawn(function()
                local hr = safeGetHRP()
                if not hr then safeNotify("No HRP", nil, 2); return end
                local last = hr.CFrame
                for _, it in ipairs(player.Backpack:GetChildren()) do
                    pcall(function() it.Parent = player.Character end)
                    task.wait(0.03)
                end
                task.wait(0.15)
                pcall(function() local hv = safeGetHum(); if hv then hv.Health = 0 end end)
                -- attempt to teleport to last pos on respawn
                spawn(function()
                    player.CharacterAdded:Wait()
                    local newChar = player.Character or player.CharacterAdded:Wait()
                    local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
                    if newHrp then task.wait(0.6); pcall(function() newHrp.CFrame = last end) end
                end)
                safeNotify("Drop All", "Completed", 1.5)
            end)
        end
    })

    -- Destroy GUI
    Settings:CreateButton({
        Name = "Destroy UI",
        Callback = function()
            pcall(function() Rayfield:Destroy() end)
        end
    })

    -- Keybind to toggle Rayfield visibility (LeftControl)
    Rayfield:Keybind({
        Name = "Toggle UI (LeftControl)",
        CurrentKeybind = "LeftControl",
        Flag = "toggle_ui",
        Callback = function()
            -- Rayfield handles toggle automatically; this ensures it exists
        end
    })

    safeNotify("Loaded", "Dangerous Night — Rayfield Enhanced", 3)
end)

if not ok then
    warn("Failed to initialize enhanced script:", err)
    -- attempt minimal Rayfield error window
    pcall(function()
        local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
        local w = Rayfield:CreateWindow({Name="DN Error", LoadingTitle="Error", LoadingSubtitle=tostring(err), ConfigurationSaving={Enabled=false}})
        local t = w:CreateTab("Error")
        t:CreateLabel("See Output for details: "..tostring(err))
    end)
end
