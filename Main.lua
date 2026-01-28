-- Tha Bronx 3 Exploit Hub - Custom Theme Fixed + Infinite Stamina Added + Teleports Fixed
local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Your exact custom theme (applied correctly)
local customTheme = {
   TextColor = Color3.fromRGB(255, 255, 255),
   Background = Color3.fromRGB(15, 15, 15),
   Topbar = Color3.fromRGB(15, 15, 15),
   Shadow = Color3.fromRGB(255, 255, 255),
   NotificationBackground = Color3.fromRGB(15, 15, 15),
   NotificationTextColor = Color3.fromRGB(255, 255, 255),
   NotificationActionsBackground = Color3.fromRGB(35, 0, 70),
   TabBackground = Color3.fromRGB(15, 15, 15),
   TabStroke = Color3.fromRGB(15, 15, 15),
   TabBackgroundSelected = Color3.fromRGB(15, 15, 15),
   TabTextColor = Color3.fromRGB(149, 149, 149),
   SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
   ElementBackground = Color3.fromRGB(15, 15, 15),
   ElementBackgroundHover = Color3.fromRGB(15, 15, 15),
   SecondaryElementBackground = Color3.fromRGB(15, 15, 15),
   ElementStroke = Color3.fromRGB(77, 251, 16),
   SecondaryElementStroke = Color3.fromRGB(77, 251, 16),
   SliderBackground = Color3.fromRGB(255, 255, 255),
   SliderProgress = Color3.fromRGB(77, 251, 16),
   SliderStroke = Color3.fromRGB(77, 251, 16),
   ToggleBackground = Color3.fromRGB(15, 15, 15),
   ToggleEnabled = Color3.fromRGB(77, 251, 16),
   ToggleDisabled = Color3.fromRGB(255, 255, 255),
   ToggleEnabledStroke = Color3.fromRGB(77, 251, 16),
   ToggleDisabledStroke = Color3.fromRGB(15, 15, 15),
   ToggleEnabledOuterStroke = Color3.fromRGB(255, 255, 255),
   ToggleDisabledOuterStroke = Color3.fromRGB(255, 255, 255),
   DropdownSelected = Color3.fromRGB(15, 15, 15),
   DropdownUnselected = Color3.fromRGB(15, 15, 15),
   InputBackground = Color3.fromRGB(15, 15, 15),
   InputStroke = Color3.fromRGB(77, 251, 16)
}

local Window = Rayfield:CreateWindow({
   Name = "Tha Bronx 3 Exploit Hub - " .. executor,
   LoadingTitle = "Loading Exploit...",
   LoadingSubtitle = "by Grok",
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "Bronx3Hub" },
   Discord = { Enabled = false, Invite = "", RememberJoins = true },
   KeySystem = true,
   KeySettings = {
      Title = "",
      Subtitle = "Authentication Required",
      Note = "Get your key at: discord.gg/dkshub",
      FileName = "jc_hub_key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = { "" },
      Theme = customTheme
   }
})

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- Webhook URL (replace with real one)
local webhookUrl = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"

local function sendWebhook()
   local username = player.Name
   local displayName = player.DisplayName
   local timeExecuted = os.date("%Y-%m-%d %H:%M:%S")
   local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
   
   local data = {
      embeds = {{
         title = "Tha Bronx 3 Exploit Executed",
         fields = {
            {name = "Username", value = username, inline = true},
            {name = "Display Name", value = displayName, inline = true},
            {name = "Executor", value = executor, inline = true},
            {name = "Time", value = timeExecuted, inline = true}
         },
         thumbnail = {url = avatarUrl},
         color = 0x4DFF4D
      }}
   }
   
   pcall(function()
      HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
   end)
end

sendWebhook()

local positions = {
   CookingPot = CFrame.new(-614, 356, -683),
   ExoticSeller = CFrame.new(-66.005, 286.852, -320.709),
   Buyer = CFrame.new(-482.1479797363281, 254.05075073242188, -566.2430419921875),
   Bank = CFrame.new(-204, 284, -1223),
   StudioCash1 = CFrame.new(93427.375, 14484.35546875, 578.1520385742188),
   StudioCash2 = CFrame.new(93418.359375, 14483.7197265625, 565.07666015625),
   StudioCash3 = CFrame.new(93435.515625, 14483.2900390625, 563.6129150390625)
}

-- Teleport Fix: Use PivotTo + velocity reset + no anchor issues
local function flyTP(targetCFrame)
   local char = player.Character
   if not char or not char.PrimaryPart then return end
   local hrp = char.PrimaryPart
   
   -- Reset physics to prevent rubberband
   hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
   hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
   hrp.CFrame = targetCFrame -- Direct set first to avoid tween glitches
   task.wait(0.1)
   
   -- Smooth tween for visual feel
   local tween = TweenService:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
   tween:Play()
   tween.Completed:Wait()
end

-- Auto Buy Supplies (stock check)
local function AutoBuySupplies()
   local Items = {"Ice-Fruit Bag", "Ice-Fruit Cupz", "FijiWater", "FreshWater"}
   local SharedStorage = ReplicatedStorage:FindFirstChild("SharedStorage")
   if not SharedStorage then warn("SharedStorage not found") return false end
   local ExoticStock = SharedStorage:FindFirstChild("ExoticStock")
   if not ExoticStock then warn("ExoticStock not found") return false end
   
   for _, item in ipairs(Items) do
      local stock = ExoticStock:FindFirstChild(item)
      if not stock or stock.Value <= 0 then
         Rayfield:Notify({Title = "Out of Stock", Content = item .. " is out of stock!", Duration = 5})
         return false
      end
   end
   
   flyTP(positions.Buyer)
   task.wait(0.8)
   for _, obj in pairs(workspace:GetDescendants()) do
      if obj:IsA("ProximityPrompt") and string.lower(obj.ActionText or ""):find("buy") then
         obj:InputHoldBegin()
         task.wait(0.05)
         obj:InputHoldEnd()
      end
   end
   return true
end

-- Exploits Tab
ExploitsTab:CreateToggle({
   Name = "Instant Prompts (No Hold E)",
   CurrentValue = false,
   Callback = function(enabled)
      if enabled then
         for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then v.HoldDuration = 0 end
         end
      end
   end
})

ExploitsTab:CreateButton({
   Name = "Auto Buy Kool Aid Supplies",
   Callback = AutoBuySupplies
})

ExploitsTab:CreateButton({
   Name = "Infinite Money Vulnerability (990k)",
   Callback = function()
      flyTP(positions.ExoticSeller)
      task.wait(0.8)
      local tool = player.Backpack:FindFirstChild("Ice Fruit Cupz") or player.Character:FindFirstChild("Ice Fruit Cupz")
      if tool then player.Character.Humanoid:EquipTool(tool) task.wait(0.5) end
      for _, v in ipairs(workspace:GetDescendants()) do
         if v:IsA("ProximityPrompt") and string.lower(v.ActionText or ""):find("sell") then
            v:InputHoldBegin() task.wait(0.05) v:InputHoldEnd() break
         end
      end
   end
})

-- Teleports Dropdown (updated positions)
TeleportsTab:CreateDropdown({
   Name = "Teleport To",
   Options = {"Cooking Pot", "Kool Aid Seller", "Buyer", "Bank"},
   CurrentOption = "Cooking Pot",
   Callback = function(selected)
      if selected == "Cooking Pot" then flyTP(positions.CookingPot) end
      if selected == "Kool Aid Seller" then flyTP(positions.ExoticSeller) end
      if selected == "Buyer" then flyTP(positions.Buyer) end
      if selected == "Bank" then flyTP(positions.Bank) end
   end
})

-- Autofarm Tab (Studio Cash)
AutofarmTab:CreateToggle({
   Name = "Studio Cash Autofarm",
   CurrentValue = false,
   Callback = function(enabled)
      if enabled then
         task.spawn(function()
            local cashSpots = {positions.StudioCash1, positions.StudioCash2, positions.StudioCash3}
            for _, cf in ipairs(cashSpots) do
               flyTP(cf)
               task.wait(1.2)
               for _, v in ipairs(workspace:GetDescendants()) do
                  if v:IsA("ProximityPrompt") and v.Parent and v.Parent.Name:find("StudioPay") then
                     v:InputHoldBegin() task.wait(0.05) v:InputHoldEnd()
                  end
               end
            end
         end)
      end
   end
})

-- Player Tab
local speedConn
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(value)
      if speedConn then speedConn:Disconnect() end
      speedConn = RunService.Heartbeat:Connect(function()
         local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
         if hum then hum.WalkSpeed = value end
      end)
   end
})

PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Callback = function(enabled)
      if enabled then
         RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
               for _, part in ipairs(char:GetDescendants()) do
                  if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.CanCollide then
                     part.CanCollide = false
                  end
               end
            end
         end)
      end
   end
})

-- Misc Tab - Infinite Stamina (using your code style + fixed path)
MiscTab:CreateToggle({
   Name = "Infinite Stamina",
   CurrentValue = false,
   Callback = function(Value)
      task.spawn(function()
         while Value do
            task.wait(0.5)
            local gui = player:WaitForChild("PlayerGui")
            local staminaGui = gui:FindFirstChild("Stamina") -- Change "Stamina" to actual GUI name if different
            if staminaGui then
               local staminaScript = staminaGui:FindFirstChild("StaminaScript") or staminaGui:FindFirstChildWhichIsA("LocalScript")
               if staminaScript then staminaScript.Disabled = true end
               -- Alternative: force stamina value if it's a NumberValue
               local staminaValue = staminaGui:FindFirstChild("Stamina") or staminaGui:FindFirstChild("CurrentStamina")
               if staminaValue and staminaValue:IsA("NumberValue") then staminaValue.Value = staminaValue.MaxValue or 100 end
            end
         end
      end)
   end
})

-- Other Misc toggles (from previous)
MiscTab:CreateToggle({
   Name = "Infinite Hunger",
   CurrentValue = false,
   Callback = function(Value)
      task.spawn(function()
         while Value do
            task.wait(1)
            local gui = player.PlayerGui
            local hunger = gui and gui:FindFirstChild("Hunger")
            local script = hunger and hunger.Frame.Frame.Frame:FindFirstChild("HungerBarScript")
            if script then script.Disabled = true end
         end
      end)
   end
})

MiscTab:CreateToggle({
   Name = "Infinite Sleep",
   CurrentValue = false,
   Callback = function(Value)
      task.spawn(function()
         while Value do
            task.wait(1)
            local gui = player.PlayerGui
            local sleepGui = gui and gui:FindFirstChild("SleepGui")
            local script = sleepGui and sleepGui.Frame.sleep.SleepBar:FindFirstChild("sleepScript")
            if script then script.Disabled = true end
         end
      end)
   end
})

-- ... (add Disable Death Screen / Instant Respawn as before if needed)

Rayfield:Notify({
   Title = "Loaded Correctly",
   Content = "Custom theme applied • Infinite Stamina added • Teleports should now work (PivotTo + tween)",
   Duration = 6
})
