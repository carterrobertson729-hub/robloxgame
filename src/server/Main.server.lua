--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Sync = require(ServerScriptService.Server.Sync)
local FindService = require(ServerScriptService.Server.FindService)
local WashService = require(ServerScriptService.Server.WashService)
local PurchaseService = require(ServerScriptService.Server.PurchaseService)

PlayerData.init()
Sync.init()
FindService.init()
WashService.init()
PurchaseService.init()
print("Thrift Store Tycoon server started")
