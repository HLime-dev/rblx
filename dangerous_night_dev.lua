-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Rayfield Test UI",
    LoadingTitle = "Testing...",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- Tab
local Tab = Window:CreateTab("Main", 4483362458)

-- Label
Tab:CreateLabel("Jika ini muncul, Rayfield kamu berfungsi.")

-- Button
Tab:CreateButton({
    Name = "Test Button",
    Callback = function()
        print("Button pressed!")
    end,
})

-- Toggle
Tab:CreateToggle({
    Name = "Test Toggle",
    CurrentValue = false,
    Callback = function(v)
        print("Toggle:", v)
    end,
})
