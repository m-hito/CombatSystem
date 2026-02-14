local WeaponData = {
	StoredData = {}
}

function WeaponData:GetWeaponData(weapon : string)
	return WeaponData.StoredData[weapon] or nil 
end

for _, module in script:GetChildren() do
	
	if module:IsA("ModuleScript") then
		WeaponData.StoredData[module.Name] = require(module)
		
	end
end
--print(WeaponData.StoredData)

return WeaponData
