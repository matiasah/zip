module("zip.Compressors", package.seeall)

Object = require("zip.Object")

Compressors = setmetatable( {}, Object )
Compressors.__index = Compressors
Compressors.__type = "Compressors"

--[[
	00: no compression
	01: shrunk
	02: reduced with compression factor 1
	03: reduced with compression factor 2 
	04: reduced with compression factor 3 
	05: reduced with compression factor 4 
	06: imploded
	07: reserved
	08: deflated
	09: enhanced deflated
	10: PKWare DCL imploded
	11: reserved
	12: compressed using BZIP2
	13: reserved
	14: LZMA
	15-17: reserved
	18: compressed using IBM TERSE
	19: IBM LZ77 z
	98: PPMd version I, Rev 1
]]

Compressors[0] = function (Data)
	
	return Data
	
end

Compressors[8] = function (Data)
	
	local Success, CompressedData = pcall(love.data.compress, "string", "deflate", Data)
	
	if Success then
		
		return CompressedData
		
	end
	
	return nil
	
end

return Compressors