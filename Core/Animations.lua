local module = {}
module.connections = {}
module.LoadedAnimations = {}

-- module.LoadedAnimations["Fist.Swings.L1"]:Play()

function module:LoadAnimations(animator: Animator, folder: Folder)
	--print("Loading from folder:", folder.Name, folder.ClassName)
	--print("RECEIVED FOLDER:", folder, folder and folder.Name)  -- ADD THIS
	if not folder then warn("FOLDER NIL") return end

	for _, Animation in folder:GetDescendants() do
		
		if Animation:IsA("Animation") then
			local fullName = Animation:GetFullName()
			fullName = fullName:split("ReplicatedStorage.Assets.Animations.")[2]
			module.LoadedAnimations[fullName] = animator:LoadAnimation(Animation)
			
		end
	
	end
	--print(module.LoadedAnimations)
end

return module
