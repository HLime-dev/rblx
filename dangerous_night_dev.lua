local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Size = UDim2.new(0, 350, 0, 200)
Frame.Position = UDim2.new(0.3, 0, 0.2, 0)

TextLabel.Parent = Frame
TextLabel.Text = "Test UI – Jika ini muncul, GUI kamu SUPPORT"
TextLabel.Size = UDim2.new(1,0,0,50)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255,255,255)

Button.Parent = Frame
Button.Position = UDim2.new(0, 20, 0, 80)
Button.Size = UDim2.new(0, 150, 0, 50)
Button.Text = "Test Button"
Button.MouseButton1Click:Connect(function()
    print("Button clicked!")
end)
