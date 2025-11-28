local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local plr = game:GetService("Players").LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

-- ===== GUI STATUS LOGGER =====
local gui = Instance.new("ScreenGui")
gui.Name = "MonsterLoggerStatus"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local labelStatus = Instance.new("TextLabel")
labelStatus.Size = UDim2.new(0, 250, 0, 30)
labelStatus.Position = UDim2.new(0, 10, 0, 250)
labelStatus.BackgroundTransparency = 0.4
labelStatus.Font = Enum.Font.GothamBlack
labelStatus.TextSize = 14
labelStatus.TextColor3 = Color3.fromRGB(255,255,255)
labelStatus.Text = "🔴 Monster Logger: OFF"
labelStatus.Parent = gui

local loggerEnabled = false
local loggedSpawn = {}

local function updateStatus()
    if loggerEnabled then
        labelStatus.Text = "🟢 Monster Logger: ON"
        labelStatus.TextColor3 = Color3.fromRGB(0,255,0)
    else
        labelStatus.Text = "🔴 Monster Logger: OFF"
        labelStatus.TextColor3 = Color3.fromRGB(255,0,0)
    end
end

-- Toggle ON/OFF pakai keyboard [L]
game:GetService("UserInputService").InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.L then
        loggerEnabled = not loggerEnabled
        updateStatus()
    end
end)

updateStatus()

-- ===== FUNGSI CATAT POSISI SPAWN =====
local function logMonster(monster)
    if loggedSpawn[monster] then return end
    loggedSpawn[monster] = true

    local hrp = monster:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        print("Spawn:", monster.Name, pos) -- internal, tidak mengganggu
        table.insert(loggedSpawn, monster)

        -- Tampilkan ke GUI
        local line = Instance.new("TextLabel")
        line.Size = UDim2.new(1, -10, 0, 22)
        line.BackgroundTransparency = 1
        line.Font = Enum.Font.GothamBold
        line.TextSize = 13
        line.TextXAlignment = Enum.TextXAlignment.Left
        line.Text = "👾 Spawn: ["..monster.Name.."] X="..string.format("%.1f",pos.X)..
                     " Y="..string.format("%.1f",pos.Y)..
                     " Z="..string.format("%.1f",pos.Z)
        line.TextColor3 = Color3.fromRGB(255,255,255)
        line.Parent = WS:FindFirstChildWhichIsA("Folder") -- nanti dipindah ke ScrollingFrame
        guiParent.MonsterSpawnViewer.Frame:Insert(line)
    end
end

-- ===== LISTENER SAAT MALAM DIMULAI =====
RS.NightStart.OnClientEvent:Connect(function()
    loggerEnabled = true
    updateStatus()
    table.clear(loggedSpawn)

    -- Cari folder Night seperti ESP Anda
    local folderNight = nil
    for _, f in ipairs(WS:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("Night") then
            folderNight = f
            break
        end
    end

    if not folderNight then
        labelStatus.Text = "⚠ Night folder belum ditemukan..."
        return
    end

    -- Logger scan cepat di awal malam (ambil spawn awal)
    task.spawn(function()
        local start = tick()
        while tick() - start < 4 do -- 4 detik awal
            if not loggerEnabled then break end

            for _, monster in ipairs(folderNight:GetChildren()) do
                if monster:IsA("Model") and monster:FindFirstChild("HumanoidRootPart") then
                    logMonster(monster)
                end
            end

            task.wait(0.1) -- scan super cepat biar monster belum roam jauh
        end
    end)

    -- Listen monster baru spawn tengah malam (jarang)
    folderNight.ChildAdded:Connect(function(monster)
        if not loggerEnabled then return end
        task.wait(0.05)
        if monster:IsA("Model") then
            logMonster(monster)
        end
    end)

end)
