local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local plr = Players.LocalPlayer
local MonsterFolder = Workspace:WaitForChild("Monsters") -- ganti sesuai folder

local SpawnedNightMonsters = {}

-- Fungsi cek apakah malam (misal: waktu Roblox di sky = jam 18-6)
local function IsNight()
    local Lighting = game:GetService("Lighting")
    local hour = Lighting.ClockTime -- ClockTime: 0-24
    return hour >= 18 or hour <= 6
end

local function RecordMonster(monster)
    if not IsNight() then return end -- hanya malam hari

    local prim = monster.PrimaryPart or monster:FindFirstChildWhichIsA("BasePart", true)
    if prim then
        SpawnedNightMonsters[monster.Name] = {
            x = prim.Position.X,
            y = prim.Position.Y,
            z = prim.Position.Z,
            time = tick()
        }
        print(("Monster %s spawned at night at %s"):format(monster.Name, tostring(prim.Position)))
    end
end

-- Catat monster yang sudah ada (hanya malam)
for _, monster in ipairs(MonsterFolder:GetChildren()) do
    RecordMonster(monster)
end

-- Catat monster baru saat spawn
MonsterFolder.ChildAdded:Connect(function(monster)
    RecordMonster(monster)
end)

-- Export ke JSON & simpan ke clipboard
local function ExportToClipboard()
    local jsonData = HttpService:JSONEncode(SpawnedNightMonsters)
    if setclipboard then
        setclipboard(jsonData)
        print("Data monster malam berhasil disalin ke clipboard!")
    else
        print("Copy JSON ini manual:\n", jsonData)
    end
end

-- Tombol GUI sederhana
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0,200,0,50)
Button.Position = UDim2.new(0,50,0,50)
Button.Text = "Export Monster Spawn Night"
Button.MouseButton1Click:Connect(ExportToClipboard)
