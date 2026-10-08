local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local function setup(char)
	local humanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	local lastRagdollCheck = 0

	-- Anti-ragdoll + levantarse rápido + a veces no caer
	RunService.Heartbeat:Connect(function()
		local now = tick()
		if now - lastRagdollCheck < 0.05 then return end
		lastRagdollCheck = now

		local ragdoll = char:FindFirstChild("Ragdoll")
		if ragdoll then
			-- 40% de probabilidad de no caer
			if math.random() < 0.4 then
				ragdoll:Destroy()
				humanoid.PlatformStand = false
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				return
			end

			-- Si cae, se levanta muy rápido
			task.delay(0.12, function()
				if ragdoll and ragdoll.Parent then
					ragdoll:Destroy()
				end
				if humanoid and humanoid.Parent then
					humanoid.PlatformStand = false
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
			end)
		end
	end)

	-- Mantener tu grab activo cuando te agarran (80% de probabilidad)
	RunService.Heartbeat:Connect(function()
		local isGrabbed =
			humanoidRootPart:FindFirstChildWhichIsA("AlignPosition") or
			humanoidRootPart:FindFirstChildWhichIsA("BodyPosition") or
			humanoidRootPart:FindFirstChildWhichIsA("VectorForce") or
			humanoidRootPart:FindFirstChildWhichIsA("BodyMover") or
			humanoidRootPart:FindFirstChildWhichIsA("AlignOrientation")

		if isGrabbed and math.random() < 0.8 then
			humanoid.PlatformStand = false
			if humanoid:GetState() == Enum.HumanoidStateType.Physics or 
			   humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
				humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end
		end
	end)
end

-- Inicial y para respawn
setup(character)
Players.LocalPlayer.CharacterAdded:Connect(setup)
