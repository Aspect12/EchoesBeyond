
-- Reads a file and creates it if it doesn't exist. Assumes the file is in the data folder.
function file.ReadOrCreate(name, default)
	if (!file.Exists(name, "DATA")) then
		file.Write(name, default)
	end

	return file.Read(name, "DATA")
end
