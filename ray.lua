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
--================== UTILITY TAB ====================--
-------------------------------------------------------

local UtilityTab = Window:CreateTab("Utility", 4483362458)

-- ESP
UtilityTab:CreateButton({
   Name = "ESP",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/Lucasfin000/SpaceHub/main/UESP'))()
   end,
})

-- Walkspeed
UtilityTab:CreateSlider({
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

-- JumpPower
UtilityTab:CreateSlider({
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

-- Anti Fall Damage
UtilityTab:CreateButton({
   Name = "Anti Fall Damage",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
   end,
})

-- Fly GUI
UtilityTab:CreateButton({
   Name = "Fly GUI V3",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
   end,
})
