-- Load the Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Create the UI Window
local Window = Library.CreateLib("ESP & Hitbox Script", "DarkTheme")

-- Create Tabs and Sections
local ESPTab = Window:NewTab("ESP Features")
local ESPSection = ESPTab:NewSection("ESP Controls")

local HitboxTab = Window:NewTab("Hitbox Features")
local HitboxSection = HitboxTab:NewSection("Hitbox Controls")

local SpeedTab = Window:NewTab("Player Speed")
local SpeedSection = SpeedTab:NewSection("Player Speed Controls")

local PlayerListTab = Window:NewTab("Player List")
local PlayerListSection = PlayerListTab:NewSection("Player List Controls")

-- Notifier Tab and Section
local NotifierTab = Window:NewTab("Notifier")
local NotifierSection = NotifierTab:NewSection("Robbery Notifications")

-- Teleport Tab and Section
local TeleportTab = Window:NewTab("Teleports")
local TeleportSection = TeleportTab:NewSection("Teleport Section")

-- ESP Toggle State
getgenv().ESPEnabled = false
getgenv().PlayerListVisible = true -- State for player list visibility

-- Speed Control Variables
getgenv().PlayerSpeed = 16 -- Default speed

-- Function to update ESP for all players
local function updateESP()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            -- Create ESP Billboard if not already present
            local espBillboard = rootPart:FindFirstChild("ESPBox")
            if not espBillboard then
                espBillboard = Instance.new("BillboardGui", rootPart)
                espBillboard.Name = "ESPBox"
                espBillboard.Size = UDim2.new(0, 200, 0, 50)
                espBillboard.AlwaysOnTop = true
                espBillboard.StudsOffset = Vector3.new(0, 3, 0)

                -- Create text label
                local textLabel = Instance.new("TextLabel", espBillboard)
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                textLabel.TextStrokeTransparency = 0.5
                textLabel.TextScaled = true
                textLabel.Font = Enum.Font.SourceSansBold
            end

            -- Update ESP text
            local distance = math.floor((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
            local health = humanoid and math.floor(humanoid.Health) or 0
            espBillboard.TextLabel.Text = string.format(
                "%s\n%sHP: %d\n%sDistance: %d", 
                player.Name, 
                "HP: ", health, 
                "Distance: ", distance
            )

            -- Set color for HP to red, and Distance to yellow
            espBillboard.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            local newText = string.gsub(espBillboard.TextLabel.Text, "HP: (%d+)", function(str)
                espBillboard.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- HP to red
                return "HP: " .. str
            end)
            newText = string.gsub(newText, "Distance: (%d+)", function(str)
                espBillboard.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Distance to yellow
                return "Distance: " .. str
            end)
            espBillboard.TextLabel.Text = newText
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

-- ESP Toggle Button
ESPSection:NewToggle("Enable ESP", "Toggles the ESP feature", function(state)
    getgenv().ESPEnabled = state
    if state then
        print("ESP Enabled")
        game:GetService("RunService").RenderStepped:Connect(function()
            if getgenv().ESPEnabled then
                updateESP()
            else
                clearESP()
            end
        end)
    else
        print("ESP Disabled")
        clearESP()
    end
end)

-- Player Speed Slider
SpeedSection:NewSlider("Player Speed", "Adjust Player Speed", 128, 16, function(speed)
    -- Update the player speed
    getgenv().PlayerSpeed = speed
end)

-- Looping the Player Speed every 0.3 seconds
game:GetService("RunService").RenderStepped:Connect(function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().PlayerSpeed
end)

-- UI Toggle Keybind
ESPSection:NewKeybind("Toggle UI", "Hides or shows the UI", Enum.KeyCode.F, function()
    Library:ToggleUI()
end)

-- Function to set hitbox size
local function setHitbox(size)
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            if rootPart:IsA("BasePart") then
                rootPart.Size = Vector3.new(size, size, size)
                rootPart.Transparency = 0.4
            end
        end
    end
    print("Hitbox size set to:", size)
end

-- Hitbox Button
HitboxSection:NewButton("Set Hitbox Size to 10", "Changes other players' hitboxes to 10", function()
    setHitbox(10)
end)

-- Player List UI
local PlayerList = Instance.new("ScreenGui", game.CoreGui)
PlayerList.Name = "PlayerListUI"

local ScrollingFrame = Instance.new("ScrollingFrame", PlayerList)
ScrollingFrame.Size = UDim2.new(0, 200, 0, 300)
ScrollingFrame.Position = UDim2.new(0, 10, 0.5, -150)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollingFrame.BorderSizePixel = 2
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Add a UIListLayout to the ScrollingFrame to handle proper spacing
local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.SortOrder = Enum.SortOrder.Name -- Sort items by name automatically
UIListLayout.Padding = UDim.new(0, 5) -- Add padding between items

-- Function to update the player list
local function updatePlayerList()
    -- Clear existing items in the list
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    -- Get all players, sort them alphabetically, and add them to the list
    local players = game.Players:GetPlayers()
    table.sort(players, function(a, b) return a.Name:lower() < b.Name:lower() end)
    
    for _, player in ipairs(players) do
        -- Create a TextLabel for each player
        local PlayerLabel = Instance.new("TextButton", ScrollingFrame)
        PlayerLabel.Size = UDim2.new(1, 0, 0, 30)
        PlayerLabel.Text = player.Name
        PlayerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayerLabel.BackgroundTransparency = 0.3
        PlayerLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        PlayerLabel.Font = Enum.Font.SourceSans
        PlayerLabel.TextScaled = true

        -- Teleport to player when clicked
        PlayerLabel.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = player.Character.HumanoidRootPart.Position
                game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
            end
        end)
    end

    -- Adjust the canvas size to fit all items
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, (#players * (30 + 5))) -- Item height + padding
end

-- Initial update
updatePlayerList()

-- Listen for players joining or leaving the game
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Player List Toggle
PlayerListSection:NewToggle("Show Player List", "Toggles the player list visibility", function(state)
    PlayerList.Enabled = state
end)

-- Robbery Notification
NotifierSection:NewToggle("Robbery Notifications", "Toggles robbery notifications", function(state)
    getgenv().NotifierEnabled = state
end)

-- Teleport Tab and Section
local Tab = Window:NewTab("Teleports")
local Section = Tab:NewSection("Teleport Section")

-- Create the teleport UI
local PlayerList = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
PlayerList.Name = "TeleportUI"

local ScrollingFrame = Instance.new("ScrollingFrame", PlayerList)
ScrollingFrame.Size = UDim2.new(0, 200, 0, 300)
ScrollingFrame.Position = UDim2.new(1, -210, 0.5, -150)  -- Position at middle-right
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollingFrame.BorderSizePixel = 2
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Add a UIListLayout to handle proper spacing
local UIListLayout = Instance.new("UIListLayout", ScrollingFrame)
UIListLayout.SortOrder = Enum.SortOrder.Name -- Sort items by name
UIListLayout.Padding = UDim.new(0, 5) -- Padding between items

-- Function to create teleport buttons
local function createTeleportButton(name, targetCFrame)
    local button = Instance.new("TextButton", ScrollingFrame)
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 0.3
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.Font = Enum.Font.SourceSans
    button.TextScaled = true

    -- Teleport action
    button.MouseButton1Click:Connect(function()
        game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(targetCFrame)
    end)
end

-- Add predefined teleport buttons
createTeleportButton("Teleport to BANK", CFrame.new(-529.840149, 17.5899639, -303.625061))
createTeleportButton("Teleport to Illegal Shop", CFrame.new(-142.381241, 4.57253838, 186.242584, -1, 0, 0, 0, 1, 0, 0, 0, -1))
createTeleportButton("Teleport to Paki Shop", CFrame.new(-101.372818, 4.42014694, 47.9233665, 0.00340612093, 0.000122707948, 0.999994397, -0.000121861485, 1, -0.000122293568, -0.999994397, -0.000121444245, 0.00340612838))
createTeleportButton("Teleport to Dominos", CFrame.new(149.960754, 4.54623413, 51.6483688, 1, 0, 0, 0, 1, 0, 0, 0, 1))
createTeleportButton("Teleport to Box", CFrame.new(-125.536354, 2.50902843, 300.507019, 1, 0, 0, 0, 1, 0, 0, 0, 1))
createTeleportButton("Teleport to Med Shop", CFrame.new(36.9738045, 4.80975246, -265.52121, 0.965931356, -0.0885077789, -0.243193239, -1.02743506e-05, 0.939688563, -0.34203124, 0.258798331, 0.330381215, 0.907673776))

-- Function to update the teleport UI visibility
local teleportUIVisible = false
local function updateTeleportUIVisibility(state)
    teleportUIVisible = state
    PlayerList.Enabled = state  -- Toggle the entire PlayerList UI
end

-- Create the toggle to show/hide the teleport UI
Section:NewToggle("Show Teleports", "Toggles the teleport list visibility", function(state)
    updateTeleportUIVisibility(state)
end)

-- Initial Update
updateTeleportUIVisibility(false)  -- Make it hidden by default
