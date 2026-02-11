local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

local modules = replicatedStorage.Modules
local attack = replicatedStorage.Remotes:FindFirstChild("Attack")
local block = replicatedStorage.Remotes:FindFirstChild("Block")

local debris = game:GetService("Debris")
local assets = replicatedStorage.Assets

local weaponData = require(replicatedStorage.Modules.WeaponData)
local stateService = require(modules.StateService)

--local Fist = require(game.ServerScriptService.Systems.Modules.Fist) -- we will use catched module to access all modules
local cachedModule = {}
--print(script.Parent.Weapons:GetChildren())

for _, module in pairs(script.Parent.Weapons:GetChildren()) do
	--print("Found:", module.Name, module.ClassName, _)  -- Shows ALL children
	if module:IsA("ModuleScript") then
		local success, result = pcall(function()
			return require(module)
		end)
		if success then
			cachedModule[module.Name] = result
			--print("✅ CACHED:", module.Name)
		else
			--warn("❌ ERROR in", module.Name, ":", result)
		end
		
	end
	
end

local function handleCharacter(character: Model)
	local statusFolder = character:WaitForChild("Status", math.huge)
	local humanoid = character:WaitForChild("Humanoid", math.huge)
	
	task.spawn(function()
		local core = character:WaitForChild("Core", math.huge)
		local animationModule = require(core.Animations)
		animationModule:LoadAnimations(humanoid.Animator, assets.Animations.Character)
		
		--print(animationModule.LoadedAnimations)
	end)
	
end


players.PlayerAdded:Connect(function(plr)
	if plr.Character then handleCharacter(plr.Character) end
	
	plr.CharacterAdded:Connect(handleCharacter)
	
end)

block.OnServerEvent:Connect(function(plr: Player, Boolean: BoolValue)
	local char = plr.Character
	if char then -- detect if character exist or the client will keep firing the event causing server to lag
		local humanoid: Humanoid = char:FindFirstChild("Humanoid")
		if humanoid then
			local foundTool = char:FindFirstChildWhichIsA("Tool")

			local coreFolder = char:FindFirstChild("Core")
			if not coreFolder then return end

			local AnimationModule = coreFolder:FindFirstChild("Animations")

			local loadedAnimation = require(AnimationModule).LoadedAnimations

			if foundTool then

				if not foundTool:GetAttribute("ToolLoaded") then return end

				if Boolean == true then -- start blocking
					
					if stateService.checkState(char, "Stunned", "Attacking", "Blocking", "NoBlock", "NoJump") then -- check if player is in this state 
						return -- if yes then do nothing he cant block during this time
					end
					
					stateService.addState(char, "Blocking", nil, {
						["weaponName"] = foundTool.Name
						}
					)

					--print("adding state..blocking to "..foundTool.Name)
					-- playing the block animation
				
				
					loadedAnimation[foundTool.Name..".Block.Idle"]:Play()
				elseif Boolean == false then -- stop blocking

					-- stop blocking
					local blockingInstance = char.Status:FindFirstChild("Blocking")
					
					if blockingInstance then

						local weaponInstance = blockingInstance:GetAttribute("weaponName")

						local animName = weaponInstance..".Block.Idle"
						--print(animName)
						
						if not weaponInstance then return end
						
						if weaponInstance then 
							loadedAnimation[weaponInstance..".Block.Idle"]:Stop(.1)
							
						end
						blockingInstance:Destroy()
						stateService.addState(char, "NoBlock", .4)
					end
					
					--stateService.removeState(char, "Blocking")
					
				end
	
			end
		end
	end
end)

attack.OnServerEvent:Connect(function(plr: Player)
	--print("inside attack")
	local char = plr.Character
	if char then -- detect if character exist or the client will keep firing the event causing server to lag
		local humanoid: Humanoid = char:FindFirstChild("Humanoid")
		if humanoid then
			local foundTool = char:FindFirstChildWhichIsA("Tool")
			if not foundTool then return end
			
			--if not foundTool:GetAttribute("Registered")  then
			--	warn("This tool is not registered: "..foundTool.Name)
			--	return
			--end
			
			if foundTool then
			
				if not foundTool:GetAttribute("ToolLoaded") then return end

				local FoundModule = cachedModule[foundTool.Name]

				if FoundModule then
				
					FoundModule:Attack(char, foundTool)

				end
			end
			
		end
		
	end
	
end)

