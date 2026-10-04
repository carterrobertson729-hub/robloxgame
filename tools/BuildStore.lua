-- Paste this whole file into the Studio Command Bar (View > Command Bar) and press Enter.
-- Builds Workspace.Store from placeholder blocks. Re-running deletes and rebuilds it.

-- Remember where you put the Donation Bin so re-running this script does not move it back.
local savedBinCFrame = nil
local old = workspace:FindFirstChild("Store")
if old then
	local oldBin = old:FindFirstChild("Stations") and old.Stations:FindFirstChild("DonationBin")
	if oldBin and oldBin.PrimaryPart then
		savedBinCFrame = oldBin.PrimaryPart.CFrame
	end
	old:Destroy()
end

local store = Instance.new("Model")
store.Name = "Store"
local building = Instance.new("Model")
building.Name = "Building"
building.Parent = store
local stations = Instance.new("Model")
stations.Name = "Stations"
stations.Parent = store

local function part(parent, name, size, pos, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Anchored = true
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

-- Layout: X from -40 to 40, Z from -20 (front) to -120 (back), divider at Z = -80.
local WALL_H, WALL_T = 16, 2
local wallColor = Color3.fromRGB(235, 225, 205)
local floorTop = 0.5

part(building, "Floor", Vector3.new(80, 1, 100), Vector3.new(0, 0, -70), Color3.fromRGB(150, 120, 90), Enum.Material.WoodPlanks)

local y = floorTop + WALL_H / 2
-- Back wall
part(building, "BackWall", Vector3.new(80, WALL_H, WALL_T), Vector3.new(0, y, -120), wallColor)
-- Side walls
part(building, "LeftWall", Vector3.new(WALL_T, WALL_H, 100), Vector3.new(-40, y, -70), wallColor)
part(building, "RightWall", Vector3.new(WALL_T, WALL_H, 100), Vector3.new(40, y, -70), wallColor)
-- Front wall with a 12-wide door gap in the middle
part(building, "FrontWallL", Vector3.new(34, WALL_H, WALL_T), Vector3.new(-23, y, -20), wallColor)
part(building, "FrontWallR", Vector3.new(34, WALL_H, WALL_T), Vector3.new(23, y, -20), wallColor)
part(building, "FrontWallTop", Vector3.new(12, WALL_H - 11, WALL_T), Vector3.new(0, floorTop + 11 + (WALL_H - 11) / 2, -20), wallColor)
-- Divider wall at Z = -80 with a 10-wide door
part(building, "DividerL", Vector3.new(35, WALL_H, WALL_T), Vector3.new(-22.5, y, -80), wallColor)
part(building, "DividerR", Vector3.new(35, WALL_H, WALL_T), Vector3.new(22.5, y, -80), wallColor)
part(building, "DividerTop", Vector3.new(10, WALL_H - 11, WALL_T), Vector3.new(0, floorTop + 11 + (WALL_H - 11) / 2, -80), wallColor)

-- Sign (placeholder name)
local sign = part(building, "Sign", Vector3.new(30, 5, 1), Vector3.new(0, 20, -19), Color3.fromRGB(40, 40, 50))
local gui = Instance.new("SurfaceGui")
gui.Face = Enum.NormalId.Front
gui.Parent = sign
local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Text = "MY THRIFT STORE"
label.TextScaled = true
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.Parent = gui

-- Stations: a Model with a PrimaryPart and a "Station" attribute so scripts can find them.
local function station(name, kind, size, pos, color, decorate)
	local m = Instance.new("Model")
	m.Name = name
	local body = part(m, "Body", size, pos, color)
	m.PrimaryPart = body
	m:SetAttribute("Station", kind)
	if decorate then
		decorate(m, body)
	end
	m.Parent = stations
end

-- A round part facing the front (+Z). Roblox cylinders point along X, so turn them 90 degrees.
local function disc(parent, name, diameter, thickness, pos, color, material)
	local p = part(parent, name, Vector3.new(thickness, diameter, diameter), pos, color, material)
	p.Shape = Enum.PartType.Cylinder
	p.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(90), 0)
	return p
end

-- Front-loading washing machine: door ring, glass window with clothes inside, control panel.
local function washerDetails(m, body)
	local pos = body.Position
	local frontZ = pos.Z + body.Size.Z / 2
	local doorY = pos.Y - 0.3
	disc(m, "DoorRing", 4.4, 0.4, Vector3.new(pos.X, doorY, frontZ + 0.15), Color3.fromRGB(150, 150, 160), Enum.Material.Metal)
	disc(m, "Drum", 3.6, 0.3, Vector3.new(pos.X, doorY, frontZ + 0.3), Color3.fromRGB(40, 40, 50))
	disc(m, "Clothes", 2.2, 0.2, Vector3.new(pos.X, doorY - 0.6, frontZ + 0.42), Color3.fromRGB(220, 90, 120))
	local glass = disc(m, "Glass", 3.6, 0.15, Vector3.new(pos.X, doorY, frontZ + 0.55), Color3.fromRGB(150, 200, 235), Enum.Material.Glass)
	glass.Transparency = 0.5
	-- Control panel across the top
	part(m, "Panel", Vector3.new(5.4, 1.1, 0.3), Vector3.new(pos.X, pos.Y + 2.4, frontZ + 0.1), Color3.fromRGB(60, 60, 70))
	disc(m, "Knob", 0.9, 0.3, Vector3.new(pos.X - 1.7, pos.Y + 2.4, frontZ + 0.4), Color3.fromRGB(200, 200, 210), Enum.Material.Metal)
	part(m, "Display", Vector3.new(1.4, 0.5, 0.2), Vector3.new(pos.X + 0.4, pos.Y + 2.4, frontZ + 0.3), Color3.fromRGB(80, 220, 140), Enum.Material.Neon)
	disc(m, "StartButton", 0.7, 0.3, Vector3.new(pos.X + 1.9, pos.Y + 2.4, frontZ + 0.4), Color3.fromRGB(230, 70, 70))
end

local rackColor = Color3.fromRGB(110, 80, 60)
for i = 1, 4 do
	station("Rack" .. i, "Rack", Vector3.new(12, 6, 3), Vector3.new(-30 + (i - 1) * 20, 3.5, -35), rackColor)
end
station("Checkout", "Checkout", Vector3.new(10, 4, 4), Vector3.new(25, 2.5, -70), Color3.fromRGB(60, 90, 140))
station("Washer1", "Washer", Vector3.new(6, 6, 6), Vector3.new(-30, 3.5, -105), Color3.fromRGB(235, 235, 240), washerDetails)
station("Washer2", "Washer", Vector3.new(6, 6, 6), Vector3.new(-20, 3.5, -105), Color3.fromRGB(235, 235, 240), washerDetails)
station("ListingDesk", "Listing", Vector3.new(10, 4, 5), Vector3.new(5, 2.5, -110), Color3.fromRGB(80, 80, 90))
station("PackingTable", "Packing", Vector3.new(12, 4, 6), Vector3.new(28, 2.5, -105), Color3.fromRGB(190, 160, 110))

-- Sourcing spot outside the front door (the front wall is at Z = -20, spawn is on the +Z side).
local BIN_SIZE = Vector3.new(4, 3.5, 3)
local BIN_GROUND_Y = BIN_SIZE.Y / 2 -- the baseplate top is at Y = 0
station("DonationBin", "Sourcing", BIN_SIZE, Vector3.new(0, BIN_GROUND_Y, 10), Color3.fromRGB(40, 120, 70))
if savedBinCFrame then
	-- Keep where you put it (and which way it faces), but sit it on the ground at the new size.
	local at = savedBinCFrame.Position
	local turn = savedBinCFrame - at
	stations.DonationBin:PivotTo(CFrame.new(at.X, BIN_GROUND_Y, at.Z) * turn)
end

store.Parent = workspace
print("Store built: ", #building:GetChildren(), "building parts,", #stations:GetChildren(), "stations (expect 10)")
