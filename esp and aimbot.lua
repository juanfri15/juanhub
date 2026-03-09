-- Librería de interfaz (Rayfield)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Crear la ventana principal
local Window = Rayfield:CreateWindow({
    Name = "Roblox Hack Suite",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "by Venice",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RobloxHack",
        FileName = "Config"
    }
})

-- Pestaña de Aimbot
local AimbotTab = Window:CreateTab("Aimbot")

-- Toggle para activar/desactivar Aimbot
local AimbotEnabled = AimbotTab:CreateToggle({
    Name = "Activar Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        _G.AimbotEnabled = Value
    end
})

-- Slider para ajustar el FOV
local FOVSlider = AimbotTab:CreateSlider({
    Name = "FOV del Aimbot",
    Range = {0, 360},
    Increment = 10,
    CurrentValue = 90,
    Callback = function(Value)
        _G.AimbotFOV = Value
    end
})

-- Pestaña de ESP
local ESPTab = Window:CreateTab("ESP")

-- Toggle para activar/desactivar ESP
local ESPEnabled = ESPTab:CreateToggle({
    Name = "Activar ESP",
    CurrentValue = false,
    Callback = function(Value)
        _G.ESPEnabled = Value
    end
})

-- Slider para ajustar la distancia del ESP
local ESPDistance = ESPTab:CreateSlider({
    Name = "Distancia del ESP",
    Range = {0, 1000},
    Increment = 50,
    CurrentValue = 500,
    Callback = function(Value)
        _G.ESPDistance = Value
    end
})

-- Función del Aimbot
local function GetClosestPlayerToMouse()
    local ClosestPlayer = nil
    local ShortestDistance = _G.AimbotFOV or 90
    
    for _, Player in pairs(game.Players:GetPlayers()) do
        if Player ~= game.Players.LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local Position = Player.Character.HumanoidRootPart.Position
            local Distance = (Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            local OnScreen = workspace.CurrentCamera:WorldToScreenPoint(Position)
            
            if Distance < ShortestDistance and OnScreen.Z > 0 then
                ClosestPlayer = Player
                ShortestDistance = Distance
            end
        end
    end
    
    return ClosestPlayer
end

-- Bucle principal del Aimbot
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.AimbotEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        local ClosestPlayer = GetClosestPlayerToMouse()
        if ClosestPlayer and ClosestPlayer.Character and ClosestPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local TargetPosition = ClosestPlayer.Character.HumanoidRootPart.Position
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, TargetPosition)
        end
    end
end)

-- Función del ESP
local function CreateESP(Player)
    local Box = Instance.new("BoxHandleAdornment")
    Box.Size = Vector3.new(4, 6, 2)
    Box.Color3 = Color3.new(1, 0, 0)
    Box.Transparency = 0.5
    Box.ZIndex = 10
    Box.AlwaysOnTop = true
    Box.Visible = false
    Box.Parent = game.Players.LocalPlayer.PlayerGui
    
    local NameTag = Instance.new("BillboardGui")
    NameTag.Size = UDim2.new(0, 100, 0, 50)
    NameTag.StudsOffset = Vector3.new(0, 3, 0)
    NameTag.AlwaysOnTop = true
    NameTag.Parent = game.Players.LocalPlayer.PlayerGui
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = Player.Name
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextStrokeTransparency = 0
    Label.Parent = NameTag
    
    return {Box = Box, NameTag = NameTag}
end

-- Bucle principal del ESP
game.Players.PlayerAdded:Connect(function(Player)
    if _G.ESPEnabled then
        local ESP = CreateESP(Player)
        Player.CharacterAdded:Connect(function(Character)
            if Character:FindFirstChild("HumanoidRootPart") then
                ESP.Box.Adornee = Character.HumanoidRootPart
                ESP.NameTag.Adornee = Character.HumanoidRootPart
                ESP.Box.Visible = true
            end
        end)
    end
end)

for _, Player in pairs(game.Players:GetPlayers()) do
    if Player ~= game.Players.LocalPlayer and _G.ESPEnabled then
        local ESP = CreateESP(Player)
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            ESP.Box.Adornee = Character.HumanoidRootPart
            ESP.NameTag.Adornee = Character.HumanoidRootPart
            ESP.Box.Visible = true
        end
    end
end
