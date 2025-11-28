local fileName = "MonsterSpawnLog.txt"

-- Buat file jika belum ada
if not isfile(fileName) then
    writefile(fileName, "=== Night Spawn Log (No Filter) ===\n")
end

-- === GUI INDIKATOR ===
local plr = game:GetService("Players").LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "NightSpawnLoggerGUI"
screenGui.Parent = guiParent

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 260, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 0.4
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBlack
statusLabel.Text = "🟢 Night Logger ACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
statusLabel.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 260, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 55)
toggleButton.BackgroundTransparency = 0.4
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

-- === FUNGSI SIMPAN LOG ===
local function logSpawn(obj, pos)
    local line = os.date("%Y-%m-%d %H:%M:%S") .. " - Spawn: [" .. obj.Name .. "]"

    if pos then
        line = line .. " at X="..string.format("%.1f", pos.X)..
                      " Y="..string.format("%.1f", pos.Y)..
                      " Z="..string.format("%.1f", pos.Z)
    else
        line = line .. " (No Position)"
    end

    line = line .. "\n"
    appendfile(fileName, line)
end

-- === LISTENER SPAWN TANPA FILTER (SESUAI CONTOH GAME ANDA) ===
local Workspace = game:GetService("Workspace")

for _, folder in ipairs(Workspace:GetChildren()) do
    if folder:IsA("Folder") and folder.Name:match("Night") then
        folder.ChildAdded:Connect(function(child)
            if not loggerEnabled then return end
            task.wait(0.2)

            local pos = nil

            -- Cek posisi di semua kemungkinan tanpa filter
            if child:IsA("Model") then
                pos = child:FindFirstChildWhichIsA("BasePart") and child:FindFirstChildWhichIsA("BasePart").Position
            elseif child:IsA("BasePart") then
                pos = child.Position
            end

            logSpawn(child, pos)
        end)
    end
end

print("✅ GUI muncul & Logger berjalan tanpa filter, menunggu spawn Night...")
