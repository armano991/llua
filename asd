
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

if _G.spinSpeed == nil then
    _G.spinSpeed = 20
end

if _G.spin == nil then
    _G.spin = false
end

if _G.noclip == nil then
    _G.noclip = false
end

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function findPlayerByPartialName(name)
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name or (player.DisplayName and player.DisplayName:lower():sub(1, #name) == name) then
            return player
        end
    end
    return nil
end

local function EnableSpin()
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = getRoot(character)
    if not root then return end
    
    for i, v in pairs(root:GetChildren()) do
        if v.Name == "Spinning" then
            v:Destroy()
        end
    end
    
    local Spin = Instance.new("BodyAngularVelocity")
    Spin.Name = "Spinning"
    Spin.Parent = root
    Spin.MaxTorque = Vector3.new(0, math.huge, 0)
    Spin.AngularVelocity = Vector3.new(0, _G.spinSpeed, 0)
end

local function DisableSpin()
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = getRoot(character)
    if not root then return end
    
    for i, v in pairs(root:GetChildren()) do
        if v.Name == "Spinning" then
            v:Destroy()
        end
    end
end
-- Simulated Running method toggle
getgenv().SwimMethod = false

-- Constantly force Running state if SwimMethod is enabled
task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    while task.wait() do
        if getgenv().SwimMethod then
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")

            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Running then
                pcall(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end
    end
end)

-- Helper: Find player by partial name or display name
function findPlayerByPartialName(name)
    name = name:lower()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name or player.DisplayName:lower():sub(1, #name) == name then
            return player
        end
    end
    return nil
end

function teleportTo(input)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return
    end

    local destinationCFrame

    if typeof(input) == "Vector3" then
        destinationCFrame = CFrame.new(input)
    elseif typeof(input) == "CFrame" then
        destinationCFrame = input
    elseif typeof(input) == "string" then
        local targetPlayer = findPlayerByPartialName(input)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            destinationCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        else
            return
        end
    else
        return
    end

    -- Perform teleport
    getgenv().SwimMethod = true
    task.wait()
    hrp.CFrame = destinationCFrame
    getgenv().SwimMethod = false

end

-- Noclip Variables and Functions
local Clip = true
local NoclipConnection = nil
local floatName = "FloatPart"

local function EnableNoclip()
    if NoclipConnection then return end
    Clip = false
    local function NoclipLoop()
        if not Clip and LocalPlayer.Character then
            for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                    child.CanCollide = false
                end
            end
        end
    end
    
    NoclipConnection = RunService.Stepped:Connect(NoclipLoop)
end

local function DisableNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    Clip = true
    if LocalPlayer.Character then
        for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") and child.Name ~= floatName then
                child.CanCollide = true
            end
        end
    end
end

local keepGunsEnabled = false

local function triggerKeepGuns()
    local excludedItems = {
        "Phone", "Fist", "Car Keys", "Gun Permit",
        ".UziMag", ".Bullets", "5.56", "7.62", ".9mm", 
        ".Extended", ".FNMag", ".MacMag", ".TecMag", ".Drum",
        "Lemonade", "FakeCard", "G26", "Shiesty", "RawSteak",
        "Ice-Fruit Bag", "Ice-Fruit Cupz", "FijiWater", "FreshWater",
        "Red Elite Bag", "Black Elite Bag", "Blue Elite Bag",
        "Drac Bag", "Yellow RCR Bag", "Black RCR Bag",
        "Red RCR Bag", "Tan RCR Bag", "Black Designer Bag",
        "BluGloves", "WhiteGloves", "BlackGloves",
        "PinkCamoGloves", "RedCamoGloves", "BluCamoGloves",
        "Water", "RawChicken"
    }

    local function isExcluded(toolName)
        local normTool = toolName:lower():gsub("%W", "")
        for _, excluded in ipairs(excludedItems) do
            if excluded:lower():gsub("%W", "") == normTool then
                return true
            end
        end
        return false
    end

    local ListWeaponRemote = ReplicatedStorage:WaitForChild("ListWeaponRemote")

    local function sellItem(itemName)
        local args = {
            [1] = itemName,
            [2] = 999999
        }
        ListWeaponRemote:FireServer(unpack(args))
    end

    local function onDeath()
        if keepGunsEnabled then
            task.spawn(function()
                repeat
                    local soldSomething = false
                    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") and not isExcluded(item.Name) then
                            sellItem(item.Name)
                            soldSomething = true
                            task.wait(2)
                        end
                    end
                    task.wait(0.1)
                until not soldSomething
            end)
        end
    end

    local function onRespawn()
        if keepGunsEnabled then
            task.wait(2)
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local marketGui = playerGui:FindFirstChild("Bronx Market 2")
                if marketGui then
                    marketGui.Enabled = true
                end
            end
        end
    end

    LocalPlayer.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(onDeath)
        end
        onRespawn()
    end)

    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Died:Connect(onDeath)
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    if _G.spin then
        EnableSpin()
    end
    if _G.noclip then
        EnableNoclip()
    end
end)

local lastSpinSpeed = _G.spinSpeed
RunService.Heartbeat:Connect(function()
    if _G.spin and LocalPlayer.Character then
        if _G.spinSpeed ~= lastSpinSpeed then
            lastSpinSpeed = _G.spinSpeed
            EnableSpin()
        end
        
        local root = getRoot(LocalPlayer.Character)
        if root and not root:FindFirstChild("Spinning") then
            EnableSpin()
        end
    end
    
    if not _G.spin and LocalPlayer.Character then
        local root = getRoot(LocalPlayer.Character)
        if root and root:FindFirstChild("Spinning") then
            DisableSpin()
        end
    end
    
    if _G.noclip and Clip then
        EnableNoclip()
    end
    if not _G.noclip and not Clip then
        DisableNoclip()
    end
end)



local WaveHub = loadstring(game:HttpGet("https://pastebin.com/raw/1pBXcAby"))()
local Window = WaveHub:New("Wave Hub | #1 Undetected")

local BronxTab = Window:CreateTab("Tha Bronx")
local MainTab = Window:CreateTab("Aimbot")
local PlayerTab = Window:CreateTab("Player")
local TeleportTab = Window:CreateTab("Teleport")
local MiscTab = Window:CreateTab("Miscellaneous")
local TargetTab = Window:CreateTab("Target")
local GunModsTab = Window:CreateTab("Gun Mods")
local VehicleModsTab = Window:CreateTab("Vehicle Mods")
local VisualsTab = Window:CreateTab("Visuals")
local FarmingTab = Window:CreateTab("Farming")
local QuickBuyTab = Window:CreateTab("Quick Buy")
local CreditsTab = Window:CreateTab("Credits")

Window:CreateToggle(BronxTab, "Buy All Items", false, function(state)
    if not state then return end

    local requiredItems = {"Ice-Fruit Bag", "Ice-Fruit Cupz", "FijiWater", "FreshWater"}
    local player = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Validate player and stored money
    local stored = player:FindFirstChild("stored")
    local money = stored and stored:FindFirstChild("Money") and stored.Money.Value or 0
    if money < 2696 then return end

    for _, item in ipairs(requiredItems) do
        local hasItem = function()
            return (player.Backpack and player.Backpack:FindFirstChild(item)) or 
                   (player.Character and player.Character:FindFirstChild(item))
        end

        if not hasItem() then
            local attempts = 0
            repeat
                local success, err = pcall(function()
                    ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer(item)
                end)
                if not success then warn("Failed to buy item:", item, err) end

                task.wait(0.3)
                attempts += 1
            until hasItem() or attempts > 5
        end
    end
end)


Window:CreateButton(BronxTab, "Money Dupe/Infinite Money", function()
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Gamepass IDs
local gamepassId1 = 1061358030
local gamepassId2 = 1061772429

-- Refill station
local refill = workspace:FindFirstChild("IceFruit Sell")
if not refill then
    warn("Refill station not found")
    return
end

-- Get original position
local OldCFrame = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.CFrame

-- Gamepass check
local function PlayerOwnsGamepass(player, id)
    local success, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
    end)
    return success and result
end

-- Teleport helper
local function BypassTp(cf)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        teleportTo(cf + Vector3.new(0, 3, 0)) 
    end
end

-- Equip Cupz if needed
local function ensureCupzEquipped()
    if player.Character and player.Character:FindFirstChild("Ice-Fruit Cupz") then
        return true -- Already equipped
    end

    local cupz = player.Backpack:FindFirstChild("Ice-Fruit Cupz")
    if cupz and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:UnequipTools()
        task.wait(0.3)
        player.Character.Humanoid:EquipTool(cupz)
        task.wait(0.5)
        return player.Character:FindFirstChild("Ice-Fruit Cupz") ~= nil
    else
        warn("Ice-Fruit Cupz not found in backpack.")
        return false
    end
end

-- Selling routine
local function sellLoop()
    local prompt = refill:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        warn("Selling prompt not found.")
        return
    end

    local sellLimit = (PlayerOwnsGamepass(player, gamepassId1) or PlayerOwnsGamepass(player, gamepassId2)) and 18000000 or 990000
    local lastMoney = player:FindFirstChild("stored") and player.stored:FindFirstChild("FilthyStack") and player.stored.FilthyStack.Value or 0
    local noChangeCount = 0

    BypassTp(refill.CFrame)
    task.wait(1)

    for i = 1, 10000 do
        if not ensureCupzEquipped() then
            warn("Can't equip Ice-Fruit Cupz. Stopping.")
            break
        end

        pcall(function()
            prompt.Enabled = true
            if Camera and prompt and prompt.Parent then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, prompt.Parent.Position)
            end
            fireproximityprompt(prompt)
        end)
        local currentMoney = player.stored and player.stored:FindFirstChild("FilthyStack") and player.stored.FilthyStack.Value or 0

        if currentMoney > lastMoney then
            lastMoney = currentMoney
            noChangeCount = 0
            if i % 100 == 0 then
                warn("Sold so far: $" .. currentMoney)
            end
        else
            noChangeCount += 1
        end

        if currentMoney >= sellLimit then
            warn("Reached sell limit: $" .. currentMoney)
            break
        end

        if noChangeCount > 1000 then
            warn("Stuck selling. Re-equipping and retrying...")
            ensureCupzEquipped()
            BypassTp(refill.CFrame)
            noChangeCount = 0
        end

        if i % 500 == 0 then task.wait(0.05) end
    end

    if OldCFrame then
        BypassTp(OldCFrame)
    end
end

-- Run
sellLoop()

end)

Window:CreateToggle(BronxTab, "Clean Money", false, function(state)
    if not state then return end
    loadstring(game:HttpGet("https://pastebin.com/raw/2MVSABvu"))()
end)

Window:CreateButton(BronxTab, "Dupe Weapon", function()
        local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
        local Players = cloneref(game:GetService("Players"))

        local Player = Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Backpack = Player:WaitForChild("Backpack")

        local Tool = Character:FindFirstChildOfClass("Tool")
        if not Tool then return end

        Tool.Parent = Backpack
        task.wait(0.5)

        local ToolName = Tool.Name
        local ToolId = nil


        local function getPing()
            if typeof(Player.GetNetworkPing) == "function" then
                local success, result = pcall(function()
                    return tonumber(string.match(Player:GetNetworkPing(), "%d+"))
                end)
                if success and result then
                    return result
                end
            end

            local success2, pingStat = pcall(function()
                return Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("Ping") or
                    Players.LocalPlayer:FindFirstChild("PlayerScripts"):FindFirstChild("Ping")
            end)
            if success2 and pingStat and pingStat:IsA("TextLabel") then
                local num = tonumber(string.match(pingStat.Text, "%d+"))
                if num then
                    return num
                end
            end

            local t0 = tick()
            local temp = Instance.new("BoolValue", ReplicatedStorage)
            temp.Name = "PingTest_" .. tostring(math.random(10000, 99999))
            task.wait(0.1)
            local t1 = tick()
            temp:Destroy()

            return math.clamp((t1 - t0) * 1000, 50, 300)
        end


        local ping = getPing()
        local delay = 0.25 + ((math.clamp(ping, 0, 300) / 300) * 0.03)


        local marketconnection = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
            if item.Name == ToolName then
                local owner = item:WaitForChild("owner", 2)
                if owner and owner.Value == Player.Name then
                    ToolId = item:GetAttribute("SpecialId")
                end
            end
        end)


        task.spawn(function()
            ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999)
        end)


        task.wait(delay)


        task.spawn(function()
            ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName)
        end)

        task.wait(3)


        if ToolId then
            task.spawn(function()
                ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", ToolId)
            end)
        end

        task.spawn(function()
            ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName)
        end)

        marketconnection:Disconnect()
        task.wait(1)
end)

Window:CreateToggle(BronxTab, "Collect Dropped & Dead Cash", false, function(state)
    if not state then return end
    
end)
-- Labels
Window:CreateLabel(BronxTab, "1. Press Buy Items, Then cook them.")
Window:CreateLabel(BronxTab, "2. Once done, hold out the jug and press the\n Money Dupe Button")
Window:CreateLabel(BronxTab, "3. Wait for Completion -> Infinite Money")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

Window:CreateToggle(BronxTab, "CFrame Walkspeed", false, function(enabled)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    -- Save default speed
    local defaultSpeed = humanoid.WalkSpeed

    if enabled then
        -- Store original speed if not already stored
        if not humanoid:FindFirstChild("OriginalWalkSpeed") then
            local speedStore = Instance.new("NumberValue")
            speedStore.Name = "OriginalWalkSpeed"
            speedStore.Value = defaultSpeed
            speedStore.Parent = humanoid
        end

        -- Set WalkSpeed to 0 to prevent conflict
        humanoid.WalkSpeed = 0

        -- Prevent duplicate connections
        if getgenv().CFrameWalkConn then
            getgenv().CFrameWalkConn:Disconnect()
            getgenv().CFrameWalkConn = nil
        end

        -- Create new connection
        local conn = RunService.Heartbeat:Connect(function(dt)
            if not character or not character.Parent or humanoid.Health <= 0 then 
                return 
            end

            local moveDir = humanoid.MoveDirection
            local speed = humanoid:FindFirstChild("OriginalWalkSpeed") and humanoid.OriginalWalkSpeed.Value or 16

            if moveDir.Magnitude > 0 then
                local velocity = moveDir * speed
                rootPart.Velocity = Vector3.new(velocity.X, rootPart.Velocity.Y, velocity.Z)
                rootPart.CFrame = rootPart.CFrame + (velocity * dt)
            else
                rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
            end
        end)

        -- Store connection
        getgenv().CFrameWalkConn = conn

    else
        -- Restore default WalkSpeed
        humanoid.WalkSpeed = humanoid:FindFirstChild("OriginalWalkSpeed") and humanoid.OriginalWalkSpeed.Value or defaultSpeed

        -- Disconnect Heartbeat connection
        if getgenv().CFrameWalkConn then
            getgenv().CFrameWalkConn:Disconnect()
            getgenv().CFrameWalkConn = nil
        end
    end
end)

Window:CreateToggle(BronxTab, "Collect Loot Bags [Gamepass]", false, function(state)
    -- Collect loot logic
end)


-- Optimized global settings
getgenv().fovsetting = {
    Rainbow = false,
    Teamcheck = false,
    Wallcheck = false,
    Dead = false,
    Snaplines = false,
    Fill = Color3.fromRGB(255,0,0),
    Outline = Color3.fromRGB(255,0,0)
}

getgenv().silentsettings = {
    Enabled = false,
    HitPart = "Head",
    RandomRedirection = false,
    Hitchance = 100,
    Wallbang = false,
    Range = 1000,
}

-- Helper function to parse RGB string
local function parseRGB(rgbString)
    local r, g, b = rgbString:match("(%d+),(%d+),(%d+)")
    if r and g and b then
        r, g, b = tonumber(r), tonumber(g), tonumber(b)
        if r >= 0 and r <= 255 and g >= 0 and g <= 255 and b >= 0 and b <= 255 then
            return Color3.fromRGB(r, g, b)
        end
    end
    return Color3.fromRGB(255, 255, 255)
end

-- Function to check if hit should register based on hitchance
local function shouldHit()
    if silentsettings.Hitchance <= 0 then
        return false  -- 0% = never hit
    elseif silentsettings.Hitchance >= 100 then
        return true   -- 100% = always hit
    else
        return math.random(1, 100) <= silentsettings.Hitchance
    end
end

-- Optimized services and setup
local plrs = cloneref(game:GetService("Players")) or game:GetService("Players")
local rs = cloneref(game:GetService("RunService")) or game:GetService("RunService")
local plr = plrs.LocalPlayer
local mouse = plr:GetMouse()
local camera = workspace.CurrentCamera
local UserInputService = cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")

-- Error handling setup
pcall(function()
    script.Name = "Kurupted"
    local ScriptContext = cloneref(game:GetService("ScriptContext")) or game:GetService("ScriptContext")
    ScriptContext.Error:Connect(function() end)
    if getconnections then
        local err = game:GetService("ScriptContext").Error
        for i, v in next, getconnections(err) do
            v:Disable()
        end
    end
end)

-- ScreenGui and FOV Circle setup
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
screenGui.Enabled = true

local Snaplines = Drawing.new("Line")
Snaplines.Color = Color3.fromRGB(255, 255, 255)
Snaplines.Thickness = 0.1
Snaplines.Transparency = 1
Snaplines.Visible = false

local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, 200, 0, 200)
fovCircle.Position = UDim2.new(0, 0, 0, 0)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundColor3 = Color3.new(1, 1, 1)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Parent = screenGui
local stroke = Instance.new("UIStroke", fovCircle)
stroke.Color = Color3.fromRGB(0, 255, 98)
stroke.Thickness = 2

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.5, 0)
uiCorner.Parent = fovCircle

-- Optimized closest opponent function
local function closestopp()
    local localPlayer = plrs.LocalPlayer
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, v in pairs(plrs:GetPlayers()) do
        if v ~= localPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid then
            if v.Team == localPlayer.Team and fovsetting.Teamcheck then
                continue
            end

            if v.Character.Humanoid.Health == 0 and fovsetting.Dead then
                continue
            end

            local characterPos = v.Character.HumanoidRootPart.Position
            local screenPos, onScreen = camera:WorldToScreenPoint(characterPos)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(fovCircle.Position.X.Offset, fovCircle.Position.Y.Offset)).Magnitude

            if distance < fovCircle.Size.X.Offset / 2 then
                if fovsetting.Wallcheck then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.FilterDescendantsInstances = { v.Character, localPlayer.Character }

                    local rayOrigin = localPlayer.Character.Head.Position
                    local directionToPlayer = (v.Character.Head.Position - rayOrigin).Unit
                    local distanceToPlayer = (v.Character.Head.Position - rayOrigin).Magnitude

                    local rayResult = workspace:Raycast(rayOrigin, directionToPlayer * distanceToPlayer, rayParams)
                    if rayResult then
                        continue
                    end
                end

                local mouseDistance = (mouse.Hit.Position - characterPos).Magnitude
                if mouseDistance < closestDistance then
                    closestDistance = mouseDistance
                    closestPlayer = v
                end
            end
        end
    end

    return closestPlayer
end

-- Optimized update loop
local target
local updateConnection
updateConnection = rs.RenderStepped:Connect(function()
    pcall(function()
        target = closestopp()
        
        -- Update FOV position
        fovCircle.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        
        -- Handle snaplines
        if target and fovsetting.Snaplines then
            Snaplines.Visible = true
            Snaplines.From = UserInputService:GetMouseLocation()
            local humanoidRootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local Tuple, Visible = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                Snaplines.To = Vector2.new(Tuple.X, Tuple.Y)
            end
        else
            Snaplines.Visible = false
        end

        -- Handle highlighting
        if fovsetting.Highlight and target and target.Character then
            local hi = Instance.new("Highlight", target.Character)
            hi.FillColor = fovsetting.Fill
            hi.OutlineColor = fovsetting.Outline
            game:GetService("Debris"):AddItem(hi, 0.1)
        end
    end)
end)


function getbody()
    local t = {}
    for i, v in next, game:GetService("Players").LocalPlayer.Character:GetChildren() do
        if v:IsA("BasePart") then
            table.insert(t, tostring(v))
        end
    end
    return t
end
local body = getbody()

Window:CreateToggle(MainTab, "Silent Aim", false, function(state)
    silentsettings.Enabled = state
end)
Window:CreateToggle(MainTab, "Randomize Hitbox", false, function(state)
    silentsettings.RandomRedirection = state
end)
Window:CreateSlider(MainTab, "Hitchance", 1, 100, 100, function(value)
silentsettings.Hitchance = value
end)
Window:CreateToggle(MainTab, "FOV Circle", false, function(state)
    fovCircle.Visible = state
end)
Window:CreateSlider(MainTab, "FOV Size", 1, 1000, 200, function(value)
    fovCircle.Size = UDim2.new(0, value, 0, value)
end)
Window:CreateToggle(MainTab, "Snaplines", false, function(state)
    fovsetting.Snaplines = state
end)
Window:CreateToggle(MainTab, "Ignore Dead", false, function(state)
    fovsetting.Dead = value
end)
fovCircle.Visible = false

-- Fixed silent aim hooks with proper hitchance system
if hookmetamethod and game.PlaceId ~= 2788229376 then
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Include
    local silent
    silent = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local args = { ... }
        if getnamecallmethod() == "Raycast" and target and target.Character then
            if silentsettings.Enabled and tostring(getfenv(0).script) ~= "Kurupted" then
                -- Check if hit should register based on hitchance
                if not shouldHit() then
                    return silent(Self, ...)  -- Return original raycast without modification
                end
                
                local origin = args[1]
                local targetPosition = target.Character[silentsettings.HitPart].Position
                if silentsettings.RandomRedirection then
                    targetPosition = target.Character[body[math.random(1, #body)]].Position
                end
                
                if silentsettings.Wallbang then
                    raycastParams.FilterDescendantsInstances = { target.Character }
                    args[3] = raycastParams
                end
                args[2] = (targetPosition - origin).Unit * silentsettings.Range
                return silent(Self, table.unpack(args))
            end
        end
        return silent(Self, ...)
    end))
    
    -- Optimized ignore list generation
    function getignorelist()
        local t = {}
        for i, v in next, workspace:GetChildren() do
            if target and target.Character and v ~= nil and v ~= target.Character and (not target.Character:IsDescendantOf(v)) then
                table.insert(t, v)
            end
        end
        return t
    end
    
    local ignorelist = {}
    task.spawn(function()
        while task.wait(0.1) do -- Reduced frequency for better performance
            pcall(function()
                if silentsettings.Wallbang and target and target.Character then
                    ignorelist = getignorelist()
                end
            end)
        end
    end)
    
    local ray
    ray = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local args = { ... }
        local method = getnamecallmethod()
        if (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") and silentsettings.Enabled and tostring(getfenv(0).script) ~= "Kurupted" then
            local s = tostring(getfenv(0).script.Parent)
            local vvvv = tostring(getfenv(0).script)
            if target and target.Character and (s ~= "CameraModule" and s ~= "PlayerModule" and vvvv ~= "CameraModule") then
                -- Check if hit should register based on hitchance
                if not shouldHit() then
                    return ray(Self, ...)  -- Return original ray without modification
                end
                
                local origin = args[1].Origin
                local targetPosition = target.Character[silentsettings.HitPart].Position
                if silentsettings.RandomRedirection then
                    targetPosition = target.Character[body[math.random(1, #body)]].Position
                end
                
                if silentsettings.Wallbang then
                    if (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay") then
                        args[2] = ignorelist
                    end
                    if (method == "FindPartOnRayWithWhitelist") then
                        args[2] = { target.Character }
                    end
                end
                
                local direction = (targetPosition - origin).Unit
                args[1] = Ray.new(origin, direction * silentsettings.Range)
                return ray(Self, table.unpack(args))
            end
        end
        return ray(Self, ...)
    end))
    
    local indexhook
    indexhook = hookmetamethod(game, "__index", newcclosure(function(Self, Value)
        if tostring(Value) == "Hit" and silentsettings.Enabled and (tostring(getfenv(0).script) ~= "Kurupted") and target and target.Character then
            -- Check if hit should register based on hitchance
            if not shouldHit() then
                return indexhook(Self, Value)  -- Return original hit without modification
            end
            
            local cframe = target.Character[silentsettings.HitPart]
            if silentsettings.RandomRedirection then
                cframe = target.Character[body[math.random(1, #body)]]
            end
            local cframe1 = cframe.CFrame
            return cframe1
        end
        return indexhook(Self, Value)
    end))
end
local player = game.Players.LocalPlayer

local function teleport(x, y, z)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    humanoid:ChangeState(0)
    repeat task.wait() until not player:GetAttribute("LastACPos")
    hrp.CFrame = CFrame.new(x, y, z)
end

Window:CreateLabel(TeleportTab, "Teleport Options")

local locations = {
    ["[🏦] Bank Tools"] = Vector3.new(-387, 340, -559),
    ["[🔫] Gun Shop 1"] = Vector3.new(92971, 122097, 17018),
    ["[🔫] Gun Shop 2"] = Vector3.new(66189, 123616, 5745),
    ["[🎒] BackPack Shop"] = Vector3.new(-675, 254, -686),
    ["[🌴] Zotic Shop"] = Vector3.new(-1524, 274, -985),
    ["[👕] Drip Store"] = Vector3.new(67467, 10489, 545),
    ["[🚗] Dealership"] = Vector3.new(-376, 253, -1248),
    ["[🏦] Bank"] = Vector3.new(-206, 284, -1204),
    ["[🏡] Penthouse"] = Vector3.new(-123, 417, -579),
    ["[🔫] Exotic Guns"] = Vector3.new(60828, 87609, -351),
    ["[6️⃣] 600Block"] = Vector3.new(-1024, 254, -296),
    ["[💼] Safe"] = Vector3.new(-189, 295, -1010),
    ["[🏨] Woody's Hotel"] = Vector3.new(-945, 253, -946),
    ["[🧺] Laundromat"] = Vector3.new(-988, 254, -685),
    ["[🗼] Riverpark Towers"] = Vector3.new(-705, 316, -790),
    ["[🚧] Construction"] = Vector3.new(-1729, 371, -1172),
    ["[🚓] NYPD"] = Vector3.new(-1403, 255, -3167),
    ["[🟠] Prison"] = Vector3.new(-1128, 255, -3312)
}

-- Create teleport buttons
for name, pos in pairs(locations) do
    Window:CreateButton(TeleportTab, name, function()
        teleport(pos.X, pos.Y, pos.Z)
    end)
end




--- Player Tab
Window:CreateLabel(PlayerTab, "Player Options")





Window:CreateToggle(PlayerTab, "Keep Guns on Death", false, function(state)
    keepGunsEnabled = state
    if keepGunsEnabled then
        triggerKeepGuns()
    end
end)

Window:CreateToggle(PlayerTab, "NoClip", false, function(state)
    _G.noclip = state
end)



Window:CreateToggle(PlayerTab, "Anti-Sleep", false, function(state)
        local sleepScript = LocalPlayer.PlayerGui.SleepGui.Frame.sleep.SleepBar:FindFirstChild("sleepScript")
    if sleepScript then
        sleepScript.Disabled = state
    end
end)
Window:CreateToggle(PlayerTab, "Anti-Hunger", false, function(state)
    local hungerScript = LocalPlayer.PlayerGui.Hunger.Frame.Frame.Frame:FindFirstChild("HungerBarScript")
    if hungerScript then
        hungerScript.Disabled = state
    end
end)

Window:CreateToggle(PlayerTab, "Inf-Stamina", false, function(state)
    local staminaScript = LocalPlayer.PlayerGui.Run.Frame.Frame.Frame:FindFirstChild("StaminaBarScript")
    if staminaScript then
        staminaScript.Disabled = state
    end
end)
Window:CreateToggle(PlayerTab, "Inf-Jump", false, function(state)
local InfiniteJumpEnabled = state
game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local humanoid = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)
end)
Window:CreateToggle(PlayerTab, "Anti-Rent Pay", false, function(state)
 local rentScript = LocalPlayer.PlayerGui.RentGui:FindFirstChild("LocalScript")
    if rentScript then
        rentScript.Disabled = state
    end
end)
local proximityPrompts = {}
local promptConnection

Window:CreateToggle(PlayerTab, "Instant Prompts", false, function(state)
  local function handlePrompt(prompt, isEnabled)
        if isEnabled then
            if not proximityPrompts[prompt] then
                proximityPrompts[prompt] = prompt.HoldDuration
            end
            prompt.HoldDuration = 0
        else
            if proximityPrompts[prompt] then
                prompt.HoldDuration = proximityPrompts[prompt]
                proximityPrompts[prompt] = nil
            end
        end
    end

    local function setHoldDurationToZero()
        for _, prompt in pairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                handlePrompt(prompt, enabled)
            end
        end
    end

    if promptConnection then
        promptConnection:Disconnect()
        promptConnection = nil
    end

    if state then
        promptConnection = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                handlePrompt(descendant, true)
            end
        end)
    end
    setHoldDurationToZero()
end)

Window:CreateButton(PlayerTab, "Steal Vehicle", function()
        loadstring(game:HttpGet("https://pastebin.com/raw/1gcNnBYE"))()
end)




        local Lighting = game:GetService("Lighting")
        
        -- Store original values
        local originalValues = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ShadowSoftness = Lighting.ShadowSoftness,
            GlobalShadows = Lighting.GlobalShadows
        }
        
        local lightingEnabled = false
        
        local function setLightingState(enabled)
            lightingEnabled = enabled
        
            if enabled then
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
                Lighting.Brightness = 2
                Lighting.ShadowSoftness = 0
                Lighting.GlobalShadows = false
            else
                -- Restore original values
                Lighting.Ambient = originalValues.Ambient
                Lighting.OutdoorAmbient = originalValues.OutdoorAmbient
                Lighting.Brightness = originalValues.Brightness
                Lighting.ShadowSoftness = originalValues.ShadowSoftness
                Lighting.GlobalShadows = originalValues.GlobalShadows
            end
        end
        
        local Lighting = game:GetService("Lighting")
        
        local originalTimeOfDay = Lighting.TimeOfDay
        local originalClockTime = Lighting.ClockTime
        local originalTimeSpeed = Lighting:GetMinutesAfterMidnight() -- Just in case
        
        local timeOverrideEnabled = false
        
        local function setTimeOverride(enabled)
            timeOverrideEnabled = enabled
        
            if enabled then
                -- Save current values
                originalTimeOfDay = Lighting.TimeOfDay
                originalClockTime = Lighting.ClockTime
                originalTimeSpeed = Lighting:GetMinutesAfterMidnight()
        
                -- Set time to day and freeze it
                Lighting.ClockTime = 12 -- Noon
                Lighting:SetMinutesAfterMidnight(720) -- 12 * 60
                Lighting.TimeOfDay = "12:00:00"
                game:GetService("RunService").Stepped:Connect(function()
                    if timeOverrideEnabled then
                        Lighting.ClockTime = 12
                    end
                end)
            else
                -- Restore original time
                Lighting.TimeOfDay = originalTimeOfDay
                Lighting.ClockTime = originalClockTime
            end
    end

Window:CreateLabel(MiscTab, "Misc Options")

    
Window:CreateToggle(MiscTab, "Full Bright", false, function(state)
    gay = state
    if gay then
                setLightingState(true)
    else
                setLightingState(false)
    end
end)





Window:CreateButton(MiscTab, "Open Market", function()
  local marketGui = LocalPlayer.PlayerGui:FindFirstChild("Bronx Market 2")
    if marketGui then
        marketGui.Enabled = true
    end
end)

 
Window:CreateToggle(MiscTab, "Character Spin", false, function(state)
_G.spin = state
end)


Window:CreateSlider(MiscTab, "Spin Speed", 1, 100, 20, function(value)
_G.spinSpeed = value
end) 

local target = nil
Window:CreateLabel(TargetTab, "Target Options")
Window:CreateToggle(TargetTab, "Kill All", false, function(state)
local Players = game:GetService("Players")
            local bringT = {}
            
            local function getRoot(char)
                return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            end
            
            local function FindInTable(tbl, val)
                for _, v in pairs(tbl) do
                    if v == val then
                        return true
                    end
                end
                return false
            end
            
            _G.loopbring = state

            
            local function loopBringAll()
                -- Clear existing table
                bringT = {}
                
                -- Add all players except local player
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Players.LocalPlayer then
                        table.insert(bringT, player.Name)
                    end
                end
                
                -- Start loop
                while _G.loopbring and #bringT > 0 do
                    local localPlayer = Players.LocalPlayer
                    if localPlayer and localPlayer.Character and getRoot(localPlayer.Character) then
                        local localRoot = getRoot(localPlayer.Character)
                        
                        for _, playerName in pairs(bringT) do
                            local player = Players:FindFirstChild(playerName)
                            if player and player.Character then
                                local char = player.Character
                                local root = getRoot(char)
                                if root then
                                    root.CFrame = localRoot.CFrame + Vector3.new(20, 1, 0)
                                end
                            end
                        end
                    end
                    wait(0.1)
                end
            end
            
            -- Toggle system
            while true do
                if _G.loopbring then
                    loopBringAll()
                else
                    bringT = {} -- Clear the table when turned off
                end
                wait(1)
            end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local selectedPlayer = nil

-- 🔍 Utility: Find player by partial name (display or username)
local function findPlayerByPartialName(partial)
    partial = partial:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.DisplayName:lower():find(partial, 1, true) or player.Name:lower():find(partial, 1, true) then
                return player
            end
        end
    end
    return nil
end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function safeTeleport(x, y, z)
    local character = getCharacter()
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
    end
end

Window:CreateTextBox(TargetTab, "Target Player", "Type part of name...", function(input)
    local match = findPlayerByPartialName(input)
    if match then
        selectedPlayer = match
        print("Selected Player:", selectedPlayer.Name)
    else
        selectedPlayer = nil
        print("No player found.")
    end
end)

-- 👁️ Spectate Toggle
Window:CreateToggle(TargetTab, "Spectate Selected Player", false, function(state)
    if state then
        if selectedPlayer and selectedPlayer.Character then
            workspace.CurrentCamera.CameraSubject = selectedPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    else
        local character = getCharacter()
        if character and character:FindFirstChildOfClass("Humanoid") then
            workspace.CurrentCamera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
        end
    end
end)

-- ⚡ Teleport Once
Window:CreateButton(TargetTab, "Teleport To Selected Player", function()
    if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = selectedPlayer.Character.HumanoidRootPart.Position
        teleport(pos.X, pos.Y, pos.Z)
    end
end)

-- ♻️ Loop Teleport
local loopTeleport = false
Window:CreateToggle(TargetTab, "Loop Teleport To Selected Player", false, function(state)
    loopTeleport = state
    if loopTeleport then
        task.spawn(function()
            while loopTeleport do
                if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = selectedPlayer.Character.HumanoidRootPart.Position
                    teleport(pos.X, pos.Y, pos.Z)
                end
                task.wait(0.1)
            end
        end)
    end
end)

-- 🧲 Loop Bring
local loopBring = false
Window:CreateToggle(TargetTab, "Loop Bring Selected Player", false, function(state)
    loopBring = state
    if loopBring then
        task.spawn(function()
            while loopBring do
                if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myChar = getCharacter()
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        selectedPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(myChar.HumanoidRootPart.Position)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)






Window:CreateLabel(FarmingTab, "Farming Options")

Window:CreateToggle(FarmingTab, "Rob Studio", false, function(state)
    if not state then return end
    
  local proximityPrompts = {}
local function setHoldDurationToZero()
    for _, prompt in pairs(game:GetService("Workspace"):GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            proximityPrompts[prompt] = proximityPrompts[prompt] or prompt.HoldDuration
            prompt.HoldDuration = 0
        end
    end
end

-- Handle new ProximityPrompts
game:GetService("Workspace").DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        proximityPrompts[descendant] = proximityPrompts[descendant] or descendant.HoldDuration
        descendant.HoldDuration = 0
    end
end)

setHoldDurationToZero()

local function teleportAndFire(path)
    local prompt = path:FindFirstChild("Prompt")
    if prompt and prompt.Enabled then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = path.CFrame
        wait(0.65)
        fireproximityprompt(prompt)
        return true
    end
    return false
end

-- Try to find and fire prompts
local foundAnyPrompt = false

for i = 1, 3 do
    local path = game:GetService("Workspace").StudioPay.Money["StudioPay" .. i]:FindFirstChild("StudioMoney1")
    if path and teleportAndFire(path) then
        foundAnyPrompt = true
    end
    wait(0.4)
end

-- If no prompts were found and fired, send notification
if not foundAnyPrompt then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Cooldown",
        Text = "Studio is on cooldown.",
        Duration = 4
    })
end
end)


Window:CreateToggle(FarmingTab, "Construction Farm", false, function(state)
    if not state then return end
getgenv().cfg = {}
local player = game.Players.LocalPlayer
local jobStopped = false
local function teleport(x, y, z)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    humanoid:ChangeState(0)
    repeat task.wait() until not player:GetAttribute("LastACPos")
    hrp.CFrame = CFrame.new(x, y, z)
end
pcall(function()
    repeat task.wait(3) until game:IsLoaded()
    repeat task.wait(3) until player.PlayerGui.BronxLoadscreen
end)
pcall(function()
    repeat firesignal(player.PlayerGui.BronxLoadscreen.Frame.play.MouseButton1Click) until not player.PlayerGui:FindFirstChild("BronxLoadscreen")
end)
pcall(function()
    repeat task.wait(1) until not player.PlayerGui:FindFirstChild("BronxLoadscreen")
end)
local jobPrompt = workspace.ConstructionStuff["Start Job"].Prompt
local jobCFrame = workspace.ConstructionStuff["Start Job"].CFrame
local function startjob()
    if jobStopped then return end
    if not player:GetAttribute("WorkingJob") or player:GetAttribute("WorkingJob") == false then
        teleport(jobCFrame.X, jobCFrame.Y, jobCFrame.Z)
        fireproximityprompt(jobPrompt)
    end
end
local function endjob()
    teleport(jobCFrame.X, jobCFrame.Y, jobCFrame.Z)
    fireproximityprompt(jobPrompt)
    jobStopped = true
end
local function autoequipwood()
    if jobStopped then return end
    if player.Backpack:FindFirstChild("PlyWood") then
        player.Backpack.PlyWood.Parent = player.Character
    end
end
local function wood()
    if jobStopped then return end
    for _, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Wall" then
            fireproximityprompt(v)
        end
    end
end
local function grabwood()
    if jobStopped then return end
    for _, v in pairs(workspace.ConstructionStuff["Grab Wood"]:GetChildren()) do
        if v:IsA("ProximityPrompt") and v.ActionText == "Wood" then
            fireproximityprompt(v)
        end
    end
end
local function mainautofarm()
    if jobStopped then return end
    for _, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
        if v:IsA("Part") and string.find(v.Name, "Prompt") then
            local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
            if not string.find(text, "RESETS") then
                teleport(v.Position.X, v.Position.Y, v.Position.Z)
            end
        end
    end
    if not (player.Backpack:FindFirstChild("PlyWood") or player.Character:FindFirstChild("PlyWood")) then
        teleport(-1728, 371, -1177)
    end
end
local function checkfornowood()
    if jobStopped then return end
    local noWood = true
    for _, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
        if v:IsA("Part") and string.find(v.Name, "Prompt") then
            local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
            if not string.find(text, "RESETS") then
                noWood = false
                break
            end
        end
    end
    if noWood then
        endjob()
    end
end
task.spawn(function()
    while task.wait(1/4) do
        if jobStopped then break end
        xpcall(startjob, debug.traceback)
    end
end)
task.spawn(function()
    while task.wait(1/6) do
        if jobStopped then break end
        xpcall(wood, debug.traceback)
        xpcall(grabwood, debug.traceback)
        xpcall(autoequipwood, debug.traceback)
        xpcall(mainautofarm, debug.traceback)
    end
end)
task.spawn(function()
    while task.wait(4) do
        if jobStopped then break end
        xpcall(checkfornowood, debug.traceback)
    end
end)
end)


Window:CreateLabel(GunModsTab, "Gun Mods Options")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function forEachGun(callback)
	for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
		if item:FindFirstChild("Setting") then
			local success, module = pcall(require, item.Setting)
			if success and module then
				callback(module)
			end
		end
	end
end

Window:CreateToggle(GunModsTab, "Infinite Ammo", false, function(enabled)
	forEachGun(function(m)
		m.LimitedAmmoEnabled = false
		m.AmmoPerMag = enabled and 1e6 or 30
		m.Ammo = enabled and 1e6 or 30
		m.MaxAmmo = enabled and 1e6 or 120
	end)
end)

Window:CreateToggle(GunModsTab, "Auto Fire", false, function(enabled)
	forEachGun(function(m)
		m.Auto = enabled
	end)
end)

Window:CreateTextBox(GunModsTab, "Fire Rate", "0.09", function(text)
	local value = tonumber(text)
	if value then
		forEachGun(function(m)
			m.FireRate = math.clamp(value, 0.01, 5)
		end)
	end
end)

Window:CreateTextBox(GunModsTab, "Base Damage", "100", function(text)
	local value = tonumber(text)
	if value then
		forEachGun(function(m)
			m.BaseDamage = value == 0 and math.huge or value
		end)
	end
end)

Window:CreateTextBox(GunModsTab, "Weapon Range", "1000", function(text)
	local value = tonumber(text)
	if value then
		forEachGun(function(m)
			m.Range = value
		end)
	end
end)

Window:CreateTextBox(GunModsTab, "Accuracy", "10", function(text)
	local value = tonumber(text)
	if value then
		forEachGun(function(m)
			m.Accuracy = math.clamp(value, 1, 10)
		end)
	end
end)

Window:CreateToggle(GunModsTab, "No Recoil", false, function(enabled)
	forEachGun(function(m)
		m.Recoil = enabled and 0 or 1
		m.CameraRecoilingEnabled = not enabled
	end)
end)

Window:CreateToggle(GunModsTab, "No Jam", false, function(enabled)
	forEachGun(function(m)
		m.JamChance = enabled and 0 or 0.1
	end)
end)


local function GetVehicleFromDescendant(Descendant)
    return Descendant:FindFirstAncestor(LocalPlayer.Name .. "'s Car")
        or (Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent)
        or (Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent)
        or Descendant:FindFirstAncestorWhichIsA("Model")
end

local velocityEnabled = true
local flightEnabled = false
local flightSpeed = 1
local defaultCharacterParent

Window:CreateLabel(VehicleModsTab, "Vehicle Mods Options")

Window:CreateToggle(VehicleModsTab, "Flight", false, function(enabled)
flightEnabled = enabled
end)
Window:CreateSlider(VehicleModsTab, "Flight Speed", 1, 8000, 100, function(value)
flightSpeed = value / 100
end) 

game:GetService("RunService").Stepped:Connect(function()
    local Character = LocalPlayer.Character
    if flightEnabled == true then
        if Character and typeof(Character) == "Instance" then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid and typeof(Humanoid) == "Instance" then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
                    local Vehicle = GetVehicleFromDescendant(SeatPart)
                    if Vehicle and Vehicle:IsA("Model") then
                        Character.Parent = Vehicle
                        if not Vehicle.PrimaryPart then
                            if SeatPart.Parent == Vehicle then
                                Vehicle.PrimaryPart = SeatPart
                            else
                                Vehicle.PrimaryPart = Vehicle:FindFirstChildWhichIsA("BasePart")
                            end
                        end
                        local PrimaryPartCFrame = Vehicle:GetPrimaryPartCFrame()
                        Vehicle:SetPrimaryPartCFrame(
                            CFrame.new(PrimaryPartCFrame.Position, PrimaryPartCFrame.Position + workspace.CurrentCamera.CFrame.LookVector)
                            * (UserInputService:GetFocusedTextBox() and CFrame.new(0, 0, 0) or CFrame.new(
                                (UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.A) and -flightSpeed) or 0,
                                (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed / 2) or (UserInputService:IsKeyDown(Enum.KeyCode.Q) and -flightSpeed / 2) or 0,
                                (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed) or (UserInputService:IsKeyDown(Enum.KeyCode.W) and -flightSpeed) or 0
                            ))
                        )
                        SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end
    else
        if Character and typeof(Character) == "Instance" then
            Character.Parent = defaultCharacterParent or Character.Parent
            defaultCharacterParent = Character.Parent
        end
    end
end)

local stopVehicleActive = false
local stopVehicleEndTime = 0
local persistentStopConn = nil
if not persistentStopConn then
    persistentStopConn = game:GetService("RunService").Heartbeat:Connect(function()
        if stopVehicleActive then
            local Character = LocalPlayer.Character
            if Character and typeof(Character) == "Instance" then
                local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid and typeof(Humanoid) == "Instance" then
                    local SeatPart = Humanoid.SeatPart
                    if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
                        SeatPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        SeatPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end
            if stopVehicleEndTime ~= math.huge and tick() >= stopVehicleEndTime then
                stopVehicleActive = false
                stopVehicleEndTime = 0
            end
        end
    end)
end
local velocityMult = 0.025
Window:CreateSlider(VehicleModsTab, "Multiplier (Thousandths)", 1, 50, 25, function(value)
flightSpeed = value / 100
end) 
local speedMultiplierActive = false
local speedMultiplierConnection
Window:CreateButton(VehicleModsTab, "Apply Speed Multiplier", function()
 speedMultiplierActive = not speedMultiplierActive
    if speedMultiplierActive then
        if speedMultiplierConnection then speedMultiplierConnection:Disconnect() end
        speedMultiplierConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local Character = LocalPlayer.Character
            if Character and typeof(Character) == "Instance" then
                local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
                if Humanoid and typeof(Humanoid) == "Instance" then
                    local SeatPart = Humanoid.SeatPart
                    if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
                        -- Only apply if moving
                        local vel = SeatPart.AssemblyLinearVelocity
                        if vel.Magnitude > 0.1 then
                            SeatPart.AssemblyLinearVelocity = Vector3.new(vel.X * (1 + velocityMult), vel.Y, vel.Z * (1 + velocityMult))
                        end
                    else
                        -- Left the car, stop applying
                        speedMultiplierActive = false
                        if speedMultiplierConnection then speedMultiplierConnection:Disconnect() speedMultiplierConnection = nil end
                    end
                end
            end
        end)
        -- Bind shift to stop vehicle while multiplier is active
        if not speedMultiplierShiftConn then
            local UserInputService = game:GetService("UserInputService")
            speedMultiplierShiftConn = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == Enum.KeyCode.F then
                    stopVehicleActive = true
                    stopVehicleEndTime = math.huge
                end
            end)
            UserInputService.InputEnded:Connect(function(input, processed)
                if input.KeyCode == Enum.KeyCode.F then
                    stopVehicleActive = false
                    stopVehicleEndTime = 0
                end
            end)
        end
    else
        if speedMultiplierConnection then speedMultiplierConnection:Disconnect() speedMultiplierConnection = nil end
        if speedMultiplierShiftConn then speedMultiplierShiftConn:Disconnect() speedMultiplierShiftConn = nil end
    end
end)
Window:CreateLabel(VehicleModsTab, "Click (F) to stop vehicle")




Window:CreateLabel(VisualsTab, "Visual Options")

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()
ESP.Enabled = false
ESP.ShowBox = false
ESP.BoxType = "Corner Box Esp"
ESP.ShowName = false
ESP.ShowHealth = false
ESP.ShowTracer = false
ESP.ShowDistance = false
ESP.ShowSkeletons = false

-- ESP Toggles
Window:CreateToggle(VisualsTab, "ESP", false, function(val)
    ESP.Enabled = val
end)

Window:CreateToggle(VisualsTab, "Box", false, function(val)
    ESP.ShowBox = val
end)

Window:CreateToggle(VisualsTab, "Health", false, function(val)
    ESP.ShowHealth = val
end)

Window:CreateToggle(VisualsTab, "Name", false, function(val)
    ESP.ShowName = val
end)

Window:CreateToggle(VisualsTab, "Distance", false, function(val)
    ESP.ShowDistance = val
end)

Window:CreateToggle(VisualsTab, "Tracer", false, function(val)
    ESP.ShowTracer = val
end)

-- Radar Button
Window:CreateButton(VisualsTab, "Radar", function()
    local Players = game:service("Players")
                local Player = Players.LocalPlayer
                local Mouse = Player:GetMouse()
                local Camera = game:service("Workspace").CurrentCamera
                local RS = game:service("RunService")
                local UIS = game:service("UserInputService")

                repeat wait() until Player.Character ~= nil and Player.Character.PrimaryPart ~= nil

                local LerpColorModule = loadstring(game:HttpGet("https://pastebin.com/raw/wRnsJeid"))()
                local HealthBarLerp = LerpColorModule:Lerp(Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0))

                local function NewCircle(Transparency, Color, Radius, Filled, Thickness)
                    local c = Drawing.new("Circle")
                    c.Transparency = Transparency
                    c.Color = Color
                    c.Visible = false
                    c.Thickness = Thickness
                    c.Position = Vector2.new(0, 0)
                    c.Radius = Radius
                    c.NumSides = math.clamp(Radius*55/100, 10, 75)
                    c.Filled = Filled
                    return c
                end

                local RadarInfo = {
                    Position = Vector2.new(200, 200),
                    Radius = 100,
                    Scale = 1,
                    RadarBack = Color3.fromRGB(10, 10, 10),
                    RadarBorder = Color3.fromRGB(75, 75, 75),
                    LocalPlayerDot = Color3.fromRGB(255, 255, 255),
                    PlayerDot = Color3.fromRGB(255, 60, 170),
                    Team = Color3.fromRGB(255, 60, 170),
                    Enemy = Color3.fromRGB(255, 60, 170),
                    Health_Color = true,
                    Team_Check = true
                }

                local RadarBackground = NewCircle(0.9, RadarInfo.RadarBack, RadarInfo.Radius, true, 1)
                RadarBackground.Visible = true
                RadarBackground.Position = RadarInfo.Position

                local RadarBorder = NewCircle(0.75, RadarInfo.RadarBorder, RadarInfo.Radius, false, 3)
                RadarBorder.Visible = true
                RadarBorder.Position = RadarInfo.Position

                local function GetRelative(pos)
                    local char = Player.Character
                    if char ~= nil and char.PrimaryPart ~= nil then
                        local pmpart = char.PrimaryPart
                        local camerapos = Vector3.new(Camera.CFrame.Position.X, pmpart.Position.Y, Camera.CFrame.Position.Z)
                        local newcf = CFrame.new(pmpart.Position, camerapos)
                        local r = newcf:PointToObjectSpace(pos)
                        return r.X, r.Z
                    else
                        return 0, 0
                    end
                end

                local function PlaceDot(plr)
                    local PlayerDot = NewCircle(1, RadarInfo.PlayerDot, 3, true, 1)

                    local function Update()
                        local c 
                        c = game:service("RunService").RenderStepped:Connect(function()
                            local char = plr.Character
                            if char and char:FindFirstChildOfClass("Humanoid") and char.PrimaryPart ~= nil and char:FindFirstChildOfClass("Humanoid").Health > 0 and char:FindFirstChild("Head") ~= nil then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                local scale = RadarInfo.Scale
                                local relx, rely = GetRelative(char.PrimaryPart.Position)
                                local newpos = RadarInfo.Position - Vector2.new(relx * scale, rely * scale) 

                                if (newpos - RadarInfo.Position).magnitude < RadarInfo.Radius-2 then 
                                    PlayerDot.Radius = 3   
                                    PlayerDot.Position = newpos
                                    PlayerDot.Visible = true
                                else 
                                    local dist = (RadarInfo.Position - newpos).magnitude
                                    local calc = (RadarInfo.Position - newpos).unit * (dist - RadarInfo.Radius)
                                    local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
                                    PlayerDot.Radius = 2
                                    PlayerDot.Position = inside
                                    PlayerDot.Visible = true
                                end

                                PlayerDot.Color = RadarInfo.PlayerDot
                                if RadarInfo.Team_Check then
                                    if plr.TeamColor == Player.TeamColor then
                                        PlayerDot.Color = RadarInfo.Team
                                    else
                                        PlayerDot.Color = RadarInfo.Enemy
                                    end
                                end

                                if RadarInfo.Health_Color then
                                    PlayerDot.Color = HealthBarLerp(hum.Health / hum.MaxHealth)
                                end
                            else 
                                PlayerDot.Visible = false
                                if Players:FindFirstChild(plr.Name) == nil then
                                    PlayerDot:Remove()
                                    c:Disconnect()
                                end
                            end
                        end)
                    end
                    coroutine.wrap(Update)()
                end

                for _,v in pairs(Players:GetChildren()) do
                    if v.Name ~= Player.Name then
                        PlaceDot(v)
                    end
                end

                local function NewLocalDot()
                    local d = Drawing.new("Triangle")
                    d.Visible = true
                    d.Thickness = 1
                    d.Filled = true
                    d.Color = RadarInfo.LocalPlayerDot
                    d.PointA = RadarInfo.Position + Vector2.new(0, -6)
                    d.PointB = RadarInfo.Position + Vector2.new(-3, 6)
                    d.PointC = RadarInfo.Position + Vector2.new(3, 6)
                    return d
                end

                local LocalPlayerDot = NewLocalDot()

                Players.PlayerAdded:Connect(function(v)
                    if v.Name ~= Player.Name then
                        PlaceDot(v)
                    end
                    LocalPlayerDot:Remove()
                    LocalPlayerDot = NewLocalDot()
                end)

                coroutine.wrap(function()
                    local c 
                    c = game:service("RunService").RenderStepped:Connect(function()
                        if LocalPlayerDot ~= nil then
                            LocalPlayerDot.Color = RadarInfo.LocalPlayerDot
                            LocalPlayerDot.PointA = RadarInfo.Position + Vector2.new(0, -6)
                            LocalPlayerDot.PointB = RadarInfo.Position + Vector2.new(-3, 6)
                            LocalPlayerDot.PointC = RadarInfo.Position + Vector2.new(3, 6)
                        end
                        RadarBackground.Position = RadarInfo.Position
                        RadarBackground.Radius = RadarInfo.Radius
                        RadarBackground.Color = RadarInfo.RadarBack

                        RadarBorder.Position = RadarInfo.Position
                        RadarBorder.Radius = RadarInfo.Radius
                        RadarBorder.Color = RadarInfo.RadarBorder
                    end)
                end)()

                local inset = game:service("GuiService"):GetGuiInset()

                local dragging = false
                local offset = Vector2.new(0, 0)
                UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - RadarInfo.Position).magnitude < RadarInfo.Radius then
                        offset = RadarInfo.Position - Vector2.new(Mouse.X, Mouse.Y)
                        dragging = true
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                coroutine.wrap(function()
                    local dot = NewCircle(1, Color3.fromRGB(255, 255, 255), 3, true, 1)
                    local c 
                    c = game:service("RunService").RenderStepped:Connect(function()
                        if (Vector2.new(Mouse.X, Mouse.Y + inset.Y) - RadarInfo.Position).magnitude < RadarInfo.Radius then
                            dot.Position = Vector2.new(Mouse.X, Mouse.Y + inset.Y)
                            dot.Visible = true
                        else 
                            dot.Visible = false
                        end
                        if dragging then
                            RadarInfo.Position = Vector2.new(Mouse.X, Mouse.Y) + offset
                        end
                    end)
                end)()
end)

-- Chams
Window:CreateToggle(VisualsTab, "Chams", false, function(enabled)
    local FillColor = Color3.fromRGB(255, 60, 170)
    local DepthMode = "AlwaysOnTop"
    local FillTransparency = 0
    local OutlineColor = Color3.fromRGB(15, 15, 15)
    local OutlineTransparency = 0
    local CoreGui = game:FindService("CoreGui")
    local Players = game:FindService("Players")
    local lp = Players.LocalPlayer
    local connections = {}
    local Storage = Instance.new("Folder")
    Storage.Parent = CoreGui
    Storage.Name = "Highlight_Storage"

    _G.ChamsEnabled = enabled

    local function Highlight(plr)
        if plr == lp then return end

        local Highlight = Instance.new("Highlight")
        Highlight.Name = plr.Name
        Highlight.FillColor = FillColor
        Highlight.DepthMode = DepthMode
        Highlight.FillTransparency = FillTransparency
        Highlight.OutlineColor = OutlineColor
        Highlight.OutlineTransparency = 0
        Highlight.Parent = Storage
        Highlight.Enabled = _G.ChamsEnabled

        local plrchar = plr.Character
        if plrchar then
            Highlight.Adornee = plrchar
        end
        connections[plr] = plr.CharacterAdded:Connect(function(char)
            Highlight.Adornee = char
        end)
    end

    Players.PlayerAdded:Connect(Highlight)
    for i,v in next, Players:GetPlayers() do
        Highlight(v)
    end

    Players.PlayerRemoving:Connect(function(plr)
        local plrname = plr.Name
        if Storage[plrname] then
            Storage[plrname]:Destroy()
        end
        if connections[plr] then
            connections[plr]:Disconnect()
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        for _, highlight in pairs(Storage:GetChildren()) do
            highlight.Enabled = _G.ChamsEnabled
        end
    end)
end)

-- View Tracers
Window:CreateToggle(VisualsTab, "View Tracers", false, function(enabled)
 local Settings = {
        Color = Color3.fromRGB(255, 203, 138),
        Thickness = 1,
        Transparency = 1,
        AutoThickness = true,
        Length = 15,
        Smoothness = 0.2
    }

    _G.toggletracer = enabled

    local player = game:GetService("Players").LocalPlayer
    local camera = game:GetService("Workspace").CurrentCamera

    local function ESP(plr)
        local line = Drawing.new("Line")
        line.Visible = false
        line.From = Vector2.new(0, 0)
        line.To = Vector2.new(0, 0)
        line.Color = Settings.Color
        line.Thickness = Settings.Thickness
        line.Transparency = Settings.Transparency

        local function Updater()
            local connection
            connection = game:GetService("RunService").RenderStepped:Connect(function()
                if _G.toggletracer and plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                    local headpos, OnScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if OnScreen then
                        local offsetCFrame = CFrame.new(0, 0, -Settings.Length)
                        local check = false
                        line.From = Vector2.new(headpos.X, headpos.Y)
                        if Settings.AutoThickness then
                            local distance = (player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude
                            local value = math.clamp(1/distance*100, 0.1, 3)
                            line.Thickness = value
                        end
                        repeat
                            local dir = plr.Character.Head.CFrame:ToWorldSpace(offsetCFrame)
                            offsetCFrame = offsetCFrame * CFrame.new(0, 0, Settings.Smoothness)
                            local dirpos, vis = camera:WorldToViewportPoint(Vector3.new(dir.X, dir.Y, dir.Z))
                            if vis then
                                check = true
                                line.To = Vector2.new(dirpos.X, dirpos.Y)
                                line.Visible = true
                                offsetCFrame = CFrame.new(0, 0, -Settings.Length)
                            end
                        until check == true
                    else 
                        line.Visible = false
                    end
                else 
                    line.Visible = false
                    if game.Players:FindFirstChild(plr.Name) == nil then
                        connection:Disconnect()
                    end
                end
            end)
        end
        coroutine.wrap(Updater)()
    end

    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Name ~= player.Name then
            coroutine.wrap(ESP)(v)
        end
    end

    game.Players.PlayerAdded:Connect(function(newplr)
        if newplr.Name ~= player.Name then
            coroutine.wrap(ESP)(newplr)
        end
    end)
end)



Window:CreateLabel(QuickBuyTab, "Quick Buy Options")
local function purchaseItem(itemName)
    game:GetService("ReplicatedStorage"):WaitForChild("ExoticShopRemote"):InvokeServer(itemName)
end

Window:CreateButton(QuickBuyTab, "Lemonade $500", function()
    purchaseItem("Lemonade")
end)

Window:CreateButton(QuickBuyTab, "FakeCard $700", function()
    purchaseItem("FakeCard")
end)

Window:CreateButton(QuickBuyTab, "G26 $550", function()
    purchaseItem("G26")
end)

Window:CreateButton(QuickBuyTab, "Shiesty $75", function()
    purchaseItem("Shiesty")
end)

Window:CreateButton(QuickBuyTab, "RawSteak $10", function()
    purchaseItem("RawSteak")
end)

Window:CreateButton(QuickBuyTab, "Ice-Fruit Bag $2500", function()
    purchaseItem("Ice-Fruit Bag")
end)

Window:CreateButton(QuickBuyTab, "Ice-Fruit Cupz $150", function()
    purchaseItem("Ice-Fruit Cupz")
end)

Window:CreateButton(QuickBuyTab, "FijiWater $48", function()
    purchaseItem("FijiWater")
end)

Window:CreateButton(QuickBuyTab, "FreshWater $48", function()
    purchaseItem("FreshWater")
end)
local userInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

-- Create Section
Window:CreateLabel(QuickBuyTab, "Backpack Shop")

-- New teleport function
local function teleport(x, y, z)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")

    humanoid:ChangeState(0)
    repeat task.wait() until not player:GetAttribute("LastACPos")
    hrp.CFrame = CFrame.new(x, y, z)
end

-- Wait for 'E' key press
local function waitForEPress()
    local connection
    local pressed = false

    connection = userInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.E then
            pressed = true
            connection:Disconnect()
        end
    end)

    repeat task.wait() until pressed
    return true
end
local function buyBackpack(position)
    local originalPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position

    teleport(position.X, position.Y + 4, position.Z)
    Library:Notify("Teleported to backpack shop. Attempting to purchase...", 2)

    -- Wait for character to settle
    task.wait(0.5)

    -- 🔍 Search for nearby ProximityPrompt within a small radius
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    local promptFired = false

    if hrp then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local distance = (obj.Parent.Position - hrp.Position).Magnitude
                if distance < 10 then -- you can tweak this range
                    -- 🛎️ Trigger the prompt
                    fireproximityprompt(obj)
                    promptFired = true
                    break
                end
            end
        end
    end

    if not promptFired then
        Library:Notify("Failed to find a prompt nearby.", 3)
    end

    -- Return to original position
    if originalPos then
        repeat
            teleport(originalPos.X, originalPos.Y + 4, originalPos.Z)
            task.wait(0.5)
        until (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and (player.Character.HumanoidRootPart.Position - originalPos).Magnitude < 5)

        Library:Notify("Returned to original position!", 2)
    end
end

-- Backpack buttons
local backpacks = {
    { name = "Red Elite Bag $500", position = Vector3.new(-681, 254, -692) },
    { name = "Black Elite Bag $500", position = Vector3.new(-680, 254, -691) },
    { name = "Blue Elite Bag $500", position = Vector3.new(-676, 254, -690) },
    { name = "Drac Bag $700", position = Vector3.new(-673, 254, -691) },
    { name = "Yellow RCR Bag $2000", position = Vector3.new(-673, 254, -691) },
    { name = "Black RCR Bag $2000", position = Vector3.new(-672, 254, -690) },
    { name = "Red RCR Bag $2000", position = Vector3.new(-669, 254, -691) },
    { name = "Tan RCR Bag $2000", position = Vector3.new(-666, 254, -694) },
    { name = "Black Designer Bag $2000", position = Vector3.new(-668, 254, -692) }
}

-- Add buttons
for _, bag in ipairs(backpacks) do
    Window:CreateButton(QuickBuyTab, bag.name, function()
        buyBackpack(bag.position)
    end)
end
Window:CreateLabel(CreditsTab, "Information -")
Window:CreateLabel(CreditsTab, "RightShift to toggle menu.")
Window:CreateLabel(CreditsTab, "Made by Simon Derek")
Window:CreateButton(CreditsTab, "Copy Discord", function()
    setclipboard("https://discord.gg/getwavehub")
end)
