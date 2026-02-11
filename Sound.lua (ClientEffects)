local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local debris = game:GetService("Debris")
local assets = replicatedStorage.Assets

local cached = {}

for _, sound in assets.Sounds:GetDescendants() do
	
	if sound:IsA("Sound") then
		local fullName = sound:GetFullName()

		fullName = fullName:split("ReplicatedStorage.Assets.Sounds.")[2]
		cached[fullName] = sound 

	end
end

local effects = assets.Effects

return function(argumentData: any)
	local soundName: string = argumentData.SoundName
	
	local Parent: BasePart = argumentData.Parent
	--print(soundName)
	if not soundName or not Parent then return end
	
	
	if soundName and Parent then
		local foundSound = cached[soundName]
		
		if foundSound then
			local clone = foundSound:Clone()
			clone.Parent = Parent
			clone:Play()
			
			task.delay(foundSound.TimeLength, function()
				clone:Destroy()
			end)
			
		end
		
	end
	
end
