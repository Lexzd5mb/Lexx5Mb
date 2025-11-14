--====================================================--
--                GAME HUB by Lexx
--      (Untuk game kamu sendiri / Dev Tools)
--====================================================--

print("[GameHub] Loaded successfully!")

-- UI FRAME SEDERHANA
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 260)
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
--                FUNGSI BOOST FPS AMAN
--====================================================--

local function BoostFPS()
    -- Matikan partikel
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
        if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v.Enabled = false
        end
        if v:IsA("Texture") or v:IsA("Decal") then
            v.Transparency = 1
        end
    end

    -- Setting lighting
    game.Lighting.GlobalShadows = false
    game.Lighting.FogEnd = 1e9
    game.Lighting.Brightness = 1

    -- Setting quality
    pcall(function()
        local gameSettings = UserSettings():GetService("UserGameSettings")
        gameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)

    print("[GameHub] FPS Boost Activated!")
end

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
--                   BUTTONS UI
--====================================================--

makeButton("Boost FPS", 0, function()
    BoostFPS()
end)

makeButton("Reset FPS", 1, function()
    ResetFPS()
end)

makeButton("Close UI", 2, function()
    ScreenGui:Destroy()
end)

print("[GameHub] UI Loaded")