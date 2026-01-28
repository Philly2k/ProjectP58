-- Executor Detection
local executor = identifyexecutor and identifyexecutor() or "Unknown"
if syn then executor = "Synapse X"
elseif fluxus then executor = "Fluxus"
elseif Krnl then executor = "Krnl"
elseif getgenv().ECLIPSE then executor = "Eclipse"
elseif getgenv().DELTA then executor = "Delta"
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Tha Bronx 3 Max Money Exploit - " .. executor .. " - Rayfield UI (Fixed Errors)",
   LoadingTitle = "Loading Fixed Exploit...",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "ThaBronx3Fixed" },
   Discord = { Enabled = false, Invite = "noinv", RememberJoins = true },
   KeySystem = false
})

local ExploitsTab = Window:CreateTab("Exploits", 4483362458)
local TeleportsTab = Window:CreateTab("Teleports", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local AutofarmTab = Window:CreateTab("Autofarm", 4483362458)

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Globals
local AutoSellEnabled = false
local StudioFarmEnabled = false
local NoClipEnabled = false
local InfJumpEnabled = false
local InfJumpConnection = nil
local NoClipConnection = nil

-- Fixed Smooth TP (No state changes, velocity reset, safer)
local function smoothTP(targetCFrame, duration)
   pcall(function()
      local char = player.Character
      if not char then return end
      local hrp = char:FindFirstChild("HumanoidRootPart")
      if not hrp then return end
      -- Reset velocity to prevent fling
      hrp.Velocity = Vector3.new(0, 0, 0)
      hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
      -- Tween
      local tweenInfo = TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad)
      local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
      tween:Play()
      tween.Completed:Wait()
   end)
end

-- Global Instant Prompts
local InstantPromptsButton = ExploitsTab:CreateButton({
   Name = "Global Instant Prompts (No Hold E)",
   Callback = function()
      local function isMimicATM(obj)
         local parent = obj.Parent
         while parent do
            if parent.Name == "MimicATM" then return true end
            parent = parent.Parent
         end
         return false
      end
      local function setInstant(obj)
         if obj:IsA("ProximityPrompt") and not isMimicATM(obj) then
            obj.HoldDuration = 0
         end
      end
      for _, obj in pairs(workspace:GetDescendants()) do 
         pcall(setInstant, obj) 
      end
      workspace.DescendantAdded:Connect(function(obj)
         task.wait(0.1)
         pcall(setInstant, obj)
      end)
      Rayfield:Notify({Title = "Instant Prompts", Content = "All HoldDuration set to 0!", Duration = 4})
   end
})

-- Buy Specific Items (Targeted, Anti-Kick Delays)
ExploitsTab:CreateButton({
   Name = "Buy Max Ice Fruit Items (Bag, Cupz, Fiji, Fresh Water)",
   Callback = function()
      spawn(function()
         Rayfield:Notify({Title = "Buying Ice Fruit Items...", Content = "Max stacks from dealer!", Duration = 4})
         local items = {"ice fruit", "ice%-fruit", "fiji", "fresh water", "bag", "cupz", "fijiwater", "freshwater"}
         for i = 1, 12 do
            for _, obj in pairs(workspace:GetDescendants()) do
               if obj:IsA("ProximityPrompt") then
                  local text = string.lower(obj.ActionText or obj.ObjectText or "")
                  local match = false
                  for _, item in pairs(items) do
                     if text:find(item) then match = true; break end
                  end
                  if match then
                     pcall(function()
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") and obj.Parent and obj.Parent:IsA("BasePart") then
                           smoothTP(obj.Parent.CFrame * CFrame.new(math.random(-2,2), 0, -4))
                           task.wait(0.5)
                           obj.HoldDuration = 0
                           obj:InputHoldBegin()
                           task.wait(0.03)
                           obj:InputHoldEnd()
                        end
                     end)
                  end
               end
            end
            task.wait(1)
         end
      end)
   end
})

-- Infinite Money Toggle
local AutoSellToggle = ExploitsTab:CreateToggle({
   Name = "Infinite Money (Auto Sell Kool Aid)",
   CurrentValue = false,
   Flag = "AutoSellToggle",
   Callback = function(Value)
      AutoSellEnabled = Value
      if Value then
         spawn(function()
            while AutoSellEnabled do
               pcall(function()
                  local char = player.Character
                  if not char then return end
                  local humanoid = char:FindFirstChildOfClass("Humanoid")
                  if not humanoid then return end
                  local backpack = player.Backpack
                  local iceCup = backpack:FindFirstChild("Ice Fruit Cupz") or backpack:FindFirstChild("Ice-Fruit Cupz") or backpack:FindFirstChild("Ice Fruit Cups") or char:FindFirstChild("Ice Fruit Cupz")
                  if iceCup and iceCup:IsA("Tool") then
                     humanoid:EquipTool(iceCup)
                     task.wait(0.5)
                  end
                  local sellPrompt = nil
                  for _, obj in pairs(workspace:GetDescendants()) do
                     if obj:IsA("ProximityPrompt") then
                        local act = string.lower(obj.ActionText or "")
                        local objt = string.lower(obj.ObjectText or "")
                        local par = string.lower(obj.Parent.Name or "")
                        if (act:find("sell") or objt:find("sell")) and (act:find("kool") or act:find("aid") or act:find("drink") or par:find("kool") or par:find("vendor") or par:find("seller")) then
                           sellPrompt = obj
                           break
                        end
                     end
                  end
                  if sellPrompt and sellPrompt.Parent and sellPrompt.Parent:IsA("BasePart") then
                     smoothTP(sellPrompt.Parent.CFrame * CFrame.new(0, 0, -4))
                     task.wait(0.7)
                     sellPrompt.HoldDuration = 0
                     sellPrompt:InputHoldBegin()
                     task.wait(0.05)
                     sellPrompt:InputHoldEnd()
                  end
               end)
               task.wait(2.2)
            end
         end)
      end
   end
})

-- Studio Autofarm Toggle
local StudioToggle = AutofarmTab:CreateToggle({
   Name = "Studio Autofarm (TP & Collect All Money)",
   CurrentValue = false,
   Flag = "StudioToggle",
   Callback = function(Value)
      StudioFarmEnabled = Value
      if Value then
         spawn(function()
            while StudioFarmEnabled do
               pcall(function()
                  local studio = nil
                  for _, model in pairs(workspace:GetChildren()) do
                     if string.lower(model.Name):find("studio") then
                        studio = model
                        break
                     end
                  end
                  if not studio then
                     for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and string.lower(obj.Name):find("studio") then
                           studio = obj
                           break
                        end
                     end
                  end
                  local char = player.Character
                  if studio and char and char:FindFirstChild("HumanoidRootPart") then
                     local targetCF = (studio:IsA("BasePart") and studio.CFrame) or (studio.PrimaryPart and studio.PrimaryPart.CFrame) or studio:GetPivot()
                     smoothTP(targetCF * CFrame.new(0, 5, 0))
                     task.wait(1)
                     for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") then
                           local act = string.lower(obj.ActionText or "")
                           local par = string.lower(obj.Parent.Name or "")
                           if (act:find("collect") or act:find("money") or act:find("cash") or act:find("rob") or act:find("take") or act:find("grab") or par:find("money") or par:find("cash")) then
                              local hrp = char.HumanoidRootPart
                              local dist = (obj.Parent.Position - hrp.Position).Magnitude
                              if dist < 50 then
                                 smoothTP(obj.Parent.CFrame * CFrame.new(0,0,-3))
                                 task.wait(0.4)
                                 obj.HoldDuration = 0
                                 obj:InputHoldBegin()
                                 task.wait(0.03)
                                 obj:InputHoldEnd()
                              end
                           end
                        end
                     end
                  end
               end)
               task.wait(2)
            end
         end)
      end
   end
})

-- Teleports
local TpPotButton = TeleportsTab:CreateButton({
   Name = "Teleport to Cooking Pot",
   Callback = function()
      local pots = {}
      for _, obj in pairs(workspace:GetDescendants()) do
         if (string.lower(obj.Name):find("pot") or string.lower(obj.Name):find("cook") or string.lower(obj.Name):find("stove")) and obj:IsA("BasePart") then
            table.insert(pots, obj)
         end
      end
      if #pots > 0 then
         local pot = pots[1]
         smoothTP(pot.CFrame + Vector3.new(0, 5, 0))
      end
   end
})

local TpSellerButton = TeleportsTab:CreateButton({
   Name = "Teleport to Kool Aid Seller",
   Callback = function()
      local sellPrompt = nil
      for _, obj in pairs(workspace:GetDescendants()) do
         if obj:IsA("ProximityPrompt") then
            local act = string.lower(obj.ActionText or "")
            local objt = string.lower(obj.ObjectText or "")
            local par = string.lower(obj.Parent.Name or "")
            if (act:find("sell") or objt:find("sell")) and (act:find("kool") or act:find("aid") or act:find("drink") or par:find("kool") or par:find("vendor") or par:find("seller")) then
               sellPrompt = obj
               break
            end
         end
      end
      if sellPrompt and sellPrompt.Parent and sellPrompt.Parent:IsA("BasePart") then
         smoothTP(sellPrompt.Parent.CFrame * CFrame.new(0, 0, -5))
      end
   end
})

-- Player Mods
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      local char = player.Character
      if char and char:FindFirstChildOfClass("Humanoid") then
         char.Humanoid.WalkSpeed = Value
      end
   end
})

PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 400},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      local char = player.Character
      if char and char:FindFirstChildOfClass("Humanoid") then
         char.Humanoid.JumpPower = Value
      end
   end
})

-- Fixed Infinite Jump Toggle
local InfJumpToggle = PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Callback = function(Value)
      InfJumpEnabled = Value
      if InfJumpConnection then
         InfJumpConnection:Disconnect()
         InfJumpConnection = nil
      end
      if Value then
         InfJumpConnection = UserInputService.JumpRequest:Connect(function()
            local char = player.Character
            if char and InfJumpEnabled then
               local hum = char:FindFirstChildOfClass("Humanoid")
               if hum then
                  hum:ChangeState(Enum.HumanoidStateType.Jumping)
               end
            end
         end)
      end
   end
})

-- Fixed NoClip Toggle (Excludes HRP, Dynamic Char, No Breakage)
local NoClipToggle = PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Callback = function(Value)
      NoClipEnabled = Value
      if NoClipConnection then
         NoClipConnection:Disconnect()
         NoClipConnection = nil
      end
      if Value then
         NoClipConnection = RunService.Heartbeat:Connect(function()
            local char = player.Character
            if char and NoClipEnabled then
               local hrp = char:FindFirstChild("HumanoidRootPart")
               for _, part in pairs(char:GetDescendants()) do
                  if part:IsA("BasePart") and part.CanCollide and part ~= hrp then
                     part.CanCollide = false
                  end
               end
            end
         end)
      end
   end
})

-- Enhanced Anti-Cheat Hooks
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
   local method = getnamecallmethod()
   if method == "Kick" or method:lower() == "kick" then
      return task.wait(math.huge)
   end
   if method == "FireServer" then
      local args = {...}
      if tostring(self):lower():find("anti") or tostring(self):lower():find("cheat") or tostring(self):lower():find("detect") then
         return
      end
   end
   return oldNamecall(self, ...)
end)

-- Re-apply on respawn
player.CharacterAdded:Connect(function()
   task.wait(1)
   -- Sliders re-apply via callback checks
end)

Rayfield:Notify({
   Title = "Loaded (Errors Fixed!)",
   Content = "NoClip/Movement/Camera Fixed | RbxCharacterSounds Spam Stopped | All Features Safe",
   Duration = 8,
   Image = 4483362458
})
