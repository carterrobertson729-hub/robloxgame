--!strict
-- Cash and the Bag panel (list of everything you are carrying). Display only.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemData = require(ReplicatedStorage.Shared.ItemData)
local Settings = require(ReplicatedStorage.Shared.Settings)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local dataUpdate = remotes:WaitForChild("DataUpdate") :: RemoteEvent
local requestData = remotes:WaitForChild("RequestData") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "Hud"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local function panel(name: string, size: UDim2, pos: UDim2): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = pos
	f.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	f.BackgroundTransparency = 0.1
	f.BorderSizePixel = 0
	f.Parent = gui
	Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
	return f
end

local cashBox = panel("Cash", UDim2.fromOffset(150, 40), UDim2.fromOffset(16, 16))
local cashLabel = Instance.new("TextLabel")
cashLabel.Size = UDim2.fromScale(1, 1)
cashLabel.BackgroundTransparency = 1
cashLabel.Font = Enum.Font.FredokaOne
cashLabel.TextSize = 22
cashLabel.TextColor3 = Color3.fromRGB(110, 230, 130)
cashLabel.Text = "$0"
cashLabel.Parent = cashBox

local bagButton = Instance.new("TextButton")
bagButton.Size = UDim2.fromOffset(150, 40)
bagButton.Position = UDim2.fromOffset(16, 64)
bagButton.BackgroundColor3 = Color3.fromRGB(60, 90, 140)
bagButton.BorderSizePixel = 0
bagButton.Font = Enum.Font.FredokaOne
bagButton.TextSize = 18
bagButton.TextColor3 = Color3.new(1, 1, 1)
bagButton.Text = "Bag 0/" .. Settings.Player.InventoryLimit
bagButton.Parent = gui
Instance.new("UICorner", bagButton).CornerRadius = UDim.new(0, 10)

local bag = panel("Bag", UDim2.fromOffset(380, 360), UDim2.fromOffset(16, 112))
bag.Visible = false
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -16, 1, -16)
list.Position = UDim2.fromOffset(8, 8)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.Parent = bag
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = list

bagButton.Activated:Connect(function()
	bag.Visible = not bag.Visible
end)

local function render(inventory: { any })
	for _, child in list:GetChildren() do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	for i, item in inventory do
		local rarity = ItemData.getRarity(item.Rarity)
		local row = Instance.new("TextLabel")
		row.LayoutOrder = i
		row.Size = UDim2.new(1, -8, 0, 40)
		row.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		row.BorderSizePixel = 0
		row.Font = Enum.Font.FredokaOne
		row.TextSize = 14
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextColor3 = rarity and rarity.Color or Color3.new(1, 1, 1)
		row.Text = string.format(
			"  %s\n  %s, %s, %s - $%d",
			ItemData.displayName(item),
			item.Rarity,
			item.Condition,
			item.Washed and "clean" or "DIRTY",
			item.Value
		)
		row.Parent = list
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
	end
end

dataUpdate.OnClientEvent:Connect(function(data)
	cashLabel.Text = "$" .. data.Cash
	bagButton.Text = "Bag " .. #data.Inventory .. "/" .. Settings.Player.InventoryLimit
	render(data.Inventory)
end)

requestData:FireServer()
