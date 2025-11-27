--// ================= REMOTE SPY GUI (On-Screen TextBox) ================= //

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- Create Screen GUI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = plr:WaitForChild("PlayerGui")

-- Frame Container
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 320)
frame.Position = UDim2.new(0.5, -300, 0.1, 0)
frame.BackgroundTransparency = 0.25
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.BorderSizePixel = 2
frame.Parent = gui

-- Title Label
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,24)
title.BackgroundTransparency = 0.3
title.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
title.Text = "RemoteSpy (On Screen)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

-- Output TextBox
local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -10, 1, -34)
box.Position = UDim2.new(0,5,0,29)
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextSize = 14
box.BackgroundTransparency = 0.2
box.BackgroundColor3 = Color3.new(0.05,0.05,0.05)
box.TextColor3 = Color3.new(0,1,0)
box.Font = Enum.Font.Code
box.Text = ""
box.Parent = frame

-- Make box scrollable
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingLeft = UDim.new(0, 4)
padding.Parent = box

local listLayout = Instance.new("UIListLayout")
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.Parent = box

-- Log function to write on screen
local function write(text)
    box.Text ..= text .. "\n"
end

-- Hook Remote Calls
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if self:IsA("RemoteEvent") and method == "FireServer" then
        write("🔥 RemoteEvent:FireServer")
        write("• Name   : " .. self.Name)
        write("• Parent : " .. (self.Parent and self.Parent.Name or "nil"))
        write("• Args   : " .. table.concat(args, ", "))
        write("--------------------------------------------------")
    end

    if self:IsA("RemoteFunction") and method == "InvokeServer" then
        write("⚡ RemoteFunction:InvokeServer")
        write("• Name   : " .. self.Name)
        write("• Parent : " .. (self.Parent and self.Parent.Name or "nil"))
        write("• Args   : " .. table.concat(args, ", "))
        write("--------------------------------------------------")
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Close Button
local close = Instance.new("TextButton")
close.Size = UDim2.new(0,120,0,22)
close.Position = UDim2.new(0,5,1,-27)
close.BackgroundTransparency = 0.2
close.BackgroundColor3 = Color3.new(0.2,0,0)
close.Text = "Close"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.Code
close.TextScaled = true
close.Parent = frame

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Draggable
local dragToggle, dragInput, dragStart, startPos
local UIS = game:GetService("UserInputService")

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

write("✅ RemoteSpy Active — Interact with game buttons to capture events...")
