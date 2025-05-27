local function teleportTo(position)
    local player = game:GetService("Players").LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    -- Create blackout screen GUI
    local screen = Instance.new("ScreenGui", player.PlayerGui)
    screen.Name = "TeleportScreen"
    screen.ResetOnSpawn = false

    local frame = Instance.new("Frame", screen)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = "Moving."
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    local dotCounter = 1
    local running = true
    task.spawn(function()
        while running and screen.Parent do
            label.Text = "Moving" .. string.rep(".", dotCounter)
            dotCounter = (dotCounter % 3) + 1
            task.wait(1)
        end
    end)

    task.spawn(function()
        while running and screen.Parent do
            label.TextSize = math.random(40, 60)
            task.wait(0.1)
        end
    end)
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
                obj:Sit(humanoid)
                break
            end
        end

        wait(3.5)
    end
    player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    if humanoid then
        humanoid.Sit = false
    end
    running = false
    screen:Destroy()
end


-- RAPID

local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
    Title = "Rapid V1.1",
    Subtitle = "Tha Bronx 3",
    Size = UDim2.fromOffset(830, 550),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

local globalSettings = {
    UIBlurToggle = Window:GlobalSetting({
        Name = "UI Blur",
        Default = Window:GetAcrylicBlurState(),
        Callback = function(bool)
            Window:SetAcrylicBlurState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " UI Blur",
                Lifetime = 5
            })
        end,
    }),
    NotificationToggler = Window:GlobalSetting({
        Name = "Notifications",
        Default = Window:GetNotificationsState(),
        Callback = function(bool)
            Window:SetNotificationsState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Enabled" or "Disabled") .. " Notifications",
                Lifetime = 5
            })
        end,
    }),
    ShowUserInfo = Window:GlobalSetting({
        Name = "Show User Info",
        Default = Window:GetUserInfoState(),
        Callback = function(bool)
            Window:SetUserInfoState(bool)
            Window:Notify({
                Title = Window.Settings.Title,
                Description = (bool and "Showing" or "Redacted") .. " User Info",
                Lifetime = 5
            })
        end,
    })
}



-- Create TabGroup
local tabGroups = {
    TabGroup1 = Window:TabGroup()
}

-- Define Tabs
local tabs = {
    Main           = tabGroups.TabGroup1:Tab({ Name = "Main",        Image = "home"     }),
    Player         = tabGroups.TabGroup1:Tab({ Name = "Player",      Image = "user"     }),
    QuickShopTab   = tabGroups.TabGroup1:Tab({ Name = "Quick Shop",  Image = "quick"    }),
    Visuals        = tabGroups.TabGroup1:Tab({ Name = "Visuals",     Image = "visuals"  }),
    GunModsTab     = tabGroups.TabGroup1:Tab({ Name = "Gun Mods",   Image = "gun"      }), -- Added comma here
    Settings       = tabGroups.TabGroup1:Tab({ Name = "Settings",    Image = "settings" }),
}

-- Define Sections
local sections = {
    MainSection1       = tabs.Main:Section({ Side = "Left" }),
    PlayerSection1     = tabs.Player:Section({ Side = "Left" }),
    QuickShopSection   = tabs.QuickShopTab:Section({ Side = "Left" }),
    VisualsSection     = tabs.Visuals:Section({ Side = "Left" }),
    GunModSection1     = tabs.GunModsTab:Section({ Side = "Left" })  -- Corrected here
}



-- Player Section: Bypass Player Options --
sections.PlayerSection1:Header({ Name = "Bypass Player Options" })

-- Teleport on Damage
sections.PlayerSection1:Toggle({
    Name = "Teleport on Damage",
    Default = false,
    Callback = function(value)
        getgenv().TeleportOnDamageEnabled = value
        local player = game:GetService("Players").LocalPlayer
        if value then
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                _G.LastHealth = player.Character.Humanoid.Health
            end
            _G.TeleportOnDamageConnection = player.Character.Humanoid.HealthChanged:Connect(function(health)
                if health < _G.LastHealth then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        teleportTo(Vector3.new(67462.6953125, 10489.0322265625, 549.5894775390625))
                    end
                end
                _G.LastHealth = health
            end)
        else
            if _G.TeleportOnDamageConnection then
                _G.TeleportOnDamageConnection:Disconnect()
                _G.TeleportOnDamageConnection = nil
            end
        end
    end,
}, "TeleportOnDamage")

-- Auto Jump
sections.PlayerSection1:Toggle({
    Name = "Auto Jump",
    Default = false,
    Callback = function(value)
        _G.AutoJump = value
        if value then
            task.spawn(function()
                while _G.AutoJump do
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        local state = char.Humanoid:GetState()
                        if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
                            char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end,
}, "AutoJump")

-- Fake Lag
sections.PlayerSection1:Toggle({
    Name = "Fake Lag",
    Default = false,
    Callback = function(value)
        _G.FakeLagEnabled = value
        local player = game:GetService("Players").LocalPlayer
        if value then
            _G.FakeLagLoop = task.spawn(function()
                while _G.FakeLagEnabled do
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local root = player.Character.HumanoidRootPart
                        local savedCFrame = root.CFrame
                        root.Anchored = true
                        task.wait(2)
                        root.CFrame = savedCFrame
                        root.Anchored = false
                    end
                    task.wait(0.1)
                end
            end)
        else
            if _G.FakeLagLoop then
                task.cancel(_G.FakeLagLoop)
                _G.FakeLagLoop = nil
            end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Anchored = false
            end
        end
    end,
}, "FakeLag")

-- Spin Bot
sections.PlayerSection1:Toggle({
    Name = "Spin Bot",
    Default = false,
    Callback = function(value)
        _G.SpinBotActive = value
        if value then
            task.spawn(function()
                while _G.SpinBotActive do
                    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(10), 0)
                    end
                    task.wait(0.01)
                end
            end)
        end
    end,
}, "SpinBot")

-- NoClip
sections.PlayerSection1:Toggle({
    Name = "NoClip",
    Default = false,
    Callback = function(state)
        local player = game:GetService("Players").LocalPlayer
        local RunService = game:GetService("RunService")
        local noclipConnection
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                local char = player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
            _G.NoClipConn = noclipConnection
        else
            if _G.NoClipConn then
                _G.NoClipConn:Disconnect()
                _G.NoClipConn = nil
            end
        end
    end,
}, "NoClip")

-- Anti Fall Damage
sections.PlayerSection1:Toggle({
    Name = "Anti Fall Damage",
    Default = false,
    Callback = function(value)
        if value then
            antifalldmg()
        end
    end,
}, "AntiFallDamage")

-- Disable Camera Bobbing
sections.PlayerSection1:Toggle({
    Name = "No Camera Bob",
    Default = false,
    Callback = function(value)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local function disableCameraBobbing(char)
            local bob = char:FindFirstChild("CameraBobbing")
            if bob then bob:Destroy() end
        end
        if value then
            if LocalPlayer.Character then disableCameraBobbing(LocalPlayer.Character) end
            _G.CamBobConn = LocalPlayer.CharacterAdded:Connect(disableCameraBobbing)
        else
            if _G.CamBobConn then _G.CamBobConn:Disconnect() _G.CamBobConn = nil end
        end
    end,
}, "NoCameraBob")

-- No Jump Debounce
sections.PlayerSection1:Toggle({
    Name = "No Jump Debounce",
    Default = false,
    Callback = function(value)
        local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        local jd = PlayerGui:FindFirstChild("JumpDebounce")
        if value and jd then
            _G.JDBak = jd:Clone()
            jd:Destroy()
        elseif not value and _G.JDBak then
            _G.JDBak.Parent = PlayerGui
            _G.JDBak = nil
        end
    end,
}, "NoJumpDebounce")

-- Instant Prompt
sections.PlayerSection1:Toggle({
    Name = "Instant Prompt",
    Default = false,
    Callback = function(value)
        for _, v in ipairs(game.Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = value and 0 or 1
                v.RequiresLineOfSight = not value
            end
        end
    end,
}, "InstantPrompt")

-- Disable Stamina Bar
sections.PlayerSection1:Toggle({
    Name = "No Stamina Bar",
    Default = false,
    Callback = function(value)
        local runGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Run")
        if runGui then
            local sb = runGui.Frame.Frame.Frame:FindFirstChild("StaminaBarScript")
            if sb then sb.Enabled = not value end
        end
    end,
}, "NoStaminaBar")

-- Disable Hunger Bar
sections.PlayerSection1:Toggle({
    Name = "No Hunger Bar",
    Default = false,
    Callback = function(value)
        local hug = game.Players.LocalPlayer.PlayerGui:FindFirstChild("Hunger")
        if hug then
            local hb = hug.Frame.Frame.Frame:FindFirstChild("HungerBarScript")
            if hb then hb.Enabled = not value end
        end
    end,
}, "NoHungerBar")

-- Disable Sleep Bar
sections.PlayerSection1:Toggle({
    Name = "No Sleep Bar",
    Default = false,
    Callback = function(value)
        local sleepGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("SleepGui")
        if sleepGui then
            local sb = sleepGui.Frame.sleep:FindFirstChild("SleepBar")
            if sb then
                local sc = sb:FindFirstChild("sleepScript")
                if sc then sc.Enabled = not value end
            end
        end
    end,
}, "NoSleepBar")

-- Disable Rent GUI
sections.PlayerSection1:Toggle({
    Name = "No Rent GUI",
    Default = false,
    Callback = function(value)
        local rentGui = game:GetService("StarterGui"):FindFirstChild("RentGui")
        if rentGui then
            local rs = rentGui:FindFirstChild("LocalScript")
            if rs then rs.Enabled = not value end
        end
    end,
}, "NoRentGUI")







--- WALKSPEED FLY JUMP 






--[[
  ─── MOVEMENT FUNCTIONS & INITIALIZATION ───────────────────────────────────
]]

-- Walkspeed
getgenv().SpeedValue   = getgenv().SpeedValue   or 28
getgenv().SpeedEnabled = getgenv().SpeedEnabled or false
local Players    = game:GetService("Players")
local runService = game:GetService("RunService")
local player     = Players.LocalPlayer
local speedConn

local function isPlayerIdle(humanoid)
    return humanoid.MoveDirection.Magnitude == 0
end

local function toggleSpeed(enabled)
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root    = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    if speedConn then
        speedConn:Disconnect()
        speedConn = nil
    end

    if enabled then
        speedConn = runService.RenderStepped:Connect(function()
            if not isPlayerIdle(humanoid) then
                root.CFrame = root.CFrame + (humanoid.MoveDirection * getgenv().SpeedValue * 0.01)
            end
        end)
    end
end

-- JumpPower
getgenv().JumpPowerValue   = getgenv().JumpPowerValue   or 50
getgenv().JumpPowerEnabled = getgenv().JumpPowerEnabled or false
local UserInput = game:GetService("UserInputService")

local function handleJump()
    if not getgenv().JumpPowerEnabled then return end
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root     = char:FindFirstChild("HumanoidRootPart")
    if humanoid and root then
        root.Velocity = Vector3.new(root.Velocity.X, getgenv().JumpPowerValue, root.Velocity.Z)
    end
end

UserInput.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Space then
        handleJump()
    end
end)

-- Flight
getgenv().FreefallEnabled = getgenv().FreefallEnabled or false
getgenv().FreefallSpeed   = getgenv().FreefallSpeed   or 75

local flying, flyConn, ibConn, ieConn
local velocity, gyro
local keysPressed = {}
local RunService = game:GetService("RunService")

local function startFlying()
    if flying then return end
    flying = true
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    velocity = Instance.new("BodyVelocity", root)
    velocity.Name     = "FlyVelocity"
    velocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    velocity.Velocity = Vector3.new(0,0,0)

    gyro = Instance.new("BodyGyro", root)
    gyro.Name      = "FlyGyro"
    gyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    gyro.CFrame    = root.CFrame

    ibConn = UserInput.InputBegan:Connect(function(inp, gp)
        if not gp and inp.UserInputType == Enum.UserInputType.Keyboard then
            keysPressed[inp.KeyCode] = true
        end
    end)
    ieConn = UserInput.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            keysPressed[inp.KeyCode] = false
        end
    end)

    flyConn = RunService.RenderStepped:Connect(function()
        local dir = Vector3.new(
            (keysPressed[Enum.KeyCode.W] and -1 or 0) + (keysPressed[Enum.KeyCode.S] and  1 or 0),
            (keysPressed[Enum.KeyCode.Space] and 1  or 0) + (keysPressed[Enum.KeyCode.LeftControl] and -1 or 0),
            (keysPressed[Enum.KeyCode.A] and -1 or 0) + (keysPressed[Enum.KeyCode.D] and  1 or 0)
        )
        if dir.Magnitude > 0 then dir = dir.Unit end
        velocity.Velocity = workspace.CurrentCamera.CFrame:VectorToWorldSpace(dir) * getgenv().FreefallSpeed
        gyro.CFrame       = workspace.CurrentCamera.CFrame
    end)
end

local function stopFlying()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if ibConn  then ibConn:Disconnect()  ibConn  = nil end
    if ieConn  then ieConn:Disconnect()  ieConn  = nil end
    for _, inst in ipairs(player.Character:GetDescendants()) do
        if inst.Name == "FlyVelocity" or inst.Name == "FlyGyro" then
            inst:Destroy()
        end
    end
end

local function toggleFlight(enabled)
    if enabled then startFlying() else stopFlying() end
end

--[[
  ─── GUI: PLAYER MOVEMENT OPTIONS ─────────────────────────────────────────
]]
local moveSection = tabs.Player:Section({ Side = "Right" })
moveSection:Header({ Name = "Player Movement Options" })

-- Walkspeed Toggle & Slider & Keybind
moveSection:Toggle({
    Name    = "Enable Walkspeed",
    Default = getgenv().SpeedEnabled,
    Callback = function(v)
        getgenv().SpeedEnabled = v
        toggleSpeed(v)
    end,
}, "SpeedEnabled")

moveSection:Slider({
    Name      = "Walkspeed Value",
    Default   = getgenv().SpeedValue,
    Minimum   = 0,
    Maximum   = 28,
    Precision = 0,
    Callback  = function(v) getgenv().SpeedValue = v end,
}, "SpeedValue")

moveSection:Keybind({
    Name      = "Walkspeed Bind",
    Blacklist = false,
    Callback  = function(bind)
        getgenv().SpeedEnabled = not getgenv().SpeedEnabled
        toggleSpeed(getgenv().SpeedEnabled)
    end,
    onBinded  = function(bind)
        Window:Notify({
            Title       = Window.Settings.Title,
            Description = "Walkspeed toggled: " .. tostring(getgenv().SpeedEnabled)
        })
    end,
}, "SpeedBind")

-- JumpPower Toggle & Slider & Keybind
moveSection:Toggle({
    Name    = "Enable JumpPower",
    Default = getgenv().JumpPowerEnabled,
    Callback = function(v)
        getgenv().JumpPowerEnabled = v
    end,
}, "JumpPowerEnabled")

moveSection:Slider({
    Name      = "JumpPower Value",
    Default   = getgenv().JumpPowerValue,
    Minimum   = 0,
    Maximum   = 200,
    Precision = 0,
    Callback  = function(v) getgenv().JumpPowerValue = v end,
}, "JumpPowerValue")

moveSection:Keybind({
    Name      = "JumpPower Bind",
    Blacklist = false,
    Callback  = function(bind)
        getgenv().JumpPowerEnabled = not getgenv().JumpPowerEnabled
        Window:Notify({
            Title       = Window.Settings.Title,
            Description = "JumpPower toggled: " .. tostring(getgenv().JumpPowerEnabled)
        })
    end,
}, "JumpPowerBind")





-- END 






-- Start of dropdowns teleport, quick buy


-- ─── QUICK BUY & TELEPORT SECTIONS (Player Tab) ────────────────────────────

-- Quick Buy Section
local quickBuySection = tabs.Player:Section({ Side = "Right" })
quickBuySection:Header({ Name = "Quick" })

local quickGasOptions = {
    "Water","Shiesty","BluGloves","WhiteGloves","BlackGloves",
    "RawSteak","BluCamoGloves","RedCamoGloves","PinkCamoGloves"
}
quickBuySection:Dropdown({
    Name     = "Quick GasStation",
    Options  = quickGasOptions,
    Default  = quickGasOptions[1],
    Callback = function(value)
        local shopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ShopRemote")
        if shopRemote then
            shopRemote:InvokeServer(value)
        else
            Window:Notify({
                Title       = Window.Settings.Title,
                Description = "Error: ShopRemote not found!",
                Lifetime    = 3
            })
        end
    end,
}, "QuickGasStation")

local exoticOptions = {
    "FakeCard","FijiWater","FreshWater","G26","Ice-Fruit Bag",
    "Ice-Fruit Cupz","Lemonade","RawSteak","Shiesty"
}
quickBuySection:Dropdown({
    Name     = "Quick ExoticShop",
    Options  = exoticOptions,
    Default  = exoticOptions[1],
    Callback = function(value)
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ExoticShopRemote")
        if remote then
            remote:InvokeServer(value)
        else
            Window:Notify({
                Title       = Window.Settings.Title,
                Description = "Error: ExoticShopRemote not found!",
                Lifetime    = 3
            })
        end
    end,
}, "QuickExoticShop")

local guiAccessOptions = {
    "Open ThaShop","Open Bronx Tattoos","Open Trunk","Open Bronx Clothing","Open ATM GUI"
}
quickBuySection:Dropdown({
    Name     = "Quick GUI Access",
    Options  = guiAccessOptions,
    Default  = guiAccessOptions[1],
    Callback = function(value)
        local player   = game:GetService("Players").LocalPlayer
        local playerGui= player:FindFirstChild("PlayerGui")
        if value == "Open ThaShop" then
            if playerGui and playerGui:FindFirstChild("ThaShop") then
                playerGui.ThaShop.Enabled = true
            else
                Window:Notify({ Title = Window.Settings.Title, Description = "ThaShop GUI not found", Lifetime = 3 })
            end
        elseif value == "Open Bronx Tattoos" then
            if playerGui and playerGui:FindFirstChild("Bronx TATTOOS") then
                playerGui["Bronx TATTOOS"].Enabled = true
            else
                Window:Notify({ Title = Window.Settings.Title, Description = "Bronx Tattoos GUI not found", Lifetime = 3 })
            end
        elseif value == "Open Bronx Clothing" then
            if playerGui and playerGui:FindFirstChild("Bronx CLOTHING") then
                playerGui["Bronx CLOTHING"].Enabled = true
            else
                Window:Notify({ Title = Window.Settings.Title, Description = "Bronx Clothing GUI not found", Lifetime = 3 })
            end
        elseif value == "Open Trunk" then
            local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
            if playerGui:FindFirstChild("TRUNK STORAGE") then
                playerGui["TRUNK STORAGE"].Enabled = true
            else
                Window:Notify({ Title = Window.Settings.Title, Description = "Bronx Clothing GUI not found", Lifetime = 3 })
            end
        elseif value == "Open ATM GUI" then
            local lighting = game:GetService("Lighting")
            local atmGui   = lighting:FindFirstChild("Assets")
                               and lighting.Assets:FindFirstChild("GUI")
                               and lighting.Assets.GUI:FindFirstChild("ATMGui")
            if atmGui then
                local existing = playerGui:FindFirstChild("ATMGui")
                if not existing then
                    existing = atmGui:Clone()
                    existing.Parent = playerGui
                end
                existing.Enabled = true
                -- hook up close button
                for _, btn in ipairs(existing:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) 
                       and string.find(string.lower(btn.Name), "close") 
                       and not btn:GetAttribute("Connected") then
                        btn.MouseButton1Click:Connect(function() existing.Enabled = false end)
                        btn:SetAttribute("Connected", true)
                    end
                end
            else
                Window:Notify({ Title = Window.Settings.Title, Description = "❌ ATM GUI not found", Lifetime = 3 })
            end
        end
    end,
}, "QuickGUIAccess")

-- Teleport Section
local teleportSection = tabs.Main:Section({ Side = "Right" })
teleportSection:Header({ Name = "Teleport to Locations" })
teleportSection:Header({ Name = "Select a Location and click on it" })

local locations = {
    ["Gunshop"]            = Vector3.new(92972.28, 122097.95, 17022.78),
    ["Gunshop 2"]          = Vector3.new(66202, 123615.71, 5749.82),
    ["Gunshop 3"]          = Vector3.new(60819.78, 87609.14, -347.31),
    ["Safe Items"]         = Vector3.new(-961.88, 253.69, -1236.51),
    ["Construction Site"]  = Vector3.new(-1731.83, 370.81, -1176.83),
    ["Ice Box"]            = Vector3.new(-202.48, 283.59, -1264.16),
    ["Frozen Shop"]        = Vector3.new(-192.00, 283.84, -1170.58),
    ["Drip Store"]         = Vector3.new(67462.69, 10489.03, 549.58),
    ["Bank"]               = Vector3.new(-204.66, 283.62, -1223.32),
    ["Pawn Shop"]          = Vector3.new(-1049.64, 253.53, -814.26),
    ["Penthouse"]          = Vector3.new(-120.87, 417.20, -572.02),
    ["Chicken Wings"]      = Vector3.new(-957.91, 253.53, -815.94),
    ["Deli"]               = Vector3.new(-923.80, 253.72, -811.12),
    ["Cash Counter Store"] = Vector3.new(-989.82, 253.65, -688.13),
    ["Pizza Store"]        = Vector3.new(-739.20, 253.22, -955.60),
    ["Car Dealer"]         = Vector3.new(-377.60, 253.25, -1245.88),
    ["Backpack Shop"]      = Vector3.new(-674.23, 253.59, -682.16),
    ["Bank Tools"]         = Vector3.new(-387.83, 340.34, -557.89)
}
local locNames = {}
for name, _ in pairs(locations) do
    table.insert(locNames, name)
end

teleportSection:Dropdown({
    Name     = "Teleport to Location",
    Options  = locNames,
    Default  = locNames[1],
    Callback = function(selected)
        local dest = locations[selected]
        local char = game:GetService("Players").LocalPlayer.Character
        if dest and char and char:FindFirstChild("HumanoidRootPart") then
            teleportTo(dest)
        else
            Window:Notify({
                Title       = Window.Settings.Title,
                Description = "Teleport failed. Character not ready or location not found.",
                Lifetime    = 3
            })
        end
    end,
}, "TeleportLocation")





-- Main Tab



-- Low Money Dupe Section
local lowMoneyDupeSection = tabs.Main:Section({ Side = "Left" })
lowMoneyDupeSection:Header({ Name = "Low Money Dupe" })
lowMoneyDupeSection:Header({ Name = "For low pc executors!!" })
lowMoneyDupeSection:Header({ Name = "How to use Money Dupe?" })
lowMoneyDupeSection:Header({ Name = "Turn instant interact On" })
lowMoneyDupeSection:Header({ Name = "Teleport to Cooking-Pots" })
lowMoneyDupeSection:Header({ Name = "Cook it-equip it" })
lowMoneyDupeSection:Header({ Name = "teleport to sell-point" })
lowMoneyDupeSection:Header({ Name = "make sure to see the prompt" })
lowMoneyDupeSection:Header({ Name = "start and spam when the text color stops changing" })

local lowMoneyDupeOptions = {
    "Teleport to Cooking Pot",
    "Open Kool-Aid Shop",
    "Teleport to Sell Point",
    "Start Low Dupe"
}

lowMoneyDupeSection:Dropdown({
    Name     = "Low Money Dupe Options",
    Options  = lowMoneyDupeOptions,
    Default  = lowMoneyDupeOptions[1],
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        
        if value == "Teleport to Cooking Pot" then
            -- Enable Freefall Method
            getgenv().FreeFalMethod = true

            task.spawn(function()
                while task.wait() do
                    if FreeFalMethod then
                        local player = game:GetService("Players").LocalPlayer
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                        end
                    end
                end
            end)

            -- Teleport to Cooking Pot location
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                teleportTo(Vector3.new(-684.8323364257812, 259.9552307128906, -1253.6285400390625))
            end
        elseif value == "Open Kool-Aid Shop" then
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui and playerGui:FindFirstChild("ThaShop") then
                playerGui["ThaShop"].Enabled = true
            else
                Library:Notify('ThaShop GUI not found ❌', 3)
            end
        elseif value == "Teleport to Sell Point" then
            -- Enable Freefall Method
            getgenv().FreeFalMethod = true

            task.spawn(function()
                while task.wait() do
                    if FreeFalMethod then
                        local player = game:GetService("Players").LocalPlayer
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                        end
                    end
                end
            end)

            -- Teleport to Sell Point location
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            teleportTo(Vector3.new(-57.800907135009766, 286.7206115722656, -336.7708435058594))       
             end
        elseif value == "Start Low Dupe" then
            -- Create the screen GUI for the black screen and text
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = player.PlayerGui
            screenGui.Name = "StartScreen"
            screenGui.IgnoreGuiInset = true -- Macht das GUI fullscreen (versteckt Roblox Icons)

            local blackFrame = Instance.new("Frame")
            blackFrame.Size = UDim2.new(1, 0, 1, 0)
            blackFrame.Position = UDim2.new(0, 0, 0, 0)
            blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            blackFrame.Parent = screenGui

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "RAPID V1"
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.Parent = blackFrame

            -- Rainbow text animation
            local function animateRainbowText()
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(255, 165, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(75, 0, 130),
                    Color3.fromRGB(238, 130, 238)
                }

                local i = 1
                while textLabel.Parent do
                    textLabel.TextColor3 = colors[i]
                    i = i + 1
                    if i > #colors then
                        i = 1
                    end
                    wait(0.2)
                end
            end

            -- Start the rainbow text animation
            coroutine.wrap(animateRainbowText)()

            -- Delay before starting the actual script
            wait(2)

            -- Your original "Money Dupe" script (Infinite Money) logic
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer

            local freezeTime = 30
            local startTime = tick()

            print("FREEZING GAME...")

            -- Function to create massive lag
            local function hardFreeze()
                while tick() - startTime < freezeTime do
                    for i = 1, 1e8 do
                        local _ = math.sin(i) * math.cos(i)
                    end
                end
                print("UNFREEZE NOW")
            end

            -- Game freeze via heavy calculation in RenderStepped
            RunService:BindToRenderStep("FreezeGame", Enum.RenderPriority.Camera.Value + 1, function()
                if tick() - startTime < freezeTime then
                    hardFreeze()
                else
                    RunService:UnbindFromRenderStep("FreezeGame")
                end
            end)

            -- Remove the black screen and text after 35 seconds
            wait(35)
            screenGui:Destroy()
        end
    end,
}, "LowMoneyDupeOptions")


-- Extreme Money Dupe Section
local extremeMoneyDupeSection = tabs.Main:Section({ Side = "Left" })
extremeMoneyDupeSection:Header({ Name = "Extreme Money Dupe" })
extremeMoneyDupeSection:Header({ Name = "for mobile, high exc!!" })
extremeMoneyDupeSection:Header({ Name = "How to use Money Dupe?" })
extremeMoneyDupeSection:Header({ Name = "Teleport to Cooking-Pots" })
extremeMoneyDupeSection:Header({ Name = "Cook it-equip it" })

local extremeMoneyDupeOptions = {
    "Teleport to Cooking Pot",
    "Open Kool-Aid Shop",
    "Start Extreme Dupe"
}

extremeMoneyDupeSection:Dropdown({
    Name     = "Extreme Money Dupe Options",
    Options  = extremeMoneyDupeOptions,
    Default  = extremeMoneyDupeOptions[1],
    Callback = function(value)
        local player = game:GetService("Players").LocalPlayer
        
        if value == "Teleport to Cooking Pot" then
            -- Enable Freefall Method
            getgenv().FreeFalMethod = true

            task.spawn(function()
                while task.wait() do
                    if FreeFalMethod then
                        local player = game:GetService("Players").LocalPlayer
                        if player and player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                        end
                    end
                end
            end)

            -- Teleport to Cooking Pot location
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                teleportTo(Vector3.new(-684.8323364257812, 259.9552307128906, -1253.6285400390625))
            end
        elseif value == "Open Kool-Aid Shop" then
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui and playerGui:FindFirstChild("ThaShop") then
                playerGui["ThaShop"].Enabled = true
            else
                Library:Notify('ThaShop GUI not found ❌', 3)
            end
        elseif value == "Start Extreme Dupe" then
            -- Create the screen GUI for the black screen and text
            local screenGui = Instance.new("ScreenGui")
            screenGui.Parent = player.PlayerGui
            screenGui.Name = "StartScreen"
            screenGui.IgnoreGuiInset = true -- Fullscreen GUI (hides Roblox icons)

            local blackFrame = Instance.new("Frame")
            blackFrame.Size = UDim2.new(1, 0, 1, 0)
            blackFrame.Position = UDim2.new(0, 0, 0, 0)
            blackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            blackFrame.Parent = screenGui

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "RAPID V1 - Extreme Dupe"
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.Parent = blackFrame

            -- Rainbow text animation
            local function animateRainbowText()
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(255, 165, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(75, 0, 130),
                    Color3.fromRGB(238, 130, 238)
                }

                local i = 1
                while textLabel.Parent do
                    textLabel.TextColor3 = colors[i]
                    i = i + 1
                    if i > #colors then
                        i = 1
                    end
                    wait(0.2)
                end
            end

            -- Start the rainbow text animation
            coroutine.wrap(animateRainbowText)()

            -- Delay before starting the actual script
            wait(2)

            -- Your original "Extreme Money Dupe" script logic
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer

            local freezeTime = 30
            local startTime = tick()

            print("FREEZING GAME...")

            -- Function to create massive lag
            local function hardFreeze()
                while tick() - startTime < freezeTime do
                    for i = 1, 1e8 do
                        local _ = math.sin(i) * math.cos(i)
                    end
                end
                print("UNFREEZE NOW")
            end

            -- Game freeze via heavy calculation in RenderStepped
            RunService:BindToRenderStep("FreezeGame", Enum.RenderPriority.Camera.Value + 1, function()
                if tick() - startTime < freezeTime then
                    hardFreeze()
                else
                    RunService:UnbindFromRenderStep("FreezeGame")
                end
            end)

            -- Remove the black screen and text after 35 seconds
            wait(35)
            screenGui:Destroy()
        end
    end,
}, "ExtremeMoneyDupeOptions")


-- Gun Dupe Section (Placed on the Right Side)
local gunDupeSection = tabs.Main:Section({ Side = "Right" })
gunDupeSection:Header({ Name = "Gun Dupe" })
gunDupeSection:Header({ Name = "equip item/gun" })
gunDupeSection:Header({ Name = "start the Dupe" })
gunDupeSection:Header({ Name = "duped item will be stored in your safe." })

local function notify(title, text, duration)
    game.StarterGui:SetCore("SendNotification", { Title = title; Text = text; Duration = duration or 3; })
end

-- Button to trigger the Gun Dupe process
gunDupeSection:Button({
    Name     = "Start Gun Dupe",
    Callback = function()
        local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local backpack = player:WaitForChild("Backpack")

local safes = workspace["1# Map"]["2 Crosswalks"].Safes:GetChildren()
local closestSafe = nil
local closestChestClicker = nil
local shortestDistance = math.huge

for _, safe in ipairs(safes) do
	local chestClicker = safe:FindFirstChild("ChestClicker")
	if chestClicker and chestClicker:IsA("BasePart") then
		local distance = (humanoidRootPart.Position - chestClicker.Position).Magnitude
		if distance < shortestDistance then
			shortestDistance = distance
			closestSafe = safe
			closestChestClicker = chestClicker
		end
	end
end

if not closestSafe or not closestChestClicker then
	warn("[RAPID] No nearby safe with ChestClicker found.")
	return
end

-- Tool handler
local function toolhandler()
	local tool = character:FindFirstChildOfClass("Tool")
	local toolName = nil
	if tool then
		toolName = tool.Name
		tool.Parent = backpack
	else
		print("[RAPID] No tool currently equipped.")
	end
	return toolName
end

_G.gun = toolhandler()

-- Dupe function
local function dupe()
	teleportTo(closestChestClicker.Position + Vector3.new(0, 5, 0))
	print("[RAPID] Teleported to safe position.")
	task.wait(0.5)

	task.spawn(function()
		game:GetService("ReplicatedStorage").BackpackRemote:InvokeServer("Store", _G.gun)
	end)

	task.spawn(function()
		game:GetService("ReplicatedStorage").Inventory:FireServer("Change", _G.gun, "Backpack", closestSafe)
	end)

	teleportTo(humanoidRootPart.Position + Vector3.new(0, 0, 0)) -- Re-teleport to original position (same pos)
	print("[RAPID] Returned to original position.")

	task.wait(1.7)
	game:GetService("ReplicatedStorage").BackpackRemote:InvokeServer("Grab", _G.gun)

	game.StarterGui:SetCore("SendNotification", {
		Title = "[RAPID] notification",
		Text = "Duped item is in your safe.",
		Duration = 2,
	})
end

dupe()
    end,
})



-- Services
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local RunService   = game:GetService("RunService")

-- Variables
local SelectedPlayer      = nil
getgenv().KillbringActive = false
getgenv().SpectateActive  = false
local SpectateConnection  = nil

-- Helper: update dropdown options
local function updatePlayerDropdown()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- KillBring Function (exactly your original)
function killBring()
    if not SelectedPlayer then
        Library:Notify("No target selected!", 3)
        return false
    end
    local target  = SelectedPlayer
    local speaker = LocalPlayer
    if target.Character and speaker.Character then
        local tR = target.Character:FindFirstChild("HumanoidRootPart")
        local sR = speaker.Character:FindFirstChild("HumanoidRootPart")
        if tR and sR then
            local h = target.Character:FindFirstChildOfClass("Humanoid")
            if h then h.Sit = false end
            task.wait()
            tR.CFrame = sR.CFrame + Vector3.new(3, 1, 0)
            return true
        end
    end
    Library:Notify("Invalid target or speaker!", 3)
    return false
end

-- Spectate Function (camera follows the target's Humanoid)
function spectatePlayer(state)
    -- disconnect previous
    if SpectateConnection then
        SpectateConnection:Disconnect()
        SpectateConnection = nil
    end
    if state and SelectedPlayer and SelectedPlayer.Character then
        SpectateConnection = RunService.Heartbeat:Connect(function()
            local h = SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then
                workspace.CurrentCamera.CameraSubject = h
            end
        end)
        Library:Notify("Spectating: " .. SelectedPlayer.Name, 3)
    else
        -- reset camera
        workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Library:Notify("Stopped spectating", 3)
    end
end

-- Create Target Player section in MacLib UI
local targetSection = tabs.Main:Section({ Side = "Right", Title = "Target Player's" })
targetSection:Header({ Name = "How to Target a Player?" })
targetSection:Header({ Name = "Select a player and use the controls below." })

-- Player selection dropdown
local playerDropdown = targetSection:Dropdown({
    Name     = "Select a Player",
    Options  = updatePlayerDropdown(),
    Default  = "",
    Callback = function(name)
        SelectedPlayer = Players:FindFirstChild(name)
    end,
}, "SelectPlayer")

-- Refresh list button
targetSection:Button({
    Name     = "Refresh player List",
    Callback = function()
        playerDropdown:UpdateValues(updatePlayerDropdown())
    end,
}, "RefreshList")

-- Auto-update dropdown values
task.spawn(function()
    while true do
        playerDropdown:UpdateValues(updatePlayerDropdown())
        task.wait(1)
    end
end)

-- KillBring toggle
targetSection:Toggle({
    Name     = "KillBring Player",
    Icon     = "check",
    Default  = false,
    Callback = function(state)
        getgenv().KillbringActive = state
        if state then
            if not SelectedPlayer then
                Library:Notify("No target selected!", 3)
                return
            end
            task.spawn(function()
                while getgenv().KillbringActive do
                    killBring()
                    task.wait(0.1)
                end
            end)
        else
            Library:Notify("KillBring Deactivated", 3)
        end
    end,
}, "KillBringPlayer")

-- Spectate toggle
targetSection:Toggle({
    Name     = "Spectate Player",
    Icon     = "eye",
    Default  = false,
    Callback = function(state)
        if not SelectedPlayer then
            Library:Notify("No target selected!", 3)
            return
        end
        spectatePlayer(state)
    end,
}, "SpectatePlayer")

-- Goto button
targetSection:Button({
    Name     = "Goto Player",
    Callback = function()
        if not SelectedPlayer or not SelectedPlayer.Character then
            Library:Notify("No target selected!", 3)
            return
        end
        local tR = SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local lR = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tR and lR then
teleportTo(tR.Position)
            Library:Notify("Teleported to " .. SelectedPlayer.Name, 3)
        else
            Library:Notify("Unable to teleport!", 3)
        end
    end,
}, "GotoPlayer")

-- View Inventory button
targetSection:Button({
    Name     = "View Inventory",
    Callback = function()
        if not SelectedPlayer then
            game.StarterGui:SetCore("SendNotification", {
                Title = "❌ No target selected!",
                Text = "Please select a player first.",
                Duration = 3
            })
            return
        end

        local backpack = SelectedPlayer:FindFirstChild("Backpack")
        if not backpack then
            game.StarterGui:SetCore("SendNotification", {
                Title = "❌ Error",
                Text = "No Backpack found on " .. SelectedPlayer.Name,
                Duration = 3
            })
            return
        end

        local names = {}
        for _, item in ipairs(backpack:GetChildren()) do
            table.insert(names, item.Name)
        end

        local message = #names > 0 
            and "Items: " .. table.concat(names, ", ")
            or "Backpack is empty."

        game.StarterGui:SetCore("SendNotification", {
            Title = "🎒 " .. SelectedPlayer.Name .. "'s Backpack",
            Text = message,
            Duration = 6
        })
    end,
}, "ViewInventory")


-- END OF THE FUCKING MAIN TAB WHICH TAKES 3 YEARS


--// ESP Settings
local Players   = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera    = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPSettings = {
    Enabled     = false,
    Box         = true,
    Name        = true,
    Tool        = true,
    Distance    = true,
    Health      = true,
    Chams       = true,
    TeamCheck   = false,
    Tracers     = true,
    BoxColor    = Color3.fromRGB(128,128,128),
    NameColor   = Color3.fromRGB(255,255,255),
    HealthColor = Color3.fromRGB(0,255,0),
    TracerColor = Color3.fromRGB(255,0,0),
}

local ESPObjects = {}

--// Drawing Helpers
local function CreateText(size)
    local t = Drawing.new("Text")
    t.Size = size
    t.Center = true
    t.Outline = true
    t.OutlineColor = Color3.new(0,0,0)
    t.Visible = false
    return t
end

local function CreateBox()
    local b = Drawing.new("Square")
    b.Thickness = 1.5
    b.Filled = false
    b.Visible = false
    return b
end

local function CreateLine()
    local l = Drawing.new("Line")
    l.Thickness = 1
    l.Visible = false
    return l
end

--// Chams Helpers
local function CreateChams(player)
    if ESPObjects[player] and ESPObjects[player].Chams then return end
    if not player.Character then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = player.Character
    hl.FillColor = ESPSettings.BoxColor
    hl.OutlineColor = Color3.new(0,0,0)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = game:GetService("CoreGui")
    ESPObjects[player] = ESPObjects[player] or {}
    ESPObjects[player].Chams = hl
end

local function DestroyChams(player)
    if ESPObjects[player] and ESPObjects[player].Chams then
        ESPObjects[player].Chams:Destroy()
        ESPObjects[player].Chams = nil
    end
end

--// Cleanup
Players.PlayerRemoving:Connect(function(plr)
    if ESPObjects[plr] then
        for _, v in pairs(ESPObjects[plr]) do
            if typeof(v)=="Instance" then v:Destroy() else v:Remove() end
        end
        ESPObjects[plr] = nil
    end
end)

--// Main Render Loop
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        -- Teamcheck
        if ESPSettings.TeamCheck and player.Team == LocalPlayer.Team then
            -- destroy all
            if ESPObjects[player] then
                for _, v in pairs(ESPObjects[player]) do
                    if typeof(v)=="Instance" then v:Destroy() else v:Remove() end
                end
                ESPObjects[player] = nil
            end
            continue
        end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and root and head and hum and hum.Health>0 and ESPSettings.Enabled) then
            -- destroy on disable or dead
            if ESPObjects[player] then
                for _, v in pairs(ESPObjects[player]) do
                    if typeof(v)=="Instance" then v:Destroy() else v:Remove() end
                end
                ESPObjects[player] = nil
            end
            continue
        end

        -- init tables + drawings
        ESPObjects[player] = ESPObjects[player] or {}
        local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local dist = (Camera.CFrame.Position - root.Position).Magnitude
        local scale = 1/(root.Position - Camera.CFrame.Position).Magnitude * 100
        local boxSize = Vector2.new(35*scale,50*scale)

        -- Chams
        if ESPSettings.Chams then CreateChams(player)
        else DestroyChams(player) end

        -- Box
        if ESPSettings.Box and onScreen then
            if not ESPObjects[player].Box then ESPObjects[player].Box = CreateBox() end
            local b = ESPObjects[player].Box
            b.Size = boxSize
            b.Position = Vector2.new(screenPos.X - boxSize.X/2, screenPos.Y - boxSize.Y/2)
            b.Color = ESPSettings.BoxColor
            b.Visible = true
        elseif ESPObjects[player] and ESPObjects[player].Box then
            ESPObjects[player].Box.Visible = false
        end

        -- Name
        if ESPSettings.Name and onScreen then
            if not ESPObjects[player].Name then ESPObjects[player].Name = CreateText(14) end
            local t = ESPObjects[player].Name
            t.Text = player.Name
            t.Position = Vector2.new(screenPos.X, screenPos.Y - boxSize.Y/2 - 10)
            t.Color = ESPSettings.NameColor
            t.Visible = true
        elseif ESPObjects[player] and ESPObjects[player].Name then
            ESPObjects[player].Name.Visible = false
        end

        -- Health
        if ESPSettings.Health and onScreen then
            if not ESPObjects[player].Health then ESPObjects[player].Health = CreateText(14) end
            local h = ESPObjects[player].Health
            h.Text = "HP:"..math.floor(hum.Health)
            h.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2 + 5)
            h.Color = ESPSettings.HealthColor
            h.Visible = true
        elseif ESPObjects[player] and ESPObjects[player].Health then
            ESPObjects[player].Health.Visible = false
        end

        -- Tool
        if ESPSettings.Tool and onScreen then
            local toolInst = char:FindFirstChildOfClass("Tool")
            if toolInst then
                if not ESPObjects[player].Tool then ESPObjects[player].Tool = CreateText(14) end
                local tt = ESPObjects[player].Tool
                tt.Text = toolInst.Name
                tt.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2 + 20)
                tt.Color = ESPSettings.NameColor
                tt.Visible = true
            end
        elseif ESPObjects[player] and ESPObjects[player].Tool then
            ESPObjects[player].Tool.Visible = false
        end

        -- Distance
        if ESPSettings.Distance and onScreen then
            if not ESPObjects[player].Distance then ESPObjects[player].Distance = CreateText(14) end
            local d = ESPObjects[player].Distance
            d.Text = math.floor(dist).."m"
            d.Position = Vector2.new(screenPos.X, screenPos.Y + boxSize.Y/2 + 35)
            d.Color = ESPSettings.NameColor
            d.Visible = true
        elseif ESPObjects[player] and ESPObjects[player].Distance then
            ESPObjects[player].Distance.Visible = false
        end

        -- Tracer
        if ESPSettings.Tracers and onScreen then
            if not ESPObjects[player].Tracer then ESPObjects[player].Tracer = CreateLine() end
            local l = ESPObjects[player].Tracer
            l.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            l.To   = Vector2.new(screenPos.X, screenPos.Y)
            l.Color = ESPSettings.TracerColor
            l.Visible = true
        elseif ESPObjects[player] and ESPObjects[player].Tracer then
            ESPObjects[player].Tracer.Visible = false
        end
    end
end)

--// UI in MacLib Visuals-Tab
sections.VisualsSection:Header({ Name = "Character ESP" })
sections.VisualsSection:Toggle({ Name = "Enable ESP",    Default = ESPSettings.Enabled,  Callback = function(v) ESPSettings.Enabled   = v end })
sections.VisualsSection:Toggle({ Name = "Box ESP",       Default = ESPSettings.Box,      Callback = function(v) ESPSettings.Box       = v end })
sections.VisualsSection:Toggle({ Name = "Name ESP",      Default = ESPSettings.Name,     Callback = function(v) ESPSettings.Name      = v end })
sections.VisualsSection:Toggle({ Name = "Tool ESP",      Default = ESPSettings.Tool,     Callback = function(v) ESPSettings.Tool      = v end })
sections.VisualsSection:Toggle({ Name = "Distance ESP",  Default = ESPSettings.Distance, Callback = function(v) ESPSettings.Distance  = v end })
sections.VisualsSection:Toggle({ Name = "Health ESP",    Default = ESPSettings.Health,   Callback = function(v) ESPSettings.Health    = v end })
sections.VisualsSection:Toggle({ Name = "Player Chams",  Default = ESPSettings.Chams,    Callback = function(v) ESPSettings.Chams     = v end })
sections.VisualsSection:Toggle({ Name = "Team Check",    Default = ESPSettings.TeamCheck,Callback = function(v) ESPSettings.TeamCheck = v end })
sections.VisualsSection:Toggle({ Name = "Goofy Tracers",       Default = ESPSettings.Tracers,  Callback = function(v) ESPSettings.Tracers   = v end })

sections.VisualsSection:Divider()
sections.VisualsSection:Header({ Name = "ESP DRAW COLOR" })
sections.VisualsSection:Colorpicker({ Name = "Box Color",         Default = ESPSettings.BoxColor,    Callback = function(c) ESPSettings.BoxColor    = c end })
sections.VisualsSection:Colorpicker({ Name = "Name Color",        Default = ESPSettings.NameColor,   Callback = function(c) ESPSettings.NameColor   = c end })
sections.VisualsSection:Colorpicker({ Name = "Health Bar Color",  Default = ESPSettings.HealthColor, Callback = function(c) ESPSettings.HealthColor = c end })
sections.VisualsSection:Colorpicker({ Name = "Tracer Color",      Default = ESPSettings.TracerColor, Callback = function(c) ESPSettings.TracerColor = c end })


-- END OF RAPID ESP



-- Quick Shop Tab

-- GasStation Shop Dropdown
sections.QuickShopSection:Dropdown({
    Name = "GasStation Shop",
    Multi = false,
    Required = true,
    Options = {
        "Water",
        "Shiesty",
        "BluGloves",
        "WhiteGloves",
        "BlackGloves",
        "RawSteak",
        "BluCamoGloves",
        "RedCamoGloves",
        "PinkCamoGloves"
    },
    Default = "Water",
    Callback = function(option)
        local shopRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ShopRemote")
        if shopRemote then
            shopRemote:InvokeServer(option)
        else
            Window:Notify({
                Title = "Error",
                Description = "ShopRemote not found!",
                Lifetime = 3
            })
        end
    end
}, "GasStationDropdown")

-- Exotic Shop Dropdown
sections.QuickShopSection:Dropdown({
    Name = "Exotic Shop",
    Multi = false,
    Required = true,
    Options = {
        "FakeCard",
        "FijiWater",
        "FreshWater",
        "G26",
        "Ice-Fruit Bag",
        "Ice-Fruit Cupz",
        "Lemonade",
        "RawSteak",
        "Shiesty"
    },
    Default = "FijiWater",
    Callback = function(option)
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ExoticShopRemote")
        if remote then
            remote:InvokeServer(option)
        else
            Window:Notify({
                Title = "Error",
                Description = "ExoticShopRemote not found!",
                Lifetime = 3
            })
        end
    end
}, "ExoticDropdown")




-- end of QuickShop

sections.GunModSection1:Toggle({
    Name = "Infinite Ammo",
    Callback = function(state)
        if state then
            local player = game.Players.LocalPlayer
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                local success, settings = pcall(function()
                    return require(tool:FindFirstChild("Setting"))
                end)

                if success and type(settings) == "table" then
                    settings.LimitedAmmoEnabled = false
                    settings.MaxAmmo = 9e9
                    settings.AmmoPerMag = 9e9
                    settings.Ammo = 9e9
                    print("Infinite Ammo enabled.")
                else
                    warn("Could not require settings from tool.")
                end
            else
                warn("No tool found in character.")
            end
        else
            print("Infinite Ammo toggle disabled.")
        end
    end
})

sections.GunModSection1:Toggle({
    Name = "No Recoil",
    Callback = function(state)
        if state then
            local player = game.Players.LocalPlayer
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                local success, settings = pcall(function()
                    return require(tool:FindFirstChild("Setting"))
                end)

                if success and type(settings) == "table" then
                    settings.Recoil = 0
                    print("No Recoil enabled.")
                else
                    warn("Failed to access tool settings.")
                end
            else
                warn("No tool equipped.")
            end
        else
            print("No Recoil toggle disabled.")
        end
    end
})

sections.GunModSection1:Toggle({
    Name = "Full Auto",
    Callback = function(state)
        if state then
            local player = game.Players.LocalPlayer
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                local success, settings = pcall(function()
                    return require(tool:FindFirstChild("Setting"))
                end)

                if success and type(settings) == "table" then
                    settings.Auto = true
                    print("Full Auto enabled.")
                else
                    warn("Failed to load settings from tool.")
                end
            else
                warn("No tool found in character.")
            end
        else
            print("Full Auto toggle disabled.")
        end
    end
})

sections.GunModSection1:Toggle({
    Name = "Instant Fire",
    Callback = function(state)
        if state then
            local player = game.Players.LocalPlayer
            local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
            if tool then
                local success, settings = pcall(function()
                    return require(tool:FindFirstChild("Setting"))
                end)

                if success and type(settings) == "table" then
                    settings.FireRate = 0
                    print("Instant Fire enabled.")
                else
                    warn("Failed to load tool settings.")
                end
            else
                warn("No tool equipped.")
            end
        else
            print("Instant Fire toggle disabled.")
        end
    end
})


-- end of gun mods




-- CONFIG SECTION + FINAL SETUP
MacLib:SetFolder("LibaryFolder")
tabs.Settings:InsertConfigSection("Left")

Window.onUnloaded(function()
    print("Unloaded!")
end)

tabs.Main:Select()
MacLib:LoadAutoLoadConfig()



