--==========================
-- SIMPLE GUI – NO RAYFIELD
--==========================

local players = game:GetService("Players")
local plr = players.LocalPlayer
local ws = game:GetService("Workspace")
local rs = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "DN_SIMPLE_UI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 420)
frame.Position = UDim2.new(0, 20, 0, 150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true

local function NewBtn(text)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -10, 0, 32)
    b.Position = UDim2.new(0, 5, 0, (#frame:GetChildren() - 1) * 35)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    return b
end

-----------------------
-- Noclip
-----------------------
local noclip = false
local noclipConn

local btnNoclip = NewBtn("Toggle Noclip")
btnNoclip.MouseButton1Click:Connect(function()
    noclip = not noclip

    if noclip then
        noclipConn = game:GetService("RunService").Stepped:Connect(function()
            if plr.Character then
                for _, v in ipairs(plr.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then
            noclipConn:Disconnect()
            noclipConn = nil
        end
    end
end)

-----------------------
-- WalkSpeed
-----------------------
local boxWS = Instance.new("TextBox", frame)
boxWS.Size = UDim2.new(1, -10, 0, 32)
boxWS.Position = UDim2.new(0, 5, 0, (#frame:GetChildren() - 1) * 35)
boxWS.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
boxWS.TextColor3 = Color3.new(1, 1, 1)
boxWS.PlaceholderText = "WalkSpeed"

boxWS.FocusLost:Connect(function()
    local n = tonumber(boxWS.Text)
    if n then
        plr.Character.Humanoid.WalkSpeed = n
    end
end)

-----------------------
-- Collect All Food
-----------------------
local btnCollect = NewBtn("Collect All Food")
btnCollect.MouseButton1Click:Connect(function()
    local hrp = plr.Character.HumanoidRootPart
    local lastPos = hrp.CFrame

    for _, tool in pairs(ws:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local h = tool.Handle
            local prompt = h:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                hrp.CFrame = h.CFrame * CFrame.new(0, 5, 0)
                task.wait(.2)
                fireproximityprompt(prompt, 10)
            end
        end
    end

    task.wait(.2)
    hrp.CFrame = lastPos
end)

-----------------------
-- Drop All Food
-----------------------
local btnDrop = NewBtn("Drop All Food")
btnDrop.MouseButton1Click:Connect(function()
    local hrp = plr.Character.HumanoidRootPart
    local lastPos = hrp.CFrame

    for _, v in pairs(plr.Backpack:GetChildren()) do
        v.Parent = plr.Character
    end

    task.wait(.3)
    plr.Character.Humanoid.Health = 0

    plr.CharacterAdded:Wait()
    local newHrp = plr.Character:WaitForChild("HumanoidRootPart")
    task.wait(.5)
    newHrp.CFrame = lastPos
end)

-----------------------
-- Furniture Dropdown
-----------------------
local dropdown = Instance.new("TextBox", frame)
dropdown.Size = UDim2.new(1, -10, 0, 32)
dropdown.Position = UDim2.new(0, 5, 0, (#frame:GetChildren() - 1) * 35)
dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.PlaceholderText = "Furniture Name"

local function ReturnFurniture()
    local list = {}
    local f = ws:FindFirstChild("Wyposazenie")
    if not f then return list end

    for _, item in pairs(f:GetChildren()) do
        if item:IsA("Folder") then
            for _, model in ipairs(item:GetChildren()) do
                if model:IsA("Model") then
                    table.insert(list, model.Name)
                end
            end
        elseif item:IsA("Model") then
            table.insert(list, item.Name)
        end
    end
    return list
end

local btnBring = NewBtn("Bring Selected Furniture")
btnBring.MouseButton1Click:Connect(function()
    local selected = dropdown.Text
    if selected == "" then return end

    local f = ws:FindFirstChild("Wyposazenie")
    if not f then return end

    for _, item in pairs(f:GetChildren()) do
        if item:IsA("Folder") then
            for _, model in pairs(item:GetChildren()) do
                if model.Name == selected then
                    rs.PickupItemEvent:FireServer(model)
                end
            end
        elseif item.Name == selected then
            rs.PickupItemEvent:FireServer(item)
        end
    end
end)

-----------------------
-- Sound Spam
-----------------------
local soundSpam = false

local btnSound = NewBtn("Toggle Sound Spam")
btnSound.MouseButton1Click:Connect(function()
    soundSpam = not soundSpam
    task.spawn(function()
        while soundSpam do
            rs.SoundEvent:FireServer("Drink")
            rs.SoundEvent:FireServer("Eat")
            task.wait()
        end
    end)
end)

-----------------------
-- Monster ESP
-----------------------
local espON = false

local btnESP = NewBtn("Monster ESP")
btnESP.MouseButton1Click:Connect(function()
    espON = not espON

    task.spawn(function()
        while espON do
            local nightFolder
            for _, f in pairs(ws:GetChildren()) do
                if f:IsA("Folder") and f.Name:find("Night") then
                    nightFolder = f
                end
            end

            if nightFolder then
                for _, mob in ipairs(nightFolder:GetChildren()) do
                    if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                        if not mob:FindFirstChild("Highlight") then
                            Instance.new("Highlight", mob)
                        end
                    end
                end
            end

            task.wait(1)
        end

        -- remove highlight
        for _, f in pairs(ws:GetChildren()) do
            if f:IsA("Folder") and f.Name:find("Night") then
                for _, mob in ipairs(f:GetChildren()) do
                    local h = mob:FindFirstChild("Highlight")
                    if h then h:Destroy() end
                end
            end
        end
    end)
end)

-----------------------
-- Teleport
-----------------------
local btnBunker = NewBtn("Teleport: Bunker")
btnBunker.MouseButton1Click:Connect(function()
    local bunker = plr:GetAttribute("AssignedBunkerName")
    if bunker then
        local spawn = ws.Bunkers[bunker].SpawnLocation.CFrame
        plr.Character.HumanoidRootPart.CFrame = spawn
    end
end)

local btnMarket = NewBtn("Teleport: Market")
btnMarket.MouseButton1Click:Connect(function()
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(143, 5, -118)
end)

-----------------------
-- Hide UI
-----------------------
local hidden = false
game:GetService("UserInputService").InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.LeftControl then
        hidden = not hidden
        frame.Visible = not hidden
    end
end)

print("Dangerous Night Simple GUI Loaded Successfully")
