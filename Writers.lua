module("zip.Writers", package.seeall)

Object = require("zip.Object")

Writers = setmetatable( {}, Object )
Writers.__index = Writers
Writers.__type = "Writers"

-- Central file header (CentralFile)
Writers[0x02014b50] = function (self, FileObj)
	
	self:WriteInt( 0x02014b50 )
	
	-- Do not use data descriptor
	local BitFlags	= FileObj:GetBitFlags()
	local Disk		= self:GetDisk()
	
	do
		
		BitFlags[3] = false
		
	end
	
	self:WriteShort( FileObj:GetVersion() )
	self:WriteShort( FileObj:GetVersionNeeded() )
	self:WriteBits( BitFlags, 16 )
	
	self:WriteShort( FileObj:GetCompressionMethod() )
	self:WriteShort( FileObj:GetLastModificationTime() )
	self:WriteShort( FileObj:GetLastModificationDate() )
	
	self:WriteInt( FileObj:GetCRC32() )
	self:WriteInt( FileObj:GetCompressedSize() )
	self:WriteInt( FileObj:GetUncompressedSize() )
	
	local Path = FileObj:GetPath()
	local ExtraField = FileObj:GetExtraField()
	local Comment = FileObj:GetComment()
	
	self:WriteShort( #Path )
	self:WriteShort( #ExtraField )
	self:WriteShort( #Comment )
	
	self:WriteShort( Disk:GetNumber() )
	self:WriteShort( FileObj:GetInternalAttributes() )
	self:WriteInt( FileObj:GetExternalAttributes() )
	self:WriteInt( FileObj:GetRelativeOffset() )
	
	self:WriteString( Path )
	self:WriteString( ExtraField )
	self:WriteString( Comment )
	
	self:SetCentralDirectorySize( self:GetCentralDirectorySize() + #Path + #ExtraField + #Comment + 46 )
	
end

-- Local file header (File)
Writers[0x04034b50] = function (self, FileObj)
	
	do
		-- First, initialize relative offset and then write signature
		local Offset = self:Tell()
		
		FileObj:SetRelativeOffset( Offset )
		
	end
	
	self:WriteInt( 0x04034b50 )
	
	-- Do not use data descriptor
	local BitFlags = FileObj:GetBitFlags()
	
	do
		-- Disable the bit 3
		BitFlags[3] = false
		
	end
	
	self:WriteShort( FileObj:GetVersionNeeded() )
	self:WriteBits( BitFlags, 16 )
	
	self:WriteShort( FileObj:GetCompressionMethod() )
	self:WriteShort( FileObj:GetLastModificationTime() )
	self:WriteShort( FileObj:GetLastModificationDate() )
	
	self:WriteInt( FileObj:GetCRC32() )
	self:WriteInt( FileObj:GetCompressedSize() )
	self:WriteInt( FileObj:GetUncompressedSize() )
	
	local Path = FileObj:GetPath()
	local ExtraField = FileObj:GetExtraField()
	
	self:WriteShort( #Path )
	self:WriteShort( #ExtraField )
	
	self:WriteString( Path )
	self:WriteString( ExtraField )
	
	self:WriteString( FileObj:GetCompressedData() )
	
end

-- Data descriptor (Data)
Writers[0x08074b50] = function (self, Data)
	
	self:WriteInt( 0x08074b50 )
	self:WriteInt( Data:GetCRC32() )
	self:WriteInt( Data:GetCompressedSize() )
	self:WriteInt( Data:GetUncompressedSize() )
	
end

-- End of central directory record (EndOfDir)
Writers[0x06054b50] = function (self)
	
	local Disk = self:GetDisk()
	
	self:WriteInt( 0x06054b50 )
	self:WriteShort( Disk:GetNumber() )
	self:WriteShort( Disk:GetZipFile():GetFirstDisk():GetNumber() )
	self:WriteShort( Disk:GetNumberOfEntries() )
	self:WriteShort( Disk:GetZipFile():GetLastDisk():GetNumber() )
	self:WriteInt( self:GetCentralDirectorySize() )
	self:WriteInt( self:GetCentralDirectoryStart() )
	
	local Comment = Disk:GetComment()
	
	self:WriteShort( #Comment )
	self:WriteString( Comment )
	
end

return Writers