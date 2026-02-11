local character = script.Parent.Parent
local replicatedStorage = game:GetService("ReplicatedStorage")
--local serverScriptService = game:GetService("ServerScriptService")
--local stateServiceInstance = serverScriptService.StateService

--local stateService = require(stateServiceInstance)
local pickedUpTool = replicatedStorage.Remotes.PickupTool

-- WAIT for tool to exist in backpack (it's created server-side)
local tool = character:WaitForChild("Part", math.huge)  -- ← Wait for it!

if not tool then
	print("No tool found")
	return
end

pickedUpTool.OnClientEvent:Connect(function()
	print("server gave "..character.Name.." a tool")
end)

tool.Equipped:Connect(function()
	print("tool equipped: "..tool.Name)
	pickedUpTool:FireServer(tool, true)
end)

tool.Unequipped:Connect(function()
	print("tool unequipped: "..tool.Name)
	pickedUpTool:FireServer(tool, false)
end)
