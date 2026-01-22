-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Player
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- Neutraliza WalkSpeed sem quebrar animações
humanoid.WalkSpeed = 0

-- =====================
-- CONFIG
-- =====================
local BASE_SPEED = 16
local BOOST_SPEED = 60
local ACCEL = 12
local DECEL = 18

local currentSpeed = 0
local enabled = false

-- =====================
-- INPUT BRUTO (ANTI-TOOL)
-- =====================
local inputVector = Vector3.zero

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W then inputVector += Vector3.new(0, 0, -1) end
	if input.KeyCode == Enum.KeyCode.S then inputVector += Vector3.new(0, 0, 1) end
	if input.KeyCode == Enum.KeyCode.A then inputVector += Vector3.new(-1, 0, 0) end
	if input.KeyCode == Enum.KeyCode.D then inputVector += Vector3.new(1, 0, 0) end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then inputVector -= Vector3.new(0, 0, -1) end
	if input.KeyCode == Enum.KeyCode.S then inputVector -= Vector3.new(0, 0, 1) end
	if input.KeyCode == Enum.KeyCode.A then inputVector -= Vector3.new(-1, 0, 0) end
	if input.KeyCode == Enum.KeyCode.D then inputVector -= Vector3.new(1, 0, 0) end
end)

-- =====================
-- LOOP DE MOVIMENTO (ESTÁVEL)
-- =====================
RunService.RenderStepped:Connect(function(dt)
	if not enabled then return end

	local camCF = camera.CFrame
	local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
	local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

	local moveDir = (forward * -inputVector.Z + right * inputVector.X)

	if moveDir.Magnitude > 0 then
		moveDir = moveDir.Unit
		currentSpeed += (BOOST_SPEED - currentSpeed) * ACCEL * dt
	else
		currentSpeed += (0 - currentSpeed) * DECEL * dt
	end

	local yVel = hrp.AssemblyLinearVelocity.Y
	hrp.AssemblyLinearVelocity = moveDir * currentSpeed + Vector3.new(0, yVel, 0)
end)

-- =====================
-- INTERFACE (UI)
-- =====================
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedUI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.2, 0.12)
frame.Position = UDim2.fromScale(0.4, 0.82)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.05
frame.Parent = gui
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 0.4)
title.BackgroundTransparency = 1
title.Text = "SPEED BOOST"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.fromScale(0.7, 0.4)
button.Position = UDim2.fromScale(0.15, 0.5)
button.Text = "OFF"
button.Font = Enum.Font.GothamBold
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(170, 60, 60)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Parent = frame
button.BorderSizePixel = 0
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 14)

-- =====================
-- BOTÃO
-- =====================
button.MouseButton1Click:Connect(function()
	enabled = not enabled

	if enabled then
		button.Text = "ON"
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 170, 90)
		}):Play()
	else
		button.Text = "OFF"
		currentSpeed = 0
		TweenService:Create(button, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(170, 60, 60)
		}):Play()
	end
end)
