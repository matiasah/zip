module("zip.Object", package.seeall)

Object = {}
Object.__index = Object
Object.__type = "Object"

function Object:typeOf(Type)
	
	local Metatable = getmetatable(self)
	
	while Metatable do
		
		if Metatable == Type or Metatable.__type == Type then
			
			return true
			
		end
		
		Metatable = getmetatable(Metatable)
		
	end
	
	return false
	
end

function Object:type()
	
	return self.__type
	
end

return Object