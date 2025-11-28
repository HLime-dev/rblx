local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local plr = game:GetService("Players").LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

task.wait(1)

-- ===== GUI SETUP =====
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = guiParent

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0,420,0,230)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundTransparency = 0.3
frame.ScrollBarThickness = 6
frame.Parent = gui

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0,4)

local labelStatus = Instance.new("TextLabel")
labelStatus.Size = UDim2.new(0,200,0,25)
labelStatus.Position = UDim2.new(0,10,0,250)
labelStatus.BackgroundTransparency = 0.4
labelStatus.Font = Enum.Font.GothamBlack
labelStatus.TextSize = 14
labelStatus.TextColor3 = Color3.fromRGB(255,0,0)
labelStatus.Text = "Monster Logger: OFF"
labelStatus.Parent = gui

local loggerEnabled = false
local logged = {}

local function addLine(text, color)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-10,0,22)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Text = text
    t.TextColor3 = color
    t.Parent = frame
end

local function updateStatus()
    if loggerEnabled then
        labelStatus.Text = "Monster Logger: ON"
        labelStatus.TextColor3 = Color3.fromRGB(0,255,0)
    else
        labelStatus.Text = "Monster Logger: OFF"
        labelStatus.TextColor3 = Color3.fromRGB(255,0,0)
    end
end

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.L then
        loggerEnabled = not loggerEnabled
        updateStatus()
    end
end)

-- Menunggu sampai model punya HRP
local function waitForHRP(obj, timeout)
    timeout = timeout or 6
    local start = tick()

    while tick() - start < timeout do
        if obj:FindFirstChild("HumanoidRootPart") then
            return obj.HumanoidRootPart
        end
        task.wait(0.05)
    end
    return nil
end

local function logSpawn(obj)
    if not loggerEnabled then return end
    if obj:IsA("Model") then
        local hrp = waitForHRP(obj)
        if hrp and not logged[obj] then
            logged[obj] = true
            local pos = hrp.Position
            addLine("👾 Spawn: ["..obj.Name.."] X="..string.format("%.1f",pos.X)..
                    " Y="..string.format("%.1f",pos.Y).." Z="..string.format("%.1f",pos.Z),
                    Color3.fromRGB(255,255,255))
        end
    end
end

-- Scan awal saat NightStart
RS.NightStart.OnClientEvent:Connect(function()
    loggerEnabled = true
    updateStatus()
    addLine("\n🌙 === NIGHT START (Scan Spawn) ===", Color3.fromRGB(0,200,255))
end)

-- Listen spawn semua objek workspace
WS.ChildAdded:Connect(function(obj)
    task.spawn(function()
        logSpawn(obj)
    end)
end)

WS.DescendantAdded:Connect(function(obj)
    task.spawn(function()
        logSpawn(obj.Parent or obj)
    end)
end)

addLine("🧠 Menunggu monster spawn di workspace...", Color3.fromRGB(255,255,0))

updateStatus()
