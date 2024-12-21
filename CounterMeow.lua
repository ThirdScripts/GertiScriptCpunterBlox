-- Загрузка библиотеки UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GertiScriptsBlox", "Ocean")

-- Создание вкладок и секций
local Tab = Window:NewTab("Main")
local Section = Tab:NewSection("Main")

-- Настройки FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = 200
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

-- Функция для аимбота
Section:NewButton("Aimbot(PressT)", "ButtonInfo", function()
    local camera = workspace.CurrentCamera
    local players = game:GetService("Players")
    local user = players.LocalPlayer
    local inputService = game:GetService("UserInputService")
    local runService = game:GetService("RunService")

    local predictionFactor = 0.042
    local aimSpeed = 10
    local holding = false
    local aimBotEnabled = false

    local function isSameTeam(player)
        if player.Team and user.Team then
            return player.Team == user.Team
        end
        return false
    end

    local function getClosestPlayer()
        local closest, minDist = nil, math.huge
        for _, player in pairs(players:GetPlayers()) do
            if player ~= user and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not isSameTeam(player) then
                local head = player.Character:FindFirstChild("Head")
                local screenPos, onScreen = camera:WorldToScreenPoint(head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - inputService:GetMouseLocation()).Magnitude
                if onScreen and distance <= FOVCircle.Radius and distance < minDist then
                    closest, minDist = player, distance
                end
            end
        end
        return closest
    end

    local function predictHead(target)
        local head = target.Character.Head
        local velocity = target.Character.HumanoidRootPart.AssemblyLinearVelocity or Vector3.zero
        return head.Position + velocity * predictionFactor
    end

    inputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then holding = true end
        if input.KeyCode == Enum.KeyCode.T then
            aimBotEnabled = not aimBotEnabled
            FOVCircle.Visible = aimBotEnabled
            if not aimBotEnabled then holding = false end
        end
    end)

    inputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then holding = false end
    end)

    runService.RenderStepped:Connect(function()
        if not aimBotEnabled then return end
        FOVCircle.Position = inputService:GetMouseLocation()
        if holding then
            local target = getClosestPlayer()
            if target then
                local predicted = predictHead(target)
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, predicted), aimSpeed * 0.1)
            end
        end
    end)
end)

-- Спидхак
Section:NewTextBox("Speedhack(PressX)", "TextboxInfo", function(txt)
    local speed = tonumber(txt) or 100
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local userInputService = game:GetService("UserInputService")
    local bodyVelocity

    userInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.X then
            if not bodyVelocity then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
                bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * speed
                bodyVelocity.Parent = humanoidRootPart
            else
                bodyVelocity.Velocity = humanoidRootPart.CFrame.LookVector * speed
            end
        end
    end)

    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.X then
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
        end
    end)
end)

-- Фулбрайт
Section:NewToggle("Fullbright", "ToggleInfo", function(state)
    local Lighting = game:GetService("Lighting")
    if state then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.FogEnd = 1e10
    else
        Lighting.Ambient = Color3.new(0.7, 0.7, 0.7)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.new(0.7, 0.7, 0.7)
        Lighting.FogEnd = 100000
    end
end)

-- ESP
Section:NewButton("ESP", "ButtonInfo", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ThirdScripts/ESPteamcolor/refs/heads/main/ESP.lua"))()
end)
