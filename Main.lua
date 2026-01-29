-- Cars Trading Exploit Script (Prison Life Compatible)
-- Made by ExploitDev | Rayfield UI | Anti-Cheat Bypass
-- Supports Synapse X, Script-Ware, Krnl, Fluxus, Electron

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- Executor Detection (very basic – most modern executors fake/hide these)
local executor = "Unknown"
if syn            then executor = "Synapse X"     end
if gethui         then executor = "Script-Ware"   end
if Krnl           then executor = "Krnl"          end
if Fluxus         then executor = "Fluxus"        end
if Electron       then executor = "Electron"      end

print("Detected Executor: " .. executor)

-- Rayfield UI Library (2025 → make sure this link still works / is up-to-date)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--------------------------------------------------------------------------------
--                           Anti-Cheat Hook (basic)
--------------------------------------------------------------------------------
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall

setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Very naive anti-kick / anti-report bypass – most servers detect this now
    if method == "Kick" or method == "Destroy" then
        return
    end

    -- Block obvious anti-cheat remote events (very game-specific & weak)
    if method == "FireServer" then
        local name = tostring(self)
        if name:find("AntiCheat",1,true) or name:find("AC",1,true) or name:find("Report",1,true) then
            return
        end
    end

    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

--------------------------------------------------------------------------------
--                                 FOV Circle
--------------------------------------------------------------------------------
local fovCircle = Drawing.new("Circle")
fovCircle.Visible       = false
fovCircle.Thickness     = 2
fovCircle.Color         = Color3.fromRGB(255, 0, 0)
fovCircle.Filled        = false
fovCircle.Radius        = 100
fovCircle.NumSides      = 64
fovCircle.Transparency  = 0.8
fovCircle.Position      = Vector2.new(0,0)

--------------------------------------------------------------------------------
--                             Aimbot / Silent Aim
--------------------------------------------------------------------------------
local aimbotEnabled    = false
local silentAimEnabled = false
local fovSize          = 150
local aimPart          = "Head"
local smoothAmount     = 0.12   -- lower = smoother but slower

local function getClosestPlayerToCursor()
    local closest, minDist = nil, fovSize

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end

        local part = plr.Character:FindFirstChild(aimPart)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
        if dist < minDist then
            minDist = dist
            closest = plr
        end
    end

    return closest
end

-- Very basic silent aim via __index hook (many games patch / detect this now)
local oldIndex
local function enableSilentAimHook()
    if silentAimEnabled then return end

    local mt = getrawmetatable(game)
    oldIndex = mt.__index

    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if silentAimEnabled and self:IsA("BasePart") and key == "Position" then
            local target = getClosestPlayerToCursor()
            if target and target.Character then
                local aimP = target.Character:FindFirstChild(aimPart)
                if aimP then
                    return aimP.Position
                end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)

    silentAimEnabled = true
end

local function disableSilentAimHook()
    if not silentAimEnabled then return end
    if not oldIndex then return end

    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    mt.__index = oldIndex
    setreadonly(mt, true)

    silentAimEnabled = false
end

--------------------------------------------------------------------------------
--                                    Fly
--------------------------------------------------------------------------------
local flying = false
local flySpeed = 50
local bv, bav

local function startFly()
    if flying then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp

    bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bav.AngularVelocity = Vector3.zero
    bav.Parent = hrp

    flying = true

    task.spawn(function()
        while flying and hrp.Parent do
            local cam = Camera.CFrame
            local move = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W)     then move += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)     then move -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)     then move -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)     then move += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += cam.UpVector   end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= cam.UpVector end

            local finalSpeed = flySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then finalSpeed *= 2.5 end

            bv.Velocity = move.Unit * finalSpeed
            task.wait()
        end
    end)
end

local function stopFly()
    flying = false
    if bv  then bv:Destroy()  bv  = nil end
    if bav then bav:Destroy() bav = nil end
end

--------------------------------------------------------------------------------
--                                   ESP
--------------------------------------------------------------------------------
local espEnabled = false
local espObjects = {}

local function createESP(plr)
    if plr == LocalPlayer then return end

    local data = {
        box      = Drawing.new("Square"),
        name     = Drawing.new("Text"),
        health   = Drawing.new("Text"),
        dist     = Drawing.new("Text"),
        tracer   = Drawing.new("Line"),
    }

    for _, v in pairs(data) do
        v.Visible      = false
        v.Transparency = 1
        v.Outline      = true
        v.Font         = Drawing.Fonts.UI  -- or 2
    end

    data.box.Color       = Color3.fromRGB(255,80,80)
    data.box.Thickness   = 2
    data.box.Filled      = false

    data.name.Color      = Color3.new(1,1,1)
    data.name.Size       = 15
    data.name.Center     = true

    data.health.Color    = Color3.fromRGB(50,255,100)
    data.health.Size     = 14
    data.health.Center   = true

    data.dist.Color      = Color3.fromRGB(255,220,80)
    data.dist.Size       = 13
    data.dist.Center     = true

    data.tracer.Color    = Color3.fromRGB(255,50,255)
    data.tracer.Thickness = 1.5

    espObjects[plr] = data
end

local function removeESP(plr)
    if espObjects[plr] then
        for _, obj in pairs(espObjects[plr]) do
            obj:Remove()
        end
        espObjects[plr] = nil
    end
end

local function updateAllESP()
    if not espEnabled then
        for _, obj in pairs(espObjects) do
            for _, d in pairs(obj) do d.Visible = false end
        end
        return
    end

    for plr, data in pairs(espObjects) do
        local char = plr.Character
        if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Head") then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end

        local hrp    = char.HumanoidRootPart
        local head   = char.Head
        local hum    = char.Humanoid
        local root, onScreen = Camera:WorldToViewportPoint(hrp.Position)

        if not onScreen then
            for _, d in pairs(data) do d.Visible = false end
            continue
        end

        -- Simple 2D box approximation
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.8,0))
        local legPos  = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3.5,0))
        local height  = math.abs(headPos.Y - legPos.Y)
        local width   = height * 0.55

        data.box.Size     = Vector2.new(width, height)
        data.box.Position = Vector2.new(root.X - width/2, root.Y - height/2)
        data.box.Visible  = true

        data.name.Text    = plr.Name
        data.name.Position = Vector2.new(root.X, root.Y - height/2 - 18)
        data.name.Visible = true

        local hpPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        data.health.Text = math.floor(hum.Health) .. " HP"
        data.health.Color = Color3.new(1-hpPerc, hpPerc, 0)
        data.health.Position = Vector2.new(root.X, root.Y + height/2 + 3)
        data.health.Visible = true

        local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and 
                     (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 9999

        data.dist.Text    = math.floor(dist) .. " studs"
        data.dist.Position = Vector2.new(root.X, root.Y + height/2 + 18)
        data.dist.Visible = true

        -- Tracer from bottom center of screen
        data.tracer.From  = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
        data.tracer.To    = Vector2.new(root.X, root.Y + height/2)
        data.tracer.Visible = true
    end
end

--------------------------------------------------------------------------------
--                               Main Loops
--------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    fovCircle.Radius   = fovSize
    fovCircle.Visible  = aimbotEnabled

    if espEnabled then
        updateAllESP()
    end
end)

RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        local target = getClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            local goal = CFrame.lookAt(Camera.CFrame.Position, target.Character[aimPart].Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, smoothAmount)
        end
    end
end)

--------------------------------------------------------------------------------
--                                 UI
--------------------------------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Prison Life / Cars Trading Exploit",
    LoadingTitle = "Loading Godmode Menu...",
    LoadingSubtitle = "by ExploitDev",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ExploitDev-PL",
        FileName = "Settings"
    }
})

local Combat = Window:CreateTab("Combat", 4483362458)
local Visuals = Window:CreateTab("Visuals", 4483362458)
local Movement = Window:CreateTab("Movement", 4483362458)

-- Combat
Combat:CreateToggle({
    Name = "Aimbot (camera move)",
    CurrentValue = false,
    Callback = function(v) aimbotEnabled = v end,
})

Combat:CreateToggle({
    Name = "Silent Aim (__index hook)",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enableSilentAimHook()
        else
            disableSilentAimHook()
        end
    end,
})

Combat:CreateSlider({
    Name = "FOV Size",
    Range = {30, 600},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(v) fovSize = v end,
})

Combat:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso","RightHand"},
    CurrentOption = "Head",
    Callback = function(opt) aimPart = opt end,
})

-- Visuals
Visuals:CreateToggle({
    Name = "ESP (Box / Name / HP / Dist / Tracer)",
    CurrentValue = false,
    Callback = function(v)
        espEnabled = v
        if v then
            for _, plr in ipairs(Players:GetPlayers()) do
                createESP(plr)
            end
        else
            for _, obj in pairs(espObjects) do
                for _, d in pairs(obj) do d.Visible = false end
            end
        end
    end,
})

-- Movement
Movement:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v)
        if v then startFly() else stopFly() end
    end,
})

Movement:CreateSlider({
    Name = "Fly Speed",
    Range = {30, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) flySpeed = v end,
})

Movement:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 120},
    Increment = 2,
    CurrentValue = 16,
    Callback = function(v)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

-- Info
local Info = Window:CreateTab("Info")
Info:CreateLabel("Executor → " .. executor)
Info:CreateLabel("Game → Prison Life / similar")
Info:CreateLabel("Anti-cheat bypass → basic (may not work 2025+)")

--------------------------------------------------------------------------------
--                               Connections
--------------------------------------------------------------------------------
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.6)
        if espEnabled then
            createESP(plr)
        end
    end)
end)

-- Cleanup when player leaves
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        createESP(plr)
    end
    plr.AncestryChanged:Connect(function()
        if not plr.Parent then
            removeESP(plr)
        end
    end)
end

Players.PlayerRemoving:Connect(removeESP)

print("Exploit loaded – use at your own risk")
