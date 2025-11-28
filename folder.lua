-- ===== FILE SETUP =====
local fileName = "MonsterSpawnLog.txt"

if not isfile(fileName) then
    writefile(fileName, "=== Night Spawn Log (All Objects, No Filter) ===\n")
end

-- ===== GUI INDIKATOR =====
local plr = game:GetService("Players").LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "NightSpawnLoggerGUI"
screenGui.Parent = guiParent

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 280, 0, 40)
statusLabel.Position = UDim2.new(0, 15, 0, 15)
statusLabel.BackgroundTransparency = 0.3
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBlack
statusLabel.Text = "🟢 Night Logger ACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
statusLabel.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 280, 0, 35)
toggleButton.Position = UDim2.new(0, 15, 0, 60)
toggleButton.BackgroundTransparency = 0.3
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Toggle Night Logger"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Parent = screenGui

local loggerEnabled = true
toggleButton.MouseButton1Click:Connect(function()
    loggerEnabled = not loggerEnabled
    if loggerEnabled then
        statusLabel.Text = "🟢 Night Logger ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusLabel.Text = "🔴 Night Logger OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
    end
end)

-- ===== FUNGSI LOG KE FILE =====
local function logSpawn(obj, pos)
    local line = os.date("%Y-%m-%d %H:%M:%S").." - Spawn: ["..obj.Name.."]"

    if pos then
        line = line.." at X="..string.format("%.1f",pos.X)..
                     " Y="..string.format("%.1f",pos.Y)..
                     " Z="..string.format("%.1f",pos.Z)
    else
        line = line.." (No Position)"
    end

    line = line.."\n"
    appendfile(fileName, line)
end

-- ===== LISTEN FOLDER NIGHT SECARA DINAMIS =====
local workspace = game:GetService("Workspace")

local function watchNightFolder(folder)
    folder.ChildAdded:Connect(function(child)
        if not loggerEnabled then return end
        task.wait(0.2)

        local pos = nil
        if child:IsA("Model") then
            local p = child:FindFirstChildWhichIsA("BasePart")
            if p then pos = p.Position end
        elseif child:IsA("BasePart") then
            pos = child.Position
        end

        logSpawn(child, pos)
    end)
end

-- Watch folder Night yang sudah ada saat script dijalankan
for _, f in ipairs(workspace:GetChildren()) do
    if f:IsA("Folder") and f.Name:match("Night") then
        watchNightFolder(f)
    end
end

-- Jika game membuat folder Night *baru* (regen setiap malam), kita tangkap juga
workspace.ChildAdded:Connect(function(f)
    if f:IsA("Folder") and f.Name:match("Night") then
        watchNightFolder(f)
    end
end)

statusLabel.Text = "🟢 Night Logger ACTIVE (Watching Night folder...)"
