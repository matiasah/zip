module("zip.File", package.seeall)

Object = require("zip.Object")
Decompressors = require("zip.Decompressors")

File = setmetatable( {}, Object )
File.__index = File
File.__type = "File"

function File:new()
	
	local self = setmetatable( {}, File )
	
	return self
	
end

function File:__tostring()
	
	return "File (zip): " .. self:GetPath()
	
end

function File:SetDirectory(Directory)
	
	self.Directory = Directory
	
end

function File:GetDirectory()
	
	return self.Directory
	
end

function File:SetVersion(Version)
	
	self.Version = Version
	
end

function File:GetVersion()
	
	return self.Version
	
end

function File:SetVersionNeeded(VersionNeeded)
	
	self.VersionNeeded = VersionNeeded
	
end

function File:GetVersionNeeded()
	
	return self.VersionNeeded
	
end

function File:SetBitFlags(BitFlags)
	
	self.BitFlags = BitFlags
	
end

function File:SetCompressionMethod(CompressionMethod)
	
	self.CompressionMethod = CompressionMethod
	
end

function File:SetLastModificationTime(LastModificationTime)
	
	self.LastModificationTime = LastModificationTime
	
end

function File:GetLastModificationTime()
	
	return self.LastModificationTime
	
end

function File:SetLastModificationDate(LastModificationDate)
	
	self.LastModificationDate = LastModificationDate
	
end

function File:GetLastModificationDate()
	
	return self.LastModificationDate
	
end

function File:SetCRC32(CRC32)
	
	self.CRC32 = CRC32
	
end

function File:GetCRC32()
	
	return self.CRC32
	
end

function File:SetCompressedSize(CompressedSize)
	
	self.CompressedSize = CompressedSize
	
end

function File:GetCompressedSize()
	
	return self.CompressedSize
	
end

function File:SetUncompressedSize(UncompressedSize)
	
	self.UncompressedSize = UncompressedSize
	
end

function File:GetUncompressedSize()
	
	return self.UncompressedSize
	
end

function File:SetDiskNumber(DiskNumber)
	
	self.DiskNumber = DiskNumber
	
end

function File:GetDiskNumber()
	
	return self.DiskNumber
	
end

function File:SetInternalAttributes(InternalAttributes)
	
	self.InternalAttributes = InternalAttributes
	
end

function File:GetInternalAttributes()
	
	return self.InternalAttributes
	
end

function File:SetExternalAttributes(ExternalAttributes)
	
	self.ExternalAttributes = ExternalAttributes
	
end

function File:GetExternalAttributes()
	
	return self.ExternalAttributes
	
end

function File:SetRelativeOffset(RelativeOffset)
	
	self.RelativeOffset = RelativeOffset
	
end

function File:GetRelativeOffset()
	
	return self.RelativeOffset
	
end

function File:SetPath(Path)
	
	self.Path = Path
	
end

function File:GetPath()
	
	return self.Path
	
end

function File:SetName(Name)
	
	self.Name = Name
	
end

function File:GetName()
	
	return self.Name
	
end

function File:GetSource()
	
	return table.concat(self.Folders, "/")
	
end

function File:SetExtraField(ExtraField)
	
	self.ExtraField = ExtraField
	
end

function File:GetExtraField()
	
	return self.ExtraField
	
end

function File:SetComment(Comment)
	
	self.Comment = Comment
	
end

function File:GetComment()
	
	return self.Comment
	
end

function File:SetFolders(Folders)
	
	self.Folders = Folders
	
end

function File:GetFolders()
	
	return self.Folders
	
end

function File:Decompress()
	
	local Method = Decompressors[self.CompressionMethod]
	
	if Method then
		
		return Method(self)
		
	end
	
	return false
	
end

return File