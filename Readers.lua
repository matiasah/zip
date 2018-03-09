module("zip.Readers", package.seeall)

Object			= require("zip.Object")
Data				= require("zip.Data")
EndOfDir			= require("zip.EndOfDir")
File				= require("zip.File")
crc32				= require("zip.crc32")

Readers = setmetatable( {}, Object )
Readers.__index = Readers
Readers.__type = "Readers"

-- Central directory file header (CentralFile)
Readers[0x02014b50] = function (self)
	
	local centralFileData = {}
	
	do
		
		centralFileData.Version = self:ReadShort()
		centralFileData.VersionNeeded = self:ReadShort()
		centralFileData.BitFlags = self:ReadBits(16)
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
		
		centralFileData.CompressionMethod = self:ReadShort()
		centralFileData.LastModificationTime = self:ReadShort()
		centralFileData.LastModificationDate = self:ReadShort()
		
		centralFileData.CRC32 = self:ReadInt()
		centralFileData.CompressedSize = self:ReadInt()
		centralFileData.UncompressedSize = self:ReadInt()
		
		local PathLength = self:ReadShort()
		local ExtraFieldLength = self:ReadShort()
		local CommentLength = self:ReadShort()
		
		centralFileData.DiskNumber = self:ReadShort()
		centralFileData.InternalAttributes = self:ReadShort()
		centralFileData.ExternalAttributes = self:ReadInt()
		centralFileData.RelativeOffset = self:ReadInt()
		centralFileData.Path = self:ReadString(PathLength)
		centralFileData.ExtraField = self:ReadString(ExtraFieldLength)
		centralFileData.Comment = self:ReadString(CommentLength)
		
		if PathLength ~= #centralFileData.Path or ExtraFieldLength ~= #centralFileData.ExtraField or CommentLength ~= #centralFileData.Comment then
			-- File corrupted
			return nil
			
		end
		
		local Disk = self:GetDisk()
		local File = Disk:GetEntry(centralFileData.Path)
		
		if File then
			
			-- Extra field from central directory and from the file doesn't match ????
			
			File:SetVersion( centralFileData.Version )
			File:SetInternalAttributes( centralFileData.InternalAttributes )
			File:SetExternalAttributes( centralFileData.ExternalAttributes )
			File:SetComment( centralFileData.Comment )
			
		end
		
	end
	
	return nil
	
end

-- Local file header (File)
Readers[0x04034b50] = function (self)
	
	local newFile = File:new()
	
	do
		
		newFile:SetReader(self)
		newFile:SetDisk(self:GetDisk())
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
		
		-- value computed over file data by CRC-32 algorithm with 'magic number' 0xdebb20e3 (little endian)
		newFile:SetCRC32( self:ReadInt() )
		newFile:SetCompressedSize( self:ReadInt() )
		newFile:SetUncompressedSize( self:ReadInt() )
		
		local PathLength = self:ReadShort()
		local ExtraFieldLength = self:ReadShort()
		
		newFile:SetPath( self:ReadString(PathLength) )
		newFile:SetExtraField( self:ReadString(ExtraFieldLength) )
		newFile:SetDataOffset( self:Tell() )
		
		if PathLength ~= #newFile:GetPath() or ExtraFieldLength ~= #newFile:GetExtraField() then
			-- File corrupted
			return nil
			
		end
		
		self:Seek( self:Tell() + newFile:GetCompressedSize() )
		
		local Name = newFile:GetName()
		
		if newFile.Path:sub(-1, -1) == "/" then
			
			newFile:SetDirectory( true )
			
		end
		
	end
	
	-- Bit 3 is set, read data descriptor
	if newFile:GetBitFlags()[3] then
		
		-- Read data descriptor signature
		if self:ReadInt() ~= 0x08074b50 then
			
			-- If the signature is not present, return 4 bytes back
			self:Seek( self:Tell() - 4 )
			
		end
		
		-- What to do with the data descriptor??
		Readers[0x08074b50](self)
		
	end

	return newFile
	
end

-- Data descriptor (Data)
Readers[0x08074b50] = function (self)
	
	local Data = Data:new()
	
	Data:SetReader(self)
	Data:SetCRC32( self:ReadInt() )
	Data:SetCompressedSize( self:ReadInt() )
	Data:SetUncompressedSize( self:ReadInt() )
	
	return Data
	
end

-- End of central directory record (EndOfDir)
Readers[0x06054b50] = function (self)
	
	local newEOD = EndOfDir:new()
	
	do
		
		newEOD:SetReader(self)
		newEOD:SetDiskNumber( self:ReadShort() )
		newEOD:SetDiskStart( self:ReadShort() )
		newEOD:SetDiskEntries( self:ReadShort() )
		newEOD:SetDiskTotal( self:ReadShort() )
		newEOD:SetSize( self:ReadInt() )
		newEOD:SetOffset( self:ReadInt() )
		
		local CommentLength	= self:ReadShort()
		local Comment			= self:ReadString(CommentLength)
		
		newEOD:SetComment( Comment )
		
	end
	
	do
		
		local Disk = self:GetDisk()
		
		Disk:SetNumber( newEOD:GetDiskNumber() )
		Disk:SetComment( newEOD:GetComment() )
		
	end
	
	return newEOD
	
end

return Readers