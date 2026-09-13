--// ULTIMATE v8.3 - PART 1 (Core + ESP + AimBot)
print("[PART1] Loading...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.AUTHOR = {Name = "DJCscript", Version = "8.3", Telegram = "@DeverJomdsCodeCC", TelegramURL = "https://t.me/DeverJomdsCodeCC"}
_G.UNIVERSAL_KEY = "DeverJomdsCodeCC"

_G.THEME = {
    BG = Color3.fromRGB(15, 15, 22),
    BGAlt = Color3.fromRGB(22, 22, 32),
    Elem = Color3.fromRGB(38, 38, 54),
    Accent = Color3.fromRGB(155, 90, 255),
    Accent2 = Color3.fromRGB(0, 220, 255),
    Success = Color3.fromRGB(80, 230, 130),
    Danger = Color3.fromRGB(255, 75, 100),
    Warning = Color3.fromRGB(255, 190, 60),
    Telegram = Color3.fromRGB(0, 136, 204),
    Text = Color3.fromRGB(245, 245, 255),
    TextDim = Color3.fromRGB(140, 140, 165),
    Stroke = Color3.fromRGB(70, 70, 100),
}

_G.ESP = {Enabled=true, ShowHighlight=true, ShowChams=false, ShowBox=false, ShowLine=false, ShowSkeleton=false,
    ShowName=true, ShowHealth=true, ShowDistance=false, TeamCheck=false, MaxDistance=500,
    BoxColor=Color3.fromRGB(0,200,255), LineColor=Color3.fromRGB(255,255,255),
    SkeletonColor=Color3.fromRGB(255,255,255), ChamsColor=Color3.fromRGB(0,255,150)}

_G.AIM = {Enabled=false, SilentAim=false, TeamCheck=true, MaxDistance=500, Smoothness=0.15, FOV=150}
_G.FOV = {Enabled=false, Value=70, DefaultValue=Camera.FieldOfView, Min=20, Max=120, Smooth=true, SmoothSpeed=8}
_G.AUTOJUMP = {Enabled=false}

local ESP = _G.ESP
local AIM = _G.AIM
local FOV = _G.FOV
local AUTOJUMP = _G.AUTOJUMP

RunService.Heartbeat:Connect(function()
    if not AUTOJUMP.Enabled then return end
    local ch = LocalPlayer.Character; if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
    if hum.FloorMaterial ~= Enum.Material.Air then hum.Jump = true end
end)

local currentFOV = FOV.DefaultValue
RunService.RenderStepped:Connect(function(dt)
    if not FOV.Enabled then return end
    local target = FOV.Value
    if FOV.Smooth then
        currentFOV = currentFOV + (target - currentFOV) * math.min(FOV.SmoothSpeed * dt, 1)
    else currentFOV = target end
    pcall(function() Camera.FieldOfView = currentFOV end)
end)

local espData = {}
local SKELETON_BONES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local CHAMS_PARTS = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}

local function createESP(player)
    if player == LocalPlayer or espData[player] then return end
    local char = player.Character or player.CharacterAdded:Wait(); if not char then return end
    local hl = Instance.new("Highlight")
    hl.Name="ESP_HL"; hl.FillColor=ESP.BoxColor; hl.FillTransparency=0.55
    hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char

    local chamsParts = {}
    local function applyChams()
        for _, name in ipairs(CHAMS_PARTS) do
            local part = char:FindFirstChild(name)
            if part and part:IsA("BasePart") and not chamsParts[part] then
                chamsParts[part] = {color = part.Color, mat = part.Material}
                part.Color = ESP.ChamsColor; part.Material = Enum.Material.ForceField
            end
        end
    end
    local function clearChams()
        for part, data in pairs(chamsParts) do
            if part and part.Parent then part.Color = data.color; part.Material = data.mat end
        end
        chamsParts = {}
    end

    local bb = Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,200,0,50); bb.StudsOffset=Vector3.new(0,3,0)
    bb.AlwaysOnTop=true; bb.Parent=char

    local nm = Instance.new("TextLabel")
    nm.Size=UDim2.new(1,0,0.34,0); nm.BackgroundTransparency=1
    nm.TextColor3=Color3.fromRGB(255,255,255); nm.TextStrokeTransparency=0.3
    nm.TextScaled=true; nm.Font=Enum.Font.GothamBold; nm.Text=player.Name; nm.Parent=bb

    local hp = Instance.new("TextLabel")
    hp.Size=UDim2.new(1,0,0.33,0); hp.Position=UDim2.new(0,0,0.34,0)
    hp.BackgroundTransparency=1; hp.TextColor3=Color3.fromRGB(80,255,80)
    hp.TextStrokeTransparency=0.3; hp.TextScaled=true; hp.Font=Enum.Font.Gotham
    hp.Text="100 HP"; hp.Parent=bb

    local dist = Instance.new("TextLabel")
    dist.Size=UDim2.new(1,0,0.33,0); dist.Position=UDim2.new(0,0,0.67,0)
    dist.BackgroundTransparency=1; dist.TextColor3=Color3.fromRGB(200,200,200)
    dist.TextStrokeTransparency=0.3; dist.TextScaled=true; dist.Font=Enum.Font.Gotham
    dist.Text="0m"; dist.Parent=bb

    local boxGui = Instance.new("ScreenGui")
    boxGui.ResetOnSpawn=false; boxGui.IgnoreGuiInset=true; boxGui.DisplayOrder=100
    boxGui.Parent=LocalPlayer:WaitForChild("PlayerGui")

    local boxFrame = Instance.new("Frame")
    boxFrame.BackgroundTransparency=1; boxFrame.BorderSizePixel=0
    boxFrame.Visible=false; boxFrame.Parent=boxGui

    local sides = {}
    for _, side in ipairs({"Top","Bottom","Left","Right"}) do
        local s = Instance.new("Frame"); s.BackgroundColor3=ESP.BoxColor
        s.BorderSizePixel=0; s.Parent=boxFrame; sides[side]=s
    end

    local lineGui = Instance.new("ScreenGui")
    lineGui.ResetOnSpawn=false; lineGui.IgnoreGuiInset=true; lineGui.DisplayOrder=99
    lineGui.Parent=LocalPlayer:WaitForChild("PlayerGui")

    local line = Instance.new("Frame")
    line.BackgroundColor3=ESP.LineColor; line.BorderSizePixel=0
    line.AnchorPoint=Vector2.new(0.5,0); line.Visible=false; line.Parent=lineGui

    local skelGui = Instance.new("ScreenGui")
    skelGui.ResetOnSpawn=false; skelGui.IgnoreGuiInset=true; skelGui.DisplayOrder=98
    skelGui.Parent=LocalPlayer:WaitForChild("PlayerGui")

    local boneLines = {}
    for i = 1, #SKELETON_BONES do
        local bl = Instance.new("Frame"); bl.BackgroundColor3=ESP.SkeletonColor
        bl.BorderSizePixel=0; bl.AnchorPoint=Vector2.new(0.5,0.5)
        bl.Visible=false; bl.Parent=skelGui; boneLines[i]=bl
    end

    espData[player] = {hl=hl, bb=bb, nm=nm, hp=hp, dist=dist, boxGui=boxGui,
        boxFrame=boxFrame, sides=sides, lineGui=lineGui, line=line,
        skeletonGui=skelGui, boneLines=boneLines, chamsParts=chamsParts,
        applyChams=applyChams, clearChams=clearChams}
end

local function removeESP(player)
    local d = espData[player]
    if d then
        for _, k in ipairs({"hl","bb","boxGui","lineGui","skeletonGui"}) do
            if d[k] then d[k]:Destroy() end
        end
        if d.clearChams then d.clearChams() end
        espData[player] = nil
    end
end

local function drawLine2D(frame, p1, p2, th)
    local mid = (p1 + p2) / 2
    local diff = p2 - p1
    frame.Size = UDim2.new(0, diff.Magnitude, 0, th)
    frame.Position = UDim2.new(0, mid.X, 0, mid.Y)
    frame.Rotation = math.deg(math.atan2(diff.Y, diff.X))
end

RunService.RenderStepped:Connect(function()
    for p, d in pairs(espData) do
        local ch = p.Character; if not ch then continue end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local rp = ch:FindFirstChild("HumanoidRootPart")
        if not hum or not rp then continue end
        local visible = ESP.Enabled
        local distValue = (Camera.CFrame.Position - rp.Position).Magnitude
        if distValue > ESP.MaxDistance then visible = false end
        if ESP.TeamCheck and p.Team == LocalPlayer.Team and p.Team ~= nil then visible = false end
        d.hp.Text = math.floor(hum.Health).." / "..math.floor(hum.MaxHealth).." HP"
        d.nm.Text = p.Name; d.dist.Text = math.floor(distValue).."m"
        d.hl.Enabled = visible and ESP.ShowHighlight; d.hl.FillColor = ESP.BoxColor
        d.bb.Enabled = visible and (ESP.ShowName or ESP.ShowHealth or ESP.ShowDistance)
        d.nm.Visible = ESP.ShowName; d.hp.Visible = ESP.ShowHealth; d.dist.Visible = ESP.ShowDistance
        if ESP.ShowChams and visible then d.applyChams() else d.clearChams() end
        if ESP.ShowBox and visible then
            local head = ch:FindFirstChild("Head")
            if head then
                local topPos = head.Position + Vector3.new(0, 0.6, 0)
                local bottomPos = rp.Position - Vector3.new(0, 3, 0)
                local ts, to = Camera:WorldToViewportPoint(topPos)
                local bs, bo = Camera:WorldToViewportPoint(bottomPos)
                if to and bo then
                    local h = math.abs(bs.Y - ts.Y); local w = h * 0.55
                    local cx = (ts.X + bs.X) / 2; local cy = (ts.Y + bs.Y) / 2
                    d.boxFrame.Visible = true
                    d.boxFrame.Position = UDim2.new(0, cx-w/2, 0, cy-h/2)
                    d.boxFrame.Size = UDim2.new(0, w, 0, h)
                    local t = 1.5
                    d.sides.Top.Size = UDim2.new(1,0,0,t)
                    d.sides.Bottom.Size = UDim2.new(1,0,0,t)
                    d.sides.Bottom.Position = UDim2.new(0,0,1,-t)
                    d.sides.Left.Size = UDim2.new(0,t,1,0)
                    d.sides.Right.Size = UDim2.new(0,t,1,0)
                    d.sides.Right.Position = UDim2.new(1,-t,0,0)
                else d.boxFrame.Visible = false end
            else d.boxFrame.Visible = false end
        else d.boxFrame.Visible = false end
        if ESP.ShowLine and visible then
            local tsp, on = Camera:WorldToViewportPoint(rp.Position)
            if on then
                local vp = Camera.ViewportSize
                drawLine2D(d.line, Vector2.new(vp.X/2, vp.Y), Vector2.new(tsp.X, tsp.Y), 1.5)
                d.line.BackgroundColor3 = ESP.LineColor; d.line.Visible = true
            else d.line.Visible = false end
        else d.line.Visible = false end
        if ESP.ShowSkeleton and visible then
            for i, bone in ipairs(SKELETON_BONES) do
                local p1 = ch:FindFirstChild(bone[1]); local p2 = ch:FindFirstChild(bone[2])
                local bl = d.boneLines[i]
                if p1 and p2 and bl then
                    local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                    local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                    if on1 and on2 then
                        drawLine2D(bl, Vector2.new(s1.X,s1.Y), Vector2.new(s2.X,s2.Y), 1.5)
                        bl.Visible = true
                    else bl.Visible = false end
                elseif bl then bl.Visible = false end
            end
        else
            for _, bl in ipairs(d.boneLines) do bl.Visible = false end
        end
    end
end)

for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.3); removeESP(p); createESP(p)
    end)
end)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not AIM.Enabled then return end
    local best, bestDist = nil, AIM.FOV
    local vp = Camera.ViewportSize; local center = Vector2.new(vp.X/2, vp.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if AIM.TeamCheck and p.Team == LocalPlayer.Team and p.Team ~= nil then continue end
        local ch = p.Character; if not ch then continue end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = ch:FindFirstChild("Head"); if not part then continue end
        if (Camera.CFrame.Position - part.Position).Magnitude > AIM.MaxDistance then continue end
        local sp, on = Camera:WorldToViewportPoint(part.Position); if not on then continue end
        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist < bestDist then bestDist = dist; best = part end
    end
    if best then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, best.Position), AIM.Smoothness)
    end
end)

_G.restoreFOV = function() pcall(function() Camera.FieldOfView = FOV.DefaultValue end) end
_G.currentFOVGetter = function() return currentFOV end
_G.setCurrentFOV = function(v) currentFOV = v end
_G.buildMenu = nil
_G.ESP = ESP
_G.AIM = AIM
_G.FOV = FOV
_G.AUTOJUMP = AUTOJUMP

print("[PART1] Core + ESP + AimBot loaded")

loadstring(game:HttpGet("https://raw.githubusercontent.com/DJCscripts/DeverJomdsCodeCC/main/Part2.lua", true))()
