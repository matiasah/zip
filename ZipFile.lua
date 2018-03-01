module("zip.ZipFile", package.seeall)

Object = require("zip.Object")
Reader = require("zip.Reader")

ZipFile = setmetatable( {}, Object )
ZipFile.__index = ZipFile
ZipFile.__type = "ZipFile"

function ZipFile:new()
	
	local self = setmetatable( {}, ZipFile)
	
	self.Objects = {}
	
	return self
	
end

function ZipFile:read(Handle)
	
	if Handle then
		
		local self = ZipFile:new()
		
		self.Reader = Reader:new( self, Handle )
		self.Reader:ReadSignatures()
		
		return self
		
	end
	
end

function ZipFile:write(Handle)
	
	if Handle then
		
		local newWriter = Writer:new( self, Handle )
		
		return newWriter:WriteSignatures()
		
	end
	
	return false
	
end

function ZipFile:GetFolderItems(Folder)
	
	if Folder == "/" then
		
		Folder = ""
		
	end
	
	local Items = {}
	
	for Path, Object in pairs(self.Objects) do
		
		if Object:GetSource() == Folder then
			
			Items[ Object:GetName() ] = Object
			
		end
		
	end
	
	return Items
	
end

function ZipFile:GetReader()
	
	return self.Reader
	
end

function ZipFile:GetObjects()
	
	return self.Objects
	
end

return ZipFile