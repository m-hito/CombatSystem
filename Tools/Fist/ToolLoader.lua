--ToolLoader 
local tool = script.Parent

local replicatedStorage = game:GetService("ReplicatedStorage")

local player = tool.Parent.Parent

local character = player.Character or player.CharacterAdded:Wait()

local assets = replicatedStorage.Assets

local humanoid = character:WaitForChild("Humanoid", math.huge)
local animator = humanoid.Animator
local LoadAnimsEvent = replicatedStorage.Remotes.LoadAnims

local animationModule = require(character.Core.Animations)  -- Global path

animationModule:LoadAnimations(animator, assets.Animations.Fist)
tool:SetAttribute("ToolLoaded", true)