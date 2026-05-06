spawn(function()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local player = Players.LocalPlayer

    if not player then return end

    local states = {
        web = false,
        fps = false
    }

    -- UI
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "LagHub"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,220,0,120)
    frame.Position = UDim2.new(0,20,0,200)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

    local function makeBtn(text, y)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.new(1,-10,0,35)
        b.Position = UDim2.new(0,5,0,y)
        b.Text = text.." : OFF"
        b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        b.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
        return b
    end

    local webBtn = makeBtn("ANTI WEB (BRUTAL)",5)
    local fpsBtn = makeBtn("FPS BOOST",50)

    -- DRAG
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if i.UserInputType.Name=="MouseButton1" then
            dragging = true
            dragStart = i.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(i)
        if i.UserInputType.Name=="MouseButton1" then
            dragging = false
        end
    end)

    frame.InputChanged:Connect(function(i)
        if dragging and i.UserInputType.Name=="MouseMovement" then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(
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
        return n:find("web") or n:find("spider") or n:find("trap")
    end

    -- 🔥 BRUTAL WEB REMOVER
    local function nukeWeb(v)
        pcall(function()
            if isWeb(v) then
                v:Destroy()
                return
            end

            if v:IsA("ParticleEmitter") and isWeb(v.Parent.Name) then
                v:Destroy()
            end

            if v:IsA("Trail") and isWeb(v.Parent.Name) then
                v:Destroy()
            end
        end)
    end

    -- 🚀 FPS BOOST
    local function boost(v)
        pcall(function()
            if v:IsA("BasePart") then
                v.CastShadow = false
                if v.Material == Enum.Material.Neon then
                    v.Material = Enum.Material.Plastic
                end
            end

            if v:IsA("ParticleEmitter") then
                v.Rate = 5
            end

            if v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0.05)
            end

            if v:IsA("PointLight") or v:IsA("SpotLight") then
                v.Enabled = false
            end
        end)
    end

    local function refresh()
        for _,v in pairs(workspace:GetDescendants()) do
            if states.web then
                nukeWeb(v)
            end
            if states.fps then
                boost(v)
            end
        end
    end

    -- BUTTONS
    webBtn.MouseButton1Click:Connect(function()
        states.web = not states.web
        webBtn.Text = "ANTI WEB (BRUTAL) : "..(states.web and "ON" or "OFF")
        refresh()
    end)

    fpsBtn.MouseButton1Click:Connect(function()
        states.fps = not states.fps
        fpsBtn.Text = "FPS BOOST : "..(states.fps and "ON" or "OFF")

        if states.fps then
            Lighting.GlobalShadows = false
            settings().Rendering.QualityLevel = "Level01"
        else
            Lighting.GlobalShadows = true
        end

        refresh()
    end)

    -- AUTO HANDLE SPAWN
    workspace.DescendantAdded:Connect(function(v)
        if states.web then
            nukeWeb(v)
        end
        if states.fps then
            boost(v)
        end
    end)
end)