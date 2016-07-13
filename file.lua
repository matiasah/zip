local zip = ...

local ZipFile = {Type = "File"}
local ZipFileMT = {__index = ZipFile}

zip.Reader[0x04034b50] = function (self)
	local File = setmetatable({}, ZipFileMT)
	
	File.Version = self:ReadShort()
	File.BitFlag = self:ReadBits(16)
	File.CompressionMethod = self:ReadShort()
	File.LastModificationTime = self:ReadShort()
	File.LastModificationDate = self:ReadShort()
	File.CRC32 = self:ReadInt()
	File.CompressedSize = self:ReadInt()
	File.UncompressedSize = self:ReadInt()
	File.PathLength = self:ReadShort()
	File.ExtraFieldLength = self:ReadShort()
	
	File.Path = self:ReadString(File.PathLength)
	File.ExtraField = self:ReadString(File.ExtraFieldLength)
	
	File.Folders = {}
	for String in File.Path:gmatch("([^/]+)") do
		table.insert(File.Folders, String)
	end
	
	if File.Path:sub(-1, -1) == "/" then
		File.Folder = true
		File.Name = ""
		File.Source = File.Path
	else
		File.Handle = io.tmpfile()
		File.Handle:write(self:ReadString(File.CompressedSize))
		
		File.Name = File.Folders[#File.Folders]
		File.Folders[#File.Folders] = nil
		File.Source = table.concat(File.Folders, "/").."/"
	end

	return File
end

function ZipFile:Decompress()
	local Method = zip.Decompressor[self.CompressionMethod]
	if Method then
		return Method(self)
	end
	return false
end