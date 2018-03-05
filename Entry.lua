module("zip.Entry", package.seeall)

Object = require("zip.Object")

Entry = setmetatable( {}, Object )
Entry.__index = Entry
Entry.__type = "Entry"

function Entry:SetReader(Reader)
	
	self.Reader = Reader
	
end

function Entry:GetReader()
	
	return self.Reader
	
end

function Entry:SetRelativeOffset(RelativeOffset)
	
	self.RelativeOffset = RelativeOffset
	
end

function Entry:GetRelativeOffset()
	
	return self.RelativeOffset
	
end

function Entry:SetDataOffset(DataOffset)
	
	self.DataOffset = DataOffset
	
end

function Entry:GetDataOffset()
	
	return self.DataOffset
	
end

function Entry:SetUncompressedSize(UncompressedSize)
	
	self.UncompressedSize = UncompressedSize
	
end

function Entry:GetUncompressedSize()
	
	return self.UncompressedSize
	
end

function Entry:SetCompressedSize(CompressedSize)
	
	self.CompressedSize = CompressedSize
	
end

function Entry:GetCompressedSize()
	
	return self.CompressedSize
	
end

function Entry:GetCompressedData()
	
	if self.DataOffset then
		
		self.Reader:Seek( self.DataOffset )
		
		return self.Reader:ReadString( self.CompressedSize )
		
	end
	
	return ""
	
end

return Entry