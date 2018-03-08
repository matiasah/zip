module("zip.Reader", package.seeall)

Object			= require("zip.Object")
EndOfDir			= require("zip.EndOfDir")
File				= require("zip.File")
Readers			= require("zip.Readers")

Reader = setmetatable( {}, Object )
Reader.__index = Reader
Reader.__type = "Reader"

function Reader:new(DiskObj, Handle)
	
	local self = setmetatable( {}, Reader )
	
	if type(Handle) == "string" then
		
		self.Handle = love.filesystem.newFile(Handle, "r")
		
	else
		
		self.Handle = Handle
		
	end
	
	self.Disk = DiskObj
	
	return self
	
end

function Reader:ReadSignatures()
	
	local Entries = self.Disk:GetEntries()
	
	while self:ReadAvail() >= 4 do
		
		local Signature	= self:ReadInt()
		local Function		= Readers[Signature]
		
		if Function then
			
			local Entry = Function(self)
			
			if Entry then
				
				if Entry:typeOf(File) then
					
					Entries[ Entry:GetPath() ] = Entry
					
				end
				
			end
			
		else
			
			error("No reader found for signature ".. Signature)
			
		end
		
	end
	
end

function Reader:GetDisk()
	
	return self.Disk
	
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
	
	local Byte = self.Handle:read(1)
	
	if Byte and #Byte > 0 then
		
		return Byte:byte()
		
	end
	
	return 0
	
end

function Reader:ReadShort()
	
	return self:ReadByte() + self:ReadByte() * 256
	
end

function Reader:ReadInt()
	
	return self:ReadByte() + self:ReadByte() * 256 + self:ReadByte() * 65536 + self:ReadByte() * 16777216
	
end

function Reader:ReadBits(Bits)
	
	local BitArray = {}
	
	for i = 1, math.ceil( Bits * 0.125 ) do
		
		local Byte = self:ReadByte()
		local Bit = 128
		
		for b = 8, 1, -1 do
			
			BitArray[ (i - 1) * 8 + ( b - 1 ) ] = Byte >= Bit
			
			if Byte >= Bit then
				
				Byte = Byte - Bit
				
			end
			
			Bit = Bit * 0.5
			
		end
		
	end
	
	return BitArray
	
end

return Reader