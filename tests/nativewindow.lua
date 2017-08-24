
local ffi = require("ffi");
local bit = require("bit");
local bor = bit.bor;

local errorhandling = require("win32.core.errorhandling_l1_1_1");
local core_library = require("win32.core.libraryloader_l1_1_1");

local User32 = require("win32.user32");


print(" core_library: ", core_library)
print("errorhandling: ", errorhandling)


ffi.cdef[[
typedef struct {
	HWND	Handle;
} WindowHandle, *PWindowHandle;
]]

local WindowHandle = ffi.typeof("WindowHandle");
local WindowHandle_mt = {}
ffi.metatype(WindowHandle, WindowHandle_mt);


local NativeWindow = {}
setmetatable(NativeWindow, {
	__call = function(self, ...)
		return self:create(...);
	end,
});
local NativeWindow_mt = {
	__index = NativeWindow,
}

--[[
function NativeWindow.RegisterClass(self, classname, msgproc, style)
	msgproc = msgproc or User32.Lib.DefWindowProcA;
	style = style or bor(ffi.C.CS_HREDRAW, ffi.C.CS_VREDRAW, ffi.C.CS_OWNDC);

	local winclass = User32.RegisterWindowClass(classname)

	return winclass;
end
--]]

function NativeWindow.init(self, rawhandle)
	local obj = {
		Handle = WindowHandle(rawhandle);
	}
	setmetatable(obj, NativeWindow_mt);

	return obj;
end

function NativeWindow.create(self, className, width, height, title)
	className = className or "NativeWindowClass";
	title = title or "Native Window Title";

	local dwExStyle = bor(ffi.C.WS_EX_APPWINDOW, ffi.C.WS_EX_WINDOWEDGE);
	local dwStyle = bor(ffi.C.WS_SYSMENU, ffi.C.WS_VISIBLE, ffi.C.WS_POPUP);

	local appInstance = core_library.GetModuleHandleA(nil);

	local hwnd = User32.CreateWindowExA(
		0,
		className,
		title,
		ffi.C.WS_OVERLAPPEDWINDOW,
		ffi.C.CW_USEDEFAULT,
		ffi.C.CW_USEDEFAULT,
		width, height,
		nil,
		nil,
		appInstance,
		nil);

	if hwnd == nil then
		return false, errorhandling.GetLastError();
	end

	return self:init(hwnd);
end



--[[
	Instance Methods
--]]

-- Attributes
function NativeWindow.getNativeHandle(self)
	return self.Handle.Handle;
end

function NativeWindow.getDeviceContext(self)
	if not self.ClientContext then
		self.ClientContext = DeviceContext(User32.GetDC(self:getNativeHandle()))
	end

	return self.ClientContext;
end

-- Functions
function NativeWindow.hide(self, kind)
	kind = kind or User32.SW_HIDE;
	self:Show(kind);
end
		
function NativeWindow.maximize(self)
	--print("NativeWinow:MAXIMIZE: ", ffi.C.SW_MAXIMIZE);
	return self:Show(ffi.C.SW_MAXIMIZE);
end

function NativeWindow.redraw(self, flags)
	local lprcUpdate = nil;	-- const RECT *
	local hrgnUpdate = nil; -- HRGN
	flags = flags or ffi.C.RDW_UPDATENOW;

	local res = User32.RedrawWindow(
  		self:getNativeHandle(),
  		lprcUpdate,
   		hrgnUpdate,
  		flags);

	return true;
end

function NativeWindow.show(self, kind)
	kind = kind or ffi.C.SW_SHOWNORMAL;

	return User32.ShowWindow(self:getNativeHandle(), kind);
end

function NativeWindow.update(self)
	User32.UpdateWindow(self:getNativeHandle())
end

function NativeWindow.getClientSize(self)
	local csize = ffi.new( "RECT[1]" )
	User32.GetClientRect(self:getNativeHandle(), csize);
	csize = csize[0]
	local width = csize.right-csize.left
	local height = csize.bottom-csize.top

	return width, height
end

function NativeWindow.getTitle(self)
	local buf = ffi.new("char[?]", 256)
	local lbuf = ffi.cast("intptr_t", buf)
	if User32.SendMessageA(self:getNativeHandle(), ffi.C.WM_GETTEXT, 255, lbuf) ~= 0 then
		return ffi.string(buf)
	end

	return nil;
end


return NativeWindow;
