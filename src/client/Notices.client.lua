--!strict
-- Small messages at the bottom of the screen ("Washing 2 items...").

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local notice = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Notice") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "Notices"
gui.ResetOnSpawn = false
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 1)
label.Position = UDim2.new(0.5, 0, 1, -90)
label.Size = UDim2.fromOffset(380, 40)
label.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
label.BackgroundTransparency = 0.15
label.BorderSizePixel = 0
label.Font = Enum.Font.FredokaOne
label.TextSize = 18
label.TextColor3 = Color3.new(1, 1, 1)
label.Visible = false
label.Parent = gui
Instance.new("UICorner", label).CornerRadius = UDim.new(0, 10)

local colors = {
	info = Color3.new(1, 1, 1),
	good = Color3.fromRGB(110, 230, 130),
	bad = Color3.fromRGB(255, 110, 110),
}

local counter = 0

notice.OnClientEvent:Connect(function(text: string, kind: string)
	counter += 1
	local mine = counter
	label.Text = text
	label.TextColor3 = colors[kind] or colors.info
	label.Visible = true
	task.delay(2.5, function()
		if counter == mine then
			label.Visible = false
		end
	end)
end)
