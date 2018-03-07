module("zip.Writers", package.seeall)

Object = require("zip.Object")

Writers = setmetatable( {}, Object )
Writers.__index = Writers
Writers.__type = "Writers"

function Writers:SetBitFlags(FileObj)
	
	local BitFlags = FileObj:GetBitFlags()
	
	-- Not encrypted
	BitFlags[0] = false
	
	-- Normal compression
	BitFlags[1] = false
	BitFlags[2] = false
	
	-- Not using data descriptor
	BitFlags[3] = false
	
	-- Not using enhanced deflate
	BitFlags[4] = false
	
	-- Not compressed patched data
	BitFlags[5] = false
	
	-- Not using encryption
	BitFlags[6] = false
	
	-- Currently unused
	for i = 7, 10 do
		
		BitFlags[i] = false
		
	end
	
	-- No language encoding flag
	BitFlags[11] = false
	
	-- Not used
	BitFlags[13] = false
	
	-- Reserved by PKWARE
	BitFlags[14] = false
	BitFlags[15] = false
	
end

-- Central file header (CentralFile)
Writers[0x02014b50] = function (self, FileObj)
	
	self:WriteInt( 0x02014b50 )
	
	local Disk = self:GetDisk()
	
	Writers:SetBitFlags( FileObj )
	
	self:WriteShort( FileObj:GetVersion() )
	self:WriteShort( FileObj:GetVersionNeeded() )
	self:WriteBits( FileObj:GetBitFlags(), 16 )
	
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
	
	Writers:SetBitFlags(FileObj)
	
	self:WriteShort( FileObj:GetVersionNeeded() )
	self:WriteBits( FileObj:GetBitFlags(), 16 )
	
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
	local Archive = Disk:GetArchive()
	
	self:WriteInt( 0x06054b50 )
	self:WriteShort( Disk:GetNumber() )
	self:WriteShort( Archive:GetFirstDisk():GetNumber() )
	self:WriteShort( Disk:GetNumberOfEntries() )
	self:WriteShort( Archive:GetNumberOfEntries() )
	self:WriteInt( self:GetCentralDirectorySize() )
	self:WriteInt( self:GetCentralDirectoryStart() )
	
	local Comment = Disk:GetComment()
	
	self:WriteShort( #Comment )
	self:WriteString( Comment )
	
end

return Writers