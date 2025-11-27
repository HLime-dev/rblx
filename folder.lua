local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local plr = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 550, 0, 300)
Frame.Position = UDim2.new(0.5, -275, 0.15, 0)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 22)
Title.BackgroundTransparency = 0.2
Title.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Title.Text = "RemoteSpy"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.Code
Title.TextScaled = true
Title.Parent = Frame

local Output = Instance.new("TextBox")
Output.Size = UDim2.new(1, -10, 1, -54)
Output.Position = UDim2.new(0, 5, 0, 27)
Output.MultiLine = true
Output.ClearTextOnFocus = false
Output.TextXAlignment = Enum.TextXAlignment.Left
Output.TextYAlignment = Enum.TextYAlignment.Top
Output.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
Output.BackgroundTransparency = 0.1
Output.TextColor3 = Color3.new(0, 1, 0)
Output.Font = Enum.Font.Code
Output.TextSize = 14
Output.Text = "✅ Listener aktif...\n"
Output.Parent = Frame

local function log(text)
    Output.Text = Output.Text .. text .. "\n"
end

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 100, 0, 22)
Close.Position = UDim2.new(0, 5, 1, -27)
Close.BackgroundColor3 = Color3.new(0.2, 0, 0)
Close.Text = "Close"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.Code
Close.TextScaled = true
Close.Parent = Frame

Close.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Draggable (safe)
local dragging, dragInput, dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Remote Listener (tanpa hook global)
for _, remote in ipairs(game:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            log("📡 RemoteEvent Triggered: " .. remote.Name)
            log("• Args: " .. table.concat({...}, ", "))
            log("• Parent: " .. tostring(remote.Parent))
            log("---------------------------")
        end)
    elseif remote:IsA("RemoteFunction") then
        log("⚙ RemoteFunction ditemukan: " .. remote.Name)
    end
end

log("✅ Interact tombol Drop/Eat di game sekarang...")
