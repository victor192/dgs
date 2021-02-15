--Dx Functions
local dxDrawImage = dxDrawImageExt
local dxDrawText = dxDrawText
local dxDrawRectangle = dxDrawRectangle
--
local triggerEvent = triggerEvent
local isElement = isElement
local createElement = createElement
local addEventHandler = addEventHandler
local dgsSetType = dgsSetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsTranslate = dgsTranslate
local calculateGuiPositionSize = calculateGuiPositionSize
local tonumber = tonumber
local assert = assert
local type = type

function dgsCreateWindow(x,y,w,h,text,relative,textColor,titleHeight,titleImage,titleColor,image,color,borderSize,noCloseButton)
	if not(type(x) == "number") then error(dgsGenAsrt(x,"dgsCreateWindow",1,"number")) end
	if not(type(y) == "number") then error(dgsGenAsrt(y,"dgsCreateWindow",2,"number")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsCreateWindow",3,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsCreateWindow",4,"number")) end
	local window = createElement("dgs-dxwindow")
	dgsSetType(window,"dgs-dxwindow")
	dgsSetParent(window,nil,true,true)
	local style = styleSettings.window
	dgsElementData[window] = {
		renderBuffer = {},
		titleImage = titleImage or dgsCreateTextureFromStyle(style.titleImage),
		textColor = tonumber(textColor) or style.textColor,
		titleColorBlur = tonumber(titleColor) or style.titleColorBlur,
		titleColor = tonumber(titleColor) or style.titleColor,
		image = image or dgsCreateTextureFromStyle(style.image),
		color = tonumber(color) or style.color,
		textSize = style.textSize,
		titleHeight = tonumber(titleHeight) or style.titleHeight,
		borderSize = tonumber(borderSize) or style.borderSize,
		ignoreTitle = false,
		colorcoded = false,
		movable = true,
		sizable = true,
		clip = true,
		wordbreak = false,
		alignment = {"center","center"},
		movetyp = false; --false only title;true are al,
		font = style.font or systemFont,
		minSize = {60,60},
		maxSize = {20000,20000},
	}
	dgsAttachToTranslation(window,resourceTranslation[sourceResource or resource])
	if type(text) == "table" then
		dgsElementData[window]._translationText = text
		dgsSetData(window,"text",text)
	else
		dgsSetData(window,"text",tostring(text))
	end
	calculateGuiPositionSize(window,x,y,relative,w,h,relative,true)
	triggerEvent("onDgsCreate",window,sourceResource)
	local createCloseButton = true
	if noCloseButton == nil then
		createCloseButton = style.closeButton
	elseif noCloseButton then
		createCloseButton = false
	end
	if createCloseButton then
		local closeBtn = dgsCreateButton(0,0,40,24,style.closeButtonText,false,window,_,_,_,_,_,_,style.closeButtonColor[1],style.closeButtonColor[2],style.closeButtonColor[3],true)
		addEventHandler("onDgsMouseClickUp",closeBtn,function(button)
			if button == "left" then
				local window = dgsGetParent(source)
				if isElement(window) then dgsCloseWindow(window) end
			end
		end,false)
		dgsElementData[window].closeButtonSize = {40,24,false}
		dgsElementData[window].closeButton = closeBtn
		dgsSetElementAlignment(closeBtn,"right")
		dgsElementData[closeBtn].font = "default-bold"
		dgsElementData[closeBtn].alignment = {"center","center"}
		dgsElementData[closeBtn].ignoreParentTitle = true
	end
	return window
end

function dgsWindowSetCloseButtonEnabled(window,bool)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetCloseButtonEnabled",1,"dgs-dxwindow")) end
	local closeButton = dgsElementData[window].closeButton
	if bool then
		if not isElement(closeButton) then
			local cbSize = dgsElementData[window].closeButtonSize
			local closeBtn = dgsCreateButton(0,0,cbSize[1],cbSize[2],"×",cbSize[3],window,_,_,_,_,_,_,tocolor(200,50,50,255),tocolor(250,20,20,255),tocolor(150,50,50,255),true)
			addEventHandler("onDgsMouseClickUp",closeBtn,function(button)
				if button == "left" then
					local window = dgsGetParent(source)
					if isElement(window) then dgsCloseWindow(window) end
				end
			end,false)
			dgsSetData(window,"closeButton",closeBtn)
			dgsSetData(closeBtn,"ignoreParentTitle",true)
			dgsSetSide(closeBtn,"right",false)
			return true
		end
	else
		if isElement(closeButton) then
			destroyElement(closeButton)
			dgsSetData(window,"closeButton",nil)
			return true
		end
	end
	return false
end

function dgsWindowGetCloseButtonEnabled(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetCloseButtonEnabled",1,"dgs-dxwindow")) end
	return isElement(dgsElementData[window].closeButton)
end

function dgsWindowSetSizable(window,bool)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetSizable",1,"dgs-dxwindow")) end
	return dgsSetData(window,"sizable",bool and true or false)
end

function dgsWindowGetSizable(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetSizable",1,"dgs-dxwindow")) end
	return dgsElementData[window].sizable
end

function dgsWindowGetCloseButton(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetCloseButton",1,"dgs-dxwindow")) end
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		return closeButton
	end
	return false
end

function dgsWindowSetMovable(window,bool)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetMovable",1,"dgs-dxwindow")) end
	return dgsSetData(window,"movable",bool and true or false)
end

function dgsWindowGetMovable(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetMovable",1,"dgs-dxwindow")) end
	return dgsElementData[window].movable
end

function dgsWindowSetCloseButtonSize(window,w,h,relative)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowSetCloseButtonSize",1,"dgs-dxwindow")) end
	if not(type(w) == "number") then error(dgsGenAsrt(w,"dgsWindowSetCloseButtonSize",2,"number")) end
	if not(type(h) == "number") then error(dgsGenAsrt(h,"dgsWindowSetCloseButtonSize",3,"number")) end
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		dgsSetData(window,"closeButtonSize",{w,h,relative and true or false})
		return dgsSetSize(closeButton,w,h,relative and true or false)
	end
	return false
end

function dgsWindowGetCloseButtonSize(window,relative)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsWindowGetCloseButtonSize",1,"dgs-dxwindow")) end
	local closeButton = dgsElementData[window].closeButton
	if isElement(closeButton) then
		return dgsGetSize(closeButton,relative and true or false)
	end
	return false
end

function dgsCloseWindow(window)
	if not(dgsGetType(window) == "dgs-dxwindow") then error(dgsGenAsrt(window,"dgsCloseWindow",1,"dgs-dxwindow")) end
	triggerEvent("onDgsWindowClose",window)
	if not wasEventCancelled() then
		return destroyElement(window)
	end
	return false
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxwindow"] = function(source,x,y,w,h,mx,my,cx,cy,enabledInherited,enabledSelf,eleData,parentAlpha,isPostGUI,rndtgt)
	local img = eleData.image
	local color = applyColorAlpha(eleData.color,parentAlpha)
	local titimg,titleColor,titsize = eleData.titleImage,eleData.isFocused and eleData.titleColor or (eleData.titleColorBlur or eleData.titleColor),eleData.titleHeight
	titleColor = applyColorAlpha(titleColor,parentAlpha)
	if img then
		dxDrawImage(x,y+titsize,w,h-titsize,img,0,0,0,color,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y+titsize,w,h-titsize,color,isPostGUI)
	end
	if titimg then
		dxDrawImage(x,y,w,titsize,titimg,0,0,0,titleColor,isPostGUI,rndtgt)
	else
		dxDrawRectangle(x,y,w,titsize,titleColor,isPostGUI)
	end
	local alignment = eleData.alignment
	local font = eleData.font or systemFont
	local textColor = applyColorAlpha(eleData.textColor,parentAlpha)
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2] or eleData.textSize[1]
	local clip,wordbreak,colorcoded = eleData.clip,eleData.wordbreak,eleData.colorcoded
	local text = eleData.text
	local shadow = eleData.shadow
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		local textX,textY = x,y
		if shadowoffx and shadowoffy and shadowc then
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			local shadowc = applyColorAlpha(shadowc,parentAlpha)
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+titsize+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+titsize-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI)
			end
		end
	end
	dxDrawText(text,x,y,x+w,y+titsize,textColor,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,eleData.colorcoded)
	return rndtgt
end