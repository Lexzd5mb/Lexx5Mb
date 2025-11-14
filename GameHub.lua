--====================================================--
--                GAME HUB by Lexx (Improved UI)
--====================================================--

print("[GameHub] Loaded successfully!")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

--====================================================--
--               MAIN FRAME / UI UTAMA
--====================================================--
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 380)
Frame.Position = UDim2.new(0.75, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Outline = Instance.new("UIStroke", Frame)
Outline.Thickness = 2
Outline.Color = Color3.fromRGB(0, 170, 255)

local Corner = Instance.new("UICorner", Frame)
Corner.CornerRadius = UDim.new(0, 8)

-- TITLE
local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Lexx Game Hub"
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 8)

--====================================================--
--                FPS COUNTER
--====================================================--
local FPSLabel = Instance.new("TextLabel", Frame)
FPSLabel.Size = UDim2.new(1, 0, 0, 25)
FPSLabel.Position = UDim2.new(0, 0, 0, 35)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
FPSLabel.TextSize = 16
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Text = "FPS: ..."

local RunService = game:GetService("RunService")
local frames, lastTime = 0, tick()

RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastTime >= 1 then
        FPSLabel.Text = "FPS: " .. frames
        frames = 0
        lastTime = tick()
    end
end)

--====================================================--
--                BUTTON MAKER
--====================================================--
local function makeButton(text, order, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 65 + (order * 45))
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end)

    btn.MouseButton1Click:Connect(callback)
end

--====================================================--
--                BOOST FUNCTIONS
--====================================================--
local function BoostFPS1()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    game.Lighting.GlobalShadows = false
    print("[GameHub] FPS Boost Level 1 Activated!")
end

local function BoostFPS2()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1 end
    end
    local L = game.Lighting
    L.GlobalShadows = false
    L.FogEnd = 1e9
    L.Brightness = 1
    print("[GameHub] FPS Boost Level 2 Activated!")
end

local function BoostFPS3()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 1 end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = false end
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end
    local L = game.Lighting
    L.GlobalShadows = false
    L.FogEnd = 999999999
    L.Ambient = Color3.new(1,1,1)
    L.OutdoorAmbient = Color3.new(1,1,1)
    L.EnvironmentDiffuseScale = 0
    L.EnvironmentSpecularScale = 0
    print("[GameHub] FPS Boost Level 3 Activated!")
end

local function ResetFPS()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then v.Transparency = 0 end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = true end
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then v.Enabled = true end
    end
    print("[GameHub] FPS Reset.")
end

--====================================================--
--          MINIMIZE SYSTEM (BUBBLE BUTTON) DENGAN GAMBAR
--====================================================--

local MiniButton = Instance.new("ImageButton", ScreenGui)
MiniButton.Size = UDim2.new(0, 55, 0, 55)
MiniButton.Position = UDim2.new(0.88, 0, 0.5, 0)
MiniButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MiniButton.Image = "https://i.imgur.com/0hgL2hp.png"
MiniButton.ScaleType = Enum.ScaleType.Fit
MiniButton.Visible = false

local MiniCorner = Instance.new("UICorner", MiniButton)
MiniCorner.CornerRadius = UDim.new(1,0)

MiniButton.Active = true
MiniButton.Draggable = true

MiniButton.MouseEnter:Connect(function()
    MiniButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
end)
MiniButton.MouseLeave:Connect(function()
    MiniButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -40, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.new(1,1,1)

local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(1,0)

MinBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    MiniButton.Visible = true
end)

MiniButton.MouseButton1Click:Connect(function()
    Frame.Visible = true
    MiniButton.Visible = false
end)

--====================================================--
--                BUTTON ORDER
--====================================================--
makeButton("FPS Level 1 (Ringan)", 0, BoostFPS1)
makeButton("FPS Level 2 (Low)", 1, BoostFPS2)
makeButton("FPS Level 3 (Ultra Low)", 2, BoostFPS3)
makeButton("Reset FPS", 3, ResetFPS)
makeButton("Close UI", 4, function() ScreenGui:Destroy() end)

print("[GameHub] UI Loaded")