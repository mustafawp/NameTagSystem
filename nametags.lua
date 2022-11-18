local drawDistance = 50
g_StreamedInPlayers = {}

function drawHPBar( x, y, v, d)
	if (v > 21.99) then
        r1 = 17
		g1 = 119
		b1 = 255
    elseif (v < 21.99) then
        r1 = 180
		g1 = 25
		b1 = 29
    end
    dxDrawRectangle(x - 37, y + 9, 77, 9, tocolor ( 0, 0, 0, 255-d*5 ))
    dxDrawRectangle(x - 35, y + 11, v/1.26 , 5, tocolor ( 255, 127, 0, 255-d*5 ))
end

function drawArmourBar( x, y, v, d)
    if(v < 0.0) then
        v = 0.0
    elseif(v > 100.0) then
        v = 100.0
    end
    dxDrawRectangle(x - 37, y + 4, 77, 9, tocolor ( 0, 0, 0, 255-d*5 ))
    dxDrawRectangle(x - 35, y + 6, v/1.38 , 5.5, tocolor ( 255, 255, 255, 255-d*5 ))
end

function onClientRender()
  local cx, cy, cz, lx, ly, lz = getCameraMatrix()
  for k, player in ipairs(g_StreamedInPlayers) do
    if isElement(player) and isElementStreamedIn(player) then
      do
        local vx, vy, vz = getPedBonePosition(player, 8)
        local dist = getDistanceBetweenPoints3D(cx, cy, cz, vx, vy, vz)
		--if getElementData(player, "invisiblePlayer") then return false end
        if dist < drawDistance and isLineOfSightClear(cx, cy, cz, vx, vy, vz, true, false, false) then
          local x, y = getScreenFromWorldPosition(vx, vy, vz + 0.32)
		  local xz, yz = getScreenFromWorldPosition(vx, vy, vz + 0.32)
          if x and y then
            local name = getPlayerName(player)
			local name2 = (string.gsub (getPlayerName(player), "#%x%x%x%x%x%x", ""))
            local w = dxGetTextWidth(name2, 1, "default-bold")
            local h = dxGetFontHeight(1, "default-bold")
			local level = getElementData(player,"levelSistem")
			local cargo_player = getElementData(player, "cargo") or ""
			if cargo_player ~= "oyuncu" then
			local cargo_player_cor = getElementData(player, "cargo->cor") or {255, 255, 255, 240}
			dxDrawText(cargo_player, xz - 18 - w / 2, yz - 1 - h - 30, w, h, tocolor(unpack(cargo_player_cor)), 1, "default-bold")
			end
			dxDrawText("#FFFFFF"..name.." #FFFFFF(Lv."..level..")", x - w / 1.5, y - 0 - h - 12, w, h, tocolor(255, 0, 0, 255-dist*2), 1, "default-bold","left","top",false,false,false,true)
			local health = getElementHealth(player)
            local armour = getPedArmor(player)
            if health > 0.0 then
				if getPedStat(player, 24) >= 785 then
					local rate = 460 / getPedStat(player, 24)
					drawHPBar(x, y - 6, health * rate, dist)
				elseif getPedStat(player, 24) >= 679 then
					local rate = 480 / getPedStat(player, 24)
					drawHPBar(x, y - 6, health * rate, dist)
				elseif getPedStat(player, 24) <= 679 then
					local rate = 500 / getPedStat(player, 24)
					drawHPBar(x, y - 6, health * rate, dist)
				end
              if armour > 0.0 then
                drawArmourBar(x, y - 12, armour, dist)
              end		
			end
          end
        end
      end
    else
      table.remove(g_StreamedInPlayers, k)
    end
  end
  end
addEventHandler( "onClientRender", root, onClientRender ,true,"high" )  

addEvent("NameTag:CloseNameTags",true)
addEventHandler("NameTag:CloseNameTags",root,function()
	removeEventHandler("onClientRender", root, onClientRender)
end)

addEvent("NameTag:OpenNameTags",true)
addEventHandler("NameTag:OpenNameTags",root,function()
	addEventHandler("onClientRender", root, onClientRender)
end)
  
  
function onClientElementStreamIn()
  if getElementType(source) == "player" then
    setPlayerNametagShowing(source, false)
    table.insert(g_StreamedInPlayers, source)
  end
end
addEventHandler("onClientElementStreamIn", root, onClientElementStreamIn)

function onClientResourceStart(startedResource)
  visibleTick = getTickCount()
  counter = 0
  normalhealthbar = false
  local players = getElementsByType("player")
  for k, v in ipairs(players) do
    if isElementStreamedIn(v) then
      setPlayerNametagShowing(v, false)
      table.insert(g_StreamedInPlayers, v)
    end
  end
end
addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)