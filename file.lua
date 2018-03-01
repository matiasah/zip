module("zip.File", package.seeall)

ZipEntry = require("zip.ZipEntry")
Decompressors = require("zip.Decompressors")
table = require("zip.table")

File = setmetatable( {}, ZipEntry )
File.__index = File
File.__type = "File"

function File:new()
	
	return setmetatable( {}, File )
	
end

function File:__tostring()
	
	if self:GetDirectory() then
		
		return "Directory (zip): " .. self:GetPath()
		
	end
	
	return "File (zip): " .. self:GetPath()
	
end

function File:SetCentralFile(CentralFile)
	
	if
		CentralFile:GetDirectory() ~= self:GetDirectory() or
		CentralFile:GetVersionNeeded() ~= self:GetVersionNeeded() or
		not table.compare(CentralFile:GetBitFlags(), self:GetBitFlags()) or
		CentralFile:GetCompressionMethod() ~= self:GetCompressionMethod() or
		CentralFile:GetLastModificationTime() ~= self:GetLastModificationTime() or
		CentralFile:GetLastModificationDate() ~= self:GetLastModificationDate() or
		CentralFile:GetCRC32() ~= self:GetCRC32() or
		CentralFile:GetName() ~= self:GetName() or
		CentralFile:GetPath() ~= self:GetPath()
		then
		
		return false
		
	end
	
	self.CentralFile = CentralFile
	
	return true
	
end

function File:GetCentralFile()
	
	return self.CentralFile
	
end

function File:SetDirectory(Directory)
	
	self.Directory = Directory
	
end

function File:GetDirectory()
	
	return self.Directory
	
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

function File:GetData()
	
	local Decompressor = Decompressors[self.CompressionMethod]
	
	if Decompressor then
		
		return Decompressor(self)
		
	end
	
	return nil
	
end

-- NEVER close the file obtained from this object, use the object itself if you want to read the file
function File:GetTMPFile()
	
	if self.ModifiedFile then
		
		return self.ModifiedFile
		
	end
	
	local Data = self:GetData()
	
	if Data then
		
		local Handle = io.tmpfile()
		
		Handle:write(Data)
		Handle:seek("set", 0)
		
		return Handle
		
	end
	
	return nil
	
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
			
			self.ModifiedFile = self.File
			
		else
			
			self.File:close()
			
		end
		
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
		
		if self.File:write(Data) then
			
			self.Modified = true
			
			return true
			
		end
		
	end
	
	return false
	
end

return File