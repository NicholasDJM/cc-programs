-- For ComputerCraft Mining Turtles (https://www.curseforge.com/minecraft/mc-mods/cc-tweaked or https://www.curseforge.com/minecraft/mc-mods/cc-restitched)
-- Cobblestone Generator script installer for Mining Turtles. Created by NicholasDJM (https://github.com/NicholasDJM/cc-programs)
local filePath = "/cobble.lua"
local fileURL = "https://raw.githubusercontent.com/NicholasDJM/cc-programs/main/cobble/cobble.lua"
if not http then
	printError("The HTTP API is disabled.")
	return nil, "The HTTP API is disabled."
end
local function top(overwrite)
	local downloadedFile = http.get(fileURL)
	if downloadedFile and downloadedFile.getResponseCode()==200 then
		if not fs.exists(filePath) or overwrite then
			local file = fs.open(filePath, "w")
			file.write(downloadedFile.readAll())
			downloadedFile.close()
			file.close()
			print("Written file "..filePath)
		elseif overwrite==nil then
			printError("There is already a file at the location of '"..filePath.."'.")
			write("Do you want to overwrite it? (y/N) ")
			local userResponse = read()
			if userResponse=="Y" or userResponse == "y" then
				top(true)
			else
				print("Aborted")
			end
		end
	elseif downloadedFile then
		printError("Installation failed. Response code: "..downloadedFile.getResponseCode())
	else
		printError("Installation failed. Unable to download the program from "..fileURL)
	end
end
top()
