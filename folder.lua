--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
    Name = "Map Marker GUI",
    LoadingTitle = "Map Marker",
    LoadingSubtitle = "by ChatGPT",
    ConfigurationSaving = { Enabled = false },
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local markedPoints = {}
local boxes = {}

-- Helper: Dapatkan HRP
local function GetHRP()
    local char = plr.Character or plr.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- Tab utama
local MainTab = Window:CreateTab("Marker", 4483362458)

-- Tombol untuk menandai 4 titik
for i = 1, 4 do
    MainTab:CreateButton({
        Name = "Mark Point "..i,
        Callback = function()
            local hrp = GetHRP()
            if hrp then
                markedPoints[i] = hrp.Position
                print("Point "..i.." marked at:", hrp.Position)

                -- optional: buat visual box
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
        end
    })
end

-- Tombol lihat semua titik
MainTab:CreateButton({
    Name = "Show Points in Output",
    Callback = function()
        for i, pos in ipairs(markedPoints) do
            print("Point "..i..":", pos)
        end
    end
})

-- Tombol copy JSON ke clipboard (Delta)
MainTab:CreateButton({
    Name = "Copy Points JSON",
    Callback = function()
        if #markedPoints < 4 then
            warn("Tandai 4 titik dulu!")
            return
        end
        local data = {}
        for i, pos in ipairs(markedPoints) do
            data[i] = {x = pos.X, y = pos.Y, z = pos.Z}
        end
        local json = HttpService:JSONEncode(data)
        pcall(function() setclipboard(json) end)
        print("Points copied to clipboard! Paste anywhere to save on HP.")
    end
})

-- Tombol hapus semua visual box
MainTab:CreateButton({
    Name = "Clear Boxes",
    Callback = function()
        for _, box in ipairs(boxes) do
            if box then pcall(function() box:Destroy() end) end
        end
        boxes = {}
    end
})
