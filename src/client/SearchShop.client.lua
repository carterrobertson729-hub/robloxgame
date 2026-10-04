--!strict
-- Shows how many searches you have. When you try to search with none left, a popup offers the
-- Robux search packs and the real odds. Display only: the server grants purchases after Roblox
-- confirms them.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ItemData = require(ReplicatedStorage.Shared.ItemData)
local Settings = require(ReplicatedStorage.Shared.Settings)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local dataUpdate = remotes:WaitForChild("DataUpdate") :: RemoteEvent
local itemFound = remotes:WaitForChild("ItemFound") :: RemoteEvent

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SearchShop"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function round(obj: GuiObject, radius: number)
	Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius)
end

-- Counter at the top left
local label = Instance.new("TextLabel")
label.Size = UDim2.fromOffset(210, 40)
label.Position = UDim2.fromOffset(182, 16)
label.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
label.BackgroundTransparency = 0.1
label.BorderSizePixel = 0
label.Font = Enum.Font.GothamBold
label.TextSize = 16
label.TextColor3 = Color3.new(1, 1, 1)
label.Text = "🔍 Free: -"
label.Parent = gui
round(label, 10)

-- Popup
local shop = Instance.new("Frame")
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.Position = UDim2.fromScale(0.5, 0.5)
shop.Size = UDim2.fromOffset(540, 510)
shop.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
shop.BorderSizePixel = 0
shop.Visible = false
shop.Parent = gui
round(shop, 14)
local shopStroke = Instance.new("UIStroke")
shopStroke.Color = Color3.fromRGB(90, 140, 230)
shopStroke.Thickness = 3
shopStroke.Parent = shop

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 40)
title.Position = UDim2.fromOffset(10, 4)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1, 1, 1)
title.Text = "🔍 Out of free searches!"
title.Parent = shop

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -40, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
close.BorderSizePixel = 0
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "✖"
close.Parent = shop
round(close, 8)

-- Bouncing pictures. A slot with an ImageId shows that picture; otherwise its emoji.
local imageCount = #Settings.ShopImages
local slotWidth = 540 / imageCount
for i, entry in Settings.ShopImages do
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(56, 56)
	holder.Position = UDim2.fromOffset((i - 0.5) * slotWidth - 28, 50)
	holder.BackgroundTransparency = 1
	holder.Parent = shop

	if entry.ImageId ~= "" then
		local img = Instance.new("ImageLabel")
		img.Size = UDim2.fromScale(1, 1)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://" .. entry.ImageId
		img.Parent = holder
	else
		local emoji = Instance.new("TextLabel")
		emoji.Size = UDim2.fromScale(1, 1)
		emoji.BackgroundTransparency = 1
		emoji.TextScaled = true
		emoji.Text = entry.Emoji
		emoji.Parent = holder
	end

	-- Bounce up and back down forever, each picture a little later than the last.
	local base = holder.Position
	local tween = TweenService:Create(
		holder,
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
		{ Position = base - UDim2.fromOffset(0, 14) }
	)
	task.delay(i * 0.15, function()
		tween:Play()
	end)
end

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 22)
status.Position = UDim2.fromOffset(10, 116)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(210, 210, 225)
status.Text = "🕛 Free searches come back every day. Or grab a pack:"
status.Parent = shop

local function oddsText(luck: number): string
	local parts = {}
	for _, entry in ItemData.rarityWeights(luck) do
		table.insert(parts, string.format("%s %s %.1f%%", entry.Rarity.Emoji, entry.Rarity.Name, entry.Chance * 100))
	end
	return table.concat(parts, "   ")
end

-- Three pack cards side by side: searches on top, luck underneath, then the price.
local CARD_W, CARD_GAP = 166, 11
local cardY = 144
for i, pack in Settings.SearchPacks do
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(CARD_W, 190)
	card.Position = UDim2.fromOffset(10 + (i - 1) * (CARD_W + CARD_GAP), cardY)
	card.BackgroundColor3 = Color3.fromRGB(40, 48, 70)
	card.BorderSizePixel = 0
	card.Parent = shop
	round(card, 12)

	local function cardLabel(y: number, h: number, text: string, color: Color3, size: number): TextLabel
		local l = Instance.new("TextLabel")
		l.Size = UDim2.new(1, -12, 0, h)
		l.Position = UDim2.fromOffset(6, y)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.GothamBold
		l.TextSize = size
		l.TextWrapped = true
		l.TextColor3 = color
		l.Text = text
		l.Parent = card
		return l
	end

	cardLabel(8, 22, "🛍️ " .. pack.Name, Color3.fromRGB(190, 200, 225), 14)
	cardLabel(36, 56, "🔍 " .. pack.Searches .. " more searches", Color3.new(1, 1, 1), 20)
	cardLabel(98, 40, "🍀 " .. math.floor(pack.Luck * 100 + 0.5) .. "% better luck", Color3.fromRGB(120, 230, 140), 16)

	local buy = Instance.new("TextButton")
	buy.Size = UDim2.new(1, -20, 0, 36)
	buy.Position = UDim2.new(0, 10, 1, -46)
	buy.BorderSizePixel = 0
	buy.Font = Enum.Font.GothamBold
	buy.TextSize = 16
	buy.TextColor3 = Color3.new(1, 1, 1)
	buy.Parent = card
	round(buy, 8)
	if pack.ProductId == 0 then
		buy.Text = "🔒 Coming soon"
		buy.BackgroundColor3 = Color3.fromRGB(80, 80, 92)
	else
		buy.Text = "R$ " .. pack.Robux
		buy.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
	end
	buy.Activated:Connect(function()
		if pack.ProductId == 0 then
			status.Text = "🔒 This pack is not available yet."
			return
		end
		MarketplaceService:PromptProductPurchase(player, pack.ProductId)
	end)
end
local y = cardY + 190

local odds = Instance.new("TextLabel")
odds.Size = UDim2.new(1, -20, 0, 160)
odds.Position = UDim2.fromOffset(10, y + 8)
odds.BackgroundTransparency = 1
odds.Font = Enum.Font.Gotham
odds.TextSize = 13
odds.TextWrapped = true
odds.TextXAlignment = Enum.TextXAlignment.Left
odds.TextYAlignment = Enum.TextYAlignment.Top
odds.TextColor3 = Color3.fromRGB(200, 200, 210)
odds.Parent = shop

local lines = { "🎲 Your odds on every search:", "🆓 Free: " .. oddsText(Settings.Finding.BaseLuck) }
for _, pack in Settings.SearchPacks do
	table.insert(lines, "🛍️ " .. pack.Name .. ": " .. oddsText(pack.Luck))
end
odds.Text = table.concat(lines, "\n\n")

close.Activated:Connect(function()
	shop.Visible = false
end)

-- Opens by itself when you try to search with none left.
itemFound.OnClientEvent:Connect(function(item)
	if item.NoSearches then
		shop.Visible = true
		status.Text = "🕛 Free searches come back every day. Or grab a pack:"
	end
end)

dataUpdate.OnClientEvent:Connect(function(data)
	label.Text = string.format("🔍 Free: %d/%d   🎁 Bonus: %d", data.FreeSearches, Settings.Finding.FreeSearchesPerDay, data.BonusSearches)
end)
