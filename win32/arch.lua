local ffi = require("ffi")

local arch = {}

function arch.stringToPointer(str)
	local num = tonumber(str);
	if not num then
		return nil, "invalid number";
	end

	return ffi.cast("void *", ffi.cast("intptr_t", num));
end


-- This helper routine will take a pointer
-- to cdata, and return a string that contains
-- the memory address
-- tonumber(ffi.cast('intptr_t', ffi.cast('void *', ptr)))
function arch.pointerToString(instance)
	if ffi.abi("64bit") then
		return string.format("0x%016x", tonumber(ffi.cast("int64_t", ffi.cast("void *", instance))))
	elseif ffi.abi("32bit") then
		return string.format("0x%08x", tonumber(ffi.cast("int32_t", ffi.cast("void *", instance))))
	end

	return nil;
end

--[=[
	Return a pointer to a specific field within a structure.

	Given:
	ffi.cdef[[
	struct POINT {
		int x;
		int y;
	}
	]]

	local aPoint = ffi.new("struct POINT");

	local addr = arch.fieldAddress(aPoint, "y")

	'addr' now contains the same result as the C equivalent: &aPoint->y;
]=]

function arch.fieldAddress(astruct, fieldname)
	local offset = ffi.offsetof(ffi.typeof(astruct), fieldname);
	
	return ffi.cast("uint8_t *", astruct) + offset;
end

return arch;
