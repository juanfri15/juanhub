local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "juanfrihub",
   Icon = 0,
   LoadingTitle = "juanfrihub",
   LoadingSubtitle = "by juanfri",
   ShowText = "juanfrihub",
   Theme = "Amethyst",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "juanfri HUB"
   },

   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true 
   },

   KeySystem = true,
   KeySettings = {
      Title = "juanfri hub key",
      Subtitle = "en progeso",
      Note = "key dada por juanfri",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = true,
      Key = {"https://pastebin.com/raw/KeSJL5sx"}
   }
})

local MainTab = Window:CreateTab("🏠home", nil)
local MainSection = MainTab:CreateSection("Main")

Rayfield:Notify({
   Title = "hi",
   Content = "good gui",
   Duration = 4,
   Image = nil,
})

local Button = MainTab:CreateButton({
   Name = "infinite jump",
   Callback = function()
   loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/Infinite%20Jump.lua"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "fly",
   Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()

   end,
})

local Button = MainTab:CreateButton({
   Name = "noclip",
   Callback = function()
   loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/Noclip.lua"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "infinite yield",
   Callback = function()
   loadstring(game:HttpGet("https://obj.wearedevs.net/2/scripts/Infinite%20Yield.lua"))()
   end,
})

local Button = MainTab:CreateButton({
   Name = "esp",
   Callback = function()
   loadstring(game:HttpGet("https://obj.wearedevs.net/s/611c5e8f37f27bdc436897be.lua"))()
   end,
})
