--// Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window
local Window = Rayfield:CreateWindow({
    Name = "novaRyn",
    LoadingTitle = "Nova",
    LoadingSubtitle = "by Sixeyes",
    ConfigurationSaving = { Enabled = false },
})

local players = game:GetService("Players")
local plr = players.LocalPlayer
local bunkerName = plr:GetAttribute("AssignedBunkerName")

--// Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)

-- Noclip Toggle
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(b)
        getgenv().noclip = b
        if noclip then
            local function NoclipLoop()
                if plr.Character then
                    for _, child in pairs(plr.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide then
                            child.CanCollide = false
                        end
                    end
                end
            end
            Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)
        else
            if Noclipping then
                Noclipping:Disconnect()
                Noclipping = nil
            end
        end
    end
})

-- WalkSpeed Box
MainTab:CreateInput({
    Name = "WalkSpeed",
    PlaceholderText = "Enter WalkSpeed",
    RemoveTextAfterFocusLost = false,
    Callback = function(ws)
        if tonumber(ws) then
            plr.Character:FindFirstChild("Humanoid").WalkSpeed = tonumber(ws)
        end
    end
})

-- Collect All Food Button
MainTab:CreateButton({
    Name = "Collect All Food",
    Callback = function()
        local lastPos = plr.Character:FindFirstChild("HumanoidRootPart").CFrame
        for _, food in pairs(game:GetService("Workspace"):GetChildren()) do
            if food:IsA("Tool") then
                local handle = food:FindFirstChild("Handle")
                local prompt = handle and handle:FindFirstChildOfClass("ProximityPrompt")
                if handle and prompt then
                    plr.Character.HumanoidRootPart.CFrame = handle.CFrame * CFrame.new(0,5,0)
                    task.wait(0.25)
                    fireproximityprompt(prompt, prompt.MaxActivationDistance)
                end
            end
        end
        task.wait(0.25)
        plr.Character.HumanoidRootPart.CFrame = lastPos
    end
})

-- Drop All Food Button
MainTab:CreateButton({
    Name = "Drop All Food",
    Callback = function()
        local lastPos = plr.Character.HumanoidRootPart.CFrame
        for _, food in pairs(plr.Backpack:GetChildren()) do
            food.Parent = plr.Character
        end
        task.wait(0.25)
        plr.Character:FindFirstChildOfClass("Humanoid").Health = 0

        task.spawn(function()
            local function onCharacterAdded(char)
                local hrp = char:WaitForChild("HumanoidRootPart", 5)
                if hrp and lastPos then
                    task.wait(0.5)
                    hrp.CFrame = lastPos
                end
            end

            if not plr.Character or plr.Character:FindFirstChildOfClass("Humanoid").Health == 0 then
                plr.CharacterAdded:Wait()
                onCharacterAdded(plr.Character)
            end
        end)
    end
})

-- Furniture Dropdown + Bring Button
local sele
