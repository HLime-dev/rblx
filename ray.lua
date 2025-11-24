--// Load Rayfield UI Library 
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// Window 
local Window = Rayfield:CreateWindow({
   Name = "novaRyn",
   LoadingTitle = "Nova",
   LoadingSubtitle = "by Sixeyes",
   ConfigurationSaving = {
      Enabled = false,
   },
})

-------------------------------------------------------
--==================== ESP TAB ======================--
-------------------------------------------------------

local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateButton({
   Name = "ESP",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
   end,
})

-------------------------------------------------------
--=================== PLAYER TAB ====================--
-------------------------------------------------------

local PlayerTab = Window:CreateTab("Player", 4483362458)

PlayerTab:CreateSlider({
   Name = "Walkspeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Flag = "ws",
   Callback = function(val)
      local char = game.Players.LocalPlayer.Character
      if char then
         char.Humanoid.WalkSpeed = val
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 200},
   Increment = 1,
   CurrentValue = 50,
   Flag = "jp",
   Callback = function(val)
      local char = game.Players.LocalPlayer.Character
      if char then
         char.Humanoid.JumpPower = val
      end
   end,
})

-------------------------------------------------------
--==================== NDS TAB =====================--
-------------------------------------------------------

local NDSTab = Window:CreateTab("NDS", 4483362458)

NDSTab:CreateButton({
   Name = "Anti Fall Damage",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
   end,
})

-------------------------------------------------------
--==================== FLY TAB =====================--
-------------------------------------------------------

local FlyTab = Window:CreateTab("Fly", 4483362458)

FlyTab:CreateButton({
   Name = "Fly GUI V3",
   Callback=function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
   end,
})
