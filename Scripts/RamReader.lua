----------------------------------------------------------
-- RamReader.lua: put variables on your video via AviUtl.
----------------------------------------------------------

if not aviutl then
	error("This script runs under Lua for AviUtl.")
end

----------------------------------------------------------
-- Import frame data first
----------------------------------------------------------
local frame
-- TODO: modify the file paths below
local basedir = ""
local frameDataPath = basedir.."framedata.txt"
function importFrameData(path)
	local file = io.open(path, "r")
	if file == nil then
		error("File could not be opened.")
	end

	frame = {}
	local f = 1
	while true do
		local i
		frame[f] = {}

		-- TODO: modify the following code to fit the content of log output.
		frame[f].count = file:read("*n")
		if frame[f].count == nil then
			frame[f] = nil
			break
		end
		frame[f].lagcount = file:read("*n")
		i = file:read("*n"); frame[f].lagged = ((i ~= 0) and true or false)
		frame[f].x = file:read("*n")
		frame[f].y = file:read("*n")
		frame[f].xv = file:read("*n")
		frame[f].yv = file:read("*n")
		frame[f].time = file:read("*n")
		-- i = file:read("*n"); frame[f].A = ((i ~= 0) and true or false)

		f = f + 1
	end

	file:close()
end
importFrameData(frameDataPath)

----------------------------------------------------------
-- Extra functions
----------------------------------------------------------
aviutl.draw_bordered_text = function(ycp, x, y, text, R, G, B, tr,
		border_width, borderR, borderG, borderB, borderTr,
		face, fh, fw, angle1, angle2, weight, italic, under, strike)

	-- FIXME: transparency won't work well.
	for yoff = -border_width, border_width do
		for xoff = -border_width, border_width do
			aviutl.draw_text(ycp, x + xoff, y + yoff, text,
				borderR, borderG, borderB, borderTr,
				face, fh, fw, angle1, angle2, weight,
				italic, under, strike)
		end
	end
	aviutl.draw_text(ycp, x, y, text, R, G, B, tr, face, fh, fw, angle1, angle2, weight, italic, under, strike)
end

-- xx seconds => h:mm:ss.ss
function formatseconds(seconds)
	local h, m, s
	s = seconds % 60
	m = math.floor(seconds / 60)
	h = math.floor(m / 60)
	m = m % 60
	return string.format("%d:%02d:%05.2f", h, m, s)
end

----------------------------------------------------------
-- Image processor
----------------------------------------------------------
function func_proc()
	local f = aviutl.get_frame() + 1
	if frame[f] == nil then
		return	-- for safety...
	end

	local ycp_edit = aviutl.get_ycp_edit()

	-- TODO: write your own drawing code here
	aviutl.draw_bordered_text(ycp_edit,
		2, 2, -- x, y
		string.format("%d/%d\nspeed (%d, %d)\ningame: %s",
			frame[f].count, frame[f].lagcount,
			frame[f].xv, frame[f].yv,
			formatseconds(frame[f].time/60.0)
		),
		255, 255, 255, 0, -- RGBA (0<alpha<4096)
		2, 0, 0, 0, 2700, -- RGBA (0<alpha<4096)
		"Verdana", 18, 8, 0, 0, 1000 -- font family, height, width, angle 1&2, weight
	)
end

----------------------------------------------------------
-- Script terminated
----------------------------------------------------------
function func_exit()
end
