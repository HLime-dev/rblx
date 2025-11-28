local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local plr = game:GetService("Players").LocalPlayer
local guiParent = plr:WaitForChild("PlayerGui")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 420, 0, 230)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundTransparency = 0.3
frame.ScrollBarThickness = 6
frame.CanvasSize = UDim2.new(0,0,10,0)
frame.Parent = screenGui

local layout = Instance.new("UIListLayout", frame)
layout.Padding = UDim.new(0,4)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local loggerEnabled = true
local loggedThisNight = {} -- menyimpan monster yang sudah dilog malam ini

local function addTextLine(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 26)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = #frame:GetChildren()
    label.Text = text
    label.TextColor3 = color
    label.Parent = frame
end

addTextLine("🛰 Night Spawn Logger Ready (spawn position locked)", Color3.fromRGB(255,255,0))
addTextLine("Press [L] to toggle logger", Color3.fromRGB(200,200,200))

-- ===== Spawn capture =====
local function captureSpawn(obj)
    if loggedThisNight[obj] then return end -- sudah dicatat, skip
    loggedThisNight[obj] = true

    if not loggerEnabled then return end

    -- Ambil part secepat part pertama muncul
    local part = nil
    if obj:IsA("Model") then
        part = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        part = obj
    end

    if part and part.Position then
        addTextLine(
            "🌑 Spawn: ["..obj.Name.."] at X="..string.format("%.1f", part.Position.X)..
            " Y="..string.format("%.1f", part.Position.Y)..
            " Z="..string.format("%.1f", part.Position.Z),
            Color3.fromRGB(255,255,255)
        )
    end
end

local function watchFolderNight(folder)
    -- Listen objek yang lebih dalam juga
    local function onSpawn(child)
        if loggedThisNight[child] then return end
        task.spawn(function()
            local start = tick()
            local detected = false

            -- tunggu sampai part pertama muncul, secepat mungkin
            while tick() - start < 6 and not detected do
                local p = nil
                if child:IsA("Model") then
                    p = child.PrimaryPart or child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
                elseif child:IsA("BasePart") then
                    p = child
                end

                if p and p.Position then
                    detected = true
                    captureSpawn(child) -- langsung ambil posisi spawn & lock
                end
                task.wait(0.05) -- sangat cepat scan
            end
        end)
    end

    folder.ChildAdded:Connect(onSpawn)

    -- Pastikan monster yang sudah ada (jarang tapi aman)
    for _, obj in ipairs(folder:GetDescendants()) do
        task.spawn(function()
            local p = waitForPart(obj, 2)
            if p then captureSpawn(obj) end
        end)
    end
end

-- Reset tiap malam, lalu pasang watcher baru
RS.NightStart.OnClientEvent:Connect(function()
    table.clear(loggedThisNight)
    addTextLine("\n🌙 === NIGHT START ===", Color3.fromRGB(0,200,255))

    for _, f in ipairs(Workspace:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("Night") then
            watchFolderNight(f)
            addTextLine("📡 Watching "..f.Name, Color3.fromRGB(0,255,0))
        end
    end
end)

-- Jika folder Night spawn *baru* (dihapus pagi lalu dibuat ulang game)
Workspace.ChildAdded:Connect(function(f)
    if f:IsA("Folder") and f.Name:match("Night") then
        watchFolderNight(f)
        addTextLine("📁 New folder detected: "..f.Name, Color3.fromRGB(0,180,255))
    end
end)

-- Toggle keyboard
game:GetService("UserInputService").InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.L then
        loggerEnabled = not loggerEnabled
        if loggerEnabled then
            addTextLine("🟢 Logger ON", Color3.fromRGB(0,255,0))
        else
            addTextLine("🔴 Logger OFF", Color3.fromRGB(255,0,0))
        end
    end
end)
