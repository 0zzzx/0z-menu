local Players=game:GetService("Players")local RunService=game:GetService("RunService")local UserInputService=game:GetService("UserInputService")local CoreGui=game:GetService("CoreGui")local TweenService=game:GetService("TweenService")local LocalPlayer=Players.LocalPlayer local Camera=workspace.CurrentCamera local Config={EspEnabled=true,TeamCheck=true,EspFillColor=Color3.fromRGB(255,255,255),EspOutlineColor=Color3.fromRGB(255,255,255),EspFillTransparency=0.65,EspDepthMode="AlwaysOnTop",AimbotEnabled=true,AimKey=Enum.UserInputType.MouseButton2,AimToggleKey=Enum.KeyCode.H,AimPart="Head",AimFOV=250,AimbotSmoothness=0.35,AimMaxDistance=1000,AimVisibleOnly=false,AimPrediction=false,AimPredictionAmount=0.15,AimLockOnTarget=true,AimIgnoreFriends=true,AimHumanize=true,RecoilReduction=0.0,MenuOpen=true,MenuKey=Enum.KeyCode.J}local Highlights,GuiName={},"0zMenuEspUI"local friendCache={}pcall(function()for _,f in ipairs(LocalPlayer:GetFriendsOnline(200))do friendCache[f.VisitorId]=true end end)local aimHeld,currentTarget=false,nil local IS_SLIDER_DRAGGING=false local Theme={Bg=Color3.fromRGB(10,9,17),BgLight=Color3.fromRGB(18,15,29),Card=Color3.fromRGB(24,20,38),CardHover=Color3.fromRGB(37,27,57),Stroke=Color3.fromRGB(77,48,112),Accent=Color3.fromRGB(174,55,255),Accent2=Color3.fromRGB(215,105,255),Text=Color3.fromRGB(250,247,255),TextDim=Color3.fromRGB(174,158,198),Danger=Color3.fromRGB(255,100,150)}local function getParentGui()if typeof(gethui)=="function"then local ok,hui=pcall(gethui)if ok and hui then return hui end end local okCore,core=pcall(function()return CoreGui end)if okCore and core then return core end return LocalPlayer:WaitForChild("PlayerGui")end local function makeGradient(parent,c1,c2,rotation)local g=Instance.new("UIGradient")g.Color=ColorSequence.new(c1,c2)g.Rotation=rotation or 0 g.Parent=parent return g end local function corner(parent,r)local c=Instance.new("UICorner")c.CornerRadius=UDim.new(0,r or 8)c.Parent=parent return c end local function stroke(parent,color,thickness)local s=Instance.new("UIStroke")s.Color=color or Theme.Stroke s.Thickness=thickness or 1 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=parent return s end local function pad(parent,t,b,l,r)local p=Instance.new("UIPadding")p.PaddingTop=UDim.new(0,t or 0)p.PaddingBottom=UDim.new(0,b or 0)p.PaddingLeft=UDim.new(0,l or 0)p.PaddingRight=UDim.new(0,r or 0)p.Parent=parent return p end local function createUI()local parentGui=getParentGui()local existing=parentGui:FindFirstChild(GuiName)if existing then existing:Destroy()end local screenGui=Instance.new("ScreenGui")screenGui.Name=GuiName screenGui.ResetOnSpawn=false screenGui.IgnoreGuiInset=true screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling screenGui.Parent=parentGui local mainFrame=Instance.new("Frame")mainFrame.Name="MainFrame"mainFrame.Size=UDim2.new(0,900,0,650)mainFrame.Position=UDim2.new(0.5,-450,0.5,-325)mainFrame.BackgroundColor3=Theme.Bg mainFrame.BorderSizePixel=0 mainFrame.Active=true mainFrame.Visible=Config.MenuOpen mainFrame.Parent=screenGui corner(mainFrame,18)stroke(mainFrame,Theme.Stroke,1.4)local shadow=Instance.new("Frame")shadow.Size=UDim2.new(1,8,1,8)shadow.Position=UDim2.new(0,-4,0,-4)shadow.BackgroundColor3=Color3.fromRGB(0,0,0)shadow.BackgroundTransparency=0.7 shadow.BorderSizePixel=0 shadow.ZIndex=-1 shadow.Parent=mainFrame corner(shadow,18)local dragging,dragStart,startPos=false,nil,nil mainFrame.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then if IS_SLIDER_DRAGGING then return end dragging=true dragStart=input.Position startPos=mainFrame.Position end end)UserInputService.InputChanged:Connect(function(input)if dragging and(input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch)then local delta=input.Position-dragStart mainFrame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)end end)UserInputService.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)local header=Instance.new("Frame")header.Size=UDim2.new(1,0,0,60)header.BackgroundColor3=Theme.BgLight header.BorderSizePixel=0 header.Parent=mainFrame corner(header,18)local headerFix=Instance.new("Frame")headerFix.Size=UDim2.new(1,0,0,16)headerFix.Position=UDim2.new(0,0,1,-16)headerFix.BackgroundColor3=Theme.BgLight headerFix.BorderSizePixel=0 headerFix.Parent=header makeGradient(header,Color3.fromRGB(25,25,25),Theme.BgLight,90)local headerLine=Instance.new("Frame")headerLine.Size=UDim2.new(1,0,0,2)headerLine.Position=UDim2.new(0,0,1,-1)headerLine.BorderSizePixel=0 headerLine.Parent=header makeGradient(headerLine,Theme.Accent,Theme.Accent2,0)local logo=Instance.new("Frame")logo.Size=UDim2.new(0,36,0,36)logo.Position=UDim2.new(0,14,0.5,-18)logo.BackgroundColor3=Theme.Accent logo.BorderSizePixel=0 logo.Parent=header corner(logo,9)makeGradient(logo,Theme.Accent,Theme.Accent2,45)local logoTxt=Instance.new("TextLabel")logoTxt.Size=UDim2.new(1,0,1,0)logoTxt.BackgroundTransparency=1 logoTxt.Text="0z"logoTxt.TextColor3=Color3.fromRGB(28,22,42)logoTxt.Font=Enum.Font.GothamBlack logoTxt.TextSize=14 logoTxt.Parent=logo local title=Instance.new("TextLabel")title.Size=UDim2.new(1,-140,0,20)title.Position=UDim2.new(0,56,0,10)title.BackgroundTransparency=1 title.Text="0z Menu"title.TextColor3=Theme.Text title.Font=Enum.Font.GothamBold title.TextSize=16 title.TextXAlignment=Enum.TextXAlignment.Left title.Parent=header local subtitle=Instance.new("TextLabel")subtitle.Size=UDim2.new(1,-140,0,16)subtitle.Position=UDim2.new(0,56,0,28)subtitle.BackgroundTransparency=1 subtitle.Text="dark interface  •  purple edition"subtitle.TextColor3=Theme.TextDim subtitle.Font=Enum.Font.Gotham subtitle.TextSize=10 subtitle.TextXAlignment=Enum.TextXAlignment.Left subtitle.Parent=header local closeBtn=Instance.new("TextButton")closeBtn.Size=UDim2.new(0,28,0,28)closeBtn.Position=UDim2.new(1,-38,0.5,-14)closeBtn.BackgroundColor3=Theme.Card closeBtn.BorderSizePixel=0 closeBtn.Text="×"closeBtn.TextColor3=Theme.TextDim closeBtn.Font=Enum.Font.GothamBold closeBtn.TextSize=20 closeBtn.AutoButtonColor=false closeBtn.Parent=header corner(closeBtn,8)stroke(closeBtn,Theme.Stroke,1)closeBtn.MouseEnter:Connect(function()TweenService:Create(closeBtn,TweenInfo.new(0.15),{BackgroundColor3=Theme.Text,TextColor3=Theme.Bg}):Play()end)closeBtn.MouseLeave:Connect(function()TweenService:Create(closeBtn,TweenInfo.new(0.15),{BackgroundColor3=Theme.Card,TextColor3=Theme.TextDim}):Play()end)closeBtn.MouseButton1Click:Connect(function()Config.MenuOpen=false mainFrame.Visible=false end)local sidePanel=Instance.new("Frame")
sidePanel.Size=UDim2.new(0,160,1,-82)
sidePanel.Position=UDim2.new(0,14,0,72)
sidePanel.BackgroundColor3=Theme.BgLight
sidePanel.BorderSizePixel=0
sidePanel.Parent=mainFrame
corner(sidePanel,16)
stroke(sidePanel,Theme.Stroke,1)

local sideLogo=Instance.new("Frame")
sideLogo.Size=UDim2.new(0,74,0,74)
sideLogo.Position=UDim2.new(0.5,-37,0,24)
sideLogo.BackgroundColor3=Theme.Accent
sideLogo.BorderSizePixel=0
sideLogo.Parent=sidePanel
corner(sideLogo,18)
makeGradient(sideLogo,Theme.Accent,Theme.Accent2,45)

local sideLogoText=Instance.new("TextLabel")
sideLogoText.Size=UDim2.new(1,0,1,0)
sideLogoText.BackgroundTransparency=1
sideLogoText.Text="0z"
sideLogoText.TextColor3=Theme.Bg
sideLogoText.Font=Enum.Font.GothamBlack
sideLogoText.TextSize=27
sideLogoText.Parent=sideLogo

local sideTitle=Instance.new("TextLabel")
sideTitle.Size=UDim2.new(1,-16,0,24)
sideTitle.Position=UDim2.new(0,8,0,112)
sideTitle.BackgroundTransparency=1
sideTitle.Text="0z  •  PVP"
sideTitle.TextColor3=Theme.Text
sideTitle.Font=Enum.Font.GothamBold
sideTitle.TextSize=14
sideTitle.Parent=sidePanel

local sideSubtitle=Instance.new("TextLabel")
sideSubtitle.Size=UDim2.new(1,-16,0,30)
sideSubtitle.Position=UDim2.new(0,8,0,138)
sideSubtitle.BackgroundTransparency=1
sideSubtitle.Text="YOUR CURRENT\nCONFIGURATION"
sideSubtitle.TextColor3=Theme.TextDim
sideSubtitle.Font=Enum.Font.Gotham
sideSubtitle.TextSize=9
sideSubtitle.TextWrapped=true
sideSubtitle.Parent=sidePanel

local statusCard=Instance.new("Frame")
statusCard.Size=UDim2.new(1,-18,0,66)
statusCard.Position=UDim2.new(0,9,1,-78)
statusCard.BackgroundColor3=Theme.Card
statusCard.BorderSizePixel=0
statusCard.Parent=sidePanel
corner(statusCard,11)
stroke(statusCard,Theme.Stroke,1)

local statusDot=Instance.new("Frame")
statusDot.Size=UDim2.new(0,10,0,10)
statusDot.Position=UDim2.new(0,12,0,14)
statusDot.BackgroundColor3=Theme.Accent
statusDot.BorderSizePixel=0
statusDot.Parent=statusCard
corner(statusDot,5)

local statusTitle=Instance.new("TextLabel")
statusTitle.Size=UDim2.new(1,-34,0,18)
statusTitle.Position=UDim2.new(0,28,0,8)
statusTitle.BackgroundTransparency=1
statusTitle.Text="STATUS"
statusTitle.TextColor3=Theme.TextDim
statusTitle.Font=Enum.Font.GothamBold
statusTitle.TextSize=9
statusTitle.TextXAlignment=Enum.TextXAlignment.Left
statusTitle.Parent=statusCard

local statusText=Instance.new("TextLabel")
statusText.Size=UDim2.new(1,-18,0,22)
statusText.Position=UDim2.new(0,10,0,31)
statusText.BackgroundTransparency=1
statusText.Text="Ready to use"
statusText.TextColor3=Theme.Accent2
statusText.Font=Enum.Font.GothamBold
statusText.TextSize=12
statusText.TextXAlignment=Enum.TextXAlignment.Left
statusText.Parent=statusCard

local navButtons={}
local navItems={
    {id="combat",label="✥  Combat"},
    {id="visuals",label="◉  Visuals"},
    {id="misc",label="⚙  Misc"},
    {id="settings",label="☷  Settings"}
}
local navFrame=Instance.new("Frame")
navFrame.Size=UDim2.new(1,-18,0,184)
