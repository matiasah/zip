module("zip.EndOfDir", package.seeall)

Entry = require("zip.Entry")

EndOfDir = setmetatable( {}, Entry )
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

function EndOfDir:SetDiskEntries(DiskEntries)
	
	self.DiskEntries = DiskEntries
	
end

function EndOfDir:GetDiskEntries()
	
	return self.DiskEntries
	
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

function EndOfDir:SetOffset(Offset)
	
	self.Offset = Offset
	
end

function EndOfDir:GetOffset()
	
	return self.Offset
	
end

function EndOfDir:SetComment(Comment)
	
	self.Comment = Comment
	
end

function EndOfDir:GetComment()
	
end

return EndOfDir