module("zip.CentralFile", package.seeall)

File = require("zip.File")

CentralFile = setmetatable( {}, File )
CentralFile.__index = CentralFile
CentralFile.__type = "CentralFile"

function CentralFile:new()
	
	return setmetatable( {}, CentralFile )
	
end

function CentralFile:SetVersion(Version)
	
	self.Version = Version
	
end

function CentralFile:GetVersion()
	
	return self.Version
	
end

function CentralFile:SetDiskNumber(DiskNumber)
	
	self.DiskNumber = DiskNumber
	
end

function CentralFile:GetDiskNumber()
	
	return self.DiskNumber
	
end

function CentralFile:SetComment(Comment)
	
	self.Comment = Comment
	
end

function CentralFile:GetComment()
	
	return self.Comment
	
end

function CentralFile:SetInternalAttributes(InternalAttributes)
	
	self.InternalAttributes = InternalAttributes
	
end

function CentralFile:GetInternalAttributes()
	
	return self.InternalAttributes
	
end

function CentralFile:SetExternalAttributes(ExternalAttributes)
	
	self.ExternalAttributes = ExternalAttributes
	
end

function CentralFile:GetExternalAttributes()
	
	return self.ExternalAttributes
	
end

return CentralFile