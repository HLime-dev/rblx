--//===========================
--//  Dangerous Night Dev Panel
--//  All-in-One Script (Rayfield)
--//===========================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Dangerous Night Developer Panel",
    LoadingTitle = "Initializing…",
    LoadingSubtitle = "Developer Tools",
    ConfigurationSaving = { Enabled = false }
})

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

local ItemsFolder = workspace:WaitForChild("Items")
local FoodsFolder = workspace:WaitForChild("Foods")

local FlyEnabled = false
local AutoFood = false
local SelectedItem = nil

local function getItemList()
    local list = {}
    for _, item in ipairs(ItemsFolder:GetChildren()) do
        table.insert(list, item.Name)
    end
    return list
end

local MainTab = Window:CreateTab("Main")

local ItemDropdown = MainTab:CreateDropdown({
    Name = "Pilih Item",
    Options = getItemList(),
    CurrentOption = "",
    Callback = function(option)
        SelectedItem = option
    end
})

MainTab:CreateButton({
    Name = "Refresh Daftar Item",
    Callback = function()
        ItemDropdown:Refresh(getItemList(), true)
    end
})

MainTab:CreateButton({
    Name = "Pickup Item Terpilih",
    Callback = function()
        if not SelectedItem then return end
        local target = ItemsFolder:FindFirstChild(SelectedItem)
        if target then
            hrp.CFrame = target.CFrame * CFrame.new(0, 3, 0)
            task.wait(.4)
            fireproximityprompt(target:FindFirstChildWhichIsA("ProximityPrompt"))
        end
    end
})

MainTab:CreateToggle({
    Name = "Auto Collect Food",
    CurrentValue = false,
    Callback = function(v) AutoFood = v end
})

task.spawn(function()
    while true do
        task.wait(.2)
        if AutoFood then
            for _, f in ipairs(FoodsFolder:GetChildren()) do
                local p = f:FindFirstChildWhichIsA("ProximityPrompt")
                if p then
                    hrp.CFrame = f.CFrame * CFrame.new(0, 3, 0)
                    task.wait(.15)
                    fireproximityprompt(p)
                end
            end
        end
    end
end)

MainTab:CreateSlider({
    Name = "Player Speed",
    Range = {16, 120},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(val) hum.WalkSpeed = val end
})

MainTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = function(v) FlyEnabled = v end
})

task.spawn(function()
    local UIS = game:GetService("UserInputService")
    while true do
        task.wait()
        if FlyEnabled then
            hum.PlatformStand = true
            local move = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then move += hrp.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then move -= hrp.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then move -= hrp.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then move += hrp.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            hrp.Velocity = move * 50
        else
            hum.PlatformStand = false
        end
    end
end)

MainTab:CreateButton({
    Name = "Drop Item di Inventory",
    Callback = function()
        local inv = player:WaitForChild("Backpack")
        for _, tool in ipairs(inv:GetChildren()) do
            tool.Parent = char
            task.wait(.1)
            tool:Deactivate()
            hum:UnequipTools()
        end
    end
})

Rayfield:Notify({
    Title = "Loaded",
    Content = "Developer panel siap!",
    Duration = 4
})
