local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = replicatedStorage.Modules

local weaponDataModule = require(modules.WeaponData)

return function(attacker: Model, targetHit: Model, weaponUsed: string, comboSwingNumber: number)
	if not weaponDataModule then return end
	--print("Full weapon data: ", weaponDataModule)

	local foundWeaponData = weaponDataModule:GetWeaponData(weaponUsed)

	if foundWeaponData then
		local targetHumanoid : Humanoid = targetHit:FindFirstChild("Humanoid")
		--print(targetHumanoid)
		if not targetHumanoid then return end

		targetHumanoid:TakeDamage(foundWeaponData.BlockDamage)
		

		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = weaponUsed..".Blocked."..tostring(comboSwingNumber),
			["Parent"] = targetHit.HumanoidRootPart
		})

		replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockEffect", {
			["Target"] = targetHit,
			["weaponUsed"] = weaponUsed
		})
		
		
		--print("[Blocked] damage hitType reached", attacker, targetHit, weaponUsed)
		
	end
	
end
