--!strict
-- Shows how many searches you have. Tap the counter, or try to search with none left, and a popup
-- offers the Robux search packs. The real odds are behind the "View odds" button.
-- Display only: the server grants purchases after Roblox confirms them.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ItemData = require(ReplicatedStorage.Shared.ItemData)
local Settings = require(ReplicatedStorage.Shared.Settings)
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local dataUpdate = remotes:WaitForChild("DataUpdate") :: RemoteEvent
local itemFound = remotes:WaitForChild("ItemFound") :: RemoteEvent

local FONT = Enum.Font.FredokaOne
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SearchShop"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10 -- stays above the other screens
gui.Parent = player:WaitForChild("PlayerGui")

local function round(obj: GuiObject, radius: number)
	Instance.new("UICorner", obj).CornerRadius = UDim.new(0, radius)
end

local function makeLabel(parent: Instance, text: string, size: number, color: Color3): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = FONT
	l.TextSize = size
	l.TextColor3 = color
	l.Text = text
	l.TextWrapped = true
	l.Parent = parent
	return l
end

local SHOP_W = 540

-- Popup
local shop = Instance.new("Frame")
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.Position = UDim2.fromScale(0.5, 0.5)
shop.Size = UDim2.fromOffset(SHOP_W, 420)
shop.BackgroundColor3 = Color3.fromRGB(28, 30, 44)
shop.BorderSizePixel = 0
shop.Visible = false
shop.Parent = gui
round(shop, 16)
local shopStroke = Instance.new("UIStroke")
shopStroke.Color = Color3.fromRGB(90, 140, 230)
shopStroke.Thickness = 3
shopStroke.Parent = shop

local title = makeLabel(shop, "", 26, Color3.new(1, 1, 1))
title.Size = UDim2.new(1, -60, 0, 40)
title.Position = UDim2.fromOffset(10, 4)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.new(1, -40, 0, 8)
close.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
close.BorderSizePixel = 0
close.Font = FONT
close.TextSize = 18
close.TextColor3 = Color3.new(1, 1, 1)
close.Text = "✖"
close.Parent = shop
round(close, 8)

-- Bouncing pictures. A slot with an ImageId shows that picture; otherwise its emoji.
local slotWidth = SHOP_W / #Settings.ShopImages
for i, entry in Settings.ShopImages do
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromOffset(52, 52)
	holder.Position = UDim2.fromOffset((i - 0.5) * slotWidth - 26, 48)
	holder.BackgroundTransparency = 1
	holder.Parent = shop

	if entry.ImageId ~= "" then
		local img = Instance.new("ImageLabel")
		img.Size = UDim2.fromScale(1, 1)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://" .. entry.ImageId
		img.Parent = holder
	else
		local emoji = makeLabel(holder, entry.Emoji, 40, Color3.new(1, 1, 1))
		emoji.Size = UDim2.fromScale(1, 1)
		emoji.TextScaled = true
	end

	local base = holder.Position
	local tween = TweenService:Create(
		holder,
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true),
		{ Position = base - UDim2.fromOffset(0, 12) }
	)
	task.delay(i * 0.15, function()
		tween:Play()
	end)
end

local status = makeLabel(shop, "", 16, Color3.fromRGB(210, 210, 225))
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.fromOffset(10, 108)

-- Three pack cards side by side: picture, searches, luck, then the price.
local CARD_W, CARD_GAP = 166, 11
local CARD_Y, CARD_H = 138, 220
for i, pack in Settings.SearchPacks do
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(CARD_W, CARD_H)
	card.Position = UDim2.fromOffset(10 + (i - 1) * (CARD_W + CARD_GAP), CARD_Y)
	card.BackgroundColor3 = Color3.fromRGB(42, 50, 76)
	card.BorderSizePixel = 0
	card.Parent = shop
	round(card, 14)

	local name = makeLabel(card, pack.Name, 16, Color3.fromRGB(190, 200, 230))
	name.Size = UDim2.new(1, -12, 0, 24)
	name.Position = UDim2.fromOffset(6, 6)

	-- Your own picture if ImageId is set, otherwise the emoji.
	if pack.ImageId ~= "" then
		local img = Instance.new("ImageLabel")
		img.Size = UDim2.fromOffset(52, 52)
		img.Position = UDim2.new(0.5, -26, 0, 32)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://" .. pack.ImageId
		img.Parent = card
	else
		local icon = makeLabel(card, pack.Emoji, 40, Color3.new(1, 1, 1))
		icon.Size = UDim2.fromOffset(52, 52)
		icon.Position = UDim2.new(0.5, -26, 0, 32)
		icon.TextScaled = true
	end

	local searches = makeLabel(card, "🔍 " .. pack.Searches .. " more searches", 20, Color3.new(1, 1, 1))
	searches.Size = UDim2.new(1, -12, 0, 44)
	searches.Position = UDim2.fromOffset(6, 88)

	local luck = makeLabel(card, "🍀 " .. math.floor(pack.Luck * 100 + 0.5) .. "% better luck", 17, Color3.fromRGB(120, 230, 140))
	luck.Size = UDim2.new(1, -12, 0, 26)
	luck.Position = UDim2.fromOffset(6, 136)

	local buy = Instance.new("TextButton")
	buy.Size = UDim2.new(1, -20, 0, 36)
	buy.Position = UDim2.new(0, 10, 1, -44)
	buy.BorderSizePixel = 0
	buy.Font = FONT
	buy.TextSize = 18
	buy.TextColor3 = Color3.new(1, 1, 1)
	buy.Parent = card
	round(buy, 10)
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

-- Odds are one tap away (Roblox requires them to be viewable for paid random items).
local oddsButton = Instance.new("TextButton")
oddsButton.Size = UDim2.fromOffset(110, 26)
oddsButton.Position = UDim2.new(0.5, -55, 0, 380)
oddsButton.BackgroundColor3 = Color3.fromRGB(60, 66, 96)
oddsButton.BorderSizePixel = 0
oddsButton.Font = FONT
oddsButton.TextSize = 14
oddsButton.TextColor3 = Color3.new(1, 1, 1)
oddsButton.Text = "🎲 Odds"
oddsButton.Parent = shop
round(oddsButton, 10)

local oddsPanel = Instance.new("Frame")
oddsPanel.Position = UDim2.fromOffset(0, 108)
oddsPanel.Size = UDim2.new(1, 0, 1, -108)
oddsPanel.BackgroundColor3 = Color3.fromRGB(28, 30, 44)
oddsPanel.BorderSizePixel = 0
oddsPanel.Visible = false
oddsPanel.Parent = shop
round(oddsPanel, 16)

local function oddsText(luck: number): string
	local parts = {}
	for _, entry in ItemData.rarityWeights(luck) do
		table.insert(parts, string.format("%s %s %.1f%%", entry.Rarity.Emoji, entry.Rarity.Name, entry.Chance * 100))
	end
	return table.concat(parts, "   ")
end

local lines = { "🆓 Free: " .. oddsText(Settings.Finding.BaseLuck) }
for _, pack in Settings.SearchPacks do
	table.insert(lines, pack.Emoji .. " " .. pack.Name .. ": " .. oddsText(pack.Luck))
end
local oddsLabel = makeLabel(oddsPanel, table.concat(lines, "\n\n"), 15, Color3.fromRGB(220, 220, 232))
oddsLabel.Size = UDim2.new(1, -24, 1, -60)
oddsLabel.Position = UDim2.fromOffset(12, 6)
oddsLabel.TextXAlignment = Enum.TextXAlignment.Left
oddsLabel.TextYAlignment = Enum.TextYAlignment.Top

local back = Instance.new("TextButton")
back.Size = UDim2.fromOffset(120, 30)
back.Position = UDim2.new(0.5, -60, 1, -40)
back.BackgroundColor3 = Color3.fromRGB(60, 66, 96)
back.BorderSizePixel = 0
back.Font = FONT
back.TextSize = 16
back.TextColor3 = Color3.new(1, 1, 1)
back.Text = "⬅ Back"
back.Parent = oddsPanel
round(back, 10)

oddsButton.Activated:Connect(function()
	oddsPanel.Visible = true
end)
back.Activated:Connect(function()
	oddsPanel.Visible = false
end)

local function openShop(outOfSearches: boolean)
	oddsPanel.Visible = false
	if outOfSearches then
		title.Text = "🔍 Out of free searches!"
		status.Text = "🕛 Free searches come back every day. Or grab a pack:"
	else
		title.Text = "🛍️ Get more searches"
		status.Text = "Packs also give you extra luck 🍀"
	end
	shop.Visible = true
end

close.Activated:Connect(function()
	shop.Visible = false
end)

-- Counter under the cash and bag boxes. Tap it to open the same popup.
local counter = Instance.new("TextButton")
counter.Size = UDim2.fromOffset(230, 44)
counter.Position = UDim2.new(0, 16, 0.5, 28)
counter.BackgroundColor3 = Color3.fromRGB(40, 70, 130)
counter.BorderSizePixel = 0
counter.Font = FONT
counter.TextSize = 18
counter.TextColor3 = Color3.new(1, 1, 1)
counter.Text = "🔍 Free: -"
counter.Parent = gui
round(counter, 12)

counter.Activated:Connect(function()
	if shop.Visible then
		shop.Visible = false
	else
		openShop(false)
	end
end)

-- Opens by itself when you try to search with none left.
itemFound.OnClientEvent:Connect(function(item)
	if item.NoSearches then
		openShop(true)
	end
end)

dataUpdate.OnClientEvent:Connect(function(data)
	counter.Text = string.format("🔍 Free: %d/%d   🎁 Bonus: %d", data.FreeSearches, Settings.Finding.FreeSearchesPerDay, data.BonusSearches)
end)
