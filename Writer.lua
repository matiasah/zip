module("zip.Writer", package.seeall)

Object = require("zip.Object")

Writer = setmetatable( {}, Object )
Writer.__index = Writer
Writer.__type = "Writer"

function Writer:new(ZipFile, Handle)
	
	local self = setmetatable( {}, Writer )
	
	if type(Handle) == "string" then
		
		self.Handle = love.filesystem.newFile(Handle, "w")
		
	else
		
		self.Handle = Handle
		
	end
	
	self.ZipFile			= ZipFile
	self.BytesWritten		= 0
	
	return self
	
end

function Writer:WriteSignatures()
	
	local Objects = self.ZipFile:GetObjects()
	
	for Path, Object in pairs(Objects) do
		
		-- Write local header
		
	end
	
	for Path, Object in pairs(Objects) do
		
		-- Write central file header
		
	end
	
	-- Write end of directories
	
	return true
	
end

function Writer:Tell()
	
	return self.BytesWritten
	
end

function Writer:Write(String)
	
	self.Handle:write(String)
	self.BytesWritten = self.BytesWritten + #String
	
end

function Writer:WriteString(String)
	
	self:Write(String)
	
end

function Writer:WriteByte(Byte)
	
	self:Write( string.char(Byte) )
	
end

function Writer:WriteShort(Number)
	
	local Byte1 = Number % 256
	local Byte2 = ( Number - Byte1 ) / 256
	
	self:Write( string.char(Byte1) .. string.char(Byte2) )
	
end

function Writer:WriteInt(Number)
	
	local Byte1 = Number % 256; Number = ( Number - Byte1 ) / 256
	local Byte2 = Number % 256; Number = ( Number - Byte2 ) / 256
	local Byte3 = Number % 256
	local Byte4 = ( Number - Byte3 ) / 256
	
	self:Write( string.char(Byte1) .. string.char(Byte2) .. string.char(Byte3) .. string.char(Byte4) )
	
end

function Writer:WriteBits(Bits, n)
	
	for i = 1, math.ceil( n * 0.125 ) do
		
		local Byte	= 0
		local n		= 1
		
		for j = 1, 8 do
			
			if Bits[ ( i - 1 ) * 8 + j ] then
				
				Byte = Byte + n
				
			end
			
			n = n * 2
			
		end
		
		self:Write( Byte )
		
	end
	
end

return Writer