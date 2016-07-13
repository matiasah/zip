local zip = ...

local ZipDir = {Type = "Directory"}
local ZipDirMT = {__index = ZipDir}

zip.Reader[0x02014b50] = function (self)
	local Dir = setmetatable({}, ZipDirMT)
	
	Dir.Version = self:ReadShort()
	Dir.VersionNeeded = self:ReadShort()
	Dir.BitFlag = self:ReadBits(16)
	Dir.CompressionMethod = self:ReadShort()
	Dir.LastModificationTime = self:ReadShort()
	Dir.LastModificationDate = self:ReadShort()
	Dir.CRC32 = self:ReadInt()
	Dir.CompressedSize = self:ReadInt()
	Dir.UncompressedSize = self:ReadInt()
	Dir.PathLength = self:ReadShort()
	Dir.ExtraFieldLength = self:ReadShort()
	Dir.CommentLength = self:ReadShort()
	
	Dir.DiskNumber = self:ReadShort()
	Dir.InternalAttributes = self:ReadShort()
	Dir.ExternalAttributes = self:ReadInt()
	Dir.RelativeOffset = self:ReadInt()
	
	Dir.Path = self:ReadString(Dir.PathLength)
	Dir.ExtraField = self:ReadString(Dir.ExtraFieldLength)
	Dir.Comment = self:ReadString(Dir.CommentLength)
	
	Dir.Folders = {}
	for String in Dir.Path:gmatch("([^/]+)") do
		table.insert(Dir.Folders, String)
	end
	
	if Dir.Path:sub(-1, -1) == "/" then
		Dir.Folder = true
		Dir.Name = ""
		Dir.Source = Dir.Path
	else
		Dir.Handle = io.tmpfile()
		Dir.Handle:write(self:ReadString(Dir.CompressedSize))
		
		Dir.Name = Dir.Folders[#Dir.Folders]
		Dir.Folders[#Dir.Folders] = nil
		Dir.Source = table.concat(Dir.Folders, "/").."/"
	end
	
	return Dir
end