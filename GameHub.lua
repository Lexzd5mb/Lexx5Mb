--============================================================
-- GARDEN HUB
-- ALL-IN-ONE SCRIPT
--============================================================

--============================================================
-- SERVICES
--============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Backpack = LocalPlayer:WaitForChild("Backpack")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Farms = Workspace:WaitForChild("Farm")

local Leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Sheckles = Leaderstats:WaitForChild("Sheckles")


--============================================================
-- CONFIG
--============================================================

local Config = {
    AutoPlant = false,
    AutoPlantRandom = false,

    AutoHarvest = false,

    AutoBuy = false,

    AutoSell = false,
    SellThreshold = 15,

    AutoWalk = false,
    AutoWalkRandom = true,
    NoClip = false,
    AutoWalkDelay = 5,

    AutoUnequip = true,
    MaxAge = 10,
}


--============================================================
-- DATA
--============================================================

local SeedStock = {}
local OwnedSeeds = {}

local SelectedSeed = nil
local SelectedBuySeed = nil

local Pets = {}
local SelectedPet = nil

local UUIDs = {}

local IsSelling = false
local Minimized = false


--============================================================
-- UTILITY
--============================================================

local function Notify(text)
    local notification = Instance.new("TextLabel")

    notification.Size = UDim2.fromOffset(300, 45)
    notification.Position = UDim2.new(1, -320, 1, -70)
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    notification.BorderSizePixel = 0

    notification.Text = text
    notification.TextColor3 = Color3.new(1,1,1)
    notification.TextSize = 14
    notification.Font = Enum.Font.GothamMedium

    notification.Parent = MainGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notification

    task.delay(2.5, function()
        if notification then
            notification:Destroy()
        end
    end)
end


local function GetCharacter()
    return LocalPlayer.Character
        or LocalPlayer.CharacterAdded:Wait()
end


local function GetHumanoid()
    local Character = GetCharacter()
    return Character:FindFirstChildOfClass("Humanoid")
end


--============================================================
-- FARM
--============================================================

local function GetFarms()
    return Farms:GetChildren()
end


local function GetFarmOwner(Farm)
    local Important = Farm:FindFirstChild("Important")
    if not Important then return nil end

    local Data = Important:FindFirstChild("Data")
    if not Data then return nil end

    local Owner = Data:FindFirstChild("Owner")

    return Owner and Owner.Value
end


local function GetFarm(PlayerName)
    for _, Farm in ipairs(GetFarms()) do
        if GetFarmOwner(Farm) == PlayerName then
            return Farm
        end
    end
end


local MyFarm = GetFarm(LocalPlayer.Name)

if not MyFarm then
    warn("[GardenHub] Farm tidak ditemukan.")
end


local MyImportant =
    MyFarm and MyFarm:FindFirstChild("Important")


local PlantLocations =
    MyImportant and MyImportant:FindFirstChild("Plant_Locations")


local PlantsPhysical =
    MyImportant and MyImportant:FindFirstChild("Plants_Physical")


local function GetArea(Base)
    local Center = Base:GetPivot()
    local Size = Base.Size

    local X1 = math.ceil(
        Center.X - (Size.X / 2)
    )

    local Z1 = math.ceil(
        Center.Z - (Size.Z / 2)
    )

    local X2 = math.floor(
        Center.X + (Size.X / 2)
    )

    local Z2 = math.floor(
        Center.Z + (Size.Z / 2)
    )

    return X1, Z1, X2, Z2
end


local function GetRandomFarmPoint()

    if not PlantLocations then
        return nil
    end

    local Lands = PlantLocations:GetChildren()

    if #Lands == 0 then
        return nil
    end

    local Land =
        Lands[math.random(1, #Lands)]

    local X1, Z1, X2, Z2 =
        GetArea(Land)

    local X =
        math.random(X1, X2)

    local Z =
        math.random(Z1, Z2)

    return Vector3.new(X, 4, Z)
end


--============================================================
-- SEED SYSTEM
--============================================================

local function GetSeedInfo(Tool)

    local PlantName =
        Tool:FindFirstChild("Plant_Name")

    local Count =
        Tool:FindFirstChild("Numbers")

    if not PlantName or not Count then
        return nil
    end

    return PlantName.Value, Count.Value
end


local function CollectSeeds(Parent)

    for _, Tool in ipairs(Parent:GetChildren()) do

        local Name, Count =
            GetSeedInfo(Tool)

        if Name then

            OwnedSeeds[Name] = {
                Count = Count,
                Tool = Tool
            }

        end

    end

end


local function RefreshOwnedSeeds()

    table.clear(OwnedSeeds)

    CollectSeeds(Backpack)

    local Character = LocalPlayer.Character

    if Character then
        CollectSeeds(Character)
    end

end


local function BuySeed(Seed)

    if not Seed then
        return
    end

    local Remote =
        GameEvents:FindFirstChild("BuySeedStock")

    if Remote then
        Remote:FireServer(Seed)
    end

end


local function GetSeedStock()

    local SeedShop =
        PlayerGui:FindFirstChild("Seed_Shop")

    if not SeedShop then
        return
    end

    local Blueberry =
        SeedShop:FindFirstChild("Blueberry", true)

    if not Blueberry then
        return
    end

    local Items = Blueberry.Parent

    table.clear(SeedStock)

    for _, Item in ipairs(Items:GetChildren()) do

        local MainFrame =
            Item:FindFirstChild("Main_Frame")

        if not MainFrame then
            continue
        end

        local StockText =
            MainFrame:FindFirstChild("Stock_Text")

        if not StockText then
            continue
        end

        local Count =
            tonumber(
                StockText.Text:match("%d+")
            )

        if Count then
            SeedStock[Item.Name] = Count
        end

    end

end


local function BuyAllSelected()

    if not SelectedBuySeed then
        return
    end

    local Stock =
        SeedStock[SelectedBuySeed]

    if not Stock or Stock <= 0 then
        Notify("Seed tidak tersedia")
        return
    end

    for i = 1, Stock do

        BuySeed(SelectedBuySeed)

        task.wait(0.05)

    end

    Notify("Bought: " .. SelectedBuySeed)

end


--============================================================
-- PLANT
--============================================================

local function EquipTool(Tool)

    if not Tool then
        return
    end

    local Character =
        GetCharacter()

    if Tool.Parent == Backpack then

        local Humanoid =
            Character:FindFirstChildOfClass("Humanoid")

        if Humanoid then
            Humanoid:EquipTool(Tool)
        end

    end

end


local function Plant(Position, Seed)

    local Remote =
        GameEvents:FindFirstChild("Plant_RE")

    if not Remote then
        return
    end

    Remote:FireServer(Position, Seed)

    task.wait(0.25)

end


local function AutoPlantOnce()

    if not SelectedSeed then
        Notify("Pilih seed dulu")
        return
    end

    RefreshOwnedSeeds()

    local Data =
        OwnedSeeds[SelectedSeed]

    if not Data then
        Notify("Seed tidak ada di inventory")
        return
    end

    if Data.Count <= 0 then
        return
    end

    EquipTool(Data.Tool)

    if Config.AutoPlantRandom then

        for i = 1, Data.Count do

            local Position =
                GetRandomFarmPoint()

            if Position then
                Plant(Position, SelectedSeed)
            end

        end

        return
    end


    if not PlantLocations then
        return
    end

    local Base =
        PlantLocations:FindFirstChildOfClass("Part")

    if not Base then
        return
    end

    local X1, Z1, X2, Z2 =
        GetArea(Base)

    local Planted = 0

    for X = X1, X2 do

        for Z = Z1, Z2 do

            if Planted >= Data.Count then
                return
            end

            local Position =
                Vector3.new(
                    X,
                    0.13,
                    Z
                )

            Plant(
                Position,
                SelectedSeed
            )

            Planted += 1

        end

    end

end


--============================================================
-- HARVEST
--============================================================

local function CanHarvest(Plant)

    local Prompt =
        Plant:FindFirstChild(
            "ProximityPrompt",
            true
        )

    if not Prompt then
        return false
    end

    return Prompt.Enabled
end


local function HarvestPlant(Plant)

    local Prompt =
        Plant:FindFirstChild(
            "ProximityPrompt",
            true
        )

    if not Prompt then
        return
    end

    if not Prompt.Enabled then
        return
    end

    fireproximityprompt(Prompt)

end


local function CollectHarvestable(
    Parent,
    Result,
    IgnoreDistance
)

    if not Parent then
        return
    end

    local Character =
        GetCharacter()

    local PlayerPosition =
        Character:GetPivot().Position


    for _, Plant in ipairs(
        Parent:GetChildren()
    ) do

        local Fruits =
            Plant:FindFirstChild("Fruits")

        if Fruits then

            CollectHarvestable(
                Fruits,
                Result,
                IgnoreDistance
            )

        end


        local Success, Position =
            pcall(function()
                return Plant:GetPivot().Position
            end)

        if not Success then
            continue
        end


        local Distance =
            (PlayerPosition - Position).Magnitude

        if not IgnoreDistance
            and Distance > 15 then

            continue

        end


        local Variant =
            Plant:FindFirstChild("Variant")

        if Variant
            and Variant:IsA("StringValue") then

            if Variant.Value == "Normal"
                and false then

                continue

            end

        end


        if CanHarvest(Plant) then

            table.insert(
                Result,
                Plant
            )

        end

    end

end


local function GetHarvestablePlants(
    IgnoreDistance
)

    local Result = {}

    CollectHarvestable(
        PlantsPhysical,
        Result,
        IgnoreDistance
    )

    return Result

end


local function HarvestAll()

    local Plants =
        GetHarvestablePlants(false)

    for _, Plant in ipairs(Plants) do

        HarvestPlant(Plant)

        task.wait(0.03)

    end

end


--============================================================
-- SELL
--============================================================

local function GetInvCrops()

    local Crops = {}

    local function Scan(Parent)

        if not Parent then
            return
        end

        for _, Tool in ipairs(
            Parent:GetChildren()
        ) do

            if Tool:FindFirstChild(
                "Item_String"
            ) then

                table.insert(
                    Crops,
                    Tool
                )

            end

        end

    end

    Scan(Backpack)
    Scan(LocalPlayer.Character)

    return Crops

end


local function SellInventory()

    if IsSelling then
        return
    end

    IsSelling = true

    local Character =
        GetCharacter()

    local Previous =
        Character:GetPivot()

    local PreviousSheckles =
        Sheckles.Value


    local SellPosition =
        CFrame.new(
            62,
            4,
            -26
        )

    Character:PivotTo(
        SellPosition
    )


    local Remote =
        GameEvents:FindFirstChild(
            "Sell_Inventory"
        )

    if Remote then

        while task.wait(0.1) do

            if Sheckles.Value
                ~= PreviousSheckles then

                break

            end

            Remote:FireServer()

        end

    end


    Character:PivotTo(
        Previous
    )

    IsSelling = false

end


--============================================================
-- PET SYSTEM
--============================================================

local function GetPetAge(Object)

    if not Object then
        return nil
    end

    local Age =
        Object:FindFirstChild(
            "Age",
            true
        )

    if not Age then
        return nil
    end

    if Age:IsA("IntValue")
        or Age:IsA("NumberValue") then

        return tonumber(
            Age.Value
        )

    end


    if Age:IsA("StringValue") then

        return tonumber(
            Age.Value
        )

    end


    local Value =
        Age:GetAttribute("Value")

    if Value ~= nil then
        return tonumber(Value)
    end


    return tonumber(Age.Name)

end


local function GetPetTool(Object)

    local Current =
        Object

    while Current
        and Current ~= Backpack do

        if Current:IsA("Tool") then
            return Current
        end

        Current =
            Current.Parent

    end

end


local function IsPetToolServer(Object)

    return string.find(
        string.lower(Object.Name),
        "pettoolserver",
        1,
        true
    ) ~= nil

end


local function AddPet(Object)

    if Pets[Object] then
        return
    end

    local Tool =
        GetPetTool(Object)

    local Data = {
        Object = Object,
        Tool = Tool
    }

    Pets[Object] = Data

    Notify(
        "Pet detected: "
        .. Object.Name
    )

end


local function ScanPets()

    table.clear(Pets)

    for _, Object in ipairs(
        Backpack:GetDescendants()
    ) do

        if IsPetToolServer(Object) then
            AddPet(Object)
        end

    end

end


local function EquipPet(Data)

    if not Data then
        return
    end

    local Tool =
        Data.Tool

    if not Tool then
        Notify("Tool pet tidak ditemukan")
        return
    end

    local Humanoid =
        GetHumanoid()

    if Humanoid then

        Humanoid:EquipTool(
            Tool
        )

        Notify(
            "Equipped: "
            .. Tool.Name
        )

    end

end


local function AutoUnequipPets()

    if not Config.AutoUnequip then
        return
    end

    local Character =
        LocalPlayer.Character

    if not Character then
        return
    end

    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not Humanoid then
        return
    end


    for _, Data in pairs(Pets) do

        local Tool =
            Data.Tool

        if Tool
            and Tool.Parent == Character then

            local Age =
                GetPetAge(Tool)

            if Age
                and Age >= Config.MaxAge then

                Humanoid:UnequipTools()

            end

        end

    end

end


--============================================================
-- UUID SCANNER
--============================================================

local function IsUUID(Name)

    if not Name:match(
        "^%b{}$"
    ) then
        return false
    end

    return Name:match(
        "^%{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x%}$"
    ) ~= nil

end


local function AddUUID(
    UUID,
    PetMover
)

    if not IsUUID(UUID) then
        return
    end

    if UUIDs[UUID] then
        return
    end

    UUIDs[UUID] =
        PetMover:GetFullName()

end


local function ScanPetMover(PetMover)

    for _, Child in ipairs(
        PetMover:GetChildren()
    ) do

        AddUUID(
            Child.Name,
            PetMover
        )

    end

end


local function ScanAllUUID()

    table.clear(UUIDs)

    for _, Object in ipairs(
        Workspace:GetDescendants()
    ) do

        if Object.Name == "PetMover" then

            ScanPetMover(
                Object
            )

        end

    end

end


-- Live UUID scanner

Workspace.DescendantAdded:Connect(
    function(Object)

        if Object.Name == "PetMover" then

            ScanPetMover(
                Object
            )

            return

        end


        local Parent =
            Object.Parent

        if Parent
            and Parent.Name == "PetMover" then

            AddUUID(
                Object.Name,
                Parent
            )

        end

    end
)


-- Live Pet scanner

Backpack.DescendantAdded:Connect(
    function(Object)

        if IsPetToolServer(Object) then

            task.wait()

            AddPet(Object)

        end

    end
)


--============================================================
-- MOVEMENT
--============================================================

local function AutoWalk()

    if IsSelling then
        return
    end

    local Humanoid =
        GetHumanoid()

    if not Humanoid then
        return
    end

    local Plants =
        GetHarvestablePlants(true)


    if Config.AutoWalkRandom
        and (
            #Plants == 0
            or math.random(1,3) == 2
        ) then

        local Position =
            GetRandomFarmPoint()

        if Position then
            Humanoid:MoveTo(
                Position
            )
        end

        return
    end


    for _, Plant in ipairs(
        Plants
    ) do

        local Success,
            Position =
            pcall(function()
                return Plant:GetPivot().Position
            end)

        if Success then

            Humanoid:MoveTo(
                Position
            )

            task.wait(
                Config.AutoWalkDelay
            )

        end

    end

end


RunService.Stepped:Connect(
    function()

        if not Config.NoClip then
            return
        end

        local Character =
            LocalPlayer.Character

        if not Character then
            return
        end

        for _, Part in ipairs(
            Character:GetDescendants()
        ) do

            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end

        end

    end
)


--============================================================
-- GUI
--============================================================

local OldGui =
    PlayerGui:FindFirstChild(
        "GardenHub"
    )

if OldGui then
    OldGui:Destroy()
end


MainGui = Instance.new("ScreenGui")
MainGui.Name = "GardenHub"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

MainGui.Parent = PlayerGui


--============================================================
-- COLORS
--============================================================

local BG =
    Color3.fromRGB(
        16, 17, 21
    )

local PANEL =
    Color3.fromRGB(
        22, 24, 29
    )

local PANEL2 =
    Color3.fromRGB(
        29, 31, 38
    )

local ACCENT =
    Color3.fromRGB(
        82, 170, 75
    )

local TEXT =
    Color3.fromRGB(
        240, 240, 245
    )

local SUBTEXT =
    Color3.fromRGB(
        155, 158, 168
    )


--============================================================
-- MAIN WINDOW
--============================================================

local Window =
    Instance.new("Frame")

Window.Size =
    UDim2.fromOffset(
        720,
        470
    )

Window.Position =
    UDim2.new(
        0.5,
        -360,
        0.5,
        -235
    )

Window.BackgroundColor3 =
    BG

Window.BorderSizePixel = 0

Window.Parent =
    MainGui


local WindowCorner =
    Instance.new("UICorner")

WindowCorner.CornerRadius =
    UDim.new(0, 14)

WindowCorner.Parent =
    Window


--============================================================
-- TOPBAR
--============================================================

local Topbar =
    Instance.new("Frame")

Topbar.Size =
    UDim2.new(
        1,
        0,
        0,
        55
    )

Topbar.BackgroundColor3 =
    PANEL

Topbar.BorderSizePixel = 0

Topbar.Parent =
    Window


local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.fromOffset(
        300,
        55
    )

Title.Position =
    UDim2.fromOffset(
        18,
        0
    )

Title.BackgroundTransparency = 1

Title.Text =
    "GARDEN HUB"

Title.TextColor3 =
    TEXT

Title.TextSize = 20

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    Topbar


local Status =
    Instance.new("TextLabel")

Status.Size =
    UDim2.fromOffset(
        150,
        55
    )

Status.Position =
    UDim2.fromOffset(
        300,
        0
    )

Status.BackgroundTransparency = 1

Status.Text =
    "● ONLINE"

Status.TextColor3 =
    ACCENT

Status.TextSize = 12

Status.Font =
    Enum.Font.GothamMedium

Status.Parent =
    Topbar


--============================================================
-- MINIMIZE
--============================================================

local Minimize =
    Instance.new("TextButton")

Minimize.Size =
    UDim2.fromOffset(
        40,
        40
    )

Minimize.Position =
    UDim2.new(
        1,
        -90,
        0,
        7
    )

Minimize.BackgroundColor3 =
    PANEL2

Minimize.Text =
    "—"

Minimize.TextColor3 =
    TEXT

Minimize.TextSize = 20

Minimize.Font =
    Enum.Font.GothamBold

Minimize.Parent =
    Topbar


local Close =
    Instance.new("TextButton")

Close.Size =
    UDim2.fromOffset(
        40,
        40
    )

Close.Position =
    UDim2.new(
        1,
        -45,
        0,
        7
    )

Close.BackgroundColor3 =
    Color3.fromRGB(
        150,
        45,
        45
    )

Close.Text =
    "×"

Close.TextColor3 =
    TEXT

Close.TextSize = 20

Close.Font =
    Enum.Font.GothamBold

Close.Parent =
    Topbar


--============================================================
-- SIDEBAR
--============================================================

local Sidebar =
    Instance.new("Frame")

Sidebar.Size =
    UDim2.new(
        0,
        145,
        1,
        -55
    )

Sidebar.Position =
    UDim2.fromOffset(
        0,
        55
    )

Sidebar.BackgroundColor3 =
    PANEL

Sidebar.BorderSizePixel = 0

Sidebar.Parent =
    Window


local SideLayout =
    Instance.new("UIListLayout")

SideLayout.Padding =
    UDim.new(
        0,
        5
    )

SideLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

SideLayout.Parent =
    Sidebar


local SidePadding =
    Instance.new("UIPadding")

SidePadding.PaddingTop =
    UDim.new(
        0,
        12
    )

SidePadding.PaddingLeft =
    UDim.new(
        0,
        8
    )

SidePadding.PaddingRight =
    UDim.new(
        0,
        8
    )

SidePadding.Parent =
    Sidebar


--============================================================
-- CONTENT
--============================================================

local Content =
    Instance.new("Frame")

Content.Size =
    UDim2.new(
        1,
        -145,
        1,
        -55
    )

Content.Position =
    UDim2.fromOffset(
        145,
        55
    )

Content.BackgroundColor3 =
    BG

Content.BorderSizePixel = 0

Content.Parent =
    Window


--============================================================
-- TAB SYSTEM
--============================================================

local Tabs = {}
local TabButtons = {}


local function CreateTab(Name, Icon)

    local Button =
        Instance.new("TextButton")

    Button.Size =
        UDim2.new(
            1,
            0,
            0,
            40
        )

    Button.BackgroundColor3 =
        PANEL

    Button.Text =
        Icon .. "  " .. Name

    Button.TextColor3 =
        SUBTEXT

    Button.TextSize = 13

    Button.Font =
        Enum.Font.GothamMedium

    Button.AutoButtonColor = false

    Button.Parent =
        Sidebar


    local Page =
        Instance.new("ScrollingFrame")

    Page.Size =
        UDim2.new(
            1,
            -30,
            1,
            -30
        )

    Page.Position =
        UDim2.fromOffset(
            15,
            15
        )

    Page.BackgroundTransparency = 1

    Page.BorderSizePixel = 0

    Page.ScrollBarThickness = 3

    Page.Visible = false

    Page.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    Page.Parent =
        Content


    local Layout =
        Instance.new("UIListLayout")

    Layout.Padding =
        UDim.new(
            0,
            8
        )

    Layout.Parent =
        Page


    Layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(function()

        Page.CanvasSize =
            UDim2.fromOffset(
                0,
                Layout.AbsoluteContentSize.Y
                + 20
            )

    end)


    Tabs[Name] = Page
    TabButtons[Name] = Button


    Button.MouseButton1Click:Connect(
        function()

            for TabName, Frame in pairs(
                Tabs
            ) do

                Frame.Visible =
                    TabName == Name

                TabButtons[TabName]
                    .TextColor3 =
                    TabName == Name
                    and TEXT
                    or SUBTEXT

                TabButtons[TabName]
                    .BackgroundColor3 =
                    TabName == Name
                    and PANEL2
                    or PANEL

            end

        end
    )


    return Page

end


local function AddLabel(
    Parent,
    Text
)

    local Label =
        Instance.new("TextLabel")

    Label.Size =
        UDim2.new(
            1,
            0,
            0,
            32
        )

    Label.BackgroundTransparency =
        1

    Label.Text =
        Text

    Label.TextColor3 =
        SUBTEXT

    Label.TextSize =
        13

    Label.Font =
        Enum.Font.GothamMedium

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Parent =
        Parent

    return Label

end


local function AddButton(
    Parent,
    Text,
    Callback
)

    local Button =
        Instance.new("TextButton")

    Button.Size =
        UDim2.new(
            1,
            0,
            0,
            40
        )

    Button.BackgroundColor3 =
        PANEL2

    Button.Text =
        Text

    Button.TextColor3 =
        TEXT

    Button.TextSize =
        13

    Button.Font =
        Enum.Font.GothamMedium

    Button.AutoButtonColor = false

    Button.Parent =
        Parent


    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            8
        )

    Corner.Parent =
        Button


    Button.MouseButton1Click:Connect(
        Callback
    )


    return Button

end


local function AddToggle(
    Parent,
    Text,
    Default,
    Callback
)

    local Value =
        Default

    local Button =
        AddButton(
            Parent,
            "",
            function()

                Value =
                    not Value

                Callback(Value)

                Button.Text =
                    Text
                    .. "  ["
                    .. (
                        Value
                        and "ON"
                        or "OFF"
                    )
                    .. "]"

                Button.BackgroundColor3 =
                    Value
                    and Color3.fromRGB(
                        45,
                        95,
                        45
                    )
                    or PANEL2

            end
        )


    Button.Text =
        Text
        .. "  ["
        .. (
            Value
            and "ON"
            or "OFF"
        )
        .. "]"


    Button.BackgroundColor3 =
        Value
        and Color3.fromRGB(
            45,
            95,
            45
        )
        or PANEL2


    return Button

end


--============================================================
-- CREATE TABS
--============================================================

local HomeTab =
    CreateTab(
        "Home",
        "⌂"
    )

local FarmTab =
    CreateTab(
        "Farm",
        "🌱"
    )

local ShopTab =
    CreateTab(
        "Shop",
        "🛒"
    )

local SellTab =
    CreateTab(
        "Sell",
        "💰"
    )

local PetTab =
    CreateTab(
        "Pets",
        "🐾"
    )

local UUIDTab =
    CreateTab(
        "UUID",
        "🔎"
    )

local MoveTab =
    CreateTab(
        "Movement",
        "🚶"
    )


--============================================================
-- HOME
--============================================================

AddLabel(
    HomeTab,
    "GARDEN HUB"
)

AddLabel(
    HomeTab,
    "All features are controlled from the tabs."
)

AddButton(
    HomeTab,
    "Refresh Everything",
    function()

        GetSeedStock()
        RefreshOwnedSeeds()
        ScanPets()
        ScanAllUUID()

        Notify(
            "Everything refreshed"
        )

    end
)

AddButton(
    HomeTab,
    "Quick Harvest",
    function()

        HarvestAll()

        Notify(
            "Harvest finished"
        )

    end
)


--============================================================
-- FARM TAB
--============================================================

AddLabel(
    FarmTab,
    "PLANTING"
)


AddButton(
    FarmTab,
    "Select Seed",
    function()

        GetSeedStock()

        local Available = {}

        for Name, Count in pairs(
            SeedStock
        ) do

            if Count > 0 then
                table.insert(
                    Available,
                    Name
                )
            end

        end

        table.sort(
            Available
        )

        if #Available == 0 then

            Notify(
                "No seed in stock"
            )

            return

        end


        SelectedSeed =
            Available[1]

        Notify(
            "Selected: "
            .. SelectedSeed
        )

    end
)


AddToggle(
    FarmTab,
    "Auto Plant",
    false,
    function(Value)

        Config.AutoPlant =
            Value

    end
)


AddToggle(
    FarmTab,
    "Random Plant",
    false,
    function(Value)

        Config.AutoPlantRandom =
            Value

    end
)


AddButton(
    FarmTab,
    "Plant Now",
    function()

        AutoPlantOnce()

    end
)


AddLabel(
    FarmTab,
    "Selected: " ..
    tostring(
        SelectedSeed or "None"
    )
)


AddLabel(
    FarmTab,
    "HARVEST"
)


AddToggle(
    FarmTab,
    "Auto Harvest",
    false,
    function(Value)

        Config.AutoHarvest =
            Value

    end
)


AddButton(
    FarmTab,
    "Harvest Now",
    function()

        HarvestAll()

    end
)


--============================================================
-- SHOP TAB
--============================================================

AddLabel(
    ShopTab,
    "SEED SHOP"
)


AddButton(
    ShopTab,
    "Refresh Stock",
    function()

        GetSeedStock()

        Notify(
            "Stock refreshed"
        )

    end
)


AddButton(
    ShopTab,
    "Select First Available Seed",
    function()

        GetSeedStock()

        for Name, Count in pairs(
            SeedStock
        ) do

            if Count > 0 then

                SelectedBuySeed =
                    Name

                Notify(
                    "Buy selected: "
                    .. Name
                )

                break

            end

        end

    end
)


AddToggle(
    ShopTab,
    "Auto Buy",
    false,
    function(Value)

        Config.AutoBuy =
            Value

    end
)


AddButton(
    ShopTab,
    "Buy Selected Stock",
    function()

        BuyAllSelected()

    end
)


AddLabel(
    ShopTab,
    "Selected: " ..
    tostring(
        SelectedBuySeed or "None"
    )
)


--============================================================
-- SELL TAB
--============================================================

AddLabel(
    SellTab,
    "SELL INVENTORY"
)


AddButton(
    SellTab,
    "Sell Inventory",
    function()

        SellInventory()

    end
)


AddToggle(
    SellTab,
    "Auto Sell",
    false,
    function(Value)

        Config.AutoSell =
            Value

    end
)


AddLabel(
    SellTab,
    "Current threshold: "
    .. Config.SellThreshold
)


AddButton(
    SellTab,
    "Threshold +5",
    function()

        Config.SellThreshold =
            math.min(
                199,
                Config.SellThreshold + 5
            )

        Notify(
            "Threshold: "
            .. Config.SellThreshold
        )

    end
)


AddButton(
    SellTab,
    "Threshold -5",
    function()

        Config.SellThreshold =
            math.max(
                1,
                Config.SellThreshold - 5
            )

        Notify(
            "Threshold: "
            .. Config.SellThreshold
        )

    end
)


--============================================================
-- PET TAB
--============================================================

AddLabel(
    PetTab,
    "PET MANAGER"
)


AddButton(
    PetTab,
    "Scan Pets",
    function()

        ScanPets()

        Notify(
            "Pets scanned"
        )

    end
)


AddButton(
    PetTab,
    "Equip First Pet",
    function()

        for _, Data in pairs(
            Pets
        ) do

            SelectedPet =
                Data

            EquipPet(
                Data
            )

            break

        end

    end
)


AddToggle(
    PetTab,
    "Auto Unequip by Age",
    true,
    function(Value)

        Config.AutoUnequip =
            Value

    end
)


AddLabel(
    PetTab,
    "Max Age: "
    .. Config.MaxAge
)


AddButton(
    PetTab,
    "Max Age +1",
    function()

        Config.MaxAge += 1

        Notify(
            "Max Age: "
            .. Config.MaxAge
        )

    end
)


AddButton(
    PetTab,
    "Max Age -1",
    function()

        Config.MaxAge =
            math.max(
                1,
                Config.MaxAge - 1
            )

        Notify(
            "Max Age: "
            .. Config.MaxAge
        )

    end
)


--============================================================
-- UUID TAB
--============================================================

AddLabel(
    UUIDTab,
    "LIVE PET UUID SCANNER"
)


AddButton(
    UUIDTab,
    "Scan UUID",
    function()

        ScanAllUUID()

        Notify(
            "UUID scanned: "
            .. tostring(
                #(
                    (function()
                        local T = {}
                        for K in pairs(UUIDs) do
                            table.insert(T, K)
                        end
                        return T
                    end)()
                )
            )
        )

    end
)


AddButton(
    UUIDTab,
    "Clear UUID",
    function()

        table.clear(UUIDs)

        Notify(
            "UUID cleared"
        )

    end
)


--============================================================
-- MOVEMENT TAB
--============================================================

AddLabel(
    MoveTab,
    "AUTO WALK"
)


AddToggle(
    MoveTab,
    "Auto Walk",
    false,
    function(Value)

        Config.AutoWalk =
            Value

    end
)


AddToggle(
    MoveTab,
    "Allow Random Points",
    true,
    function(Value)

        Config.AutoWalkRandom =
            Value

    end
)


AddToggle(
    MoveTab,
    "NoClip",
    false,
    function(Value)

        Config.NoClip =
            Value

    end
)


AddButton(
    MoveTab,
    "Walk To Random Farm Point",
    function()

        local Position =
            GetRandomFarmPoint()

        local Humanoid =
            GetHumanoid()

        if Position
            and Humanoid then

            Humanoid:MoveTo(
                Position
            )

        end

    end
)


--============================================================
-- DRAG WINDOW
--============================================================

local Dragging = false
local DragStart
local StartPosition


Topbar.InputBegan:Connect(
    function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            Dragging = true

            DragStart =
                Input.Position

            StartPosition =
                Window.Position

        end

    end
)


UserInputService.InputChanged:Connect(
    function(Input)

        if not Dragging then
            return
        end

        if Input.UserInputType
            ~= Enum.UserInputType.MouseMovement
        then
            return
        end

        local Delta =
            Input.Position
            - DragStart

        Window.Position =
            UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset
                    + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset
                    + Delta.Y
            )

    end
)


UserInputService.InputEnded:Connect(
    function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            Dragging = false

        end

    end
)


--============================================================
-- MINIMIZE / CLOSE
--============================================================

Minimize.MouseButton1Click:Connect(
    function()

        Minimized =
            not Minimized

        Sidebar.Visible =
            not Minimized

        Content.Visible =
            not Minimized

        if Minimized then

            Window.Size =
                UDim2.fromOffset(
                    720,
                    55
                )

        else

            Window.Size =
                UDim2.fromOffset(
                    720,
                    470
                )

        end

    end
)


Close.MouseButton1Click:Connect(
    function()

        Config.AutoPlant = false
        Config.AutoHarvest = false
        Config.AutoBuy = false
        Config.AutoSell = false
        Config.AutoWalk = false
        Config.NoClip = false

        MainGui:Destroy()

    end
)


--============================================================
-- BACKGROUND SERVICES
--============================================================

task.spawn(
    function()

        while MainGui.Parent do

            task.wait(0.5)

            GetSeedStock()
            RefreshOwnedSeeds()

        end

    end
)


task.spawn(
    function()

        while MainGui.Parent do

            task.wait(1)

            AutoUnequipPets()

        end

    end
)


task.spawn(
    function()

        while MainGui.Parent do

            task.wait(0.1)

            if Config.AutoPlant then
                AutoPlantOnce()
            end

        end

    end
)


task.spawn(
    function()

        while MainGui.Parent do

            task.wait(0.15)

            if Config.AutoHarvest then
                HarvestAll()
            end

        end

    end
)


task.spawn(
    function()

        while MainGui.Parent do

            task.wait(0.2)

            if Config.AutoBuy then

                BuyAllSelected()

            end

        end

    end
)


task.spawn(
    function()

        while MainGui.Parent do

            task.wait(1)

            if Config.AutoSell then

                local Count =
                    #GetInvCrops()

                if Count
                    >= Config.SellThreshold then

                    SellInventory()

                end

            end

        end

    end
)


task.spawn(
    function()

        while MainGui.Parent do

            task.wait(
                Config.AutoWalkDelay
            )

            if Config.AutoWalk then
                AutoWalk()
            end

        end

    end
)


--============================================================
-- INITIAL SCAN
--============================================================

GetSeedStock()
RefreshOwnedSeeds()
ScanPets()
ScanAllUUID()


--============================================================
-- SHOW HOME TAB
--============================================================

Tabs.Home.Visible = true

TabButtons.Home.TextColor3 =
    TEXT

TabButtons.Home.BackgroundColor3 =
    PANEL2


Notify(
    "Garden Hub loaded"
)

print(
    "[GardenHub] Loaded successfully."
)
