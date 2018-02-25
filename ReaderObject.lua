module("zip.ReaderObject", package.seeall)

Object = require("zip.Object")

ReaderObject = setmetatable( {}, Object )
ReaderObject.__index = ReaderObject
ReaderObject.__type = "ReaderObject"

function ReaderObject:SetReader(Reader)
	
	self.Reader = Reader
	
end

function ReaderObject:GetReader()
	
	return self.Reader
	
end

function ReaderObject:SetHeaderOffset(HeaderOffset)
	
	self.HeaderOffset = HeaderOffset
	
end

function ReaderObject:GetHeaderOffset()
	
	return self.HeaderOffset
	
end

function ReaderObject:SetRelativeOffset(RelativeOffset)
	
	self.RelativeOffset = RelativeOffset
	
end

function ReaderObject:GetRelativeOffset()
	
	return self.RelativeOffset
	
end

function ReaderObject:SetUncompressedSize(UncompressedSize)
	
	self.UncompressedSize = UncompressedSize
	
end

function ReaderObject:GetUncompressedSize()
	
	return self.UncompressedSize
	
end

function ReaderObject:SetCompressedSize(CompressedSize)
	
	self.CompressedSize = CompressedSize
	
end

function ReaderObject:GetCompressedSize()
	
	return self.CompressedSize
	
end

function ReaderObject:SetCompressedData(CompressedData)
	
	self.CompressedData = CompressedData
	
end

function ReaderObject:GetCompressedData()
	
	return self.CompressedData
	
end

return ReaderObject