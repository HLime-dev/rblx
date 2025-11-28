-- === LOGGER SETUP ===
local fileName = "MonsterSpawnLog.txt"

if not isfile(fileName) then
    writefile(fileName, "=== Monster Spawn Log ===\n")
end

-- === GUI INDIKATOR (PASTI MUNCUL) ===
local plr = game:GetService("Players").LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 250, 0, 40)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundTransparency = 0.4
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBlack
statusLabel.Text = "🟢 Monster Logger ACTIVE1"
statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
statusLabel.Parent = screenGui

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 250, 0, 35)
toggleButton.Position = UDim2.new(0, 10, 0, 55)
toggleButton.BackgroundTransparency = 0.4
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Toggle Monster Logger"
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Parent = screenGui

local loggerEnabled = true
toggleButton.MouseButton1Click:Connect(function()
    loggerEnabled = not loggerEnabled
    if loggerEnabled then
        statusLabel.Text = "🟢 Monster Logger ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
    else
        statusLabel.Text = "🔴 Monster Logger OFF"
        statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
    end
end)

-- === FUNGSI SIMPAN LOG ===
local function saveSpawn(monster, pos)
    local line = os.date("%Y-%m-%d %H:%M:%S") ..
        " - Spawn: ["..monster.Name.."] at X="..
        string.format("%.1f", pos.X).." Y="..
        string.format("%.1f", pos.Y).." Z="..
        string.format("%.1f", pos.Z).."\n"

    appendfile(fileName, line)
end

-- === MONSTER SPAWN LISTENER (FIX SESUAI STRUKTUR GAME) ===
local Workspace = game:GetService("Workspace")

for _, folder in ipairs(Workspace:GetChildren()) do
    if folder:IsA("Folder") and folder.Name:match("Night") then
        
        folder.ChildAdded:Connect(function(child)
            if not loggerEnabled then return end
            task.wait(0.3)

            if child:IsA("Model") and child:FindFirstChild("HumanoidRootPart") then
                saveSpawn(child, child.HumanoidRootPart.Position)
            end
        end)

    end
end

statusLabel.Text = "🟢 Monster Logger ACTIVE1 (menunggu spawn Night)"
print("✅ GUI & Logger siap! menunggu monster spawn...")
