local zip = ...

local ZipData = {Type = "Data"}
local ZipDataMT = {__index = ZipData}

zip.Reader[0x08074b50] = function (self)
	local Data = setmetatable({}, ZipDataMT)
	
	Data.CRC32 = self:ReadInt()
	Data.CompressedSize = self:ReadInt()
	Data.UncompressedSize = self:ReadInt()
	
	Data.Handle = io.tmpfile()
	Data.Handle:write(self:ReadString(Data.CompressedSize))
	
	return Data
end