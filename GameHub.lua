--====================================================--
--                GAME HUB by Lexx (Improved UI)
--====================================================--

print("[GameHub] Loaded successfully!")

-- UI FRAME SEDERHANA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

-- FRAME UTAMA
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 240, 0, 380)
Frame.Position = UDim2.new(0.75, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

-- FRAME BORDER OUTLINE
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
--                 FPS COUNTER DI UI
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
local frames = 0
local lastTime = tick()

RunService.RenderStepped:Connect(function()
    frames = frames + 1
    if tick() - lastTime >= 1 then
        FPSLabel.Text = "FPS: " .. frames
        frames = 0
        lastTime = tick()
    end
end)

--====================================================--
--                 BUTTON MAKER BARU
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

    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end)

    btn.MouseButton1Click:Connect(callback)
end

--====================================================--
--        BOOST LEVEL 1 — Ringan
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

--====================================================--
--        BOOST LEVEL 2 — Low / Medium
--====================================================--
local function BoostFPS2()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
        if v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end

    local L = game.Lighting
    L.GlobalShadows = false
    L.FogEnd = 1e9
    L.Brightness = 1

    print("[GameHub] FPS Boost Level 2 Activated!")
end

--====================================================--
--        BOOST LEVEL 3 — Ultra Low / Potato Mode
--====================================================--
local function BoostFPS3()
    for _, v in ipairs(workspace:GetDescendants()) do

        if v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end

        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end

        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = false
        end

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

--====================================================--
--        RESET FPS
--====================================================--
local function ResetFPS()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 0
        end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = true
        end
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = true
        end
    end
    print("[GameHub] FPS Reset.")
end

--====================================================--
--                UI BUTTON ORDER
--====================================================--

makeButton("FPS Level 1 (Ringan)", 0, BoostFPS1)
makeButton("FPS Level 2 (Low)", 1, BoostFPS2)
makeButton("FPS Level 3 (Ultra Low)", 2, BoostFPS3)
makeButton("Reset FPS", 3, ResetFPS)
makeButton("Close UI", 4, function()
    ScreenGui:Destroy()
end)

print("[GameHub] UI Loaded")