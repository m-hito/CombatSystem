local replicatedStorage = game:GetService("ReplicatedStorage")

local modules = replicatedStorage.Modules
local attack = replicatedStorage.Remotes:FindFirstChild("Attack")
local debris = game:GetService("Debris")
local assets = replicatedStorage.Assets
--local test = game.Workspace:WaitForChild("ShopNpc"):WaitForChild("Humanoid")
local stateService = require(modules.StateService)

local tweenService = game:GetService("TweenService")
local Modules = replicatedStorage.Modules
local weaponData = require(Modules.WeaponData):GetWeaponData(script.Name)
local dmgGui = assets.DmgGui

--print(weaponData["damage"])

local weaponType = {
	hitTypes = {}
}

-- Requiring hittypes

for _, module in script.Parent.Parent.HitTypes:GetChildren() do

	if module:IsA("ModuleScript") then
 		weaponType.hitTypes[module.Name] = require(module)
		--print(weaponType.hitTypes)
	end

end

weaponType.__index = weaponType

function weaponType.new(char)
	local self = {}
	return self
end

function weaponType:GiveDmg()
	return weaponData["damage"]
end

function weaponType:GiveDmgGui(enemyHumanoid, GiveDmg)
	local dmgGui = dmgGui:Clone()
	dmgGui.Parent = enemyHumanoid.Parent
	dmgGui.Name = "DmgLabel"..enemyHumanoid.Parent.Name
	local dmgLabel = dmgGui.DmgLabel
	
	dmgLabel.Text = GiveDmg
	
	
	local tweenInfo = TweenInfo.new(1.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	local goal = {}

	goal.Position = UDim2.new(-0.3, 0, -0.4, 0) 
	goal.Size = UDim2.new(2.4, 0, 1.3, 0)
	local Tween = tweenService:Create(dmgLabel, tweenInfo, goal)
	Tween:Play()
	
	return dmgGui
end



function weaponType:DestroyDmgGui(EnemyDmgLabel)
	if EnemyDmgLabel then EnemyDmgLabel:Destroy() end
end

function weaponType:Attack(char, tool : Tool)
	--print("Atack")
	if stateService.checkState(char, "Attacking", "Blocking", "Stunned") then
		return -- if already attackin/ blocking do nothing 
	end
	
	--if tool.Name ~= script.Name then return end 

	local configuration = tool:FindFirstChild("Configuration")
	if not configuration then return end
	
	local core = char:WaitForChild("Core")
	local animationModule = require(core.Animations)
	
	-- swing system/ combo system logic
	local SwingNumber = configuration.SwingNumber
	local LastCombo = configuration.LastCombo
	local LastSwing = configuration.LastSwing
	
	if os.clock() - LastSwing.Value >= weaponData.ComboResetTime  then -- first check which combo animation to play
		SwingNumber.Value = 0
	end
	
	if (os.clock() - LastCombo.Value) < weaponData.ComboCoolDown then -- then check interval between complete combos 
		return
	end 
	
	-- cleanup previous connection like { [weaponType.Swings.L2] = nil} setting it to nil for next connection and cleanup
	for connectionName, connection in pairs(animationModule.connections) do -- connectionName is index of the table inside animation.connections
		
		if string.find(connectionName, "Fist.Swings") then -- {}
			animationModule.connections[connectionName]:Disconnect() -- disconnect the previous combo state from the markerreachedSignal 
		end
	end
	
	local trueSwingNumber = nil
	SwingNumber.Value += 1 
	trueSwingNumber = SwingNumber.Value
	
	if SwingNumber.Value >= 5 then -- check if combo completed 
		LastCombo.Value = os.clock() -- record time for next combo 
		trueSwingNumber = 5
		SwingNumber.Value = 0 -- reset for next combo 
	end
	
	LastSwing.Value = os.clock()
	local swingName = "Fist.Swings.L"..tostring(trueSwingNumber)
	
	local animToPlay: AnimationTrack = animationModule.LoadedAnimations[swingName]
	
	stateService.addState(char, "Attacking", animToPlay.Length) -- replace previous folder logic/ we can also wrap it in variable (return value use case)
	stateService.addState(char, "NoBlock", animToPlay.Length+.3)
	stateService.addState(char, "NoJump", animToPlay.Length+.5)
	stateService.addState(char, "NoSprint", animToPlay.Length+.5)
	
	animToPlay:Play()
	
	--hitbox detection only create hitbox when anim reach the hitbox event inside the animation we added
	animationModule.connections[swingName] = animToPlay:GetMarkerReachedSignal("Hit"):Once(function()  -- add the current input inside connection 
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = "Fist.Swings."..tostring(trueSwingNumber),
			["Parent"] = char.HumanoidRootPart
		})
		
		--print("Hit called")
		animationModule.connections[swingName] = nil
		
		-- hitbox logic
		local hitbox = assets.HitboxTemplate:Clone()
		hitbox.Parent = workspace.World.HitBoxes
		hitbox.Name = "Hitbox"

		local weld = Instance.new("Weld")
		weld.C0 = CFrame.new(0, 0, -3) -- make it cframe infront of player
		weld.Part0 = char.HumanoidRootPart
		weld.Part1 = hitbox
		weld.Parent = hitbox

		task.spawn(function()
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {char, workspace.World.HitBoxes}

			local damage = self:GiveDmg()
			local alreadyHit = {}

			while hitbox.Parent do
				local hitParts = workspace:GetPartBoundsInBox( -- get all parts that overlap it
					hitbox.CFrame, 
					hitbox.Size,
					params
				)

				for _, Enemy in ipairs(hitParts) do
					local hitPart = Enemy.Parent
					if hitPart and hitPart:FindFirstChild("Humanoid") then
						local enemyHumanoid = hitPart:FindFirstChild("Humanoid")
						
						--if alreadyHit[Enemy.Parent] then return end  -- WRONG: exits function -- skip whole attack function 
						if not alreadyHit[hitPart] and enemyHumanoid.Health > 0 then 
							
							-----------------------
							local isBlocking = stateService.checkState(hitPart, "Blocking")
							
							-- HitType logic
							
							if isBlocking then

								if trueSwingNumber >= 5 then
									-- Blockbreak
									weaponType.hitTypes["BlockBreak"](char, hitPart, tool.Name, trueSwingNumber)
									
								else
									-- Do blocked hittype 
									weaponType.hitTypes["Blocked"](char, hitPart, tool.Name)
									
								end
							else -- Default hit
								weaponType.hitTypes["Default"](char, hitPart, tool.Name, trueSwingNumber)
								
							end

							-------------------------------

							local dmgGui = self:GiveDmgGui(enemyHumanoid, damage)
 
							task.spawn(function()
								task.wait(1)
								self:DestroyDmgGui(dmgGui) 
							end)

							--print("Hit "..Enemy.Parent.Name.." Has "..enemyHumanoid.Health.." Health")
							alreadyHit[Enemy.Parent] = true

						end

					end

				end

				task.wait(0.1)
			end

		end)

		debris:AddItem(hitbox, .35)

	end)
	
end

return weaponType

