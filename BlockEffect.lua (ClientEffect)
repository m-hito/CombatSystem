local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local debris = game:GetService("Debris")


local effects = assets.Effects

return function(argumentData: any)
	local target: Model = argumentData.Target
	local weaponUsed: string = argumentData.weaponUsed
	
	if target and weaponUsed then
		local rootPart = target:FindFirstChild("HumanoidRootPart")
		
		if rootPart then
			local Clone = effects.CoreEffect.Blocked:Clone()
			Clone.Parent = rootPart
			
			for _, v in Clone:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					local emitDelay = v:GetAttribute("EmitDelay") or 0  -- Default 0 if nil
					local emitCount = v:GetAttribute("EmitCount") or 20  -- Default 20 if nil
					
					
					if emitDelay > 0 then
						task.delay(emitDelay, function()
							v:Emit(emitCount)
						end)
						
					else
						v:Emit(emitCount)
	
					end

				end
			end
			
			debris:AddItem(Clone, .5)
			
		end
		
	end
	
end
