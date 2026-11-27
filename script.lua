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
navFrame.Position=UDim2.new(0,9,0,238)
navFrame.BackgroundTransparency=1
navFrame.Parent=sidePanel
local navList=Instance.new("UIListLayout")
navList.Padding=UDim.new(0,9)
navList.SortOrder=Enum.SortOrder.LayoutOrder
navList.Parent=navFrame

local pages={}
local function setTab(name)
    for id,page in pairs(pages) do
        page.Visible=(id==name)
    end
    for id,button in pairs(navButtons) do
        local active=(id==name)
        TweenService:Create(button,TweenInfo.new(0.16),{
            BackgroundColor3=active and Theme.Accent or Theme.Card,
            TextColor3=active and Theme.Text or Theme.TextDim
        }):Play()
    end
end

local function makeTab(name,label,order)
    local button=Instance.new("TextButton")
    button.Size=UDim2.new(1,0,0,42)
    button.BackgroundColor3=Theme.Card
    button.BorderSizePixel=0
    button.Text=label
    button.TextColor3=Theme.TextDim
    button.Font=Enum.Font.GothamBold
    button.TextSize=12
    button.AutoButtonColor=false
    button.LayoutOrder=order
    button.Parent=navFrame
    corner(button,10)
    stroke(button,Theme.Stroke,1)
    button.MouseButton1Click:Connect(function() setTab(name) end)
    navButtons[name]=button

    local page=Instance.new("ScrollingFrame")
    page.Name=name.."Page"
    page.Size=UDim2.new(1,-204,1,-88)
    page.Position=UDim2.new(0,190,0,76)
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageColor3=Theme.Accent
    page.CanvasSize=UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=false
    page.Parent=mainFrame
    pad(page,8,16,8,8)
    local list=Instance.new("UIListLayout")
    list.Padding=UDim.new(0,9)
    list.SortOrder=Enum.SortOrder.LayoutOrder
    list.Parent=page
    pages[name]=page
    return page
end

local aimPage=makeTab("combat","✥  Combat",1)
local espPage=makeTab("visuals","◉  Visuals",2)
local miscPage=makeTab("misc","⚙  Misc",3)
local setPage=makeTab("settings","☷  Settings",4)
