
-- Reads a json file and creates it if it doesn't exist
function file.ReadOrCreate(name)
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
