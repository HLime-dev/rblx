--=====================
--  CREATE UI SCREEN
--=====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 250, 0, 340)
Main.Position = UDim2.new(0.1, 0, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

--=====================
--  UI TITLE
--=====================
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Title.BorderSizePixel = 0
Title.Text = "Dangerous Night Panel"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Parent = Main

--=====================
--  DRAG SYSTEM (FULL WORKING)
--=====================
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                              startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

--=====================
--  BUTTON MAKER
--=====================
local function CreateButton(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.Position = UDim2.new(0, 10, 0, 40 + (#Main:GetChildren()-2)*40)
    Btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Btn.BorderSizePixel = 0
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255,255,255)
    Btn.Parent = Main
    Btn.MouseButton1Click:Connect(callback)
end

--=====================
--  SAMPLE BUTTONS
--=====================
CreateButton("Toggle Noclip", function()
    noclip = not noclip
end)

CreateButton("Collect All Food", function()
    print("Collecting food…")
end)

CreateButton("Monster ESP", function()
    print("ESP enabled")
end)

CreateButton("Teleport: Bunker", function()
    print("Teleporting…")
end)
