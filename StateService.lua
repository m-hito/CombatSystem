local runService = game:GetService("RunService")

local StateService = {}

-- ... means arguments (chracter, "Stunned", "Blocking", etc)

function StateService.checkState(character, ...)
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then return end

	local statesToCheck = {...} -- access the unknown arguments
	
	for _, stateName in pairs(statesToCheck) do
		if statusFolder:FindFirstChild(stateName) then
			return true -- loop through all state in folder if found then only return true 
		end
	end
	return false -- loop through all state in folder if not found then only return false
end

function StateService.removeState(character, stateName: string)
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then return end
	
	for _, state in pairs(statusFolder:GetChildren()) do -- loop through all states in status folder 
		if state.Name == stateName then --  if found the folder remove it 
			state:Destroy()
		end
	end
	
end

function StateService.addState(character, stateName: string, duration: number, attributes: any)
	local statusFolder = character:FindFirstChild("Status")
	if not statusFolder then 
		if runService:IsServer() then
			local StatusFolder = Instance.new("Folder")
			StatusFolder.Parent = character
			StatusFolder.Name = "Status"
		else 
			return
		end

	end
	
	if character and stateName then
		local newState = Instance.new("BoolValue")
		newState.Name = stateName
		
		if attributes then
			for name, value in attributes  do
				newState:SetAttribute(name, value)
			end
		end
		newState.Parent = statusFolder
		
		if duration then
			task.delay(duration, function()
				newState:Destroy()
			end)
		end
		
		return newState -- if any other script need newstate return it 
	end
	
	return nil -- cleanup
end

return StateService
