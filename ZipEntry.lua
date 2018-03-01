module("zip.ZipEntry", package.seeall)

Object = require("zip.Object")

ZipEntry = setmetatable( {}, Object )
ZipEntry.__index = ZipEntry
ZipEntry.__type = "ZipEntry"

function ZipEntry:SetReader(Reader)
	
	self.Reader = Reader
	
end

function ZipEntry:GetReader()
	
	return self.Reader
	
end

function ZipEntry:SetRelativeOffset(RelativeOffset)
	
	self.RelativeOffset = RelativeOffset
	
end

function ZipEntry:GetRelativeOffset()
	
	return self.RelativeOffset
	
end

function ZipEntry:SetDataOffset(DataOffset)
	
	self.DataOffset = DataOffset
	
end

function ZipEntry:GetDataOffset()
	
	return self.DataOffset
	
end

function ZipEntry:SetUncompressedSize(UncompressedSize)
	
	self.UncompressedSize = UncompressedSize
	
end

function ZipEntry:GetUncompressedSize()
	
	return self.UncompressedSize
	
end

function ZipEntry:SetCompressedSize(CompressedSize)
	
	self.CompressedSize = CompressedSize
	
end

function ZipEntry:GetCompressedSize()
	
	return self.CompressedSize
	
end

function ZipEntry:GetCompressedData()
	
	if self.DataOffset then
		
		self.Reader:Seek( self.DataOffset )
		
		return self.Reader:ReadString( self.CompressedSize )
		
	end
	
	return ""
	
end

return ZipEntry