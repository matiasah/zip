module("zip.Writer", package.seeall)

Object = require("zip.Object")
Writers = require("zip.Writers")

Writer = setmetatable( {}, Object )
Writer.__index = Writer
Writer.__type = "Writer"

Writer.BytesWritten				= 0
Writer.CentralDirectorySize	= 0
Writer.CentralDirectoryStart	= 0

function Writer:new(DiskObj, Handle)
	
	local self = setmetatable( {}, Writer )
	
	if type(Handle) == "string" then
		
		self.Handle = love.filesystem.newFile(Handle, "w")
		
	else
		
		self.Handle = Handle
		
	end
	
	self.Disk = DiskObj
	
	return self
	
end

function Writer.EntrySorter(EntryA, EntryB)
	
	return EntryA:GetPath() < EntryB:GetPath()
	
end

function Writer:WriteSignatures()
	
	local EntryMap = self.Disk:GetEntries()
	local Entries = {}
	
	-- Get all entries and put them into an array
	for Index, Entry in pairs(EntryMap) do
		Entries[#Entries + 1] = Entry
	end
	
	-- Sort the array by the entries path
	table.sort(Entries, self.EntrySorter)
	
	-- Write every file and their content
	for Index, Entry in pairs(Entries) do
		
		-- Write local header
		Writers[0x04034b50](self, Entry)
		
	end
	
	self:SetCentralDirectoryStart( self:Tell() )
	
	for Index, Entry in pairs(Entries) do
		
		-- Write central file header
		Writers[0x02014b50](self, Entry)
		
	end
	
	-- Write end of directories
	Writers[0x06054b50](self)
	
	self.Handle:close()
	
	return true
	
end

function Writer:SetCentralDirectorySize(CentralDirectorySize)
	
	self.CentralDirectorySize = CentralDirectorySize
	
end

function Writer:GetCentralDirectorySize()
	
	return self.CentralDirectorySize
	
end

function Writer:SetCentralDirectoryStart(CentralDirectoryStart)
	
	self.CentralDirectoryStart = CentralDirectoryStart
	
end

function Writer:GetCentralDirectoryStart()
	
	return self.CentralDirectoryStart
	
end

function Writer:GetDisk()
	
	return self.Disk
	
end

function Writer:Tell()
	
	return self.BytesWritten
	
end

function Writer:Write(String)
	
	self.Handle:write( String )
	self.BytesWritten = self.BytesWritten + #String
	
end

function Writer:WriteString(String)
	
	self:Write( String )
	
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
	
	local BinaryString = ""
	
	for i = 1, math.ceil( n * 0.125 ) do
		
		local Byte	= 0
		local n		= 1
		
		for j = 1, 8 do
			
			if Bits[ ( i - 1 ) * 8 + ( j - 1 ) ] then
				
				Byte = Byte + n
				
			end
			
			n = n * 2
			
		end
		
		BinaryString = BinaryString .. string.char(Byte)
		
	end
	
	self:Write( BinaryString )
	
end

return Writer