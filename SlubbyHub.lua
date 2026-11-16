
--[[
    SLUBBY HUB v2.0
    Standalone Roblox client script
    Player ESP | Manual Aimlock | Movement | Flight
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGURATION
local Config = {
    Speed = 16,
    Jump = 50,
    AimEnabled = false,
    AimFOV = 180,
    Smoothness = 8,
    ESPEnabled = false,
    FlyEnabled = false,
    TeamCheck = false,
    Theme = 1
}

local Themes = {
    {Main = Color3.fromRGB(17,18,23), Panel = Color3.fromRGB(27,28,35), Accent = Color3.fromRGB(175,25,48)},
    {Main = Color3.fromRGB(12,12,12), Panel = Color3.fromRGB(25,25,25), Accent = Color3.fromRGB(255,0,55)},
    {Main = Color3.fromRGB(20,20,25), Panel = Color3.fromRGB(35,35,40), Accent = Color3.fromRGB(110,110,120)}
}

local function character()
    return Player.Character
end

local function humanoid()
    local c = character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function root()
    local c = character()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- GUI PARENT
local GUI = Instance.new("ScreenGui")
GUI.Name = "SlubbyHubV2"
GUI.ResetOnSpawn = false

local parent = game:GetService("CoreGui")
pcall(function()
    if gethui then
        parent = gethui()
    end
end)

GUI.Parent = parent

local theme = Themes[Config.Theme]

-- MAIN WINDOW
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(620,420)
Main.Position = UDim2.new(0.5,-310,0.5,-210)
Main.BackgroundColor3 = theme.Main
Main.BorderSizePixel = 0
Main.Parent = GUI

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,12)
mainCorner.Parent = Main

local outline = Instance.new("UIStroke")
outline.Color = theme.Accent
outline.Thickness = 1.5
outline.Parent = Main

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,52)
Header.BackgroundColor3 = theme.Panel
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1,-60,1,0)
HeaderTitle.Position = UDim2.fromOffset(18,0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "SLUBBY HUB"
HeaderTitle.TextColor3 = Color3.new(1,1,1)
HeaderTitle.TextSize = 19
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local Version = Instance.new("TextLabel")
Version.Size = UDim2.fromOffset(55,25)
Version.Position = UDim2.new(1,-70,0.5,-12)
Version.BackgroundColor3 = theme.Accent
Version.Text = "2.0"
Version.TextColor3 = Color3.new(1,1,1)
Version.Font = Enum.Font.GothamBold
Version.TextSize = 12
Version.Parent = Header

Instance.new("UICorner",Version).CornerRadius = UDim.new(0,6)

-- DRAGGING
local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(12,65)
Sidebar.Size = UDim2.fromOffset(135,340)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Main

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0,9)
sideLayout.Parent = Sidebar

-- CONTENT
local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(160,65)
Content.Size = UDim2.new(1,-175,1,-78)
Content.BackgroundColor3 = theme.Panel
Content.BorderSizePixel = 0
Content.Parent = Main

Instance.new("UICorner",Content).CornerRadius = UDim.new(0,9)

local Pages = {}

for _,name in ipairs({"Home","Combat","Player","Settings"}) do
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,9)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0,12)
    padding.PaddingLeft = UDim.new(0,12)
    padding.PaddingRight = UDim.new(0,12)
    padding.Parent = page

    Pages[name] = page
end

local function switchPage(name)
    for pageName,page in pairs(Pages) do
        page.Visible = pageName == name
    end
end

local function label(page,text)
    local obj = Instance.new("TextLabel")
    obj.Size = UDim2.new(1,-5,0,32)
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.fromRGB(235,235,240)
    obj.TextSize = 14
    obj.Font = Enum.Font.GothamBold
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = Pages[page]
    return obj
end

local function button(page,text,callback)
    local obj = Instance.new("TextButton")
    obj.Size = UDim2.new(1,-5,0,39)
    obj.BackgroundColor3 = Themes[Config.Theme].Accent
    obj.Text = text
    obj.TextColor3 = Color3.new(1,1,1)
    obj.TextSize = 13
    obj.Font = Enum.Font.GothamMedium
    obj.AutoButtonColor = true
    obj.Parent = Pages[page]

    Instance.new("UICorner",obj).CornerRadius = UDim.new(0,7)

    obj.MouseButton1Click:Connect(callback)
    return obj
end

-- SLIDERS
local function slider(page,title,min,max,initial,callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1,-5,0,65)
    holder.BackgroundTransparency = 1
    holder.Parent = Pages[page]

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,0,25)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,1)
    txt.Font = Enum.Font.Gotham
    txt.TextSize = 13
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.Parent = holder

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1,-5,0,8)
    bar.Position = UDim2.fromOffset(0,37)
    bar.BackgroundColor3 = Color3.fromRGB(55,55,65)
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = holder

    Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Themes[Config.Theme].Accent
    fill.Parent = bar
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(15,15)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new(0,0,0.5,0)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Parent = bar
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local current = initial
    local active = false

    local function update(x)
        local width = bar.AbsoluteSize.X
        local percent = math.clamp(
            (x-bar.AbsolutePosition.X)/width,0,1
        )
        current = math.floor(min+(max-min)*percent)
        fill.Size = UDim2.new(percent,0,1,0)
        knob.Position = UDim2.new(percent,0,0.5,0)
        txt.Text = title .. ": " .. current
        callback(current)
    end

    txt.Text = title .. ": " .. current

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = true
            update(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if active and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            active = false
        end
    end)

    update(bar.AbsolutePosition.X + bar.AbsoluteSize.X *
        ((initial-min)/(max-min)))
end

-- SIDEBAR BUTTONS
for _,name in ipairs({"Home","Combat","Player","Settings"}) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1,0,0,42)
    tab.BackgroundColor3 = theme.Panel
    tab.Text = "   " .. name
    tab.TextColor3 = Color3.fromRGB(235,235,240)
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tab.Font = Enum.Font.GothamMedium
    tab.TextSize = 14
    tab.Parent = Sidebar
    Instance.new("UICorner",tab).CornerRadius = UDim.new(0,7)

    tab.MouseButton1Click:Connect(function()
        switchPage(name)
    end)
end

-- HOME
label("Home","WELCOME TO SLUBBY HUB")
label("Home","Your Roblox testing command center.")
label("Home","Version 2.0")
label("Home","Combat | Player | Settings")

-- COMBAT
label("Combat","COMBAT SETTINGS")

-- AIM FOV CIRCLE
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.Parent = GUI

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1,0)
circleCorner.Parent = FOVCircle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(220,35,65)
circleStroke.Thickness = 1.5
circleStroke.Parent = FOVCircle

local aimButton
aimButton = button("Combat","Aimlock: OFF",function()
    Config.AimEnabled = not Config.AimEnabled
    aimButton.Text = "Aimlock: " ..
        (Config.AimEnabled and "ON" or "OFF")
end)

slider("Combat","Aim FOV",50,500,180,function(v)
    Config.AimFOV = v
end)

slider("Combat","Aim Smoothness",1,30,8,function(v)
    Config.Smoothness = v
end)

local teamButton
teamButton = button("Combat","Team Check: OFF",function()
    Config.TeamCheck = not Config.TeamCheck
    teamButton.Text = "Team Check: " ..
        (Config.TeamCheck and "ON" or "OFF")
end)

-- PLAYER ESP
local ESP = {}

local function removeESP(plr)
    if ESP[plr] then
        for _,obj in ipairs(ESP[plr]) do
            obj:Destroy()
        end
        ESP[plr] = nil
    end
end

local function createESP(plr)
    if plr == Player or not Config.ESPEnabled then return end

    removeESP(plr)

    local c = plr.Character
    if not c then return end

    local rootPart = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not rootPart or not hum or hum.Health <= 0 then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = c
    highlight.FillColor = Color3.fromRGB(180,20,45)
    highlight.OutlineColor = Color3.fromRGB(255,70,90)
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = GUI

    local tag = Instance.new("BillboardGui")
    tag.Adornee = rootPart
    tag.Size = UDim2.fromOffset(180,30)
    tag.StudsOffset = Vector3.new(0,3,0)
    tag.AlwaysOnTop = true
    tag.Parent = GUI

    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1,1)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextSize = 13
    text.Parent = tag

    ESP[plr] = {highlight,tag,text}
end

local function refreshESP()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            createESP(plr)
        end
    end
end

local espButton
espButton = button("Combat","Player ESP: OFF",function()
    Config.ESPEnabled = not Config.ESPEnabled
    espButton.Text = "Player ESP: " ..
        (Config.ESPEnabled and "ON" or "OFF")

    if Config.ESPEnabled then
        refreshESP()
    else
        for plr in pairs(ESP) do
            removeESP(plr)
        end
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if Config.ESPEnabled then
            createESP(plr)
        end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

-- PLAYER
label("Player","MOVEMENT SETTINGS")

slider("Player","WalkSpeed",16,40,16,function(v)
    Config.Speed = v
end)

slider("Player","Jump Power",50,500,50,function(v)
    Config.Jump = v
end)

local flyButton
flyButton = button("Player","Fly: OFF",function()
    Config.FlyEnabled = not Config.FlyEnabled
    flyButton.Text = "Fly: " ..
        (Config.FlyEnabled and "ON" or "OFF")
end)

label("Player","Flight controls:")
label("Player","WASD / Arrow Keys / Mobile Thumbstick")
label("Player","Space = Ascend | Left Ctrl = Descend")
label("Player","Mobile: use the on-screen flight buttons")

-- MOBILE FLIGHT BUTTONS
local function mobileButton(name,pos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(65,55)
    b.Position = pos
    b.BackgroundColor3 = Themes[Config.Theme].Accent
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.Visible = false
    b.Parent = GUI
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)
    return b
end

local upButton = mobileButton("UP",UDim2.new(1,-155,1,-180))
local downButton = mobileButton("DOWN",UDim2.new(1,-155,1,-115))

local ascend = false
local descend = false

upButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        ascend = true
    end
end)

upButton.InputEnded:Connect(function()
    ascend = false
end)

downButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        descend = true
    end
end)

downButton.InputEnded:Connect(function()
    descend = false
end)

-- SETTINGS
label("Settings","HUB SETTINGS")

local themeButton
themeButton = button("Settings","Change Theme",function()
    Config.Theme = Config.Theme % #Themes + 1
    local t = Themes[Config.Theme]

    Main.BackgroundColor3 = t.Main
    Content.BackgroundColor3 = t.Panel
    Header.BackgroundColor3 = t.Panel
    outline.Color = t.Accent
    FOVCircle:FindFirstChildOfClass("UIStroke").Color = t.Accent

    for _,obj in ipairs(GUI:GetDescendants()) do
        if obj:IsA("TextButton") and obj ~= themeButton then
            obj.BackgroundColor3 = t.Accent
        end
        if obj:IsA("Frame") and obj ~= Main
        and obj ~= Content and obj ~= Header then
            if obj.Parent == GUI then
                obj.BackgroundColor3 = t.Accent
            end
        end
    end
end)

button("Settings","Close Hub",function()
    Config.AimEnabled = false
    Config.ESPEnabled = false
    Config.FlyEnabled = false

    for plr in pairs(ESP) do
        removeESP(plr)
    end

    GUI:Destroy()
end)

-- MOVEMENT
local bodyVelocity
local bodyGyro

local function stopFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

local function startFly()
    local r = root()
    if not r then return end

    stopFly()

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = r

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bodyGyro.P = 10000
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.Parent = r
end

local function isKeyDown(key)
    return UIS:IsKeyDown(key)
end

-- AIM TARGET SELECTION
local function validTarget(plr)
    if plr == Player then return false end

    if Config.TeamCheck and plr.Team == Player.Team then
        return false
    end

    local c = plr.Character
    if not c then return false end

    local hum = c:FindFirstChildOfClass("Humanoid")
    local head = c:FindFirstChild("Head")

    return hum and hum.Health > 0 and head
end

local function getTarget()
    local best = nil
    local shortest = Config.AimFOV
    local center = Camera.ViewportSize / 2

    for _,plr in ipairs(Players:GetPlayers()) do
        if validTarget(plr) then
            local head = plr.Character.Head
            local screenPos,visible = Camera:WorldToViewportPoint(head.Position)

            if visible and screenPos.Z > 0 then
                local distance = (
                    Vector2.new(screenPos.X,screenPos.Y)-center
                ).Magnitude

                if distance < shortest then
                    shortest = distance
                    best = head
                end
            end
        end
    end

    return best
end

-- MAIN UPDATE LOOP
local updateConnection

updateConnection = RunService.RenderStepped:Connect(function()
    if not GUI.Parent then
        updateConnection:Disconnect()
        stopFly()
        return
    end

    Camera = workspace.CurrentCamera

    -- FOV DISPLAY
    local center = Camera.ViewportSize / 2
    FOVCircle.Position = UDim2.fromOffset(center.X,center.Y)
    FOVCircle.Size = UDim2.fromOffset(
        Config.AimFOV*2,Config.AimFOV*2
    )
    FOVCircle.Visible = Config.AimEnabled

    -- AIMLOCK
    if Config.AimEnabled then
        local target = getTarget()

        if target then
            local desired = CFrame.lookAt(
                Camera.CFrame.Position,
                target.Position
            )

            local alpha = 1 / Config.Smoothness
            Camera.CFrame = Camera.CFrame:Lerp(desired,alpha)
        end
    end

    -- ESP DISTANCE
    if Config.ESPEnabled then
        local myRoot = root()

        for plr,objects in pairs(ESP) do
            local c = plr.Character
            local targetRoot = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChildOfClass("Humanoid")

            if targetRoot and myRoot and hum and hum.Health > 0 then
                objects[3].Text = plr.DisplayName .. "  [" ..
                    math.floor((targetRoot.Position-myRoot.Position).Magnitude) ..
                    " studs]"
            else
                objects[3].Text = plr.DisplayName .. "  [Unavailable]"
            end
        end
    end

    -- WALK SPEED AND JUMP
    local hum = humanoid()

    if hum then
        hum.UseJumpPower = true
        hum.WalkSpeed = Config.Speed
        hum.JumpPower = Config.Jump
    end

    -- FLIGHT
    if Config.FlyEnabled then
        if not bodyVelocity or not bodyVelocity.Parent then
            startFly()
        end

        local r = root()
        if r and bodyVelocity then
            local move = hum and hum.MoveDirection or Vector3.zero

            local vertical = 0

            if isKeyDown(Enum.KeyCode.Space) or ascend then
                vertical = vertical + 1
            end

            if isKeyDown(Enum.KeyCode.LeftControl)
            or isKeyDown(Enum.KeyCode.RightControl)
            or descend then
                vertical = vertical - 1
            end

            bodyVelocity.Velocity =
                move * Config.Speed +
                Vector3.new(0,vertical*Config.Speed,0)

            if bodyGyro then
                bodyGyro.CFrame = Camera.CFrame
            end
        end
    else
        if bodyVelocity or bodyGyro then
            stopFly()
        end
    end

    upButton.Visible = Config.FlyEnabled and UIS.TouchEnabled
    downButton.Visible = Config.FlyEnabled and UIS.TouchEnabled
end)

-- RESPAWN HANDLING
Player.CharacterAdded:Connect(function()
    task.wait(1)
    stopFly()

    local hum = humanoid()
    if hum then
        hum.UseJumpPower = true
        hum.WalkSpeed = Config.Speed
        hum.JumpPower = Config.Jump
    end
end)

-- INITIALIZE
switchPage("Home")

print("[SLUBBY HUB v2.0] Loaded successfully.")
