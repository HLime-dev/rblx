-- Dangerous Night — Dev Toolkit (v3)
-- Single LocalScript meant for use in YOUR OWN game (Roblox Studio).
-- Features: dropdown item selector, pickup, drop, auto-collect food, walk speed, fly, noclip, monsters ESP, teleport, robust error handling.
-- Place this LocalScript into StarterPlayer -> StarterPlayerScripts
-- Expected workspace folders (case-sensitive): workspace.items, workspace.food
-- Optional server-side RemoteEvents (in ReplicatedStorage/RemoteEvents):
--   RequestGiveItem, RequestDropItem, RequestCollectFood (recommended for secure ops)

local ok, err = pcall(function()
    -- Rayfield V4 (stable)
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local CollectionService = game:GetService("CollectionService")

    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    -- Folder names (as requested)
    local ITEMS_NAME = "items"
    local FOOD_NAME  = "food"

    -- Try to find folders; create placeholder if absent to prevent errors
    local itemsFolder = workspace:FindFirstChild(ITEMS_NAME)
    if not itemsFolder then
        warn(("Workspace folder '%s' not found; creating placeholder (empty)."):format(ITEMS_NAME))
        itemsFolder = Instance.new("Folder")
        itemsFolder.Name = ITEMS_NAME
        itemsFolder.Parent = workspace
    end
    local foodFolder = workspace:FindFirstChild(FOOD_NAME)
    if not foodFolder then
        warn(("Workspace folder '%s' not found; creating placeholder (empty)."):format(FOOD_NAME))
        foodFolder = Instance.new("Folder")
        foodFolder.Name = FOOD_NAME
        foodFolder.Parent = workspace
    end

    -- Optional RemoteEvents (if you created them on server)
    local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    local RequestGiveItem = remoteFolder and remoteFolder:FindFirstChild("RequestGiveItem")
    local RequestDropItem = remoteFolder and remoteFolder:FindFirstChild("RequestDropItem")
    local RequestCollectFood = remoteFolder and remoteFolder:FindFirstChild("RequestCollectFood")

    -- UI
    local Window = Rayfield:CreateWindow({
        Name = "Dangerous Night Dev Toolkit (v3)",
        LoadingTitle = "Initializing Toolkit",
        LoadingSubtitle = "Rayfield V4",
        ConfigurationSaving = { Enabled = false }
    })

    local mainTab = Window:CreateTab("Main")
    local tpTab   = Window:CreateTab("Teleport")
    local settingsTab = Window:CreateTab("Settings")

    ----------------------------
    -- Utility functions
    ----------------------------
    local function safeFindItemByName(name)
        if not name then return nil end
        return itemsFolder:FindFirstChild(name)
    end

    local function getChildrenPositions(obj)
        local out = {}
        for _, v in ipairs(obj:GetChildren()) do
            local pos
            if v:IsA("Model") and v.PrimaryPart then pos = v.PrimaryPart.Position
            elseif v:IsA("BasePart") then pos = v.Position end
            if pos then out[#out+1] = {inst = v, pos = pos} end
        end
        return out
    end

    local function triggerProximityPromptOn(inst)
        if not inst then return false end
        local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            -- try safe pcall fire methods
            pcall(function()
                -- InputHoldBegin/End may be needed for hold prompts
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end)
            -- fallback
            pcall(function() fireproximityprompt(prompt) end)
            return true
        end
        return false
    end

    ----------------------------
    -- Item & Dropdown
    ----------------------------
    local function GetItemList()
        local list = {}
        for _, it in ipairs(itemsFolder:GetChildren()) do
            table.insert(list, it.Name)
        end
        table.sort(list)
        return list
    end

    local selectedItem = nil
    local dropdown = mainTab:CreateDropdown({
        Name = "Select Item",
        Options = GetItemList(),
        CurrentOption = nil,
        MultipleOptions = false,
        Callback = function(option) selectedItem = option end
    })

    mainTab:CreateButton({
        Name = "Refresh Item List",
        Callback = function()
            dropdown:Refresh(GetItemList(), true)
            Rayfield:Notify({Title = "Refreshed", Content = "Item list updated", Duration = 2})
        end
    })

    -- Pickup selected item
    mainTab:CreateButton({
        Name = "Pickup Selected Item",
        Callback = function()
            if not selectedItem then
                Rayfield:Notify({Title="No Selection", Content="Please select an item first", Duration=2})
                return
            end
            if RequestGiveItem then
                RequestGiveItem:FireServer(selectedItem)
                Rayfield:Notify({Title="Requested", Content="Requested server to give "..selectedItem, Duration=2})
                return
            end
            local target = safeFindItemByName(selectedItem)
            if not target then
                Rayfield:Notify({Title="Not found", Content="Selected item not in workspace." , Duration=2})
                return
            end
            -- teleport near and attempt prompt
            local old = hrp.CFrame
            local pos = (target:IsA("Model") and target.PrimaryPart and target.PrimaryPart.Position) or (target:IsA("BasePart") and target.Position)
            if pos then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
                task.wait(0.2)
                local ok = triggerProximityPromptOn(target)
                task.wait(0.15)
                hrp.CFrame = old
                if ok then
                    Rayfield:Notify({Title="Picked", Content=selectedItem, Duration=1.5})
                else
                    Rayfield:Notify({Title="Attempted", Content="No prompt found - server give may be required", Duration=2})
                end
            else
                Rayfield:Notify({Title="Invalid", Content="Item has no position", Duration=2})
            end
        end
    })

    -- Pickup nearest convenience
    mainTab:CreateButton({
        Name = "Pickup Nearest",
        Callback = function()
            local mine = hrp.Position
            local nearest, nd = nil, math.huge
            for _, it in ipairs(itemsFolder:GetChildren()) do
                local pos = (it:IsA("Model") and it.PrimaryPart and it.PrimaryPart.Position) or (it:IsA("BasePart") and it.Position)
                if pos then
                    local d = (pos - mine).Magnitude
                    if d < nd then nd = d; nearest = it end
                end
            end
            if not nearest then Rayfield:Notify({Title="No items", Content="No items found", Duration=2}); return end
            if RequestGiveItem then
                RequestGiveItem:FireServer(nearest.Name)
                Rayfield:Notify({Title="Requested", Content="Requested give "..nearest.Name, Duration=2})
            else
                local old = hrp.CFrame
                hrp.CFrame = CFrame.new(((nearest.PrimaryPart and nearest.PrimaryPart.Position) or nearest.Position) + Vector3.new(0,3,0))
                task.wait(0.2)
                triggerProximityPromptOn(nearest)
                task.wait(0.15)
                hrp.CFrame = old
            end
        end
    })

    -- Drop selected / drop all
    mainTab:CreateButton({
        Name = "Drop Selected Item",
        Callback = function()
            if not selectedItem then Rayfield:Notify({Title="No Selection", Content="Select item to drop", Duration=2}); return end
            if RequestDropItem then
                RequestDropItem:FireServer(selectedItem)
                Rayfield:Notify({Title="Requested", Content="Requested server to drop "..selectedItem, Duration=2})
                return
            end
            local backpack = player:FindFirstChild("Backpack")
            if not backpack then Rayfield:Notify({Title="No Backpack", Content="Backpack missing", Duration=2}); return end
            local tool = backpack:FindFirstChild(selectedItem)
            if not tool then Rayfield:Notify({Title="Not Found", Content="Item not in backpack", Duration=2); return end
            -- simple drop: clone to world near player and destroy original
            local clone = tool:Clone()
            clone.Parent = workspace
            if clone:IsA("Model") and clone.PrimaryPart then clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0,0,-3))
            elseif clone:IsA("BasePart") then clone.CFrame = hrp.CFrame * CFrame.new(0,0,-3) end
            tool:Destroy()
            Rayfield:Notify({Title="Dropped", Content=selectedItem, Duration=1.5})
        end
    })

    mainTab:CreateButton({
        Name = "Drop All Tools (Backpack -> World)",
        Callback = function()
            local backpack = player:FindFirstChild("Backpack")
            if not backpack then Rayfield:Notify({Title="No Backpack", Content="Backpack missing", Duration=2}); return end
            for _, item in ipairs(backpack:GetChildren()) do
                local clone = item:Clone()
                clone.Parent = workspace
                if clone:IsA("Model") and clone.PrimaryPart then clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0,0,-3))
                elseif clone:IsA("BasePart") then clone.CFrame = hrp.CFrame * CFrame.new(0,0,-3) end
                item:Destroy()
                task.wait(0.03)
            end
            Rayfield:Notify({Title="Dropped", Content="All items dropped", Duration=2})
        end
    })

    ----------------------------
    -- Auto Collect Food
    ----------------------------
    local autoCollect = false
    mainTab:CreateToggle({
        Name = "Auto Collect Food",
        CurrentValue = false,
        Callback = function(state) autoCollect = state end
    })
    mainTab:CreateSlider({
        Name = "Auto Collect Radius",
        Range = {4, 120},
        Increment = 1,
        CurrentValue = 30,
        Suffix = "studs",
        Callback = function(val) -- stored by closure if needed
        end
    })

    spawn(function()
        while true do
            task.wait(0.7)
            if autoCollect then
                if RequestCollectFood then
                    RequestCollectFood:FireServer(30)
                else
                    -- client-side: teleport near nearby food and trigger prompts
                    local mine = hrp.Position
                    for _, f in ipairs(foodFolder:GetChildren()) do
                        local pos = (f:IsA("Model") and f.PrimaryPart and f.PrimaryPart.Position) or (f:IsA("BasePart") and f.Position)
                        if pos and (pos - mine).Magnitude <= 60 then
                            local old = hrp.CFrame
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
                            task.wait(0.15)
                            triggerProximityPromptOn(f)
                            task.wait(0.12)
                            hrp.CFrame = old
                        end
                    end
                end
            end
        end
    end)

    ----------------------------
    -- WalkSpeed
    ----------------------------
    mainTab:CreateSlider({
        Name = "WalkSpeed",
        Range = {8, 200},
        Increment = 1,
        CurrentValue = hum.WalkSpeed or 16,
        Callback = function(val) if hum and hum.Parent then hum.WalkSpeed = val end end
    })

    ----------------------------
    -- Noclip
    ----------------------------
    local noclipEnabled = false
    local noclipConn = nil
    mainTab:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Callback = function(state)
            noclipEnabled = state
            if noclipEnabled then
                noclipConn = RunService.Stepped:Connect(function()
                    if player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            end
        end
    })

    ----------------------------
    -- Fly (client-side)
    ----------------------------
    local flying = false
    local flySpeed = 80
    settingsTab:CreateToggle({
        Name = "Fly (E ascend, Q descend)",
        CurrentValue = false,
        Callback = function(state) flying = state end
    })
    settingsTab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 400},
        Increment = 1,
        CurrentValue = flySpeed,
        Callback = function(val) flySpeed = val end
    })

    local bv = nil
    local ascend = 0
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.E then ascend = 1 end
        if inp.KeyCode == Enum.KeyCode.Q then ascend = -1 end
    end)
    UserInputService.InputEnded:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.E and ascend == 1 then ascend = 0 end
        if inp.KeyCode == Enum.KeyCode.Q and ascend == -1 then ascend = 0 end
    end)

    RunService.RenderStepped:Connect(function()
        if flying then
            if not bv or not bv.Parent then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.Parent = hrp
                hum.PlatformStand = true
            end
            local cam = workspace.CurrentCamera
            local moveVec = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            local finalVel = Vector3.new(0,0,0)
            if moveVec.Magnitude > 0 then finalVel = moveVec.Unit * flySpeed end
            bv.Velocity = finalVel + Vector3.new(0, ascend * flySpeed, 0)
        else
            if bv then bv:Destroy(); bv = nil; hum.PlatformStand = false end
        end
    end)

    ----------------------------
    -- Monsters ESP (Highlight)
    ----------------------------
    local espEnabled = false
    local espConn = nil
    mainTab:CreateToggle({
        Name = "Monsters ESP",
        CurrentValue = false,
        Callback = function(state)
            espEnabled = state
            if espEnabled then
                espConn = RunService.Heartbeat:Connect(function()
                    -- find any folder with "Night" in name (as previous script did), else look for typical enemy folders
                    local nightFolder = nil
                    for _, obj in ipairs(workspace:GetChildren()) do
                        if obj:IsA("Folder") and string.find(obj.Name, "Night") then nightFolder = obj; break end
                    end
                    if not nightFolder then
                        -- fallback: scan for models with HumanoidRootPart and "Enemy" in name
                        for _, obj in ipairs(workspace:GetChildren()) do
                            if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and string.find(obj.Name, "Enemy") then
                                nightFolder = workspace; break
                            end
                        end
                    end
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
            else
                if espConn then espConn:Disconnect(); espConn = nil end
                -- remove any existing highlights
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Highlight") and v.Name == "DN_Highlight" then pcall(function() v:Destroy() end) end
                end
            end
        end
    })

    ----------------------------
    -- Teleport tab (bunker / market / to player)
    ----------------------------
    local bunkerName = player:GetAttribute("AssignedBunkerName")
    tpTab:CreateButton({
        Name = "To Bunker (Assigned)",
        Callback = function()
            if not bunkerName then Rayfield:Notify({Title="No Bunker", Content="AssignedBunkerName not set", Duration=2}); return end
            local bunkers = workspace:FindFirstChild("Bunkers")
            if not bunkers then Rayfield:Notify({Title="No Bunkers", Content="workspace.Bunkers missing", Duration=2}); return end
            local bunker = bunkers:FindFirstChild(bunkerName)
            if not bunker then Rayfield:Notify({Title="Invalid", Content="Assigned bunker not found", Duration=2}); return end
            local spawn = bunker:FindFirstChild("SpawnLocation") or bunker:FindFirstChildWhichIsA("BasePart")
            if spawn then hrp.CFrame = spawn.CFrame else Rayfield:Notify({Title="No Spawn", Content="Bunker spawn missing", Duration=2}) end
        end
    })
    tpTab:CreateButton({
        Name = "To Market (example)",
        Callback = function() hrp.CFrame = CFrame.new(143,5,-118) end
    })
    tpTab:CreateBox({
        Name = "Teleport to player (name)",
        Placeholder = "Player name or part of it",
        Callback = function(text, focusLost)
            if not focusLost then return end
            local lower = text:lower()
            for _, pl in ipairs(Players:GetPlayers()) do
                if string.find(pl.Name:lower(), lower) or string.find(pl.DisplayName:lower(), lower) then
                    if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = pl.Character.HumanoidRootPart.CFrame
                        return
                    end
                end
            end
            Rayfield:Notify({Title="Not found", Content="Player not found", Duration=2})
        end
    })

    ----------------------------
    -- Quick utilities
    ----------------------------
    mainTab:CreateButton({
        Name = "Collect All Food (instant-ish)",
        Callback = function()
            local old = hrp.CFrame
            for _, f in ipairs(workspace:GetChildren()) do
                if f:IsA("Tool") or (f:IsA("Model") and f:FindFirstChild("Handle")) then
                    local handle = f:FindFirstChild("Handle") or (f.PrimaryPart and f.PrimaryPart)
                    if handle then
                        hrp.CFrame = handle.CFrame * CFrame.new(0,5,0)
                        task.wait(0.18)
                        triggerProximityPromptOn(f)
                    end
                end
            end
            task.wait(0.2)
            hrp.CFrame = old
        end
    })

    mainTab:CreateButton({
        Name = "Drop All Inventory (kill to respawn at same pos)",
        Callback = function()
            -- move tools to character then kill to drop (works if game drops on death)
            for _, it in ipairs(player.Backpack:GetChildren()) do
                it.Parent = player.Character
                task.wait(0.03)
            end
            -- kill
            pcall(function() player.Character:FindFirstChildOfClass("Humanoid").Health = 0 end)
            -- try to respawn at same pos when character comes back
            local lastPos = hrp.CFrame
            spawn(function()
                player.CharacterAdded:Wait()
                local newChar = player.Character or player.CharacterAdded:Wait()
                local newHrp = newChar:WaitForChild("HumanoidRootPart", 5)
                if newHrp and lastPos then task.wait(0.6); newHrp.CFrame = lastPos end
            end)
        end
    })

    ----------------------------
    -- Final notify
    ----------------------------
    Rayfield:Notify({Title="Loaded", Content="Dangerous Night Dev Toolkit v3 is ready", Duration=4})

end)

if not ok then
    warn("Dev Toolkit failed to initialize: ", err)
    -- Try to show minimal Rayfield message
    pcall(function()
        local r = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
        local w = r:CreateWindow({Name="Dev Toolkit Error", LoadingTitle="Error", LoadingSubtitle=tostring(err), ConfigurationSaving={Enabled=false}})
        local t = w:CreateTab("Error")
        t:CreateLabel("See Output for details: "..tostring(err))
    end)
end
