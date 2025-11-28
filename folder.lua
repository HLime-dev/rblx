local fileName = "MonsterSpawnLog.txt"
local loggerEnabled = true

-- === GUI SETUP ===
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 40)
statusLabel.Position = UDim2.new(0, 20, 0, 20)
statusLabel.BackgroundTransparency = 0.3
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Text = "🟢 LOGGER ACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 35)
toggleButton.Position = UDim2.new(0, 20, 0, 65)
toggleButton.BackgroundTransparency = 0.3
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "Toggle Logger"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = screenGui

-- Toggle logger saat tombol diklik
toggleButton.MouseButton1Click:Connect(function()
    loggerEnabled = not loggerEnabled
    if loggerEnabled then
        statusLabel.Text = "🟢 LOGGER ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "🔴 LOGGER OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- === LOGGER FUNCTION ===
local function savePositionToFile(monster, position)
    local text = os.date("%Y-%m-%d %H:%M:%S") ..
                 " - Spawn: ["..monster.Name.."] at X="..position.X..
                 " Y="..position.Y.." Z="..position.Z.."\n"

    if isfile(fileName) then
        appendfile(fileName, text)
    else
        writefile(fileName, text)
    end
end

local function isNightTime()
    local lighting = game:GetService("Lighting")
    return lighting.ClockTime >= 18 or lighting.ClockTime <= 6
end

-- Listener spawn monster
game:GetService("Workspace").ChildAdded:Connect(function(child)
    if not loggerEnabled then return end -- berhenti jika OFF
    if isNightTime() then
        task.wait(0.3)
        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            local part = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
            if part then
                savePositionToFile(child, part.Position)
            end
        end
    end
end)

-- Reset status otomatis saat pagi agar tidak confusion
task.spawn(function()
    while true do
        if not isNightTime() then
            -- Kalau pagi dan logger masih OFF, label tetap merah
            if loggerEnabled then
                statusLabel.Text = "🟢 LOGGER ACTIVE"
                statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
        task.wait(10)
    end
end)
