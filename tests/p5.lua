--[[
    This single file represents the guts of a processing/p5 skin
    The code will be very familiar to anyone who's used to doing processing,
    but done with a Lua flavor.
    

    Typical usage:

    -- This first line MUST come before any user code
    local graphicApp = require("graphicapp")

    function onMouseMove(event)
        print("MOVE: ", event.x, event.y)
    end

    -- This MUST be the last line of the user code
    graphicApp.run();
]]
local ffi = require("ffi")
local bit = require("bit")
local band, bor = bit.band, bit.bor
local rshift, lshift = bit.rshift, bit.lshift;

local sched = require("scheduler")
local stopwatch = require("stopwatch")
local wingdi = require("win32.wingdi")
local winuser = require("win32.winuser")
local WindowKind = require("WindowKind")
local NativeWindow = require("nativewindow")
local wmmsgs = require("wm_reserved")
local DeviceContext = require("DeviceContext")
local GDISurface = require("GDISurface")



local exports = {}
local lonMessage = false;
local SWatch = stopwatch();


-- Global things
-- Constants
HALF_PI = math.pi / 2
PI = math.pi
QUARTER_PI = math.pi/4
TWO_PI = math.pi * 2
TAU = TWO_PI

-- angleMode
DEGREES = 1;
RADIANS = 2;


-- Constants related to colors
-- colorMode
RGB = 1;
HSB = 2;

-- rectMode, ellipseMode
CORNER = 1;
CORNERS = 2;
RADIUS = 3;
CENTER = 4;

-- kind of close (for polygon)
STROKE = 0;
CLOSE = 1;

-- alignment
CENTER      = 0x00;
LEFT        = 0x01;
RIGHT       = 0x04;
TOP         = 0x10;
BOTTOM      = 0x40;
BASELINE    = 0x80;

MODEL = 1;
SCREEN = 2;
SHAPE = 3;

-- GEOMETRY
POINTS          = 0;
LINES           = 1;
LINE_STRIP      = 2;
LINE_LOOP       = 3;
POLYGON         = 4;
QUADS           = 5;
QUAD_STRIP      = 6;
TRIANGLES       = 7;
TRIANGLE_STRIP  = 8;
TRIANGLE_FAN    = 9;




-- environment
frameCount = 0;
focused = false;
displayWidth = false;
displayHeight = false;
windowWidth = false;
windowHeight = false;
width = false;
height = false;

-- Mouse state changing live
mouseX = false;
mouseY = false;
pMouseX = false;
pMouseY = false;
winMouseX = false;
winMouseY = false;
pwinMouseX = false;
pwinMouseY = false;
mouseButton = false;
mouseIsPressed = false;
-- to be implemented by user code
-- mouseMoved()
-- mouseDragged()
-- mousePressed()
-- mouseReleased()
-- mouseClicked()
-- doubleClicked()
-- mouseWheel()

-- Keyboard state changing live
keyIsPressed = false;
key = false;
keyCode = false;
-- to be implemented by client code
-- keyPressed()
-- keyReleased()
-- keyTyped()
-- keyIsDown()

-- Touch events
touches = false;
-- touchStarted()
-- touchMoved()
-- touchEnded()

-- Initial State for modes
AngleMode = RADIANS;
ColorMode = RGB;
RectMode = CORNER;
EllipseMode = CENTER;
ShapeMode = POLYGON;

FrameRate = 20;
LoopActive = true;
EnvironmentReady = false;

-- Typography
TextSize = 12;
TextHAlignment = LEFT;
TextVAlignment = BASELINE;
TextLeading = 0;
TextMode = SCREEN;
TextSize = 12;


StrokeWidth = 0;
StrokeWeight = 1;

--[[
    These are functions that are globally available, so user code
    can use them.  These functions don't rely specifically on the 
    drawing interface, so that can remain here in case the drawing
    driver changes.
]]

--[[
    MATHS
]]


function lerp(low, high, x)
    return low + x*(high-low)
end

function mag(x, y)
    return sqrt(x*x +y*y)
end

function map(x, olow, ohigh, rlow, rhigh)
    rlow = rlow or olow
    rhigh = rhigh or ohigh
    return rlow + (x-olow)*((rhigh-rlow)/(ohigh-olow))
end

function sq(x)
    return x*x
end

abs = math.abs
asin = math.asin
acos = math.acos
atan = math.atan

function atan2(y,x)
    return atan(y/x)
end

ceil = math.ceil

function constrain(x, low, high)
    return math.min(math.max(x, low), high)
end
clamp = constrain
cos = math.cos

degrees = math.deg

function dist(x1, y1, x2, y2)
    return math.sqrt(sq(x2-x1) + sq(y2-y1))
end

exp = math.exp
floor = math.floor
log = math.log
max = math.max
min = math.min

function norm(val, low, high)
    return map(value, low, high, 0, 1)
end

function pow(x,y)
    return x^y;
end

radians = math.rad
random = math.random

function round(n)
	if n >= 0 then
		return floor(n+0.5)
	end

	return ceil(n-0.5)
end

sin = math.sin
sqrt = math.sqrt





--[[
    COLOR
]]
function color(...)
	local nargs = select('#', ...)
	local self = {}

	-- There can be 1, 2, 3, or 4, arguments
	--	print("Color.new - ", nargs)
	
	local r = 0
	local g = 0
	local b = 0
	local a = 0
	
	if (nargs == 1) then
			r = select(1,...)
			g = select(1,...)
			b = select(1,...)
			a = 255;
	elseif nargs == 2 then
			r = select(1,...)
			g = select(1,...)
			b = select(1,...)
			a = select(2,...)
	elseif nargs == 3 then
			r = select(1,...)
			g = select(2,...)
			b = select(3,...)
			a = 255
	elseif nargs == 4 then
		r = select(1,...)
		g = select(2,...)
		b = select(3,...)
		a = select(4,...)
	end
	
	self.cref = wingdi.RGB(r,g,b)
	
	self.R = r
	self.G = g
	self.B = b
	self.A = a

	return self;
end


function blue(c)
	return c.B
end

function green(c)
	return c.G
end

function red(c)
	return c.R
end

function alpha(c)
	return c.A
end

-- Modes to be honored by various drawing APIs
function angleMode(newMode)
    if newMode ~= DEGREES and newMode ~= RADIANS then 
        return false 
    end

    AngleMode = newMode;

    return true;
end

function ellipseMode(newMode)
    EllipseMode = newMode;
end

function rectMode(newMode)
    RectMode = newMode;
end

--[[
	Scene
--]]
function addactor(actor)
	if not actor then return end

	if actor.Update then
		table.insert(Processing.Actors, actor)
	end

	if actor.Render then
		addgraphic(actor)
	end

	addinteractor(actor)
end

function addgraphic(agraphic)
	if not agraphic then return end

	table.insert(Processing.Graphics, agraphic)
end

function addinteractor(interactor)
	if not interactor then return end

	if interactor.MouseActivity then
		table.insert(Processing.MouseInteractors, interactor)
	end

	if interactor.KeyboardActivity then
		table.insert(Processing.KeyboardInteractors, interactor)
	end
end

-- timing
function millis()
    -- get millis from p5 stopwatch
    return SWatch:millis();
end

function frameRate(...)
    if select('#', ...) == 0 then
        return FrameRate;
    end

    if type(select(1,...)) ~= "number" then
        return false, 'must specify a numeric frame rate'
    end

    FrameRate = select(1,...);

    -- reset frame timer
end

function loop()
    LoopActive = true;
end

function noLoop()
    LoopActive = false;
end

-- Drawing and canvas management
function refreshWindow()
    --appWindow:redraw(bor(ffi.C.RDW_UPDATENOW, ffi.C.RDW_INTERNALPAINT))
    --appWindow:redraw(bor(ffi.C.RDW_INTERNALPAINT))
    appWindow:invalidate();

    return true;
end

function redraw()
    if draw then
        draw();
        surface.DC:flush();
    end

    refreshWindow();

    return true;
end

function createCanvas(width, height)
    return false;
end









-- Very Windows specific

local function HIWORD(val)
    return band(rshift(val, 16), 0xffff)
end

local function LOWORD(val)
    return band(val, 0xffff)
end

-- encapsulate a mouse event
local function wm_mouse_event(hwnd, msg, wparam, lparam)
    -- assign previous mouse position
    if mouseX then pmouseX = mouseX end
    if mouseY then pmouseY = mouseY end

    -- assign new mouse position
    mouseX = tonumber(band(lparam,0x0000ffff));
    mouseY = tonumber(rshift(band(lparam, 0xffff0000),16));

    local event = {
        x = mouseX;
        y = mouseY;
        control = band(wparam, ffi.C.MK_CONTROL) ~= 0;
        shift = band(wparam, ffi.C.MK_SHIFT) ~= 0;
        lbutton = band(wparam, ffi.C.MK_LBUTTON) ~= 0;
        rbutton = band(wparam, ffi.C.MK_RBUTTON) ~= 0;
        mbutton = band(wparam, ffi.C.MK_MBUTTON) ~= 0;
        xbutton1 = band(wparam, ffi.C.MK_XBUTTON1) ~= 0;
        xbutton2 = band(wparam, ffi.C.MK_XBUTTON2) ~= 0;
    }

    mousePressed = event.lbutton or event.rbutton or event.mbutton;

    return event;
end

function MouseActivity(hwnd, msg, wparam, lparam)
    local res = 1;

    local event = wm_mouse_event(hwnd, msg, wparam, lparam)


    if msg == ffi.C.WM_MOUSEMOVE  then
        event.activity = 'mousemove'
        if mousePressed then
            signalAll('gap_mousedrag')
        end
        signalAll('gap_mousemove', event)
    elseif msg == ffi.C.WM_LBUTTONDOWN or 
        msg == ffi.C.WM_RBUTTONDOWN or
        msg == ffi.C.WM_MBUTTONDOWN or
        msg == ffi.C.WM_XBUTTONDOWN then
        event.activity = 'mousedown';
        signalAll('gap_mousedown', event)
    elseif msg == ffi.C.WM_LBUTTONUP or
        msg == ffi.C.WM_RBUTTONUP or
        msg == ffi.C.WM_MBUTTONUP or
        msg == ffi.C.WM_XBUTTONUP then
        event.activity = 'mouseup'
        signalAll('gap_mouseup', event)
        signalAll('gap_mouseclick', event)
    elseif msg == ffi.C.WM_MOUSEWHEEL then
        event.activity = 'mousewheel';
        signalAll('gap_mousewheel', event)
    elseif msg == ffi.C.WM_MOUSELEAVE then
        --print("WM_MOUSELEAVE")
    else
        res = ffi.C.DefWindowProcA(hwnd, msg, wparam, lparam);
    end

    return res;
end

function KeyboardActivity(hwnd, msg, wparam, lparam)
    --print("onKeyboardActivity")
    local res = 1;

    res = ffi.C.DefWindowProcA(hwnd, msg, wparam, lparam);

    return res;
end

function CommandActivity(hwnd, msg, wparam, lparam)
    if onCommand then
        onCommand({source = tonumber(HIWORD(wparam)), id=tonumber(LOWORD(wparam))})
    end
end


function WindowProc(hwnd, msg, wparam, lparam)
    --print(string.format("WindowProc: msg: 0x%x, %s", msg, wmmsgs[msg]), wparam, lparam)

    local res = 1;

    -- If the window has been destroyed, then post a quit message
    if msg == ffi.C.WM_COMMAND then
        CommandActivity(hwnd, msg, wparam, lparam)
    elseif msg == ffi.C.WM_DESTROY then
        ffi.C.PostQuitMessage(0);
        signalAllImmediate('gap_quitting');
        return 0;
    elseif msg == ffi.C.WM_PAINT then
        local ps = ffi.new("PAINTSTRUCT");
		local hdc = ffi.C.BeginPaint(hwnd, ps);
--print("PAINT: ", ps.rcPaint.left, ps.rcPaint.top,ps.rcPaint.right, ps.rcPaint.bottom)
		-- bitblt backing store to client area

        if (surface  == nil) then
            print("NO SURFACE YET")
        else
			ret = ffi.C.BitBlt(hdc,
				ps.rcPaint.left, ps.rcPaint.top,
				ps.rcPaint.right - ps.rcPaint.left, ps.rcPaint.bottom - ps.rcPaint.top,
				surface.DC.Handle,
				ps.rcPaint.left, ps.rcPaint.top,
                ffi.C.SRCCOPY);
        end

		ffi.C.EndPaint(hwnd, ps);
    elseif msg >= ffi.C.WM_MOUSEFIRST and msg <= ffi.C.WM_MOUSELAST then
        res = MouseActivity(hwnd, msg, wparam, lparam)
    elseif msg >= ffi.C.WM_KEYFIRST and msg <= ffi.C.WM_KEYLAST then
        res = KeyboardActivity(hwnd, msg, wparam, lparam)  
    elseif msg == ffi.C.WM_SETFOCUS then
        --print("WM_SETFOCUS")
        focused = true;
    elseif msg == ffi.C.WM_KILLFOCUS then
        --print("WM_KILLFOCUS")
        focused = false;
    else
        res = ffi.C.DefWindowProcA(hwnd, msg, wparam, lparam);
    end

	return res
end
jit.off(WindowProc)




local function msgLoop()
    --  create some a loop to process window messages
    --print("msgLoop - BEGIN")
    local msg = ffi.new("MSG")
    local res = 0;

    while (true) do
        --print("LOOP")
        -- we use peekmessage, so we don't stall on a GetMessage
        while (ffi.C.PeekMessageA(msg, nil, 0, 0, ffi.C.PM_REMOVE) ~= 0) do
            --print(string.format("Loop Message: 0x%x", msg.message), wmmsgs[msg.message])            
            if lonMessage then
                lonMessage(msg);
            end
            
            -- If we see a quit message, it's time to stop the program
            -- ideally we'd call an 'onQuit' and wait for that to return
            -- before actually halting.  That will give the app a chance
            -- to do some cleanup
            if msg.message == ffi.C.WM_QUIT then
                --print("msgLoop - QUIT")
                halt();
            end

            res = ffi.C.TranslateMessage(msg)
            res = ffi.C.DispatchMessageA(msg)
        end

        yield();
    end

    --print("msgLoop - END")        
end


local function createWindow(params)
    params = params or {width=1024, height=768, title="GraphicApplication"}
    params.width = params.width or 1024;
    params.height = params.height or 768;
    params.title = params.title or "Graphic App";

    -- set global variables
    width = params.width;
    height = params.height;

    -- You MUST register a window class before you can use it.
    local winkind, err = WindowKind("GraphicWindow", WindowProc);

    if not winkind then
        print("Window kind not created, ERROR: ", err);
        return false, err;
    end

    -- create an instance of a window
    appWindow = NativeWindow:create(winkind.ClassName, params.width, params.height,  params.title);

    appWindow:show();
end



-- Register UI event handler global functions
-- These are the functions that the user should implement
-- in their code
local function setupUIHandlers()
    local handlers = {
        {activity = 'gap_mousemove', response = "mouseMoved"};
        {activity = 'gap_mouseup', response = "mouseReleased"};
        {activity = 'gap_mousedown', response = "mousePressed"};
        {activity = 'gap_mousedrag', response = 'mouseDragged'};
        {activity = 'gap_mousewheel', response = "mouseWheel"};
        {activity = 'gap_mouseclick', response = "mouseClicked"};

        {activity = 'gap_keydown', response = "onKeyboardActivity"};
        {activity = 'gap_keyup', response = "onKeyboardActivity"};
        {activity = 'gap_syskeydown', response = "onKeyboardActivity"};
        {activity = 'gap_syskeyup', response = "onKeyboardActivity"};

        {activity = 'gap_idle', response = "onIdle"};
        --{activity = 'gap_frame', response = "draw"};
    }

    for i, handler in ipairs(handlers) do
        --print("response: ", handler.response, _G[handler.response])
        if _G[handler.response] ~= nil then
            on(handler.activity, _G[handler.response])
        end
    end

end

local function handleFrame()
    if LoopActive and EnvironmentReady then
        if draw then
            redraw();
        end
        frameCount = frameCount + 1;
    end
end


local function main(params)

    FrameRate = params.frameRate or 15;

    -- make a local for 'onMessage' global function    
    if onMessage then
        lonMessage = onMessage;
    end

	surface = GDISurface(params)

    spawn(msgLoop);
    yield();

	createWindow(params);
    setupUIHandlers();
    yield();


    background(0xCC)        -- light gray
    fill(0,0,0)             -- black
    stroke(0,0,0)

    EnvironmentReady = true;

    if setup then
        setup();
    end
    redraw();
    yield();

    -- setup the periodic frame calling
    local framePeriod = math.floor((1/FrameRate)*1000)
    --print("Frame Period: ", framePeriod)
    periodic(framePeriod, handleFrame)

    signalAll("gap_ready");
end


function go(params)
    params = params or {
        width = 320;
        height = 240;
        title = "p5"
    }
    params.width = params.width or 320;
    params.height = params.height or 240;
    params.title = params.title or "p5";
    params.frameRate = params.frameRate or 15;

    run(main, params)
end

require("p5_gdi")