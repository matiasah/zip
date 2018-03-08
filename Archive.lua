module("zip.Archive", package.seeall)

Object		= require("zip.Object")
Reader		= require("zip.Reader")
Disk			= require("zip.Disk")

Archive = setmetatable( {}, Object )
Archive.__index = Archive
Archive.__type = "Archive"

function Archive:new()
	
	local self = setmetatable( {}, Archive)
	
	self.Disk = {}
	
	return self
	
end

-- Static method, use Archive:read("file") (not self:read("file"))
function Archive:read(Handle)
	
	if Handle then
		
		local self		= Archive:new()
		local newDisk	= Disk:read(Handle)
		
		if newDisk then
			
			self:AddDisk( newDisk )
			
			return self
			
		end
		
	end
	
	return nil
	
end

function Archive:write(Handle, Index)
	
	if Handle then
		
		local DiskObj
		
		if Index then
			
			DiskObj = self.Disk[Index]
			
		else
			
			DiskObj = self:GetFirstDisk()
			
		end
		
		if DiskObj then
			
			return DiskObj:write(Handle)
			
		end
		
	end
	
	return false
	
end

function Archive:load(Handle)
	
	if Handle then
		
		local newDisk = Disk:read(Handle)
		
		if newDisk then
			
			self:AddDisk( newDisk )
			
			return newDisk
			
		end
		
	end
	
	return nil
	
end

function Archive:GetFolderEntries(Folder)
	
	local Entries = {}
	
	for Index, DiskObj in pairs(self.Disk) do
		
		DiskObj:PushFolderEntries(Entries, Folder)
		
	end
	
	return Entries
	
end

function Archive:GetEntry(Path)
	
	for Index, DiskObj in pairs(self.Disk) do
		
		local Entry = DiskObj:GetEntry(Path)
		
		if Entry then
			
			return Entry
			
		end
		
	end
	
	return nil
	
end

function Archive:GetDiskIterator()
	
	return pairs(self.Disk)
	
end

function Archive:AddDisk(DiskObj)
	
	local Index = 0
	
	if self.Disk[Index] then
		
		Index = #self.Disk + 1
		
	end
	
	-- Disk number is it's index minus one
	DiskObj:SetNumber( Index )
	DiskObj:SetArchive(self)
	
	self.Disk[Index] = DiskObj
	
	return Index
	
end

function Archive:RemoveDisk(Index)
	
	local Disk = self.Disk[Index]
	
	for i = Index, #self.Disk do
		
		local Aux = self.Disk[i + 1]
		
		if Aux then
			
			Aux:SetNumber( i )
			
		end
		
		self.Disk[i] = Aux
		
	end
	
	return Disk
	
end

function Archive:GetDisk(Index)
	
	return self.Disk[Index]
	
end

function Archive:GetFirstDisk()
	
	local Index, DiskObj = next(self.Disk)
	
	return DiskObj
	
end

function Archive:GetNumberOfEntries()
	
	local Entries = 0
	
	for Index, DiskObj in pairs(self.Disk) do
		
		Entries = Entries + DiskObj:GetNumberOfEntries()
		
	end
	
	return Entries
	
end

return Archive