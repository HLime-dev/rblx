--// Buat ScreenGUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.CoreGui

--// Buat TextLabel
local label = Instance.new("TextLabel")
label.Parent = gui
label.Size = UDim2.new(0, 250, 0, 100)
label.Position = UDim2.new(0, 10, 0, 10)
label.BackgroundTransparency = 0.3
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.Text = "Loading..."

--// Update koordinat secara real-time
game:GetService("RunService").RenderStepped:Connect(function()
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        label.Text = string.format(
            "Koordinat Kamu:\nX: %.1f\nY: %.1f\nZ: %.1f",
            pos.X, pos.Y, pos.Z
        )
    end
end)
