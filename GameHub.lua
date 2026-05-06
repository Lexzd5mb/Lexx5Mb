spawn(function()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local player = Players.LocalPlayer

    if not player then return end

    local states = {
        antilag = false,
        web = false,
        particle = false
    }

    -- UI
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "LagHub"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,200,0,150)
    frame.Position = UDim2.new(0,20,0,200)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

    local function makeButton(text, posY)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,0,posY)
        btn.Text = text.." : OFF"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
        return btn
    end

    local antiBtn = makeButton("Anti Lag",0)
    local webBtn = makeButton("Hide Web",40)
    local partBtn = makeButton("Low Particle",80)

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

    -- DETECT WEB
    local function isWeb(name)
        name = string.lower(name)
        return name:find("web") or name:find("spider")
    end

    -- APPLY
    local function apply(v)
        pcall(function()
            if states.web then
                if v:IsA("BasePart") and isWeb(v.Name) then
                    v.LocalTransparencyModifier = 1
                    v.CanCollide = false
                end
                if v:IsA("ParticleEmitter") and isWeb(v.Name) then
                    v.Enabled = false
                end
                if v:IsA("Trail") and isWeb(v.Name) then
                    v.Enabled = false
                end
            end

            if states.particle then
                if v:IsA("ParticleEmitter") then
                    v.Rate = 10
                end
                if v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0.1)
                end
            end

            if states.antilag then
                if v:IsA("BasePart") then
                    v.CastShadow = false
                    if v.Material == Enum.Material.Neon then
                        v.Material = Enum.Material.Plastic
                    end
                end
                if v:IsA("PointLight") or v:IsA("SpotLight") then
                    v.Range = 8
                    v.Brightness = 1
                end
            end
        end)
    end

    local function refresh()
        for _,v in pairs(workspace:GetDescendants()) do
            apply(v)
        end
    end

    -- BUTTONS
    antiBtn.MouseButton1Click:Connect(function()
        states.antilag = not states.antilag
        antiBtn.Text = "Anti Lag : "..(states.antilag and "ON" or "OFF")

        if states.antilag then
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = true
        end

        refresh()
    end)

    webBtn.MouseButton1Click:Connect(function()
        states.web = not states.web
        webBtn.Text = "Hide Web : "..(states.web and "ON" or "OFF")
        refresh()
    end)

    partBtn.MouseButton1Click:Connect(function()
        states.particle = not states.particle
        partBtn.Text = "Low Particle : "..(states.particle and "ON" or "OFF")
        refresh()
    end)

    workspace.DescendantAdded:Connect(function(v)
        apply(v)
    end)
end)