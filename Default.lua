local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local modules = replicatedStorage.Modules
local debris = game:GetService("Debris")

local stateService = require(modules.StateService)
local weaponDataModule = require(modules.WeaponData)
local assets = replicatedStorage.Assets
local remotes = replicatedStorage.Remotes

local DropExp = remotes.DropExp

return function(attacker: Model, targetHit: Model, weaponUsed: string, comboSwingNumber: number)
	local attackerHrp = attacker:FindFirstChild("HumanoidRootPart")
	local targetHrp = targetHit:FindFirstChild("HumanoidRootPart")
	
	if not weaponDataModule then return end
	--print("Full weapon data: ", weaponDataModule)
	
	local foundWeaponData = weaponDataModule:GetWeaponData(weaponUsed)
	
	if foundWeaponData then
		local targetHumanoid : Humanoid = targetHit:FindFirstChild("Humanoid")
		if not targetHumanoid then return end
		
		stateService.addState(targetHit, "Stunned", .4)
		
		local damagePertick = foundWeaponData.damage /3
		local tickCount = 5
		
		task.spawn(function()

			for i = 1, tickCount do
				if targetHumanoid.Health <= 0 then
					DropExp:Fire(attacker, targetHit)
				end
				
				task.delay(i * 2 / 10, function()
					if targetHumanoid and targetHumanoid.Health > 0 then
						--if targetHumanoid.Health <= 20 then
						--	targetHumanoid.Health = 100
						--end
						targetHumanoid:TakeDamage(damagePertick)
						
						replicatedStorage.Remotes.ClientEffects:FireAllClients("DefaultHit", {
							["Target"] = targetHit,
							["weaponUsed"] = weaponUsed
						})
						--print("Poison tick " .. i .. " on " .. targetHit.Name .. " (took " .. damagePertick .. " damage)")
					end
				end)
			end

		end)
		
		--targetHumanoid:TakeDamage(foundWeaponData.damage)
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound", {
			["SoundName"] = weaponUsed..".Hit."..tostring(comboSwingNumber),
			["Parent"] = targetHit.HumanoidRootPart
		})
		 
		replicatedStorage.Remotes.ClientEffects:FireAllClients("DefaultHit", {
			["Target"] = targetHit,
			["weaponUsed"] = weaponUsed
		})
		
		-- playing the animation of hitreaction on enemy
		if targetHit:FindFirstChild("Core") then
			--print("inside core")
			local animationModule = require(targetHit.Core.Animations)
			local anim = animationModule.LoadedAnimations[weaponUsed..".HitReaction."..tostring(comboSwingNumber)]
			
			if anim then anim:Play() end 
			
			print(animationModule.LoadedAnimations[weaponUsed..".HitReaction."..tostring(comboSwingNumber)])
		else
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			
			if animator then
				local reactionAnim = animator:LoadAnimation(assets.Animations[weaponUsed]["HitReaction"][tostring(comboSwingNumber)])
				reactionAnim:Play()				
				if reactionAnim.IsPlaying then
					--print("Animation is playing")
				end
			end
		end
		

		--if comboSwingNumber == 3 then
		--	stateService.addState(targetHit, "Airbone")
		--	local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		--	local goal = {CFrame = targetHrp.CFrame * CFrame.new(0, 4, 0)}
		--	local goal2 = {CFrame = attackerHrp.CFrame * CFrame.new(0, 4, 0)}

		--	local targetTween = tweenService:Create(targetHrp, tweenInfo, goal)
		--	local attackerTween = tweenService:Create(attackerHrp, tweenInfo, goal2)

		--	targetTween:Play(); attackerTween:Play()

		--	debris:AddItem(targetTween, .4)
		--	debris:AddItem(attackerTween, .4)

		--	task.wait(.4)
		--	stateService.removeState(targetHit, "Airbone")
		--end
		
		-- Replace your commented airborne section with THIS:
		if comboSwingNumber == 3 then
			stateService.addState(targetHit, "Airborne", 0.6) -- Protect from spam

			local targetHrp = targetHit.HumanoidRootPart
			local attackerHrp = attacker.HumanoidRootPart

			-- SINGLE smooth launch (no BodyVelocity spam)
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
			bodyVelocity.Velocity = (targetHrp.Position - attackerHrp.Position).Unit * 30 + Vector3.new(0, 75, 0)
			bodyVelocity.Parent = targetHrp
			
			-- Smooth fade out (no jitter)
			local fadeTween = tweenService:Create(bodyVelocity, 
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
				{MaxForce = Vector3.new(0,0,0)}
			)
			
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				bodyVelocity:Destroy()
				task.wait(0.3)
				debris:AddItem(bodyVelocity, 0.3)
				stateService.removeState(targetHit, "Airborne")
			end)
		end

		
		------- knockback
		local velocities = {
			10,
			20,
			30,
			40,
			50
		}
		
		local velocity = velocities[comboSwingNumber]
		
		if comboSwingNumber ~= 5 then 
			local pullVelocity = Instance.new("BodyVelocity")
			pullVelocity.MaxForce = Vector3.new(4e4, 0, 4e4)
			pullVelocity.Velocity = attacker.HumanoidRootPart.CFrame.LookVector * velocity * 2
			pullVelocity.Parent = attacker.HumanoidRootPart
			debris:AddItem(pullVelocity, .2)
		end
		
		local knockBack = Instance.new("BodyVelocity")
		knockBack.MaxForce = Vector3.new(4e4, 4e4, 4e4)
		knockBack.Velocity = attacker.HumanoidRootPart.CFrame.LookVector * velocity
		knockBack.Parent = targetHit.HumanoidRootPart
		debris:AddItem(knockBack, .2)
		
		--print("Default damage hitType reached", attacker, targetHit, weaponUsed)
		
	end
	
end
