module("zip.Decompressors", package.seeall)

Object = require("zip.Object")

Decompressors = setmetatable( {}, Object )
Decompressors.__index = Decompressors
Decompressors.__type = "Decompressors"

--[[
	01: shrunk
	02: reduced with compression factor 1
	03: reduced with compression factor 2 
	04: reduced with compression factor 3 
	05: reduced with compression factor 4 
	06: imploded
	07: reserved
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

Decompressors[0] = function (CompressedData)
	
	-- Decompression method 0: no compression
	
	return CompressedData
	
end

Decompressors[8] = function (CompressedData)
	
	-- Decompression method 8: deflate
	local Success, DecompressedData = pcall(love.data.decompress, "string", "deflate", CompressedData)
	
	if Success then
		
		return DecompressedData
		
	end
	
	return nil
	
end

return Decompressors