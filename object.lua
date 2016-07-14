local zip = ...
local ZipOBJ = {Type = "Object"}
local ZipOBJMT = {__index = ZipOBJ}

zip.Reader = {}
zip.ZipOBJ = ZipOBJ

function zip.CreateReader(Handle)
	return setmetatable({Handle = Handle}, ZipOBJMT)
end

function ZipOBJ:GetFolderItems(Folder)
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

function ZipOBJ:ReadSignatures()
	self.Folder = {}
	
	while self:ReadAvail() >= 4 do
		local Signature = self:ReadInt()
		local Function = zip.Reader[Signature]
		if Function then
			local Object = Function(self)
			
			if Object.Type == "File" then
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
			end
		end
	end
end

function ZipOBJ:ReadAvail()
	return self.Handle:getSize() - self.Handle:tell()
end

function ZipOBJ:ReadString(Length)
	return self.Handle:read(Length)
end

function ZipOBJ:ReadByte()
	return self.Handle:read(1):byte()
end

function ZipOBJ:ReadShort()
	return self:ReadByte() + self:ReadByte() * 256
end

function ZipOBJ:ReadInt()
	return self:ReadByte() + self:ReadByte() * 256 + self:ReadByte() * 256 * 256 + self:ReadByte() * 256 * 256 * 256
end

function ZipOBJ:ReadBits(Bits)
	local BitArray = {}
	local Bytes = math.ceil(Bits / 8)
	for i = 1, Bytes do
		local Byte = self:ReadByte()
		local Bit = 128
		for i = 1, math.min(Bits, 8) do
			if Byte >= Bit then
				BitArray[#BitArray + 1] = true
				Byte = Byte - Bit
			else
				BitArray[#BitArray + 1] = false
			end
		end
		Bits = Bits - 8
	end
	return BitArray
end