-- Movement and Combat GUI by Juan Hub - Kavo UI (Team Check + Health Bar FIXED)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Movement & Combat | Juan Hub", "DarkTheme")

-- ==================== SERVICES ====================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player    = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid  = character:WaitForChild("Humanoid")
local rootPart  = character:WaitForChild("HumanoidRootPart")

-- ==================== MOVEMENT VARIABLES ====================
local flyEnabled          = false
local flySpeed            = 50
local walkSpeedEnabled    = false
local walkSpeedValue      = 50
local jumpPowerEnabled    = false
local jumpPowerValue      = 100
local infiniteJumpEnabled = false
local noclipEnabled       = false

-- ==================== ESP VARIABLES ====================
local espEnabled       = false
local boxesEnabled     = false
local namesEnabled     = false
local tracersEnabled   = false
local teamCheckEnabled = true
local healthBarEnabled = true

local espDrawings = {}
local camera = workspace.CurrentCamera

-- WalkSpeed + JumpPower
RunService.Heartbeat:Connect(function()
   if character and humanoid and humanoid.Parent then
      humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or 16
      humanoid.JumpPower = jumpPowerEnabled and jumpPowerValue or 50
   end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
   if infiniteJumpEnabled and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
      humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   end
end)

-- Fly
local flyBV = Instance.new("BodyVelocity")
flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
local flyBG = Instance.new("BodyGyro")
flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
flyBG.P = 15000

local function updateFly()
   if not flyEnabled or not rootPart then return end
   local cam = workspace.CurrentCamera
   local moveDir = Vector3.new()
   if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
   if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
   if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
   
   flyBV.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.new()
   flyBG.CFrame = cam.CFrame
end
RunService.RenderStepped:Connect(updateFly)

local function toggleFly(state)
   flyEnabled = state
   local root = character and character:FindFirstChild("HumanoidRootPart")
   if root then
      if state then
         flyBV.Parent = root
         flyBG.Parent = root
         humanoid.PlatformStand = true
      else
         flyBV.Parent = nil
         flyBG.Parent = nil
         humanoid.PlatformStand = false
      end
   end
end

-- Noclip
local noclipConn
local function toggleNoclip(state)
   noclipEnabled = state
   if state then
      if noclipConn then noclipConn:Disconnect() end
      noclipConn = RunService.Stepped:Connect(function()
         if character then
            for _, part in ipairs(character:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = false end
            end
         end
      end)
   else
      if noclipConn then noclipConn:Disconnect() end
   end
end

-- ==================== MAIN TAB ====================
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Movement Controls")

MainSection:NewToggle("Fly", "Vuelo libre con WASD + Space/Ctrl", function(s) toggleFly(s) end)
MainSection:NewSlider("Fly Speed", "Velocidad del vuelo", 500, 10, function(v) flySpeed = v end)
MainSection:NewToggle("Walk Speed", "Activar velocidad personalizada", function(s) walkSpeedEnabled = s end)
MainSection:NewSlider("Walk Speed Value", "Valor de WalkSpeed", 1000, 16, function(v) walkSpeedValue = v end)
MainSection:NewToggle("Jump Power", "Activar salto más alto", function(s) jumpPowerEnabled = s end)
MainSection:NewSlider("Jump Power Value", "Valor de JumpPower", 1000, 50, function(v) jumpPowerValue = v end)
MainSection:NewToggle("Infinite Jump", "Saltar infinitamente en el aire", function(s) infiniteJumpEnabled = s end)
MainSection:NewToggle("Noclip", "Atravesar paredes", function(s) toggleNoclip(s) end)

-- ==================== ESP SYSTEM ====================
local CombatTab = Window:NewTab("Combat")
local ESPSection = CombatTab:NewSection("ESP + Extras")

local function createESP(plr)
   if plr == player or espDrawings[plr] then return end
   
   local d = {
      box       = Drawing.new("Square"),
      name      = Drawing.new("Text"),
      tracer    = Drawing.new("Line"),
      healthBG  = Drawing.new("Square"),
      healthBar = Drawing.new("Square")
   }
   
   -- Box
   d.box.Thickness = 2; d.box.Filled = false; d.box.Transparency = 1; d.box.Color = Color3.fromRGB(255,0,0); d.box.Visible = false
   
   -- Name
   d.name.Size = 14; d.name.Center = true; d.name.Outline = true; d.name.Color = Color3.new(1,1,1); d.name.Transparency = 1; d.name.Visible = false
   
   -- Tracer
   d.tracer.Thickness = 1.5; d.tracer.Transparency = 0.8; d.tracer.Color = Color3.fromRGB(0,255,255); d.tracer.Visible = false
   
   -- Health Bar
   d.healthBG.Filled = true; d.healthBG.Transparency = 0.6; d.healthBG.Color = Color3.fromRGB(20,20,20); d.healthBG.Visible = false
   d.healthBar.Filled = true; d.healthBar.Transparency = 1; d.healthBar.Visible = false
   
   espDrawings[plr] = d
end

local function updateESP()
   for plr, d in pairs(espDrawings) do
      local char = plr.Character
      if not (espEnabled and char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0) then
         if d.box then d.box.Visible = false end
         if d.name then d.name.Visible = false end
         if d.tracer then d.tracer.Visible = false end
         if d.healthBG then d.healthBG.Visible = false end
         if d.healthBar then d.healthBar.Visible = false end
         continue
      end

      -- TEAM CHECK
      if teamCheckEnabled and plr.Team == player.Team and not plr.Neutral then
         d.box.Visible = false; d.name.Visible = false; d.tracer.Visible = false
         d.healthBG.Visible = false; d.healthBar.Visible = false
         continue
      end

      local root = char.HumanoidRootPart
      local vector, onScreen = camera:WorldToViewportPoint(root.Position)

      if onScreen then
         local boxHeight = 5.8
         local boxWidth  = boxHeight / 2.1
         local rootPos   = root.Position

         -- BOX
         d.box.Visible = boxesEnabled
         if boxesEnabled then
            d.box.Size = Vector2.new(boxWidth, boxHeight)
            d.box.Position = Vector2.new(vector.X - boxWidth/2, vector.Y - boxHeight/2)
         end

         -- NAME + DISTANCIA
         d.name.Visible = namesEnabled
         if namesEnabled then
            local dist = math.floor((rootPart.Position - rootPos).Magnitude)
            d.name.Text = string.format("%s [%dm]", plr.Name, dist)
            d.name.Position = Vector2.new(vector.X, vector.Y - boxHeight/2 - 22)
         end

         -- TRACER
         d.tracer.Visible = tracersEnabled
         if tracersEnabled then
            d.tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
            d.tracer.To = Vector2.new(vector.X, vector.Y)
         end

         -- HEALTH BAR
         if healthBarEnabled then
            local hp = char.Humanoid.Health / char.Humanoid.MaxHealth
            local barColor = Color3.fromHSV(hp * 0.33, 1, 1)
            
            local barX = vector.X - boxWidth/2 - 10
            local barY = vector.Y - boxHeight/2
            
            d.healthBG.Visible = true
            d.healthBG.Size = Vector2.new(5, boxHeight)
            d.healthBG.Position = Vector2.new(barX, barY)
            
            d.healthBar.Visible = true
            d.healthBar.Size = Vector2.new(5, boxHeight * hp)
            d.healthBar.Position = Vector2.new(barX, barY + boxHeight * (1 - hp))
            d.healthBar.Color = barColor
         else
            d.healthBG.Visible = false
            d.healthBar.Visible = false
         end
      else
         d.box.Visible = false; d.name.Visible = false; d.tracer.Visible = false
         d.healthBG.Visible = false; d.healthBar.Visible = false
      end
   end
end

RunService.RenderStepped:Connect(updateESP)

-- Setup players
local function setup(plr)
   if plr == player then return end
   plr.CharacterAdded:Connect(function() task.wait(0.4) if espEnabled then createESP(plr) end end)
   if plr.Character then task.wait(0.4) if espEnabled then createESP(plr) end end
end
for _, p in Players:GetPlayers() do setup(p) end
Players.PlayerAdded:Connect(setup)

-- ==================== ESP TOGGLES ====================
ESPSection:NewToggle("Enable ESP", "Activar todo el sistema", function(s)
   espEnabled = s
   if s then
      for _, p in Players:GetPlayers() do
         if p ~= player and not espDrawings[p] then createESP(p) end
      end
   end
end)

ESPSection:NewToggle("Boxes", "Cajas alrededor del jugador", function(s) boxesEnabled = s end)
ESPSection:NewToggle("Names + Distancia", "Nombre con metros arriba", function(s) namesEnabled = s end)
ESPSection:NewToggle("Tracers", "Líneas desde abajo", function(s) tracersEnabled = s end)
ESPSection:NewToggle("Team Check", "No mostrar ESP a compañeros", function(s) teamCheckEnabled = s end)
ESPSection:NewToggle("Health Bars", "Barra de vida a la izquierda", function(s) healthBarEnabled = s end)

-- Respawn
player.CharacterAdded:Connect(function(new)
   character = new
   humanoid = new:WaitForChild("Humanoid")
   rootPart = new:WaitForChild("HumanoidRootPart")
   if flyEnabled then toggleFly(true) end
   if noclipEnabled then toggleNoclip(true) end
end)

Library:Notify("✅ Arreglado!", "Team Check + Health Bar funcionando correctamente.\nRightShift para abrir menú.")
