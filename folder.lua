local fname = "MonsterSpawnLog.txt"

local supportsFile = pcall(function()
    writefile(fname, "test")
    appendfile(fname, "test")
    readfile(fname)
    isfile(fname)
end)

-- hapus test file jika sempat terbuat
pcall(function() delfile(fname) end)

-- Tampilkan hasil di layar GUI
local plr = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", plr.PlayerGui)
local label = Instance.new("TextLabel", gui)

label.Size = UDim2.new(0,300,0,40)
label.Position = UDim2.new(0,10,0,10)
label.TextScaled = true
label.Font = Enum.Font.GothamBold

if supportsFile then
    label.Text = "🟢 Executor SUPPORT writefile!"
    label.TextColor3 = Color3.fromRGB(0,255,0)
else
    label.Text = "🔴 Executor TIDAK support writefile!"
    label.TextColor3 = Color3.fromRGB(255,0,0)
end
