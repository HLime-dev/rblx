--========================================
-- SIMPLE CLEAN UI (DRAGGABLE + TABS)
--========================================

-- Destroy old UI
if game.CoreGui:FindFirstChild("DN_UI") then
    game.CoreGui.DN_UI:Destroy()
end

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DN_UI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 450, 0, 300)
main.Position = UDim2.new(0.3, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Top Bar
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 35)
top.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
top.BorderSizePixel = 0
top.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "Dangerous Night"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Parent = top

-- Tab Buttons
local tabHolder = Instance.new("Frame")
tabHolder.Size = UDim2.new(0, 120, 1, -35)
tabHolder.Position = UDim2.new(0, 0, 0, 35)
tabHolder.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
tabHolder.BorderSizePixel = 0
tabHolder.Parent = main

local pages = Instance.new("Frame")
pages.Size = UDim2.new(1, -120, 1, -35)
pages.Position = UDim2.new(0, 120, 0, 35)
pages.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
pages.BorderSizePixel = 0
pages.Parent = main

-- Function for creating tabs
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = tabHolder

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 500)
    page.ScrollBarThickness = 6
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Parent = pages

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages:GetChildren()) do
            if p:IsA("ScrollingFrame") then p.Visible = false end
        end
        for _, b in pairs(tabHolder:GetChildren()) do
            if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30,30,30) end
        end
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        page.Visible = true
    end)

    return page
end

-- Create Tabs
local mainTab = CreateTab("Main")
local espTab = CreateTab("ESP")
local tpTab = CreateTab("Teleport")

mainTab.Visible = true  -- default tab

-- Helper: Add button element
local function AddButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, #parent:GetChildren()*45)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
end

------------------------------------------------------
-- MAIN TAB FEATURES
------------------------------------------------------

local plr = game.Players.LocalPlayer

AddButton(mainTab, "Toggle Noclip", function()
    getgenv().noclip = not getgenv().noclip
    if noclip then
        if getgenv()._nc then getgenv()._nc:Disconnect() end
        getgenv()._nc = game.RunService.Stepped:Connect(function()
            if plr.Character then
                for _, v in pairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if getgenv()._nc then getgenv()._nc:Disconnect() end
    end
end)

AddButton(mainTab, "Collect All Food", function()
    for _, food in pairs(workspace:GetChildren()) do
        if food:IsA("Tool") and food:FindFirstChild("Handle") then
            local prompt = food.Handle:FindFirstChildOfClass("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
        end
    end
end)

------------------------------------------------------
-- ESP TAB
------------------------------------------------------

AddButton(espTab, "Monster ESP", function()
    getgenv().esp = not getgenv().esp

    while esp do
        for _, f in pairs(workspace:GetChildren()) do
            if f:IsA("Folder") and f.Name:match("Night") then
                for _, m in pairs(f:GetChildren()) do
                    if m:IsA("Model") and m:FindFirstChild("HumanoidRootPart") then
                        if not m:FindFirstChild("Highlight") then
                            Instance.new("Highlight", m)
                        end
                    end
                end
            end
        end
        task.wait(1)
    end

    for _, m in pairs(workspace:GetDescendants()) do
        if m:IsA("Highlight") then m:Destroy() end
    end
end)

------------------------------------------------------
-- TELEPORT TAB
------------------------------------------------------

AddButton(tpTab, "Teleport: Bunker", function()
    local bunker = plr:GetAttribute("AssignedBunkerName")
    if workspace.Bunkers[bunker] then
        plr.Character.HumanoidRootPart.CFrame = workspace.Bunkers[bunker].SpawnLocation.CFrame
    end
end)

