module("zip.Reader", package.seeall)

Object = require("zip.Object")
CentralFile = require("zip.CentralFile")
File = require("zip.File")
EndOfDir = require("zip.EndOfDir")
Readers = require("zip.Readers")

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
	
	self.Object = {}
	
	self:ReadSignatures()
	
	return self
	
end

function Reader:SetHandle(Handle)
	
	self.Handle = Handle
	
end

function Reader:GetFolderItems(Folder)
	
	if Folder == "/" then
		
		Folder = ""
		
	end
	
	local Items = {}
	
	for Path, Object in pairs(self.Object) do
		
		if Object:GetSource() == Folder then
			
			Items[ Object:GetName() ] = Object
			
		end
		
	end
	
	return Items
	
end

function Reader:ReadSignatures()
	
	while self:ReadAvail() >= 4 do
		
		local Signature	= self:ReadInt()
		local Function		= Readers[Signature]
		
		if Function then
			
			local Object = Function(self)
			
			if Object then
				
				if Object:typeOf(File) then
					
					if Object:typeOf(CentralFile) then
						
						local File = self.Object[ Object:GetPath() ]
						
						if File then
							
							if not File:SetCentralFile( Object ) then
								-- Corrupted file
								self.Object[ Object:GetPath() ] = nil
								
							end
							
						end
						
					else
						
						self.Object[ Object:GetPath() ] = Object
						
					end
					
				elseif Object:typeOf(EndOfDir) then
					
					break
					
				end
				
			end
			
		else
			
			print("no reader found for signature", Signature)
			
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