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
local MainTab = Window:CreateTab("Main", 4483362458)       -- tab icon 1
local TeleTab = Window:CreateTab("Teleport", 4483362459)   -- tab icon 2
local SettingsTab = Window:CreateTab("Settings", 4483362460) -- tab icon 3

