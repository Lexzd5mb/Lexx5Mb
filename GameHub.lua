local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

local enabled = false

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "AntiLagUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 40)
button.Position = UDim2.new(0, 20, 0, 200)
button.Text = "Anti Lag: OFF"
button.BackgroundColor3 = Color3.fromRGB(40,40,40)
button.TextColor3 = Color3.new(1,1,1)
button.Parent = gui

-- DRAG
local dragging, dragStart, startPos
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
    end
end)

button.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

button.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- DETEKSI WEB
local function isWeb(v)
    local n = string.lower(v.Name)
    return n:find("web") or n:find("spider")
end

-- APPLY
local function apply(v)
    pcall(function()

        -- 🔥 HIDE WEB
        if v:IsA("BasePart") and isWeb(v) then
            v.LocalTransparencyModifier = 1
            v.CanCollide = false
        end

        if v:IsA("ParticleEmitter") and isWeb(v) then
            v.Enabled = false
        end

        if v:IsA("Trail") and isWeb(v) then
            v.Enabled = false
        end

        -- ⚡ ANTI LAG
        if v:IsA("ParticleEmitter") then
            v.Rate = math.min(v.Rate, 10)
        end

        if v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0.1)
        end

        if v:IsA("PointLight") or v:IsA("SpotLight") then
            v.Range = 8
            v.Brightness = 1
        end

        if v:IsA("BasePart") then
            v.CastShadow = false
            if v.Material == Enum.Material.Neon then
                v.Material = Enum.Material.Plastic
            end
        end

    end)
end

-- APPLY GLOBAL
local function enableAll()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
    end)

    for _, v in pairs(workspace:GetDescendants()) do
        apply(v)
    end
end

-- TOGGLE
button.MouseButton1Click:Connect(function()
    enabled = not enabled

    if enabled then
        button.Text = "Anti Lag: ON"
        enableAll()
    else
        button.Text = "Anti Lag: OFF"
        Lighting.GlobalShadows = true
    end
end)

-- HANDLE SPAWN BARU
workspace.DescendantAdded:Connect(function(v)
    if enabled then
        apply(v)
    end
end)