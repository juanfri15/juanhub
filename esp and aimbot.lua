local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Movement & Combat | Juan Hub", "DarkTheme")

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid", 5)
local rootPart = character:WaitForChild("HumanoidRootPart", 5)
local camera = workspace.CurrentCamera

-- ==================== MOVEMENT VARIABLES ====================
local flyEnabled = false
local flySpeed = 50
local walkSpeedEnabled = false
local walkSpeedValue = 50
local jumpPowerEnabled = false
local jumpPowerValue = 100
local infiniteJumpEnabled = false
local noclipEnabled = false
local speedBV = Instance.new("BodyVelocity")
speedBV.MaxForce = Vector3.new(1e5, 0, 1e5)
speedBV.Velocity = Vector3.new()
speedBV.Parent = nil

-- ==================== ESP VARIABLES ====================
local espEnabled = false
local boxesEnabled = false
local namesEnabled = false
local tracersEnabled = false
local teamCheckEnabled = true
local healthBarEnabled = false
local espDrawings = {}

-- ==================== AIMBOT VARIABLES ====================
local aimbotEnabled = false
local fovRadius = 150
local onlyVisibleEnabled = true
local showFOVEnabled = false
local aimSmoothing = 3
local predictionEnabled = false
local predictionAmount = 0.15
local aimPart = "Head"
local triggerbotEnabled = false
local noRecoilEnabled = false
local lastShot = 0
local aiming = false

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Transparency = 0.6
fovCircle.Filled = false
fovCircle.NumSides = 64

-- WalkSpeed Bypass
local function updateSpeed()
   if not character or not humanoid or not rootPart then return end
   if walkSpeedEnabled then
      humanoid.WalkSpeed = walkSpeedValue
      speedBV.Velocity = humanoid.MoveDirection * walkSpeedValue * 2
      if not speedBV.Parent then speedBV.Parent = rootPart end
   else
      humanoid.WalkSpeed = 16
      speedBV.Velocity = Vector3.new()
      speedBV.Parent = nil
   end
   if jumpPowerEnabled then
      humanoid.JumpPower = jumpPowerValue
      if not humanoid.UseJumpPower then
         humanoid.JumpHeight = jumpPowerValue / 7.2
      end
   else
      humanoid.JumpPower = 50
      humanoid.JumpHeight = 7.2
   end
end
RunService.RenderStepped:Connect(updateSpeed)

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

-- ==================== NOCLIP ====================
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
      if noclipConn then noclipConn:Disconnect() noclipConn = nil end
      if character then
         for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
         end
      end
   end
end

-- ==================== AIMBOT INPUT ====================
UserInputService.InputBegan:Connect(function(input, gp)
   if gp then return end
   if input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = true end
end)
UserInputService.InputEnded:Connect(function(input, gp)
   if gp then return end
   if input.UserInputType == Enum.UserInputType.MouseButton2 then aiming = false end
end)

-- ==================== MAIN TAB ====================
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Movement Controls")
MainSection:NewToggle("Fly", "Vuelo libre con WASD + Space/Ctrl", function(s) toggleFly(s) end)
MainSection:NewSlider("Fly Speed", "Velocidad del vuelo", 500, 10, function(v) flySpeed = v end)
MainSection:NewToggle("Walk Speed", "Activar velocidad personalizada (bypass)", function(s) walkSpeedEnabled = s end)
MainSection:NewSlider("Walk Speed Value", "Valor (prueba 50-200)", 200, 16, function(v) walkSpeedValue = v end)
MainSection:NewToggle("Jump Power", "Activar salto más alto", function(s) jumpPowerEnabled = s end)
MainSection:NewSlider("Jump Power Value", "Valor (prueba 100-300)", 300, 50, function(v) jumpPowerValue = v end)
MainSection:NewToggle("Infinite Jump", "Saltar infinitamente en el aire", function(s) infiniteJumpEnabled = s end)
MainSection:NewToggle("Noclip", "Atravesar paredes", function(s) toggleNoclip(s) end)

-- ==================== COMBAT TAB ====================
local CombatTab = Window:NewTab("Combat")
local EspSection = CombatTab:NewSection("ESP + Aimbot")

EspSection:NewToggle("Enable ESP", "Activar todo el ESP (maestro)", function(s) espEnabled = s end)
EspSection:NewToggle("Boxes", "Cajas 2D alrededor de jugadores", function(s) boxesEnabled = s end)
EspSection:NewToggle("Names", "Nombres encima de la cabeza", function(s) namesEnabled = s end)
EspSection:NewToggle("Tracers", "Líneas desde la parte inferior de la pantalla", function(s) tracersEnabled = s end)
EspSection:NewToggle("Health Bar", "Barra de vida lateral (rojo → verde)", function(s) healthBarEnabled = s end)
EspSection:NewToggle("Team Check", "Ocultar jugadores del mismo equipo", function(s) teamCheckEnabled = s end)

-- AIMBOT CONTROLES (mantengo el smoothing que ya funcionaba)
EspSection:NewToggle("Aimbot", "Apunta automáticamente (mantén clic derecho)", function(s) aimbotEnabled = s end)
EspSection:NewSlider("FOV Radius", "Radio del campo de visión", 800, 50, function(v) fovRadius = v end)
EspSection:NewToggle("Only Visible", "Solo apunta a jugadores visibles (sin paredes)", function(s) onlyVisibleEnabled = s end)
EspSection:NewToggle("Show FOV Circle", "Mostrar círculo de FOV en pantalla", function(s) showFOVEnabled = s end)
EspSection:NewSlider("Smoothing", "0 = INSTANTÁNEO | 10 = Muy suave y lento", 10, 0, function(v) aimSmoothing = v end)

-- NUEVAS OPCIONES (añadidas sin romper nada)
EspSection:NewToggle("Prediction", "Adelanta el movimiento del objetivo", function(s) predictionEnabled = s end)
EspSection:NewSlider("Prediction Strength", "0.0 - 0.5 (más alto = más adelante)", 0.5, 0, function(v) predictionAmount = v end)

EspSection:NewDropdown("Aim Part", "Dónde apunta el aimbot", {"Head", "Torso", "LowerTorso", "Random"}, function(selected)
   aimPart = selected
end)

EspSection:NewToggle("Triggerbot", "Dispara automáticamente al apuntar", function(s) triggerbotEnabled = s end)
EspSection:NewToggle("No Recoil", "Elimina retroceso del arma", function(s) noRecoilEnabled = s end)

-- ==================== FUNCIONES AUXILIARES ====================
local function isEnemy(otherPlayer)
   if not teamCheckEnabled then return true end
   if player.Team == nil or otherPlayer.Team == nil then return true end
   return otherPlayer.Team ~= player.Team
end

local function isVisible(targetChar)
   if not onlyVisibleEnabled then return true end
   local targetPart = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
   if not targetPart then return false end
   local origin = camera.CFrame.Position
   local direction = targetPart.Position - origin
   local raycastParams = RaycastParams.new()
   raycastParams.FilterDescendantsInstances = {character}
   raycastParams.FilterType = Enum.RaycastFilterType.Exclude
   raycastParams.IgnoreWater = true
   local result = workspace:Raycast(origin, direction, raycastParams)
   if result then
      return result.Instance:IsDescendantOf(targetChar)
   end
   return true
end

local function getAimPart(char)
   if aimPart == "Random" then
      local parts = {"Head", "Torso", "LowerTorso"}
      return char:FindFirstChild(parts[math.random(1,#parts)]) or char:FindFirstChild("Head")
   end
   return char:FindFirstChild(aimPart) or char:FindFirstChild("Head")
end

local function getClosestTarget()
   local closestDist = math.huge
   local closestPlayer = nil
   local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
   for _, otherPlayer in ipairs(Players:GetPlayers()) do
      if otherPlayer == player then continue end
      if not isEnemy(otherPlayer) then continue end
      local char = otherPlayer.Character
      if not char then continue end
      local hum = char:FindFirstChild("Humanoid")
      if not hum or hum.Health <= 0 then continue end
      local targetPart = getAimPart(char)
      if not targetPart then continue end
      local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
      if not onScreen then continue end
      local distToCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
      if distToCenter > fovRadius then continue end
      if not isVisible(char) then continue end
      if distToCenter < closestDist then
         closestDist = distToCenter
         closestPlayer = otherPlayer
      end
   end
   return closestPlayer
end

-- ==================== AIMBOT LOOP (con prediction y triggerbot) ====================
local function updateAimbot()
   if not aimbotEnabled or not aiming then return end
   local targetPlayer = getClosestTarget()
   if not targetPlayer then return end
   local char = targetPlayer.Character
   local targetPart = getAimPart(char)
   if not targetPart then return end

   local targetPos = targetPart.Position
   if predictionEnabled and targetPart.AssemblyLinearVelocity then
      targetPos = targetPos + targetPart.AssemblyLinearVelocity * predictionAmount
   end

   local targetCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
   local lerpFactor = 1 / (aimSmoothing + 1)
   camera.CFrame = camera.CFrame:Lerp(targetCFrame, lerpFactor)

   -- Triggerbot
   if triggerbotEnabled and tick() - lastShot > 0.08 then
      local tool = player.Character:FindFirstChildOfClass("Tool")
      if tool then
         game:GetService("VirtualUser"):Button1Down(Vector2.new())
         game:GetService("VirtualUser"):Button1Up(Vector2.new())
         lastShot = tick()
      end
   end
end
RunService.RenderStepped:Connect(updateAimbot)

-- ==================== NO RECOIL (simple y seguro) ====================
RunService.RenderStepped:Connect(function()
   if noRecoilEnabled then
      camera.CFrame = camera.CFrame * CFrame.Angles(0,0,0)
   end
end)

-- ==================== FOV CIRCLE ====================
local function updateFOVCircle()
   fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
   fovCircle.Radius = fovRadius
   fovCircle.Visible = showFOVEnabled and aimbotEnabled
end
RunService.RenderStepped:Connect(updateFOVCircle)

-- ==================== ESP (exacto el que ya funcionaba) ====================
local function hidePlayerESP(plr)
   if not espDrawings[plr] then return end
   local d = espDrawings[plr]
   if d.box then d.box.Visible = false end
   if d.name then d.name.Visible = false end
   if d.tracer then d.tracer.Visible = false end
   if d.healthOutline then d.healthOutline.Visible = false end
   if d.healthFill then d.healthFill.Visible = false end
end

local function updateESP()
   if not espEnabled then
      for plr, _ in pairs(espDrawings) do hidePlayerESP(plr) end
      return
   end
   for _, otherPlayer in ipairs(Players:GetPlayers()) do
      if otherPlayer == player then continue end
      if not isEnemy(otherPlayer) then
         hidePlayerESP(otherPlayer)
         continue
      end
      local char = otherPlayer.Character
      local root = char and char:FindFirstChild("HumanoidRootPart")
      local hum = char and char:FindFirstChild("Humanoid")
      local head = char and char:FindFirstChild("Head")
      if not char or not root or not hum or hum.Health <= 0 then
         hidePlayerESP(otherPlayer)
         continue
      end
      local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
      if not onScreen then
         hidePlayerESP(otherPlayer)
         continue
      end
      if not espDrawings[otherPlayer] then
         espDrawings[otherPlayer] = {
            box = Drawing.new("Square"),
            name = Drawing.new("Text"),
            tracer = Drawing.new("Line"),
            healthOutline = Drawing.new("Square"),
            healthFill = Drawing.new("Square"),
         }
         local d = espDrawings[otherPlayer]
         d.box.Thickness = 2; d.box.Filled = false; d.box.Transparency = 1
         d.name.Size = 14; d.name.Center = true; d.name.Outline = true; d.name.Transparency = 1
         d.tracer.Thickness = 2; d.tracer.Transparency = 1
         d.healthOutline.Filled = false; d.healthOutline.Thickness = 1; d.healthOutline.Transparency = 1
         d.healthFill.Filled = true; d.healthFill.Transparency = 1
      end
      local d = espDrawings[otherPlayer]
      local headPos = head and camera:WorldToViewportPoint(head.Position) or rootPos
      local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
      local boxHeight = math.abs(headPos.Y - legPos.Y)
      local boxWidth = boxHeight / 1.8
      d.box.Size = Vector2.new(boxWidth, boxHeight)
      d.box.Position = Vector2.new(rootPos.X - boxWidth/2, math.min(headPos.Y, legPos.Y))
      d.box.Color = Color3.fromRGB(255,0,0)
      d.box.Visible = boxesEnabled

      d.name.Position = Vector2.new(rootPos.X, headPos.Y - 25)
      d.name.Text = otherPlayer.Name
      d.name.Color = Color3.fromRGB(255,255,255)
      d.name.Visible = namesEnabled

      d.tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
      d.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
      d.tracer.Color = Color3.fromRGB(255,0,0)
      d.tracer.Visible = tracersEnabled

      local hp = hum.Health / hum.MaxHealth
      local barX = d.box.Position.X - 10
      local barY = d.box.Position.Y
      local barH = d.box.Size.Y
      d.healthOutline.Position = Vector2.new(barX, barY)
      d.healthOutline.Size = Vector2.new(4, barH)
      d.healthOutline.Color = Color3.fromRGB(0,0,0)
      d.healthOutline.Visible = healthBarEnabled

      local fillH = barH * hp
      d.healthFill.Position = Vector2.new(barX + 0.5, barY + barH - fillH)
      d.healthFill.Size = Vector2.new(3, fillH)
      d.healthFill.Color = Color3.fromRGB(255*(1-hp), 255*hp, 0)
      d.healthFill.Visible = healthBarEnabled
   end
end
RunService.RenderStepped:Connect(updateESP)

Players.PlayerRemoving:Connect(function(plr)
   if espDrawings[plr] then
      local d = espDrawings[plr]
      if d.box then d.box:Remove() end
      if d.name then d.name:Remove() end
      if d.tracer then d.tracer:Remove() end
      if d.healthOutline then d.healthOutline:Remove() end
      if d.healthFill then d.healthFill:Remove() end
      espDrawings[plr] = nil
   end
end)

-- ==================== RESPAWN ====================
player.CharacterAdded:Connect(function(newChar)
   task.wait(0.3)
   character = newChar
   humanoid = newChar:WaitForChild("Humanoid", 5)
   rootPart = newChar:WaitForChild("HumanoidRootPart", 5)
   if flyEnabled then toggleFly(true) end
   if noclipEnabled then toggleNoclip(true) end
   speedBV.Parent = nil
   updateSpeed()
end)

