local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local plr = game:GetService("Players").LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

task.wait(1) -- ✅ Biar GUI tidak dibuat terlalu cepat

-- ===== GUI SETUP =====
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "MonsterSpawnViewer"
screenGui.Parent = guiParent -- ✅ Pakai PlayerGui (lebih kompatibel)

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.3
frame.ScrollBarThickness = 6
frame.CanvasSize = UDim2.new(0, 0, 5, 0)
frame.Parent = screenGui

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local loggerEnabled = true

local function addTextLine(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #frame:GetChildren()
    label.Text = text
    label.TextColor3 = color
    label.Parent = frame
end

-- Recursive: menunggu sampai object punya part dengan posisi
local function waitForPart(obj, timeout)
    timeout = timeout or 5
    local start = tick()
    while tick() - start < timeout do
        if obj:IsA("Model") then
            local part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if part and part.Position then
                return part
            end
        elseif obj:IsA("BasePart") and obj.Position then
            return obj
        end
        task.wait(0.1)
    end
    return nil
end

local function logSpawn(obj)
    local part = waitForPart(obj)
    if part then
        local pos = part.Position
        addTextLine(
            "👾 Spawn: ["..obj.Name.."] at X="..string.format("%.1f", pos.X)..
            " Y="..string.format("%.1f", pos.Y).." Z="..string.format("%.1f", pos.Z),
            Color3.fromRGB(255,255,255)
        )
    else
        addTextLine(
            "👾 Spawn: ["..obj.Name.."] ⚠ Menunggu part...", 
            Color3.fromRGB(255,150,0)
        )

        task.spawn(function()
            local latePart = waitForPart(obj, 10)
            if latePart then
                local p = latePart.Position
                addTextLine(
                    "✅ Pos Update: ["..obj.Name.."] at X="..string.format("%.1f", p.X)..
                    " Y="..string.format("%.1f", p.Y).." Z="..string.format("%.1f", p.Z),
                    Color3.fromRGB(0,255,0)
                )
            end
        end)
    end
end

local function watchNightFolder(folder)
    folder.ChildAdded:Connect(function(child)
        if not loggerEnabled then return end
        task.spawn(function() 
            local part = waitForPart(child, 6)
            logSpawn(child)
        end)
    end)
end

-- Handler saat malam dimulai
RS.NightStart.OnClientEvent:Connect(function()
    addTextLine("\n🌙 === MALAM DIMULAI, LOGGER RESET ===", Color3.fromRGB(0,150,255))

    -- listen ke folder Night yang ada atau baru dibuat
    for _, f in ipairs(Workspace:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("Night") then
            watchNightFolder(f)
        end
    end

    Workspace.ChildAdded:Connect(function(f)
        if f:IsA("Folder") and f.Name:match("Night") then
            watchNightFolder(f)
            addTextLine("📁 Night folder detected: "..f.Name, Color3.fromRGB(0,180,255))
        end
    end)
end)

-- Toggle keyboard
game:GetService("UserInputService").InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.L then
        loggerEnabled = not loggerEnabled
        if loggerEnabled then
            addTextLine("🟢 Logger ENABLED", Color3.fromRGB(0,255,0))
        else
            addTextLine("🔴 Logger DISABLED", Color3.fromRGB(255,0,0))
        end
    end
end)

addTextLine("🧠 Logger standby, menunggu NightStart...", Color3.fromRGB(255,255,0))
