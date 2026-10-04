--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local PlayerData = require(ServerScriptService.Server.PlayerData)
local FindService = require(ServerScriptService.Server.FindService)

PlayerData.init()
FindService.init()
print("Thrift Store Tycoon server started")
