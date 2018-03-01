module("zip.table", package.seeall)

table = setmetatable( {}, {__index = table})

function table.compare(TableA, TableB)
	
	for k, v in pairs(TableA) do
		
		if type(v) == "table" and type(TableB[k]) == "table" then
			
			if not table.compare(v, TableB[k]) then
				
				return false
				
			end
			
		elseif v ~= TableB[k] then
			
			return false
			
		end
		
	end
	
	return true
	
end

return table