local Path = (...):gsub("%p", "/")
local RequirePath = ...

local zip = {}

package.loaded["zip"]						=		zip
package.preload["zip.crc32"]				=		assert(love.filesystem.load(Path.."/crc32.lua"))
package.preload["zip.Object"]				=		assert(love.filesystem.load(Path.."/Object.lua"))
package.preload["zip.Decompressors"]	=		assert(love.filesystem.load(Path.."/Decompressors.lua"))
package.preload["zip.Readers"]			=		assert(love.filesystem.load(Path.."/Readers.lua"))

package.preload["zip.Data"]				=		assert(love.filesystem.load(Path.."/Data.lua"))
package.preload["zip.EndOfDir"]			=		assert(love.filesystem.load(Path.."/EndOfDir.lua"))
package.preload["zip.File"]				=		assert(love.filesystem.load(Path.."/File.lua"))
package.preload["zip.Reader"]				=		assert(love.filesystem.load(Path.."/Reader.lua"))

return zip