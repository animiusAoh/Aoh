-- =====================================================
-- SERVICES
-- =====================================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================
-- CONFIGURATION
-- =====================================================

local WEBHOOK_URL = "https://discord.com/api/webhooks/1557790554924916866/HNTbzgw8H3C2cW1jXnYryhFSglig0rom_xWxrGUlUBiclV-xZs_rHnAKD4Us4vsyQ6x4"
local EMBED_COLOR = 606060 -- Azul profesional

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

local function getPlayerCount()
    return #Players:GetPlayers()
end

local function getAllUsernames()
    local usernames = {}

    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(usernames, player.Name)
    end

    return usernames
end

local function formatUserList(userTable)
    if #userTable == 0 then
        return "None"
    end

    return table.concat(userTable, "\n")
end

local function sendWebhook(payload)
    local request = syn and syn.request or http_request
    if not request then return end

    request({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = HttpService:JSONEncode(payload)
    })
end

-- =====================================================
-- MAIN EXECUTION LOGGER
-- =====================================================

pcall(function()

    local playerCount = getPlayerCount()
    local userListTable = getAllUsernames()
    local formattedUsers = formatUserList(userListTable)

    local embedData = {
        ["title"] = "Script Execution Log",
        ["color"] = EMBED_COLOR,
        ["fields"] = {

            {
                ["name"] = "Executor Information",
                ["value"] =
                    "👤 Username: " .. LocalPlayer.Name .. "\n" ..
                    "UserId: " .. tostring(LocalPlayer.UserId) .. "\n" ..
                    "DisplayName: " .. LocalPlayer.DisplayName,
                ["inline"] = false
            },

            {
                ["name"] = "Server Information",
                ["value"] =
                    "PlaceId: " .. tostring(game.PlaceId) .. "\n" ..
                    "JobId: " .. game.JobId .. "\n" ..
                    "PlayerCount: " .. tostring(playerCount),
                ["inline"] = false
            },

            {
                ["name"] = "Players In Server",
                ["value"] = formattedUsers,
                ["inline"] = false
            },

            {
                ["name"] = "Execution Time",
                ["value"] = os.date("%Y-%m-%d %H:%M:%S"),
                ["inline"] = false
            }
        },

        ["footer"] = {
            ["text"] = ".dcto script"
        }
    }

    local payload = {
        ["content"] = "",
        ["embeds"] = { embedData }
    }

    sendWebhook(payload)

end)

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
