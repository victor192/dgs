local check
if fileExists("update.cfg") then
	check = fileOpen("update.cfg")
else
	check = fileCreate("update.cfg")
end
local allstr = fileRead(check,fileGetSize(check))
setElementData(resourceRoot,"Version",allstr)
fileClose(check)
Version = tonumber(allstr) or 0
RemoteVersion = 0
ManualUpdate = false
updateTimer = false
updatePeriodTimer = false
function checkUpdate()
	fetchRemote(dgsConfig.updateCheckURL.."/dgs/update.cfg",function(data,err)
		if err == 0 then
			RemoteVersion = tonumber(data)
			if not ManualUpdate then
				if RemoteVersion > Version then
					outputDebugString("[DGS]Remote Version Got [Remote:"..data.." Current:"..allstr.."]. See the update log: http://angel.mtaip.cn:233/dgsUpdate")
					outputDebugString("[DGS]Update? Command: updatedgs")
					if isTimer(updateTimer) then killTimer(updateTimer) end
					updateTimer = setTimer(function()
						if RemoteVersion > Version then
							outputDebugString("[DGS]Remote Version Got [Remote:"..RemoteVersion.." Current:"..allstr.."]. See the update log: http://angel.mtaip.cn:233/dgsUpdate")
							outputDebugString("[DGS]Update? Command: updatedgs")
						else
							killTimer(updateTimer)
						end
					end,dgsConfig.updateCheckNoticeInterval*60000,0)
				else
					outputDebugString("[DGS]Current Version("..allstr..") is latest!")
				end
			else
				startUpdate()
			end
		else
			outputDebugString("[DGS]Can't Get Remote Version ("..err..")")
		end
	end)
end

if dgsConfig.updateCheckAuto then
	checkUpdate()
	updatePeriodTimer = setTimer(checkUpdate,dgsConfig.updateCheckInterval*3600000,0)
end
	
addCommandHandler("updatedgs",function(player)
	local account = getPlayerAccount(player)
	local accName = getAccountName(account)
	local isAdmin = isObjectInACLGroup("user."..accName,aclGetGroup("Admin")) or isObjectInACLGroup("user."..accName,aclGetGroup("Console"))
	if isAdmin then
		outputDebugString("[DGS]Player "..getPlayerName(player).." attempt to update dgs (Allowed)")
		outputDebugString("[DGS]Preparing for updating dgs")
		outputChatBox("[DGS]Preparing for updating dgs",root,0,255,0)
		if RemoteVersion > Version then
			startUpdate()
		else
			ManualUpdate = true
			checkUpdate()
		end
	else
		outputChatBox("[DGS]Access Denined!",player,255,0,0)
		outputDebugString("[DGS]Player "..getPlayerName(player).." attempt to update dgs (Denied)",2)
	end
end)

function startUpdate()
	ManualUpdate = false
	setTimer(function()
		outputDebugString("[DGS]Downloading meta.xml")
		fetchRemote(dgsConfig.updateCheckURL.."/dgs/meta.xml",function(data,err)
			if err == 0 then
				local meta = fileCreate("updated/meta.xml")
				fileWrite(meta,data)
				fileClose(meta)
				checkFiles()
				outputDebugString("[DGS]Preparing For Checking Files")
			else
				outputDebugString("[DGS]Can't Get meta.xml, Update Failed ("..err..")",2)
			end
		end)
	end,50,1)
end

preUpdate = {}
preUpdateCount = 0
UpdateCount = 0
FetchCount = 0
preFetch = 0
function checkFiles()
	local xml = xmlLoadFile("updated/meta.xml")
	for k,v in pairs(xmlNodeGetChildren(xml)) do
		if xmlNodeGetName(v) == "script" or xmlNodeGetName(v) == "file" then
			local path = xmlNodeGetAttribute(v,"src")
			if path ~= "colorScheme.txt"  then
				local sha = ""
				if fileExists(path) then
					local file = fileOpen(path)
					local text = fileRead(file,fileGetSize(file))
					fileClose(file)
					sha = hash("sha256",text)
				end
				preFetch = preFetch+1
				outputDebugString("[DGS]Checking File ("..preFetch.."): "..path)
				fetchRemote(dgsConfig.updateCheckURL.."/dgsUpdate.php?path="..path,function(data,err,path,sha)
					FetchCount = FetchCount+1
					if sha ~= data then
						outputDebugString("[DGS]Need Update ("..path..")")
						table.insert(preUpdate,path)
					end
					if FetchCount == preFetch then
						table.insert(preUpdate,"colorScheme.txt")
						DownloadFiles()
					end
				end,"",false,path,sha)
			end
		end
	end
	outputDebugString("[DGS]Please Wait...")
end

function DownloadFiles()
	UpdateCount = UpdateCount + 1
	if not preUpdate[UpdateCount] then
		DownloadFinish()
		return
	end
	outputDebugString("[DGS]Download ("..UpdateCount.."/"..(#preUpdate or "Unknown").."): "..tostring(preUpdate[UpdateCount]).."")
	fetchRemote(dgsConfig.updateCheckURL.."/dgs/"..preUpdate[UpdateCount],function(data,err,path)
		if err == 0 then
			local size = 0
			if path == "colorScheme.txt" then
				if not fileExists(path) then
					local file = fileCreate(path)
					fileWrite(file,data)
					local newsize = fileGetSize(file)
					fileClose(file)
					outputDebugString("[DGS]File Got ("..UpdateCount.."/"..#preUpdate.."): "..path.." [ "..size.."B -> "..newsize.."B ]")
				else
					local newsize,size = updateColorScheme(path,data)
					outputDebugString("[DGS]Color Scheme Updated ("..UpdateCount.."/"..#preUpdate.."): "..path.." [ "..size.."B -> "..newsize.."B ]")
				end
			else
				if fileExists(path) then
					local file = fileOpen(path)
					size = fileGetSize(file)
					fileClose(file)
					fileDelete(path)
				end
				local file = fileCreate(path)
				fileWrite(file,data)
				local newsize = fileGetSize(file)
				fileClose(file)
				outputDebugString("[DGS]File Got ("..UpdateCount.."/"..#preUpdate.."): "..path.." [ "..size.."B -> "..newsize.."B ]")
			end
		else
			outputDebugString("[DGS]Download Failed: "..path.." ("..err..")")
		end
		if preUpdate[UpdateCount+1] then
			DownloadFiles()
		else
			DownloadFinish()
		end
	end,"",false,preUpdate[UpdateCount])
end

function updateColorScheme(path,data)
	schemeColor = {}
	local file = fileOpen("colorSchemeIndex.txt")
	local str = fileRead(file,fileGetSize(file))
	local size = fileGetSize(file)
	fileClose(file)
	loadstring(str)()
	-------------------------------------
	local file = fileOpen(path)
	local str = fileRead(file,fileGetSize(file))
	local size = fileGetSize(file)
	fileClose(file)
	if fileExists(path..".bak") then
		fileDelete(path..".bak")
	end
	fileRename(path,path..".bak")
	loadstring(data)()
	loadstring(str)()
	local newData = ""
	local newData_ = ""
	for k,v in pairs(schemeColor) do
		if type(v) == "table" then
			for a,b in pairs(v) do
				if type(b) == "table" then
					local pstr = ""
					for i = 1,#b do
						local cr,cg,cb,ca = fromcolor(b[i])
						pstr = pstr.."tocolor("..cr..","..cg..","..cb..","..ca.."),"
					end
					local pstr = pstr:sub(1,#pstr-1)
					newData = newData.."schemeColor."..k.."."..a.." = {"..pstr.."}".."\n"
				else
					local cr,cg,cb,ca = fromcolor(b)
					newData = newData.."schemeColor."..k.."."..a.." = tocolor("..cr..","..cg..","..cb..","..ca..")\n"
				end
			end
			newData = newData.."\n"
		else
			newData_ = newData_.."schemeColor."..k.." = "..tostring(v).."\n"
		end
	end
	local file = fileCreate(path)
	fileWrite(file,newData..newData_)
	local newsize = fileGetSize(file)
	fileClose(file)
	return newsize,size
end

function DownloadFinish()
	outputDebugString("[DGS]Changing Config File")
	if fileExists("update.cfg") then
		fileDelete("update.cfg")
	end
	local file = fileCreate("update.cfg")
	fileWrite(file,tostring(RemoteVersion))
	fileClose(file)
	if fileExists("meta.xml") then
		fileDelete("meta.xml")
	end
	fileRename("updated/meta.xml","meta.xml")
	outputDebugString("[DGS]Update Complete (Updated "..#preUpdate.." Files)")
	outputDebugString("[DGS]Please Restart DGS")
	outputChatBox("[DGS]Update Complete (Updated "..#preUpdate.." Files)",root,0,255,0)
	preUpdate = {}
	preUpdateCount = 0
	UpdateCount = 0
	FetchCount = 0
	preFetch = 0
end

addCommandHandler("dgsver",function(pla,cmd)
	local vsdd
	if fileExists("update.cfg") then
		local file = fileOpen("update.cfg")
		local vscd = fileRead(file,fileGetSize(file))
		fileClose(file)
		vsdd = tonumber(vscd)
		if vsdd then
			outputDebugString("[DGS]Version: "..vsdd,3)
		else
			outputDebugString("[DGS]Version State is damaged! Please use /updatedgs to update",1)
		end
	else
			outputDebugString("[DGS]Version State is damaged! Please use /updatedgs to update",1)
	end
	if getPlayerName(pla) ~= "Console" then
		if vsdd then
			outputChatBox("[DGS]Version: "..vsdd,pla,0,255,0)
		else
			outputChatBox("[DGS]Version State is damaged! Please use /updatedgs to update",pla,255,0,0)
		end
	end
end)

function fromcolor(int)
	local a,r,g,b
	b,g,r,a = bitExtract(int,0,8),bitExtract(int,8,8),bitExtract(int,16,8),bitExtract(int,24,8)
	return r,g,b,a
end

function tocolor(r,g,b,a)
	local color = a*256^3+r*256^2+g*256+b
	if color > 2147483647 then
		color = color-0xFFFFFFFF-1
	end
	return color
end