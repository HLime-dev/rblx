local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayerGui = plr:WaitForChild("PlayerGui")

local markedPoints = {}
local boxes = {}

-- Helper HRP
local function GetHRP()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- Buat ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MapMarkerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Fungsi buat tombol
local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,150,0,40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(0,128,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = screenGui
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Tombol Mark Point 1-4
for i = 1, 4 do
    createButton("Mark Point "..i, UDim2.new(0, 10, 0, 50*i), function()
        local hrp = GetHRP()
        if hrp then
            markedPoints[i] = hrp.Position
            print("Point "..i.." marked at:", hrp.Position)

            -- Visual box
            if boxes[i] then boxes[i]:Destroy() end
            local part = Instance.new("Part")
            part.Size = Vector3.new(2,2,2)
            part.Position = hrp.Position
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(0,255,0)
            part.Transparency = 0.5
            part.Parent = workspace
            boxes[i] = part
        else
            warn("Character belum spawn atau HumanoidRootPart tidak ada!")
        end
    end)
end

-- Tombol Show Points
createButton("Show Points", UDim2.new(0,10,0,260), function()
    for i, pos in ipairs(markedPoints) do
        print("Point "..i..":", pos)
    end
end)

-- Tombol Copy JSON
createButton("Copy JSON", UDim2.new(0,10,0,310), function()
    if #markedPoints < 4 then
        warn("Tandai 4 titik dulu!")
        return
    end
    local data = {}
    for i, pos in ipairs(markedPoints) do
        data[i] = {x=pos.X, y=pos.Y, z=pos.Z}
    end
    local json = HttpService:JSONEncode(data)
    pcall(function() setclipboard(json) end)
    print("Points copied to clipboard! Paste anywhere di HP.")
end)

-- Tombol Clear Boxes
createButton("Clear Boxes", UDim2.new(0,10,0,360), function()
    for _, box in ipairs(boxes) do
        if box then pcall(function() box:Destroy() end) end
    end
    boxes = {}
end)
