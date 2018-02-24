module("zip.Data", package.seeall)

Object = require("zip.Object")

Data = setmetatable( {}, Object )
Data.__index = Data
Data.__type = "Data"

function Data:new()
	
	return setmetatable( {}, Data )
	
end

function Data:__tostring()
	
	return "Data (zip)"
	
end

function Data:SetCRC32(CRC32)
	
	self.CRC32 = CRC32
	
end

function Data:GetCRC32()
	
	return self.CRC32
	
end

function Data:SetCompressedSize(CompressedSize)
	
	self.CompressedSize = CompressedSize
	
end

function Data:GetCompressedSize()
	
	return self.CompressedSize
	
end

function Data:SetUncompressedSize(UncompressedSize)
	
	self.UncompressedSize = UncompressedSize
	
end

function Data:GetUncompressedSize()
	
	return self.UncompressedSize
	
end

return Data