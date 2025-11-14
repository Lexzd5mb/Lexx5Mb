--====================================================--
--                GAME HUB by Lexx
--====================================================--

print("[GameHub] Loaded successfully!")

-- UI FRAME SEDERHANA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 360)
Frame.Position = UDim2.new(0.75, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "Lexx Game Hub"
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)

-- BUTTON MAKER
local function makeButton(text, order, callback)
    local btn = Instance.new("TextButton", Frame)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 35 + (order * 40))
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text
    btn.TextSize = 16
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

        -- Matikan semua texture
        if v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end

        -- Matikan particle
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end

        -- Matikan semua lampu
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = false
        end

        -- Ganti semua material jadi smooth plastic
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