
-- Reads a json file and creates it if it doesn't exist
function file.ReadOrCreate(name)
	-- Split the name into folders and file
	local folders = string.Explode("/", name)

	for i = 1, #folders - 1 do
		local folder = table.concat(folders, "/", 1, i)

		if (!file.Exists(folder, "DATA")) then
			file.CreateDir(folder)
		end
	end

	if (!file.Exists(name, "DATA")) then
		file.Write(name, "[]")
	end

	return util.JSONToTable(file.Read(name, "DATA"))
end

-- Lerps a color
function LerpColor(frac, from, to)
	return Color(
		Lerp(frac, from.r, to.r),
		Lerp(frac, from.g, to.g),
		Lerp(frac, from.b, to.b),
		Lerp(frac, from.a, to.a)
	)
end

local hexChars = "0123456789ABCDEF"

function GenerateHex()
	local hex = ""

	for i = 1, 32 do
		hex = hex .. hexChars[math.random(16)]
	end

	return hex
end

function EchoSound(path, pitch, volume)
	print(path)
	print(pitch)
	print(volume)
	LocalPlayer():EmitSound("echoesbeyond/" .. path .. ".wav", 75, pitch or math.random(95, 105), volume or 1)
end

function RemoveSigning(text)
    local s, e = text:find("[%-~][^%-~]*$")  -- This pattern matches from the last dash/tilde to the end.
    if (!s) then return text end

	local candidate = text:sub(s+1):match("^%s*(.-)%s*$") -- Extract the candidate signing text (trim whitespace).

	-- If the candidate isn't empty, starts with a letter, and is short, assume it's a signing block and remove it.
	if (candidate and candidate:match("^[A-Za-z]") and #candidate <= 30) then
		return text:sub(1, s-1)
	end

    return text
end
