
--[[
    SLUBBY HUB!
    Version 1.0
    Standalone Roblox client UI
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local WalkSpeed = 16
local JumpPower = 50
local FlyEnabled = false
local AimlockEnabled = false
local AimTarget = nil

local Themes = {
    {Main = Color3.fromRGB(10,10,10), Accent = Color3.fromRGB(145,15,30)},
    {Main = Color3.fromRGB(10,10,10), Accent = Color3.fromRGB(255,0,40)},
    {Main = Color3.fromRGB(0,0,0), Accent = Color3.fromRGB(90,90,90)}
}
local ThemeIndex = 1

local function getCharacter()
    return Player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyMovement()
    local hum = getHumanoid()
    if not hum then return end

    hum.WalkSpeed = WalkSpeed
    hum.UseJumpPower = true
    hum.JumpPower = JumpPower
end

-- GUI setup
local GUI = Instance.new("ScreenGui")
GUI.Name = "SlubbyHub"
GUI.ResetOnSpawn = false

local parent = game:GetService("CoreGui")
pcall(function()
    if gethui then parent = gethui() end
end)
GUI.Parent = parent

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(540,370)
Main.Position = UDim2.new(0.5,-270,0.5,-185)
Main.BackgroundColor3 = Themes[1].Main
Main.BorderSizePixel = 0
Main.Parent = GUI

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Themes[1].Accent
Stroke.Thickness = 2
Stroke.Parent = Main

local Header = Instance.new("TextButton")
Header.Size = UDim2.new(1,0,0,43)
Header.BackgroundColor3 = Themes[1].Accent
Header.Text = "SLUBBY HUB!  |  v1.0"
Header.TextColor3 = Color3.new(1,1,1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Header.Parent = Main

-- Dragging
local dragging = false
local dragInput
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
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

local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10,55)
Sidebar.Size = UDim2.fromOffset(125,300)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Main

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0,8)
SideLayout.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(145,55)
Content.Size = UDim2.new(1,-155,1,-65)
Content.BackgroundColor3 = Color3.fromRGB(20,20,20)
Content.BorderSizePixel = 0
Content.Parent = Main

local Pages = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1,1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    Pages[name] = page
end

for _, name in ipairs({"Home","Combat","Player","Settings"}) do
    createPage(name)
end

local function switchPage(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end
end

for _, name in ipairs({"Home","Combat","Player","Settings"}) do
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1,0,0,42)
    tab.BackgroundColor3 = Themes[1].Accent
    tab.Text = name
    tab.TextColor3 = Color3.new(1,1,1)
    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 14
    tab.Parent = Sidebar

    tab.MouseButton1Click:Connect(function()
        switchPage(name)
    end)
end

local function addLabel(pageName, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-12,0,34)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = Pages[pageName]
    return label
end

local function addButton(pageName, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1,-12,0,38)
    button.BackgroundColor3 = Themes[ThemeIndex].Accent
    button.Text = text
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = Pages[pageName]

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

-- HOME
addLabel("Home","WELCOME TO SLUBBY HUB!")
addLabel("Home","Your Roblox testing command center.")
addLabel("Home","Version: 1.0")
addLabel("Home","Categories: 4")

-- COMBAT
addLabel("Combat","COMBAT SETTINGS")

local aimButton
aimButton = addButton("Combat","Aimlock: OFF",function()
    AimlockEnabled = not AimlockEnabled
    aimButton.Text = "Aimlock: " .. (AimlockEnabled and "ON" or "OFF")
end)

addLabel("Combat","Aimlock is a test toggle placeholder.")

-- PLAYER
addLabel("Player","PLAYER SETTINGS")

local speedLabel = addLabel("Player","WalkSpeed: 16")

addButton("Player","Speed +",function()
    WalkSpeed = math.clamp(WalkSpeed + 2,16,40)
    speedLabel.Text = "WalkSpeed: "..WalkSpeed
    applyMovement()
end)

addButton("Player","Speed -",function()
    WalkSpeed = math.clamp(WalkSpeed - 2,16,40)
    speedLabel.Text = "WalkSpeed: "..WalkSpeed
    applyMovement()
end)

local jumpLabel = addLabel("Player","Jump Power: 50")

addButton("Player","Jump +",function()
    JumpPower = math.clamp(JumpPower + 25,50,500)
    jumpLabel.Text = "Jump Power: "..JumpPower
    applyMovement()
end)

addButton("Player","Jump -",function()
    JumpPower = math.clamp(JumpPower - 25,50,500)
    jumpLabel.Text = "Jump Power: "..JumpPower
    applyMovement()
end)

-- Fly is intentionally a UI-only test toggle here.
local flyButton
flyButton = addButton("Player","Fly: OFF",function()
    FlyEnabled = not FlyEnabled
    flyButton.Text = "Fly: "..(FlyEnabled and "ON" or "OFF")
end)

-- SETTINGS
addLabel("Settings","HUB SETTINGS")

addButton("Settings","Change Theme",function()
    ThemeIndex = ThemeIndex % #Themes + 1
    local theme = Themes[ThemeIndex]

    Main.BackgroundColor3 = theme.Main
    Stroke.Color = theme.Accent
    Header.BackgroundColor3 = theme.Accent

    for _, obj in ipairs(GUI:GetDescendants()) do
        if obj:IsA("TextButton") then
            obj.BackgroundColor3 = theme.Accent
        end
    end
end)

addButton("Settings","Close Hub",function()
    GUI:Destroy()
end)

Player.CharacterAdded:Connect(function()
    task.wait(1)
    applyMovement()
end)

switchPage("Home")

print("[Slubby Hub!] Loaded successfully.")
