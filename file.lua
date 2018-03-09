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
File.LastModificationTime	= 0
File.LastModificationDate	= 0
File.Version					= 3
File.VersionNeeded			= 20
File.InternalAttributes		= 0
File.ExternalAttributes		= 0
File.CRC32						= 0
File.Comment					= ""
File.CompressedSize			= 0
File.UncompressedSize		= 0
File.ExtraField				= ""

function File:new()
	
	local self = setmetatable( {}, File )
	
	self.BitFlags = {}
	self.Folders = {}
	
	return self
	
end

function File:__tostring()
	
	if self:GetDirectory() then
		
		return "Directory (zip): " .. self:GetPath()
		
	end
	
	return "File (zip): " .. self:GetPath()
	
end

function File:SetDisk(Disk)
	
	self.Disk = Disk
	
end

function File:GetDisk()
	
	return self.Disk
	
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

--[[
	Bit 0: If set, indicates that the file is encrypted.

	(For Method 6 - Imploding)
	Bit 1: If the compression method used was type 6,
			Imploding, then this bit, if set, indicates
			an 8K sliding dictionary was used.  If clear,
			then a 4K sliding dictionary was used.

	Bit 2: If the compression method used was type 6,
			Imploding, then this bit, if set, indicates
			3 Shannon-Fano trees were used to encode the
			sliding dictionary output.  If clear, then 2
			Shannon-Fano trees were used.

	(For Methods 8 and 9 - Deflating)
	Bit 2  Bit 1
	 0      0    Normal (-en) compression option was used.
	 0      1    Maximum (-exx/-ex) compression option was used.
	 1      0    Fast (-ef) compression option was used.
	 1      1    Super Fast (-es) compression option was used.

	(For Method 14 - LZMA)
	Bit 1: If the compression method used was type 14,
			LZMA, then this bit, if set, indicates
			an end-of-stream (EOS) marker is used to
			mark the end of the compressed data stream.
			If clear, then an EOS marker is not present
			and the compressed data size must be known
			to extract.

	Note:  Bits 1 and 2 are undefined if the compression
			method is any other.

	Bit 3: If this bit is set, the fields crc-32, compressed 
			size and uncompressed size are set to zero in the 
			local header.  The correct values are put in the 
			data descriptor immediately following the compressed
			data.  (Note: PKZIP version 2.04g for DOS only 
			recognizes this bit for method 8 compression, newer 
			versions of PKZIP recognize this bit for any 
			compression method.)

	Bit 4: Reserved for use with method 8, for enhanced
			deflating. 

	Bit 5: If this bit is set, this indicates that the file is 
			compressed patched data.  (Note: Requires PKZIP 
			version 2.70 or greater)

	Bit 6: Strong encryption.  If this bit is set, you MUST
			set the version needed to extract value to at least
			50 and you MUST also set bit 0.  If AES encryption
			is used, the version needed to extract value MUST 
			be at least 51. See the section describing the Strong
			Encryption Specification for details.  Refer to the 
			section in this document entitled "Incorporating PKWARE 
			Proprietary Technology into Your Product" for more 
			information.

	Bit 7: Currently unused.

	Bit 8: Currently unused.

	Bit 9: Currently unused.

	Bit 10: Currently unused.

	Bit 11: Language encoding flag (EFS).  If this bit is set,
			 the filename and comment fields for this file
			 MUST be encoded using UTF-8. (see APPENDIX D)

	Bit 12: Reserved by PKWARE for enhanced compression.

	Bit 13: Set when encrypting the Central Directory to indicate 
			 selected data values in the Local Header are masked to
			 hide their actual values.  See the section describing 
			 the Strong Encryption Specification for details.  Refer
			 to the section in this document entitled "Incorporating 
			 PKWARE Proprietary Technology into Your Product" for 
			 more information.

	Bit 14: Reserved by PKWARE.

	Bit 15: Reserved by PKWARE.
]]
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

function File:GetModificationTimeValues()
	
	local Time = self.LastModificationTime
	local Second = Time % 32
	
	Time = ( Time - Second ) / 32
	Second = Second * 2
	
	local Minute = Time % 64
	
	Time = ( Time - Minute ) / 64
	
	local Hour = Time % 32
	
	return Hour, Minute, Second
	
end

function File:GetModificationDateValues()
	
	local Date = self.LastModificationDate
	local Day = Date % 32
	
	Date = ( Date - Day ) / 32
	
	local Month = Date % 32
	
	Date = ( Date - Month ) / 32
	
	local Year = Date % 128
	
	return Day, Month, Year + 1999
	
end

function File:UpdateModificationTime(Number)
	
	local Timestamp = os.date("*t", Number)
	
	self:SetLastModificationTime( math.ceil( Timestamp.sec * 0.5 ) + ( Timestamp.min + Timestamp.hour * 64 ) * 32 )
	self:SetLastModificationDate( Timestamp.day + ( Timestamp.month + ( Timestamp.year - 1999 ) * 32 ) * 32 )
	
end

function File:SetCRC32(CRC32)
	
	self.CRC32 = CRC32
	
end

function File:GetCRC32()
	
	return self.CRC32
	
end

function File:SetPath(Path)
	
	if self.Disk and self.Path then
		
		self.Disk:RemoveEntry( self.Path )
		
	end
	
	self.Path = Path
	self.Folders = {}
	
	if self.Path then
		
		for String in self.Path:gmatch("([^/]+)") do
			
			table.insert(self.Folders, String)
			
		end
		
		self.Name							= self.Folders[#self.Folders]
		self.Folders[#self.Folders]	= nil
		
		if self.Disk then
			
			self.Disk:PutEntry( self )
			
		end
		
	else
		
		self.Name = nil
		
	end
	
end

function File:GetPath()
	
	return self.Path
	
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
	
	local CompressedData = self:GetCompressedData()
	
	if CompressedData then
		
		local Decompressor = Decompressors[self.CompressionMethod]
		
		if Decompressor then
			
			return Decompressor( self:GetCompressedData() )
			
		end
		
	end
	
	return nil
	
end

-- NEVER close the file obtained from this object, use the object itself if you want to read the file
function File:GetTMPFile()
	
	local Data = self:GetData()
	local Handle = io.tmpfile()
	
	if Data then
		
		--if self.CRC32 == crc32.hash(Data) then
			-- File is corrupted
			
		--end
		
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
	
	return self
	
end

function File:close()
	
	if self.File then
		
		if self.Modified then
			
			self.File:seek("set", 0)
			
			local Data = self.File:read("*a")
			local Compressor = Compressors[self.CompressionMethod]
			
			if Compressor then
				
				local CompressedData = Compressors[self.CompressionMethod]( Data )
				
				if CompressedData then
					
					self.CompressedFile = io.tmpfile()
					self.CompressedFile:write(CompressedData)
					self.CompressedFile:seek("set", 0)
					
					self.CompressedSize = #CompressedData
					self.UncompressedSize = #Data
					self.CRC32 = crc32.hash(Data)
					
					self:UpdateModificationTime( os.time() )
					
				else
					
					return false, "Couldn't compress data with method '" .. self.CompressionMethod .. "'"
					
				end
				
				self.Modified = false
				
			else
				
				return false, "No compression method found"
				
			end
			
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
	
	if self.File then
		
		local Current = self.File:seek("cur", 0)
		local Size = self.File:seek("end", 0)
		
		self.File:seek("set", Current)
		
		return Size
		
	end
	
	return self.UncompressedSize
	
end

function File:isEOF()
	
	if self.File then
		
		return self.File:seek("cur", 0) >= self:getSize()
		
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

function File:read(Size)
	
	if self.File then
		
		if Size == "all" or Size == nil then
			
			Size = "*a"
			
		end
		
		return self.File:read(Size)
		
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