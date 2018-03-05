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

function Archive:GetFolderEntries(Folder)
	
	local Entries = {}
	
	for Index, DiskObj in pairs(self.Disk) do
		
		DiskObj:PushFolderEntries(Entries, Folder)
		
	end
	
	return Entries
	
end

function Archive:GetDiskIterator()
	
	return pairs(self.Disk)
	
end

function Archive:AddDisk(DiskObj)
	
	local Index = #self.Disk + 1
	
	-- Disk number is it's index minus one
	DiskObj:SetNumber( Index - 1 )
	DiskObj:SetZipFile(self)
	
	self.Disk[Index] = DiskObj
	
	return Index
	
end

function Archive:RemoveDisk(Index)
	
	for i = Index, #self.Disk do
		
		local Aux = self.Disk[Index + 1]
		
		Aux:SetNumber( i - 1 )
		
		self.Disk[Index] = Aux
		
	end
	
end

function Archive:GetFirstDisk()
	
	local Index, DiskObj = next(self.Disk)
	
	return DiskObj
	
end

function Archive:GetLastDisk()
	
	return self.Disk[#self.Disk]
	
end

return Archive