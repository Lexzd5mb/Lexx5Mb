local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoRejoinGUI"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(280, 160)
Main.Position = UDim2.new(0.5, -140, 0.5, -80)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Auto Rejoin"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

local IntervalBox = Instance.new("TextBox")
IntervalBox.Size = UDim2.new(0.85, 0, 0, 35)
IntervalBox.Position = UDim2.new(0.075, 0, 0, 50)
IntervalBox.Text = "3600"
IntervalBox.PlaceholderText = "Interval (detik)"
IntervalBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
IntervalBox.TextColor3 = Color3.new(1,1,1)
IntervalBox.Font = Enum.Font.Gotham
IntervalBox.TextSize = 14
IntervalBox.Parent = Main

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = IntervalBox

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0.85, 0, 0, 35)
Toggle.Position = UDim2.new(0.075, 0, 0, 100)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.Text = "ON"
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

-- Drag GUI
local UIS = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Auto execute (langsung aktif)
local Enabled = true

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    if Enabled then
        Toggle.Text = "ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,170,127)
    else
        Toggle.Text = "OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(170,50,50)
    end
end)

task.spawn(function()
    while true do
        local Interval = tonumber(IntervalBox.Text) or 3600
        task.wait(Interval)

        if Enabled then
            TeleportService:Teleport(game.PlaceId, Player)
        end
    end
end)
