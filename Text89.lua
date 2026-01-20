--// ESP Dinámico Npc or Die con toggle y auto-update SIN LAG
--// Sheriffs / Criminals / NPCs (NPCs = criminal)
--// RAW / LOCAL

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ================= TOGGLE =================
if _G.ESPHighlights then
	for _, hl in pairs(_G.ESPHighlights) do
		if hl then hl:Destroy() end
	end
	_G.ESPHighlights = nil
	print("ESP destruido ❌")
	return
end

-- ================= VARIABLES =================
local highlights = {}
local visibleStates = {}
_G.ESPHighlights = highlights

local NPC_FOLDER = Workspace:FindFirstChild("NPCs") -- ajusta si tus NPCs están en otra carpeta

-- ================= FUNCIONES =================
local function obtenerMiRol()
	if LocalPlayer.Team and LocalPlayer.Team.Name:lower() == "sheriffs" then
		return "sheriff"
	end
	return "criminal"
end

local function aplicarHighlight(model, color, visible)
	if not model or not model:IsA("Model") then return end

	if not highlights[model] then
		local hl = Instance.new("Highlight")
		hl.Name = "ESP_Highlight"
		hl.Adornee = model
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Parent = Workspace
		highlights[model] = hl
	end

	local hl = highlights[model]
	hl.FillColor = color
	hl.OutlineColor = color

	if visibleStates[model] ~= visible then
		hl.Enabled = visible
		visibleStates[model] = visible
	end
end

-- ================= ACTUALIZAR JUGADORES =================
local function actualizarJugadores()
	local miRol = obtenerMiRol()

	for _, plr in pairs(Players:GetPlayers()) do
		if plr.Character then
			local rol = "criminal"
			if plr.Team and plr.Team.Name:lower() == "sheriffs" then
				rol = "sheriff"
			end

			local color = (rol == "sheriff")
				and Color3.fromRGB(0,0,255)
				or Color3.fromRGB(255,0,0)

			local visible = (rol ~= miRol) -- como antes
			aplicarHighlight(plr.Character, color, visible)
		end
	end
end

-- ================= ACTUALIZAR NPCs =================
local function actualizarNPCs()
	if not NPC_FOLDER then return end

	for _, npc in pairs(NPC_FOLDER:GetChildren()) do
		if npc:IsA("Model") then
			-- Forzar siempre visible y rojo, sin importar tu rol
			aplicarHighlight(npc, Color3.fromRGB(255,0,0), true)
		end
	end
end

-- ================= EVENTOS =================
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(actualizarJugadores)
end)

for _, plr in pairs(Players:GetPlayers()) do
	if plr.Character then
		plr.CharacterAdded:Connect(actualizarJugadores)
	end
end

if NPC_FOLDER then
	NPC_FOLDER.ChildAdded:Connect(actualizarNPCs)
end

-- ================= LOOP DE RESPALDO (ANTI BUGS) =================
task.spawn(function()
	while _G.ESPHighlights do
		actualizarJugadores()
		actualizarNPCs()
		task.wait(1) -- solo 1 vez por segundo (cero lag)
	end
end)
