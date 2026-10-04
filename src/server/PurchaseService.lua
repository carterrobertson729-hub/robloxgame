--!strict
-- Grants search packs and cash packs bought with Robux. Each purchase is granted once (receipts are saved)
-- and only reported as done after the player's data is saved.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Settings = require(ReplicatedStorage.Shared.Settings)
local Format = require(ReplicatedStorage.Shared.Format)
local PlayerData = require(ServerScriptService.Server.PlayerData)
local Searches = require(ServerScriptService.Server.Searches)
local Sync = require(ServerScriptService.Server.Sync)
local Net = require(ServerScriptService.Server.Net)

local PurchaseService = {}

-- Finds the pack for a Robux product. Returns the kind ("search" or "cash") and the pack.
local function packForProduct(productId: number): (string?, any)
	if productId == 0 then
		return nil, nil
	end
	for _, pack in Settings.SearchPacks do
		if pack.ProductId == productId then
			return "search", pack
		end
	end
	for _, pack in Settings.CashPacks do
		if pack.ProductId == productId then
			return "cash", pack
		end
	end
	return nil, nil
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

	local kind, pack = packForProduct(info.ProductId)
	if not pack then
		warn("Purchase for unknown product", info.ProductId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Grant, then save. If the save fails, undo the grant and ask Roblox to try again later.
	local entry = nil
	if kind == "search" then
		entry = Searches.grant(data, pack.Searches, pack.Luck)
	else
		data.Cash += pack.Cash
	end
	data.Receipts[receiptId] = true

	if not PlayerData.save(player) then
		if kind == "search" then
			Searches.revoke(data, entry)
		else
			data.Cash -= pack.Cash
		end
		data.Receipts[receiptId] = nil
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if kind == "search" then
		Net.notice(player, "+" .. pack.Searches .. " searches (luck +" .. math.floor(pack.Luck * 100) .. "%)", "good")
	else
		Net.notice(player, "+" .. Format.cash(pack.Cash) .. " 💵", "good")
	end
	Sync.push(player)
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function PurchaseService.init()
	MarketplaceService.ProcessReceipt = processReceipt
end

return PurchaseService
