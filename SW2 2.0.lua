-- Load Fluent UI Library and Addons
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Options = Fluent.Options

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "ESP & Hitbox Script",
    SubTitle = "by YourName",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.F
})

-- Create Tabs
local Tabs = {
    ESP = Window:AddTab({ Title = "ESP Features", Icon = "eye" }),
    Hitbox = Window:AddTab({ Title = "Hitbox Features", Icon = "box" }),
    Speed = Window:AddTab({ Title = "Player Speed", Icon = "gauge" }),
    Players = Window:AddTab({ Title = "Player List", Icon = "users" }),
    Notifier = Window:AddTab({ Title = "Notifier", Icon = "bell" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Values = Window:AddTab({ Title = "Values Editor", Icon = "edit-3" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Create Player List UI
local PlayerList = Instance.new("ScreenGui", game.CoreGui)
PlayerList.Name = "PlayerListUI"

local ScrollingFrame = Instance.new("ScrollingFrame", PlayerList)
ScrollingFrame.Size = UDim2.new(0, 200, 0, 300)
ScrollingFrame.Position = UDim2.new(0, 10, 0.5, -150)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollingFrame.BorderSizePixel = 2
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 5)

-- Global Variables
getgenv().ESPEnabled = false
getgenv().PlayerListVisible = true
getgenv().PlayerSpeed = 16
getgenv().HitboxSize = 10
getgenv().MoneyValue = 0
getgenv().CustomNameEnabled = false

-- Function to update player list
local function updatePlayerList()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    local players = game.Players:GetPlayers()
    table.sort(players, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    for _, player in ipairs(players) do
        local PlayerLabel = Instance.new("TextButton", ScrollingFrame)
        PlayerLabel.Size = UDim2.new(1, 0, 0, 30)
        PlayerLabel.Text = player.Name
        PlayerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayerLabel.BackgroundTransparency = 0.3
        PlayerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        PlayerLabel.Font = Enum.Font.SourceSans
        PlayerLabel.TextScaled = true

        PlayerLabel.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = player.Character.HumanoidRootPart.Position
                game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
            end
        end)
    end

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (#players * (30 + 5)))
end

-- Function to update ESP
local function updateESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            local espBillboard = rootPart:FindFirstChild("ESPBox")
            if not espBillboard then
                espBillboard = Instance.new("BillboardGui", rootPart)
                espBillboard.Name = "ESPBox"
                espBillboard.Size = UDim2.new(0, 200, 0, 50)
                espBillboard.AlwaysOnTop = true
                espBillboard.StudsOffset = Vector3.new(0, 3, 0)

                local textLabel = Instance.new("TextLabel", espBillboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.SourceSansBold
            end

            local distance = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
            local health = humanoid and math.floor(humanoid.Health) or 0
            espBillboard.TextLabel.Text = string.format("%s\nHP: %d\nDistance: %d", player.Name, health, distance)
        end
    end
end

-- Function to clear ESP
local function clearESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local espBillboard = player.Character.HumanoidRootPart:FindFirstChild("ESPBox")
            if espBillboard then
                espBillboard:Destroy()
            end
        end
    end
end

-- Initial update and event connections
updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- ESP Toggle
local ESPToggle = Tabs.ESP:AddToggle("ESPToggle", {
    Title = "Enable ESP",
    Description = "Toggles the ESP feature",
    Default = false
})

ESPToggle:OnChanged(function(Value)
    getgenv().ESPEnabled = Value
    if Value then
        game:GetService("RunService").RenderStepped:Connect(function()
            if getgenv().ESPEnabled then
                updateESP()
            else
                clearESP()
            end
        end)
    else
        clearESP()
    end
end)

-- Player Speed Slider
local SpeedSlider = Tabs.Speed:AddSlider("SpeedSlider", {
    Title = "Player Speed",
    Description = "Adjust Player Speed",
    Default = 16,
    Min = 16,
    Max = 128,
    Rounding = 0,
    Callback = function(Value)
        getgenv().PlayerSpeed = Value
    end
})

-- Hitbox Input
local HitboxInput = Tabs.Hitbox:AddInput("HitboxSize", {
    Title = "Hitbox Size",
    Description = "Enter hitbox size (number)",
    Default = "10",
    Placeholder = "Enter size...",
    Numeric = true,
    Callback = function(Value)
        local size = tonumber(Value) or 10
        getgenv().HitboxSize = size
    end
})

-- Money Value Input
local MoneyInput = Tabs.Values:AddInput("MoneyValue", {
    Title = "Money Value",
    Description = "Enter money amount",
    Default = "0",
    Placeholder = "Enter amount...",
    Numeric = true,
    Callback = function(Value)
        local amount = tonumber(Value) or 0
        getgenv().MoneyValue = amount
    end
})

-- Custom Name Toggle
local NameToggle = Tabs.Values:AddToggle("CustomNameToggle", {
    Title = "Custom Name",
    Description = "Changes display name to @CWK.GG",
    Default = false
})

NameToggle:OnChanged(function(Value)
    getgenv().CustomNameEnabled = Value
end)

-- Speed Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().PlayerSpeed
    end
end)

-- Hitbox Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            if rootPart:IsA("BasePart") then
                rootPart.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                rootPart.Transparency = 0.4
            end
        end
    end
end)

-- Money Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if game:GetService("Players").LocalPlayer:FindFirstChild("leaderstats") and 
       game:GetService("Players").LocalPlayer.leaderstats:FindFirstChild("Wallet") then
        game:GetService("Players").LocalPlayer.leaderstats.Wallet.Value = getgenv().MoneyValue
    end
end)

-- Name Update Loop
game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().CustomNameEnabled then
        if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Stats") then
            local stats = game:GetService("Players").LocalPlayer.PlayerGui.Stats.Main
            if stats:FindFirstChild("Username") then
                stats.Username.Text = "@CWK.GG"
            end
            if stats:FindFirstChild("FirstLastName") then
                stats.FirstLastName.Text = "@CWK.GG"
            end
        end
    end
end)

-- Player List Toggle
local PlayerListToggle = Tabs.Players:AddToggle("PlayerListToggle", {
    Title = "Show Player List",
    Description = "Toggles the player list visibility",
    Default = false
})

PlayerListToggle:OnChanged(function(Value)
    PlayerList.Enabled = Value
end)

-- Teleport Buttons
local teleports = {
    {name = "BANK", pos = CFrame.new(-529.840149, 17.5899639, -303.625061)},
    {name = "Illegal Shop", pos = CFrame.new(-142.381241, 4.57253838, 186.242584, -1, 0, 0, 0, 1, 0, 0, 0, -1)},
    {name = "Paki Shop", pos = CFrame.new(-101.372818, 4.42014694, 47.9233665)},
    {name = "Dominos", pos = CFrame.new(149.960754, 4.54623413, 51.6483688)},
    {name = "Box", pos = CFrame.new(-125.536354, 2.50902843, 300.507019)},
    {name = "Med Shop", pos = CFrame.new(36.9738045, 4.80975246, -265.52121)}
}

for _, teleport in ipairs(teleports) do
    Tabs.Teleports:AddButton({
        Title = "Teleport to " .. teleport.name,
        Description = "Click to teleport",
        Callback = function()
            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(teleport.pos)
        end
    })
end

-- Setup SaveManager and InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ESPScript")
SaveManager:SetFolder("ESPScript/configs")

-- Build Settings
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select default tab and show loaded notification
Window:SelectTab(1)

Fluent:Notify({
    Title = "Script Loaded",
    Content = "ESP & Hitbox Script has been loaded successfully",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
