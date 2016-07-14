local zip = ...

local ZipFile = {Type = "File"}
local ZipFileMT = {__index = ZipFile}

function ZipFileMT:__tostring()
	return "Zip "..tostring(self.Handle)
end

zip.Reader[0x04034b50] = function (self)
	local File = setmetatable({}, ZipFileMT)
	
	File.Version = self:ReadShort()
	File.BitFlag = self:ReadBits(16)
	
	--[[
		General purpose bit flag:
		Bit 00: encrypted file
		Bit 01: compression option 
		Bit 02: compression option 
		Bit 03: data descriptor
		Bit 04: enhanced deflation
		Bit 05: compressed patched data
		Bit 06: strong encryption
		Bit 07-10: unused
		Bit 11: language encoding
		Bit 12: reserved
		Bit 13: mask header values
		Bit 14-15: reserved
	]]
	
	File.CompressionMethod = self:ReadShort()
	File.LastModificationTime = self:ReadShort()
	File.LastModificationDate = self:ReadShort()
	--[[
		File modification time	stored in standard MS-DOS format:
		Bits 00-04: seconds divided by 2 
		Bits 05-10: minute
		Bits 11-15: hour
		File modification date	stored in standard MS-DOS format:
		Bits 00-04: day
		Bits 05-08: month
		Bits 09-15: years from 1980
	]]
	
	-- value computed over file data by CRC-32 algorithm with 'magic number' 0xdebb20e3 (little endian)
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
		local Content = self:ReadString(File.CompressedSize)
		File.Handle = io.tmpfile()
		File.Handle:write(Content)
		
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