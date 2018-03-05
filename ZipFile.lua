module("zip.ZipFile", package.seeall)

Object		= require("zip.Object")
Reader		= require("zip.Reader")
Disk			= require("zip.Disk")

ZipFile = setmetatable( {}, Object )
ZipFile.__index = ZipFile
ZipFile.__type = "ZipFile"

function ZipFile:new()
	
	local self = setmetatable( {}, ZipFile)
	
	self.Disk = {}
	
	return self
	
end

function ZipFile:read(Handle)
	
	if Handle then
		
		local self		= ZipFile:new()
		local newDisk	= Disk:read(Handle)
		
		if newDisk then
			
			self:AddDisk( newDisk )
			
			return self
			
		end
		
	end
	
	return nil
	
end

function ZipFile:write(Handle, Index)
	
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

function ZipFile:GetFolderEntries(Folder)
	
	local Entries = {}
	
	for Index, DiskObj in pairs(self.Disk) do
		
		DiskObj:PushFolderEntries(Entries, Folder)
		
	end
	
	return Entries
	
end

function ZipFile:GetDiskIterator()
	
	return pairs(self.Disk)
	
end

function ZipFile:AddDisk(DiskObj)
	
	local Index = #self.Disk + 1
	
	DiskObj:SetNumber(Index)
	DiskObj:SetZipFile(self)
	
	self.Disk[Index] = DiskObj
	
	return Index
	
end

function ZipFile:RemoveDisk(Index)
	
	for i = Index, #self.Disk do
		
		local Aux = self.Disk[Index + 1]
		
		Aux:SetNumber( i )
		
		self.Disk[Index] = Aux
		
	end
	
end

function ZipFile:GetFirstDisk()
	
	local Index, DiskObj = next(self.Disk)
	
	return DiskObj
	
end

function ZipFile:GetLastDisk()
	
	return self.Disk[#self.Disk]
	
end

return ZipFile