module("zip.Readers", package.seeall)

Object			= require("zip.Object")
CentralFile		= require("zip.CentralFile")
Data				= require("zip.Data")
EndOfDir			= require("zip.EndOfDir")
File				= require("zip.File")

Readers = setmetatable( {}, Object )
Readers.__index = Readers
Readers.__type = "Readers"

-- Central directory file header
Readers[0x02014b50] = function (self)
	
	local newFile = CentralFile:new()
	
	newFile:SetReader(self)
	newFile:SetVersion( self:ReadShort() )
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
	
	newFile:SetVersionNeeded( self:ReadShort() )
	newFile:SetBitFlags( self:ReadBits(16) )
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
	
	newFile:SetCompressionMethod( self:ReadShort() )
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
	
	newFile:SetLastModificationTime( self:ReadShort() )
	newFile:SetLastModificationDate( self:ReadShort() )
	newFile:SetCRC32( self:ReadInt() )
	newFile:SetCompressedSize( self:ReadInt() )
	newFile:SetUncompressedSize( self:ReadInt() )
	
	local PathLength = self:ReadShort()
	local ExtraFieldLength = self:ReadShort()
	local CommentLength = self:ReadShort()
	
	newFile:SetDiskNumber( self:ReadShort() )
	newFile:SetInternalAttributes( self:ReadShort() )
	newFile:SetExternalAttributes( self:ReadInt() )
	newFile:SetRelativeOffset( self:ReadInt() )
	
	newFile:SetPath( self:ReadString(PathLength) )
	newFile:SetExtraField( self:ReadString(ExtraFieldLength) )
	newFile:SetComment( self:ReadString(CommentLength) )
	
	local Folders = {}
	
	for String in newFile:GetPath():gmatch("([^/]+)") do
		
		table.insert(Folders, String)
		
	end
	
	local Name = table.remove(Folders, #Folders)
	
	newFile:SetFolders( Folders )
	
	if newFile.Path:sub(-1, -1) == "/" then
		
		newFile:SetDirectory( true )
		newFile:SetName( Name )
		
	else
		
		newFile:SetName( Name )
		
	end
	
	return newFile
	
end

-- Local file header
Readers[0x04034b50] = function (self)
	
	local newFile = File:new()
	
	newFile:SetReader(self)
	newFile:SetVersionNeeded( self:ReadShort() )
	newFile:SetBitFlags( self:ReadBits(16) )
	
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
	
	newFile:SetCompressionMethod( self:ReadShort() )
	newFile:SetLastModificationTime( self:ReadShort() )
	newFile:SetLastModificationDate( self:ReadShort() )
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
	newFile:SetCRC32( self:ReadInt() )
	newFile:SetCompressedSize( self:ReadInt() )
	newFile:SetUncompressedSize( self:ReadInt() )
	
	local PathLength = self:ReadShort()
	local ExtraFieldLength = self:ReadShort()
	
	newFile:SetPath( self:ReadString(PathLength) )
	newFile:SetCompressedData( self:ReadString( newFile:GetCompressedSize() ) )
	newFile:SetExtraField( self:ReadString(ExtraFieldLength) )
	
	local Folders = {}
	
	for String in newFile:GetPath():gmatch("([^/]+)") do
		
		table.insert(Folders, String)
		
	end
	
	local Name = table.remove(Folders, #Folders)
	
	newFile:SetFolders( Folders )
	
	if newFile.Path:sub(-1, -1) == "/" then
		
		newFile:SetDirectory( true )
		newFile:SetName( Name )
		
	else
		
		newFile:SetName( Name )
		
	end

	return newFile
	
end

Readers[0x08074b50] = function (self)
	
	local Data = Data:new()
	
	Data:SetReader(self)
	Data:SetCRC32( self:ReadInt() )
	Data:SetCompressedSize( self:ReadInt() )
	Data:SetUncompressedSize( self:ReadInt() )
	Data:SetRelativeOffset( self:Tell() )
	
	return Data
	
end

-- End of central directory record (EOCD)
Readers[0x06054b50] = function (self)
	
	local newEOD = EndOfDir:new()
	
	newEOD:SetReader(self)
	newEOD:SetDiskNumber( self:ReadShort() )
	newEOD:SetDiskStart( self:ReadShort() )
	newEOD:SetDiskRecord( self:ReadShort() )
	newEOD:SetDiskTotal( self:ReadShort() )
	newEOD:SetSize( self:ReadInt() )
	newEOD:SetRelativeOffset( self:ReadInt() )
	
	local CommentLength = self:ReadShort()
	newEOD:SetComment( self:ReadString(CommentLength) )
	
	return newEOD
	
end

return Readers