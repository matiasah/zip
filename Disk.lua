module("zip.Disk", package.seeall)

Object	= require("zip.Object")
Reader	= require("zip.Reader")
Writer	= require("zip.Writer")
File		= require("zip.File")

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

function Disk:read(Handle)
	
	if Handle then
		-- Reader's handle doesn't get automatically closed
		local self		= Disk:new()
		local Reader	= Reader:new(self, Handle)
		
		if Reader then
			
			Reader:ReadSignatures()
			
			return self
			
		end
		
	end
	
	return nil
	
end

function Disk:write(Handle)
	
	if Handle then
		
		local Writer	= Writer:new(self, Handle)
		
		if Writer then
			
			return Writer:WriteSignatures()
			
		end
		
	end
	
	return nil
	
end

function Disk:PushFolderEntries(Entries, Source)
	
	if Source == nil then
		
		Source = ""
		
	end
	
	while Source:sub(1, 1) == "/" do
		
		Source = Source:sub(2)
		
	end
	
	for Path, Entry in pairs(self.Entries) do
		
		if Entry:GetSource() == Source then
			
			Entries[ Entry:GetName() ] = Entry
			
		end
		
	end
	
end

function Disk:GetFolderEntries(Source)
	
	if Source == nil then
		
		Source = ""
		
	end
	
	while Source:sub(1, 1) == "/" do
		
		Source = Source:sub(2)
		
	end
	
	local Entries = {}
	
	for Path, Entry in pairs(self.Entries) do
		
		if Entry:GetSource() == Source then
			
			Entries[ Entry:GetName() ] = Entry
			
		end
		
	end
	
	return Entries
	
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

function Disk:GetEntryIterator()
	
	return pairs(self.Entries)
	
end

function Disk:GetEntry(Path)
	
	if Path then
		
		while Path:sub(1, 1) == "/" do
			
			Path = Path:sub(2)
			
		end
		
		return self.Entries[Path]
		
	end
	
end

function Disk:PutEntry(Entry)
	
	if Entry and Entry:GetPath() then
		
		while Entry:GetPath():sub(1, 1) == "/" do
			
			Entry:SetPath( Entry:GetPath():sub(2) )
			
		end
		
		self.Entries[ Entry:GetPath() ] = Entry
		
		local SourceFolder = Entry:GetSource() .. "/"
		
		if #SourceFolder > 1 then
			
			if not self.Entries[ SourceFolder ] then
				-- Folder does not exist, make one
				local newDir = File:new()
				
				newDir:SetPath( SourceFolder )
				newDir:SetDirectory( true )
				newDir:UpdateModificationTime( os.time() )
				
				self:PutEntry( newDir )
				
			end
			
		end
		
		return true
		
	end
	
	return false
	
end

function Disk:RemoveEntry(Path)
	
	if Path then
		
		while Path:sub(1, 1) == "/" do
			
			Path = Path:sub(2)
			
		end
		
		local Entry = self.Entries[Path]
		
		self.Entries[Path] = nil
		
		return Entry
		
	end
	
	return nil
	
end

function Disk:SetComment(Comment)
	
	self.Comment = Comment
	
end

function Disk:GetComment()
	
	return self.Comment
	
end

function Disk:SetArchive(Archive)
	
	self.Archive = Archive
	
end

function Disk:GetArchive()
	
	return self.Archive
	
end

function Disk:GetNumberOfEntries()
	
	local Entries = 0
	
	for Path, Entry in pairs(self.Entries) do
		
		Entries = Entries + 1
		
	end
	
	return Entries
	
end

return Disk