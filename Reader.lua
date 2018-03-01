module("zip.Reader", package.seeall)

Object = require("zip.Object")
CentralFile = require("zip.CentralFile")
File = require("zip.File")
Readers = require("zip.Readers")

Reader = setmetatable( {}, Object )
Reader.__index = Reader
Reader.__type = "Reader"

function Reader:new(ZipFile, Handle)
	
	local self = setmetatable( {}, Reader )
	
	if type(Handle) == "string" then
		
		self.Handle = love.filesystem.newFile(Handle, "r")
		
	else
		
		self.Handle = Handle
		
	end
	
	self.ZipFile = ZipFile
	
	return self
	
end

function Reader:ReadSignatures()
	
	local Objects = self.ZipFile:GetObjects()
	
	while self:ReadAvail() >= 4 do
		
		local Signature	= self:ReadInt()
		local Function		= Readers[Signature]
		
		if Function then
			
			local Entry = Function(self)
			
			if Entry then
				
				if Entry:typeOf(File) then
					
					if Entry:typeOf(CentralFile) then
						
						local File = Objects[ Entry:GetPath() ]
						
						if File then
							
							if not File:SetCentralFile( Entry ) then
								-- Corrupted file
								Objects[ Entry:GetPath() ] = nil
								
							end
							
						end
						
					else
						
						Objects[ Entry:GetPath() ] = Entry
						
					end
					
				end
				
			end
			
		else
			
			error("No reader found for signature ".. Signature)
			
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
	
	for i = 1, math.ceil( Bits * 0.125 ) do
		
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