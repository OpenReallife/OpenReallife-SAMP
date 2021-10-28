/*
####################################################################################################################################
#
# 	OpenReallife | (C) 2021
#   https://github.com/OpenReallife/OpenReallife-SAMP
#
#   SA:MP Reallife Script as OpenSource project.
#   Let's create the best Reallife Script for SA:MP!
#
#   First Version: v21w14a / 10.04.2021
#   Current Version: v21w43a / 27.10.2021
#
####################################################################################################################################
*/

//========== Includes ==========
#include <a_samp>
#include <ocmd>
#include <sscanf2>
#include <a_mysql>
#include <streamer>

#include "../include/mysql_connect.inc" // Database Auth Information

//========== Constants ==========
//Server Variables
#define SERVER_NAME "OpenReallife Server"

//Developer Variables
#define DEVELOPER_NAME "OpenReallife"
#define SCRIPT_VERSION "v21w43a" //v[Year]w[Calendarweek][Revision]
#define COPYRIGHT_YEAR "2021"

//Colors
#define BLACK 0x00000000 //Black
#define WHITE 0xFFFFFFFF //White
#define GRAY 0x8C8C8CFF //Gray
#define RED 0xFF000000 // Red
#define GREEN 0x0DFF0000 //Green
#define BLUE 0x0048FF00 //Blue
#define YELLOW 0xF2FF0000 //Yellow
#define RED_BRIGHT 0xFF0000FF //Bright red
#define GREEN_BRIGHT 0x00FF00FF //Bright green
#define BLUE_BRIGHT 0x0000FFFF //Bright blue
#define GRAY_BRIGHT 0xE6E6E6FF //Bright gray

//User Dialog
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_CARSHOP 3
#define DIALOG_STATS 4


//========== Global Variables ==========
//Enums
enum playerInfo{
	playerID,
	
	bool:isAdmin,
	bool:isAdminDuty,
	
	bool:isModerator,
	bool:isModeratorDuty,
	
	//Account info
	bool:loggedIn,
	skinID,
	level,
	experience,
	
	cashMoney,
	bankMoney,
	
	wantedLevel,
	bool:isCuffed,
	bool:isJailed,
	
	//Faction Information
	factionID,
	factionRank,
	bool:factionOnDuty,
	
	//Position info
	Float:lastPos[3],
	interiorID,
	
	//Server info
	registerDate,
	lastLogin[32],
	playerIP[16]
}

enum buildingEnum{
	Float:b_x,
	Float:b_y,
	Float:b_z,
	Float:b_ix,
	Float:b_iy,
	Float:b_iz,
	b_interior,
	b_name[32],
	b_color
}

enum csVehiclePos{
	bool:isVehicleOnPosition,
	vModel,
	vPrice,
	vOdometer,
	Float:vPosX,
	Float:vPosY,
	Float:vPosZ,
	Float:vPosR,
	vID
}

enum factEnum{
	faction_name[128],
	faction_skin,
	Float:faction_x,
	Float:faction_y,
	Float:faction_z,
	Float:faction_r,
	faction_interior,
	faction_world,
	faction_color,
	faction_money
}

enum vehicleEnum{
	vehE_ID,
 	bool:vehE_isSpawned,
	vehE_serverVehID,
	vehE_modelID,
	vehE_fuel,
	vehE_odometer,
	bool:vehE_isLocked,
	
	bool:vehE_isPrivateVehicle,
	vehE_ownerFactionID,
	vehE_ownerPlayerID,
	
	Float:vehE_parkPosX,
	Float:vehE_parkPosY,
	Float:vehE_parkPosZ,
	Float:vehE_parkPosR,
	
	Float:vehE_lastPosX,
	Float:vehE_lastPosY,
	Float:vehE_lastPosZ,
	Float:vehE_lastPosR,
	
	vehE_color1,
	vehE_color2
}

//Arrays
new bInfo[][buildingEnum] = {
	{1555.0837, -1675.5475, 16.1953, 246.7685, 62.7243, 1003.6406, 6, "Los Santos Police Department", BLUE_BRIGHT}, //LSPD main entrance
	{1482.7832, -1771.7301, 18.7958, 390.0709, 173.8111, 1008.3828, 3, "Los Santos Stadthalle"}, //Townhall main entrance
	{1199.2440, -918.4398, 43.1211, 366.0248, -73.3478, 1001.5078, 10, "Los Santos Burger Shot Nord"}, //BSN main entrance
	{1580.1323, -1636.9937, 13.5517, 214.7067, 81.9221, 1005.0391, 6},
	{1524.4832, -1677.9498, 6.2188, 246.3555, 87.6390, 1003.6406, 6}
};

new fInfo[][factEnum] = {
	{"Civil", 1, 0.0, 0.0, 0.0, 0.0, 0, 0, WHITE},
	{"LSPD", 280, 256.4681, 69.4044, 1003.6406, 91.7022, 6, 0, BLUE_BRIGHT}
};



//Variables
new MySQL:dbhandle;
new pInfo[MAX_PLAYERS][playerInfo];
new cInfo[2000][vehicleEnum];
new csCars[10][csVehiclePos];
new weatherID;
new Text:clockLabel;
new Text:Textdraw0;
new Text:Textdraw1;
new Text:titleLabel;
new Text:titleNameLabel;
new pdGate;
new officeDoor;
new jailDoor1;
new jailDoor2;
new jailDoor3;
new bigJailDoor;
new PlayerText:speedLabel[MAX_PLAYERS];
new PlayerText:odometerLabel[MAX_PLAYERS];
new PlayerText:gasLabel[MAX_PLAYERS];
new PlayerText:engineLabel[MAX_PLAYERS];
new PlayerText:lockedLabel[MAX_PLAYERS];
new globalUsername[MAX_PLAYER_NAME + 1];
new globalString[MAX_PLAYER_NAME + 128];
new bool:isOnDuty;


//========== Forwards ==========
forward OnUserCheck(playerid);
forward OnPasswordResponse(playerid);
forward OnCarshopResponse();
forward SaveCurrentPosition(playerid);
forward second(playerid);
forward alarmTimer(playerid);
forward hour(playerid);
forward speedometerTimer(playerid);
forward isPlayerAtDoor(playerid);
forward initVehicles(playerid);
forward loadVehicles(playerid, rowCount);
forward saveCurrentVehicle(playerid, isPrivateVehicle, ownerFactionID, ownerPlayerID);



main()
{
	print("\n-------------------------------------------------------------------");
	print(" " DEVELOPER_NAME " | " SCRIPT_VERSION " | (C) " COPYRIGHT_YEAR);
	print("-------------------------------------------------------------------\n");
}


public OnGameModeInit()
{
	printf("Starting Server...");
	SetGameModeText("Reallife by OpenReallife");
	
	//Database
	dbhandle = mysql_connect(SQL_HOSTNAME, SQL_USERNAME, SQL_PASSWORD, SQL_DATABASE);
	mysql_log(ALL);
	printf("[INIT] Database");
	
	if(mysql_errno() != 0)
	{
	    printf("[DATABASE]: Connection failed to '%s'", SQL_DATABASE);
	    printf("Server stopped!");
	}
	else
	{
	    printf("[DATABASE]: Connection established to '%s'", SQL_DATABASE);
	    
	    AddPlayerClass(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

		//Disabling SingePlayer entities
		ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
		SetNameTagDrawDistance(20.0);
		EnableStuntBonusForAll(0);
		DisableInteriorEnterExits();
		ManualVehicleEngineAndLights();
		printf("[INIT] Disable SinglePlayer entities");

		//Configure World
		new h, m, s;
		gettime(h, m, s);
		SetWorldTime(h);
		printf("[INIT] World time (Set to %i)", h);

		SetWeather(2);
		printf("[INIT] Weather (ID 2)");

		setServerWelcomeDisplay();
		loadPDObjects();


		//Load Building entrance pickups
		for(new i = 0; i < sizeof(bInfo); i++)
		{
		    //Entrance
	 		CreatePickup(1239, 1, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z]);
	 		Create3DTextLabel(bInfo[i][b_name], bInfo[i][b_color], bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z], 10, 0, 0);

	 		//Exit (interior)
	 		CreatePickup(1239, 1, bInfo[i][b_ix], bInfo[i][b_iy], bInfo[i][b_iz]);
		}
		printf("[INIT] %i Entrance/Exit Pickups", sizeof(bInfo));


		//DEVELOPMENT Duty Pickup
		CreatePickup(1239, 1, 256.4681, 69.4044, 1003.6406); //LSPD Duty Pickup
		Create3DTextLabel("Verwende /duty um den Dienst zu starten oder zu beenden.", WHITE, 256.4681, 69.4044, 1003.6406, 3, 0, 1);


		//Timer
		SetTimer("second", 1000, true);
		SetTimer("hour", 3600000, true);
		SetTimer("speedometerTimer", 100, true);
		printf("[INIT] Timer");


		//Clock
		clockLabel = TextDrawCreate(548.000000, 23.000000, "00:00");
		TextDrawBackgroundColor(clockLabel, 255);
		TextDrawFont(clockLabel, 3);
		TextDrawLetterSize(clockLabel, 0.659999, 2.000000);
		TextDrawColor(clockLabel, -1);
		TextDrawSetOutline(clockLabel, 1);
		TextDrawSetProportional(clockLabel, 1);
		TextDrawSetSelectable(clockLabel, 0);
		printf("[INIT] Clock");

		new query[256];
		mysql_format(dbhandle, query, sizeof(query), "SELECT * FROM carshop");
		mysql_tquery(dbhandle, query, "OnCarshopResponse");

		mysql_format(dbhandle, query, sizeof(query), "SELECT * FROM vehicle");
		mysql_tquery(dbhandle, query, "initVehicles");


		printf("Server started!");
	}
	
	return 1;
}

isEngineOn(vehID)
{
	new e, l, a, d, b, bb, o;
	GetVehicleParamsEx(vehID, e, l, a, d, b, bb, o);
	
	if(e == 1) return 1;
	return 0;
}

new fuelTimer = 0;
new odometerTimer = 0;
public second(playerid)
{
	new string[128], h, m, s;
	new carID = GetPlayerVehicleID(playerid);
	gettime(h, m, s);
	format(string, sizeof(string), "%02d:%02d", h, m);
	TextDrawSetString(clockLabel, string);
	format(string, sizeof(string), "%i%% Kraftstoff", cInfo[carID-1][vehE_fuel]);
	PlayerTextDrawSetString(playerid, gasLabel[playerid], string);
	format(string, sizeof(string), "%ikm", cInfo[carID-1][vehE_odometer]);
	PlayerTextDrawSetString(playerid, odometerLabel[playerid], string);
	
	//Very simple Fuel counter (Updates Fuel every 120 seconds / -1% every 120 seconds/2 min)
	fuelTimer++;
	if(fuelTimer == 120)
	{
	    fuelTimer = 0;
		if(!isEngineOn(carID))return 1;
		cInfo[carID-1][vehE_fuel]--;
		
		if(cInfo[carID-1][vehE_fuel] == 0)
		{
 	    	format(string, sizeof(string), "Motor aus");
		    PlayerTextDrawHide(playerid, engineLabel[playerid]);
		    PlayerTextDrawSetString(playerid, engineLabel[playerid], string);
		    PlayerTextDrawColor(playerid, engineLabel[playerid], RED_BRIGHT);
		    PlayerTextDrawShow(playerid, engineLabel[playerid]);
		    SendClientMessage(playerid, WHITE, "Der Treibstofftank ist leer!");
		    SetVehicleParamsEx(carID, 0, 0, 0, 0, 0, 0, 0);
		}
	}
	
	//Very simple Odometer (Updates 1km every minute if your speed is equal or above 50km/h or 2km if speed equal or above 120km/h)
	odometerTimer++;
	if(odometerTimer == 60)
	{
	    odometerTimer = 0;
		if(!isEngineOn(carID))return 1;
		if(getPlayerSpeed(playerid) >= 50)
		{
			cInfo[carID-1][vehE_odometer]++;
		}
		else if(getPlayerSpeed(playerid) >= 120)
		{
		    cInfo[carID-1][vehE_odometer] += 2;
		}
	}
	return 1;
}

public hour(playerid)
{
	new h, m, s;
	gettime(h, m, s);
	SetWorldTime(h);
	printf("World time set to %i", h);
	
	weatherID = random(21);
	SetWeather(weatherID);
	printf("Weather set to ID %i", weatherID);
	return 1;
}

public alarmTimer(playerid)
{
    PlayerPlaySound(playerid, 3201, 1554.9617, -1673.9443, 18.4635);
    return 1;
}

public speedometerTimer(playerid)
{
	new string[128];
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerConnected(i))continue;
	    if(!IsPlayerInAnyVehicle(i))continue;
	    format(string, sizeof(string), "%ikm/h", getPlayerSpeed(i));
	    PlayerTextDrawSetString(i, speedLabel[playerid], string);
	}
	return 1;
}

public OnGameModeExit()
{
	mysql_close(dbhandle);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	setLoginCamera(playerid);
	print("Camera triggered");
	
	TextDrawShowForPlayer(playerid, titleLabel);
	TextDrawShowForPlayer(playerid, titleNameLabel);

	//Register/Login
	new username[MAX_PLAYER_NAME], query[128];
	GetPlayerName(playerid, username, sizeof(username));
	mysql_format(dbhandle, query, sizeof(query), "SELECT id FROM user WHERE username='%s'", username);
	mysql_tquery(dbhandle, query, "OnUserCheck", "i", playerid);

	return 1;
}

public OnUserCheck(playerid)
{
	print("OnUserCheck called");
	
	new row_count;
	
	cache_get_row_count(row_count);
	if (row_count == 0)
	{
	    printf("Couldn't retrieve row count. User need to register.");
	    format(globalString, sizeof(globalString), "{33AA33}Willkommen auf OpenReallife %s!\n\n {FEFEFE}Bitte w�hle ein Passwort um dich zu registrieren.", globalUsername);
	    ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Auf OpenReallife registrieren", globalString, "{0069FF}Registrieren", "Abbrechen");
	}
	else if (row_count == 1)
	{
	    printf("Retrieve row count. User need login.");
	    format(globalString, sizeof(globalString), "{33AA33}Willkommen zur�ck auf OpenReallife %s!\n\n {FEFEFE}Bitte gib dein Passwort ein um dich einzuloggen.", globalUsername);
	    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Auf OpenReallife einloggen", globalString, "{0069FF}Einloggen", "Abbrechen");
	}
	else
	{
	    SendClientMessage(playerid, RED_BRIGHT, "Ein Fehler ist aufgetreten. Bitte verwende einen anderen Usernamen und versuche es erneut.");
	    printf("[ERROR] There are %d rows in the current result set. More than one id uses the same username.", row_count);
	    Kick(playerid);
	}

	return 1;
}

public OnPlayerConnect(playerid)
{
	SendClientMessage(playerid, BLUE_BRIGHT, "Wilkommen auf OpenReallife!");
	
	SetPlayerColor(playerid, WHITE);
	GetPlayerName(playerid, globalUsername, sizeof(globalUsername));
	
	removeBuildings(playerid);
	
	PlayAudioStreamForPlayer(playerid, "http://inspiredprogrammer.com/api/Welcome.mp3");
	
	setTachometerDisplay(playerid);
	
	return 1;
}

saveLastPosition(playerid)
{
    if(pInfo[playerid][loggedIn] == false) return 1;
    
    GetPlayerPos(playerid, pInfo[playerid][lastPos][0], pInfo[playerid][lastPos][1], pInfo[playerid][lastPos][2]);
    pInfo[playerid][interiorID] = GetPlayerInterior(playerid);
    printf("Saved last Position: %f, %f, %f, %d", pInfo[playerid][lastPos][0], pInfo[playerid][lastPos][1], pInfo[playerid][lastPos][2], GetPlayerInterior(playerid));
    
    new query[128];
    mysql_format(dbhandle, query, sizeof(query), "UPDATE user SET lastPosX='%f', lastPosY='%f', lastPosZ='%f', interiorID='%d' WHERE id='%i'", pInfo[playerid][lastPos][0], pInfo[playerid][lastPos][1], pInfo[playerid][lastPos][2], pInfo[playerid][interiorID], pInfo[playerid][playerID]);
	mysql_tquery(dbhandle, query, "", "", playerid);
    
	return 1;
}

savePlayer(playerid)
{
	new query[128];
	mysql_format(dbhandle, query, sizeof(query), "UPDATE user SET level='%i', factionID='%i', factionRank='%i', lastLogin='%s', playerIP='%s' WHERE id='%i'", pInfo[playerid][level], pInfo[playerid][factionID], pInfo[playerid][factionRank], pInfo[playerid][lastLogin], pInfo[playerid][playerIP], pInfo[playerid][playerID]);
	mysql_tquery(dbhandle, query, "", "", playerid);

	return 1;
}

saveLastVehiclePosition(playerid)
{
	new Float:x, Float:y, Float:z, Float:r;
 	new vehID = GetPlayerVehicleID(playerid);

 	if(!IsPlayerInVehicle(playerid, vehID)) return SendClientMessage(playerid, RED_BRIGHT, "Du bist in keinem Fahrzeug");

	GetVehiclePos(vehID, x, y, z);
	GetVehicleZAngle(vehID, r);
	cInfo[vehID][vehE_parkPosX] = x;
	cInfo[vehID][vehE_parkPosY] = y;
	cInfo[vehID][vehE_parkPosZ] = z;
	cInfo[vehID][vehE_parkPosR] = r;

	new query[256];
	mysql_format(dbhandle, query, sizeof(query), "UPDATE vehicle SET parkPosX='%f', parkPosY='%f', parkPosZ='%f', parkPosR='%f' WHERE serverVehID='%i'", cInfo[vehID][vehE_parkPosX], cInfo[vehID][vehE_parkPosY], cInfo[vehID][vehE_parkPosZ], cInfo[vehID][vehE_parkPosR], vehID);
	mysql_tquery(dbhandle, query, "", "", playerid);

	new string[128];
	format(string, sizeof(string), "%f, %f, %f, %f, %i", cInfo[vehID][vehE_parkPosX], cInfo[vehID][vehE_parkPosY], cInfo[vehID][vehE_parkPosZ], cInfo[vehID][vehE_parkPosR], vehID);
	printf(string);
	
	SendClientMessage(playerid, GREEN_BRIGHT, "Das Fahrzeug wurde an dieser Stelle geparkt!");
        
 	return 1;
}

resetPlayer(playerid)
{
    if(pInfo[playerid][loggedIn] == false) return 1;
    
    pInfo[playerid][loggedIn] = false;
    pInfo[playerid][isAdmin] = false;
    pInfo[playerid][playerID] = 0;
    pInfo[playerid][level] = 0;
    pInfo[playerid][lastPos][0] = 0;
    pInfo[playerid][lastPos][1] = 0;
    pInfo[playerid][lastPos][2] = 0;
    pInfo[playerid][interiorID] = 0;
    
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	PlayerTextDrawDestroy(playerid, gasLabel[playerid]);

	GetPlayerPos(playerid, pInfo[playerid][lastPos][0], pInfo[playerid][lastPos][1], pInfo[playerid][lastPos][2]);
	savePlayer(playerid);
	saveLastPosition(playerid);
	resetPlayer(playerid);
	return 1;
}

isPlayerInFaction(playerid, f_id)
{
	if(pInfo[playerid][factionID] == f_id) return 1;
	return 0;
}

public OnPlayerSpawn(playerid)
{
	showWelcomeScreen(playerid);
	TextDrawHideForPlayer(playerid, titleLabel);
	TextDrawHideForPlayer(playerid, titleNameLabel);

	if(pInfo[playerid][lastPos][0] == 0 && pInfo[playerid][lastPos][1] == 0 && pInfo[playerid][lastPos][2] == 0)
	{
		SetPlayerSkin(playerid, pInfo[playerid][skinID]);
		SetPlayerPos(playerid, 1638.5836, -2241.7380, 13.4981); //Spawnpoint Airport
		SetPlayerFacingAngle(playerid, 114.5038);
	}
	else
	{
	    SetPlayerSkin(playerid, pInfo[playerid][skinID]);
    	SetPlayerPos(playerid, pInfo[playerid][lastPos][0], pInfo[playerid][lastPos][1], pInfo[playerid][lastPos][2]);
    	SetPlayerInterior(playerid, pInfo[playerid][interiorID]);
    }
    
    if(!isPlayerInFaction(playerid, 0))
    {
        new fID;
        fID = pInfo[playerid][factionID];
        //SetPlayerPos(playerid, fInfo[fID][faction_x], fInfo[fID][faction_y], fInfo[fID][faction_z]);
        //SetPlayerFacingAngle(playerid, fInfo[fID][faction_r]);
        //SetPlayerInterior(playerid, fInfo[fID][faction_interior]);
        //SetPlayerVirtualWorld(playerid, fInfo[fID][faction_world]);
        SetPlayerColor(playerid, fInfo[fID][faction_color]);
	}
	
	return 1;
}

public OnCarshopResponse()
{
	new row_count;
	cache_get_row_count(row_count);
	
	printf("Number of Carshop Cars: %i", row_count);
	
	for(new i = 0; i < row_count; i++)
	{
	    cache_get_value_name_int(i, "id", csCars[i][vID]);
		cache_get_value_name_bool(i, "isOnPosition", csCars[i][isVehicleOnPosition]);
		cache_get_value_name_int(i, "model", csCars[i][vModel]);
		cache_get_value_name_int(i, "price", csCars[i][vPrice]);
		cache_get_value_name_int(i, "odometer", csCars[i][vOdometer]);
		cache_get_value_name_float(i, "vPosX", csCars[i][vPosX]);
		cache_get_value_name_float(i, "vPosY", csCars[i][vPosY]);
		cache_get_value_name_float(i, "vPosZ", csCars[i][vPosZ]);
		cache_get_value_name_float(i, "vPosR", csCars[i][vPosR]);
 	}

	return 1;
}

public initVehicles(playerid)
{
	new row_count;
	cache_get_row_count(row_count);

	printf("Number of Cars: %i", row_count);

	for(new i = 0; i < row_count; i++)
	{
	    cache_get_value_name_int(i, "id", cInfo[i][vehE_ID]);
	    printf("%i", cInfo[i][vehE_ID]);
	    cache_get_value_name_int(i, "serverVehID", cInfo[i][vehE_serverVehID]);
	    cache_get_value_name_int(i, "modelID", cInfo[i][vehE_modelID]);
	    cache_get_value_name_int(i, "fuel", cInfo[i][vehE_fuel]);
	    cache_get_value_name_int(i, "odometer", cInfo[i][vehE_odometer]);
	    cache_get_value_name_bool(i, "isLocked", cInfo[i][vehE_isLocked]);
	    cache_get_value_name_bool(i, "isPrivateVehicle", cInfo[i][vehE_isPrivateVehicle]);
	    cache_get_value_name_int(i, "ownerFactionID", cInfo[i][vehE_ownerFactionID]);
	    cache_get_value_name_int(i, "ownerPlayerID", cInfo[i][vehE_ownerPlayerID]);
	    cache_get_value_name_float(i, "parkPosX", cInfo[i][vehE_parkPosX]);
	    cache_get_value_name_float(i, "parkPosY", cInfo[i][vehE_parkPosY]);
	    cache_get_value_name_float(i, "parkPosZ", cInfo[i][vehE_parkPosZ]);
	    cache_get_value_name_float(i, "parkPosR", cInfo[i][vehE_parkPosR]);
	    cache_get_value_name_float(i, "lastPosX", cInfo[i][vehE_lastPosX]);
	    cache_get_value_name_float(i, "lastPosY", cInfo[i][vehE_lastPosY]);
	    cache_get_value_name_float(i, "lastPosZ", cInfo[i][vehE_lastPosZ]);
	    cache_get_value_name_float(i, "lastPosR", cInfo[i][vehE_lastPosR]);
	    cache_get_value_name_int(i, "color1", cInfo[i][vehE_color1]);
	    cache_get_value_name_int(i, "color2", cInfo[i][vehE_color2]);
	    
 	}
 	
	//new query[256];
	//mysql_format(dbhandle, query, sizeof(query), "UPDATE vehicle SET vehicle.id = @count := @count + 1");
	//mysql_tquery(dbhandle, query, "", "", playerid);
 	
 	loadVehicles(playerid, row_count);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}


// ########### Admin Commands ##############
ocmd:aduty(playerid, params[]) //Admin OnDuty
{
	new name[MAX_PLAYER_NAME];
	new string[MAX_PLAYER_NAME + 64];
	GetPlayerName(playerid, name, sizeof(name));
	
	if(pInfo[playerid][isAdmin] == true && isOnDuty == false)
	{
		format(string, sizeof(string), "{FF1E00}[INFORMATION] {FEFEFE}%s ist nun als Admin im Dienst.", name);
		SetPlayerColor(playerid, RED_BRIGHT);
		SendClientMessageToAll(WHITE, string);
		isOnDuty = true;
	}
	else if(pInfo[playerid][isAdmin] == true && isOnDuty == true)
	{
		format(string, sizeof(string), "{FF1E00}[INFORMATION] {FEFEFE}%s ist nicht mehr als Admin im Dienst.", name);
		SetPlayerColor(playerid, WHITE);
		SendClientMessageToAll(WHITE, string);
		isOnDuty = false;
	}
	else
	{
	    SendClientMessage(playerid, WHITE, "Du bist kein Admin.");
	}
	return 1;
}

ocmd:settime(playerid, params[]) //Set Time
{
	new time, string[32];
	sscanf(params, "i", time);
	
	if(pInfo[playerid][isAdmin] == true && isOnDuty == true)
	{
		SetWorldTime(time);
		format(string, sizeof(string), "Zeit auf ID %i gesetzt.", time);
		SendClientMessage(playerid, WHITE, string);
	}
	else
 	{
 	    SendClientMessage(playerid, WHITE, "Du bist kein Admin.");
 	}
	return 1;
}

ocmd:setweather(playerid, params[]) //Set Weather
{
	new setWeatherID = 0, string[32];
	sscanf(params, "i", setWeatherID);

	if(pInfo[playerid][isAdmin] == true && isOnDuty == true)
	{
	    if(setWeatherID > 20) return SendClientMessage(playerid, WHITE, "Wetter IDs nur von [0-20] m�glich.");
		SetWeather(setWeatherID);
		format(string, sizeof(string), "Wetter auf ID %i gesetzt.", setWeatherID);
		SendClientMessage(playerid, WHITE, string);
	}
	else
 	{
 	    SendClientMessage(playerid, WHITE, "Du bist kein Admin.");
 	}
	return 1;
}

ocmd:tp(playerid, params[]) //Teleport to Player
{
	new toPlayerID, string[64], pName[MAX_PLAYER_NAME];
	new Float:px, Float:py, Float:pz;
	sscanf(params, "i", toPlayerID);

	if(pInfo[playerid][isAdmin] == true && isOnDuty == true)
	{
		GetPlayerPos(toPlayerID, px, py, pz);
		SetPlayerPos(playerid, px, py, pz);
		GetPlayerName(toPlayerID, pName, sizeof(pName));
		format(string, sizeof(string), "Du wurdest zur Position des Spielers %s teleportiert", pName);
		SendClientMessage(playerid, WHITE, string);
	}
	else
 	{
 	    SendClientMessage(playerid, WHITE, "Du bist kein Admin.");
 	}
	return 1;
}

ocmd:scv(playerid, params[]) //Save spawned vehicle in Database
{
	new bool:isPrivateVehicle, Float:ownerFactionID, Float:ownerPlayerID;
	SendClientMessage(playerid, WHITE, "/scv [isPrivateVehicle] [ownerFactionID] [ownerPlayerID]");
    sscanf(params, "bii", isPrivateVehicle, ownerFactionID, ownerPlayerID);
    saveCurrentVehicle(playerid, isPrivateVehicle, ownerFactionID, ownerPlayerID);
    return 1;
}
// ########### Admin Commands End ##############

ocmd:wanted(playerid, params[]) //Give Player Wanted
{
	new toPlayerID, wanteds, string[128], reason[32], pName[MAX_PLAYER_NAME], ownName[MAX_PLAYER_NAME];
	sscanf(params, "iis[32]", toPlayerID, wanteds, reason);

	if(pInfo[playerid][factionID] == 1)
	{
		GetPlayerName(toPlayerID, pName, sizeof(pName));
		GetPlayerName(playerid, ownName, sizeof(ownName));
		
		if(pInfo[toPlayerID][wantedLevel] < 6)
		{
			pInfo[toPlayerID][wantedLevel] += wanteds;
			SetPlayerWantedLevel(toPlayerID, wanteds);
		}

		
		format(string, sizeof(string), "{FF9600}[WANTED INFO] {FEFEFE}Officer %s hat dir {FF9600}%i Wanted(s) {FEFEFE}gegeben. Begr�ndung: %s ", ownName, wanteds, reason);
		SendClientMessage(toPlayerID, WHITE, string);
		format(string, sizeof(string), "{2800FF}[LSPD INFO] {FEFEFE}Du hast %s [%i] {2800FF}%i Wanted(s) {FEFEFE}gegeben. Begr�ndung: %s ", pName, toPlayerID, wanteds, reason);
		SendClientMessage(playerid, WHITE, string);
	}
	else
 	{
 	    SendClientMessage(playerid, WHITE, "Du bist kein Polizist.");
 	}
	return 1;
}

ocmd:jail(playerid, params[]) //Give Player Wanted
{
	new toPlayerID, wanteds, string[128], reason[32], pName[MAX_PLAYER_NAME], ownName[MAX_PLAYER_NAME];
	sscanf(params, "i", toPlayerID);

	if(pInfo[playerid][factionID] == 1)
	{
		GetPlayerName(toPlayerID, pName, sizeof(pName));
		GetPlayerName(playerid, ownName, sizeof(ownName));
		pInfo[toPlayerID][wantedLevel] += wanteds;

		format(string, sizeof(string), "{FF9600}[WANTED INFO] {FEFEFE}Officer %s hat dir {FF9600}%i Wanted(s) {FEFEFE}gegeben. Begr�ndung: %s ", ownName, wanteds, reason);
		SendClientMessage(toPlayerID, WHITE, string);
		format(string, sizeof(string), "{2800FF}[LSPD INFO] {FEFEFE}Du hast %s [%i] {2800FF}%i Wanted(s) {FEFEFE}gegeben. Begr�ndung: %s ", pName, toPlayerID, wanteds, reason);
		SendClientMessage(playerid, WHITE, string);
	}
	else
 	{
 	    SendClientMessage(playerid, WHITE, "Du bist kein Polizist.");
 	}
	return 1;
}


//Player Stats
ocmd:stats(playerid, params[])
{
	new string[256];
	format(string, sizeof(string), "Spielder ID:\t %i\nLevel:\t %i\nFraktion ID:\t %i\nLetzte Position:\t [%f][%f][%f]\nRegistrierungsdatum:\t %s", pInfo[playerid][playerID], pInfo[playerid][level], pInfo[playerid][factionID], pInfo[playerid][lastPos][0], pInfo[playerid][lastPos][1], pInfo[playerid][lastPos][2], pInfo[playerid][registerDate]);

    ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_TABLIST, "Spielerinfo",
	string,
	"OK", "");
	return 1;
}

//Enter/Exit Building
ocmd:enter(playerid, params[])
{
	if(GetPlayerInterior(playerid) == 0)
	{
		for(new i = 0; i < sizeof(bInfo); i++)
		{
			if(!IsPlayerInRangeOfPoint(playerid, 2, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z])) continue;
		   	SetPlayerPos(playerid, bInfo[i][b_ix], bInfo[i][b_iy], bInfo[i][b_iz]);
		   	SetPlayerInterior(playerid, bInfo[i][b_interior]);
		   	SetPlayerVirtualWorld(playerid, i);
	   		return 1;
		}
	}
	else if(GetPlayerInterior(playerid) != 0)
	{
		for(new i = 0; i < sizeof(bInfo); i++)
		{
			if(!IsPlayerInRangeOfPoint(playerid, 2, bInfo[i][b_ix], bInfo[i][b_iy], bInfo[i][b_iz])) continue;
			SetPlayerPos(playerid, bInfo[i][b_x], bInfo[i][b_y], bInfo[i][b_z]);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
			return 1;
		}
	}
	return 1;
}

//Start/Stop Engine
ocmd:motor(playerid, params[])
{
	new string[32];

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)return
	    SendClientMessage(playerid, WHITE, "Du bist nicht der Fahrer eines Fahrzeugs.");
	    
	new vehID = GetPlayerVehicleID(playerid),
		tmp_engine,
		tmp_lights,
		tmp_alarm,
		tmp_doors,
		tmp_bonnet,
		tmp_boot,
		tmp_objective;
	
	GetVehicleParamsEx(vehID, tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective);
	
	if(tmp_engine == 1)
	{
	    tmp_engine = 0;
	    format(string, sizeof(string), "Motor aus");
	    PlayerTextDrawHide(playerid, engineLabel[playerid]);
	    PlayerTextDrawSetString(playerid, engineLabel[playerid], string);
	    PlayerTextDrawColor(playerid, engineLabel[playerid], RED_BRIGHT);
	    PlayerTextDrawShow(playerid, engineLabel[playerid]);
	}
	else
	{
	    tmp_engine = 1;
	    format(string, sizeof(string), "Motor an");
	    PlayerTextDrawHide(playerid, engineLabel[playerid]);
	    PlayerTextDrawSetString(playerid, engineLabel[playerid], string);
	    PlayerTextDrawColor(playerid, engineLabel[playerid], GREEN_BRIGHT);
	    PlayerTextDrawShow(playerid, engineLabel[playerid]);
	    
		if(cInfo[vehID-1][vehE_fuel] == 0)
		{
		    tmp_engine = 0;
 	    	format(string, sizeof(string), "Motor aus");
		    PlayerTextDrawHide(playerid, engineLabel[playerid]);
		    PlayerTextDrawSetString(playerid, engineLabel[playerid], string);
		    PlayerTextDrawColor(playerid, engineLabel[playerid], RED_BRIGHT);
		    PlayerTextDrawShow(playerid, engineLabel[playerid]);
		    SendClientMessage(playerid, WHITE, "Der Treibstofftank ist leer!");
		}
	}
	
	SetVehicleParamsEx(vehID, tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective);
	    
	return 1;
}

//Lock/Unlock Vehicle (when sitting in Vehicle)
ocmd:carlock(playerid, params[])
{
    new string[32];

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)return
	    SendClientMessage(playerid, WHITE, "Du bist nicht der Fahrer eines Fahrzeugs.");

	new vehID = GetPlayerVehicleID(playerid);
	new tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective;

	GetVehicleParamsEx(vehID, tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective);
	
	if(tmp_doors == 1)
	{
	    tmp_doors = 0;
	    format(string, sizeof(string), "Aufgeschlossen");
	    PlayerTextDrawHide(playerid, lockedLabel[playerid]);
	    PlayerTextDrawSetString(playerid, lockedLabel[playerid], string);
	    PlayerTextDrawColor(playerid, lockedLabel[playerid], GREEN_BRIGHT);
	    PlayerTextDrawShow(playerid, lockedLabel[playerid]);
	}
	else
	{
	    tmp_doors = 1;
	    format(string, sizeof(string), "Abgeschlossen");
	    PlayerTextDrawHide(playerid, lockedLabel[playerid]);
	    PlayerTextDrawSetString(playerid, lockedLabel[playerid], string);
	    PlayerTextDrawColor(playerid, lockedLabel[playerid], RED_BRIGHT);
	    PlayerTextDrawShow(playerid, lockedLabel[playerid]);
	}

	SetVehicleParamsEx(vehID, tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective);
	
	return 1;
}

//Lock/Unlock Vehicle (when not in Vehicle)
ocmd:carlockoutside(playerid, params[])
{
    new carID, string[32];
    new	tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective;
    sscanf(params, "i", carID);
    
	GetVehicleParamsEx(carID, tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective);

	if(pInfo[playerid][factionID] == cInfo[carID-1][vehE_ownerFactionID] || pInfo[playerid][playerID] == cInfo[carID-1][vehE_ownerPlayerID])
	{
		if(tmp_doors == 1)
		{
		    tmp_doors = 0;
		    SendClientMessage(playerid, GREEN_BRIGHT, "Das Fahrzeug wurde aufgeschlossen.");
		    format(string, sizeof(string), "Aufgeschlossen");
	    	PlayerTextDrawHide(playerid, lockedLabel[playerid]);
	    	PlayerTextDrawSetString(playerid, lockedLabel[playerid], string);
	    	PlayerTextDrawColor(playerid, lockedLabel[playerid], GREEN_BRIGHT);
		}
		else
		{
		    tmp_doors = 1;
		    SendClientMessage(playerid, RED_BRIGHT, "Das Fahrzeug wurde abgeschlossen.");
		    format(string, sizeof(string), "Abgeschlossen");
	    	PlayerTextDrawHide(playerid, lockedLabel[playerid]);
	    	PlayerTextDrawSetString(playerid, lockedLabel[playerid], string);
	    	PlayerTextDrawColor(playerid, lockedLabel[playerid], RED_BRIGHT);
		}

		SetVehicleParamsEx(carID, tmp_engine, tmp_lights, tmp_alarm, tmp_doors, tmp_bonnet, tmp_boot, tmp_objective);

		return 1;
	}
	else
	{
	    SendClientMessage(playerid, WHITE, "Du hast keinen Schl�ssel f�r das Fahrzeug.");

		if(GetPlayerWeapon(playerid) == 4) //Knife as Lockpick
		{
		    new str[128];
   			new rand = random(9999999);
			SetPVarInt(playerid, "carLockNumber", rand);
		    format(str, sizeof(str), "Code zum aufbrechen: %i", rand);
		    SendClientMessage(playerid, WHITE, str);
		}
	    return 1;
	}
}

//Unlock Vehicle without Keys (Steal)
ocmd:unlock(playerid, params[])
{
	new lockNumber = GetPVarInt(playerid, "carLockNumber");
	new inputNumber = random(99999999);
 	new string[32];
	sscanf(params, "i", inputNumber);
	
	if(!IsPlayerInAnyVehicle(playerid))
	{
		new carID = INVALID_VEHICLE_ID;
		new Float:x, Float:y, Float:z;
		new Float:radius = 5;
		GetPlayerPos(playerid, x, y, z);

		for(new i = 0; i < MAX_VEHICLES; i++)
		{
			if(!IsVehicleStreamedIn(i, playerid)) continue;
			if(GetVehicleDistanceFromPoint(i, x, y, z) > radius) continue;
			radius = GetVehicleDistanceFromPoint(i, x, y, z);
			carID = i;
			printf("In func: %i", carID);
		}

		if(carID != INVALID_VEHICLE_ID)
		{
		    if(inputNumber == lockNumber && GetPlayerWeapon(playerid) == 4)
		    {
		        ApplyAnimation(playerid, "ROB_BANK", "CAT_Safe_Open", 4.1, 0, 0, 0, 0, 3500, 1);
				SetVehicleParamsEx(carID, 0, 0, 0, 0, 0, 0, 0);
				SendClientMessage(playerid, WHITE, "Du hast das Fahrzeug aufgebrochen.");
				format(string, sizeof(string), "Aufgeschlossen");
	    		PlayerTextDrawHide(playerid, lockedLabel[playerid]);
	    		PlayerTextDrawSetString(playerid, lockedLabel[playerid], string);
	    		PlayerTextDrawColor(playerid, lockedLabel[playerid], GREEN_BRIGHT);
				return 1;
			}
			else
			{
			    SendClientMessage(playerid, WHITE, "Du konntest das Fahrzeug nicht aufbrechen.");
			    return 1;
			}
		}
	}
	return 1;
}

//On/Off Duty for Fractions
ocmd:duty(playerid, params[])
{
	new playerFacID = pInfo[playerid][factionID];
	if(playerFacID == 0)
	{
		return SendClientMessage(playerid, WHITE, "Du bist in keiner Fraktion");
	}
	else
	{
	    if(pInfo[playerid][factionOnDuty] == false)
	    {
			if(!IsPlayerInRangeOfPoint(playerid, 2, fInfo[playerFacID][faction_x], fInfo[playerFacID][faction_y], fInfo[playerFacID][faction_z]))
			{
				SendClientMessage(playerid, WHITE, "Du bist nicht am richtigen Ort.");
			}
			else
			{
			    SendClientMessage(playerid, WHITE, "Du bist nun im Dienst.");
				pInfo[playerid][factionOnDuty] = true;
			    SetPlayerSkin(playerid, fInfo[playerFacID][faction_skin]);
			}
		}
		else
  		{
 			if(!IsPlayerInRangeOfPoint(playerid, 2, fInfo[playerFacID][faction_x], fInfo[playerFacID][faction_y], fInfo[playerFacID][faction_z]))
			{
				SendClientMessage(playerid, WHITE, "Du bist nicht am richtigen Ort.");
			}
			else
			{
			    SendClientMessage(playerid, WHITE, "Du bist nicht mehr im Dienst.");
				pInfo[playerid][factionOnDuty] = false;
			    SetPlayerSkin(playerid, pInfo[playerid][skinID]);
			}
  		}
	}
	return 1;
}


public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp("/handsup", cmdtext, true) == 0)
	{
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CUFFED);
	    return 1;
	}

	if (strcmp("/pop", cmdtext, true, 10) == 0)
	{
		populateCarShop(playerid);
		SendClientMessageToAll(RED_BRIGHT, "/pop started");
		return 1;
	}
	
	if (strcmp("/bb", cmdtext, true, 10) == 0)
	{
	    new vehID = GetPlayerVehicleID(playerid);
		if(GetVehicleModel(vehID) != 508) return SendClientMessage(playerid, WHITE, "Du ben�tigst einen Wohnwagen");
		PlayAudioStreamForPlayer(playerid, "http://inspiredprogrammer.com/api/BBIntro.mp3", 0, 0, 0, 10, 0);
		return 1;
	}
	
	if (strcmp("/park", cmdtext, true, 10) == 0)
	{
		saveLastVehiclePosition(playerid);
		return 1;
	}
	
	if(pInfo[playerid][factionID] == 1) //LSPD Faction
	{
		if (strcmp(cmdtext, "/gate", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1544.70032, -1630.83423, 13.10000)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(pdGate, 1544.70032, -1630.83423, 13.10000, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 1544.70032, -1630.83423, 13.10000);
	        SendClientMessage(playerid, 0xFF000000, "Gate offen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/gatec", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 10.0, 1544.70032, -1630.83423, 13.10000)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(pdGate, 1544.70032, -1630.83423, 13.10000, 5.0, 0.00000, 90.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 1544.70032, -1630.83423, 13.10000);
	        SendClientMessage(playerid, 0xFF000000, "Gate geschlossen.");
	        return 1;
	    }
	    
	   	if (strcmp(cmdtext, "/do", true) == 0)
	    {
		 	if(!IsPlayerInRangeOfPoint(playerid, 5.0, 244.74249, 72.50200, 1003.84802)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(officeDoor, 244.74249, 72.50200, 1003.84802, 5.0, 0.00000, 0.00000, 0.00000);
			PlayerPlaySound(playerid, 12201, 244.74249, 72.50200, 1003.84802);
	        SendClientMessage(playerid, WHITE, "T�r offen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/dc", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5.0, 244.74249, 72.50200, 1003.84802))return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(officeDoor, 246.40251, 72.50202, 1003.84802, 5.0, 0.00000, 0.00000, 0.00000);
			PlayerPlaySound(playerid, 12201, 244.74249, 72.50200, 1003.84802);
	        SendClientMessage(playerid, WHITE, "T�r geschlossen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/jd1", true) == 0)
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 5.0, 266.30710, 76.8480, 1001.27350)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(jailDoor1, 266.30710, 76.8480, 1001.27350, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 266.30710, 76.8480, 1001.27350);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r 1 offen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/jdc1", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5.0, 266.30710, 78.46800, 1001.27350)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(jailDoor1, 266.30710, 78.46800, 1001.27350, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 266.30710, 76.8480, 1001.27350);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r 1 geschlossen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/jd2", true) == 0)
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 5.0, 266.30710, 81.2610, 1001.27350)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(jailDoor2, 266.30710, 81.2610, 1001.27350, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 266.30710, 81.2610, 1001.27350);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r 2 offen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/jdc2", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5.0, 266.30710, 82.96800, 1001.27350)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(jailDoor2, 266.30710, 82.96800, 1001.27350, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 266.30710, 81.2610, 1001.27350);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r 2 geschlossen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/jd3", true) == 0)
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 5.0, 266.30710, 85.7408, 1001.27350)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(jailDoor3, 266.30710, 85.7408, 1001.27350, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 266.30710, 85.7408, 1001.27350);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r 3 offen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/jdc3", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5.0, 266.30710, 87.46800, 1001.27350)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(jailDoor3, 266.30710, 87.46800, 1001.27350, 5.0, 0.00000, 0.00000, 90.00000);
			PlayerPlaySound(playerid, 12201, 266.30710, 85.7408, 1001.27350);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r 3 geschlossen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/bjd", true) == 0)
	    {
	        if(!IsPlayerInRangeOfPoint(playerid, 5.0, 256.3934, 85.7177, 1002.6555)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(bigJailDoor, 256.3934, 85.7177, 1002.6555, 5.0, 0.00000, 0.00000, 0.00000);
			PlayerPlaySound(playerid, 12201, 258.03339, 85.71773, 1002.65552);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r gro� offen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/bjdc", true) == 0)
	    {
            if(!IsPlayerInRangeOfPoint(playerid, 5.0, 258.03339, 85.71773, 1002.65552)) return SendClientMessage(playerid, WHITE, "Du bist nicht in der n�he!");
			MoveObject(bigJailDoor, 258.03339, 85.71773, 1002.65552, 5.0, 0.00000, 0.00000, 0.00000);
			PlayerPlaySound(playerid, 12201, 258.03339, 85.71773, 1002.65552);
	        SendClientMessage(playerid, WHITE, "Gef�ngnist�r gro� geschlossen");
	        return 1;
	    }

	   	if (strcmp(cmdtext, "/alarm", true) == 0)
	    {
			SetTimer("alarmTimer", 2000, true);
			SendClientMessage(playerid, 0xFF000000, "ALARM!");
			return 1;
	    }
	    
	   	if (strcmp(cmdtext, "/alarm off", true) == 0)
	    {
			SendClientMessage(playerid, 0xFF000000, "ALARM AUS");
			return 1;
	    }
   	}
   	else
   	{
        new string[128];
        format(string, sizeof(string), "Du bist kein Mitglied der Fraktion %s", fInfo[1][faction_name]);
        SendClientMessage(playerid, RED, string);
        return 1;
   	}
    
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public SaveCurrentPosition(playerid)
{
    TextDrawHideForPlayer(playerid, Textdraw0);
    TextDrawHideForPlayer(playerid, Textdraw1);
	saveLastPosition(playerid);
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	//Player Spawned -> OnFoot
	if(oldstate == PLAYER_STATE_SPAWNED && newstate == PLAYER_STATE_ONFOOT)
	{
	    SetTimerEx("SaveCurrentPosition", 5000, false, "i", playerid);
		return 1;
	}

	//Player driver
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new vehID = GetPlayerVehicleID(playerid);
		new engine, l, a, d, b, bo, o;
	
 		for(new i = 0; i < sizeof(csCars); i++)
	    {
	        if(csCars[i][vID] != vehID) continue;
	        if(csCars[i][isVehicleOnPosition] == false) continue;

		 	printf("isOnPos: %d", csCars[i][isVehicleOnPosition]);
		 	printf("vehID: %d", vehID);

	        //Sell procedure
	        new string[256];
	        SetPVarInt(playerid, "buyCarID", i);
	        format(string, sizeof(string), "M�chten Sie das Fahrzeug f�r %i$ kaufen? Kilometerstand: %ikm", csCars[i][vPrice], csCars[i][vOdometer]);
	        ShowPlayerDialog(playerid, DIALOG_CARSHOP, DIALOG_STYLE_MSGBOX, "Autohaus", string, "Ja", "Nein");
	        break;
		}
    	
    	GetVehicleParamsEx(vehID, engine, l, a, d, b, bo, o);
    	
    	if(engine != 1)
    	{
    	    new string[32];
		    format(string, sizeof(string), "Motor aus");
		    PlayerTextDrawHide(playerid, engineLabel[playerid]);
		    PlayerTextDrawSetString(playerid, engineLabel[playerid], string);
		    PlayerTextDrawColor(playerid, engineLabel[playerid], RED_BRIGHT);
		    PlayerTextDrawShow(playerid, engineLabel[playerid]);
		}
  		else
        {
   	    	new string[32];
		    format(string, sizeof(string), "Motor an");
		    PlayerTextDrawHide(playerid, engineLabel[playerid]);
		    PlayerTextDrawSetString(playerid, engineLabel[playerid], string);
		    PlayerTextDrawColor(playerid, engineLabel[playerid], GREEN_BRIGHT);
		    PlayerTextDrawShow(playerid, engineLabel[playerid]);
		}
		
		new str[32];
  		format(str, sizeof(str), "%ikm", cInfo[vehID-1][vehE_odometer]);
  		printf("Veh: %i", cInfo[vehID-1][vehE_odometer]);
	    PlayerTextDrawSetString(playerid, odometerLabel[playerid], str);
	    format(str, sizeof(str), "%i%% Tankinhalt", cInfo[vehID-1][vehE_fuel]);
	    PlayerTextDrawSetString(playerid, gasLabel[playerid], str);
		PlayerTextDrawShow(playerid, speedLabel[playerid]);
		PlayerTextDrawShow(playerid, odometerLabel[playerid]);
		PlayerTextDrawShow(playerid, gasLabel[playerid]);
		PlayerTextDrawShow(playerid, lockedLabel[playerid]);
		
	    return 1;
	}
	
	//Player Driver -> OnFoot
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT)
	{
	    PlayerTextDrawHide(playerid, speedLabel[playerid]);
        PlayerTextDrawHide(playerid, odometerLabel[playerid]);
		PlayerTextDrawHide(playerid, gasLabel[playerid]);
  		PlayerTextDrawHide(playerid, engineLabel[playerid]);
	    PlayerTextDrawHide(playerid, lockedLabel[playerid]);
	    return 1;
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	//Key [Z] pressed (German Keyboard Layout)
	if(newkeys & KEY_YES)
	{
	    if(GetPlayerVehicleID(playerid) != 0)
	    {
	        ocmd_motor(playerid, "");
		}
		else
		{
	    	ocmd_enter(playerid, "");
	    }
	    return 1;
	}
	
	
	//Key [N] pressed (German/US Keyboard Layout)
	if(newkeys & KEY_NO)
	{
	    if(GetPlayerVehicleID(playerid) != 0)
	    {
	        ocmd_carlock(playerid, "");
		}
		else if(!IsPlayerInAnyVehicle(playerid))
		{
		    new carID = INVALID_VEHICLE_ID;
	  		new Float:x, Float:y, Float:z;
	  		new Float:radius = 5;
	  		GetPlayerPos(playerid, x, y, z);
	  		
		    for(new i = 1; i < MAX_VEHICLES; i++)
		    {
		        if(!IsVehicleStreamedIn(i, playerid)) continue;
		        if(GetVehicleDistanceFromPoint(i, x, y, z) > radius) continue;
		        radius = GetVehicleDistanceFromPoint(i, x, y, z);
		        carID = i;
		        printf("In func: %i", carID);
			}
			
			if(carID != INVALID_VEHICLE_ID)
			{
			    new str[10];
			    format(str, sizeof(str), "%i", carID);
			    ocmd_carlockoutside(playerid, str);
			}
		}
  		return 1;
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPasswordResponse(playerid)
{
    new row_count;
	cache_get_row_count(row_count);
	
	if (row_count == 1)
	{
	    new y, m, d, date[32], pIP[16];
     	getdate(y, m, d);
     	format(date, sizeof(date), "%02d/%02d/%d", d, m, y);
	
	    //Password correct
     	SendClientMessage(playerid, GREEN_BRIGHT, "Einloggen erfolgreich!");
     	
     	cache_get_value_name_int(0, "id", pInfo[playerid][playerID]);
        cache_get_value_name_int(0, "skinID", pInfo[playerid][skinID]);
        
        cache_get_value_name_int(0, "factionID", pInfo[playerid][factionID]);
		cache_get_value_name_int(0, "factionRank", pInfo[playerid][factionRank]);
		 
     	StopAudioStreamForPlayer(playerid);
     	TextDrawShowForPlayer(playerid, clockLabel);
     	
    	SpawnPlayer(playerid);
  		pInfo[playerid][loggedIn] = true;
    	
    	cache_get_value_name_float(0, "lastPosX", pInfo[playerid][lastPos][0]);
 		cache_get_value_name_float(0, "lastPosY", pInfo[playerid][lastPos][1]);
		cache_get_value_name_float(0, "lastPosZ", pInfo[playerid][lastPos][2]);
		cache_get_value_name_int(0, "interiorID", pInfo[playerid][interiorID]);
		
		pInfo[playerid][lastLogin] = date;

		GetPlayerIp(playerid, pIP, sizeof(pIP));
		pInfo[playerid][playerIP] = pIP;
	     
	    //DEV
	    GivePlayerMoney(playerid, 500000);
	    GivePlayerWeapon(playerid, 4, 0);
	    //

		cache_get_value_name_bool(0, "isAdmin", pInfo[playerid][isAdmin]);
	}
	else
	{
	    //Password false
	    SendClientMessage(playerid, RED_BRIGHT, "Falsches Passwort. Bitte erneut versuchen.");
	    format(globalString, sizeof(globalString), "{33AA33}Willkommen zur�ck auf OpenReallife %s!\n\n {FEFEFE}Bitte gib dein Passwort ein um dich einzuloggen.", globalUsername);
	    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Auf OpenReallife einloggen", globalString, "{0069FF}Einloggen", "Abbrechen");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//Register Dialog
	if(dialogid == DIALOG_REGISTER)
	{
	    if(response)
	    {
	        new username[MAX_PLAYER_NAME], password[35], query[268];
	        GetPlayerName(playerid, username, sizeof(username));
	        if(strlen(inputtext)>= 3)
	        {
	            new y, m, d, date[265];
	            getdate(y, m, d);
	            format(date, sizeof(date), "%02d/%02d/%d", d, m, y);
	            printf("%02d/%02d/%d", d, m, y);
	            mysql_escape_string(inputtext, password, sizeof(password), dbhandle);                                                                                                                                                                                                                                                                      
				mysql_format(dbhandle, query, sizeof(query), "INSERT INTO user (isAdmin, username, password, skinID, level, cashMoney, bankMoney, factionID, factionRank, lastPosX, lastPosY, lastPosZ, iteriorID, lastLogin, registerDate, playerIP) VALUES ('%i', '%s', MD5('%s'), '%i', '%i', '%i', '%i', '%i', '%i', '%f', '%f', '%f', '%i', '%s', '%s', '%s')", 0, username, password, 1, 0, 5000, 0, 0, 0, 0.0, 0.0, 0.0, 0, date, date, "none");
				mysql_tquery(dbhandle, query, "", "");
				
				print("On Player Request Class after Register");
				new classid = 1;
				OnPlayerRequestClass(playerid, classid);
			}
	        else
	        {
	            SendClientMessage(playerid, RED_BRIGHT, "Das Passwort ist zu kurz! Bitte mindestens 4 Zeichen verwenden.");
        	    format(globalString, sizeof(globalString), "{33AA33}Willkommen auf OpenReallife %s!\n\n {FEFEFE}Bitte w�hle ein Passwort um dich zu registrieren.", globalUsername);
	    		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Auf OpenReallife registrieren", globalString, "{0069FF}Registrieren", "Abbrechen");
			}
		}
		else
		{
		    Kick(playerid);
		}
		return 1;
	}


	//Login Dialog
	if(dialogid == DIALOG_LOGIN)
	{
		if(response)
		{
		    new username[MAX_PLAYER_NAME], password[35], query[128];
	        GetPlayerName(playerid, username, sizeof(username));
	        if(strlen(inputtext)> 0)
	        {
	            mysql_escape_string(inputtext, password, sizeof(password), dbhandle);
				mysql_format(dbhandle, query, sizeof(query), "SELECT * FROM user WHERE username='%s' AND password=MD5('%s')", username, password);
				mysql_tquery(dbhandle, query, "OnPasswordResponse", "i", playerid);
			}
	        else
	        {
	            SendClientMessage(playerid, RED_BRIGHT, "Bitte gib dein Passwort ein.");
       		    format(globalString, sizeof(globalString), "{33AA33}Willkommen zur�ck auf OpenReallife %s!\n\n {FEFEFE}Bitte gib dein Passwort ein um dich einzuloggen.", globalUsername);
	    		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Auf OpenReallife einloggen", globalString, "{0069FF}Einloggen", "Abbrechen");
			}
		}
		else
		{
			Kick(playerid);
		}
	    return 1;
	}
	
	
 	//CarShop Dialog
	if(dialogid == DIALOG_CARSHOP)
	{
		if(response)
		{
		    new id = GetPVarInt(playerid, "buyCarID");
		    if(GetPlayerMoney(playerid) < csCars[id][vPrice])
		    {
		        RemovePlayerFromVehicle(playerid);
		    	SendClientMessage(playerid, WHITE, "Du hast nicht gen�gend Geld.");
		    	return 1;
			}
			else
			{
			    GivePlayerMoney(playerid, -csCars[id][vPrice]);
			    SendClientMessage(playerid, WHITE, "Du hast das Fahrzeug gekauft.");
			    
			    new vehID = GetPlayerVehicleID(playerid);
			    
			    new query[265];
    			mysql_format(dbhandle, query, sizeof(query), "INSERT INTO vehicle (serverVehID, modelID, fuel, odometer, isLocked, isPrivateVehicle, ownerFactionID, ownerPlayerID) VALUES ('%i', '%i', '%i', '%i', '%b', '%b', '%i', '%i')", vehID, csCars[id][vModel], 100, csCars[id][vOdometer], 0, 1, 0, pInfo[playerid][playerID]);
				mysql_tquery(dbhandle, query, "", "", playerid);
				
				csCars[id][isVehicleOnPosition] = false;
			    CreatePickup(1239, 2, csCars[id][vPosX], csCars[id][vPosY], csCars[id][vPosZ], 0);
			    
				mysql_format(dbhandle, query, sizeof(query), "UPDATE carshop SET isOnPosition='%i', model='%i', price='%i', odometer='%i' WHERE id='%i'", csCars[id][isVehicleOnPosition], csCars[id][vModel], csCars[id][vPrice], csCars[id][vOdometer], id + 1);
				mysql_tquery(dbhandle, query, "", "", playerid);
			}
		}
		else
		{
		    RemovePlayerFromVehicle(playerid);
		    SendClientMessage(playerid, WHITE, "Fahrzeug wurde nicht gekauft.");
		}
	}

	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}



//================================== Functions ==================================

populateCarShop(playerid)
{
    for(new i = 0; i < sizeof(csCars); i++)
    {
        if(!csCars[i][isVehicleOnPosition])
        {
            CreatePickup(1239, 0, csCars[i][vPosX], csCars[i][vPosY], csCars[i][vPosZ], 0);
		}
		else
		{
        	csCars[i][vID] = CreateVehicle(csCars[i][vModel], csCars[i][vPosX], csCars[i][vPosY], csCars[i][vPosZ], csCars[i][vPosR], -1, -1, -1, 0);
        }
	}
	return 1;
}


public loadVehicles(playerid, rowCount)
{
    for(new i = 0; i <= rowCount-1; i++)
    {
        if(!cInfo[i][vehE_isPrivateVehicle])
        {
			cInfo[i][vehE_serverVehID] = CreateVehicle(cInfo[i][vehE_modelID], cInfo[i][vehE_parkPosX], cInfo[i][vehE_parkPosY], cInfo[i][vehE_parkPosZ], cInfo[i][vehE_parkPosR], cInfo[i][vehE_color1], cInfo[i][vehE_color2], -1, 0);
			cInfo[i][vehE_isSpawned] = true;
			printf("serverVehID: %i, ModelID: %i", cInfo[i][vehE_serverVehID], cInfo[i][vehE_modelID]);
		}
		else
		{
            cInfo[i][vehE_serverVehID] = 65535;
			cInfo[i][vehE_isSpawned] = false;
		}
		
		new query[256];
		mysql_format(dbhandle, query, sizeof(query), "UPDATE vehicle SET isSpawned='%b', serverVehID='%i' WHERE id='%i'", cInfo[i][vehE_isSpawned], cInfo[i][vehE_serverVehID], i+1);
		mysql_tquery(dbhandle, query, "", "", playerid);
	}
	print("Cars loaded");
	return 1;
}


public saveCurrentVehicle(playerid, isPrivateVehicle, ownerFactionID, ownerPlayerID)
{
	new fuel = 100, odometer = 0;
	new bool:isLocked = false, bool:isPrivateVehicle = false;
	new ownerFactionID, ownerPlayerID;
	new Float:parkPosX, Float:parkPosY, Float:parkPosZ, Float:parkPosR;
	new Float:lastPosX, Float:lastPosY, Float:lastPosZ, Float:lastPosR;
	new color1, color2;
	
	new vehID = GetPlayerVehicleID(playerid);
	new model = GetVehicleModel(vehID);
	GetVehiclePos(vehID, parkPosX, parkPosY, parkPosZ);
	GetVehicleZAngle(vehID, parkPosR);
	
	new query[800];
	mysql_format(dbhandle, query, sizeof(query), "INSERT INTO vehicle (serverVehID, modelID, fuel, odometer, isLocked, isPrivateVehicle, ownerFactionID, ownerPlayerID, parkPosX, parkPosY, parkPosZ, parkPosR, lastPosX, lastPosY, lastPosZ, lastPosR, color1, color2) VALUE (%i, %i, %i, %i, %b, %b, %i, %i, %f, %f, %f, %f, %f, %f, %f, %f, %i, %i)", vehID, model, fuel, odometer, 0, 0, 1, -1, parkPosX, parkPosY, parkPosZ, parkPosR, parkPosX, parkPosY, parkPosZ, parkPosR, 0, 1);
	mysql_tquery(dbhandle, query, "", "", playerid);

	return 1;
}


setLoginCamera(playerid)
{
	new rand = random(5);
	
	switch(rand)
	{
		case 0:
		{
  			SetPlayerCameraPos(playerid, 1229.8470, -1609.3655, 29.7529);
			SetPlayerCameraLookAt(playerid, 1230.5107, -1608.6121, 30.1829);
		}
		case 1:
		{
		    SetPlayerCameraPos(playerid, 907.1270, -1058.7306, 80.7499);
			SetPlayerCameraLookAt(playerid, 908.0257, -1058.2839, 80.7049);
		}
		case 2:
		{
			SetPlayerCameraPos(playerid, -2587.8506, 2269.2458, 57.1260);
			SetPlayerCameraLookAt(playerid, -2587.9497, 2268.2463, 57.2312);
		}
		case 3:
		{
		    SetPlayerCameraPos(playerid, 1702.0625, -1819.9368, 18.6157);
			SetPlayerCameraLookAt(playerid, 1701.6968, -1819.0024, 19.0457);
		}
		case 4:
		{
			SetPlayerCameraPos(playerid, 1968.6445, -1600.9139, 27.6080);
			SetPlayerCameraLookAt(playerid, 1967.8619, -1600.2874, 27.9130);
		}
	}
	return 1;
}


getPlayerSpeed(playerid)
{
	new Float:x, Float:y, Float:z, Float:rtn;
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleVelocity(GetPlayerVehicleID(playerid), x, y, z);
	}
	rtn = floatsqroot(x*x + y*y + z*z);
	return floatround(rtn * 100 * 1.61);
}


setTachometerDisplay(playerid)
{
	//Tacho Label
	speedLabel[playerid] = CreatePlayerTextDraw(playerid, 480.000000, 399.000000, "120km/h");
	PlayerTextDrawBackgroundColor(playerid, speedLabel[playerid], 255);
	PlayerTextDrawFont(playerid, speedLabel[playerid], 1);
	PlayerTextDrawLetterSize(playerid, speedLabel[playerid], 0.470000, 1.600000);
	PlayerTextDrawColor(playerid, speedLabel[playerid], -1);
	PlayerTextDrawSetOutline(playerid, speedLabel[playerid], 1);
	PlayerTextDrawSetProportional(playerid, speedLabel[playerid], 1);
	PlayerTextDrawUseBox(playerid, speedLabel[playerid], 1);
	PlayerTextDrawBoxColor(playerid, speedLabel[playerid], 0x141414FF);
	PlayerTextDrawTextSize(playerid, speedLabel[playerid], 680.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, speedLabel[playerid], 0);
	PlayerTextDrawHide(playerid, speedLabel[playerid]);

	odometerLabel[playerid] = CreatePlayerTextDraw(playerid, 480.000000, 415.000000, "1.254km");
	PlayerTextDrawBackgroundColor(playerid, odometerLabel[playerid], 255);
	PlayerTextDrawFont(playerid, odometerLabel[playerid], 1);
	PlayerTextDrawLetterSize(playerid, odometerLabel[playerid], 0.300000, 1.0999999);
	PlayerTextDrawColor(playerid, odometerLabel[playerid], -1);
	PlayerTextDrawSetOutline(playerid, odometerLabel[playerid], 1);
	PlayerTextDrawSetProportional(playerid, odometerLabel[playerid], 1);
	PlayerTextDrawUseBox(playerid, odometerLabel[playerid], 1);
	PlayerTextDrawBoxColor(playerid, odometerLabel[playerid], 0x141414FF);
	PlayerTextDrawTextSize(playerid, odometerLabel[playerid], 670.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, odometerLabel[playerid], 0);
	PlayerTextDrawHide(playerid, odometerLabel[playerid]);

	gasLabel[playerid] = CreatePlayerTextDraw(playerid, 480.000000, 427.000000, "100% Tankinhalt");
	PlayerTextDrawBackgroundColor(playerid, gasLabel[playerid], 255);
	PlayerTextDrawFont(playerid, gasLabel[playerid], 1);
	PlayerTextDrawLetterSize(playerid, gasLabel[playerid], 0.269999, 1.099999);
	PlayerTextDrawColor(playerid, gasLabel[playerid], -1);
	PlayerTextDrawSetOutline(playerid, gasLabel[playerid], 1);
	PlayerTextDrawSetProportional(playerid, gasLabel[playerid], 1);
	PlayerTextDrawUseBox(playerid, gasLabel[playerid], 1);
	PlayerTextDrawBoxColor(playerid, gasLabel[playerid], 0x141414FF);
	PlayerTextDrawTextSize(playerid, gasLabel[playerid], 669.000000, 20.000000);
	PlayerTextDrawSetSelectable(playerid, gasLabel[playerid], 0);
	PlayerTextDrawHide(playerid, gasLabel[playerid]);
	
	engineLabel[playerid] = CreatePlayerTextDraw(playerid, 480.000000, 385.000000, "Motor aus");
	PlayerTextDrawBackgroundColor(playerid, engineLabel[playerid], 255);
	PlayerTextDrawFont(playerid, engineLabel[playerid], 1);
	PlayerTextDrawLetterSize(playerid, engineLabel[playerid], 0.190000, 0.999999);
	PlayerTextDrawColor(playerid, engineLabel[playerid], RED_BRIGHT);
	PlayerTextDrawSetOutline(playerid, engineLabel[playerid], 1);
	PlayerTextDrawSetProportional(playerid, engineLabel[playerid], 1);
	PlayerTextDrawUseBox(playerid, engineLabel[playerid], 1);
	PlayerTextDrawBoxColor(playerid, engineLabel[playerid], 0x141414FF);
	PlayerTextDrawTextSize(playerid, engineLabel[playerid], 680.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, engineLabel[playerid], 0);
	PlayerTextDrawHide(playerid, engineLabel[playerid]);
	
	lockedLabel[playerid] = CreatePlayerTextDraw(playerid, 541.000000, 385.000000, "Nicht abgeschlossen");
	PlayerTextDrawBackgroundColor(playerid, lockedLabel[playerid], 255);
	PlayerTextDrawFont(playerid, lockedLabel[playerid], 1);
	PlayerTextDrawLetterSize(playerid, lockedLabel[playerid], 0.190000, 0.999999);
	PlayerTextDrawColor(playerid, lockedLabel[playerid], RED_BRIGHT);
	PlayerTextDrawSetOutline(playerid, lockedLabel[playerid], 1);
	PlayerTextDrawSetProportional(playerid, lockedLabel[playerid], 1);
	PlayerTextDrawUseBox(playerid, lockedLabel[playerid], 1);
	PlayerTextDrawBoxColor(playerid, lockedLabel[playerid], 0x141414FF);
	PlayerTextDrawTextSize(playerid, lockedLabel[playerid], 680.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, lockedLabel[playerid], 0);
	PlayerTextDrawHide(playerid, lockedLabel[playerid]);
}


setServerWelcomeDisplay()
{
	titleLabel = TextDrawCreate(195.000000, 103.000000, "Willkommen bei");
	TextDrawBackgroundColor(titleLabel, 255);
	TextDrawFont(titleLabel, 3);
	TextDrawLetterSize(titleLabel, 0.689999, 2.800001);
	TextDrawColor(titleLabel, -1);
	TextDrawSetOutline(titleLabel, 1);
	TextDrawSetProportional(titleLabel, 1);
	TextDrawSetSelectable(titleLabel, 0);

    titleNameLabel = TextDrawCreate(195.000000, 125.000000, "OpenReallife");
	TextDrawBackgroundColor(titleNameLabel, 255);
	TextDrawFont(titleNameLabel, 3);
	TextDrawLetterSize(titleNameLabel, 1.069999, 3.700000);
	TextDrawColor(titleNameLabel, 65535);
	TextDrawSetOutline(titleNameLabel, 1);
	TextDrawSetProportional(titleNameLabel, 1);
	TextDrawSetSelectable(titleNameLabel, 0);
}


showWelcomeScreen(playerid)
{
	new string[MAX_PLAYER_NAME + 1];

    Textdraw0 = TextDrawCreate(627.000000, 341.000000, "WILLKOMMEN");
	TextDrawAlignment(Textdraw0, 3);
	TextDrawBackgroundColor(Textdraw0, 255);
	TextDrawFont(Textdraw0, 3);
	TextDrawLetterSize(Textdraw0, 0.479999, 2.299999);
	TextDrawColor(Textdraw0, -1);
	TextDrawSetOutline(Textdraw0, 1);
	TextDrawSetProportional(Textdraw0, 1);
	TextDrawSetSelectable(Textdraw0, 0);

	GetPlayerName(playerid, string, sizeof(string));
	Textdraw1 = TextDrawCreate(628.000000, 366.000000, string);
	TextDrawAlignment(Textdraw1, 3);
	TextDrawBackgroundColor(Textdraw1, 255);
	TextDrawFont(Textdraw1, 3);
	TextDrawLetterSize(Textdraw1, 0.709999, 2.599998);
	TextDrawColor(Textdraw1, 65535);
	TextDrawSetOutline(Textdraw1, 1);
	TextDrawSetProportional(Textdraw1, 1);
	TextDrawSetSelectable(Textdraw1, 0);

	TextDrawShowForPlayer(playerid, Textdraw0);
	TextDrawShowForPlayer(playerid, Textdraw1);
}


removeBuildings(playerid)
{
    RemoveBuildingForPlayer(playerid, 14843, 266.3516, 81.1953, 1001.2813, 200.0); //Remove LSPD Standard-Cell-Doors
}


loadPDObjects()
{
	//PD Objects
	pdGate = CreateObject(968, 1544.70032, -1630.83423, 13.10000, 0.00000, 90.00000, 90.00000);
	CreateObject(638, 1544.54797, -1622.17651, 13.20120,   0.00000, 0.00000, 0.00000);
	CreateObject(638, 1544.56946, -1619.15186, 13.22120,   0.00000, 0.00000, 0.00000);
	CreateObject(638, 1544.40002, -1634.27832, 13.20120,   0.00000, 0.00000, 0.00000);
	CreateObject(1214, 1544.14832, -1620.63330, 12.40000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.73230, -1618.13818, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.73022, -1619.55444, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.74500, -1621.03174, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.73230, -1618.13818, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.74353, -1622.69214, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.60913, -1633.17615, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.68823, -1635.43958, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1539.66382, -1634.32813, 13.00000,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1546.45959, -1672.49622, 13.96570,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1546.58521, -1678.82312, 13.96570,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1550.97180, -1678.79517, 15.65700,   0.00000, 0.00000, 0.00000);
	CreateObject(19122, 1550.99695, -1672.51538, 15.65700,   0.00000, 0.00000, 0.00000);
	CreateObject(18646, 1554.96167, -1673.94434, 18.46350,   0.00000, -90.00000, 0.00000);
	CreateObject(19967, 1544.14294, -1620.65710, 12.00000,   0.00000, 0.00000, -91.00000);
	CreateObject(19978, 1541.65601, -1617.83911, 12.13450,   0.00000, 0.00000, 0.00000);
	CreateObject(19369, 1545.07922, -9014.19238, 14.19200,   0.00000, 0.00000, 1.02000);
	CreateObject(19368, 1545.04077, -16.95110, 14.13000,   0.00000, 0.00000, 0.00000);
	CreateObject(19371, 1545.06042, -1619.32507, 14.16370,   0.00000, 0.00000, 0.00000);
	CreateObject(19371, 1545.04187, -1636.25769, 14.16370,   0.00000, 0.00000, 0.00000);
	CreateObject(19371, 1545.04297, -1634.46558, 14.16370,   0.00000, 0.00000, 0.00000);
	CreateObject(19371, 1546.60034, -1637.86499, 14.16370,   0.00000, 0.00000, 90.00000);
	CreateObject(19371, 1545.06042, -1621.98511, 14.16370,   0.00000, 0.00000, 0.00000);
	CreateObject(19868, 1545.05811, -1620.74951, 13.47350,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, 1545.03674, -1635.56775, 13.47350,   0.00000, 0.00000, 90.00000);
	CreateObject(1597, 1550.71204, -1620.44946, 15.09420,   0.00000, 0.00000, 90.00000);
	CreateObject(1597, 1573.55347, -1620.40955, 15.09420,   0.00000, 0.00000, 90.00000);
	CreateObject(1597, 1562.20825, -1620.10669, 15.09420,   0.00000, 0.00000, 270.00000);
	CreateObject(19868, 1542.32507, -1617.72961, 13.47350,   0.00000, 0.00000, 180.00000);
	CreateObject(19868, 1539.74463, -1615.14392, 13.47350,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, 1539.74878, -1609.98267, 13.47350,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, 1539.72644, -1605.00928, 13.47350,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, 1542.30920, -1602.42859, 13.47350,   0.00000, 0.00000, 0.00000);
	CreateObject(1569, 1579.44141, -1637.61841, 12.55760,   0.00000, 0.00000, 0.00000);

	//Interior
	CreateObject(2933, 252.81532, 85.70239, 1002.19672,   0.00000, 0.00000, 0.00000);
	CreateObject(2933, 254.98193, 85.70950, 1005.55487,   0.00000, 0.00000, 0.00000);
	CreateObject(1280, 252.19321, 82.22804, 1001.81421,   0.00000, 0.00000, 270.00000);
	CreateObject(1280, 254.86209, 82.25385, 1001.81421,   0.00000, 0.00000, 270.00000);
	CreateObject(1280, 257.47427, 82.24676, 1001.81421,   0.00000, 0.00000, 270.00000);
	
	//Officedoor
	officeDoor = CreateObject(19302, 246.40251, 72.50202, 1003.84802,   0.00000, 0.00000, 0.00000); //Moveable

	//Big Jaildoor
	bigJailDoor = CreateObject(19302, 258.03339, 85.71773, 1002.65552,   0.00000, 0.00000, 0.00000); //Moveable

	//Small Jaildoors
	jailDoor1 = CreateObject(19302, 266.30710, 78.46800, 1001.27350,   0.00000, 0.00000, 90.00000); //Moveable
	jailDoor2 = CreateObject(19302, 266.30710, 82.96800, 1001.27350,   0.00000, 0.00000, 90.00000); //Moveable
	jailDoor3 =CreateObject(19302, 266.30710, 87.46800, 1001.27350,   0.00000, 0.00000, 90.00000); //Moveable
	CreateObject(19302, 266.34711, 81.22800, 1001.27350,   0.00000, 0.00000, 90.00000);
	CreateObject(19302, 266.34711, 76.70800, 1001.27350,   0.00000, 0.00000, 90.00000);
	CreateObject(19302, 266.34711, 85.70800, 1001.27350,   0.00000, 0.00000, 90.00000);
}
