--!strict
-- Shows what the player just found. Display only: the server decides the item.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ItemData = require(ReplicatedStorage.Shared.ItemData)
local itemFound = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemFound") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "FindReveal"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.new(0.5, 0, 0, -140)
card.Size = UDim2.fromOffset(320, 110)
card.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
card.BorderSizePixel = 0
card.Parent = gui
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = card

local function makeLabel(y: number, h: number, font: Enum.Font): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = UDim2.new(0, 10, 0, y)
	l.Size = UDim2.new(1, -20, 0, h)
	l.Font = font
	l.TextScaled = true
	l.TextColor3 = Color3.new(1, 1, 1)
	l.Parent = card
	return l
end

local rarityLabel = makeLabel(8, 24, Enum.Font.FredokaOne)
local nameLabel = makeLabel(36, 38, Enum.Font.FredokaOne)
local detailLabel = makeLabel(78, 22, Enum.Font.FredokaOne)

local shownAt = 0

itemFound.OnClientEvent:Connect(function(item)
	if item.NoSearches then
		return -- the search shop pops up instead
	elseif item.Full then
		rarityLabel.Text = "BAG FULL"
		rarityLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		nameLabel.Text = "Wash and sell something first"
		detailLabel.Text = ""
		stroke.Color = Color3.fromRGB(255, 90, 90)
	else
		local rarity = ItemData.getRarity(item.Rarity)
		local color = rarity and rarity.Color or Color3.new(1, 1, 1)
		rarityLabel.Text = (rarity and rarity.Emoji or "") .. " " .. string.upper(item.Rarity)
		rarityLabel.TextColor3 = color
		nameLabel.Text = ItemData.displayName(item)
		detailLabel.Text = item.Condition .. "  -  worth $" .. item.Value
		stroke.Color = color
	end
	card.Position = UDim2.new(0.5, 0, 0, -140)
	TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back), { Position = UDim2.new(0.5, 0, 0, 20) }):Play()
	shownAt = os.clock()
	local mine = shownAt
	task.delay(3, function()
		if shownAt == mine then
			TweenService:Create(card, TweenInfo.new(0.3), { Position = UDim2.new(0.5, 0, 0, -140) }):Play()
		end
	end)
end)
