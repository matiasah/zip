local zip = ...

local ZipEODir = {Type = "End Of Directory"}
local ZipEODirMT = {__index = ZipEODir}

zip.Reader[0x06054b50] = function (self)
	local Dir = setmetatable({}, ZipEODirMT)
	
	Dir.DiskNumber = self:ReadShort()
	Dir.DiskStart = self:ReadShort()
	Dir.DiskRecord = self:ReadShort()
	Dir.DiskTotal = self:ReadShort()
	Dir.Size = self:ReadInt()
	Dir.Offset = self:ReadInt()
	Dir.CommentLength = self:ReadShort()
	Dir.Comment = self:ReadString(Dir.CommentLength)
	
	return Dir
end