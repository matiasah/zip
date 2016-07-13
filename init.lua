local Path = (...):gsub("%p", "/")
local RequirePath = ...

local zip = {}

zip.crc32 = require(RequirePath..".crc32")

love.filesystem.load(Path.."/object.lua")(zip)
love.filesystem.load(Path.."/data.lua")(zip)
love.filesystem.load(Path.."/file.lua")(zip)
love.filesystem.load(Path.."/directory.lua")(zip)
love.filesystem.load(Path.."/eodirectory.lua")(zip)
love.filesystem.load(Path.."/decompression.lua")(zip)

function zip.read(Path)
	local Handle = love.filesystem.newFile(Path, "r")
	if not Handle then
		return nil
	end
	
	local ZipObject = zip.CreateReader(Handle)
	ZipObject:ReadSignatures()
	ZipObject.Handle:close()
	
	return ZipObject
end

return zip