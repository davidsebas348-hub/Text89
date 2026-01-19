--// ESP Dinámico "Equipo" Npc or Die con destrucción automática
--// Solo resalta tu equipo
--// RAW / LOCAL

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ======== DESTRUCCIÓN SI YA EXISTE ========
if _G.ESPTeamTexts then
	for target, textLabel in pairs(_G.ESPTeamTexts) do
		if textLabel and textLabel.Parent then
			textLabel.Parent:Destroy()
		end
	end
	_G.ESPTeamTexts = nil
	print("ESP de equipo destruido ❌")
	return
end

-- ======== VARIABLES ========
local espTexts = {}
_G.ESPTeamTexts = espTexts

-- ======== FUNCIONES ========
local function obtenerMiRol()
	if LocalPlayer.Team then
		local t = LocalPlayer.Team.Name:lower()
		if t == "sheriffs" then
			return "sheriff"
		elseif t == "criminals" then
			return "criminal"
		else
			return "lobby"
		end
	else
		return "lobby"
	end
end

local function aplicarTexto(target, color, visible)
	if not target or not target:IsA("Model") then return end
	local head = target:FindFirstChild("Head")
	if not head then return end

	if not espTexts[target] then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP_Team_Text"
		billboard.Adornee = head
		billboard.Size = UDim2.new(0, 100, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 2, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = head

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextScaled = false
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextColor3 = color
		textLabel.TextStrokeTransparency = 0
		textLabel.Text = "Equipo"
		textLabel.Parent = billboard

		espTexts[target] = textLabel
	end

	local textLabel = espTexts[target]
	textLabel.TextColor3 = color
	textLabel.Visible = visible
end

-- ======== LOOP ESP ========
local conn
conn = RunService.Heartbeat:Connect(function()
	local miRol = obtenerMiRol()

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local playerRol
			if plr.Team then
				local t = plr.Team.Name:lower()
				playerRol = (t == "sheriffs") and "sheriff" or "criminal"
			else
				playerRol = "lobby"
			end

			local color = Color3.fromRGB(0, 255, 0) -- verde para equipo
			local visible = (playerRol == miRol) -- solo tu mismo equipo

			aplicarTexto(plr.Character, color, visible)
		end
	end
end)

-- ======== LIMPIEZA ========
Players.PlayerRemoving:Connect(function(player)
	if player.Character and espTexts[player.Character] then
		espTexts[player.Character].Parent:Destroy()
		espTexts[player.Character] = nil
	end
end)
