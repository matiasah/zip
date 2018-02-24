module("zip.Decompressors", package.seeall)

Decompressors = {}
Decompressors.__index = Decompressors
Decompressors.__type = "Decompressors"

Decompressors[0] = function (self)
	
	-- Decompression method 0: no compression
	if self.Out then
		
		self.Out:close()
		
	end
	
	self.Handle:seek("set", 0)
	self.Out = io.tmpfile()
	self.Out:write(self.Handle:read("*a"))
	self.Out:seek("set", 0)
	
	return self.Out
	
end

Decompressors[8] = function (self)
	-- Decompression method 8: deflate
	
	if self.Out then
		
		self.Out:close()
		
	end
	
	local Size = self.Handle:seek("end")
	
	self.Out = nil
	self.Handle:seek("set", 0)
	
	local Content = self.Handle:read("*a")
	local Success, Decompress = pcall(love.math.decompress, Content, "zlib")
	
	if Success then
		
		self.Out = io.tmpfile()
		self.Out:write(Decompress)
		self.Out:seek("set", 0)
		
		return self.Out
		
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