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
    hl.DepthMode = (Config.EspDepthMode == "Occluded
