local fileName = "MonsterSpawnLog.txt"

-- Menyimpan posisi spawn ke file txt
local function savePositionToFile(monster, position)
    local text = os.date("%Y-%m-%d %H:%M:%S") ..
                 " - Spawn: ["..monster.Name.."] at X="..position.X..
                 " Y="..position.Y.." Z="..position.Z.."\n"

    writefile(fileName, (isfile(fileName) and readfile(fileName) or "") .. text)
end

-- Cek apakah sedang malam hari
local function isNightTime()
    local lighting = game:GetService("Lighting")
    return lighting.ClockTime >= 18 or lighting.ClockTime <= 6
end

-- Listener: setiap monster baru masuk workspace saat malam, langsung log
game:GetService("Workspace").ChildAdded:Connect(function(child)
    if isNightTime() then
        task.wait(0.3) -- biar model ter-load dulu

        if child:IsA("Model") and child:FindFirstChild("Humanoid") then
            local part = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
            if part then
                savePositionToFile(child, part.Position)
            end
        end
    end
end)

-- (Opsional) Cetak di layar biar tahu script aktif
print("✅ Monster Spawn Logger aktif, mencatat semua monster di malam hari...")
