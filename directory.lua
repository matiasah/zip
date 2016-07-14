local zip = ...

local ZipDir = {Type = "Directory"}
local ZipDirMT = {__index = ZipDir}

function ZipDirMT:__tostring()
	return "Zip "..tostring(self.Handle)
end

zip.Reader[0x02014b50] = function (self)
	local Dir = setmetatable({}, ZipDirMT)
	
	Dir.Version = self:ReadShort()
	--[[
		0 - MS-DOS and OS/2 (FAT / VFAT / FAT32 file systems)
		1 - Amiga 
		2 - OpenVMS
		3 - UNIX 
		4 - VM/CMS
		5 - Atari ST
		6 - OS/2 H.P.F.S.
		7 - Macintosh 
		8 - Z-System
		9 - CP/M 
		10 - Windows NTFS
		11 - MVS (OS/390 - Z/OS) 
		12 - VSE
		13 - Acorn Risc 
		14 - VFAT
		15 - alternate MVS 
		16 - BeOS
		17 - Tandem 
		18 - OS/400
		19 - OS/X (Darwin) 
		20 - 255: unused
	]]
	
	Dir.VersionNeeded = self:ReadShort()
	Dir.BitFlag = self:ReadBits(16)
	--[[
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
	
	Dir.CompressionMethod = self:ReadShort()
	--[[
		00: no compression
		01: shrunk
		02: reduced with compression factor 1
		03: reduced with compression factor 2 
		04: reduced with compression factor 3 
		05: reduced with compression factor 4 
		06: imploded
		07: reserved
		08: deflated
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
		local Content = self:ReadString(Dir.CompressedSize)
		Dir.Handle = io.tmpfile()
		Dir.Handle:write(Content)
		
		Dir.Name = Dir.Folders[#Dir.Folders]
		Dir.Folders[#Dir.Folders] = nil
		Dir.Source = table.concat(Dir.Folders, "/").."/"
	end
	
	return Dir
end

function ZipDir:Decompress()
	local Method = zip.Decompressor[self.CompressionMethod]
	if Method then
		return Method(self)
	end
	return false
end