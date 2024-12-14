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
    getgenv().PlayerListVisible = state
    PlayerList.Enabled = state
end)

-- Robbery Notifications Toggle
NotifierSection:NewToggle("Enable Notifications", "Toggle this to enable notifications when an object spawns", function(state)
    if state then
        -- Enable the notification feature
        game:GetService("Workspace").BrinksRobbery.ChildAdded:Connect(function(child)
            -- Create a custom notification
            local screenGui = Instance.new("ScreenGui")
            local notification = Instance.new("TextLabel")
            notification.Parent = screenGui
            screenGui.Parent = game.Players.LocalPlayer.PlayerGui

            -- Set up the notification appearance
            notification.Size = UDim2.new(0.5, 0, 0.1, 0)
            notification.Position = UDim2.new(0.25, 0, 0.8, 0)
            notification.BackgroundTransparency = 1 -- Remove the black background
            notification.TextColor3 = Color3.fromRGB(255, 0, 0) -- Text color (red)
            notification.TextSize = 24
            notification.Text = "Truck has spawned, go rob it!"
            notification.TextWrapped = true
            notification.TextStrokeTransparency = 0.8
            notification.TextStrokeColor3 = Color3.fromRGB(255, 255, 255) -- White text stroke for better readability

            -- Show the notification for 5 seconds
            wait(5)
            screenGui:Destroy()
        end)
    else
        -- Disable notifications
        print("Notifications disabled")
    end
end)
