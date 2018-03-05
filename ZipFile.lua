module("zip.ZipFile", package.seeall)

Object		= require("zip.Object")
Reader		= require("zip.Reader")
Disk			= require("zip.Disk")
Writer		= require("zip.Writer")

ZipFile = setmetatable( {}, Object )
ZipFile.__index = ZipFile
ZipFile.__type = "ZipFile"

function ZipFile:new()
	
	local self = setmetatable( {}, ZipFile)
	
	self.Disk = {}
	
	self:AddDisk( Disk:new() )
	
	return self
	
end

function ZipFile:read(Handle)
	
	if Handle then
		
		local self			= ZipFile:new()
		local newReader	= Reader:new( self.Disk[1], Handle )
		
		newReader:ReadSignatures()
		
		return self
		
	end
	
end

function ZipFile:write(Handle)
	
	if Handle then
		
		local newWriter = Writer:new( self.Disk[1], Handle )
		
		return newWriter:WriteSignatures()
		
	end
	
	return false
	
end

function ZipFile:GetFolderEntries(Folder)
	
	if Folder == "/" then
		
		Folder = ""
		
	end
	
	local Entries = {}
	
	for Index, DiskObj in pairs(self.Disk) do
		
		DiskObj:PushFolderEntries(Entries, Folder)
		
	end
	
	return Entries
	
end

function ZipFile:AddDisk(DiskObj)
	
	local Index = #self.Disk + 1
	
	DiskObj:SetNumber(Index)
	DiskObj:SetZipFile(self)
	
	self.Disk[Index] = DiskObj
	
end

function ZipFile:GetFirstDisk()
	
	local Index, DiskObj = next(self.Disk)
	
	return DiskObj
	
end

function ZipFile:GetLastDisk()
	
	return self.Disk[#self.Disk]
	
end

return ZipFile