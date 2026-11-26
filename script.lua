local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    EspEnabled = true, TeamCheck = true, EspFillColor = Color3.fromRGB(139, 92, 246), EspOutlineColor = Color3.fromRGB(255, 255, 255), EspFillTransparency = 0.65, EspDepthMode = "AlwaysOnTop",
    AimbotEnabled = true, AimKey = Enum.UserInputType.MouseButton2, AimToggleMode = false, AimToggleKey = Enum.KeyCode.H, AimPart = "Head", AimFOV = 250, AimbotSmoothness = 0.35, AimMaxDistance = 1000, AimVisibleOnly = false, AimPrediction = false, AimPredictionAmount = 0.15, AimLockOnTarget = true, AimIgnoreFriends = true, AimHumanize = true,
    MenuOpen = true, MenuKey = Enum.KeyCode.J,
}

local Highlights, GuiName = {}, "0zMenuEspUI"
local friendCache = {}
pcall(function() for _, f in ipairs(LocalPlayer:GetFriendsOnline(200)) do friendCache[f.VisitorId] = true end end)
local aimHeld, currentTarget = false, nil
local IS_SLIDER_DRAGGING = false

local Theme = {
    Bg = Color3.fromRGB(13, 14, 19), BgLight = Color3.fromRGB(20, 22, 30), Card = Color3.fromRGB(26, 28, 38), CardHover = Color3.fromRGB(32, 35, 47), Stroke = Color3.fromRGB(42, 46, 62),
    Accent = Color3.fromRGB(139, 92, 246), Accent2 = Color3.fromRGB(59, 130, 246), Text = Color3.fromRGB(240, 242, 248), TextDim = Color3.fromRGB(148, 155, 175), Danger = Color3.fromRGB(239, 68, 68),
}

local function getParentGui()
    if typeof(gethui) == "function" then local ok, hui = pcall(gethui) if ok and hui then return hui end end
    local okCore, core = pcall(function() return CoreGui end)
    if okCore and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function makeGradient(parent, c1, c2, rotation) local g = Instance.new("UIGradient") g.Color = ColorSequence.new(c1, c2) g.Rotation = rotation or 0 g.Parent = parent return g end
local function corner(parent, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 8) c.Parent = parent return c end
local function stroke(parent, color, thickness) local s = Instance.new("UIStroke") s.Color = color or Theme.Stroke s.Thickness = thickness or 1 s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Parent = parent return s end
local function pad(parent, t, b, l, r) local p = Instance.new("UIPadding") p.PaddingTop = UDim.new(0, t or 0) p.PaddingBottom = UDim.new(0, b or 0) p.PaddingLeft = UDim.new(0, l or 0) p.PaddingRight = UDim.new(0, r or 0) p.Parent = parent return p end

local function createUI()
    local parentGui = getParentGui()
    local existing = parentGui:FindFirstChild(GuiName)
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = GuiName screenGui.ResetOnSpawn = false screenGui.IgnoreGuiInset = true screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling screenGui.Parent = parentGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame" mainFrame.Size = UDim2.new(0, 340, 0, 460) mainFrame.Position = UDim2.new(0, 24, 0.5, -230)
    mainFrame.BackgroundColor3 = Theme.Bg mainFrame.BorderSizePixel = 0 mainFrame.Active = true mainFrame.Visible = Config.MenuOpen mainFrame.Parent = screenGui
    corner(mainFrame, 14) stroke(mainFrame, Theme.Stroke, 1.2)

    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 8, 1, 8) shadow.Position = UDim2.new(0, -4, 0, -4) shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0) shadow.BackgroundTransparency = 0.7 shadow.BorderSizePixel = 0 shadow.ZIndex = -1 shadow.Parent = mainFrame
    corner(shadow, 18)

    local dragging, dragStart, startPos = false, nil, nil
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if IS_SLIDER_DRAGGING then return end
            dragging = true dragStart = input.Position startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 56) header.BackgroundColor3 = Theme.BgLight header.BorderSizePixel = 0 header.Parent = mainFrame
    corner(header, 14)
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 16) headerFix.Position = UDim2.new(0, 0, 1, -16) headerFix.BackgroundColor3 = Theme.BgLight headerFix.BorderSizePixel = 0 headerFix.Parent = header
    makeGradient(header, Color3.fromRGB(22, 24, 33), Theme.BgLight, 90)
    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 2) headerLine.Position = UDim2.new(0, 0, 1, -1) headerLine.BorderSizePixel = 0 headerLine.Parent = header
    makeGradient(headerLine, Theme.Accent, Theme.Accent2, 0)

    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(0, 32, 0, 32) logo.Position = UDim2.new(0, 14, 0.5, -16) logo.BackgroundColor3 = Theme.Accent logo.BorderSizePixel = 0 logo.Parent = header
    corner(logo, 9) makeGradient(logo, Theme.Accent, Theme.Accent2, 45)
    local logoTxt = Instance.new("TextLabel")
    logoTxt.Size = UDim2.new(1, 0, 1, 0) logoTxt.BackgroundTransparency = 1 logoTxt.Text = "0z" logoTxt.TextColor3 = Theme.Text logoTxt.Font = Enum.Font.GothamBlack logoTxt.TextSize = 14 logoTxt.Parent = logo

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 0, 20) title.Position = UDim2.new(0, 56, 0, 10) title.BackgroundTransparency = 1 title.Text = "0z Menu" title.TextColor3 = Theme.Text title.Font = Enum.Font.GothamBold title.TextSize = 16 title.TextXAlignment = Enum.TextXAlignment.Left title.Parent = header
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -140, 0, 16) subtitle.Position = UDim2.new(0, 56, 0, 28) subtitle.BackgroundTransparency = 1 subtitle.Text = "aim • esp • utility" subtitle.TextColor3 = Theme.TextDim subtitle.Font = Enum.Font.Gotham subtitle.TextSize = 10 subtitle.TextXAlignment = Enum.TextXAlignment.Left subtitle.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28) closeBtn.Position = UDim2.new(1, -38, 0.5, -14) closeBtn.BackgroundColor3 = Theme.Card closeBtn.BorderSizePixel = 0 closeBtn.Text = "×" closeBtn.TextColor3 = Theme.TextDim closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 20 closeBtn.AutoButtonColor = false closeBtn.Parent = header
    corner(closeBtn, 8) stroke(closeBtn, Theme.Stroke, 1)
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Danger, TextColor3 = Theme.Text }):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDim }):Play() end)
    closeBtn.MouseButton1Click:Connect(function() Config.MenuOpen = false mainFrame.Visible = false end)

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -28, 0, 36) tabBar.Position = UDim2.new(0, 14, 0, 64) tabBar.BackgroundColor3 = Theme.BgLight tabBar.BorderSizePixel = 0 tabBar.Parent = mainFrame
    corner(tabBar, 10) stroke(tabBar, Theme.Stroke, 1) pad(tabBar, 4, 4, 4, 4)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal tabLayout.Padding = UDim.new(0, 2) tabLayout.SortOrder = Enum.SortOrder.LayoutOrder tabLayout.Parent = tabBar

    local pages, tabButtons = {}, {}
    local function setTab(name)
        for n, page in pairs(pages) do page.Visible = (n == name) end
        for n, btn in pairs(tabButtons) do
            local isActive = (n == name)
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = isActive and Theme.Accent or Theme.Card, TextColor3 = isActive and Theme.Text or Theme.TextDim }):Play()
        end
    end

    local function makeTab(name, label, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1 / 3, -2, 1, 0) btn.BackgroundColor3 = Theme.Card btn.BorderSizePixel = 0 btn.Text = label btn.TextColor3 = Theme.TextDim btn.Font = Enum.Font.GothamBold btn.TextSize = 12 btn.AutoButtonColor = false btn.LayoutOrder = order btn.Parent = tabBar
        corner(btn, 7) btn.MouseButton1Click:Connect(function() setTab(name) end)
        tabButtons[name] = btn
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, -114) page.Position = UDim2.new(0, 0, 0, 110) page.BackgroundTransparency = 1 page.BorderSizePixel = 0 page.ScrollBarThickness = 3 page.ScrollBarImageColor3 = Theme.Accent page.CanvasSize = UDim2.new(0, 0, 0, 0) page.AutomaticCanvasSize = Enum.AutomaticSize.Y page.Visible = false page.Parent = mainFrame
        pad(page, 10, 16, 14, 14)
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8) list.SortOrder = Enum.SortOrder.LayoutOrder list.Parent = page
        pages[name] = page return page
    end

    local aimPage, espPage, setPage = makeTab("aimbot", "Aimbot", 1), makeTab("esp", "ESP", 2), makeTab("settings", "Config", 3)

    local function section(parent, text, order)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 16) lbl.BackgroundTransparency = 1 lbl.Text = string.upper(text) lbl.TextColor3 = Theme.Accent lbl.Font = Enum.Font.GothamBold lbl.TextSize = 10 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.LayoutOrder = order lbl.Parent = parent
    end

    local function toggleRow(parent, labelText, initialState, onToggle, order)
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 42) row.BackgroundColor3 = Theme.Card row.BorderSizePixel = 0 row.Text = "" row.AutoButtonColor = false row.LayoutOrder = order row.Parent = parent
        corner(row, 10) stroke(row, Theme.Stroke, 1)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 1, 0) lbl.Position = UDim2.new(0, 14, 0, 0) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.TextColor3 = Theme.Text lbl.Font = Enum.Font.GothamMedium lbl.TextSize = 13 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = row
        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(0, 40, 0, 22) switchBg.Position = UDim2.new(1, -54, 0.5, -11) switchBg.BackgroundColor3 = Color3.fromRGB(52, 56, 72) switchBg.BorderSizePixel = 0 switchBg.Parent = row
        corner(switchBg, 11)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16) knob.Position = UDim2.new(0, 3, 0.5, -8) knob.BackgroundColor3 = Theme.Text knob.BorderSizePixel = 0 knob.Parent = switchBg
        corner(knob, 8)
        local state = initialState
        local function refresh(anim)
            local info = TweenInfo.new(anim and 0.2 or 0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if state then TweenService:Create(switchBg, info, { BackgroundColor3 = Theme.Accent }):Play() TweenService:Create(knob, info, { Position = UDim2.new(1, -19, 0.5, -8) }):Play()
            else TweenService:Create(switchBg, info, { BackgroundColor3 = Color3.fromRGB(52, 56, 72) }):Play() TweenService:Create(knob, info, { Position = UDim2.new(0, 3, 0.5, -8) }):Play() end
        end
        refresh(false)
        row.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Theme.CardHover }):Play() end)
        row.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Card }):Play() end)
        row.MouseButton1Click:Connect(function() state = not state refresh(true) onToggle(state) end)
    end

    local function sliderRow(parent, labelText, minV, maxV, initialV, onChange, order, suffix)
        suffix = suffix or ""
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 56) row.BackgroundColor3 = Theme.Card row.BorderSizePixel = 0 row.LayoutOrder = order row.Parent = parent
        corner(row, 10) stroke(row, Theme.Stroke, 1)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -100, 0, 20) lbl.Position = UDim2.new(0, 14, 0, 6) lbl.BackgroundTransparency = 1 lbl.Text = labelText lbl.TextColor3 = Theme.Text lbl.Font = Enum.Font.GothamMedium lbl.TextSize = 13 lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Parent = row
        local valueLbl = Instance.new("TextLabel")
        local displayVal = (maxV >= 100 and suffix == "") and tostring(math.floor(initialV)) or tostring(initialV)
        valueLbl.Size = UDim2.new(0, 80, 0, 20) valueLbl.Position = UDim2.new(1, -94, 0, 6) valueLbl.BackgroundTransparency = 1 valueLbl.Text = displayVal .. suffix valueLbl.TextColor3 = Theme.Accent valueLbl.Font = Enum.Font.GothamBold valueLbl.TextSize = 13 valueLbl.TextXAlignment = Enum.TextXAlignment.Right valueLbl.Parent = row
        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, -28, 0, 16) barBg.Position = UDim2.new(0, 14, 1, -22) barBg.BackgroundTransparency = 1 barBg.BorderSizePixel = 0 barBg.Parent = row
        local barVisual = Instance.new("Frame")
        barVisual.Size = UDim2.new(1, 0, 0, 6) barVisual.Position = UDim2.new(0, 0, 0.5, -3) barVisual.BackgroundColor3 = Color3.fromRGB(45, 48, 62) barVisual.BorderSizePixel = 0 barVisual.Parent = barBg
        corner(barVisual, 3)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((initialV - minV) / (maxV - minV), 0, 1, 0) fill.BackgroundColor3 = Theme.Accent fill.BorderSizePixel = 0 fill.Parent = barVisual
        corner(fill, 3) makeGradient(fill, Theme.Accent, Theme.Accent2, 0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14) knob.AnchorPoint = Vector2.new(0.5, 0.5) knob.Position = UDim2.new((initialV - minV) / (maxV - minV), 0, 0.5, 0) knob.BackgroundColor3 = Theme.Text knob.BorderSizePixel = 0 knob.Parent = barVisual
        corner(knob, 7) stroke(knob, Theme.Accent, 2)
        local dragging = false
        local function setFromX(x)
            local abs, w = barBg.AbsolutePosition.X, barBg.AbsoluteSize.X
            local t = math.clamp((x - abs) / w, 0, 1)
            local val = minV + (maxV - minV) * t
            if maxV >= 100 and suffix == "" then val = math.floor(val + 0.5) valueLbl.Text = tostring(val) .. suffix
            else valueLbl.Text = string.format("%.2f", val):gsub("%.?0+$", "") .. suffix end
            fill.Size = UDim2.new(t, 0, 1, 0) knob.Position = UDim2.new(t, 0, 0.5, 0) onChange(val)
        end
        barBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true IS_SLIDER_DRAGGING = true setFromX(input.Position.X) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false IS_SLIDER_DRAGGING = false end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFromX(input.Position.X) end end)
    end

    local o = 0
    local function ord() o = o + 1 return o end

    section(aimPage, "Geral", ord()) toggleRow(aimPage, "Aimbot", Config.AimbotEnabled, function(v) Config.AimbotEnabled = v end, ord()) toggleRow(aimPage, "Toggle Mode", Config.AimToggleMode, function(v) Config.AimToggleMode = v end, ord()) toggleRow(aimPage, "Lock On Target", Config.AimLockOnTarget, function(v) Config.AimLockOnTarget = v end, ord())
    section(aimPage, "Filtros", ord()) toggleRow(aimPage, "Only Visible", Config.AimVisibleOnly, function(v) Config.AimVisibleOnly = v end, ord()) toggleRow(aimPage, "Ignore Friends", Config.AimIgnoreFriends, function(v) Config.AimIgnoreFriends = v end, ord()) toggleRow(aimPage, "Prediction", Config.AimPrediction, function(v) Config.AimPrediction = v end, ord()) toggleRow(aimPage, "Humanize", Config.AimHumanize, function(v) Config.AimHumanize = v end, ord())
    section(aimPage, "Ajustes", ord()) sliderRow(aimPage, "Smoothness", 0.05, 1, Config.AimbotSmoothness, function(v) Config.AimbotSmoothness = v end, ord()) sliderRow(aimPage, "FOV", 20, 400, Config.AimFOV, function(v) Config.AimFOV = v end, ord(), "px") sliderRow(aimPage, "Max Distance", 50, 2000, Config.AimMaxDistance, function(v) Config.AimMaxDistance = v end, ord()) sliderRow(aimPage, "Prediction Amt", 0, 0.5, Config.AimPredictionAmount, function(v) Config.AimPredictionAmount = v end, ord())

    o = 0
    section(espPage, "Highlight", ord()) toggleRow(espPage, "ESP Highlight", Config.EspEnabled, function(v) Config.EspEnabled = v end, ord()) toggleRow(espPage, "Team Check", Config.TeamCheck, function(v) Config.TeamCheck = v end, ord())

    o = 0
    section(setPage, "Menu", ord())
    local keyRow = Instance.new("Frame")
    keyRow.Size = UDim2.new(1, 0, 0, 42) keyRow.BackgroundColor3 = Theme.Card keyRow.BorderSizePixel = 0 keyRow.LayoutOrder = ord() keyRow.Parent = setPage
    corner(keyRow, 10) stroke(keyRow, Theme.Stroke, 1)
    local keyLbl = Instance.new("TextLabel")
    keyLbl.Size = UDim2.new(1, -100, 1, 0) keyLbl.Position = UDim2.new(0, 14, 0, 0) keyLbl.BackgroundTransparency = 1 keyLbl.Text = "Menu Key" keyLbl.TextColor3 = Theme.Text keyLbl.Font = Enum.Font.GothamMedium keyLbl.TextSize = 13 keyLbl.TextXAlignment = Enum.TextXAlignment.Left keyLbl.Parent = keyRow
    local keyVal = Instance.new("TextButton")
    keyVal.Size = UDim2.new(0, 70, 0, 24) keyVal.Position = UDim2.new(1, -84, 0.5, -12) keyVal.BackgroundColor3 = Theme.BgLight keyVal.Text = Config.MenuKey.Name keyVal.TextColor3 = Theme.Accent keyVal.Font = Enum.Font.GothamBold keyVal.TextSize = 12 keyVal.AutoButtonColor = false keyVal.Parent = keyRow
    corner(keyVal, 6)

    local toggleRowKey = Instance.new("Frame")
    toggleRowKey.Size = UDim2.new(1, 0, 0, 42) toggleRowKey.BackgroundColor3 = Theme.Card toggleRowKey.BorderSizePixel = 0 toggleRowKey.LayoutOrder = ord() toggleRowKey.Parent = setPage
    corner(toggleRowKey, 10) stroke(toggleRowKey, Theme.Stroke, 1)
    local toggleLbl = Instance.new("TextLabel")
    toggleLbl.Size = UDim2.new(1, -100, 1, 0) toggleLbl.Position = UDim2.new(0, 14, 0, 0) toggleLbl.BackgroundTransparency = 1 toggleLbl.Text = "Aim Toggle Key" toggleLbl.TextColor3 = Theme.Text toggleLbl.Font = Enum.Font.GothamMedium toggleLbl.TextSize = 13 toggleLbl.TextXAlignment = Enum.TextXAlignment.Left toggleLbl.Parent = toggleRowKey
    local toggleVal = Instance.new("TextButton")
    toggleVal.Size = UDim2.new(0, 70, 0, 24) toggleVal.Position = UDim2.new(1, -84, 0.5, -12) toggleVal.BackgroundColor3 = Theme.BgLight toggleVal.Text = Config.AimToggleKey.Name toggleVal.TextColor3 = Theme.Accent toggleVal.Font = Enum.Font.GothamBold toggleVal.TextSize = 12 toggleVal.AutoButtonColor = false toggleVal.Parent = toggleRowKey
    corner(toggleVal, 6)

    local listeningKey = false
    local function startListening(label, currentKey, callback)
        if listeningKey then return end
        listeningKey = true label.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                conn:Disconnect() listeningKey = false
                if input.KeyCode ~= Enum.KeyCode.Escape then callback(input.KeyCode) label.Text = input.KeyCode.Name
                else label.Text = currentKey.Name end
            end
        end)
    end
    keyVal.MouseButton1Click:Connect(function() startListening(keyVal, Config.MenuKey, function(newKey) Config.MenuKey = newKey end) end)
    toggleVal.MouseButton1Click:Connect(function() startListening(toggleVal, Config.AimToggleKey, function(newKey) Config.AimToggleKey = newKey end) end)

    section(setPage, "Info", ord())
    local infoLbl = Instance.new("TextLabel")
    infoLbl.Size = UDim2.new(1, 0, 0, 60) infoLbl.BackgroundColor3 = Theme.Card infoLbl.Text = "0z Menu v2\n[FOV] circunda alvo\n[RMB] mira • [J] menu" infoLbl.TextColor3 = Theme.TextDim infoLbl.Font = Enum.Font.Gotham infoLbl.TextSize = 11 infoLbl.LayoutOrder = ord() infoLbl.Parent = setPage
    corner(infoLbl, 10) stroke(infoLbl, Theme.Stroke, 1)

    setTab("aimbot")
    return mainFrame
end

local MainMenuFrame = createUI()

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "0zAimFOV" fovGui.ResetOnSpawn = false fovGui.IgnoreGuiInset = true fovGui.Parent = getParentGui()

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, 0, 0, 0) fovCircle.AnchorPoint = Vector2.new(0.5, 0.5) fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0) fovCircle.BackgroundTransparency = 1 fovCircle.BorderSizePixel = 0 fovCircle.Parent = fovGui
local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Theme.Accent fovStroke.Thickness = 1.5 fovStroke.Transparency = 0.35 fovStroke.Parent = fovCircle
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0) fovCorner.Parent = fovCircle

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Config.MenuKey then Config.MenuOpen = not Config.MenuOpen if MainMenuFrame then MainMenuFrame.Visible = Config.MenuOpen end end
    if not gameProcessed and input.KeyCode == Config.AimToggleKey then aimHeld = not aimHeld end
    if input.UserInputType == Config.AimKey then if Config.AimToggleMode then aimHeld = not aimHeld else aimHeld = true end end
end)

UserInputService.InputEnded:Connect(function(input) if not Config.AimToggleMode and input.UserInputType == Config.AimKey then aimHeld = false end end)
UserInputService.WindowFocusReleased:Connect(function() if not Config.AimToggleMode then aimHeld = false end end)

local function isFriend(player) if not Config.AimIgnoreFriends then return false end return friendCache[player.UserId] == true end
local function isValidTarget(player, forAim)
    if player == LocalPlayer then return false end
    if Config.TeamCheck and LocalPlayer.Team and player.Team and player.Team == LocalPlayer.Team then return false end
    if forAim and isFriend(player) then return false end
    local character = player.Character if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local aimPart = character:FindFirstChild(Config.AimPart) or character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 or not aimPart then return false end
    return true, aimPart
end

local rayParams = RaycastParams.new() rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function isVisible(part)
    if not Config.AimVisibleOnly then return true end
    if not part or not LocalPlayer.Character then return true end
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }
    local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, rayParams)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function removeHighlight(player) if Highlights[player] then Highlights[player]:Destroy() Highlights[player] = nil end end
local function syncHighlight(player, character)
    if not character then removeHighlight(player) return end
    local hl = Highlights[player]
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight") hl.Name = "0zMenuHighlight" hl.DepthMode = (Config.EspDepthMode == "Occluded") and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop hl.FillTransparency = Config.EspFillTransparency hl.OutlineTransparency = 0 hl.FillColor = Config.EspFillColor hl.OutlineColor = Config.EspOutlineColor Highlights[player] = hl
    end
    hl.DepthMode = (Config.EspDepthMode == "Occluded") and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = character hl.Parent = character
end

local function predictPosition(part)
    if not Config.AimPrediction then return part.Position end
    local root = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
    return part.Position + ((root and root.AssemblyLinearVelocity or Vector3.zero) * Config.AimPredictionAmount)
end

local function getBestTarget()
    Camera = workspace.CurrentCamera if not Camera then return nil end
    local viewport, center = Camera.ViewportSize, Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
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
                        if currentTarget == targetPart then score = score - 100 end
                        if score < bestScore then bestScore = score best = targetPart end
                    end
                end
            end
        end
    end
    return best
end

local AIM_PRIORITY = Enum.RenderPriority.Camera.Value + 1
RunService:BindToRenderStep("0zAimbot", AIM_PRIORITY, function()
    Camera = workspace.CurrentCamera if not Camera then return end
    fovCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
    fovCircle.Visible = Config.AimbotEnabled and aimHeld
    if not Config.AimbotEnabled or not aimHeld then currentTarget = nil return end

    if Config.AimLockOnTarget and currentTarget
 then
        local char = currentTarget.Parent local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 or not isVisible(currentTarget) then currentTarget = nil end
    end

    if not currentTarget or not Config.AimLockOnTarget then currentTarget = getBestTarget() end
    if not currentTarget then return end

    local camPos = Camera.CFrame.Position local desired = CFrame.lookAt(camPos, predictPosition(currentTarget))
    local alpha = math.clamp(Config.AimbotSmoothness, 0.01, 1)
    if Config.AimHumanize then alpha = alpha * (0.85 + math.random() * 0.3) end
    Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
end)

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera if not Camera then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if Config.EspEnabled and isValidTarget(player, false) and player.Character then syncHighlight(player, player.Character)
            else removeHighlight(player) end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player) removeHighlight(player) if currentTarget and currentTarget.Parent == player.Character then currentTarget = nil end end)
