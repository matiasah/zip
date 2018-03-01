module("zip.Data", package.seeall)

ZipEntry = require("zip.ZipEntry")
Decompressors = require("zip.Decompressors")

Data = setmetatable( {}, ZipEntry )
Data.__index = Data
Data.__type = "Data"

function Data:new()
	
	return setmetatable( {}, Data )
	
end

function Data:__tostring()
	
	return "Data (zip)"
	
end

function Data:GetName()
	
	return self.CRC32
	
end

function Data:SetCRC32(CRC32)
	
	self.CRC32 = CRC32
	
end

function Data:GetCRC32()
	
	return self.CRC32
	
end

function Data:GetData()
	
	return Decompressors[8](self)
	
end

return Data