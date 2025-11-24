-- Dangerous Night Developer Panel (Updated, Rayfield V4)
-- Put this LocalScript into StarterPlayer > StarterPlayerScripts
-- Folders expected: workspace.items, workspace.food  (case-sensitive as you specified)

local success, err = pcall(function()

    -- Rayfield V4 (stable source)
    local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")

    -- Use the exact folder names you gave: "items" and "food"
    local ITEMS_NAME = "items"
    local FOOD_NAME = "food"

    -- Try to find folders; if they don't exist, warn but keep script running
    local itemsFolder = workspace:FindFirstChild(ITEMS_NAME)
    local foodFolder = workspace:FindFirstChild(FOOD_NAME)

    if not itemsFolder then
        warn(("Folder '%s' not found in workspace. Create a Folder named '%s' and put pickup items there."):format(ITEMS_NAME, ITEMS_NAME))
        -- create a local placeholder so script won't error (won't replicate to server)
        itemsFolder = Instance.new("Folder")
        itemsFolder.Name = ITEMS_NAME
        itemsFolder.Parent = workspace -- attempt to create; if client can't create, it still prevents errors locally
    end

    if not foodFolder then
        warn(("Folder '%s' not found in workspace. Create a Folder named '%s' and put food items there."):format(FOOD_NAME, FOOD_NAME))
        foodFolder = Instance.new("Folder")
        foodFolder.Name = FOOD_NAME
        foodFolder.Parent = workspace
    end

    -- Optional RemoteEvents if you set them on server for secure operations
    local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    local RequestGiveItem = remoteFolder and remoteFolder:FindFirstChild("RequestGiveItem") or nil
    local RequestDropItem = remoteFolder and remoteFolder:FindFirstChild("RequestDropItem") or nil
    local RequestCollectFood = remoteFolder and remoteFolder:FindFirstChild("RequestCollectFood") or nil

    -- UI Setup
    local Window = Rayfield:CreateWindow({
        Name = "Dangerous Night Developer Panel",
        LoadingTitle = "Initializing…",
        LoadingSubtitle = "Developer Tools (V4)",
        ConfigurationSaving = { Enabled = false }
    })

    local Tab = Window:CreateTab("Main")

    -- Utility: get item names (only direct children)
    local function GetItemList()
        local out = {}
        for _, v in ipairs(itemsFolder:GetChildren()) do
            table.insert(out, v.Name)
        end
        table.sort(out)
        return out
    end

    local selectedItem = nil

    local dropdown = Tab:CreateDropdown({
        Name = "Select Item",
        Options = GetItemList(),
        CurrentOption = nil,
        MultipleOptions = false,
        Callback = function(option)
            selectedItem = option
        end
    })

    Tab:CreateButton({
        Name = "Refresh Items",
        Callback = function()
            dropdown:Refresh(GetItemList(), true)
            Rayfield:Notify({ Title = "Refreshed", Content = "Item list updated", Duration = 2 })
        end
    })

    -- Helper: find object by name safely
    local function FindItemByName(name)
        if not name then return nil end
        return itemsFolder:FindFirstChild(name)
    end

    -- Helper: trigger proximity prompt (safe)
    local function TriggerPrompt(target)
        if not target then return false end
        local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            -- fire local prompt (works if prompt is set to be triggerable by client)
            local ok, e = pcall(function() prompt:InputHoldBegin() prompt:InputHoldEnd() end)
            if not ok then
                -- fallback
                pcall(function() fireproximityprompt(prompt) end)
            end
            return true
        else
            return false
        end
    end

    -- PICKUP selected item: try remote if available, else try teleport+prompt
    Tab:CreateButton({
        Name = "Pickup Selected Item",
        Callback = function()
            if not selectedItem then
                Rayfield:Notify({ Title = "No item", Content = "Please select an item first", Duration = 2 })
                return
            end

            if RequestGiveItem then
                -- Ask server to give the item (recommended for secure ops)
                RequestGiveItem:FireServer(selectedItem)
                Rayfield:Notify({ Title = "Requested", Content = "Asked server to give item: "..selectedItem, Duration = 2 })
                return
            end

            local target = FindItemByName(selectedItem)
            if not target then
                Rayfield:Notify({ Title = "Not found", Content = "Item not found in workspace.items", Duration = 2 })
                return
            end

            -- attempt local pickup: teleport near and trigger prompt if exists
            local pos = nil
            if target:IsA("Model") and target.PrimaryPart then pos = target.PrimaryPart.Position
            elseif target:IsA("BasePart") then pos = target.Position
            end

            if pos then
                local oldCFrame = hrp.CFrame
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                task.wait(0.25)
                local ok = TriggerPrompt(target)
                task.wait(0.2)
                hrp.CFrame = oldCFrame
                if ok then
                    Rayfield:Notify({ Title = "Picked", Content = selectedItem, Duration = 2 })
                else
                    Rayfield:Notify({ Title = "Tried", Content = "No prompt found — item may require server give", Duration = 2 })
                end
            else
                Rayfield:Notify({ Title = "Invalid", Content = "Item has no position", Duration = 2 })
            end
        end
    })

    -- Pickup nearest convenience
    Tab:CreateButton({
        Name = "Pickup Nearest Item",
        Callback = function()
            local hrppos = hrp.Position
            local nearest, nd = nil, math.huge
            for _, it in ipairs(itemsFolder:GetChildren()) do
                local pos
                if it:IsA("Model") and it.PrimaryPart then pos = it.PrimaryPart.Position
                elseif it:IsA("BasePart") then pos = it.Position end
                if pos then
                    local d = (pos - hrppos).Magnitude
                    if d < nd then nd = d; nearest = it end
                end
            end
            if nearest then
                -- try remote give first
                if RequestGiveItem then
                    RequestGiveItem:FireServer(nearest.Name)
                    Rayfield:Notify({ Title = "Requested", Content = "Give "..nearest.Name, Duration = 2 })
                else
                    local old = hrp.CFrame
                    hrp.CFrame = CFrame.new((nearest.PrimaryPart and nearest.PrimaryPart.Position or nearest.Position) + Vector3.new(0,3,0))
                    task.wait(.2)
                    TriggerPrompt(nearest)
                    task.wait(.15)
                    hrp.CFrame = old
                end
            else
                Rayfield:Notify({ Title = "No items", Content = "No items in workspace.items", Duration = 2 })
            end
        end
    })

    -- DROP selected: try server RemoteEvent, else attempt to move any tool from Backpack to workspace
    Tab:CreateButton({
        Name = "Drop Selected Item",
        Callback = function()
            if not selectedItem then
                Rayfield:Notify({ Title = "No item", Content = "Select an item to drop", Duration = 2 })
                return
            end

            if RequestDropItem then
                RequestDropItem:FireServer(selectedItem)
                Rayfield:Notify({ Title = "Requested", Content = "Asked server to drop "..selectedItem, Duration = 2 })
                return
            end

            -- fallback: look for tool in backpack
            local backpack = player:FindFirstChild("Backpack")
            local tool = backpack and backpack:FindFirstChild(selectedItem)
            if tool then
                local clone = tool:Clone()
                clone.Parent = workspace
                if clone:IsA("Model") and clone.PrimaryPart then
                    clone:SetPrimaryPartCFrame(hrp.CFrame * CFrame.new(0,0,-3))
                elseif clone:IsA("BasePart") then
                    clone.CFrame = hrp.CFrame * CFrame.new(0,0,-3)
                end
                tool:Destroy()
                Rayfield:Notify({ Title = "Dropped", Content = selectedItem, Duration = 2 })
            else
                Rayfield:Notify({ Title = "Not found", Content = "Item not in your Backpack", Duration = 2 })
            end
        end
    })

    -- Speed slider
    Tab:CreateSlider({
        Name = "Walk Speed",
        Range = {8, 200},
        Increment = 1,
        CurrentValue = hum.WalkSpeed or 16,
        Suffix = "studs/s",
        Callback = function(val)
            if hum and hum.Parent then hum.WalkSpeed = val end
        end
    })

    -- Fly
    local flying = false
    local flySpeed = 60
    Tab:CreateToggle({
        Name = "Fly (WASD, Space up, LShift down)",
        CurrentValue = false,
        Callback = function(state)
            flying = state
            if not state then
                -- stop
                pcall(function() hum.PlatformStand = false end)
            end
        end
    })

    Tab:CreateSlider({
        Name = "Fly Speed",
        Range = {10, 300},
        Increment = 1,
        CurrentValue = flySpeed,
        Callback = function(v) flySpeed = v end
    })

    -- Fly loop (client-side)
    local bv = nil
    local asc = 0
    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.E then asc = 1 end
        if inp.KeyCode == Enum.KeyCode.Q then asc = -1 end
    end)
    UserInputService.InputEnded:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.E and asc == 1 then asc = 0 end
        if inp.KeyCode == Enum.KeyCode.Q and asc == -1 then asc = 0 end
    end)

    RunService.RenderStepped:Connect(function()
        if flying then
            if not bv or not bv.Parent then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.Velocity = Vector3.new(0,0,0)
                bv.Parent = hrp
                hum.PlatformStand = true
            end
            local cam = workspace.CurrentCamera
            local moveVec = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            local vertical = asc
            local finalVel = (moveVec.Unit ~= moveVec.Unit) and (moveVec * flySpeed) or (moveVec.Unit * flySpeed)
            if moveVec.Magnitude == 0 then finalVel = Vector3.new(0,0,0) end
            bv.Velocity = finalVel + Vector3.new(0, vertical * flySpeed, 0)
        else
            if bv then bv:Destroy(); bv = nil end
        end
    end)

    -- Auto collect food: prefer server RemoteEvent; fallback to teleport+prompt
    local autoCollect = false
    Tab:CreateToggle({
        Name = "Auto Collect Food",
        CurrentValue = false,
        Callback = function(v) autoCollect = v end
    })

    Tab:CreateSlider({
        Name = "Collect Radius (client-side scan)",
        Range = {4, 120},
        Increment = 1,
        CurrentValue = 20,
        Callback = function(val) end
    })

    spawn(function()
        while true do
            task.wait(0.8)
            if autoCollect then
                if RequestCollectFood then
                    RequestCollectFood:FireServer(20) -- ask server to collect within 20 studs
                else
                    for _, f in ipairs(foodFolder:GetChildren()) do
                        local pos
                        if f:IsA("Model") and f.PrimaryPart then pos = f.PrimaryPart.Position
                        elseif f:IsA("BasePart") then pos = f.Position end
                        if pos and (pos - hrp.Position).Magnitude <= 50 then
                            local old = hrp.CFrame
                            hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
                            task.wait(0.15)
                            TriggerPrompt(f)
                            task.wait(0.1)
                            hrp.CFrame = old
                        end
                    end
                end
            end
        end
    end)

    -- Notify loaded
    Rayfield:Notify({ Title = "Loaded", Content = "Developer panel ready (items, food)", Duration = 4 })

end)

if not success then
    warn("Script failed to initialize: ", err)
    -- Try minimal Rayfield check so UI isn't totally blank
    local ok, _ = pcall(function()
        local r = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
        local w = r:CreateWindow({ Name = "Dangerous Night Dev Panel (Error)"; LoadingTitle = "Error"; LoadingSubtitle = tostring(err); ConfigurationSaving = { Enabled = false } })
        local t = w:CreateTab("Error")
        t:CreateLabel("See Output for details. Error: "..tostring(err))
    end)
end
