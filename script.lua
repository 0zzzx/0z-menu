local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
	EspEnabled = true,
	TeamCheck = false,
	EspFillColor = Color3.fromRGB(255, 255, 255),
	EspOutlineColor = Color3.fromRGB(255, 255, 255),
	EspFillTransparency = 0.65,
	EspDepthMode = "AlwaysOnTop",

	AimbotEnabled = true,
	AimKey = Enum.UserInputType.MouseButton2,
	AimToggleKey = Enum.KeyCode.H,
	AimPart = "Head",
	AimFOV = 250,
	AimbotSmoothness = 0.35,
	AimMaxDistance = 1000,
	AimVisibleOnly = false,
	AimPrediction = false,
	AimPredictionAmount = 0.15,
	AimLockOnTarget = true,
	AimIgnoreFriends = false,
	AimHumanize = true,

	RecoilReduction = 0.0,
	MenuOpen = true,
	MenuKey = Enum.KeyCode.J,
}

local Highlights, GuiName = {}, "0zMenuEspUI"
local friendCache = {}
pcall(function()
	for _, f in ipairs(LocalPlayer:GetFriendsOnline(200)) do
		friendCache[f.VisitorId] = true
	end
end)

local aimHeld, currentTarget = false, nil
local IS_SLIDER_DRAGGING = false
local listeningKey = false

local Theme = {
	Bg = Color3.fromRGB(16, 14, 24),
	Sidebar = Color3.fromRGB(20, 17, 30),
	Card = Color3.fromRGB(27, 23, 39),
	CardHover = Color3.fromRGB(35, 30, 50),
	ControlBg = Color3.fromRGB(43, 37, 62),
	Stroke = Color3.fromRGB(68, 52, 108),
	StrokeGlow = Color3.fromRGB(139, 92, 246),
	Purple = Color3.fromRGB(147, 51, 234),
	PurpleBright = Color3.fromRGB(168, 85, 247),
	PurpleDark = Color3.fromRGB(88, 28, 135),
	SwitchOff = Color3.fromRGB(226, 232, 240),
	Text = Color3.fromRGB(248, 250, 252),
	TextDim = Color3.fromRGB(148, 142, 173),
	StatusGreen = Color3.fromRGB(192, 132, 252),
}

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
	s.Transparency = transparency or 0
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

local function createUI()
	local parentGui = getParentGui()
	local existing = parentGui:FindFirstChild(GuiName)
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = GuiName
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = parentGui

	-- Brilho externo roxo suave ao redor da janela
	local outerGlow = Instance.new("Frame")
	outerGlow.Name = "OuterGlow"
	outerGlow.Size = UDim2.new(0, 796, 0, 516)
	outerGlow.Position = UDim2.new(0.5, -398, 0.5, -258)
	outerGlow.BackgroundColor3 = Theme.Purple
	outerGlow.BackgroundTransparency = 0.84
	outerGlow.BorderSizePixel = 0
	outerGlow.Visible = Config.MenuOpen
	outerGlow.Parent = screenGui
	corner(outerGlow, 22)
	makeGradient(outerGlow, Theme.PurpleBright, Theme.PurpleDark, 35)

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 780, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -390, 0.5, -250)
	mainFrame.BackgroundColor3 = Theme.Bg
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Visible = Config.MenuOpen
	mainFrame.Parent = screenGui
	corner(mainFrame, 16)
	stroke(mainFrame, Theme.StrokeGlow, 1.4, 0.25)

	-- Arrastar janela pelo topo ou barra lateral
	local dragging, dragStart, startPos = false, nil, nil
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if IS_SLIDER_DRAGGING then
				return
			end
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local nextPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			mainFrame.Position = nextPos
			outerGlow.Position = UDim2.new(nextPos.X.Scale, nextPos.X.Offset - 8, nextPos.Y.Scale, nextPos.Y.Offset - 8)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Sidebar esquerda (logo Oz, navegação vertical e status)
	local sidebarWidth = 178
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
	sidebar.BackgroundColor3 = Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame
	corner(sidebar, 16)
	stroke(sidebar, Theme.Stroke, 1, 0.35)

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
	sidebarDivider.Position = UDim2.new(1, -1, 0, 0)
	sidebarDivider.BackgroundColor3 = Theme.Stroke
	sidebarDivider.BackgroundTransparency = 0.4
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.Parent = sidebar

	-- Logo "Oz" estilizado
	local logoBox = Instance.new("Frame")
	logoBox.Size = UDim2.new(1, -24, 0, 84)
	logoBox.Position = UDim2.new(0, 12, 0, 12)
	logoBox.BackgroundTransparency = 1
	logoBox.Parent = sidebar

	local ozLabel = Instance.new("TextLabel")
	ozLabel.Size = UDim2.new(1, 0, 1, 0)
	ozLabel.BackgroundTransparency = 1
	ozLabel.Text = "Oz"
	ozLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ozLabel.Font = Enum.Font.GothamBlackItalic
	ozLabel.TextSize = 54
	ozLabel.Parent = logoBox
	makeGradient(ozLabel, Color3.fromRGB(255, 255, 255), Theme.PurpleBright, 45)
	local ozStroke = Instance.new("UIStroke")
	ozStroke.Color = Theme.PurpleDark
	ozStroke.Thickness = 2
	ozStroke.Parent = ozLabel

	-- Navegação lateral
	local navHolder = Instance.new("Frame")
	navHolder.Size = UDim2.new(1, -20, 1, -172)
	navHolder.Position = UDim2.new(0, 10, 0, 104)
	navHolder.BackgroundTransparency = 1
	navHolder.Parent = sidebar

	local navLayout = Instance.new("UIListLayout")
	navLayout.Padding = UDim.new(0, 6)
	navLayout.SortOrder = Enum.SortOrder.LayoutOrder
	navLayout.Parent = navHolder

	-- Status inferior na sidebar
	local statusCard = Instance.new("Frame")
	statusCard.Size = UDim2.new(1, -20, 0, 54)
	statusCard.Position = UDim2.new(0, 10, 1, -66)
	statusCard.BackgroundColor3 = Theme.Card
	statusCard.BorderSizePixel = 0
	statusCard.Parent = sidebar
	corner(statusCard, 10)
	stroke(statusCard, Theme.Stroke, 1, 0.4)
	pad(statusCard, 8, 8, 12, 10)

	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.new(0, 8, 0, 8)
	statusDot.Position = UDim2.new(0, 0, 0, 5)
	statusDot.BackgroundColor3 = Theme.PurpleBright
	statusDot.BorderSizePixel = 0
	statusDot.Parent = statusCard
	corner(statusDot, 4)

	local statusTitle = Instance.new("TextLabel")
	statusTitle.Size = UDim2.new(1, -16, 0, 16)
	statusTitle.Position = UDim2.new(0, 16, 0, 0)
	statusTitle.BackgroundTransparency = 1
	statusTitle.Text = "Status"
	statusTitle.TextColor3 = Theme.Text
	statusTitle.Font = Enum.Font.GothamBold
	statusTitle.TextSize = 12
	statusTitle.TextXAlignment = Enum.TextXAlignment.Left
	statusTitle.Parent = statusCard

	local statusSub = Instance.new("TextLabel")
	statusSub.Size = UDim2.new(1, 0, 0, 16)
	statusSub.Position = UDim2.new(0, 0, 0, 20)
	statusSub.BackgroundTransparency = 1
	statusSub.Text = "Ready to use!"
	statusSub.TextColor3 = Theme.StatusGreen
	statusSub.Font = Enum.Font.GothamMedium
	statusSub.TextSize = 11
	statusSub.TextXAlignment = Enum.TextXAlignment.Left
	statusSub.Parent = statusCard

	-- Área principal à direita
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -sidebarWidth, 1, 0)
	contentArea.Position = UDim2.new(0, sidebarWidth, 0, 0)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = mainFrame

	-- Header superior
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 62)
	header.BackgroundColor3 = Theme.Sidebar
	header.BackgroundTransparency = 0.25
	header.BorderSizePixel = 0
	header.Parent = contentArea

	local headerBottomLine = Instance.new("Frame")
	headerBottomLine.Size = UDim2.new(1, 0, 0, 1)
	headerBottomLine.Position = UDim2.new(0, 0, 1, -1)
	headerBottomLine.BackgroundColor3 = Theme.Stroke
	headerBottomLine.BackgroundTransparency = 0.45
	headerBottomLine.BorderSizePixel = 0
	headerBottomLine.Parent = header

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -110, 0, 24)
	titleLbl.Position = UDim2.new(0, 20, 0, 11)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "Oz Menu"
	titleLbl.TextColor3 = Theme.Text
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 18
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = header

	local subtitleLbl = Instance.new("TextLabel")
	subtitleLbl.Size = UDim2.new(1, -110, 0, 16)
	subtitleLbl.Position = UDim2.new(0, 20, 0, 34)
	subtitleLbl.BackgroundTransparency = 1
	subtitleLbl.Text = "aim • esp • utility"
	subtitleLbl.TextColor3 = Theme.TextDim
	subtitleLbl.Font = Enum.Font.Gotham
	subtitleLbl.TextSize = 11
	subtitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLbl.Parent = header

	local function makeWinBtn(txt, xOffset, onClick)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 28, 0, 28)
		btn.Position = UDim2.new(1, xOffset, 0.5, -14)
		btn.BackgroundColor3 = Theme.Card
		btn.BorderSizePixel = 0
		btn.Text = txt
		btn.TextColor3 = Theme.TextDim
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = txt == "×" and 18 or 15
		btn.AutoButtonColor = false
		btn.Parent = header
		corner(btn, 7)
		stroke(btn, Theme.Stroke, 1, 0.4)

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.12), {
				BackgroundColor3 = Theme.Purple,
				TextColor3 = Theme.Text,
			}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.12), {
				BackgroundColor3 = Theme.Card,
				TextColor3 = Theme.TextDim,
			}):Play()
		end)
		btn.MouseButton1Click:Connect(onClick)
		return btn
	end

	local minimized = false
	makeWinBtn("−", -74, function()
		minimized = not minimized
		if minimized then
			mainFrame.Size = UDim2.new(0, 780, 0, 62)
			outerGlow.Size = UDim2.new(0, 796, 0, 78)
			sidebar.Visible = false
			contentArea.Size = UDim2.new(1, 0, 1, 0)
			contentArea.Position = UDim2.new(0, 0, 0, 0)
		else
			mainFrame.Size = UDim2.new(0, 780, 0, 500)
			outerGlow.Size = UDim2.new(0, 796, 0, 516)
			sidebar.Visible = true
			contentArea.Size = UDim2.new(1, -sidebarWidth, 1, 0)
			contentArea.Position = UDim2.new(0, sidebarWidth, 0, 0)
		end
	end)

	makeWinBtn("×", -40, function()
		Config.MenuOpen = false
		mainFrame.Visible = false
		outerGlow.Visible = false
	end)

	-- Páginas de navegação
	local pages, navButtons = {}, {}
	local function setTab(name)
		for n, p in pairs(pages) do
			p.Visible = (n == name)
		end
		for n, item in pairs(navButtons) do
			local active = (n == name)
			TweenService:Create(item.Button, TweenInfo.new(0.15), {
				BackgroundColor3 = active and Theme.Purple or Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = active and 0 or 1,
			}):Play()
			item.Icon.TextColor3 = active and Theme.Text or Theme.TextDim
			item.Label.TextColor3 = active and Theme.Text or Theme.TextDim
			item.Stroke.Transparency = active and 0.1 or 1
		end
	end

	local function createNavItem(name, iconChar, labelText, order)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 38)
		btn.BackgroundColor3 = Theme.Purple
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.LayoutOrder = order
		btn.Parent = navHolder
		corner(btn, 9)
		local btnStroke = stroke(btn, Theme.PurpleBright, 1, 1)

		local icon = Instance.new("TextLabel")
		icon.Size = UDim2.new(0, 22, 1, 0)
		icon.Position = UDim2.new(0, 12, 0, 0)
		icon.BackgroundTransparency = 1
		icon.Text = iconChar
		icon.TextColor3 = Theme.TextDim
		icon.Font = Enum.Font.GothamBold
		icon.TextSize = 14
		icon.Parent = btn

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -40, 1, 0)
		lbl.Position = UDim2.new(0, 38, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.TextDim
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = btn

		local page = Instance.new("ScrollingFrame")
		page.Name = name .. "Page"
		page.Size = UDim2.new(1, 0, 1, -62)
		page.Position = UDim2.new(0, 0, 0, 62)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = Theme.PurpleBright
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = contentArea
		pad(page, 14, 16, 16, 16)

		btn.MouseEnter:Connect(function()
			if not page.Visible then
				TweenService:Create(btn, TweenInfo.new(0.12), {
					BackgroundColor3 = Theme.Card,
					BackgroundTransparency = 0.2,
				}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if not page.Visible then
				TweenService:Create(btn, TweenInfo.new(0.12), {
					BackgroundTransparency = 1,
				}):Play()
			end
		end)
		btn.MouseButton1Click:Connect(function()
			setTab(name)
		end)

		navButtons[name] = { Button = btn, Icon = icon, Label = lbl, Stroke = btnStroke }
		pages[name] = page
		return page
	end

	local combatPage = createNavItem("combat", "◎", "Combat", 1)
	local visualsPage = createNavItem("visuals", "◉", "Visuals", 2)
	local miscPage = createNavItem("misc", "⚙", "Misc", 3)
	local settingsPage = createNavItem("settings", "≡", "Settings", 4)
	local creditsPage = createNavItem("credits", "★", "Credits", 5)

	-- Helpers de cartões e controles
	local function makeCard(parent, titleText, iconChar, layoutOrder)
		local card = Instance.new("Frame")
		card.BackgroundColor3 = Theme.Card
		card.BorderSizePixel = 0
		card.LayoutOrder = layoutOrder or 1
		card.Parent = parent
		corner(card, 12)
		stroke(card, Theme.Stroke, 1, 0.35)
		pad(card, 12, 12, 14, 14)

		local top = Instance.new("Frame")
		top.Size = UDim2.new(1, 0, 0, 22)
		top.BackgroundTransparency = 1
		top.Parent = card

		local ico = Instance.new("TextLabel")
		ico.Size = UDim2.new(0, 20, 1, 0)
		ico.BackgroundTransparency = 1
		ico.Text = iconChar
		ico.TextColor3 = Theme.PurpleBright
		ico.Font = Enum.Font.GothamBold
		ico.TextSize = 14
		ico.TextXAlignment = Enum.TextXAlignment.Left
		ico.Parent = top

		local hdr = Instance.new("TextLabel")
		hdr.Size = UDim2.new(1, -24, 1, 0)
		hdr.Position = UDim2.new(0, 22, 0, 0)
		hdr.BackgroundTransparency = 1
		hdr.Text = titleText
		hdr.TextColor3 = Theme.Text
		hdr.Font = Enum.Font.GothamBold
		hdr.TextSize = 14
		hdr.TextXAlignment = Enum.TextXAlignment.Left
		hdr.Parent = top

		local body = Instance.new("Frame")
		body.Size = UDim2.new(1, 0, 0, 0)
		body.Position = UDim2.new(0, 0, 0, 28)
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.BackgroundTransparency = 1
		body.Parent = card

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 6)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = body

		return card, body
	end

	local function addSwitch(parent, labelText, initialState, onToggle, order)
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 30)
		row.BackgroundTransparency = 1
		row.Text = ""
		row.AutoButtonColor = false
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -60, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local pill = Instance.new("Frame")
		pill.Size = UDim2.new(0, 44, 0, 22)
		pill.Position = UDim2.new(1, -44, 0.5, -11)
		pill.BackgroundColor3 = Theme.SwitchOff
		pill.BorderSizePixel = 0
		pill.Parent = row
		corner(pill, 11)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.Position = UDim2.new(0, 3, 0.5, -8)
		knob.BackgroundColor3 = Theme.Bg
		knob.BorderSizePixel = 0
		knob.Parent = pill
		corner(knob, 8)

		local state = initialState
		local function refresh(anim)
			local info = TweenInfo.new(anim and 0.16 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			if state then
				TweenService:Create(pill, info, { BackgroundColor3 = Theme.PurpleBright }):Play()
				TweenService:Create(knob, info, { Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255) }):Play()
			else
				TweenService:Create(pill, info, { BackgroundColor3 = Theme.SwitchOff }):Play()
				TweenService:Create(knob, info, { Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Theme.Bg }):Play()
			end
		end
		refresh(false)

		row.MouseButton1Click:Connect(function()
			state = not state
			refresh(true)
			onToggle(state)
		end)
	end

	local function addSlider(parent, labelText, minV, maxV, initialV, onChange, order, suffix)
		suffix = suffix or ""
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -80, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local fmt = function(v)
			if maxV >= 100 and suffix == "" then
				return tostring(math.floor(v + 0.5)) .. suffix
			end
			return tostring(string.format("%.2f", v):gsub("%.?0+$", "")) .. suffix
		end

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 76, 0, 18)
		valLbl.Position = UDim2.new(1, -76, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = fmt(initialV)
		valLbl.TextColor3 = Theme.Text
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextSize = 12
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = row

		local hitArea = Instance.new("Frame")
		hitArea.Size = UDim2.new(1, 0, 0, 18)
		hitArea.Position = UDim2.new(0, 0, 0, 20)
		hitArea.BackgroundTransparency = 1
		hitArea.Parent = row

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, 0, 0, 5)
		track.Position = UDim2.new(0, 0, 0.5, -2.5)
		track.BackgroundColor3 = Theme.ControlBg
		track.BorderSizePixel = 0
		track.Parent = hitArea
		corner(track, 3)

		local ratio = math.clamp((initialV - minV) / (maxV - minV), 0, 1)
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		fill.BackgroundColor3 = Theme.PurpleBright
		fill.BorderSizePixel = 0
		fill.Parent = track
		corner(fill, 3)
		makeGradient(fill, Theme.Purple, Theme.PurpleBright, 0)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new(ratio, 0, 0.5, 0)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.BorderSizePixel = 0
		knob.Parent = track
		corner(knob, 7)
		stroke(knob, Theme.PurpleBright, 2, 0)

		local draggingSlider = false
		local function setFromX(x)
			local abs, w = hitArea.AbsolutePosition.X, hitArea.AbsoluteSize.X
			if w <= 0 then
				return
			end
			local t = math.clamp((x - abs) / w, 0, 1)
			local val = minV + (maxV - minV) * t
			if maxV >= 100 and suffix == "" then
				val = math.floor(val + 0.5)
			end
			valLbl.Text = fmt(val)
			fill.Size = UDim2.new(t, 0, 1, 0)
			knob.Position = UDim2.new(t, 0, 0.5, 0)
			onChange(val)
		end

		hitArea.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSlider = true
				IS_SLIDER_DRAGGING = true
				setFromX(input.Position.X)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

	local function addColorDotRow(parent, labelText, initialColor, onPick, order)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.55, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local palette = {
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(168, 85, 247),
			Color3.fromRGB(239, 68, 68),
			Color3.fromRGB(34, 197, 94),
			Color3.fromRGB(59, 130, 246),
		}

		local holder = Instance.new("Frame")
		holder.Size = UDim2.new(0.45, 0, 1, 0)
		holder.Position = UDim2.new(0.55, 0, 0, 0)
		holder.BackgroundTransparency = 1
		holder.Parent = row

		local hLayout = Instance.new("UIListLayout")
		hLayout.FillDirection = Enum.FillDirection.Horizontal
		hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		hLayout.Padding = UDim.new(0, 6)
		hLayout.Parent = holder

		local dots = {}
		local function updateSelection(selectedCol)
			for _, item in ipairs(dots) do
				local isSame = (item.Color == selectedCol)
				item.Stroke.Color = isSame and Theme.PurpleBright or Theme.ControlBg
				item.Stroke.Thickness = isSame and 2.5 or 1
			end
		end

		for _, col in ipairs(palette) do
			local dot = Instance.new("TextButton")
			dot.Size = UDim2.new(0, 20, 0, 20)
			dot.BackgroundColor3 = col
			dot.Text = ""
			dot.AutoButtonColor = false
			dot.BorderSizePixel = 0
			dot.Parent = holder
			corner(dot, 10)
			local dStroke = stroke(dot, Theme.ControlBg, 1, 0)
			table.insert(dots, { Color = col, Stroke = dStroke })

			dot.MouseButton1Click:Connect(function()
				updateSelection(col)
				onPick(col)
			end)
		end

		updateSelection(initialColor)
	end

	local function addCycleRow(parent, labelText, options, currentText, onSelect, order)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 30)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.55, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local idx = 1
		for i, opt in ipairs(options) do
			if opt.Label == currentText then
				idx = i
				break
			end
		end

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 110, 0, 24)
		btn.Position = UDim2.new(1, -110, 0.5, -12)
		btn.BackgroundColor3 = Theme.ControlBg
		btn.BorderSizePixel = 0
		btn.Text = options[idx].Label .. "  ⌄"
		btn.TextColor3 = Theme.Text
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.Parent = row
		corner(btn, 6)
		stroke(btn, Theme.Stroke, 1, 0.4)

		btn.MouseButton1Click:Connect(function()
			idx = (idx % #options) + 1
			local chosen = options[idx]
			btn.Text = chosen.Label .. "  ⌄"
			onSelect(chosen.Value)
		end)
	end

	local function addKeyRow(parent, labelText, initialName, onKeySet, order)
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 30)
		row.BackgroundTransparency = 1
		row.LayoutOrder = order
		row.Parent = parent

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.55, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = labelText
		lbl.TextColor3 = Theme.Text
		lbl.Font = Enum.Font.Gotham
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 76, 0, 24)
		btn.Position = UDim2.new(1, -76, 0.5, -12)
		btn.BackgroundColor3 = Theme.ControlBg
		btn.BorderSizePixel = 0
		btn.Text = initialName
		btn.TextColor3 = Theme.Text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.Parent = row
		corner(btn, 6)
		stroke(btn, Theme.Stroke, 1, 0.4)

		btn.MouseButton1Click:Connect(function()
			if listeningKey then
				return
			end
			listeningKey = true
			local prev = btn.Text
			btn.Text = "..."
			local conn
			conn = UserInputService.InputBegan:Connect(function(input, gp)
				if gp then
					return
				end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					conn:Disconnect()
					listeningKey = false
					if input.KeyCode ~= Enum.KeyCode.Escape then
						btn.Text = input.KeyCode.Name
						onKeySet(input.KeyCode)
					else
						btn.Text = prev
					end
				end
			end)
		end)
	end

	-- Layout principal em 2 colunas (Combat: ESP + Misc à esquerda | Aimbot à direita)
	local leftCol = Instance.new("Frame")
	leftCol.Size = UDim2.new(0.48, -6, 0, 0)
	leftCol.AutomaticSize = Enum.AutomaticSize.Y
	leftCol.BackgroundTransparency = 1
	leftCol.Parent = combatPage

	local leftList = Instance.new("UIListLayout")
	leftList.Padding = UDim.new(0, 12)
	leftList.SortOrder = Enum.SortOrder.LayoutOrder
	leftList.Parent = leftCol

	local rightCol = Instance.new("Frame")
	rightCol.Size = UDim2.new(0.52, -6, 0, 0)
	rightCol.Position = UDim2.new(0.48, 6, 0, 0)
	rightCol.AutomaticSize = Enum.AutomaticSize.Y
	rightCol.BackgroundTransparency = 1
	rightCol.Parent = combatPage

	local rightList = Instance.new("UIListLayout")
	rightList.Padding = UDim.new(0, 12)
	rightList.SortOrder = Enum.SortOrder.LayoutOrder
	rightList.Parent = rightCol

	-- Cartão ESP (Esquerda superior)
	local _, espBody = makeCard(leftCol, "ESP", "🖥", 1)
	local eo = 0
	local function eOrd()
		eo = eo + 1
		return eo
	end

	addSwitch(espBody, "ESP Enabled", Config.EspEnabled, function(v)
		Config.EspEnabled = v
	end, eOrd())
	addSwitch(espBody, "Team Check", Config.TeamCheck, function(v)
		Config.TeamCheck = v
	end, eOrd())
	addColorDotRow(espBody, "Fill Color", Config.EspFillColor, function(col)
		Config.EspFillColor = col
	end, eOrd())
	addColorDotRow(espBody, "Outline Color", Config.EspOutlineColor, function(col)
		Config.EspOutlineColor = col
	end, eOrd())
	addSlider(espBody, "Fill Transparency", 0, 1, Config.EspFillTransparency, function(v)
		Config.EspFillTransparency = v
	end, eOrd(), "%")
	addCycleRow(espBody, "Depth Mode", {
		{ Label = "Always On Top", Value = "AlwaysOnTop" },
		{ Label = "Occluded", Value = "Occluded" },
	}, "Always On Top", function(val)
		Config.EspDepthMode = val
	end, eOrd())

	-- Cartão Misc (Esquerda inferior)
	local _, miscBody = makeCard(leftCol, "Misc", "⚙", 2)
	local mo = 0
	local function mOrd()
		mo = mo + 1
		return mo
	end

	addSlider(miscBody, "Recoil Reduction", 0, 1, Config.RecoilReduction, function(v)
		Config.RecoilReduction = v
	end, mOrd(), "%")
	addKeyRow(miscBody, "Menu Key", Config.MenuKey.Name, function(k)
		Config.MenuKey = k
	end, mOrd())
	addSwitch(miscBody, "Menu Open", Config.MenuOpen, function(v)
		Config.MenuOpen = v
		mainFrame.Visible = v
		outerGlow.Visible = v
	end, mOrd())

	-- Cartão Aimbot (Direita)
	local _, aimBody = makeCard(rightCol, "Aimbot", "◎", 1)
	local ao = 0
	local function aOrd()
		ao = ao + 1
		return ao
	end

	addSwitch(aimBody, "Aimbot Enabled", Config.AimbotEnabled, function(v)
		Config.AimbotEnabled = v
	end, aOrd())
	addCycleRow(aimBody, "Aim Key", {
		{ Label = "RMB", Value = Enum.UserInputType.MouseButton2 },
		{ Label = "LMB", Value = Enum.UserInputType.MouseButton1 },
	}, "RMB", function(val)
		Config.AimKey = val
	end, aOrd())
	addKeyRow(aimBody, "Aim Toggle Key", Config.AimToggleKey.Name, function(k)
		Config.AimToggleKey = k
	end, aOrd())
	addCycleRow(aimBody, "Aim Part", {
		{ Label = "Head", Value = "Head" },
		{ Label = "HumanoidRootPart", Value = "HumanoidRootPart" },
		{ Label = "UpperTorso", Value = "UpperTorso" },
	}, Config.AimPart, function(val)
		Config.AimPart = val
	end, aOrd())
	addSlider(aimBody, "Aim FOV", 20, 400, Config.AimFOV, function(v)
		Config.AimFOV = v
	end, aOrd())
	addSlider(aimBody, "Smoothness", 0.05, 1, Config.AimbotSmoothness, function(v)
		Config.AimbotSmoothness = v
	end, aOrd())
	addSlider(aimBody, "Max Distance", 50, 2000, Config.AimMaxDistance, function(v)
		Config.AimMaxDistance = v
	end, aOrd())
	addSwitch(aimBody, "Aim Visible Only", Config.AimVisibleOnly, function(v)
		Config.AimVisibleOnly = v
	end, aOrd())
	addSwitch(aimBody, "Aim Prediction", Config.AimPrediction, function(v)
		Config.AimPrediction = v
	end, aOrd())
	addSwitch(aimBody, "Aim Lock On Target", Config.AimLockOnTarget, function(v)
		Config.AimLockOnTarget = v
	end, aOrd())
	addSwitch(aimBody, "Aim Ignore Friends", Config.AimIgnoreFriends, function(v)
		Config.AimIgnoreFriends = v
	end, aOrd())
	addSwitch(aimBody, "Aim Humanize", Config.AimHumanize, function(v)
		Config.AimHumanize = v
	end, aOrd())

	-- Aba Visuals (atalho rápido para Prediction Amt)
	local _, visBody = makeCard(visualsPage, "Ballistics & Visuals", "◉", 1)
	addSlider(visBody, "Prediction Amt", 0, 0.5, Config.AimPredictionAmount, function(v)
		Config.AimPredictionAmount = v
	end, 1)

	-- Aba Misc dedicada
	local _, miscTabBody = makeCard(miscPage, "Quick Utility", "⚙", 1)
	addSlider(miscTabBody, "Recoil Reduction", 0, 1, Config.RecoilReduction, function(v)
		Config.RecoilReduction = v
	end, 1, "%")

	-- Aba Settings dedicada
	local _, setTabBody = makeCard(settingsPage, "Keybinds & Window", "≡", 1)
	addKeyRow(setTabBody, "Menu Key", Config.MenuKey.Name, function(k)
		Config.MenuKey = k
	end, 1)
	addKeyRow(setTabBody, "Aim Toggle Key", Config.AimToggleKey.Name, function(k)
		Config.AimToggleKey = k
	end, 2)

	-- Aba Credits
	local _, credBody = makeCard(creditsPage, "Credits", "★", 1)
	local credText = Instance.new("TextLabel")
	credText.Size = UDim2.new(1, 0, 0, 56)
	credText.BackgroundTransparency = 1
	credText.Text = "0z Menu\n[RMB] Aim • [H] Toggle Aim • [J] Toggle Menu"
	credText.TextColor3 = Theme.TextDim
	credText.Font = Enum.Font.Gotham
	credText.TextSize = 12
	credText.TextXAlignment = Enum.TextXAlignment.Left
	credText.Parent = credBody

	setTab("combat")
	return mainFrame, outerGlow
end

local MainMenuFrame, MainMenuGlow = createUI()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Config.MenuKey then
		Config.MenuOpen = not Config.MenuOpen
		if MainMenuFrame then
			MainMenuFrame.Visible = Config.MenuOpen
		end
		if MainMenuGlow then
			MainMenuGlow.Visible = Config.MenuOpen
		end
	end
	if not gameProcessed and input.KeyCode == Config.AimToggleKey then
		aimHeld = not aimHeld
	end
	if input.UserInputType == Config.AimKey then
		aimHeld = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Config.AimKey then
		aimHeld = false
	end
end)

UserInputService.WindowFocusReleased:Connect(function()
	aimHeld = false
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
	if not Config.AimVisibleOnly then
		return true
	end
	if not part or not LocalPlayer.Character then
		return true
	end
	rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
	local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
	return result == nil or result.Instance:IsDescendantOf(part.Parent)
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
		hl.Parent = character
		Highlights[player] = hl
	end
	hl.DepthMode = (Config.EspDepthMode == "Occluded") and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = Config.EspFillTransparency
	hl.OutlineTransparency = 0
	hl.FillColor = Config.EspFillColor
	hl.OutlineColor = Config.EspOutlineColor
	hl.Adornee = character
	hl.Parent = character
end

local function predictPosition(part)
	if not Config.AimPrediction then
		return part.Position
	end
	local root = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
	return part.Position + ((root and root.AssemblyLinearVelocity or Vector3.zero) * Config.AimPredictionAmount)
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
						local score = d
						if currentTarget == targetPart then
							score = score - 100
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
	if Config.RecoilReduction and Config.RecoilReduction > 0 then
		local targetCF = CFrame.new(currentCF.Position, currentCF.Position + currentCF.LookVector)
		currentCF = currentCF:Lerp(targetCF, 1 - Config.RecoilReduction)
		Camera.CFrame = currentCF
	end

	if not Config.AimbotEnabled or not aimHeld then
		currentTarget = nil
		return
	end

	if Config.AimLockOnTarget and currentTarget then
		local char = currentTarget.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not char or not hum or hum.Health <= 0 or not isVisible(currentTarget) then
			currentTarget = nil
		end
	end

	if not currentTarget or not Config.AimLockOnTarget then
		currentTarget = getBestTarget()
	end
	if not currentTarget then
		return
	end

	local camPos = Camera.CFrame.Position
	local desired = CFrame.lookAt(camPos, predictPosition(currentTarget))
	local alpha = math.clamp(Config.AimbotSmoothness, 0.01, 1)
	if Config.AimHumanize then
		alpha = alpha * (0.85 + math.random() * 0.3)
	end
	Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
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
