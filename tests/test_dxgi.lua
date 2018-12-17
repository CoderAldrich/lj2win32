package.path = "../?.lua;"..package.path;

--COM_NO_WINDOWS_H = true

local dxgi = require("win32.dxgi")
local C = ffi.C 

local ppFactory = ffi.new("IDXGIFactory1*[1]")
local hr = dxgi.CreateDXGIFactory1(C.IID_IDXGIFactory1,  ppFactory)

print(hr, ppFactory[0])
