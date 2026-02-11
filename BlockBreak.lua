local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = replicatedStorage.Modules

local assets = replicatedStorage.Assets
local stateService = require(modules.StateService)
local weaponDataModule = require(modules.WeaponData)

return function(attacker: Model, targetHit: Model, weaponUsed: string, comboSwingNumber)
	if not weaponDataModule then return end
	--print("Full weapon data: ", weaponDataModule)
	local foundWeaponData = weaponDataModule:GetWeaponData(weaponUsed)
	
	if foundWeaponData then
		local targetHumanoid : Humanoid = targetHit:FindFirstChild("Humanoid")
		if not targetHumanoid then return end
		
		stateService.addState(targetHit, "Stunned", 1.4)
		stateService.addState(targetHit, "BlockBroken", 1.4)
		

		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = "BlockBreak",
			["Parent"] = targetHit.HumanoidRootPart
		})

		replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockBreak", {
			["Target"] = targetHit,
			["weaponUsed"] = weaponUsed
		})


		
		if targetHit then
			local animationModule = require(targetHit.Core.Animations)
			animationModule.LoadedAnimations["Character.BlockBreak"]:Play()
			
		else
			local animator: Animator = targetHit.Humanoid.Animator
			if animator then
				local playAnim = animator:LoadAnimation(assets.Animations.Character.BlockBreak)
				
				playAnim:Play()
			end
			

			
		end
		
		--print("[BlockBreak] damage hitType reached", attacker, targetHit, weaponUsed)
		
	end
	
end
