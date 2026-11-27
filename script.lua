
-- 0z Menu | UI rebuild
-- Interface demonstrativa: os controles abaixo alteram apenas a aparência/estado visual
-- desta GUI. Nenhuma função de mira, ESP, recoil ou interação com outros jogadores é executada.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("0zMenuUI")
if old then old:Destroy() end

local Theme = {
    bg = Color3.fromRGB(10, 9, 17),
    panel = Color3.fromRGB(18, 15, 29),
    card = Color3.fromRGB(24, 20, 38),
    hover = Color3.fromRGB(37, 27, 57),
    stroke = Color3.fromRGB(77, 48, 112),
    purple = Color3.fromRGB(174, 55, 255),
    pink = Color3.fromRGB(215, 105, 255),
    text = Color3.fromRGB(250, 247, 255),
    muted = Color3.fromRGB(174, 158, 198),
    off = Color3.fromRGB(64, 54, 82),
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local function round(obj, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, obj)
end

local function outline(obj, color, thickness)
    make("UIStroke", {
        Color = color or Theme.stroke,
        Thickness = thickness or 1,
        Transparency = 0.1,
    }, obj)
end

local function gradient(obj)
    make("UIGradient", {
        Color = ColorSequence.new(Theme.purple, Theme.pink),
        Rotation = 25,
    }, obj)
end

local gui = make("ScreenGui", {
    Name = "0zMenuUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(900, 620),
    Position = UDim2.new(0.5, -450, 0.5, -310),
    BackgroundColor3 = Theme.bg,
    BorderSizePixel = 0,
}, gui)
round(main, 18)
outline(main, Theme.stroke, 1.5)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
}, main)
round(header, 18)

local headerMask = make("Frame", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 1, -18),
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
}, header)

local logo = make("Frame", {
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.fromOffset(16, 12),
    BackgroundColor3 = Theme.purple,
    BorderSizePixel = 0,
}, header)
round(logo, 13)
gradient(logo)

make("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "0z",
    TextColor3 = Theme.bg,
    Font = Enum.Font.GothamBlack,
    TextSize = 19,
}, logo)

make("TextLabel", {
    Position = UDim2.fromOffset(78, 13),
    Size = UDim2.new(0, 300, 0, 26),
    BackgroundTransparency = 1,
    Text = "0z Menu",
    TextColor3 = Theme.text,
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

make("TextLabel", {
    Position = UDim2.fromOffset(79, 39),
    Size = UDim2.new(0, 360, 0, 18),
    BackgroundTransparency = 1,
    Text = "pvp interface  •  purple edition",
    TextColor3 = Theme.muted,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local close = make("TextButton", {
    Size = UDim2.fromOffset(34, 34),
    Position = UDim2.new(1, -48, 0, 18),
    BackgroundColor3 = Theme.card,
    Text = "×",
    TextColor3 = Theme.muted,
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    AutoButtonColor = false,
}, header)
round(close, 9)
outline(close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local line = make("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 0, 71),
    BackgroundColor3 = Theme.purple,
    BorderSizePixel = 0,
}, main)
gradient(line)

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(14, 88),
    Size = UDim2.new(0, 170, 1, -102),
    BackgroundColor3 = Theme.panel,
    BorderSizePixel = 0,
}, main)
round(sidebar, 15)
outline(sidebar)

local sideLogo = make("Frame", {
    Size = UDim2.fromOffset(76, 76),
    Position = UDim2.new(0.5, -38, 0, 22),
    BackgroundColor3 = Theme.purple,
    BorderSizePixel = 0,
}, sidebar)
round(sideLogo, 19)
gradient(sideLogo)
make("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "0z",
    TextColor3 = Theme.bg,
    Font = Enum.Font.GothamBlack,
    TextSize = 28,
}, sideLogo)

make("TextLabel", {
    Position = UDim2.new(0, 0, 0, 108),
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = "0z  •  PVP",
    TextColor3 = Theme.text,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
}, sidebar)

make("TextLabel", {
    Position = UDim2.new(0, 10, 0, 137),
    Size = UDim2.new(1, -20, 0, 30),
    BackgroundTransparency = 1,
    Text = "YOUR CURRENT\nCONFIGURATION",
    TextColor3 = Theme.muted,
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextWrapped = true,
}, sidebar)

local nav = make("Frame", {
    Position = UDim2.fromOffset(9, 190),
    Size = UDim2.new(1, -18, 0, 196),
    BackgroundTransparency = 1,
}, sidebar)
local navList = make("UIListLayout", {
    Padding = UDim.new(0, 9),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, nav)

local status = make("Frame", {
    Position = UDim2.new(0, 9, 1, -76),
    Size = UDim2.new(1, -18, 0, 64),
    BackgroundColor3 = Theme.card,
    BorderSizePixel = 0,
}, sidebar)
round(status, 11)
outline(status)
local dot = make("Frame", {
    Position = UDim2.fromOffset(12, 14),
    Size = UDim2.fromOffset(10, 10),
    BackgroundColor3 = Theme.purple,
    BorderSizePixel = 0,
}, status)
round(dot, 5)
make("TextLabel", {
    Position = UDim2.fromOffset(29, 8),
    Size = UDim2.new(1, -36, 0, 17),
    BackgroundTransparency = 1,
    Text = "STATUS",
    TextColor3 = Theme.muted,
    Font = Enum.Font.GothamBold,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
}, status)
make("TextLabel", {
    Position = UDim2.fromOffset(11, 31),
    Size = UDim2.new(1, -18, 0, 20),
    BackgroundTransparency = 1,
    Text = "Interface loaded",
    TextColor3 = Theme.pink,
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, status)

local content = make("Frame", {
    Position = UDim2.fromOffset(198, 88),
    Size = UDim2.new(1, -212, 1, -102),
    BackgroundTransparency = 1,
}, main)

local pages = {}
local navButtons = {}
local currentPage = "Combat"

local function makePage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.purple,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    pages[name] = page
    return page
end

local combat = makePage("Combat")
local visuals = makePage("Visuals")
local misc = makePage("Misc")
local settings = makePage("Settings")

local function selectPage(name)
    currentPage = name
    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
    for buttonName, button in pairs(navButtons) do
        local active = buttonName == name
        TweenService:Create(button, TweenInfo.new(0.15), {
            BackgroundColor3 = active and Theme.purple or Theme.card,
            TextColor3 = active and Theme.text or Theme.muted,
        }):Play()
    end
end

local function addCategory(name, label, order)
    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.card,
        Text = label,
        TextColor3 = Theme.muted,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        LayoutOrder = order,
    }, nav)
    round(button, 10)
    outline(button)
    button.MouseButton1Click:Connect(function() selectPage(name) end)
    navButtons[name] = button
end

addCategory("Combat", "✥   Combat", 1)
addCategory("Visuals", "◉   Visuals", 2)
addCategory("Misc", "⚙   Misc", 3)
addCategory("Settings", "☷   Settings", 4)

local function section(parent, title)
    local label = make("TextLabel", {
        Size = UDim2.new(1, -4, 0, 18),
        BackgroundTransparency = 1,
        Text = string.upper(title),
        TextColor3 = Theme.muted,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent)
    return label
end

local function toggle(parent, title, initial)
    local row = make("TextButton", {
        Size = UDim2.new(1, -4, 0, 48),
        BackgroundColor3 = Theme.card,
        Text = "",
        AutoButtonColor = false,
    }, parent)
    round(row, 12)
    outline(row)
    make("TextLabel", {
        Position = UDim2.fromOffset(15, 0),
        Size = UDim2.new(1, -85, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local track = make("Frame", {
        Position = UDim2.new(1, -58, 0.5, -11),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = initial and Theme.purple or Theme.off,
        BorderSizePixel = 0,
    }, row)
    round(track, 11)
    local knob = make("Frame", {
        Position = initial and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.text,
        BorderSizePixel = 0,
    }, track)
    round(knob, 8)
    local value = initial
    row.MouseButton1Click:Connect(function()
        value = not value
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = value and Theme.purple or Theme.off,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = value and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3),
        }):Play()
    end)
end

local function slider(parent, title, initial, suffix)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 66),
        BackgroundColor3 = Theme.card,
        BorderSizePixel = 0,
    }, parent)
    round(row, 12)
    outline(row)
    make("TextLabel", {
        Position = UDim2.fromOffset(14, 7),
        Size = UDim2.new(1, -110, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    make("TextLabel", {
        Position = UDim2.new(1, -92, 0, 7),
        Size = UDim2.fromOffset(78, 20),
        BackgroundTransparency = 1,
        Text = tostring(initial) .. (suffix or ""),
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local bar = make("Frame", {
        Position = UDim2.new(0, 14, 1, -20),
        Size = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = Theme.off,
        BorderSizePixel = 0,
    }, row)
    round(bar, 3)
    local fill = make("Frame", {
        Size = UDim2.new(0.4, 0, 1, 0),
        BackgroundColor3 = Theme.purple,
        BorderSizePixel = 0,
    }, bar)
    round(fill, 3)
    gradient(fill)
    make("Frame", {
        Position = UDim2.new(0.4, -7, 0.5, -7),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Theme.text,
        BorderSizePixel = 0,
    }, bar)
end

local function palette(parent)
    local card = make("Frame", {
        Size = UDim2.new(1, -4, 0, 96),
        BackgroundColor3 = Theme.card,
        BorderSizePixel = 0,
    }, parent)
    round(card, 12)
    outline(card)
    make("TextLabel", {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Text = "ESP Color",
        TextColor3 = Theme.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, card)
    local colors = {
        Color3.fromRGB(174, 55, 255),
        Color3.fromRGB(215, 105, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(110, 75, 165),
        Color3.fromRGB(255, 90, 170),
    }
    for i, color in ipairs(colors) do
        local swatch = make("TextButton", {
            Position = UDim2.new((i - 1) * 0.19, 14, 0, 43),
            Size = UDim2.new(0.17, 0, 0, 36),
            BackgroundColor3 = color,
            Text = "",
            AutoButtonColor = false,
        }, card)
        round(swatch, 7)
    end
end

section(combat, "Combat")
toggle(combat, "Aimbot", true)
toggle(combat, "Lock On Target", true)
section(combat, "Filters")
toggle(combat, "Only Visible", false)
toggle(combat, "Ignore Friends", true)
toggle(combat, "Prediction", false)
toggle(combat, "Humanize", true)
section(combat, "Adjustments")
slider(combat, "Smoothness", "0.35")
slider(combat, "FOV", "250", "px")
slider(combat, "Max Distance", "1000")
slider(combat, "Prediction Amount", "0.15")

section(visuals, "Highlight")
toggle(visuals, "ESP Highlight", true)
toggle(visuals, "Team Check", true)
palette(visuals)

section(misc, "Utility")
slider(misc, "Recoil Reduction", "0%")
make("TextLabel", {
    Size = UDim2.new(1, -4, 0, 54),
    BackgroundColor3 = Theme.card,
    Text = "Interface preview only\nThese controls do not affect gameplay.",
    TextColor3 = Theme.muted,
    Font = Enum.Font.Gotham,
    TextSize = 11,
}, misc)

section(settings, "Menu")
local keyCard = make("Frame", {
    Size = UDim2.new(1, -4, 0, 48),
    BackgroundColor3 = Theme.card,
    BorderSizePixel = 0,
}, settings)
round(keyCard, 12)
outline(keyCard)
make("TextLabel", {
    Position = UDim2.fromOffset(15, 0),
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1,
    Text = "Menu Key",
    TextColor3 = Theme.text,
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
}, keyCard)
make("TextLabel", {
    Position = UDim2.new(1, -78, 0.5, -12),
    Size = UDim2.fromOffset(62, 24),
    BackgroundColor3 = Theme.bg,
    Text = "J",
    TextColor3 = Theme.text,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
}, keyCard)
make("TextLabel", {
    Size = UDim2.new(1, -4, 0, 66),
    BackgroundColor3 = Theme.card,
    Text = "0z Menu  •  UI rebuild\nPurple PvP interface",
    TextColor3 = Theme.muted,
    Font = Enum.Font.Gotham,
    TextSize = 11,
}, settings)

-- Drag the window from the header.
local dragging = false
local dragInput, dragStart, startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

selectPage("Combat")
