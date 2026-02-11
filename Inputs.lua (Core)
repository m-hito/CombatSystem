local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")  -- ✓
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera 

local modules = replicatedStorage.Modules
local remotes = replicatedStorage:WaitForChild("Remotes")
local LoadAnimsEvent = remotes.LoadAnims
local statusFolder = character:WaitForChild("Status", math.huge)
local stateService = require(modules.StateService)

local assets = replicatedStorage.Assets
local animationFolder = assets.Animations
local weaponData = require(replicatedStorage.Modules.WeaponData)

local animModule = require(script.Parent.Animations)

local clientFolder = animationFolder:WaitForChild("Client", 3)

animModule:LoadAnimations(humanoid.Animator, clientFolder)

--print("Loaded Animations: ", animModule.LoadedAnimations)

local isTyping = false
local stepConnection = nil

local currentIdle = Instance.new("StringValue")
currentIdle.Name = "CurrentIdle"
currentIdle.Value = ""
currentIdle.Parent = statusFolder

local currentRun = Instance.new("StringValue")
currentRun.Name = "CurrentRun"
currentRun.Value = ""
currentRun.Parent = statusFolder

local startTime = os.time()

local function canDash()
	if stateService.checkState(character, "Stunned", "Attacking", "NoSprint", "NoMove", "Dashing", "DashCooldown") then
		return false
	end
	
	--if statusFolder:FindFirstChild("Blocking") 
	--	or statusFolder:FindFirstChild("Stunned") 
	--	or statusFolder:FindFirstChild("Attacking")
	--	or statusFolder:FindFirstChild("NoSprint")	
	--	or statusFolder:FindFirstChild("NoMove") 
	--	or statusFolder:FindFirstChild("Dashing") 
	--	or statusFolder:FindFirstChild("DashCooldown") then

	--	return false

	--end

	return true 
end

local function canBlock()
	if stateService.checkState(character, "Stunned", "Attacking", "NoSprint", "NoMove", "BlockBroken")  then
		return false
	end
	
	return true 
end

local function isMoving()
	return (humanoid.MoveDirection.Magnitude > 0)
end

local function changeIdle()
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool then
		if weaponData:GetWeaponData(foundTool.Name) then
			
			local previous = currentIdle.Value

			currentIdle.Value = "Client.Idles."..foundTool.Name
			--print("CurrentIdle = "..currentIdle.Name)
			return 
		end
		
	end

	if currentIdle.Value ~= "Client.Idles.Default" then
		local previous = currentIdle.Value
		currentIdle.Value = "Client.Idles.Default"
		
		return 
	end
	
	currentIdle.Value = "Client.Idles.Default"
	
	return {} -- the variable itself return a table 
end

local function changeRun()
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool then
		if weaponData:GetWeaponData(foundTool.Name) then

			local previous = currentRun.Value

			currentRun.Value = "Client.Runs."..foundTool.Name
			--print("CurrentRun = "..currentRun.Name)
			return 
		end

	end

	if currentRun.Value ~= "Client.Runs.Default" then
		local previous = currentRun.Value
		currentRun.Value = "Client.Runs.Default"

		return 
	end

	currentRun.Value = "Client.Runs.Default"

	return {} -- the variable itself return a table 
end

local function getDashDirection()
	local keyPressed = UserInputService:GetKeysPressed()
	for _, input: InputObject in keyPressed do
		if input.KeyCode == Enum.KeyCode.A then
			return "Left"
		end
		
		if input.KeyCode == Enum.KeyCode.D then
			return "Right"
		end
		
		if input.KeyCode == Enum.KeyCode.S then
			return "Back"
		end
		
		if input.KeyCode == Enum.KeyCode.W then
			return "Forward"
		end
	end
	
	return nil 
end

local function stopAnimation(category) 
	
	if category == "Idles" then
		for name, anim in animModule.LoadedAnimations do
			if string.find(name, "Client.Idles") then
				if anim.IsPlaying then
					anim:Stop(.3)
				end
			end

		end
	end
	
	if category == "Runs" then
		for name, anim in animModule.LoadedAnimations do
			if string.find(name, "Client.Runs") then
				if anim.IsPlaying then
					anim:Stop(.3)
				end
			end

		end
	end
	
end

local function ToggleSprint(isSprinting)
	local humanoid = character:FindFirstChild("Humanoid")
	local goalFOV = isSprinting and 95 -- Zoom out when running

	-- Change Speed
	humanoid.WalkSpeed = isSprinting and 24 or 16

	-- Tween FOV for "Speed Effect"
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad)
	local FOV = TweenService:Create(Camera, tweenInfo, {FieldOfView = goalFOV}):Play()
	
	task.delay(0.6, function()
		goalFOV = 70
		TweenService:Create(Camera, tweenInfo, {FieldOfView = goalFOV}):Play()
	end)
	
end

UserInputService.InputBegan:Connect(function(input, gameProccessed)
	if gameProccessed and (input.KeyCode ~= Enum.KeyCode.LeftControl) and (input.KeyCode ~= Enum.KeyCode.RightControl) then
		isTyping = true
		return
	end
	isTyping = false
	
	if input.KeyCode == Enum.KeyCode.Q  then
		local direction = getDashDirection()
		--print(direction)
		if direction then
			if not canDash() then return end
			
			local dashing = Instance.new("Folder")
			dashing.Name = "Dashing"
			dashing.Parent = statusFolder
			
			local dashEndLag = Instance.new("Folder")
			dashEndLag.Name = "DashEndLag"
			dashEndLag.Parent = statusFolder

			debris:AddItem(dashEndLag, .5)
			debris:AddItem(dashing, .3)
			
			animModule.LoadedAnimations["Client.Dashes."..direction]:Play()
			
			local dashVelocity = Instance.new("BodyVelocity")
			dashVelocity.MaxForce = Vector3.new(99999, 99999, 99999)
			dashVelocity.Parent = character.HumanoidRootPart
			
			local dashingConnection = nil 
			dashingConnection = runService.RenderStepped:Connect(function()
				if not dashing.Parent then
					dashingConnection:Disconnect()
					dashingConnection = nil
					dashVelocity:Destroy()
					
					local dashCoolDown = Instance.new("Folder")
					dashCoolDown.Name = "DashCooldown"
					dashCoolDown.Parent = statusFolder

					debris:AddItem(dashCoolDown, 1.5)
					return 
				end
				
				if direction == "Left" then -- CFrame.LeftVector is not a thing so we use rightvector
					dashVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * -50
					ToggleSprint(true)
				elseif direction == "Right" then
					dashVelocity.Velocity = character.HumanoidRootPart.CFrame.RightVector * 50
					ToggleSprint(true)
				elseif direction == "Forward" then
					dashVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * 50
					ToggleSprint(true)
				elseif direction == "Back" then 
					dashVelocity.Velocity = character.HumanoidRootPart.CFrame.LookVector * -50
					ToggleSprint(true)
				end
			end)
			
		end

		
	end
	

end)
-- instead of IsKeyDown in renderstepped we can use InputEnded here to detect if F key was held down then set isBlocking false 

runService.Heartbeat:Connect(function(dt: number) -- detect input each frame for smooth input detection

	--- state handler 
	task.spawn(function()
		local finalWalkSpeed = 16
		local finalJumpPower = 32
		
		if statusFolder:FindFirstChild("Sprinting") then
			if not canBlock() or statusFolder:FindFirstChild("Blocking") then
				statusFolder["Sprinting"]:Destroy()
			end
			
		end
		
		if statusFolder:FindFirstChild("Sprinting") then
			finalWalkSpeed = 50
			
		end
		
		if character.Status:FindFirstChild("Blocking") then
			finalWalkSpeed = 10
			finalJumpPower = 0
		end
		
		if character.Status:FindFirstChild("Attacking") then
			finalWalkSpeed = 7
			finalJumpPower = 0 
			
		end
		
		humanoid.WalkSpeed = finalWalkSpeed
		humanoid.JumpPower = finalJumpPower
		
		if finalJumpPower == 0 or statusFolder:FindFirstChild("NoJump") then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			--print("F pressed")
		else
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
		

		-- IDLE AND RUN LOGIC 
		task.spawn(function()
			
			if humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Landed then
				stopAnimation("Idles")
				stopAnimation("Runs")
				return
			end
			
			if statusFolder:FindFirstChild("Dashing") or statusFolder:FindFirstChild("DashEndLag") then
				stopAnimation("Idles")
				stopAnimation("Runs")
				return
			end
			
			-- Playing idle and run animations
			if isMoving() then

				local foundNewIdle = animModule.LoadedAnimations[currentIdle.Value]

				if foundNewIdle and foundNewIdle.IsPlaying then
					--print("STOPPING IDLE: ".. foundNewIdle.Name)
					foundNewIdle:Stop(.3)
				end

			else
				stopAnimation("Runs")
				changeIdle() -- here we are expecting a table 

				-- stop Previous only if it changed
				for name, anim in animModule.LoadedAnimations do
					if string.find(name, "Client.Idles.") and name ~= currentIdle.Value then
						anim:Stop(.3)
					end
				end

				local foundNewIdle = animModule.LoadedAnimations[currentIdle.Value]

				if foundNewIdle and not foundNewIdle.IsPlaying then
					--print("Playing idle: "..foundNewIdle.Name)
					foundNewIdle:Play()
				end

			end
			-- sprint section

			if isMoving() and statusFolder:FindFirstChild("Sprinting")then
				stopAnimation("Idles")
				changeRun() -- here we are expecting a table 

				-- stop Previous only if it changed
					for name, anim in animModule.LoadedAnimations do
						if string.find(name, "Client.Runs.") and name ~= currentRun.Value then
							anim:Stop(.2)
							--print("stopped "..anim.Name)
						end
					end

				local foundRun = animModule.LoadedAnimations[currentRun.Value]
				
				if foundRun and not foundRun.IsPlaying then
					--print("Playing Run: "..foundRun.Name, lastPlayedRun)
					foundRun:Play()

				end
			else
				-- Not moving idle state
				stopAnimation("Runs")

			end

		end)

	end)
	

	-- tell server to attack
	if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then -- is mouseButtonPressed for M1 is perfect
		--print("User left clicked")
		if not character:FindFirstChildWhichIsA("Tool") then return end
		
		if not stateService.checkState(character, "Dashing", "Attacking", "Blocking", "DashEndLag") then
			--Camera logic
		
			remotes.Attack:FireServer({})
			
			task.spawn(function()

				repeat
					task.wait()
					local endTime = os.time()

					local XOffset = math.random(-100, 100) / 100
					local YOffset = math.random(-100, 100) / 500
					local ZOffset = math.random(-100, 100) / 100

					humanoid.CameraOffset = Vector3.new(XOffset, YOffset, ZOffset)

				until startTime - endTime >= 0.1 or not stateService.checkState(character, "Attacking", "Blocking", "Dashing")

				humanoid.CameraOffset = Vector3.new(0, 0, 0)
				print("attack")
				
			end)
		end
	end

	
	-- Sprinting
	local isSprinting = false
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
		
		if canBlock() or statusFolder:FindFirstChild("Blocking") then
			-- start sprinting
			if not statusFolder:FindFirstChild("Sprinting") then
				local sprinting = Instance.new("Folder")
				sprinting.Name = "Sprinting"
				sprinting.Parent = statusFolder
				
				if statusFolder:FindFirstChild("Sprinting") then
					isSprinting = true
					ToggleSprint(isSprinting)
				end

			end
		end

	else
		-- stop sprinting
		local found = statusFolder:FindFirstChild("Sprinting")
		if found then
			found:Destroy()
			isSprinting = false
		end
	end
	
	---- Blocking 
	
	if not canBlock() then
		
		remotes.Block:FireServer(false)
		return
	end
	
	if not character:FindFirstChildWhichIsA("Tool") then -- dont block while there is no tool
		if statusFolder:FindFirstChild("Blocking") then
			remotes.Block:FireServer(false) -- this boolean means start blocking or not 
		end

		return -- we dont need anything below to run so we return it or if else statement will be executed!
	else
		local toolName = character:FindFirstChildWhichIsA("Tool").Name
		local blockingInstance = statusFolder:FindFirstChild("Blocking")
		
		--if not toolName and statusFolder:FindFirstChild("Blocking") then
		--	remotes.Block:FireServer(false)
		--end
		
		if blockingInstance  then
			local weaponName = blockingInstance:GetAttribute("weaponName")
			
			if weaponName ~= toolName then
				remotes.Block:FireServer(false)
			end			
		end
	end
	
	if UserInputService:IsKeyDown(Enum.KeyCode.F) and isTyping == false then
		
		if not statusFolder:FindFirstChild("Blocking") then -- if dont find blocking inside status then give true to server (CombatSystem)
			remotes.Block:FireServer(true)
		end

	else
		if statusFolder:FindFirstChild("Blocking") then
			remotes.Block:FireServer(false)

		end
	end
	
end)
