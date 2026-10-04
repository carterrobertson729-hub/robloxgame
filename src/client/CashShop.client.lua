--!strict
-- Tap your cash to buy more with Robux. Three packs side by side.
-- Display only: the server grants purchases after Roblox confirms them.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Format = require(ReplicatedStorage.Shared.Format)
local Settings = require(ReplicatedStorage.Shared.Settings)

local FONT = Enum.Font.FredokaOne
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "CashShop"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = playerGui

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

local shop = Instance.new("Frame")
shop.Name = "Shop"
shop.AnchorPoint = Vector2.new(0.5, 0.5)
shop.Position = UDim2.fromScale(0.5, 0.5)
shop.Size = UDim2.fromOffset(540, 330)
shop.BackgroundColor3 = Color3.fromRGB(28, 30, 44)
shop.BorderSizePixel = 0
shop.Visible = false
shop.Parent = gui
round(shop, 16)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 200, 120)
stroke.Thickness = 3
stroke.Parent = shop

local title = makeLabel(shop, "💰 Get more cash", 26, Color3.new(1, 1, 1))
title.Size = UDim2.new(1, -60, 0, 40)
title.Position = UDim2.fromOffset(10, 4)

local status = makeLabel(shop, "Spend it on workers, upgrades and more!", 16, Color3.fromRGB(210, 210, 225))
status.Size = UDim2.new(1, -20, 0, 24)
status.Position = UDim2.fromOffset(10, 44)

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
close.Activated:Connect(function()
	shop.Visible = false
end)

local CARD_W, CARD_GAP = 166, 11
for i, pack in Settings.CashPacks do
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(CARD_W, 230)
	card.Position = UDim2.fromOffset(10 + (i - 1) * (CARD_W + CARD_GAP), 80)
	card.BackgroundColor3 = Color3.fromRGB(42, 62, 56)
	card.BorderSizePixel = 0
	card.Parent = shop
	round(card, 14)

	local name = makeLabel(card, pack.Name, 16, Color3.fromRGB(190, 230, 205))
	name.Size = UDim2.new(1, -12, 0, 24)
	name.Position = UDim2.fromOffset(6, 6)

	-- Your own picture if ImageId is set, otherwise the emoji.
	if pack.ImageId ~= "" then
		local img = Instance.new("ImageLabel")
		img.Size = UDim2.fromOffset(60, 60)
		img.Position = UDim2.new(0.5, -30, 0, 34)
		img.BackgroundTransparency = 1
		img.Image = "rbxassetid://" .. pack.ImageId
		img.Parent = card
	else
		local icon = makeLabel(card, pack.Emoji, 44, Color3.new(1, 1, 1))
		icon.Size = UDim2.fromOffset(60, 60)
		icon.Position = UDim2.new(0.5, -30, 0, 34)
		icon.TextScaled = true
	end

	local amount = makeLabel(card, Format.cash(pack.Cash), 28, Color3.fromRGB(120, 240, 150))
	amount.Size = UDim2.new(1, -12, 0, 40)
	amount.Position = UDim2.fromOffset(6, 104)

	local buy = Instance.new("TextButton")
	buy.Size = UDim2.new(1, -20, 0, 36)
	buy.Position = UDim2.new(0, 10, 1, -48)
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

-- Tap the cash box (in the Hud) to open or close this shop.
local hud = playerGui:WaitForChild("Hud")
local cashButton = hud:WaitForChild("CashButton") :: TextButton
cashButton.Activated:Connect(function()
	if shop.Visible then
		shop.Visible = false
		return
	end
	local searchGui = playerGui:FindFirstChild("SearchShop")
	if searchGui and searchGui:FindFirstChild("Shop") then
		searchGui.Shop.Visible = false
	end
	status.Text = "Spend it on workers, upgrades and more!"
	shop.Visible = true
end)
