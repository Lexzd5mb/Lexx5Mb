-- ==============================================
--   AUTO COLLECT + VARIANT/MUTASI DETECTOR
--       GROW A GARDEN (Roblox) - v2
-- ==============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ==============================================
-- KONFIGURASI
-- ==============================================
local CONFIG = {
    AutoCollect       = true,
    TeleportMode      = false,
    Delay             = 0.1,
    DebugMode         = false,

    -- Prioritas: jika true, ambil mutasi duluan walaupun lebih jauh
    PrioritizeMutation = false,

    -- Filter: hanya ambil jika ada mutasi? (false = ambil semua)
    OnlyMutation      = true,
}

-- ==============================================
-- DATA BUAH & VARIANT/MUTASI
-- (Berdasarkan data Grow a Garden Wiki)
-- ==============================================

-- Semua nama buah/tanaman di GAG
local FRUIT_NAMES = {
    -- Common
    "tomato",
    -- Uncommon
    "blueberry",
  -- General fallback
    "fruit","plant","crop","flower","seed","harvest",
}

-- Semua variant/mutasi yang ada di GAG
local MUTATIONS = {
    -- Tier warna dasar
    { name = "Rainbow",   color = Color3.fromRGB(255, 100, 255), priority = 10 },
    { name = "Golden",    color = Color3.fromRGB(255, 215, 0),   priority = 9  },
    { name = "silver",     color = Color3.fromRGB(192, 192, 192),  priority = 9  },
}

-- Buat set untuk lookup cepat
local MUTATION_LOOKUP = {}
for _, m in ipairs(MUTATIONS) do
    MUTATION_LOOKUP[m.name:lower()] = m
end

local FRUIT_LOOKUP = {}
for _, f in ipairs(FRUIT_NAMES) do
    FRUIT_LOOKUP[f:lower()] = true
end

-- ==============================================
-- LOG
-- ==============================================
local function Log(msg)
    if CONFIG.DebugMode then print("[GAG] " .. tostring(msg)) end
end

-- ==============================================
-- DETEKSI MUTASI DARI NAMA OBJEK
-- Format nama di GAG biasanya: "Golden Carrot", "Rainbow Strawberry", dll
-- ==============================================
local function DetectMutation(name)
    local lower = name:lower()

    if lower:find("rainbow") then
        return {name = "Rainbow", priority = 10}
    elseif lower:find("golden") then
        return {name = "Golden", priority = 9}
    elseif lower:find("silver") then
        return {name = "Silver", priority = 8}
    end

    return nil
end

local function IsFruit(name)
    local lower = name:lower()
    for fruitName, _ in pairs(FRUIT_LOOKUP) do
        if lower:find(fruitName) then return true end
    end
    return false
end

-- ==============================================
-- INTERAKSI
-- ==============================================
local function SafeTeleport(pos)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
        task.wait(0.15)
    end
end

local function TryInteract(obj)
    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled then
            fireproximityprompt(v)
            return true
        end
        if v:IsA("ClickDetector") then
            fireclickdetector(v)
            return true
        end
    end
    -- Coba remote
    local remoteNames = {"HarvestCrop","Harvest","CollectFruit","PickFruit","Collect"}
    for _, rName in ipairs(remoteNames) do
        local r = ReplicatedStorage:FindFirstChild(rName, true)
        if r and r:IsA("RemoteEvent") then
            r:FireServer(obj)
            return true
        end
    end
    return false
end

-- ==============================================
-- SCAN WORKSPACE
-- ==============================================
local function ScanTargets()
    local results = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name
        local mutation = DetectMutation(name)
        local isFruit = IsFruit(name)

        -- Hanya proses kalau buah atau ada mutasi
        if not (isFruit or mutation) then continue end

        -- Filter OnlyMutation
        if CONFIG.OnlyMutation and not mutation then continue end

        local pos = nil
        if obj:IsA("BasePart") then
            pos = obj.Position
        elseif obj:IsA("Model") then
            if obj.PrimaryPart then
                pos = obj.PrimaryPart.Position
            else
                for _, p in ipairs(obj:GetDescendants()) do
                    if p:IsA("BasePart") then pos = p.Position break end
                end
            end
        elseif obj:IsA("ProximityPrompt") and obj.Enabled then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                pos = parent.Position
                -- Override nama dengan parent
                name = parent.Name
                mutation = DetectMutation(name)
                isFruit = IsFruit(name)
                obj = parent
            end
        end

        if not pos then continue end

        local dist = (HumanoidRootPart.Position - pos).Magnitude

        -- Cek duplikat
        local dup = false
        for _, r in ipairs(results) do
            if r.object == obj then dup = true break end
        end
        if dup then continue end

        table.insert(results, {
            object   = obj,
            name     = name,
            position = pos,
            distance = dist,
            mutation = mutation,
            priority = mutation and mutation.priority or 0,
        })
    end

    -- Sort: mutasi prioritas tinggi dulu, lalu jarak
    table.sort(results, function(a, b)
        if CONFIG.PrioritizeMutation then
            if a.priority ~= b.priority then
                return a.priority > b.priority
            end
        end
        return a.distance < b.distance
    end)

    return results
end

-- ==============================================
-- GUI
-- ==============================================
local GUI, StatusLabel, MutationLog, ToggleBtn

local function CreateGUI()
    if LocalPlayer.PlayerGui:FindFirstChild("GAG_GUI2") then
        LocalPlayer.PlayerGui.GAG_GUI2:Destroy()
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "GAG_GUI2"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = LocalPlayer.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 155)
    frame.Position = UDim2.new(0, 12, 0, 12)
    frame.BackgroundColor3 = Color3.fromRGB(12, 22, 12)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(80, 200, 80)
    stroke.Thickness = 1.5

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 28)
    title.Position = UDim2.new(0, 0, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "🌱 Grow a Garden Auto v2"
    title.TextColor3 = Color3.fromRGB(120, 255, 100)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -10, 0, 18)
    status.Position = UDim2.new(0, 5, 0, 35)
    status.BackgroundTransparency = 1
    status.Text = "Status: AKTIF ✅"
    status.TextColor3 = Color3.fromRGB(180, 255, 180)
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    -- Mutation log
    local mutlog = Instance.new("TextLabel")
    mutlog.Name = "MutLog"
    mutlog.Size = UDim2.new(1, -10, 0, 50)
    mutlog.Position = UDim2.new(0, 5, 0, 55)
    mutlog.BackgroundColor3 = Color3.fromRGB(5, 15, 5)
    mutlog.BackgroundTransparency = 0.3
    mutlog.TextColor3 = Color3.fromRGB(255, 230, 100)
    mutlog.Text = "🔍 Menunggu mutasi..."
    mutlog.TextScaled = true
    mutlog.Font = Enum.Font.Gotham
    mutlog.TextWrapped = true
    mutlog.Parent = frame
    Instance.new("UICorner", mutlog).CornerRadius = UDim.new(0, 6)

    -- Toggle
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, 115)
    btn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "ON  |  [F] Toggle"
    btn.Font = Enum.Font.GothamSemibold
    btn.TextScaled = true
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    return status, mutlog, btn
end

StatusLabel, MutationLog, ToggleBtn = CreateGUI()

local lastMutationMsg = "🔍 Menunggu mutasi..."

local function UpdateGUI(mutMsg)
    if CONFIG.AutoCollect then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 70)
        ToggleBtn.Text = "🟢 AUTO COLLECT ON"
        StatusLabel.Text = "Status: AKTIF ✅"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "🔴 AUTO COLLECT OFF"
        StatusLabel.Text = "Status: NONAKTIF ❌"
    end

    if mutMsg then
        lastMutationMsg = mutMsg
    end

    MutationLog.Text = lastMutationMsg
end

local function Toggle()
    CONFIG.AutoCollect = not CONFIG.AutoCollect
    UpdateGUI()
    print("[GAG] Auto Collect: " .. (CONFIG.AutoCollect and "ON ✅" or "OFF ❌"))
end

ToggleBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoCollect = not CONFIG.AutoCollect
    UpdateGUI()
end)
-- ==============================================
-- MAIN LOOP
-- ==============================================
print("[GAG] ✅ Script v2 aktif! Tekan F untuk toggle.")
print("[GAG] 🌟 Deteksi mutasi: " .. #MUTATIONS .. " tipe")

task.spawn(function()
    while true do
        task.wait(CONFIG.Delay)
        if not CONFIG.AutoCollect then continue end

        Character = LocalPlayer.Character
        if not Character then continue end
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        Humanoid = Character:FindFirstChild("Humanoid")
        if not HumanoidRootPart or not Humanoid or Humanoid.Health <= 0 then continue end

        local targets = ScanTargets()
        Log("Target: " .. #targets)

        local mutFound = {}
        for _, t in ipairs(targets) do
            if t.mutation then
                table.insert(mutFound, t.mutation.name .. " " .. t.name)
            end
        end

        -- Update GUI mutasi
        if #mutFound > 0 then
            local msg = "🌟 Mutasi: " .. table.concat(mutFound, ", ")
            UpdateGUI(msg)
            print("[GAG] " .. msg)
        else
            UpdateGUI("🔍 Tidak ada mutasi terdeteksi")
        end

        -- Harvest semua
        for _, target in ipairs(targets) do
            if not target.object or not target.object.Parent then continue end

            if not CONFIG.TeleportMode then
Humanoid:MoveTo(target.position)
Humanoid.MoveToFinished:Wait()
else
    SafeTeleport(target.position)
end

            local ok = TryInteract(target.object)
            if ok then
                local label = target.mutation and ("⭐ [" .. target.mutation.name .. "] ") or ""
                Log("Harvested: " .. label .. target.name)
            end

            task.wait(0.1)
        end
    end
end)
