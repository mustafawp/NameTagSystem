db = dbConnect("sqlite","db.db")
klanlar = { }
klantaglar = { }
local klan
local owner
local s = false

function setCargo(player)
	if player then
		if isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Console")) then
			setElementData(player, "cargo", "MG | Sunucu Sahibi")
			setElementData(player, "cargo->cor", {255, 127, 0, 240})
			s = true
		elseif isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("MGyonetim")) then
			setElementData(player, "cargo", "MG | Yönetim Ekibi")
			setElementData(player, "cargo->cor", {255, 255, 0, 240})
			s = true
		elseif getAccountData(getPlayerAccount(player),"ozelnametag") ~= "" then
					local nametag = getAccountData(getPlayerAccount(player),"ozelnametag")
					setElementData(player, "cargo", nametag)
					setElementData(player, "cargo->cor", {255, 0, 0, 240})
					s = true
					elseif getElementData(player, "godMode") == true then
			setElementData(player, "cargo", "     ÖLÜMSÜZ")
			setElementData(player, "cargo->cor", {255, 127, 0, 240})
			S = true
		else
			setElementData(player,"cargo","oyuncu")
		end
		local klani = getElementData(player,"Clan")
		for i = 1, #klanlar do 
		if tostring(klani) == tostring(klanlar[i]) and s == false then
		setElementData(player, "cargo", klantaglar[i])
		setElementData(player, "cargo->cor", {255, 0, 0, 240})
		end
		end
	end
end

setTimer(
function()
	for i, pl in pairs(getElementsByType("player")) do
		if pl ~= (false or nil) then
			setCargo(pl)
		end
	end
end,
3000,
0)

function klanguncelleme(veriler)
	for i = 1, #klanlar do
	table.remove(klanlar, i)
	table.remove(klantaglar, i)
	end
	local secim = dbPoll(veriler,0)
    for i,isim in pairs(secim) do 
		table.insert(klanlar, isim.klanismi)
		table.insert(klantaglar, isim.klanowner)
    end  
end
addEventHandler("onResourceStart",root,function()
	dbQuery(klanguncelleme,db,"SELECT * FROM klans")
end)

function klaneklename(kisi,klanisim,sahip)
	klan = klanisim
	oyun = kisi
	owner = sahip
	for i = 1, #klanlar do
	if tostring(klanlar[i]) == tostring(klanisim) then
		exports.hud:dm("Klanının NameTag 'ı başarıyla değişti.",kisi,255,127,0,true)
		dbExec(db,"UPDATE klans SET klanowner = ? WHERE klanismi = ?",owner,klanisim)
		dbQuery(klanguncelleme,db,"SELECT * FROM klans")
		return
	end
	end
	dbExec(db,"INSERT INTO klans(klanismi,klanowner) VALUES (?,?)",klanisim,sahip)
	dbQuery(klanguncelleme,db,"SELECT * FROM klans")
end

addCommandHandler("kisiselnametagsil",function(oyuncu,cmd,isim)
	local hesap = getAccountName(getPlayerAccount(oyuncu))
	if isObjectInACLGroup("user."..hesap, aclGetGroup("Console")) then
	if isim ~= "" then
		local hespa = getAccount(isim)
		setAccountData(hespa,"ozelnametag","")
		exports.hud:dm("Kişisel NameTag 'ı başarıyla silindi bro. Burak Mrx 'den selamlar",oyuncu,255,127,0,true)
		else
		exports.hud:dm("klan ismi girin.",oyuncu,255,127,0,true)
	end
	else
	exports.hud:dm("Bu komutu kullanamazsın.",oyuncu,255,127,0,true)
	end
end)

addCommandHandler("nametagsil",function(oyuncu,cmd,isim)
	local hesap = getAccountName(getPlayerAccount(oyuncu))
	if isObjectInACLGroup("user."..hesap, aclGetGroup("MGyonetim")) then
	if isim ~= "" then
		dbExec(db,"DELETE FROM klans WHERE klanismi = ? ",isim)
		dbQuery(klanguncelleme,db,"SELECT * FROM klans")
		exports.hud:dm("Klanın NameTag 'ı başarıyla silindi bro. Burak Mrx 'den selamlar",oyuncu,255,127,0,true)
		else
		exports.hud:dm("klan ismi girin.",oyuncu,255,127,0,true)
	end
	else
	exports.hud:dm("Bu komutu kullanamazsın.",oyuncu,255,127,0,true)
	end

end)