-- Paste this whole file into the Studio Command Bar (View > Command Bar) and press Enter.
-- Builds Workspace.Store from placeholder blocks. Re-running deletes and rebuilds it.

local old = workspace:FindFirstChild("Store")
if old then
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
local function station(name, kind, size, pos, color)
	local m = Instance.new("Model")
	m.Name = name
	local body = part(m, "Body", size, pos, color)
	m.PrimaryPart = body
	m:SetAttribute("Station", kind)
	m.Parent = stations
end

local rackColor = Color3.fromRGB(110, 80, 60)
for i = 1, 4 do
	station("Rack" .. i, "Rack", Vector3.new(12, 6, 3), Vector3.new(-30 + (i - 1) * 20, 3.5, -35), rackColor)
end
station("Checkout", "Checkout", Vector3.new(10, 4, 4), Vector3.new(25, 2.5, -70), Color3.fromRGB(60, 90, 140))
station("Washer1", "Washer", Vector3.new(6, 6, 6), Vector3.new(-30, 3.5, -105), Color3.fromRGB(220, 220, 230))
station("Washer2", "Washer", Vector3.new(6, 6, 6), Vector3.new(-20, 3.5, -105), Color3.fromRGB(220, 220, 230))
station("ListingDesk", "Listing", Vector3.new(10, 4, 5), Vector3.new(5, 2.5, -110), Color3.fromRGB(80, 80, 90))
station("PackingTable", "Packing", Vector3.new(12, 4, 6), Vector3.new(28, 2.5, -105), Color3.fromRGB(190, 160, 110))

store.Parent = workspace
print("Store built: ", #building:GetChildren(), "building parts,", #stations:GetChildren(), "stations")
