module("zip.Decompressors", package.seeall)

zlib = require("zip.zlib")

Decompressors = {}
Decompressors.__index = Decompressors
Decompressors.__type = "Decompressors"

Decompressors[0] = function (self)
	
	-- Decompression method 0: no compression
	
	return love.filesystem.newFileData( self:GetCompressedData(), self:GetName() )
	
end

Decompressors[8] = function (self)
	
	-- Decompression method 0: no compression
	local Data = self:GetCompressedData()
	local Success, DecompressedData = pcall(zlib.inflate, Data, "", #Data, "deflate")
	
	if Success then
		
		return love.filesystem.newFileData( DecompressedData, self:GetName() )
		
	end
	
	return nil
	
end

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

return Decompressors