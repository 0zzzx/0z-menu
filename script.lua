local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local MENU_VERSION = "v1.2"
local MENU_CREDITS = "zyx"
local SAVE_FILE = "0zMenu_Config.json"
local SAVE_ATTR = "OzMenuSavedConfigJson"

local ThemePresets = {
	Roxo = {
		Accent = Color3.fromRGB(139, 92, 246),
		Accent2 = Color3.fromRGB(168, 85, 247),
		Glow = Color3.fromRGB(196, 132, 252),
		Stroke = Color3.fromRGB(64, 52, 92),
	},
	Vermelho = {
		Accent = Color3.fromRGB(220, 38, 38),
		Accent2 = Color3.fromRGB(248, 113, 113),
		Glow = Color3.fromRGB(252, 165, 165),
		Stroke = Color3.fromRGB(92, 46, 52),
	},
	Azul = {
		Accent = Color3.fromRGB(37, 99, 235),
		Accent2 = Color3.fromRGB(96, 165, 250),
		Glow = Color3.fromRGB(147, 197, 253),
		Stroke = Color3.fromRGB(48, 64, 96),
	},
	Verde = {
		Accent = Color3.fromRGB(22, 163, 74),
		Accent2 = Color3.fromRGB(74, 222, 128),
		Glow = Color3.fromRGB(134, 239, 172),
		Stroke = Color3.fromRGB(46, 86, 62),
	},
}

local FixedActionTheme = {
	Bg = Color3.fromRGB(124, 58, 237),
	GradA = Color3.fromRGB(139, 92, 246),
	GradB = Color3.fromRGB(168, 85, 247),
	Glow = Color3.fromRGB(196, 132, 252),
}

local DefaultConfig = {
	EspEnabled = true,
	TeamCheck = true,
	EspFillColor = Color3.fromRGB(255, 255, 255),
	EspOutlineColor = Color3.fromRGB(255, 255, 255),
	EspFillTransparency = 0.65,
	EspDepthMode = "AlwaysOnTop",
	AimbotEnabled = true,
	AimToggleKey = Enum.KeyCode.H,
	AimPart = "Head",
	AimFOV = 250,
	AimbotSmoothness = 0.35,
	AimMaxDistance = 1000,
	AimVisibleOnly = false,
	AimNoWall = false,
	AimPrediction = false,
	AimPredictionAmount = 0.15,
	AimLockOnTarget = true,
	AimIgnoreFriends = true,
	AimHumanize = true,
	RecoilReduction = 0.0,
	NoSpreadEnabled = false,
	MenuOpen = true,
	MenuKey = Enum.KeyCode.J,
	UiScale = 1.0,
	ThemeName = "Roxo",
}

local Config = {
	EspEnabled = DefaultConfig.EspEnabled,
	TeamCheck = DefaultConfig.TeamCheck,
	EspFillColor = DefaultConfig.EspFillColor,
	EspOutlineColor = DefaultConfig.EspOutlineColor,
	EspFillTransparency = DefaultConfig.EspFillTransparency,
	EspDepthMode = DefaultConfig.EspDepthMode,
	AimbotEnabled = DefaultConfig.AimbotEnabled,
	AimToggleKey = DefaultConfig.AimToggleKey,
	AimPart = DefaultConfig.AimPart,
	AimFOV = DefaultConfig.AimFOV,
	AimbotSmoothness = DefaultConfig.AimbotSmoothness,
	AimMaxDistance = DefaultConfig.AimMaxDistance,
	AimVisibleOnly = DefaultConfig.AimVisibleOnly,
	AimNoWall = DefaultConfig.AimNoWall,
	AimPrediction = DefaultConfig.AimPrediction,
	AimPredictionAmount = DefaultConfig.AimPredictionAmount,
	AimLockOnTarget = DefaultConfig.AimLockOnTarget,
	AimIgnoreFriends = DefaultConfig.AimIgnoreFriends,
	AimHumanize = DefaultConfig.AimHumanize,
	RecoilReduction = DefaultConfig.RecoilReduction,
	NoSpreadEnabled = DefaultConfig.NoSpreadEnabled,
	MenuOpen = DefaultConfig.MenuOpen,
	MenuKey = DefaultConfig.MenuKey,
	UiScale = DefaultConfig.UiScale,
	ThemeName = DefaultConfig.ThemeName,
}

local SavedSessionJson = nil
local Highlights, GuiName = {}, "0zMenuEspUI"

local function applyEspColorsToAll(col)
	if typeof(col) ~= "Color3" then
		return
	end
	Config.EspFillColor = col
	Config.EspOutlineColor = col
	for _, hl in pairs(Highlights) do
		if hl and hl.Parent then
			hl.FillColor = col
			hl.OutlineColor = col
		end
	end
end

local function serializeConfig()
	return {
		EspEnabled = Config.EspEnabled,
		TeamCheck = Config.TeamCheck,
		EspColor = {
			math.floor(Config.EspFillColor.R * 255 + 0.5),
			math.floor(Config.EspFillColor.G * 255 + 0.5),
			math.floor(Config.EspFillColor.B * 255 + 0.5),
		},
		EspFillTransparency = Config.EspFillTransparency,
		EspDepthMode = Config.EspDepthMode,
		AimbotEnabled = Config.AimbotEnabled,
		AimToggleKeyName = Config.AimToggleKey.Name,
		AimPart = Config.AimPart,
		AimFOV = Config.AimFOV,
		AimbotSmoothness = Config.AimbotSmoothness,
		AimMaxDistance = Config.AimMaxDistance,
		AimVisibleOnly = Config.AimVisibleOnly,
		AimNoWall = Config.AimNoWall,
		AimPrediction = Config.AimPrediction,
		AimLockOnTarget = Config.AimLockOnTarget,
		AimIgnoreFriends = Config.AimIgnoreFriends,
		AimHumanize = Config.AimHumanize,
		RecoilReduction = Config.RecoilReduction,
		NoSpreadEnabled = Config.NoSpreadEnabled,
		MenuOpen = Config.MenuOpen,
		MenuKeyName = Config.MenuKey.Name,
		UiScale = Config.UiScale,
		ThemeName = Config.ThemeName,
	}
end

local function applySerializedConfig(data)
	if type(data) ~= "table" then
		return
	end
	if type(data.EspEnabled) == "boolean" then Config.EspEnabled = data.EspEnabled end
	if type(data.TeamCheck) == "boolean" then Config.TeamCheck = data.TeamCheck end
	if type(data.EspColor) == "table" and #data.EspColor == 3 then
		local r = math.clamp(tonumber(data.EspColor[1]) or 255, 0, 255)
		local g = math.clamp(tonumber(data.EspColor[2]) or 255, 0, 255)
		local b = math.clamp(tonumber(data.EspColor[3]) or 255, 0, 255)
		local c = Color3.fromRGB(r, g, b)
		Config.EspFillColor = c
		Config.EspOutlineColor = c
	end
	if type(data.EspFillTransparency) == "number" then Config.EspFillTransparency = data.EspFillTransparency end
	if data.EspDepthMode == "AlwaysOnTop" or data.EspDepthMode == "Occluded" then Config.EspDepthMode = data.EspDepthMode end
	if type(data.AimbotEnabled) == "boolean" then Config.AimbotEnabled = data.AimbotEnabled end
	if data.AimToggleKeyName and Enum.KeyCode[data.AimToggleKeyName] then
		Config.AimToggleKey = Enum.KeyCode[data.AimToggleKeyName]
	end
	if data.AimPart == "Head" or data.AimPart == "HumanoidRootPart" or data.AimPart == "UpperTorso" then
		Config.AimPart = data.AimPart
	end
	if type(data.AimFOV) == "number" then Config.AimFOV = data.AimFOV end
	if type(data.AimbotSmoothness) == "number" then Config.AimbotSmoothness = data.AimbotSmoothness end
	if type(data.AimMaxDistance) == "number" then Config.AimMaxDistance = data.AimMaxDistance end
	if type(data.AimVisibleOnly) == "boolean" then Config.AimVisibleOnly = data.AimVisibleOnly end
	if type(data.AimNoWall) == "boolean" then Config.AimNoWall = data.AimNoWall end
	if type(data.AimPrediction) == "boolean" then Config.AimPrediction = data.AimPrediction end
	if type(data.AimLockOnTarget) == "boolean" then Config.AimLockOnTarget = data.AimLockOnTarget end
	if type(data.AimIgnoreFriends) == "boolean" then Config.AimIgnoreFriends = data.AimIgnoreFriends end
	if type(data.AimHumanize) == "boolean" then Config.AimHumanize = data.AimHumanize end
	if type(data.RecoilReduction) == "number" then Config.RecoilReduction = data.RecoilReduction end
	if type(data.NoSpreadEnabled) == "boolean" then Config.NoSpreadEnabled = data.NoSpreadEnabled end
	if type(data.MenuOpen) == "boolean" then Config.MenuOpen = data.MenuOpen end
	if data.MenuKeyName and Enum.KeyCode[data.MenuKeyName] then
		Config.MenuKey = Enum.KeyCode[data.MenuKeyName]
	end
	if type(data.UiScale) == "number" then
		Config.UiScale = math.clamp(data.UiScale, 0.75, 1.35)
	end
	if type(data.ThemeName) == "string" and ThemePresets[data.ThemeName] then
		Config.ThemeName = data.ThemeName
	end
end

local function decodeAndApply(raw)
	if type(raw) ~= "string" or raw == "" then
		return false
	end
	local okDec, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if okDec and type(decoded) == "table" then
		applySerializedConfig(decoded)
		return true
	end
	return false
end

local function loadSavedConfig()
	if typeof(isfile) == "function" and typeof(readfile) == "function" then
		local okExists, exists = pcall(isfile, SAVE_FILE)
		if okExists and exists then
			local okRead, raw = pcall(readfile, SAVE_FILE)
			if okRead and decodeAndApply(raw) then
				SavedSessionJson = raw
				return true, "arquivo"
			end
		end
	end
	if LocalPlayer then
		local attrJson = LocalPlayer:GetAttribute(SAVE_ATTR)
		if decodeAndApply(attrJson) then
			SavedSessionJson = attrJson
			return true, "sessão"
		end
	end
	if SavedSessionJson and decodeAndApply(SavedSessionJson) then
		return true, "sessão"
	end
	return false, nil
end

local function saveCurrentConfig()
	local payload = serializeConfig()
	local okEnc, encoded = pcall(function()
		return HttpService:JSONEncode(payload)
	end)
	if not okEnc or type(encoded) ~= "string" then
		return false, "Erro ao serializar as alterações!", "Erro"
	end

	SavedSessionJson = encoded
	pcall(function()
		if LocalPlayer then
			LocalPlayer:SetAttribute(SAVE_ATTR, encoded)
		end
	end)

	if typeof(writefile) == "function" then
		local okWrite = pcall(writefile, SAVE_FILE, encoded)
		if okWrite then
			return true, "Alterações salvas em " .. SAVE_FILE .. "!", "Salvo"
		end
	end

	return true, "Alterações salvas com sucesso!", "Salvo"
end

loadSavedConfig()

local friendCache = {}
pcall(function()
	for _, f in ipairs(LocalPlayer:GetFriendsOnline(200)) do
		friendCache[f.VisitorId] = true
	end
end)

local aimHeld, fireHeld, currentTarget = false, false, nil
local lastCameraLook = nil
local IS_SLIDER_DRAGGING = false
local IS_DROPDOWN_OPEN = false
local NotifyCallback = nil

local function getPlayerDisplayName()
	if not LocalPlayer then
		return "Jogador"
	end
	if LocalPlayer.DisplayName and LocalPlayer.DisplayName ~= "" then
		return LocalPlayer.DisplayName
	end
	return LocalPlayer.Name or "Jogador"
end

local SyncCallbacks = {}
local function registerSync(key, fn)
	SyncCallbacks[key] = SyncCallbacks[key] or {}
	table.insert(SyncCallbacks[key], fn)
end
local function emitSync(key, value)
	local list = SyncCallbacks[key]
	if list then
		for _, fn in ipairs(list) do
			fn(value)
		end
	end
end

local initialPreset = ThemePresets[Config.ThemeName] or ThemePresets.Roxo
local Theme = {
	Bg = Color3.fromRGB(16, 15, 24),
	Panel = Color3.fromRGB(22, 21, 33),
	Card = Color3.fromRGB(30, 29, 44),
	CardHover = Color3.fromRGB(38, 37, 56),
	Stroke = initialPreset.Stroke,
	Accent = initialPreset.Accent,
	Accent2 = initialPreset.Accent2,
	Glow = initialPreset.Glow,
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(165, 162, 185),
	Danger = Color3.fromRGB(239, 68, 68),
	TrackOff = Color3.fromRGB(55, 52, 74),
}

local ThemeListeners = {}
local function onThemeChanged(fn)
	table.insert(ThemeListeners, fn)
end

local function getParentGui()
	if typeof(gethui) == "function" then
		local ok, hui = pcall(gethui)
		if ok and hui then
			return hui
		end
	end
	local okCore, core = pcall(function()
		return CoreGui
	end)
	if okCore and core then
		return core
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function makeGradient(parent, c1, c2, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c1, c2)
	g.Rotation = rotation or 0
	g.Parent = parent
	return g
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.35
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function pad(parent, t, b, l, r)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.Parent = parent
	return p
end

local function applyItalicGothamBlack(label)
	pcall(function()
		label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic)
	end)
end

local function formatInputName(inputObj)
	if not inputObj then
		return "Nenhum"
	end
	if typeof(inputObj) == "EnumItem" then
		if inputObj.EnumType == Enum.UserInputType then
			if inputObj == Enum.UserInputType.MouseButton2 then
				return "RMB"
			elseif inputObj == Enum.UserInputType.MouseButton1 then
				return "LMB"
			elseif inputObj == Enum.UserInputType.MouseButton3 then
				return "MMB"
			end
		end
		return inputObj.Name
	end
	return tostring(inputObj)
end

local function formatDepthMode(val)
	if val == "Occluded" then
		return "Ocluso"
	end
	return "Sempre no Topo"
end
local function parseDepthMode(label)
	if label == "Ocluso" or label == "Occluded" then
		return "Occluded"
	end
	return "AlwaysOnTop"
end

local function formatAimPart(val)
	if val == "Head" then
		return "Cabeça"
	elseif val == "HumanoidRootPart" then
		return "Tronco (HRP)"
	elseif val == "UpperTorso" then
		return "Peito"
	end
	return tostring(val)
end
local function parseAimPart(label)
	if label == "Cabeça" or label == "Head" then
		return "Head"
	elseif label == "Tronco (HRP)" or label == "HumanoidRootPart" then
		return "HumanoidRootPart"
	elseif label == "Peito" or label == "UpperTorso" then
		return "UpperTorso"
	end
	return "Head"
end

local function createUI()
	table.clear(SyncCallbacks)
	table.clear(ThemeListeners)
	local parentGui = getParentGui()
	local existing = parentGui:FindFirstChild(GuiName)
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = GuiName
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 9999
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parentGui

	-- Banner de Notificação ao Salvar / Resetar / Alternar Aim / Abrir Menu
	local toastFrame = Instance.new("Frame")
	toastFrame.Name = "SaveNotification"
	toastFrame.Size = UDim2.new(0, 316, 0, 56)
	toastFrame.Position = UDim2.new(1, -334, 0, 22)
	toastFrame.BackgroundColor3 = Theme.Panel
	toastFrame.BackgroundTransparency = 0
	toastFrame.BorderSizePixel = 0
	toastFrame.ZIndex = 200
	toastFrame.Visible = false
	toastFrame.Parent = screenGui
	corner(toastFrame, 12)
	local toastStroke = stroke(toastFrame, Theme.Accent2, 1.8, 0.05)

	local toastBar = Instance.new("Frame")
	toastBar.Size = UDim2.new(0, 5, 1, -12)
	toastBar.Position = UDim2.new(0, 6, 0, 6)
	toastBar.BackgroundColor3 = Theme.Accent2
	toastBar.BorderSizePixel = 0
	toastBar.ZIndex = 201
	toastBar.Parent = toastFrame
	corner(toastBar, 3)

	local toastTitle = Instance.new("TextLabel")
	toastTitle.Size = UDim2.new(1, -26, 0, 18)
	toastTitle.Position = UDim2.new(0, 18, 0, 8)
	toastTitle.BackgroundTransparency = 1
	toastTitle.Text = "Salvo"
	toastTitle.TextColor3 = Theme.Text
	toastTitle.Font = Enum.Font.GothamBold
	toastTitle.TextSize = 13
	toastTitle.TextXAlignment = Enum.TextXAlignment.Left
	toastTitle.ZIndex = 201
	toastTitle.Parent = toastFrame

	local toastMsg = Instance.new("TextLabel")
	toastMsg.Size = UDim2.new(1, -26, 0, 18)
	toastMsg.Position = UDim2.new(0, 18, 0, 28)
	toastMsg.BackgroundTransparency = 1
	toastMsg.Text = "Alterações salvas com sucesso!"
	toastMsg.TextColor3 = Theme.TextDim
	toastMsg.Font = Enum.Font.GothamMedium
	toastMsg.TextSize = 11
	toastMsg.TextXAlignment = Enum.TextXAlignment.Left
	toastMsg.ZIndex = 201
	toastMsg.Parent = toastFrame

	local toastToken = 0
	local function showSaveNotification(titleText, bodyText, isError)
		toastToken = toastToken + 1
		local myToken = toastToken
		toastTitle.Text = titleText or "Salvo"
		toastMsg.Text = bodyText or "Alterações salvas com sucesso!"
		local accentCol = isError and Theme.Danger or Theme.Accent2
		toastStroke.Color = accentCol
		toastBar.BackgroundColor3 = accentCol
		toastFrame.Visible = true
		toastFrame.Position = UDim2.new(1, 360, 0, 22)

		TweenService:Create(toastFrame, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -334, 0, 22),
		}):Play()

		task.delay(2.2, function()
			if toastToken == myToken and toastFrame and toastFrame.Parent then
				local hideTween = TweenService:Create(toastFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Position = UDim2.new(1, 360, 0, 22),
				})
				hideTween:Play()
				hideTween.Completed:Connect(function()
					if toastToken == myToken and toastFrame and toastFrame.Parent then
						toastFrame.Visible = false
					end
				end)
			end
		end)
	end

	NotifyCallback = showSaveNotification

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 760, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -380, 0.5, -250)
	mainFrame.BackgroundColor3 = Theme.Bg
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Visible = Config.MenuOpen
	mainFrame.Parent = screenGui
	corner(mainFrame, 18)
	local outerStroke = stroke(mainFrame, Theme.Accent, 1.5, 0.25)
	local outerGrad = makeGradient(outerStroke, Theme.Accent, Theme.Accent2, 35)

	local uiScale = Instance.new("UIScale")
	uiScale.Name = "MenuScale"
	uiScale.Scale = Config.UiScale
	uiScale.Parent = mainFrame

	local function setUiScale(scaleVal)
		local clamped = math.clamp(scaleVal, 0.75, 1.35)
		Config.UiScale = clamped
		uiScale.Scale = clamped
	end

	local function setMenuVisibility(openState)
		local wasOpen = Config.MenuOpen
		Config.MenuOpen = openState
		mainFrame.Visible = openState
		emitSync("MenuOpen", openState)
		if openState and not wasOpen and NotifyCallback then
			NotifyCallback("Bem vindo!", "Bem vindo! " .. getPlayerDisplayName(), false)
		end
	end

	local dragging, dragStart, startPos = false, nil, nil
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if IS_SLIDER_DRAGGING or IS_DROPDOWN_OPEN then
				return
			end
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = (input.Position - dragStart) / math.max(uiScale.Scale, 0.01)
			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Barra Lateral Esquerda
	local sidebarWidth = 175
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
	sidebar.Position = UDim2.new(0, 0, 0, 0)
	sidebar.BackgroundColor3 = Theme.Panel
	sidebar.BackgroundTransparency = 0.15
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame
	corner(sidebar, 18)
	local sidebarStroke = stroke(sidebar, Theme.Stroke, 1, 0.5)

	-- Logo Estilizada "0z"
	local logoFrame = Instance.new("Frame")
	logoFrame.Size = UDim2.new(1, -20, 0, 72)
	logoFrame.Position = UDim2.new(0, 10, 0, 8)
	logoFrame.BackgroundTransparency = 1
	logoFrame.Parent = sidebar

	local glowArc = Instance.new("Frame")
	glowArc.Size = UDim2.new(0, 96, 0, 26)
	glowArc.Position = UDim2.new(0.5, -48, 0.5, -8)
	glowArc.Rotation = -12
	glowArc.BackgroundColor3 = Theme.Accent
	glowArc.BackgroundTransparency = 0.78
	glowArc.BorderSizePixel = 0
	glowArc.Parent = logoFrame
	corner(glowArc, 13)

	local logo0 = Instance.new("TextLabel")
	logo0.Size = UDim2.new(0, 52, 1, 0)
	logo0.Position = UDim2.new(0.5, -46, 0, -2)
	logo0.Rotation = -10
	logo0.BackgroundTransparency = 1
	logo0.Text = "0"
	logo0.TextColor3 = Color3.fromRGB(255, 255, 255)
	logo0.Font = Enum.Font.GothamBlack
	logo0.TextSize = 48
	logo0.TextXAlignment = Enum.TextXAlignment.Center
	logo0.TextYAlignment = Enum.TextYAlignment.Center
	logo0.ZIndex = 3
	logo0.Parent = logoFrame
	local s0 = stroke(logo0, Theme.Accent2, 1.5, 0.4)
	s0.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	local logoZ = Instance.new("TextLabel")
	logoZ.Size = UDim2.new(0, 52, 1, 0)
	logoZ.Position = UDim2.new(0.5, -2, 0, 2)
	logoZ.Rotation = -14
	logoZ.BackgroundTransparency = 1
	logoZ.Text = "z"
	logoZ.TextColor3 = Color3.fromRGB(255, 255, 255)
	logoZ.Font = Enum.Font.GothamBlack
	logoZ.TextSize = 46
	logoZ.TextXAlignment = Enum.TextXAlignment.Center
	logoZ.TextYAlignment = Enum.TextYAlignment.Center
	logoZ.ZIndex = 4
	logoZ.Parent = logoFrame
	applyItalicGothamBlack(logoZ)
	local logoZGrad = makeGradient(logoZ, Theme.Glow, Theme.Accent, 35)
	local sZ = stroke(logoZ, Theme.Glow, 1.5, 0.35)
	sZ.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

	-- Container das Abas
	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, -24, 0, 180)
	tabContainer.Position = UDim2.new(0, 12, 0, 88)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = sidebar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabContainer

	-- Créditos na Barra Lateral
	local creditsLbl = Instance.new("TextLabel")
	creditsLbl.Size = UDim2.new(1, -24, 0, 18)
	creditsLbl.Position = UDim2.new(0, 12, 1, -100)
	creditsLbl.BackgroundTransparency = 1
	creditsLbl.Text = "Créditos: " .. MENU_CREDITS
	creditsLbl.TextColor3 = Theme.TextDim
	creditsLbl.Font = Enum.Font.GothamMedium
	creditsLbl.TextSize = 11
	creditsLbl.TextXAlignment = Enum.TextXAlignment.Center
	creditsLbl.Parent = sidebar

	-- Caixa de Status
	local statusBox = Instance.new("Frame")
	statusBox.Size = UDim2.new(1, -24, 0, 62)
	statusBox.Position = UDim2.new(0, 12, 1, -76)
	statusBox.BackgroundColor3 = Theme.Card
	statusBox.BackgroundTransparency = 0.25
	statusBox.BorderSizePixel = 0
	statusBox.Parent = sidebar
	corner(statusBox, 12)
	local statusStroke = stroke(statusBox, Theme.Stroke, 1, 0.45)

	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.new(0, 8, 0, 8)
	statusDot.Position = UDim2.new(0, 12, 0, 14)
	statusDot.BackgroundColor3 = Theme.Accent2
	statusDot.BorderSizePixel = 0
	statusDot.Parent = statusBox
	corner(statusDot, 4)

	local statusTitle = Instance.new("TextLabel")
	statusTitle.Size = UDim2.new(1, -30, 0, 16)
	statusTitle.Position = UDim2.new(0, 26, 0, 10)
	statusTitle.BackgroundTransparency = 1
	statusTitle.Text = "Status"
	statusTitle.TextColor3 = Theme.TextDim
	statusTitle.Font = Enum.Font.GothamMedium
	statusTitle.TextSize = 11
	statusTitle.TextXAlignment = Enum.TextXAlignment.Left
	statusTitle.Parent = statusBox

	local statusValue = Instance.new("TextLabel")
	statusValue.Size = UDim2.new(1, -24, 0, 18)
	statusValue.Position = UDim2.new(0, 12, 0, 32)
	statusValue.BackgroundTransparency = 1
	statusValue.Text = "Pronto para uso!"
	statusValue.TextColor3 = Theme.Accent2
	statusValue.Font = Enum.Font.GothamBold
	statusValue.TextSize = 12
	statusValue.TextXAlignment = Enum.TextXAlignment.Left
	statusValue.Parent = statusBox

	-- Cabeçalho Superior
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -sidebarWidth, 0, 64)
	header.Position = UDim2.new(0, sidebarWidth, 0, 0)
	header.BackgroundTransparency = 1
	header.Parent = mainFrame

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -130, 0, 26)
	titleLbl.Position = UDim2.new(0, 22, 0, 10)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "0z Menu  " .. MENU_VERSION
	titleLbl.TextColor3 = Theme.Text
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 21
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = header

	local subtitleLbl = Instance.new("TextLabel")
	subtitleLbl.Size = UDim2.new(1, -130, 0, 16)
	subtitleLbl.Position = UDim2.new(0, 22, 0, 35)
	subtitleLbl.BackgroundTransparency = 1
	subtitleLbl.Text = "aim • esp • utilidade  •  créditos: " .. MENU_CREDITS
	subtitleLbl.TextColor3 = Theme.TextDim
	subtitleLbl.Font = Enum.Font.GothamMedium
	subtitleLbl.TextSize = 11
	subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLbl.Parent = header

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 30, 0, 30)
	minBtn.Position = UDim2.new(1, -82, 0, 16)
	minBtn.BackgroundColor3 = Theme.Card
	minBtn.BackgroundTransparency = 0.25
	minBtn.BorderSizePixel = 0
	minBtn.Text = "—"
	minBtn.TextColor3 = Theme.TextDim
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 14
	minBtn.AutoButtonColor = false
	minBtn.Parent = header
	corner(minBtn, 8)
	local minStroke = stroke(minBtn, Theme.Stroke, 1, 0.5)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -44, 0, 16)
	closeBtn.BackgroundColor3 = Theme.Card
	closeBtn.BackgroundTransparency = 0.25
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Theme.TextDim
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	corner(closeBtn, 8)
	local closeStroke = stroke(closeBtn, Theme.Stroke, 1, 0.5)

	local isMinimized = false
	local normalSize = mainFrame.Size
	local normalPos = mainFrame.Position
	minBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			normalSize = mainFrame.Size
			normalPos = mainFrame.Position
			sidebar.Visible = false
			mainFrame.Size = UDim2.new(0, 340, 0, 64)
			header.Position = UDim2.new(0, 0, 0, 0)
			header.Size = UDim2.new(1, 0, 1, 0)
			minBtn.Position = UDim2.new(1, -76, 0.5, -15)
			closeBtn.Position = UDim2.new(1, -40, 0.5, -15)
			for _, page in pairs(mainFrame:GetChildren()) do
				if page.Name == "PageHolder" then
					page.Visible = false
				end
			end
		else
			sidebar.Visible = true
			mainFrame.Size = normalSize
			mainFrame.Position = normalPos
			header.Position = UDim2.new(0, sidebarWidth, 0, 0)
			header.Size = UDim2.new(1, -sidebarWidth, 0, 64)
			minBtn.Position = UDim2.new(1, -82, 0, 16)
			closeBtn.Position = UDim2.new(1, -44, 0, 16)
			for _, page in pairs(mainFrame:GetChildren()) do
				if page.Name == "PageHolder" then
					page.Visible = true
				end
			end
		end
	end)

	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Danger, BackgroundTransparency = 0, TextColor3 = Theme.Text }):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.25, TextColor3 = Theme.TextDim }):Play()
	end)
	closeBtn.MouseButton1Click:Connect(function()
		Config.MenuOpen = false
		mainFrame.Visible = false
		emitSync("MenuOpen", false)
	end)

	-- Área das Páginas
	local pageHolder = Instance.new("Frame")
	pageHolder.Name = "PageHolder"
	pageHolder.Size = UDim2.new(1, -sidebarWidth - 28, 1, -74)
	pageHolder.Position = UDim2.new(0, sidebarWidth + 14, 0, 64)
	pageHolder.BackgroundTransparency = 1
	pageHolder.Parent = mainFrame

	local pages, pageCards, tabButtons, tabGradients = {}, {}, {}, {}
	local activeTabName = nil

	local function animatePageCards(page)
		local cards = pageCards[page]
		if not cards then
			return
		end
		for idx, card in ipairs(cards) do
			card.Position = card:GetAttribute("TargetPos") + UDim2.new(0, 26, 0, 0)
			card.BackgroundTransparency = 0.85
			local delayTime = (idx - 1) * 0.045
			task.delay(delayTime, function()
				if card and card.Parent and page.Visible then
					TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Position = card:GetAttribute("TargetPos"),
						BackgroundTransparency = 0.12,
					}):Play()
				end
			end)
		end
	end

	local function setTab(name)
		if activeTabName == name then
			return
		end
		activeTabName = name

		for n, page in pairs(pages) do
			if n == name then
				page.Visible = true
				page.CanvasPosition = Vector2.new(0, 0)
				animatePageCards(page)
			else
				page.Visible = false
			end
		end

		for n, btn in pairs(tabButtons) do
			local active = (n == name)
			local grad = tabGradients[n]
			if grad then
				grad.Enabled = active
				grad.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
			end
			TweenService:Create(btn, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = active and Theme.Accent or Theme.Card,
				BackgroundTransparency = active and 0 or 0.35,
				TextColor3 = active and Theme.Text or Theme.TextDim,
				Position = active and UDim2.new(0, 5, 0, 0) or UDim2.new(0, 0, 0, 0),
			}):Play()
		end

		TweenService:Create(outerStroke, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Thickness = 2.2, Transparency = 0.08 }):Play()
		task.delay(0.24, function()
			if outerStroke and outerStroke.Parent then
				TweenService:Create(outerStroke, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Thickness = 1.5, Transparency = 0.25 }):Play()
			end
		end)
	end

	local function makeTab(name, label, icon, order)
		local slot = Instance.new("Frame")
		slot.Size = UDim2.new(1, 0, 0, 38)
		slot.BackgroundTransparency = 1
		slot.LayoutOrder = order
		slot.Parent = tabContainer

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -5, 1, 0)
		btn.Position = UDim2.new(0, 0, 0, 0)
		btn.BackgroundColor3 = Theme.Card
		btn.BackgroundTransparency = 0.35
		btn.BorderSizePixel = 0
		btn.Text = "   " .. icon .. "   " .. label
		btn.TextColor3 = Theme.TextDim
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.Parent = slot
		corner(btn, 10)
		local g = makeGradient(btn, Theme.Accent, Theme.Accent2, 15)
		g.Enabled = false
		tabGradients[name] = g

		btn.MouseButton1Click:Connect(function()
			setTab(name)
		end)
		tabButtons[name] = btn

		local page = Instance.new("ScrollingFrame")
		page.Name = name .. "Page"
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = Theme.Accent
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = pageHolder
		pad(page, 2, 14, 2, 6)
		pageCards[page] = {}

		onThemeChanged(function()
			page.ScrollBarImageColor3 = Theme.Accent
		end)

		return page
	end

	local function createGroupCard(parent, titleText, iconText, posUDim2, sizeUDim2)
		local card = Instance.new("Frame")
		card.Size = sizeUDim2
		card.Position = posUDim2
		card:SetAttribute("TargetPos", posUDim2)
		card.BackgroundColor3 = Theme.Panel
		card.BackgroundTransparency = 0.12
		card.BorderSizePixel = 0
		card.Parent = parent
		corner(card, 14)
		local cStroke = stroke(card, Theme.Stroke, 1, 0.35)

		if pageCards[parent] then
			table.insert(pageCards[parent], card)
		end

		local headerBar = Instance.new("Frame")
		headerBar.Size = UDim2.new(1, -24, 0, 34)
		headerBar.Position = UDim2.new(0, 12, 0, 8)
		headerBar.BackgroundTransparency = 1
		headerBar.Parent = card

		local hIcon = Instance.new("TextLabel")
		hIcon.Size = UDim2.new(0, 22, 1, 0)
		hIcon.Position = UDim2.new(0, 0, 0, 0)
		hIcon.BackgroundTransparency = 1
		hIcon.Text = iconText
		hIcon.TextColor3 = Theme.Accent2
		hIcon.Font = Enum.Font.GothamBold
		hIcon.TextSize = 15
		hIcon.Parent = headerBar

		local hTitle = Instance.new("TextLabel")
		hTitle.Size = UDim2.new(1, -26, 1, 0)
		hTitle.Position = UDim2.new(0, 26, 0, 0)
		hTitle.BackgroundTransparency = 1
		hTitle.Text = titleText
		hTitle.TextColor3 = Theme.Text
		hTitle.Font = Enum.Font.GothamBold
		hTitle.TextSize = 14
		hTitle.TextXAlignment = Enum.TextXAlignment.Left
		hTitle.Parent = headerBar

		local divider = Instance.new("Frame")
		divider.Size = UDim2.new(1, -24, 0, 1)
		divider.Position = UDim2.new(0, 12, 0, 42)
		divider.BackgroundColor3 = Theme.Stroke
		divider.BackgroundTransparency = 0.55
		divider.BorderSizePixel = 0
		divider.Parent = card

		onThemeChanged(function()
			cStroke.Color = Theme.Stroke
			hIcon.TextColor3 = Theme.Accent2
			divider.BackgroundColor3 = Theme.Stroke
		end)

		local items = Instance.new("Frame")
		items.Name = "Items"
		items.Size = UDim2.new(1, -20, 1, -50)
		items.Position = UDim2.new(0, 10, 0, 46)
		items.BackgroundTransparency = 1
		items.Parent = card

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 5)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = items

		return items
	end

	local function addToggle(parent, labelText, initialState, onToggle, order, syncKey)
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundTransparency = 1
		row.Text = ""
		row.AutoButtonColor = false
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -56, 1, 0)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local switchBg = Instance.new("Frame")
		switchBg.Size = UDim2.new(0, 36, 0, 18)
		switchBg.Position = UDim2.new(1, -40, 0.5, -9)
		switchBg.BackgroundColor3 = Theme.TrackOff
		switchBg.BorderSizePixel = 0
		switchBg.Parent = row
		corner(switchBg, 9)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Position = UDim2.new(0, 2, 0.5, -7)
		knob.BackgroundColor3 = Theme.Text
		knob.BorderSizePixel = 0
		knob.Parent = switchBg
		corner(knob, 7)

		local state = initialState
		local function refresh(anim)
			local info = TweenInfo.new(anim and 0.16 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if state then
				TweenService:Create(switchBg, info, { BackgroundColor3 = Theme.Accent }):Play()
				TweenService:Create(knob, info, { Position = UDim2.new(1, -16, 0.5, -7) }):Play()
			else
				TweenService:Create(switchBg, info, { BackgroundColor3 = Theme.TrackOff }):Play()
				TweenService:Create(knob, info, { Position = UDim2.new(0, 2, 0.5, -7) }):Play()
			end
		end
		refresh(false)

		onThemeChanged(function()
			refresh(false)
		end)

		if syncKey then
			registerSync(syncKey, function(newVal)
				if state ~= newVal then
					state = newVal
					refresh(false)
				end
			end)
		end

		row.MouseButton1Click:Connect(function()
			state = not state
			refresh(true)
			onToggle(state)
			if syncKey then
				emitSync(syncKey, state)
			end
		end)
	end

	local function colorsClose(a, b)
		if typeof(a) ~= "Color3" or typeof(b) ~= "Color3" then
			return false
		end
		return math.abs(a.R - b.R) < 0.01 and math.abs(a.G - b.G) < 0.01 and math.abs(a.B - b.B) < 0.01
	end

	local function addColorDot(parent, labelText, initialColor, onSelect, order)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -135, 1, 0)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local palette = {
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(168, 85, 247),
			Color3.fromRGB(59, 130, 246),
			Color3.fromRGB(34, 197, 94),
			Color3.fromRGB(239, 68, 68),
		}

		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(0, 114, 0, 20)
		holder.Position = UDim2.new(1, -118, 0.5, -10)
		holder.BackgroundTransparency = 1
		holder.Parent = row

		local hlLayout = Instance.new("UIListLayout")
		hlLayout.FillDirection = Enum.FillDirection.Horizontal
		hlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		hlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		hlLayout.Padding = UDim.new(0, 6)
		hlLayout.Parent = holder

		local buttons = {}
		local currentCol = initialColor
		local function updateSelected(col)
			currentCol = col
			for _, b in ipairs(buttons) do
				local st = b:FindFirstChildOfClass("UIStroke")
				if st then
					local isMatch = colorsClose(b.BackgroundColor3, col)
					st.Color = isMatch and Theme.Accent2 or Theme.Stroke
					st.Thickness = isMatch and 2 or 1
				end
			end
		end

		onThemeChanged(function()
			updateSelected(currentCol)
		end)

		registerSync("EspFillColor", function(newCol)
			updateSelected(newCol)
		end)

		for i, col in ipairs(palette) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 16, 0, 16)
			btn.BackgroundColor3 = col
			btn.Text = ""
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.LayoutOrder = i
			btn.Parent = holder
			corner(btn, 8)
			stroke(btn, Theme.Stroke, 1, 0.2)
			table.insert(buttons, btn)

			btn.MouseButton1Click:Connect(function()
				updateSelected(col)
				onSelect(col)
				emitSync("EspFillColor", col)
			end)
		end
		updateSelected(initialColor)
	end

	local function addSlider(parent, labelText, minV, maxV, initialV, onChange, order, suffix, syncKey, isScale)
		suffix = suffix or ""
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 42)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -76, 0, 18)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local function fmt(val)
			if suffix == "%" then
				return tostring(math.floor(val * 100 + 0.5)) .. "%"
			elseif isScale then
				return string.format("%.2f", val) .. "x"
			elseif maxV >= 100 and suffix == "" then
				return tostring(math.floor(val + 0.5))
			else
				return string.format("%.2f", val):gsub("%.?0+$", "") .. suffix
			end
		end

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 68, 0, 18)
		valLbl.Position = UDim2.new(1, -72, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = fmt(initialV)
		valLbl.TextColor3 = Theme.Text
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextSize = 12
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = row

		local barHit = Instance.new("Frame")
		barHit.Size = UDim2.new(1, -8, 0, 16)
		barHit.Position = UDim2.new(0, 4, 0, 22)
		barHit.BackgroundTransparency = 1
		barHit.Parent = row

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, 0, 0, 5)
		track.Position = UDim2.new(0, 0, 0.5, -2.5)
		track.BackgroundColor3 = Theme.TrackOff
		track.BorderSizePixel = 0
		track.Parent = barHit
		corner(track, 3)

		local initT = math.clamp((initialV - minV) / (maxV - minV), 0, 1)
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(initT, 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel = 0
		fill.Parent = track
		corner(fill, 3)
		local fillGrad = makeGradient(fill, Theme.Accent, Theme.Accent2, 0)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 12, 0, 12)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new(initT, 0, 0.5, 0)
		knob.BackgroundColor3 = Theme.Text
		knob.BorderSizePixel = 0
		knob.Parent = track
		corner(knob, 6)
		local knobStroke = stroke(knob, Theme.Accent, 2, 0)

		onThemeChanged(function()
			fill.BackgroundColor3 = Theme.Accent
			fillGrad.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
			knobStroke.Color = Theme.Accent
		end)

		local function applyVisual(val)
			local t = math.clamp((val - minV) / (maxV - minV), 0, 1)
			valLbl.Text = fmt(val)
			fill.Size = UDim2.new(t, 0, 1, 0)
			knob.Position = UDim2.new(t, 0, 0.5, 0)
		end

		if syncKey then
			registerSync(syncKey, function(newVal)
				applyVisual(newVal)
			end)
		end

		local draggingSlider = false
		local function setFromX(x)
			local absX, w = barHit.AbsolutePosition.X, barHit.AbsoluteSize.X
			if w <= 0 then
				return
			end
			local t = math.clamp((x - absX) / w, 0, 1)
			local val = minV + (maxV - minV) * t
			if isScale then
				val = math.floor(val * 20 + 0.5) / 20
			elseif maxV >= 100 and suffix == "" then
				val = math.floor(val + 0.5)
			end
			applyVisual(val)
			onChange(val)
			if syncKey then
				emitSync(syncKey, val)
			end
		end

		barHit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSlider = true
				IS_SLIDER_DRAGGING = true
				setFromX(input.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				draggingSlider = false
				IS_SLIDER_DRAGGING = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				setFromX(input.Position.X)
			end
		end)
	end

	local function addDropdown(parent, labelText, displayOptions, initialDisplayVal, onSelect, order, syncKey)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundTransparency = 1
		row.ZIndex = 5
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -125, 1, 0)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local dropBtn = Instance.new("TextButton")
		dropBtn.Size = UDim2.new(0, 114, 0, 22)
		dropBtn.Position = UDim2.new(1, -118, 0.5, -11)
		dropBtn.BackgroundColor3 = Theme.Card
		dropBtn.BorderSizePixel = 0
		dropBtn.Text = tostring(initialDisplayVal) .. " v"
		dropBtn.TextColor3 = Theme.Text
		dropBtn.Font = Enum.Font.GothamMedium
		dropBtn.TextSize = 11
		dropBtn.AutoButtonColor = false
		dropBtn.ZIndex = 6
		dropBtn.Parent = row
		corner(dropBtn, 6)
		local dropStroke = stroke(dropBtn, Theme.Stroke, 1, 0.35)

		local menuList = Instance.new("Frame")
		menuList.Size = UDim2.new(0, 114, 0, #displayOptions * 22)
		menuList.Position = UDim2.new(1, -118, 1, 2)
		menuList.BackgroundColor3 = Theme.CardHover
		menuList.BorderSizePixel = 0
		menuList.Visible = false
		menuList.ZIndex = 20
		menuList.Parent = row
		corner(menuList, 6)
		local menuStroke = stroke(menuList, Theme.Accent, 1, 0.25)

		onThemeChanged(function()
			dropStroke.Color = Theme.Stroke
			menuStroke.Color = Theme.Accent
		end)

		local mLayout = Instance.new("UIListLayout")
		mLayout.SortOrder = Enum.SortOrder.LayoutOrder
		mLayout.Parent = menuList

		local open = false
		dropBtn.MouseButton1Click:Connect(function()
			open = not open
			menuList.Visible = open
			IS_DROPDOWN_OPEN = open
			row.ZIndex = open and 25 or 5
		end)

		if syncKey then
			registerSync(syncKey, function(newLabel)
				dropBtn.Text = tostring(newLabel) .. " v"
			end)
		end

		for idx, opt in ipairs(displayOptions) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, 0, 0, 22)
			optBtn.BackgroundTransparency = 1
			optBtn.Text = tostring(opt)
			optBtn.TextColor3 = Theme.Text
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.TextSize = 11
			optBtn.LayoutOrder = idx
			optBtn.ZIndex = 21
			optBtn.Parent = menuList

			optBtn.MouseButton1Click:Connect(function()
				dropBtn.Text = tostring(opt) .. " v"
				open = false
				menuList.Visible = false
				IS_DROPDOWN_OPEN = false
				row.ZIndex = 5
				onSelect(opt)
				if syncKey then
					emitSync(syncKey, opt)
				end
			end)
		end
	end

	local listeningBind = false
	local function addKeybind(parent, labelText, initialBind, allowMouseButton, onBind, order, syncKey)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -96, 1, 0)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local bindBtn = Instance.new("TextButton")
		bindBtn.Size = UDim2.new(0, 82, 0, 22)
		bindBtn.Position = UDim2.new(1, -86, 0.5, -11)
		bindBtn.BackgroundColor3 = Theme.Card
		bindBtn.BorderSizePixel = 0
		bindBtn.Text = formatInputName(initialBind)
		bindBtn.TextColor3 = Theme.Text
		bindBtn.Font = Enum.Font.GothamBold
		bindBtn.TextSize = 11
		bindBtn.AutoButtonColor = false
		bindBtn.Parent = row
		corner(bindBtn, 6)
		local bindStroke = stroke(bindBtn, Theme.Stroke, 1, 0.35)

		onThemeChanged(function()
			bindStroke.Color = Theme.Stroke
		end)

		if syncKey then
			registerSync(syncKey, function(newBind)
				bindBtn.Text = formatInputName(newBind)
			end)
		end

		bindBtn.MouseButton1Click:Connect(function()
			if listeningBind then
				return
			end
			listeningBind = true
			local prevText = bindBtn.Text
			bindBtn.Text = "..."
			local conn
			conn = UserInputService.InputBegan:Connect(function(input, gp)
				if gp then
					return
				end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					conn:Disconnect()
					listeningBind = false
					if input.KeyCode ~= Enum.KeyCode.Escape then
						bindBtn.Text = formatInputName(input.KeyCode)
						onBind(input.KeyCode)
						if syncKey then
							emitSync(syncKey, input.KeyCode)
						end
					else
						bindBtn.Text = prevText
					end
				elseif allowMouseButton and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3) then
					conn:Disconnect()
					listeningBind = false
					bindBtn.Text = formatInputName(input.UserInputType)
					onBind(input.UserInputType)
					if syncKey then
						emitSync(syncKey, input.UserInputType)
					end
				end
			end)
		end)
	end

	local function addActionButton(parent, labelText, buttonText, onClick, order)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 32)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -135, 1, 0)
		lbl.Position = UDim2.new(0, 4, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 122, 0, 24)
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, -4, 0.5, 0)
		btn.BackgroundColor3 = FixedActionTheme.Bg
		btn.BorderSizePixel = 0
		btn.Text = buttonText
		btn.TextColor3 = Theme.Text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 11
		btn.AutoButtonColor = false
		btn.Parent = row
		corner(btn, 7)

		local btnScale = Instance.new("UIScale")
		btnScale.Scale = 1
		btnScale.Parent = btn

		local btnStroke = stroke(btn, FixedActionTheme.Glow, 1.2, 0.55)
		makeGradient(btn, FixedActionTheme.GradA, FixedActionTheme.GradB, 15)

		local busy = false
		btn.MouseEnter:Connect(function()
			if not busy then
				TweenService:Create(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.04 }):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.15 }):Play()
			end
		end)

		btn.MouseLeave:Connect(function()
			if not busy then
				TweenService:Create(btnScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
				TweenService:Create(btnStroke, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 0.55 }):Play()
			end
		end)

		btn.MouseButton1Click:Connect(function()
			if busy then
				return
			end
			busy = true

			local downTween = TweenService:Create(btnScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 0.92 })
			downTween:Play()
			downTween.Completed:Connect(function()
				TweenService:Create(btnScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1.03 }):Play()
			end)
			TweenService:Create(btnStroke, TweenInfo.new(0.12), { Thickness = 2.2, Transparency = 0 }):Play()

			local okSaved, msg, badgeTitle = onClick()
			showSaveNotification(badgeTitle or "Salvo", msg or "Alterações salvas com sucesso!", not okSaved)

			if msg then
				btn.Text = okSaved and ("✓ " .. (badgeTitle or "Salvo!")) or "✕ Erro!"
				statusValue.Text = okSaved and (badgeTitle or "Salvo!") or "Falha ao salvar"
				task.delay(1.5, function()
					if btn and btn.Parent then
						btn.Text = buttonText
						TweenService:Create(btnScale, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
						TweenService:Create(btnStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Thickness = 1.2, Transparency = 0.55 }):Play()
					end
					if statusValue and statusValue.Parent then
						statusValue.Text = "Pronto para uso!"
					end
					busy = false
				end)
			else
				busy = false
			end
		end)
	end

	local function applyThemePreset(themeName)
		local preset = ThemePresets[themeName] or ThemePresets.Roxo
		Config.ThemeName = themeName
		Theme.Accent = preset.Accent
		Theme.Accent2 = preset.Accent2
		Theme.Glow = preset.Glow
		Theme.Stroke = preset.Stroke

		outerStroke.Color = Theme.Accent
		outerGrad.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
		sidebarStroke.Color = Theme.Stroke
		glowArc.BackgroundColor3 = Theme.Accent
		s0.Color = Theme.Accent2
		logoZGrad.Color = ColorSequence.new(Theme.Glow, Theme.Accent)
		sZ.Color = Theme.Glow
		statusStroke.Color = Theme.Stroke
		statusDot.BackgroundColor3 = Theme.Accent2
		statusValue.TextColor3 = Theme.Accent2
		minStroke.Color = Theme.Stroke
		closeStroke.Color = Theme.Stroke
		toastStroke.Color = Theme.Accent2
		toastBar.BackgroundColor3 = Theme.Accent2

		for n, btn in pairs(tabButtons) do
			local isAct = (n == activeTabName)
			local g = tabGradients[n]
			if g then
				g.Color = ColorSequence.new(Theme.Accent, Theme.Accent2)
			end
			btn.BackgroundColor3 = isAct and Theme.Accent or Theme.Card
		end

		for _, fn in ipairs(ThemeListeners) do
			fn()
		end
	end

	local function resetToDefaultConfig()
		Config.EspEnabled = DefaultConfig.EspEnabled
		Config.TeamCheck = DefaultConfig.TeamCheck
		applyEspColorsToAll(DefaultConfig.EspFillColor)
		Config.EspFillTransparency = DefaultConfig.EspFillTransparency
		Config.EspDepthMode = DefaultConfig.EspDepthMode
		Config.AimbotEnabled = DefaultConfig.AimbotEnabled
		Config.AimToggleKey = DefaultConfig.AimToggleKey
		Config.AimPart = DefaultConfig.AimPart
		Config.AimFOV = DefaultConfig.AimFOV
		Config.AimbotSmoothness = DefaultConfig.AimbotSmoothness
		Config.AimMaxDistance = DefaultConfig.AimMaxDistance
		Config.AimVisibleOnly = DefaultConfig.AimVisibleOnly
		Config.AimNoWall = DefaultConfig.AimNoWall
		Config.AimPrediction = DefaultConfig.AimPrediction
		Config.AimLockOnTarget = DefaultConfig.AimLockOnTarget
		Config.AimIgnoreFriends = DefaultConfig.AimIgnoreFriends
		Config.AimHumanize = DefaultConfig.AimHumanize
		Config.RecoilReduction = DefaultConfig.RecoilReduction
		Config.NoSpreadEnabled = DefaultConfig.NoSpreadEnabled
		Config.MenuOpen = DefaultConfig.MenuOpen
		Config.MenuKey = DefaultConfig.MenuKey
		Config.UiScale = DefaultConfig.UiScale
		Config.ThemeName = DefaultConfig.ThemeName

		mainFrame.Visible = Config.MenuOpen
		setUiScale(Config.UiScale)
		applyThemePreset(Config.ThemeName)

		emitSync("EspEnabled", Config.EspEnabled)
		emitSync("TeamCheck", Config.TeamCheck)
		emitSync("EspFillColor", Config.EspFillColor)
		emitSync("EspFillTransparency", Config.EspFillTransparency)
		emitSync("EspDepthMode", formatDepthMode(Config.EspDepthMode))
		emitSync("RecoilReduction", Config.RecoilReduction)
		emitSync("NoSpreadEnabled", Config.NoSpreadEnabled)
		emitSync("MenuKey", Config.MenuKey)
		emitSync("MenuOpen", Config.MenuOpen)
		emitSync("AimbotEnabled", Config.AimbotEnabled)
		emitSync("AimToggleKey", Config.AimToggleKey)
		emitSync("AimPart", formatAimPart(Config.AimPart))
		emitSync("AimFOV", Config.AimFOV)
		emitSync("AimbotSmoothness", Config.AimbotSmoothness)
		emitSync("AimMaxDistance", Config.AimMaxDistance)
		emitSync("AimVisibleOnly", Config.AimVisibleOnly)
		emitSync("AimNoWall", Config.AimNoWall)
		emitSync("AimPrediction", Config.AimPrediction)
		emitSync("AimLockOnTarget", Config.AimLockOnTarget)
		emitSync("AimIgnoreFriends", Config.AimIgnoreFriends)
		emitSync("AimHumanize", Config.AimHumanize)
		emitSync("ThemeName", Config.ThemeName)
		emitSync("UiScale", Config.UiScale)

		return true, "Configurações restauradas para o padrão!", "Resetado!"
	end

	-- Criar Abas
	local combatPage = makeTab("combat", "Combate", "◎", 1)
	local visualsPage = makeTab("visuals", "Visual", "◉", 2)
	local settingsPage = makeTab("settings", "Configurações", "⚙", 3)
	pages.combat = combatPage
	pages.visuals = visualsPage
	pages.settings = settingsPage

	-- ===========================
	-- ABA COMBATE
	-- ===========================
	local espCard = createGroupCard(combatPage, "ESP", "🖥", UDim2.new(0, 0, 0, 0), UDim2.new(0.485, 0, 0, 198))
	local o = 0
	local function ord()
		o = o + 1
		return o
	end
	addToggle(espCard, "Ativar ESP", Config.EspEnabled, function(v)
		Config.EspEnabled = v
	end, ord(), "EspEnabled")
	addToggle(espCard, "Ignorar Aliados", Config.TeamCheck, function(v)
		Config.TeamCheck = v
	end, ord(), "TeamCheck")
	addSlider(espCard, "Transparência", 0, 1, Config.EspFillTransparency, function(v)
		Config.EspFillTransparency = v
		for _, hl in pairs(Highlights) do
			if hl and hl.Parent then
				hl.FillTransparency = v
			end
		end
	end, ord(), "%", "EspFillTransparency", false)
	addDropdown(espCard, "Modo de Visão", { "Sempre no Topo", "Ocluso" }, formatDepthMode(Config.EspDepthMode), function(opt)
		Config.EspDepthMode = parseDepthMode(opt)
	end, ord(), "EspDepthMode")

	local miscCard = createGroupCard(combatPage, "Diversos", "⚙", UDim2.new(0, 0, 0, 208), UDim2.new(0.485, 0, 0, 190))
	o = 0
	addSlider(miscCard, "Redução de Recuo", 0, 1, Config.RecoilReduction, function(v)
		Config.RecoilReduction = v
	end, ord(), "%", "RecoilReduction", false)
	addToggle(miscCard, "Tiros Certos (Sem Spread)", Config.NoSpreadEnabled, function(v)
		Config.NoSpreadEnabled = v
	end, ord(), "NoSpreadEnabled")
	addKeybind(miscCard, "Tecla do Menu", Config.MenuKey, false, function(newKey)
		Config.MenuKey = newKey
	end, ord(), "MenuKey")
	addToggle(miscCard, "Menu Aberto", Config.MenuOpen, function(v)
		setMenuVisibility(v)
	end, ord(), "MenuOpen")

	local aimCard = createGroupCard(combatPage, "Aimbot", "⊕", UDim2.new(0.505, 0, 0, 0), UDim2.new(0.495, 0, 0, 520))
	o = 0
	addToggle(aimCard, "Ativar Aimbot", Config.AimbotEnabled, function(v)
		Config.AimbotEnabled = v
	end, ord(), "AimbotEnabled")
	addKeybind(aimCard, "Alternar Mira", Config.AimToggleKey, false, function(newKey)
		Config.AimToggleKey = newKey
	end, ord(), "AimToggleKey")
	addDropdown(aimCard, "Parte do Alvo", { "Cabeça", "Tronco (HRP)", "Peito" }, formatAimPart(Config.AimPart), function(opt)
		Config.AimPart = parseAimPart(opt)
	end, ord(), "AimPart")
	addSlider(aimCard, "Campo de Visão (FOV)", 20, 400, Config.AimFOV, function(v)
		Config.AimFOV = v
	end, ord(), "", "AimFOV", false)
	addSlider(aimCard, "Suavidade", 0.05, 1, Config.AimbotSmoothness, function(v)
		Config.AimbotSmoothness = v
	end, ord(), "", "AimbotSmoothness", false)
	addSlider(aimCard, "Distância Máxima", 50, 2000, Config.AimMaxDistance, function(v)
		Config.AimMaxDistance = v
	end, ord(), "", "AimMaxDistance", false)
	addToggle(aimCard, "Apenas Visíveis", Config.AimVisibleOnly, function(v)
		Config.AimVisibleOnly = v
	end, ord(), "AimVisibleOnly")
	addToggle(aimCard, "Sem Parede", Config.AimNoWall, function(v)
		Config.AimNoWall = v
		if v and currentTarget and not isVisible(currentTarget) then
			currentTarget = nil
		end
	end, ord(), "AimNoWall")
	addToggle(aimCard, "Previsão de Movimento", Config.AimPrediction, function(v)
		Config.AimPrediction = v
	end, ord(), "AimPrediction")
	addToggle(aimCard, "Travar no Alvo", Config.AimLockOnTarget, function(v)
		Config.AimLockOnTarget = v
	end, ord(), "AimLockOnTarget")
	addToggle(aimCard, "Ignorar Amigos", Config.AimIgnoreFriends, function(v)
		Config.AimIgnoreFriends = v
	end, ord(), "AimIgnoreFriends")
	addToggle(aimCard, "Humanizar Mira", Config.AimHumanize, function(v)
		Config.AimHumanize = v
	end, ord(), "AimHumanize")

	-- ===========================
	-- ABA VISUAL
	-- ===========================
	local visEspCard = createGroupCard(visualsPage, "ESP", "🖥", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 232))
	o = 0
	addToggle(visEspCard, "Ativar ESP", Config.EspEnabled, function(v)
		Config.EspEnabled = v
	end, ord(), "EspEnabled")
	addToggle(visEspCard, "Ignorar Aliados", Config.TeamCheck, function(v)
		Config.TeamCheck = v
	end, ord(), "TeamCheck")
	addColorDot(visEspCard, "Cor do ESP", Config.EspFillColor, function(col)
		applyEspColorsToAll(col)
	end, ord())
	addSlider(visEspCard, "Transparência", 0, 1, Config.EspFillTransparency, function(v)
		Config.EspFillTransparency = v
		for _, hl in pairs(Highlights) do
			if hl and hl.Parent then
				hl.FillTransparency = v
			end
		end
	end, ord(), "%", "EspFillTransparency", false)
	addDropdown(visEspCard, "Modo de Visão", { "Sempre no Topo", "Ocluso" }, formatDepthMode(Config.EspDepthMode), function(opt)
		Config.EspDepthMode = parseDepthMode(opt)
	end, ord(), "EspDepthMode")

	-- ===========================
	-- ABA CONFIGURAÇÕES
	-- ===========================
	local menuSetCard = createGroupCard(settingsPage, "Interface e Configuração (" .. MENU_VERSION .. ")", "⚙", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 346))
	o = 0
	addDropdown(menuSetCard, "Temas", { "Roxo", "Vermelho", "Azul", "Verde" }, Config.ThemeName, function(opt)
		applyThemePreset(opt)
	end, ord(), "ThemeName")
	addSlider(menuSetCard, "Escala da Interface", 0.75, 1.35, Config.UiScale, function(v)
		setUiScale(v)
	end, ord(), "", "UiScale", true)
	addKeybind(menuSetCard, "Tecla do Menu", Config.MenuKey, false, function(newKey)
		Config.MenuKey = newKey
	end, ord(), "MenuKey")
	addKeybind(menuSetCard, "Alternar Mira", Config.AimToggleKey, false, function(newKey)
		Config.AimToggleKey = newKey
	end, ord(), "AimToggleKey")
	addToggle(menuSetCard, "Menu Aberto", Config.MenuOpen, function(v)
		setMenuVisibility(v)
	end, ord(), "MenuOpen")
	addActionButton(menuSetCard, "Salvar Alterações", "Salvar Mudanças", function()
		return saveCurrentConfig()
	end, ord())
	addActionButton(menuSetCard, "Resetar Alterações", "Resetar Padrão", function()
		return resetToDefaultConfig()
	end, ord())

	setTab("combat")
	applyThemePreset(Config.ThemeName)
	emitSync("EspFillColor", Config.EspFillColor)
	if Config.MenuOpen and NotifyCallback then
		NotifyCallback("Bem vindo!", "Bem vindo! " .. getPlayerDisplayName(), false)
	end
	return mainFrame
end

local MainMenuFrame = createUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Config.MenuKey then
		local nextOpen = not Config.MenuOpen
		Config.MenuOpen = nextOpen
		if MainMenuFrame then
			MainMenuFrame.Visible = nextOpen
		end
		emitSync("MenuOpen", nextOpen)
		if nextOpen and NotifyCallback then
			NotifyCallback("Bem vindo!", "Bem vindo! " .. getPlayerDisplayName(), false)
		end
	end
	if not gameProcessed and input.KeyCode == Config.AimToggleKey then
		aimHeld = not aimHeld
		if not aimHeld then
			currentTarget = nil
		end
		if NotifyCallback then
			if aimHeld then
				NotifyCallback("Aim Ativado", "Mira travada/ativa via tecla " .. formatInputName(Config.AimToggleKey) .. ".", false)
			else
				NotifyCallback("Aim Desativado", "Mira desativada via tecla " .. formatInputName(Config.AimToggleKey) .. ".", true)
			end
		end
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fireHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		fireHeld = false
	end
end)

UserInputService.WindowFocusReleased:Connect(function()
	fireHeld = false
end)

local function isFriend(player)
	if not Config.AimIgnoreFriends then
		return false
	end
	return friendCache[player.UserId] == true
end

local function isValidTarget(player, forAim)
	if player == LocalPlayer then
		return false
	end
	if Config.TeamCheck and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then
		return false
	end
	if forAim and isFriend(player) then
		return false
	end
	local character = player.Character
	if not character then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local aimPart = character:FindFirstChild(Config.AimPart) or character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not aimPart then
		return false
	end
	return true, aimPart
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(part)
	if not Config.AimVisibleOnly and not Config.AimNoWall then
		return true
	end
	if not part or not Camera then
		return true
	end
	local ignoreList = {}
	if LocalPlayer and LocalPlayer.Character then
		table.insert(ignoreList, LocalPlayer.Character)
	end
	if part.Parent then
		table.insert(ignoreList, part.Parent)
	end
	rayParams.FilterDescendantsInstances = ignoreList
	local direction = part.Position - Camera.CFrame.Position
	local result = workspace:Raycast(Camera.CFrame.Position, direction, rayParams)
	return result == nil
end

local function removeHighlight(player)
	if Highlights[player] then
		Highlights[player]:Destroy()
		Highlights[player] = nil
	end
end

local function syncHighlight(player, character)
	if not character then
		removeHighlight(player)
		return
	end
	local hl = Highlights[player]
	if not hl or not hl.Parent then
		hl = Instance.new("Highlight")
		hl.Name = "0zMenuHighlight"
		hl.OutlineTransparency = 0
		Highlights[player] = hl
	end
	hl.DepthMode = (Config.EspDepthMode == "Occluded") and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = Config.EspFillTransparency
	hl.FillColor = Config.EspFillColor
	hl.OutlineColor = Config.EspOutlineColor
	hl.Adornee = character
	hl.Parent = character
end

local function predictPosition(part)
	if not Config.AimPrediction or not Camera then
		return part.Position
	end
	local root = part.Parent and (part.Parent:FindFirstChild("HumanoidRootPart") or part.Parent:FindFirstChild("UpperTorso"))
	local vel = (root and root.AssemblyLinearVelocity) or part.AssemblyLinearVelocity or Vector3.zero
	local dist = (part.Position - Camera.CFrame.Position).Magnitude
	local leadTime = Config.AimPredictionAmount * (1 + math.clamp(dist / 250, 0, 0.75))
	return part.Position + (vel * leadTime)
end

local function isTargetInRangeAndFOV(part)
	if not part or not Camera then
		return false
	end
	local dist3D = (part.Position - Camera.CFrame.Position).Magnitude
	if dist3D > Config.AimMaxDistance then
		return false
	end
	local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
	if not onScreen or screenPos.Z <= 0 then
		return false
	end
	local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
	local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
	return d <= Config.AimFOV
end

local function getBestTarget()
	Camera = workspace.CurrentCamera
	if not Camera then
		return nil
	end
	local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
	local best, bestScore = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		local valid, targetPart = isValidTarget(player, true)
		if valid and targetPart then
			local dist3D = (targetPart.Position - Camera.CFrame.Position).Magnitude
			if dist3D <= Config.AimMaxDistance and isVisible(targetPart) then
				local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
				if onScreen and screenPos.Z > 0 then
					local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					if d <= Config.AimFOV then
						local score = d + (dist3D * 0.08)
						if currentTarget == targetPart then
							score = score - 120
						end
						if score < bestScore then
							bestScore = score
							best = targetPart
						end
					end
				end
			end
		end
	end
	return best
end

local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 1
RunService:BindToRenderStep("0zAimbot", AIM_PRIORITY, function()
	Camera = workspace.CurrentCamera
	if not Camera then
		return
	end

	local currentCF = Camera.CFrame
	local currentLook = currentCF.LookVector

	local effectiveRecoil = Config.RecoilReduction or 0
	if Config.NoSpreadEnabled then
		effectiveRecoil = math.max(effectiveRecoil, 0.85)
	end

	if effectiveRecoil > 0 and fireHeld and lastCameraLook then
		local mouseDelta = UserInputService:GetMouseDelta()
		if mouseDelta.Magnitude < 2.5 then
			local pitchDiff = currentLook.Y - lastCameraLook.Y
			if pitchDiff > 0.0005 then
				local correctedLook = (currentLook - Vector3.new(0, pitchDiff * effectiveRecoil, 0)).Unit
				currentCF = CFrame.lookAt(currentCF.Position, currentCF.Position + correctedLook)
				Camera.CFrame = currentCF
				currentLook = correctedLook
			end
		end
	end
	lastCameraLook = currentLook

	if not Config.AimbotEnabled or not aimHeld then
		currentTarget = nil
		return
	end

	if Config.AimLockOnTarget and currentTarget then
		local char = currentTarget.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not char or not hum or hum.Health <= 0 or not isVisible(currentTarget) or not isTargetInRangeAndFOV(currentTarget) then
			currentTarget = nil
		end
	end

	if not currentTarget or not Config.AimLockOnTarget then
		currentTarget = getBestTarget()
	end
	if not currentTarget then
		return
	end

	local aimWorldPos = predictPosition(currentTarget)
	local camPos = Camera.CFrame.Position
	local toTarget = (aimWorldPos - camPos).Unit
	local angleRad = math.acos(math.clamp(Camera.CFrame.LookVector:Dot(toTarget), -1, 1))
	local desired = CFrame.lookAt(camPos, aimWorldPos)

	local alpha = math.clamp(Config.AimbotSmoothness, 0.02, 1)
	if Config.NoSpreadEnabled then
		alpha = math.clamp(math.max(alpha, 0.65), 0.02, 1)
	elseif angleRad < 0.015 then
		alpha = math.clamp(alpha * 0.65, 0.02, 0.85)
	elseif Config.AimHumanize then
		alpha = math.clamp(alpha * (0.9 + math.random() * 0.2), 0.02, 1)
	end

	Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
	lastCameraLook = Camera.CFrame.LookVector
end)

RunService.RenderStepped:Connect(function()
	Camera = workspace.CurrentCamera
	if not Camera then
		return
	end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if Config.EspEnabled and isValidTarget(player, false) and player.Character then
				syncHighlight(player, player.Character)
			else
				removeHighlight(player)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	removeHighlight(player)
	if currentTarget and currentTarget.Parent == player.Character then
		currentTarget = nil
	end
end)
