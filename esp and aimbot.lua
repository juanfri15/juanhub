-- Movement and Combat GUI by Juan Hub using Rayfield Library (ESP COMPLETO EN COMBAT)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Movement and Combat by Juan Hub",
   LoadingTitle = "Juan Hub",
   LoadingSubtitle = "by Juan",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- ==================== PESTAÑA MAIN (Movement) ====================
local MainTab = Window:CreateTab("Main", nil)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variables Movement
local flyEnabled = false
local flySpeed = 50
local walkSpeedEnabled = false
local walkSpeedValue = 50
local jumpPowerEnabled = false
local jumpPowerValue = 100
local infiniteJumpEnabled = false
local noclipEnabled = false

-- LOOP WalkSpeed + JumpPower
game:GetService("RunService").Heartbeat:Connect(function()
   if character and humanoid then
      humanoid.WalkSpeed = walkSpeedEnabled and walkSpeedValue or 16
      humanoid.JumpPower = jumpPowerEnabled and jumpPowerValue or 50
   end
end)

-- Infinite Jump
game:GetService("UserInputService").JumpRequest:Connect(function()
   if infiniteJumpEnabled and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
      humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   end
end)

-- Fly Setup
local flyBV = Instance.new("BodyVelocity")
flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
local flyBG = Instance.new("BodyGyro")
flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

local function startFly()
   local root = character:FindFirstChild("HumanoidRootPart")
   if root then
      flyBV.Parent = root
      flyBG.Parent = root
   end
   humanoid.PlatformStand = true
end

local function stopFly()
   flyBV.Parent = nil
   flyBG.Parent = nil
   humanoid.PlatformStand = false
end

local function updateFly()
   if flyEnabled then
      startFly()
      local cam = workspace.CurrentCamera
      local moveDir = Vector3.new(0, 0, 0)
      local UIS = game:GetService("UserInputService")
      if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
      if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
      if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
      if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
      flyBV.Velocity = moveDir * flySpeed
      flyBG.CFrame = cam.CFrame
   else
      stopFly()
   end
end
game:GetService("RunService").RenderStepped:Connect(updateFly)

-- Noclip
local function setNoclip(state)
   if character then
      for _, part in pairs(character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = not state
         end
      end
   end
end

game:GetService("RunService").Stepped:Connect(function()
   if noclipEnabled then
      setNoclip(true)
   end
end)
setNoclip(false)

-- ==================== ELEMENTOS MAIN ====================
MainTab:CreateToggle({ Name = "Fly", CurrentValue = false, Callback = function(v) flyEnabled = v end })
MainTab:CreateSlider({ Name = "Fly Speed", Range = {10, 300}, Increment = 1, Suffix = "Speed", CurrentValue = 50, Callback = function(v) flySpeed = v end })
MainTab:CreateToggle({ Name = "Walk Speed", CurrentValue = false, Callback = function(v) walkSpeedEnabled = v end })
MainTab:CreateSlider({ Name = "Walk Speed Value", Range = {16, 500}, Increment = 1, Suffix = "Speed", CurrentValue = 50, Callback = function(v) walkSpeedValue = v end })
MainTab:CreateToggle({ Name = "Jump Power", CurrentValue = false, Callback = function(v) jumpPowerEnabled = v end })
MainTab:CreateSlider({ Name = "Jump Power Value", Range = {50, 500}, Increment = 1, Suffix = "Power", CurrentValue = 100, Callback = function(v) jumpPowerValue = v end })
MainTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Callback = function(v) infiniteJumpEnabled = v end })
MainTab:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) noclipEnabled = v if not v then setNoclip(false) end end })
MainTab:CreateButton({ Name = "Minimizar GUI", Callback = function() Rayfield:Notify({Title = "Cómo minimizar", Content = "Haz clic en la flecha ↓ arriba del GUI", Duration = 6}) end })

-- ==================== ESP SYSTEM (para Combat) ====================
local Players = game:GetService("Players")
local camera = workspace.CurrentCamera

local espEnabled = false
local boxesEnabled = false
local namesEnabled = false
local tracersEnabled = false
local espDrawings = {}

local function createESP(plr)
   if plr == player or espDrawings[plr] then return end
   
   local drawings = {
      box = Drawing.new("Square"),
      name = Drawing.new("Text"),
      tracer = Drawing.new("Line")
   }
   
   drawings.box.Thickness = 2
   drawings.box.Filled = false
   drawings.box.Transparency = 0.85
   drawings.box.Color = Color3.fromRGB(255, 0, 0)
   
   drawings.name.Size = 14
   drawings.name.Center = true
   drawings.name.Outline = true
   drawings.name.Color = Color3.fromRGB(255, 255, 255)
   drawings.name.Transparency = 1
   
   drawings.tracer.Thickness = 1.5
   drawings.tracer.Transparency = 0.7
   drawings.tracer.Color = Color3.fromRGB(0, 255, 255)
   
   espDrawings[plr] = drawings
end

local function updateESP()
   for plr, drawings in pairs(espDrawings) do
      if espEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
         local root = plr.Character.HumanoidRootPart
         local pos, onScreen = camera:WorldToViewportPoint(root.Position)
         
         if onScreen then
            -- Box
            local headY = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2.5, 0)).Y
            local legY = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y
            local boxHeight = headY - legY
            local boxWidth = boxHeight / 2.2
            
            if boxesEnabled then
               drawings.box.Visible = true
               drawings.box.Size = Vector2.new(boxWidth, boxHeight)
               drawings.box.Position = Vector2.new(pos.X - boxWidth/2, legY)
            else
               drawings.box.Visible = false
            end
            
            -- Name
            if namesEnabled then
               drawings.name.Visible = true
               local dist = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
               drawings.name.Text = plr.Name .. " (" .. dist .. "m)"
               drawings.name.Position = Vector2.new(pos.X, legY - 18)
            else
               drawings.name.Visible = false
            end
            
            -- Tracer
            if tracersEnabled then
               drawings.tracer.Visible = true
               drawings.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y - 20)
               drawings.tracer.To = Vector2.new(pos.X, pos.Y)
            else
               drawings.tracer.Visible = false
            end
         else
            drawings.box.Visible = false
            drawings.name.Visible = false
            drawings.tracer.Visible = false
         end
      else
         if drawings.box then drawings.box.Visible = false end
         if drawings.name then drawings.name.Visible = false end
         if drawings.tracer then drawings.tracer.Visible = false end
      end
   end
end

game:GetService("RunService").RenderStepped:Connect(updateESP)

-- Auto-crear ESP para jugadores nuevos y existentes
Players.PlayerAdded:Connect(function(plr)
   plr.CharacterAdded:Connect(function()
      task.wait(0.6)
      if espEnabled then createESP(plr) end
   end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
   if plr ~= player then
      if plr.Character then task.wait(0.6) if espEnabled then createESP(plr) end end
      plr.CharacterAdded:Connect(function() task.wait(0.6) if espEnabled then createESP(plr) end end)
   end
end

Players.PlayerRemoving:Connect(function(plr)
   if espDrawings[plr] then
      for _, d in pairs(espDrawings[plr]) do d:Remove() end
      espDrawings[plr] = nil
   end
end)

-- ==================== PESTAÑA COMBAT ====================
local CombatTab = Window:CreateTab("Combat", nil)

CombatTab:CreateLabel("🔥 ESP System")
CombatTab:CreateToggle({
   Name = "Enable ESP",
   CurrentValue = false,
   Callback = function(Value)
      espEnabled = Value
      if Value then
         for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and not espDrawings[plr] then
               createESP(plr)
            end
         end
      end
   end
})

CombatTab:CreateToggle({
   Name = "Boxes",
   CurrentValue = false,
   Callback = function(Value) boxesEnabled = Value end
})

CombatTab:CreateToggle({
   Name = "Names (con distancia)",
   CurrentValue = false,
   Callback = function(Value) namesEnabled = Value end
})

CombatTab:CreateToggle({
   Name = "Tracers (desde abajo)",
   CurrentValue = false,
   Callback = function(Value) tracersEnabled = Value end
})

CombatTab:CreateButton({
   Name = "Minimizar GUI",
   Callback = function()
      Rayfield:Notify({Title = "Cómo minimizar", Content = "Haz clic en la flecha ↓ en la barra superior del GUI", Duration = 6})
   end
})

-- ==================== RESPAWN ====================
player.CharacterAdded:Connect(function(newChar)
   character = newChar
   humanoid = newChar:WaitForChild("Humanoid")
end)

Rayfield:Notify({
   Title = "✅ ¡ESP AÑADIDO!",
   Content = "Pestaña Combat con ESP completo:\n• Enable ESP\n• Boxes\n• Names (con distancia)\n• Tracers\n\n¡Todo separado y funcional!",
   Duration = 0
})
