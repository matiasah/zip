module("zip.EndOfDir", package.seeall)

ReaderObject = require("zip.ReaderObject")

EndOfDir = setmetatable( {}, ReaderObject )
EndOfDir.__index = EndOfDir
EndOfDir.__type = "EndOfDir"

function EndOfDir:new()
	
	return setmetatable( {}, EndOfDir )
	
end

function EndOfDir:__tostring()
	
	return "EndOfDir (zip)"
	
end

function EndOfDir:SetDiskNumber(DiskNumber)
	
	self.DiskNumber = DiskNumber
	
end

function EndOfDir:GetDiskNumber()
	
	return self.DiskNumber
	
end

function EndOfDir:SetDiskStart(DiskStart)
	
	self.DiskStart = DiskStart
	
end

function EndOfDir:GetDiskStart()
	
	return self.DiskStart
	
end

function EndOfDir:SetDiskRecord(DiskRecord)
	
	self.DiskRecord = DiskRecord
	
end

function EndOfDir:GetDiskRecord()
	
	return self.DiskRecord
	
end

function EndOfDir:SetDiskTotal(DiskTotal)
	
	self.DiskTotal = DiskTotal
	
end

function EndOfDir:GetDiskTotal()
	
	return self.DiskTotal
	
end

function EndOfDir:SetSize(Size)
	
	self.Size = Size
	
end

function EndOfDir:GetSize()
	
	return self.Size
	
end

function EndOfDir:SetComment(Comment)
	
	self.Comment = Comment
	
end

return EndOfDir