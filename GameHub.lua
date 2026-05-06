spawn(function()
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local player = Players.LocalPlayer

    if not player then return end

    local states = {
        web = false,
        fps = false,
        pet = false
    }

    -- UI
    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "LagHub"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0,240,0,180)
    frame.Position = UDim2.new(0,20,0,200)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

    -- TITLE
    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1,0,0,30)
    title.Text = "LAG HUB"
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1

    -- CLOSE BUTTON
    local close = Instance.new("TextButton", frame)
    close.Size = UDim2.new(0,30,0,30)
    close.Position = UDim2.new(1,-30,0,0)
    close.Text = "X"
    close.BackgroundColor3 = Color3.fromRGB(150,40,40)
    close.TextColor3 = Color3.new(1,1,1)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

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

    local webBtn = makeBtn("ANTI WEB",35)
    local fpsBtn = makeBtn("FPS BOOST",75)
    local petBtn = makeBtn("HIDE PET (ALL)",115)

    -- 🔥 DRAG FIX (WORKING)
    local UIS = game:GetService("UserInputService")
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- QUEUE
    local queue = {}
    workspace.DescendantAdded:Connect(function(v)
        table.insert(queue, v)
    end)

    -- LOOP
    task.spawn(function()
        while true do

            for i = 1, math.min(#queue, 60) do
                local v = table.remove(queue, 1)

                if v then
                    pcall(function()

                        local name = string.lower(v.Name)

                        -- 🕸️ ANTI WEB
                        if states.web then
                            if name:find("web") or name:find("spider") or name:find("trap") then
                                v:Destroy()
                                return
                            end

                            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                                v.Enabled = false
                            end
                        end

                        -- 🚀 FPS BOOST (LEBIH KERAS)
                        if states.fps then
                            if v:IsA("BasePart") then
                                v.CastShadow = false
                                v.Material = Enum.Material.Plastic
                            end

                            if v:IsA("Decal") or v:IsA("Texture") then
                                v.Transparency = 1
                            end

                            if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                                v.Enabled = false
                            end

                            if v:IsA("PointLight") or v:IsA("SpotLight") then
                                v.Enabled = false
                            end
                        end

                        -- 🐾 HIDE PET (GLOBAL FIX)
                        if states.pet then
                            if v:IsA("Model") then
                                local n = string.lower(v.Name)

                                if n:find("pet") or n:find("spider") then
                                    for _, part in pairs(v:GetDescendants()) do
                                        if part:IsA("BasePart") then
                                            part.LocalTransparencyModifier = 1
                                            part.CanCollide = false
                                        end

                                        if part:IsA("ParticleEmitter") or part:IsA("Trail") then
                                            part.Enabled = false
                                        end
                                    end
                                end
                            end
                        end

                    end)
                end
            end

            task.wait(0.15)
        end
    end)

    -- BUTTONS
    webBtn.MouseButton1Click:Connect(function()
        states.web = not states.web
        webBtn.Text = "ANTI WEB : "..(states.web and "ON" or "OFF")
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

    petBtn.MouseButton1Click:Connect(function()
        states.pet = not states.pet
        petBtn.Text = "HIDE PET : "..(states.pet and "ON" or "OFF")
    end)
end)