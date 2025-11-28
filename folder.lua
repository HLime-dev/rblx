local plr = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")
local guiParent = plr:WaitForChild("PlayerGui")

-- ===== GUI SETUP =====
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "MonsterSpawnViewer"
screenGui.Parent = guiParent

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 400, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.3
frame.ScrollBarThickness = 6
frame.Parent = screenGui

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0, 5)

local loggerEnabled = true

local function addTextLine(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 30)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.TextColor3 = color
    label.Parent = frame
end

-- Status awal
addTextLine("🟢 Monster Logger ACTIVE", Color3.fromRGB(0,255,0))
addTextLine("Press [L] to toggle ON/OFF", Color3.fromRGB(255,255,0))

-- Toggle pakai keyboard biar mudah & GUI tidak perlu tombol extra
game:GetService("UserInputService").InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.L then
        loggerEnabled = not loggerEnabled
        if loggerEnabled then
            addTextLine("🟢 Logger ENABLED", Color3.fromRGB(0,255,0))
        else
            addTextLine("🔴 Logger DISABLED", Color3.fromRGB(255,0,0))
        end
    end
end)

-- ===== FUNGSI LOG SPAWN KE LAYAR =====
local function logSpawn(obj)
    local pos = nil

    if obj:IsA("Model") then
        local p = obj:FindFirstChildWhichIsA("BasePart")
        if p then pos = p.Position end
    elseif obj:IsA("BasePart") then
        pos = obj.Position
    end

    if pos then
        addTextLine(
            "👾 Spawn: ["..obj.Name.."] at X="..string.format("%.1f",pos.X)..
            " Y="..string.format("%.1f",pos.Y).." Z="..string.format("%.1f",pos.Z),
            Color3.fromRGB(255,255,255)
        )
    else
        addTextLine(
            "👾 Spawn: ["..obj.Name.."] (No Position)",
            Color3.fromRGB(200,200,200)
        )
    end
end

-- ===== LISTENER FOLDER NIGHT (DINAMIS + AUTO UPDATE) =====
local function watchNightFolder(folder)
    folder.ChildAdded:Connect(function(child)
        if not loggerEnabled then return end
        task.wait(0.1)
        logSpawn(child)
    end)
end

-- Cek folder Night yang sudah ada saat script run
for _, f in ipairs(workspace:GetChildren()) do
    if f:IsA("Folder") and f.Name:match("Night") then
        watchNightFolder(f)
    end
end

-- Jika folder Night dibuat ulang oleh game, kita listen juga
workspace.ChildAdded:Connect(function(f)
    if f:IsA("Folder") and f.Name:match("Night") then
        watchNightFolder(f)
        addTextLine("🌙 Night folder detected: "..f.Name, Color3.fromRGB(0,150,255))
    end
end)

addTextLine("🧠 System berjalan, menunggu spawn monster...", Color3.fromRGB(0,150,255))
