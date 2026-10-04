--!strict
-- Grants search packs bought with Robux. Each purchase is granted once (receipts are saved)
-- and only reported as done after the player's data is saved.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Settings = require(ReplicatedStorage.Shared.Settings)
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Searches = require(ServerScriptService.Server.Searches)
local Sync = require(ServerScriptService.Server.Sync)
local Net = require(ServerScriptService.Server.Net)

local PurchaseService = {}

local function packForProduct(productId: number): any
	if productId == 0 then
		return nil
	end
	for _, pack in Settings.SearchPacks do
		if pack.ProductId == productId then
			return pack
		end
	end
	return nil
end

local function processReceipt(info: any)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = PlayerData.get(player)
	if not data or PlayerData.isTemporary(player) then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local receiptId = tostring(info.PurchaseId)
	if data.Receipts[receiptId] then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local pack = packForProduct(info.ProductId)
	if not pack then
		warn("Purchase for unknown product", info.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local entry = Searches.grant(data, pack.Searches, pack.Luck)
	data.Receipts[receiptId] = true
	if not PlayerData.save(player) then
		Searches.revoke(data, entry)
		data.Receipts[receiptId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	Net.notice(player, "+" .. pack.Searches .. " searches (luck +" .. math.floor(pack.Luck * 100) .. "%)", "good")
	Sync.push(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function PurchaseService.init()
	MarketplaceService.ProcessReceipt = processReceipt
end

return PurchaseService
