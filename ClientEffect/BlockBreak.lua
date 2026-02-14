local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local debris = game:GetService("Debris")


local effects = assets.Effects

return function(argumentData: any)
	local target: Model = argumentData.Target
	local weaponUsed: string = argumentData.weaponUsed
	local duration: number = argumentData.Duration or 1.4
	
	if target and weaponUsed then
		
		local clone = effects.Dizzyeffect:Clone()
		local weld = Instance.new("Weld")
		weld.Part0 = target.Head
		weld.Part1 = clone
		
		weld.Parent = clone
		clone.Parent = target
		
		task.delay(duration, function()

			for _, eff in clone:GetDescendants() do
				if eff:IsA("ParticleEmitter") then
					eff.Enabled = false
					
				end
			end
			
			debris:AddItem(clone, 1.4)
		end)
	end
	
end
