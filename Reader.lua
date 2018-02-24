module("zip.Reader", package.seeall)

Object = require("zip.Object")
Readers = require("zip.Readers")
EndOfDir = require("zip.EndOfDir")
File = require("zip.File")

Reader = setmetatable( {}, Object )
Reader.__index = Reader
Reader.__type = "Reader"

function Reader:new(Handle)
	
	local self = setmetatable( {}, Reader)
	
	if type(Handle) == "string" then
		
		self:SetHandle( love.filesystem.newFile(Handle, "r") )
		
	else
		
		self:SetHandle( Handle )
		
	end
	
	self:ReadSignatures()
	
	return self
	
end

function Reader:SetHandle(Handle)
	
	self.Handle = Handle
	
end

function Reader:GetFolderItems(Folder)
	
	if #Folder == 0 or Folder == "/" then
		
		return self.Folder
		
	end
	
	local SubFolder = self.Folder
	
	for Name in Folder:gmatch("([^/]+)") do
		
		if SubFolder[Name] then
			
			SubFolder = SubFolder[Name]
			
		else
			
			return {}
			
		end
		
	end
	
	return SubFolder
	
end

function Reader:ReadSignatures()
	
	self.Folder = {}
	
	while self:ReadAvail() >= 4 do
		
		local Signature = self:ReadInt()
		local Function = Readers[Signature]
		
		if Function then
			
			local Object = Function(self)
			
			if Object:typeOf(File) then
				
				-- A file object
				if not Object.Folder then
					
					-- Folders are considered file objects too
					
					local SubFolder = self.Folder
					
					for _, FolderName in pairs(Object.Folders) do
						
						if not SubFolder[FolderName] then
							
							SubFolder[FolderName] = {}
							
						end
						
						SubFolder = SubFolder[FolderName]
						
					end
					
					SubFolder[Object.Name] = Object
					
				end
				
			elseif Object:typeOf(EndOfDir) then
				
			end
			
		end
		
	end
	
end

function Reader:Seek(Position)
	
	return self.Handle:seek(Position) --self.Handle:seek("set", Position)
	
end

function Reader:GetSize()
	
	return self.Handle:getSize() --self.Size
	
end

function Reader:Tell()
	
	return self.Handle:tell() --self.Handle:seek("cur", 0)
	
end

function Reader:ReadAvail()
	
	return self:GetSize() - self:Tell()
	
end

function Reader:ReadString(Length)
	
	return self.Handle:read(Length)
	
end

function Reader:ReadByte()
	
	return self.Handle:read(1):byte()
	
end

function Reader:ReadShort()
	
	return self:ReadByte() + self:ReadByte() * 256
	
end

function Reader:ReadInt()
	
	return self:ReadByte() + 256 * ( self:ReadByte() + 256 * ( self:ReadByte() + self:ReadByte() * 256 ) )
	
end

function Reader:ReadBits(Bits)
	
	local BitArray = {}
	
	for i = 1, math.ceil(Bits / 8) do
		
		local Byte = self:ReadByte()
		local Bit = 128
		
		for b = 8, 1, -1 do
			
			BitArray[(i - 1) * 8 + b] = Byte >= Bit
			
			if Byte >= Bit then
				
				Byte = Byte - Bit
				
			end
			
			Bit = Bit * 0.5
			
		end
		
	end
	
	return BitArray
	
end

return Reader