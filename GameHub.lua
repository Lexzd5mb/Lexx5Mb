spawn(function()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local player = Players.LocalPlayer

    if not player then return end

    local states = {
        web = false,
        fps = false
    }

    -- UI (punya lo, ga diubah)
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

    -- DRAG (tetap)
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

    -- DETEKSI
    local function isWeb(v)
        local n = string.lower(v.Name)
        return n:find("web") or n:find("spider") or n:find("trap")
    end

    local function isNear(v)
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return false end

        local root = char.HumanoidRootPart
        return (v.Position - root.Position).Magnitude < 40
    end

    -- QUEUE SYSTEM (BIAR GA NGELAG)
    local queue = {}

    workspace.DescendantAdded:Connect(function(v)
        table.insert(queue, v)
    end)

    -- PROCESS LOOP (di throttle)
    task.spawn(function()
        while true do
            for i = 1, math.min(#queue, 30) do
                local v = table.remove(queue, 1)

                if v then
                    pcall(function()

                        -- 🕸️ ANTI WEB (fokus dekat player)
                        if states.web and v:IsA("BasePart") and isNear(v) then
                            if isWeb(v) or (v.Transparency > 0.2 and v.Size.Magnitude < 6) then
                                v:Destroy()
                                return
                            end
                        end

                        -- 🚀 FPS BOOST
                        if states.fps then
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
                        end

                    end)
                end
            end

            task.wait(0.1) -- 🔥 throttle biar CPU turun
        end
    end)

    -- BUTTON
    webBtn.MouseButton1Click:Connect(function()
        states.web = not states.web
        webBtn.Text = "ANTI WEB (BRUTAL) : "..(states.web and "ON" or "OFF")
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
    end)
end)