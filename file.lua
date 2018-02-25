module("zip.File", package.seeall)

ReaderObject = require("zip.ReaderObject")
Decompressors = require("zip.Decompressors")

File = setmetatable( {}, ReaderObject )
File.__index = File
File.__type = "File"

function File:new()
	
	return setmetatable( {}, File )
	
end

function File:__tostring()
	
	if self:GetDirectory() then
		
		return "Directory (zip): " .. self:GetPath()
		
	end
	
	return "File (zip): " .. self:GetPath()
	
end

function File:SetCentralFile(CentralFile)
	
	if CentralFile:GetDirectory() ~= self:GetDirectory() then
		return false
	end
	
	self.CentralFile = CentralFile
	
	return true
	
end

function File:GetCentralFile()
	
	return self.CentralFile
	
end

function File:SetDirectory(Directory)
	
	self.Directory = Directory
	
end

function File:GetDirectory()
	
	return self.Directory
	
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

function File:SetFolders(Folders)
	
	self.Folders = Folders
	
end

function File:GetFolders()
	
	return self.Folders
	
end

function File:GetData()
	
	local Decompressor = Decompressors[self.CompressionMethod]
	
	if Decompressor then
		
		return Decompressor(self)
		
	end
	
	return nil
	
end

function File:Open()
	
	local newFileData = self:GetData()
	
	if newFileData then
		
		return love.filesystem.newFile(newFileData, "r")
		
	end
	
	return nil
	
end

return File