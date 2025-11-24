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
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
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
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character.Humanoid.JumpPower = val
      end
   end,
})

-------------------------------------------------------
--==================== NDS =====================--
-------------------------------------------------------

local MiscTab = Window:CreateTab("NDS", 4483362458)

MiscTab:CreateButton({
   Name = "anti fall dmg",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Natural-Disaster-Survival-No-fall-damage-68524"))()
   end,
})

-------------------------------------------------------
--================== flygui ===================--
-------------------------------------------------------

local flyguitab= Window:CreateTab("fly gui", 4483362458)

flyguitab:CreateButton({
   Name = "fly gui v3",
   Callback=function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Fly-Gui-V3-59173"))()
   end,
})

loadstring(game:HttpGet("https://pastefy.app/JW1n7G8M/raw"))()

local shadertab= Window:CreateTab("shader", 4483362458)

shadertab:CreateButton({
   Name = "shader",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Premium-RTX-Shader-59847"))()
   end,
})

-------------------------------------------------------
--==================== son! ====================--
-------------------------------------------------------

local hubtab= Window:CreateTab("Hub universal", 4483362458)

hubtab:CreateButton({
   Name = "Ghost hub",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Ghost-hub-keyless-65732"))()
   end,
})

hubtab:CreateButton({
   Name = "Get Key",
   Callback = function()
      setclipboard("KEY_01055d471d040858521b5d595c")
   end,
})

-------------------------------------------------------
--==================== Aimlock ====================--
-------------------------------------------------------

local aimlocktab= Window:CreateTab("aimlock", 4483362458)

aimlocktab:CreateButton({
   Name = "aimlock",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-op-aimlock-made-by-dontscare1-68016"))()
   end,
})

local tsbgtab= Window:CreateTab("tsbg", 4483362458)

tsbgtab:CreateButton({
   Name = "kars Saitama",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/OfficialAposty/RBLX-Scripts/refs/heads/main/UltimateLifeForm.lua"))()
   end,
})

tsbgtab:CreateButton({
   Name = "gojo sixeyes Saitama",
   Callback = function()
      getgenv().morph = true
      loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/BaldyToSorcerer/refs/heads/main/LatestV2.lua"))()
   end,
})

tsbgtab:CreateButton({
   Name = "sukuna v2 Saitama",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/damir512/whendoesbrickdie/main/tspno.txt",true))()
   end,
})

tsbgtab:CreateButton({
   Name = "Shinji Saitama",
   Callback = function()
      getgenv().speedtools = false --- set true if you want use this tool if you want to run
      getgenv().speedpunch= true --- tp and normal Punch
      getgenv().dance= true --- set true if you want to this dance song made by rebzyyx all I want is you
      getgenv().night= true -- set true if you want to day to night
      loadstring(game:HttpGet('https://raw.githubusercontent.com/Kenjihin69/Kenjihin69/refs/heads/main/Shinji%20tp%20exploit'))()
   end,
})
