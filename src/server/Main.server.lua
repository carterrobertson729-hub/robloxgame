--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Sync = require(ServerScriptService.Server.Sync)
local FindService = require(ServerScriptService.Server.FindService)
local WashService = require(ServerScriptService.Server.WashService)

PlayerData.init()
Sync.init()
FindService.init()
WashService.init()
print("Thrift Store Tycoon server started")
