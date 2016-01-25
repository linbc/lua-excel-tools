
-------------------------------------------------------------
-- class Sheet
local Sheet = {}

function Sheet.new(ptr)
	local o = {ptr = ptr}
	setmetatable(o, Sheet)
	Sheet.__index = Sheet
	return o
end

function Sheet:getRange(startRange, width_or_endRange, height)
end

return Sheet
