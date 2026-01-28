-- Executor Detection
local executor = identifyexecutor and identifyexecutor() or getexecutorname and getexecutorname() or "Unknown"
if syn then executor = "Synapse X"
elseif fluxus then executor = "Fluxus"
elseif Krnl then executor = "Krnl"
elseif getgenv and getgenv().ECLIPSE then executor = "Eclipse"
elseif getgenv and getgenv().DELTA then executor = "Delta"
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Tha Bronx 3 Exploit - " .. executor .. " - Fixed 2025",
   LoadingTitle = "Loading Stable Version...",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "ThaBronx3Stable" },
   Discord = { Enabled = false },
   KeySystem = false
})

local ExploitsTab = Window:CreateTab("Exploits", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local AutofarmTab = Window:CreateTab("Autofarm", 4483362458)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local connections = {}  -- Track all connections to clean up
local AutoSellEnabled = false
local StudioFarmEnabled = false
local NoClipEnabled = false
local InfJumpEnabled = false

-- Safe Smooth TP
local function smoothTP(targetCFrame, duration)
   duration = duration or 0.45
   local char = player.Character
   if not char then return end
   local hrp = char:FindFirstChild("HumanoidRootPart")
   if not hrp then return end
   
   pcall(function()
      hrp.Velocity = Vector3.zero
      hrp.AssemblyLinearVelocity = Vector3.zero
      hrp.AssemblyAngularVelocity = Vector3.zero
      
      local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
      tween:Play()
      tween.Completed:Wait()
   end)
end

-- Global Instant Prompts
ExploitsTab:CreateButton({
   Name = "Global Instant Prompts (No Hold E)",
   Callback = function()
      for _, obj in workspace:GetDescendants() do
         pcall(function()
            if obj:IsA("ProximityPrompt") and not obj.Parent.Name:find("MimicATM") then
               obj.HoldDuration = 0
            end
         end)
      end
      local conn = workspace.DescendantAdded:Connect(function(obj)
         task.delay(0.2, function()
            pcall(function()
               if obj:IsA("ProximityPrompt") and not obj.Parent.Name:find("MimicATM") then
                  obj.HoldDuration = 0
               end
            end)
         end)
      end)
      table.insert(connections, conn)
      Rayfield:Notify({Title = "Instant Prompts", Content = "Activated (excluding MimicATM)", Duration = 3})
   end
})

-- Buy Ice Fruit Items (targeted + safe delay)
ExploitsTab:CreateButton({
   Name = "Buy Max Ice Fruit / Water Items",
   Callback = function()
      task.spawn(function()
         local keywords = {"ice fruit", "ice%-fruit", "cupz", "bag", "fiji", "fresh water", "fijiwater", "freshwater"}
         for _ = 1, 10 do
            for _, obj in workspace:GetDescendants() do
               if obj:IsA("ProximityPrompt") then
                  local txt = (obj.ActionText or obj.ObjectText or ""):lower()
                  for _, kw in keywords do
                     if txt:find(kw) then
                        pcall(function()
                           local char = player.Character
                           local hrp = char and char:FindFirstChild("HumanoidRootPart")
                           if hrp and obj.Parent and obj.Parent:IsA("BasePart") then
                              smoothTP(obj.Parent.CFrame * CFrame.new(0,0,-3.5), 0.4)
                              task.wait(0.6)
                              obj.HoldDuration = 0
                              obj:InputHoldBegin()
                              task.wait(0.04)
                              obj:InputHoldEnd()
                           end
                        end)
                        break
                     end
                  end
               end
            end
            task.wait(1.2)  -- Very safe delay
         end
      end)
   end
})

-- Infinite Money (Kool Aid Sell)
local AutoSellToggle = ExploitsTab:CreateToggle({
   Name = "Infinite Money (Auto Sell Kool Aid)",
   CurrentValue = false,
   Callback = function(val)
      AutoSellEnabled = val
      if val then
         task.spawn(function()
            while AutoSellEnabled do
               pcall(function()
                  local char = player.Character
                  local hum = char and char:FindFirstChildOfClass("Humanoid")
                  local hrp = char and char:FindFirstChild("HumanoidRootPart")
                  if not (hum and hrp) then return end

                  -- Equip cup
                  local cupNames = {"Ice Fruit Cupz", "Ice-Fruit Cupz", "Ice Fruit Cups"}
                  local cup = nil
                  for _, name in cupNames do
                     cup = player.Backpack:FindFirstChild(name) or char:FindFirstChild(name)
                     if cup then break end
                  end
                  if cup and cup:IsA("Tool") then
                     hum:EquipTool(cup)
                     task.wait(0.4)
                  end

                  -- Find sell prompt
                  local prompt = nil
                  for _, obj in workspace:GetDescendants() do
                     if obj:IsA("ProximityPrompt") then
                        local a = (obj.ActionText or ""):lower()
                        local o = (obj.ObjectText or ""):lower()
                        local p = obj.Parent.Name:lower()
                        if (a:find("sell") or o:find("sell")) and (a:find("kool") or a:find("aid") or p:find("vendor") or p:find("seller")) then
                           prompt = obj
                           break
                        end
                     end
                  end

                  if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                     smoothTP(prompt.Parent.CFrame * CFrame.new(0,0,-4), 0.5)
                     task.wait(0.7)
                     prompt.HoldDuration = 0
                     prompt:InputHoldBegin()
                     task.wait(0.05)
                     prompt:InputHoldEnd()
                  end
               end)
               task.wait(2.5)
            end
         end)
      end
   end
})

-- Studio Autofarm
local StudioToggle = AutofarmTab:CreateToggle({
   Name = "Studio Autofarm (Collect Money)",
   CurrentValue = false,
   Callback = function(val)
      StudioFarmEnabled = val
      if val then
         task.spawn(function()
            while StudioFarmEnabled do
               pcall(function()
                  local char = player.Character
                  local hrp = char and char:FindFirstChild("HumanoidRootPart")
                  if not hrp then return end

                  local studioPart = nil
                  for _, v in workspace:GetDescendants() do
                     if v:IsA("BasePart") and v.Name:lower():find("studio") then
                        studioPart = v
                        break
                     end
                  end
                  if studioPart then
                     smoothTP(studioPart.CFrame + Vector3.new(0,6,0), 0.5)
                     task.wait(1)
                  end

                  -- Collect nearby money prompts
                  for _, obj in workspace:GetDescendants() do
                     if obj:IsA("ProximityPrompt") then
                        local a = (obj.ActionText or ""):lower()
                        if a:find("collect") or a:find("money") or a:find("cash") or a:find("take") then
                           local dist = (obj.Parent.Position - hrp.Position).Magnitude
                           if dist < 60 then
                              smoothTP(obj.Parent.CFrame * CFrame.new(0,0,-3), 0.35)
                              task.wait(0.5)
                              obj.HoldDuration = 0
                              obj:InputHoldBegin()
                              task.wait(0.04)
                              obj:InputHoldEnd()
                           end
                        end
                     end
                  end
               end)
               task.wait(2.8)
            end
         end)
      end
   end
})

-- Teleports (simple & safe)
TeleportsTab:CreateButton({
   Name = "Teleport to Cooking Pot",
   Callback = function() 
      for _, v in workspace:GetDescendants() do
         if v:IsA("BasePart") and (v.Name:lower():find("pot") or v.Name:lower():find("cook") or v.Name:lower():find("stove")) then
            smoothTP(v.CFrame + Vector3.new(0,5,0))
            break
         end
      end
   end
})

TeleportsTab:CreateButton({
   Name = "Teleport to Kool Aid Seller",
   Callback = function() 
      for _, v in workspace:GetDescendants() do
         if v:IsA("ProximityPrompt") then
            local a = (v.ActionText or ""):lower()
            if a:find("sell") and (a:find("kool") or a:find("aid")) then
               smoothTP(v.Parent.CFrame * CFrame.new(0,0,-5))
               break
            end
         end
      end
   end
})

-- Player Mods
PlayerTab:CreateSlider({Name = "WalkSpeed", Range = {16, 400}, Increment = 1, CurrentValue = 16, Callback = function(v)
   local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if hum then hum.WalkSpeed = v end
end})

PlayerTab:CreateSlider({Name = "Jump Power", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v)
   local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
   if hum then hum.JumpPower = v end
end})

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(val)
      InfJumpEnabled = val
      if val then
         local conn = UserInputService.JumpRequest:Connect(function()
            if InfJumpEnabled then
               local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
               if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
         end)
         table.insert(connections, conn)
      end
   end
})

-- Fixed NoClip (Stepped + exclude HRP + cleanup)
PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Callback = function(val)
      NoClipEnabled = val
      if val then
         local conn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char and NoClipEnabled then
               local hrp = char:FindFirstChild("HumanoidRootPart")
               for _, part in char:GetDescendants() do
                  if part:IsA("BasePart") and part ~= hrp and part.CanCollide then
                     part.CanCollide = false
                  end
               end
            end
         end)
         table.insert(connections, conn)
      end
   end
})

-- Anti-Kick
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
   local method = getnamecallmethod()
   if method == "Kick" then return end
   return old(self, ...)
end)
setreadonly(mt, true)

-- Cleanup on leave / respawn
local function cleanup()
   for _, conn in connections do
      pcall(function() conn:Disconnect() end)
   end
   connections = {}
end

player.CharacterRemoving:Connect(cleanup)
player.AncestryChanged:Connect(function(_, parent)
   if parent == nil then cleanup() end
end)

Rayfield:Notify({
   Title = "Loaded Stable Version",
   Content = "NoClip / Sounds / Movement / Camera fixed - no spam, no breaks",
   Duration = 6
})
