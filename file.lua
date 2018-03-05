module("zip.File", package.seeall)

crc32 = require("zip.crc32")

Entry = require("zip.Entry")
Decompressors = require("zip.Decompressors")
Compressors = require("zip.Compressors")
table = require("zip.table")

File = setmetatable( {}, Entry )
File.__index = File
File.__type = "File"

File.CompressionMethod		= 8
File.Version					= 2
File.VersionNeeded			= 20
File.InternalAttributes		= 0
File.ExternalAttributes		= 0
File.Comment					= ""

function File:new()
	
	return setmetatable( {}, File )
	
end

function File:__tostring()
	
	if self:GetDirectory() then
		
		return "Directory (zip): " .. self:GetPath()
		
	end
	
	return "File (zip): " .. self:GetPath()
	
end

function File:SetDirectory(Directory)
	
	self.Directory = Directory
	
end

function File:GetDirectory()
	
	return self.Directory
	
end

--[[
	0 - MS-DOS and OS/2 (FAT / VFAT / FAT32 file systems)
	1 - Amiga 
	2 - OpenVMS
	3 - UNIX 
	4 - VM/CMS
	5 - Atari ST
	6 - OS/2 H.P.F.S.
	7 - Macintosh 
	8 - Z-System
	9 - CP/M 
	10 - Windows NTFS
	11 - MVS (OS/390 - Z/OS) 
	12 - VSE
	13 - Acorn Risc 
	14 - VFAT
	15 - alternate MVS 
	16 - BeOS
	17 - Tandem 
	18 - OS/400
	19 - OS/X (Darwin) 
	20 - 255: unused
]]
function File:SetVersion(Version)
	
	self.Version = Version
	
end

function File:GetVersion()
	
	return self.Version
	
end

function File:SetVersionNeeded(VersionNeeded)
	
	self.VersionNeeded = VersionNeeded
	
end

function File:GetVersionNeeded()
	
	return self.VersionNeeded
	
end

function File:SetBitFlags(BitFlags)
	
	self.BitFlags = BitFlags
	
end

function File:GetBitFlags()
	
	return self.BitFlags
	
end

function File:SetCompressionMethod(CompressionMethod)
	
	self.CompressionMethod = CompressionMethod
	
end

function File:GetCompressionMethod()
	
	return self.CompressionMethod
	
end

function File:SetLastModificationTime(LastModificationTime)
	
	self.LastModificationTime = LastModificationTime
	
end

function File:GetLastModificationTime()
	
	return self.LastModificationTime
	
end

function File:SetLastModificationDate(LastModificationDate)
	
	self.LastModificationDate = LastModificationDate
	
end

function File:GetLastModificationDate()
	
	return self.LastModificationDate
	
end

function File:SetCRC32(CRC32)
	
	self.CRC32 = CRC32
	
end

function File:GetCRC32()
	
	return self.CRC32
	
end

function File:SetPath(Path)
	
	self.Path = Path
	
end

function File:GetPath()
	
	return self.Path
	
end

function File:SetName(Name)
	
	self.Name = Name
	
end

function File:GetName()
	
	return self.Name
	
end

function File:GetSource()
	
	return table.concat(self.Folders, "/")
	
end

function File:SetExtraField(ExtraField)
	
	self.ExtraField = ExtraField
	
end

function File:GetExtraField()
	
	return self.ExtraField
	
end

function File:SetFolders(Folders)
	
	self.Folders = Folders
	
end

function File:GetFolders()
	
	return self.Folders
	
end

function File:SetInternalAttributes(InternalAttributes)
	
	self.InternalAttributes = InternalAttributes
	
end

function File:GetInternalAttributes()
	
	return self.InternalAttributes
	
end

function File:SetExternalAttributes(ExternalAttributes)
	
	self.ExternalAttributes = ExternalAttributes
	
end

function File:GetExternalAttributes()
	
	return self.ExternalAttributes
	
end

function File:SetComment(Comment)
	
	self.Comment = Comment
	
end

function File:GetComment()
	
	return self.Comment
	
end

function File:GetCompressedData()
	
	if self.CompressedFile then
		
		self.CompressedFile:seek("set", 0)
		
		return self.CompressedFile:read("*a")
		
	end
	
	return Entry.GetCompressedData(self)
	
end

function File:GetData()
	
	local Decompressor = Decompressors[self.CompressionMethod]
	
	if Decompressor then
		
		return Decompressor( self:GetCompressedData() )
		
	end
	
	return nil
	
end

-- NEVER close the file obtained from this object, use the object itself if you want to read the file
function File:GetTMPFile()
	
	local Data = self:GetData()
	local Handle = io.tmpfile()
	
	if Data then
		
		Handle:write(Data)
		Handle:seek("set", 0)
		
	end
	
	return Handle
	
end

-- io functions
function File:open()
	
	if not self.File then
		
		self.File = self:GetTMPFile()
		
	end
	
	if self.File == nil then
		
		return false, "Couldn't create temporary file"
		
	end
	
	return true
	
end

function File:close()
	
	if self.File then
		
		if self.Modified then
			
			self.File:seek("set", 0)
			local Data = self.File:read("*a")
			local CompressedData = Compressors[self.CompressionMethod]( Data )
			
			if CompressedData then
				
				self.CompressedFile = io.tmpfile()
				self.CompressedFile:write(CompressedData)
				self.CompressedFile:seek("set", 0)
				
				self.CompressedSize = #CompressedData
				self.UncompressedSize = #Data
				self.CRC32 = crc32.hash(Data)
				
			else
				
				return false, "Couldn't compress data with method '" .. self.CompressionMethod .. "'"
				
			end
			
			self.Modified = false
			
		end
		
		self.File:close()
		self.File = nil
		
	end
	
	return true
	
end

function File:flush()
	
	if self.File then
		
		self.File:flush()
		
	end
	
end

function File:getFilename()
	
	return self:GetName()
	
end

function File:getMode()
	
	if self.File then
		
		return "rw"
		
	end
	
	return "c"
	
end

function File:getSize()
	
	return self.UncompressedSize
	
end

function File:isEOF()
	
	if self.File then
		
		return self.File:seek("cur", 0) >= self.UncompressedSize
		
	end
	
	return true
	
end

function File:isOpen()
	
	return self.File ~= nil
	
end

function File:lines()
	
	if self.File then
		
		return self.File:lines()
		
	end
	
	return nil
	
end

function File:read(Mode)
	
	if self.File then
		
		if Mode == "all" then
			
			Mode = "*a"
			
		end
		
		return self.File:read(Mode)
		
	end
	
	return nil
	
end

function File:seek(Position)
	
	if self.File then
		
		return self.File:seek("set", Position)
		
	end
	
	return false
	
end

function File:tell()
	
	if self.File then
		
		return self.File:seek("cur", 0)
		
	end
	
	return 0
	
end

function File:write(Data)
	
	if self.File then
		
		if #Data > 0 then
			
			if self.File:write(Data) then
				
				self.Modified = true
				
				return true
				
			end
			
		end
		
	end
	
	return false
	
end

return File