module("zip.Disk", package.seeall)

Object = require("zip.Object")

Disk = setmetatable( {}, Object )
Disk.__index = Disk
Disk.__type = "Disk"

Disk.Number		= 0
Disk.Comment	= ""

function Disk:new()
	
	local self = setmetatable( {}, Disk )
	
	self.Entries	= {}
	
	return self
	
end

function Disk:PushFolderEntries(Entries, Source)
	
	for Path, Entry in pairs(self.Entries) do
		
		if Entry:GetSource() == Source then
			
			Entries[ Entry:GetName() ] = Entry
			
		end
		
	end
	
end

function Disk:SetNumber(Number)
	
	self.Number = Number
	
end

function Disk:GetNumber()
	
	return self.Number
	
end

function Disk:GetEntries()
	
	return self.Entries
	
end

function Disk:GetEntry(Path)
	
	while Path:sub(1, 1) == "/" do
		
		Path = Path:sub(2)
		
	end
	
	return self.Entries[Path]
	
end

function Disk:SetComment(Comment)
	
	self.Comment = Comment
	
end

function Disk:GetComment()
	
	return self.Comment
	
end

function Disk:SetZipFile(ZipFile)
	
	self.ZipFile = ZipFile
	
end

function Disk:GetZipFile()
	
	return self.ZipFile
	
end

function Disk:GetNumberOfEntries()
	
	local Entries = 0
	
	for Path, Entry in pairs(self.Entries) do
		
		Entries = Entries + 1
		
	end
	
	return Entries
	
end

return Disk