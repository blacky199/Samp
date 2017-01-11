/*
||========================||============================||=========================||
||=====================||[WsR].:: |Whitesharks|Reallife|::.||======================||
||========================||============================||=========================||
||===============############======== © by Whitesharks =====#########=============||
||===============####################################################==============||
||===============### 						                      ###==============||
||===============###  ###         ###  ###########  ############  ###==============||
||===============###  ###         ###  ###########  ############  ###==============||
||===============###  ###         ###  ##           ###       ##  ###==============||
||===============###  ###         ###  ##	        ###       ##  ###==============||
||===============###  ###         ###  ##    	    ###       ##  ###==============||
||===============###  ###   ###   ###  ###########  ############  ###==============||
||===============###  ###   ###   ###  ###########  ############  ###==============||
||===============###  ###   ###   ###           ##  ###  ###      ###==============||
||===============###  ###   ###   ###           ##  ###   ###	  ###==============||
||===============###  ###   ###   ###           ##  ###    ###    ###==============||
||===============###   #############   ###########  ###     ###   ###==============||
||===============###    ###########    ###########  ###      ###  ###==============||
||===============###                                        	  ###==============||
||===============####################################################==============||
||===============############======= and Haubi ========##############==============||
||=========================||============================||========================||
||=========================||    © by BlackFire/haubi    ||========================||
||=========================||============================||========================||
||=========================||============================||========================||
||================|| Scripter BlackFire (in der Woche ugf. 8 Std.)||===============||
||=========================||============================||========================||
teffdgfsdfkf
*/

// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>
#include <dutils>
#include <a_mysql>
#include <zcmd>
#include <md5>
#include <sscanf2>
#include <wssql>
//Defines

//Utils
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

//Colors 
#define Color_Error 0xFF0000FF
#define Color_Info 0x0079FFFF
#define Color_Saccess 0x00BB00FF

//Dalog id´s
#define DIALOG_REGISTER 1
#define DIALOG_LOGIN 2
#define DIALOG_PASSWORT 3
#define DIALOG_SEX 4 
#define DIALOG_CARSHOP 5
//Mysql Data
#define dbhost "5.9.20.170"
#define dbuser "samp"
#define dbpass  "3Nr8fL5Xmswt7j2j"
#define dbdb	"samp"

//Maxs
#define MAX_SFRAKS 20
#define MAX_AUTOHAUS 4


//TextDraw
new PlayerText:BackgroundRight[MAX_PLAYERS];
new PlayerText:BackgroundBottom[MAX_PLAYERS];
new PlayerText:Title[MAX_PLAYERS];
new PlayerText:Login[MAX_PLAYERS];
new PlayerText:Register[MAX_PLAYERS];
new PlayerText:Ts3[MAX_PLAYERS];
new PlayerText:Website[MAX_PLAYERS];
new PlayerText:About[MAX_PLAYERS];
new PlayerText:Abbrechen[MAX_PLAYERS];

new PlayerText:Registerbg[MAX_PLAYERS];
new PlayerText:RegisterTitle[MAX_PLAYERS];
new PlayerText:Enterpw[MAX_PLAYERS];
new PlayerText:RegisterSex[MAX_PLAYERS];
new PlayerText:RegisterWelcome[MAX_PLAYERS];
new PlayerText:RegisterButton[MAX_PLAYERS];



//Player Enum
enum playerInformation
{
	bool:isLoggedin,
	username[MAX_PLAYER_NAME],
	pSkin,
	admin,
	money,
	jId,
	jpay,
	fID,
	sid,
	payday,
	wanted,
	age,
	sex,
	jail
}

enum playerCarInformation
{
	owner[MAX_PLAYER_NAME],
	paintjob, 
	key, 
	Float:parkPosX,
	Float:parkPosY,
	Float:parkPosZ,
	Float:parkRotation
}

new g_playerCarInfo[MAX_PLAYERS][playerCarInformation];

enum jobInformation
{
	jobname[89],
	Float:jobPosX,
	Float:jobPosY,
	Float:jobPosZ,
	jobloan
}

enum sFrakInformation
{
	sID,
	sName[70],
	sLeader[24],
	sloan
} 

enum AutoHausInfo
{
	aName[120],
	Float:ahPosX,
	Float:ahPosY,
	Float:ahPosZ,
	Float:ahsPosX,
	Float:ahsPosY,
	Float:ahsPosZ,
	Float:ahsPosA,
	inhaber[MAX_PLAYER_NAME],
	kasse
}


//News

new g_sFrakInfo[MAX_SFRAKS][sFrakInformation];
new sFrakPickup[MAX_SFRAKS];
new Text3D:sFrakLabel[MAX_SFRAKS];

new VehicleIds[MAX_VEHICLES] = {INVALID_VEHICLE_ID, ...};
//Player News
new g_PlayerInfo[MAX_PLAYERS][playerInformation];
new dbhandle;
new pOnduty[MAX_PLAYERS];
new ahOnline = 0;
new gJobInfo[][jobInformation];

new ACarSiren[MAX_VEHICLES];

//Autoaus
new ahInfo[MAX_AUTOHAUS][AutoHausInfo];

//Forwards
forward LoginTextDraw(playerid);
forward onPasswordResponse(playerid);
forward onPlayerRegister(playerid);
forward getPlayerSFrak(playerid);
forward onRegisterResponse(playerid,pw[]);
//Abfragen
forward onUserCheck(playerid);
forward isPlayerInFrontOfAutohaus(playerid);
forward isAnyPlayerInVehicle(vid);
forward isPlayerInFrontOfJob(playerid,pJob);

//Loading
forward LoadPlayerData(playerid);
forward loadServerJobs();
forward onjobsLoad(is);
forward loadStartsFraktion();
forward LoadedsFraktion();
forward loadAutohaus();
forward onAutoHausLoaded();

//Update
forward UpdatePlayer(playerid);

//@TODO: Autohaus fertig scripten
//@TODO: Jobs scrippten
//@TODO: Fraktionen scripten 
main() 
{
	print("\n----------------------------------");
	print("Whitesharks-Gaming Reallife 1.0");
	print("----------------------------------\n");
}

public OnGameModeInit() 
{
	
	SetGameModeText("WsG Reallife");
	AddPlayerClass(23, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	
	Mysql_Connection();
	
	//lade Staatsfraktion
	loadStartsFraktion();
	
	CreateActor(133,2201.2207,-1970.3649,13.7841,89.3850);
	//Lade Jobs
	loadServerJobs();
	
	//Autohaus 
	loadAutohaus();
	
	
	//Objecte
	
	return 1;
}


public LoginTextDraw(playerid) 
{
	
	new text[150];
	
	BackgroundRight[playerid] = CreatePlayerTextDraw(playerid, 641.666687, 1.500000, "Background Right");
	PlayerTextDrawLetterSize(playerid, BackgroundRight[playerid], 0.000000, 49.415019);
	PlayerTextDrawTextSize(playerid, BackgroundRight[playerid], 491.666656, 0.000000);
	PlayerTextDrawAlignment(playerid, BackgroundRight[playerid], 1);
	PlayerTextDrawColor(playerid, BackgroundRight[playerid], 0);
	PlayerTextDrawUseBox(playerid, BackgroundRight[playerid], true);
	PlayerTextDrawBoxColor(playerid, BackgroundRight[playerid], 102);
	PlayerTextDrawSetShadow(playerid, BackgroundRight[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BackgroundRight[playerid], 0);
	PlayerTextDrawFont(playerid, BackgroundRight[playerid], 0);

	BackgroundBottom[playerid] = CreatePlayerTextDraw(playerid, 494.333312, 415.070587, "Background Bottom");
	PlayerTextDrawLetterSize(playerid, BackgroundBottom[playerid], 0.000000, 3.601027);
	PlayerTextDrawTextSize(playerid, BackgroundBottom[playerid], -2.333333, 0.000000);
	PlayerTextDrawAlignment(playerid, BackgroundBottom[playerid], 1);
	PlayerTextDrawColor(playerid, BackgroundBottom[playerid], 0);
	PlayerTextDrawUseBox(playerid, BackgroundBottom[playerid], true);
	PlayerTextDrawBoxColor(playerid, BackgroundBottom[playerid], 102);
	PlayerTextDrawSetShadow(playerid, BackgroundBottom[playerid], 0);
	PlayerTextDrawSetOutline(playerid, BackgroundBottom[playerid], 0);
	PlayerTextDrawFont(playerid, BackgroundBottom[playerid], 0);
	
	format(text, sizeof(text),"~r~Whitesharks~w~-Gaming");
	Title[playerid] = CreatePlayerTextDraw(playerid, 511.333374, 42.311107, text);
	PlayerTextDrawLetterSize(playerid, Title[playerid], 0.337333, 1.454814);
	PlayerTextDrawAlignment(playerid, Title[playerid], 1);
	PlayerTextDrawColor(playerid, Title[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Title[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Title[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Title[playerid], 51);
	PlayerTextDrawFont(playerid, Title[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Title[playerid], 1);
	
	Login[playerid] = CreatePlayerTextDraw(playerid, 565.333312, 88.355560, "Login");
	PlayerTextDrawLetterSize(playerid, Login[playerid], 0.366333, 1.089777);
	PlayerTextDrawTextSize(playerid, Login[playerid], 10,75);
	PlayerTextDrawAlignment(playerid, Login[playerid], 2);
	PlayerTextDrawColor(playerid, Login[playerid], -1);
	PlayerTextDrawUseBox(playerid, Login[playerid], true);
	PlayerTextDrawBoxColor(playerid, Login[playerid], 50);
	PlayerTextDrawSetShadow(playerid, Login[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Login[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Login[playerid], 255);
	PlayerTextDrawFont(playerid, Login[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Login[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Login[playerid], true);
	
	Register[playerid] = CreatePlayerTextDraw(playerid, 565.333312, 104.948158, "Register");
	PlayerTextDrawLetterSize(playerid, Register[playerid], 0.366333, 1.089777);
	PlayerTextDrawTextSize(playerid, Register[playerid], 10,75);
	PlayerTextDrawAlignment(playerid, Register[playerid], 2);
	PlayerTextDrawColor(playerid, Register[playerid], -1);
	PlayerTextDrawUseBox(playerid, Register[playerid], true);
	PlayerTextDrawBoxColor(playerid, Register[playerid], 50);
	PlayerTextDrawSetShadow(playerid, Register[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Register[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Register[playerid], 51);
	PlayerTextDrawFont(playerid, Register[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Register[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Register[playerid], true);

	Ts3[playerid] = CreatePlayerTextDraw(playerid, 1.666669, 418.133300, "Teamspeak 3 Ip: 5.9.20.170:9987");
	PlayerTextDrawLetterSize(playerid, Ts3[playerid], 0.163333, 1.247407);
	PlayerTextDrawAlignment(playerid, Ts3[playerid], 1);
	PlayerTextDrawColor(playerid, Ts3[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Ts3[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Ts3[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Ts3[playerid], 51);
	PlayerTextDrawFont(playerid, Ts3[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Ts3[playerid], 1);

	Website[playerid] = CreatePlayerTextDraw(playerid, 108.000000, 417.303619, "Website: http://whitesharks-gaming.ws");
	PlayerTextDrawLetterSize(playerid, Website[playerid], 0.250000, 1.388444);
	PlayerTextDrawAlignment(playerid, Website[playerid], 1);
	PlayerTextDrawColor(playerid, Website[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Website[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Website[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Website[playerid], 51);
	PlayerTextDrawFont(playerid, Website[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Website[playerid], 1);
	new query[128];
	format(query,sizeof(query), "SELECT `id` FROM `users` WHERE `username`='%s'",PlayerName(playerid));
	mysql_function_query(dbhandle,query,true,"onUserCheck","i", playerid);
	
	
	
	PlayerTextDrawShow(playerid, BackgroundRight[playerid]);
	PlayerTextDrawShow(playerid, BackgroundRight[playerid]);
	PlayerTextDrawShow(playerid, BackgroundBottom[playerid]);
	PlayerTextDrawShow(playerid, Title[playerid]);
	
	
	
	
	PlayerTextDrawShow(playerid, Ts3[playerid]);
	PlayerTextDrawShow(playerid, Website[playerid]);
	
	SelectTextDraw(playerid,Color_Saccess);
	
	printf("Show Start Textdraw to: %s", PlayerName(playerid));
	return 1;
}

public OnGameModeExit()
{
	mysql_close(dbhandle);
	return 1;
}

public OnPlayerRequestClass(playerid, classid) 
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);

	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(!IsPlayerNPC(playerid)) 
	{		
		SetTimerEx("UpdatePlayer",3600000,true,"i",playerid);
		TogglePlayerSpectating(playerid, 1);
		LoginTextDraw(playerid);		
		return 1;
	}
	
	RemoveBuildingForPlayer(playerid, 4024, 1479.8672, -1790.3984, 56.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 4044, 1481.1875, -1785.0703, 22.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 4057, 1479.5547, -1693.1406, 19.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 1527, 1448.2344, -1755.8984, 14.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 4210, 1479.5625, -1631.4531, 12.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 713, 1457.9375, -1620.6953, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1266, 1538.5234, -1609.8047, 19.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 4229, 1597.9063, -1699.7500, 30.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 4230, 1597.9063, -1699.7500, 30.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 713, 1496.8672, -1707.8203, 13.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, 1393.2734, -1796.3516, 16.9766, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1430.1719, -1719.4688, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1451.6250, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 4002, 1479.8672, -1790.3984, 56.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 3980, 1481.1875, -1785.0703, 22.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 4003, 1481.0781, -1747.0313, 33.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1467.9844, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1485.1719, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1713.5078, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.6953, -1716.7031, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1505.1797, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1713.7031, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1289, 1504.7500, -1711.8828, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1445.0078, -1704.7656, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1702.3594, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1676.6875, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1445.0078, -1692.2344, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1656.2500, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1636.2344, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1445.8125, -1650.0234, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1619.0547, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1443.2031, -1592.9453, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1457.7266, -1710.0625, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1461.6563, -1707.6875, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1704.6406, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1463.0625, -1701.5703, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.6953, -1702.5313, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1457.5547, -1697.2891, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1694.0469, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.3828, -1692.3906, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 4186, 1479.5547, -1693.1406, 19.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1461.1250, -1687.5625, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1463.0625, -1690.6484, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 641, 1458.6172, -1684.1328, 11.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1457.2734, -1666.2969, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1682.7188, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1471.4063, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.3828, -1682.3125, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1458.2578, -1659.2578, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1449.8516, -1655.9375, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1477.9375, -1652.7266, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1479.6094, -1653.2500, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1457.3516, -1650.5703, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1454.4219, -1642.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1467.8516, -1646.5938, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1472.8984, -1651.5078, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1465.9375, -1639.8203, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1466.4688, -1637.9609, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1449.5938, -1635.0469, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1467.7109, -1632.8906, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1465.8906, -1629.9766, 15.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1472.6641, -1627.8828, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1479.4688, -1626.0234, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 3985, 1479.5625, -1631.4531, 12.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 4206, 1479.5547, -1639.6094, 13.6484, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1465.8359, -1608.3750, 15.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1466.4844, -1598.0938, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1451.3359, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1471.3516, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1704.5938, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1494.2109, -1694.4375, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1693.7344, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1496.9766, -1686.8516, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 641, 1494.1406, -1689.2344, 11.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1682.6719, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1480.6094, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1488.2266, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1486.4063, -1651.3906, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1491.3672, -1646.3828, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1493.1328, -1639.4531, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1486.1797, -1627.7656, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1491.2188, -1632.6797, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1494.4141, -1629.9766, 15.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1494.3594, -1608.3750, 15.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1488.5313, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1498.0547, -1598.0938, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1288, 1504.7500, -1705.4063, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1287, 1504.7500, -1704.4688, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1286, 1504.7500, -1695.0547, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1285, 1504.7500, -1694.0391, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1498.9609, -1684.6094, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1504.1641, -1662.0156, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1504.7188, -1670.9219, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1503.1875, -1621.1250, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1501.2813, -1624.5781, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1498.3594, -1616.9688, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1504.8906, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1508.4453, -1668.7422, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1505.6953, -1654.8359, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1508.5156, -1647.8594, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1513.2734, -1642.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1510.8906, -1607.3125, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1721.6328, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1705.2734, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1524.2188, -1693.9688, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1546.6016, -1693.3906, 14.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1547.5703, -1689.9844, 13.0469, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1688.0859, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1546.8672, -1687.1016, 14.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 646, 1545.5234, -1678.8438, 14.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 646, 1553.8672, -1677.7266, 16.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1524.2188, -1673.7109, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 646, 1553.8672, -1673.4609, 16.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1668.0781, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 646, 1545.5625, -1672.2188, 14.0000, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1546.6016, -1664.6250, 14.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 647, 1546.8672, -1658.3438, 14.4375, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1547.5703, -1661.0313, 13.0469, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1647.6406, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1621.9609, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1525.3828, -1611.1563, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1260, 1538.5234, -1609.8047, 19.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1528.9531, -1605.8594, 15.6250, 0.25);
	return 1;
}

stock Mysql_Connection()
{
	dbhandle = mysql_connect(dbhost,dbuser,dbdb,dbpass);
	if(dbhandle) 
	{
		print("[MYSQL] Connected");
		return 1;
	}
	else 
	{
		print("[MYSQL] Could not connect to Server");
		return 1;
	}
}

public OnPlayerDisconnect(playerid, reason)
{
	if(!IsPlayerNPC(playerid)) 
	{
		new string[64], pName[MAX_PLAYER_NAME];
		SavePlayer(playerid);
		GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
		format(string, sizeof(string), "%s has diconnected.", pName);
		SendClientMessageToAll(Color_Info,string);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	
	
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

public OnPlayerCommandText(playerid, cmdtext[])
{
	
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
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

public OnPlayerStateChange(playerid, newstate, oldstate)
{
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
	if(newkeys == KEY_FIRE) 
	{
		
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	
	switch(dialogid)
	{
		case DIALOG_LOGIN:
			if(response)
			{
				if(strlen(inputtext) != 0)
				{
					PlayerTextDrawHide(playerid, BackgroundRight[playerid]);
					PlayerTextDrawHide(playerid, BackgroundRight[playerid]);
					PlayerTextDrawHide(playerid, BackgroundBottom[playerid]);
					PlayerTextDrawHide(playerid, Title[playerid]);
					PlayerTextDrawHide(playerid, Login[playerid]);
					PlayerTextDrawHide(playerid, Register[playerid]);
					PlayerTextDrawHide(playerid, Ts3[playerid]);
					PlayerTextDrawHide(playerid, Website[playerid]);
					PlayerTextDrawHide(playerid, About[playerid]);
					PlayerTextDrawHide(playerid, Abbrechen[playerid]);
					
					
					PlayerLogin(playerid, inputtext);
					
					
				}
				else 
				{
					SendClientMessage(playerid,Color_Error,"Bitte gib dein Passwort ein!");
					ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login","Gebe nun dein Passwort ein","Login","Abbrechen");
				}
			}
			else 
			{
				Kick(playerid);
			}	
			
		case DIALOG_PASSWORT:
			if(response)
			{
				SetPVarString(playerid,"password",inputtext);
				PlayerTextDrawDestroy(playerid,Enterpw[playerid]);
				Enterpw[playerid] = CreatePlayerTextDraw(playerid, 280.333435, 240.177764, inputtext);
				PlayerTextDrawLetterSize(playerid, Enterpw[playerid], 0.250333, 1.421629);
				PlayerTextDrawTextSize(playerid, Enterpw[playerid], 20,90);
				PlayerTextDrawUseBox(playerid, Enterpw[playerid],true);
				PlayerTextDrawAlignment(playerid, Enterpw[playerid], 2);
				PlayerTextDrawColor(playerid, Enterpw[playerid], -16776961);
				PlayerTextDrawSetShadow(playerid, Enterpw[playerid], 0);
				PlayerTextDrawSetOutline(playerid, Enterpw[playerid], 1);
				PlayerTextDrawBackgroundColor(playerid, Enterpw[playerid], 51);
				PlayerTextDrawFont(playerid, Enterpw[playerid], 1);
				PlayerTextDrawSetProportional(playerid, Enterpw[playerid], 1);
				PlayerTextDrawSetSelectable(playerid, Enterpw[playerid], true);
				PlayerTextDrawShow(playerid,Enterpw[playerid]);
				SelectTextDraw(playerid,Color_Saccess);
			}
			
		case DIALOG_SEX:
			if(response)
			{
				if(listitem == 0)
				{
					SetPVarInt(playerid,"sex",1);
					PlayerTextDrawDestroy(playerid,RegisterSex[playerid]);
					RegisterSex[playerid] = CreatePlayerTextDraw(playerid, 386.333404, 238.933349, "Meannlich");
					PlayerTextDrawLetterSize(playerid, RegisterSex[playerid], 0.250333, 1.421628);
					PlayerTextDrawTextSize(playerid, RegisterSex[playerid], 20,90);
					PlayerTextDrawUseBox(playerid, RegisterSex[playerid],true);
					PlayerTextDrawAlignment(playerid, RegisterSex[playerid], 2);
					PlayerTextDrawColor(playerid, RegisterSex[playerid], -16776961);
					PlayerTextDrawSetShadow(playerid, RegisterSex[playerid], 0);
					PlayerTextDrawSetOutline(playerid, RegisterSex[playerid], 1);
					PlayerTextDrawBackgroundColor(playerid, RegisterSex[playerid], 51);
					PlayerTextDrawFont(playerid, RegisterSex[playerid], 1);
					PlayerTextDrawSetProportional(playerid, RegisterSex[playerid], 1);
					PlayerTextDrawSetSelectable(playerid, RegisterSex[playerid], true);
					PlayerTextDrawShow(playerid,RegisterSex[playerid]);
					SelectTextDraw(playerid,Color_Saccess);
				}
				else if(listitem == 1)
				{
					SetPVarInt(playerid, "sex",0);
					PlayerTextDrawDestroy(playerid,RegisterSex[playerid]);
					//Erstelle neue Textdraw für das geschlecht
					RegisterSex[playerid] = CreatePlayerTextDraw(playerid, 386.333404, 238.933349, "Weiblich");
					PlayerTextDrawLetterSize(playerid, RegisterSex[playerid], 0.250333, 1.421628);
					PlayerTextDrawTextSize(playerid, RegisterSex[playerid], 20,90);
					PlayerTextDrawUseBox(playerid, RegisterSex[playerid],true);
					PlayerTextDrawAlignment(playerid, RegisterSex[playerid], 2);
					PlayerTextDrawColor(playerid, RegisterSex[playerid], -16776961);
					PlayerTextDrawSetShadow(playerid, RegisterSex[playerid], 0);
					PlayerTextDrawSetOutline(playerid, RegisterSex[playerid], 1);
					PlayerTextDrawBackgroundColor(playerid, RegisterSex[playerid], 51);
					PlayerTextDrawFont(playerid, RegisterSex[playerid], 1);
					PlayerTextDrawSetProportional(playerid, RegisterSex[playerid], 1);
					PlayerTextDrawSetSelectable(playerid, RegisterSex[playerid], true);
					PlayerTextDrawShow(playerid,RegisterSex[playerid]);
					SelectTextDraw(playerid,Color_Saccess);
				}
			}	
		case DIALOG_CARSHOP:
			if(response)
			{
				if(listitem == 0)
				{
					GivePlayerMoney(playerid, -300000);
					//@TODO: Car System
					new pos1[60],pos2[60],pos3[60],pos4[60],pcarkey;
					pcarkey = countPlayerKeys(playerid);
					for(new i = 0; i < MAX_AUTOHAUS; i++) {
						if(IsPlayerInRangeOfPoint(playerid,4.0,ahInfo[i][ahPosX],ahInfo[i][ahPosY],ahInfo[i][ahPosZ]))
						{
							format(pos1,sizeof(pos1),"%f",ahInfo[i][ahsPosX]);
							format(pos2,sizeof(pos2),"%f",ahInfo[i][ahsPosY]);
							format(pos3,sizeof(pos3),"%f",ahInfo[i][ahsPosZ]);
							format(pos4,sizeof(pos4),"%f",ahInfo[i][ahsPosA]);
							InsertPlayerCar(PlayerName(playerid),1,560,pos1,pos2,pos3,pos4);
							break;
						}
					}
					
				}
			}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	print(error);
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
  
	if(playertextid == Login[playerid]) 
	{
		
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login","Gebe nun dein Passwort ein","Login","Abbrechen");
		CancelSelectTextDraw(playerid);
	}
	else if(playertextid == Register[playerid]) 
	{
		ShowRegister(playerid);
	}
	else if(playertextid == Enterpw[playerid])
	{
		ShowPlayerDialog(playerid,DIALOG_PASSWORT, DIALOG_STYLE_INPUT, "Enter Password","Gebe dein Passwort an","Ok","Abbrechen");
		
	}
	else if(playertextid == RegisterSex[playerid])
	{
		ShowPlayerDialog(playerid,DIALOG_SEX, DIALOG_STYLE_LIST, "Weahle Geschlaecht","Mann\nFrau","Weahlen", "Abbrechen");
	}
	else if(playertextid == RegisterButton[playerid])
	{
		CancelSelectTextDraw(playerid);
		PlayerTextDrawHide(playerid, Registerbg[playerid]);
		PlayerTextDrawHide(playerid, RegisterTitle[playerid]);
		PlayerTextDrawHide(playerid, Enterpw[playerid]);
		PlayerTextDrawHide(playerid, RegisterSex[playerid]);
		PlayerTextDrawHide(playerid, RegisterWelcome[playerid]);
		PlayerTextDrawHide(playerid, RegisterButton[playerid]);
		PlayerTextDrawHide(playerid, BackgroundRight[playerid]);
		PlayerTextDrawHide(playerid, BackgroundRight[playerid]);
		PlayerTextDrawHide(playerid, BackgroundBottom[playerid]);
		PlayerTextDrawHide(playerid, Title[playerid]);
		PlayerTextDrawHide(playerid, Login[playerid]);
		PlayerTextDrawHide(playerid, Register[playerid]);
		PlayerTextDrawHide(playerid, Ts3[playerid]);
		PlayerTextDrawHide(playerid, Website[playerid]);
		PlayerTextDrawHide(playerid, About[playerid]);
		PlayerTextDrawHide(playerid, Abbrechen[playerid]);
		if(GetPVarInt(playerid,"sex") == 1)
		{
			new pw[129];
			GetPVarString(playerid,"password",pw, sizeof(pw));
			RegistPlayer(playerid,pw,1,23);
		}
		else
		{
			new pw[129];
			GetPVarString(playerid,"password",pw, sizeof(pw));
			
			RegistPlayer(playerid,pw,0,12);
		}
	}
    return 1;
}

stock onPCarSave(float:pcPosX,float:pcPosY,float:pcPosZ)
{
	AddStaticVehicle(560,0,0,0,90,1,1);
}

stock SQL_GetInt(TABLE[],FIELD[],WHERE[],Is[])
{
	new query[128],rows,fields, result;
	mysql_real_escape_string(TABLE,TABLE);
	mysql_real_escape_string(FIELD,FIELD);
	mysql_real_escape_string(WHERE,WHERE);
	mysql_real_escape_string(Is,Is);
	if(IsNumeric(Is))
	{
		format(query,sizeof(query), "SELECT `%s` FROM `%s` WHERE `%s`='%i'",TABLE,FIELD,WHERE,Is);
	}
	else 
	{
		format(query,sizeof(query), "SELECT `%s` FROM `%s` WHERE `%s`='%s'",TABLE,FIELD,WHERE,Is);
	}
	mysql_function_query(dbhandle,query,true,"","","");
	cache_get_data(rows,fields,dbhandle);
	result = cache_get_field_content_int(1,  FIELD, dbhandle);
	return result;
}


stock countPlayerKeys(playerid)
{
	new query[128];
	format(query,sizeof(query),"SELECT `key` FROM `cars` WHERE `ower`='%s'",PlayerName(playerid));
	return mysql_num_rows();
}
//Player 
stock InsertPlayerCar(carowner[MAX_PLAYER_NAME],carkey, carid,carPosX[],carPosY[],carPosZ[],carR[])
{
	new query[128],Float:pos1,Float:pos2,Float:pos3;
	format(query,sizeof(query),"INSERT INTO `cars` (`owner`,`carkey`,`carid`,`carPosX`,`carPosY`,`carPosZ`,`carRotation`) VALUES('%s','%i','%i','%s','%s','%s','%s')",carowner,carkey,carid,carPosX,carPosY,carPosZ,carR);
	pos1 = floatstr(carPosX);
	pos2 = floatstr(carPosY);
	pos3 = floatstr(carPosZ);
	mysql_function_query(dbhandle,query,true,"onPCarSave","fff",pos1,pos2,pos3);
	return 1;
}

//Abfragen
public getPlayerSFrak(playerid)
{
	new frak;
	if(g_PlayerInfo[playerid][sid] != 0)
	{
		frak = g_PlayerInfo[playerid][sid];
	}
	return frak;
}

public isPlayerInFrontOfJob(playerid,pJob)
{
	switch(pJob)
	{
		case 1:
			if(IsPlayerInRangeOfPoint(playerid,1.0,2201.2207,-1970.3649,13.7841))
			{
				return 1;
			}
			else
			{
				return 0;
			}
	}
	return 1;
}


public isAnyPlayerInVehicle(vid)
{
	new bool:inVehicle;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerInVehicle(i,vid))
		{
			inVehicle = true;
		}
		else 
		{
			inVehicle = false;
		}
	}
	return inVehicle;
}
stock isPlayerAnAdmin(playerid,level)
{
	if(g_PlayerInfo[playerid][admin] >= level) return 1;
	
	return 0;
}

//Register
stock ShowRegister(playerid)
{
	Registerbg[playerid] = CreatePlayerTextDraw(playerid, 445.000000, 69.529617, "registerbg");
	PlayerTextDrawLetterSize(playerid, Registerbg[playerid], 0.000000, 35.357402);
	PlayerTextDrawTextSize(playerid, Registerbg[playerid], 226.333343, 0.000000);
	PlayerTextDrawAlignment(playerid, Registerbg[playerid], 1);
	PlayerTextDrawColor(playerid, Registerbg[playerid], 0);
	PlayerTextDrawUseBox(playerid, Registerbg[playerid], true);
	PlayerTextDrawBoxColor(playerid, Registerbg[playerid], 102);
	PlayerTextDrawSetShadow(playerid, Registerbg[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Registerbg[playerid], 0);
	PlayerTextDrawFont(playerid, Registerbg[playerid], 0);

	RegisterTitle[playerid] = CreatePlayerTextDraw(playerid, 335.666748, 70.103683, "Register");
	PlayerTextDrawLetterSize(playerid, RegisterTitle[playerid], 0.449999, 1.600000);
	PlayerTextDrawTextSize(playerid, RegisterTitle[playerid], 248.666580, 212.799987);
	PlayerTextDrawAlignment(playerid, RegisterTitle[playerid], 2);
	PlayerTextDrawColor(playerid, RegisterTitle[playerid], -1);
	PlayerTextDrawUseBox(playerid, RegisterTitle[playerid], true);
	PlayerTextDrawBoxColor(playerid, RegisterTitle[playerid], -1940717313);
	PlayerTextDrawSetShadow(playerid, RegisterTitle[playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegisterTitle[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegisterTitle[playerid], 51);
	PlayerTextDrawFont(playerid, RegisterTitle[playerid], 1);
	PlayerTextDrawSetProportional(playerid, RegisterTitle[playerid], 1);


	Enterpw[playerid] = CreatePlayerTextDraw(playerid, 280.333435, 240.177764, "Enter Password...");
	PlayerTextDrawLetterSize(playerid, Enterpw[playerid], 0.250333, 1.421629);
	PlayerTextDrawTextSize(playerid, Enterpw[playerid], 20,90);
	PlayerTextDrawUseBox(playerid, Enterpw[playerid],true);
	PlayerTextDrawAlignment(playerid, Enterpw[playerid], 2);
	PlayerTextDrawColor(playerid, Enterpw[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, Enterpw[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Enterpw[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Enterpw[playerid], 51);
	PlayerTextDrawFont(playerid, Enterpw[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Enterpw[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, Enterpw[playerid], true);



	RegisterSex[playerid] = CreatePlayerTextDraw(playerid, 386.333404, 238.933349, "Geschlecht");
	PlayerTextDrawLetterSize(playerid, RegisterSex[playerid], 0.250333, 1.421628);
	PlayerTextDrawTextSize(playerid, RegisterSex[playerid], 20,90);
	PlayerTextDrawUseBox(playerid, RegisterSex[playerid],true);
	PlayerTextDrawAlignment(playerid, RegisterSex[playerid], 2);
	PlayerTextDrawColor(playerid, RegisterSex[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, RegisterSex[playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegisterSex[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegisterSex[playerid], 51);
	PlayerTextDrawFont(playerid, RegisterSex[playerid], 1);
	PlayerTextDrawSetProportional(playerid, RegisterSex[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, RegisterSex[playerid], true);
	
	new string[200];
	format(string,sizeof(string), "Willkommen %s auf dem~n~Whitesharks-Gaming Reallife Server~n~Wir wuenschen dir viel spass beim Spielen.",PlayerName(playerid));
	RegisterWelcome[playerid] = CreatePlayerTextDraw(playerid, 239.000015, 95.822204, string);
	PlayerTextDrawLetterSize(playerid, RegisterWelcome[playerid], 0.203666, 1.405037);
	PlayerTextDrawAlignment(playerid, RegisterWelcome[playerid], 1);
	PlayerTextDrawColor(playerid, RegisterWelcome[playerid], -1);
	PlayerTextDrawSetShadow(playerid, RegisterWelcome[playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegisterWelcome[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegisterWelcome[playerid], 51);
	PlayerTextDrawFont(playerid, RegisterWelcome[playerid], 1);
	PlayerTextDrawSetProportional(playerid, RegisterWelcome[playerid], 1);

	RegisterButton[playerid] = CreatePlayerTextDraw(playerid, 335.666564, 355.081512, "Register");
	PlayerTextDrawLetterSize(playerid, RegisterButton[playerid], 0.450666, 2.690963);
	PlayerTextDrawTextSize(playerid, RegisterButton[playerid], 27.333339, 197.452026);
	PlayerTextDrawAlignment(playerid, RegisterButton[playerid], 2);
	PlayerTextDrawColor(playerid, RegisterButton[playerid], -1);
	PlayerTextDrawUseBox(playerid, RegisterButton[playerid], true);
	PlayerTextDrawBoxColor(playerid, RegisterButton[playerid], -1959067393);
	PlayerTextDrawSetShadow(playerid, RegisterButton[playerid], 0);
	PlayerTextDrawSetOutline(playerid, RegisterButton[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, RegisterButton[playerid], 51);
	PlayerTextDrawFont(playerid, RegisterButton[playerid], 1);
	PlayerTextDrawSetProportional(playerid, RegisterButton[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, RegisterButton[playerid], true);
	
	
	PlayerTextDrawShow(playerid,Registerbg[playerid]);
	PlayerTextDrawShow(playerid,RegisterTitle[playerid]);
	PlayerTextDrawShow(playerid,Enterpw[playerid]);
	PlayerTextDrawShow(playerid,RegisterSex[playerid]);
	PlayerTextDrawShow(playerid,RegisterWelcome[playerid]);
	PlayerTextDrawShow(playerid,RegisterButton[playerid]);
	
	return 1;
}

public onRegisterResponse(playerid, pw[])
{	
	new query[128];
	format(query,sizeof(query),"SELECT * FROM `users` WHERE `username`='%s' AND `password`='%s'",PlayerName(playerid), pw);
	mysql_function_query(dbhandle, query,true, "onPlayerRegister","i", playerid);
	return 1;
}

stock RegistPlayer(playerid, pw[],psex,pskinid)
{
	DeletePVar(playerid,"password");
	DeletePVar(playerid,"sex");
	new hashed[128],mypw[120],query[128];
	hashed = MD5_Hash(pw);
	
	mysql_real_escape_string(hashed,mypw, dbhandle);
	format(query,sizeof(query), "INSERT INTO `users` (`username`,`password`,`sex`,`skinid`) VALUES('%s','%s','%i','%i')",PlayerName(playerid),mypw,psex,pskinid);
	mysql_function_query(dbhandle, query,true, "onRegisterResponse","is", playerid,mypw);
	return 1;
}

public onPlayerRegister(playerid)
{		
	new num_rows,num_fields;	
	cache_get_data(num_rows,num_fields,dbhandle);
	if(num_rows == 1)
	{
		SendClientMessage(playerid,Color_Saccess,"Erfolgreich registriert.");
		g_PlayerInfo[playerid][isLoggedin] = true;
		new string[90];
		format(string,sizeof(string),"%s Joined the Server",PlayerName(playerid));
		SendClientMessageToAll(Color_Info,string);
		printf("%s registerd", PlayerName(playerid));
		LoadPlayerData(playerid);
	}
	else
	{
		SendClientMessage(playerid,Color_Error,"Fehler beim registrieren");
	}
	return 1;
}

//Player Load
public LoadPlayerData(playerid)
{
	if(g_PlayerInfo[playerid][isLoggedin] == true) 
	{
		new num_rows,num_fields;
		cache_get_data(num_rows,num_fields,dbhandle);
		//Lade Spieler daten
		
		cache_get_field_content(0, "username",g_PlayerInfo[playerid][username], dbhandle);
		g_PlayerInfo[playerid][age] = cache_get_field_content_int(0,"age", dbhandle);
		SetPlayerScore(playerid,g_PlayerInfo[playerid][age]);
		SetPVarInt(playerid,"loggedin",1);
		g_PlayerInfo[playerid][payday] = cache_get_field_content_int(0,"payday", dbhandle);
		g_PlayerInfo[playerid][admin] = cache_get_field_content_int(0, "admin", dbhandle);
		SetPVarInt(playerid,"adminlevel", g_PlayerInfo[playerid][admin]);
		g_PlayerInfo[playerid][money] = cache_get_field_content_int(0, "money",dbhandle);
		g_PlayerInfo[playerid][sex] = cache_get_field_content_int(0, "sex",dbhandle);
		g_PlayerInfo[playerid][pSkin] = cache_get_field_content_int(0, "skinid",dbhandle);
		g_PlayerInfo[playerid][fID] = cache_get_field_content_int(0, "fraktion",dbhandle);
		g_PlayerInfo[playerid][sid] = cache_get_field_content_int(0, "staatfrak", dbhandle);
		
		
	

	/*jId,
	jpay,
	fID,
	sid,
	wanted,
	jail*/
		printf("SKin: %i",cache_get_field_content_int(0, "skinid",dbhandle));
		SetPlayerMoney(playerid,g_PlayerInfo[playerid][money]);
		
		PlayerSpawn(playerid);
	}
	else 
	{
		SendClientMessage(playerid,Color_Error,"Daten konnten nicht geladen werden, weil du nicht Online bist!");
		Kick(playerid);
	}
	return 1;
}

//Login 
public onPasswordResponse(playerid)
{
	new num_rows,num_fields;
	cache_get_data(num_rows,num_fields,dbhandle);
	if(num_rows == 1) 
	{	
		new string[90];
		format(string,sizeof(string),"%s Joined the Server",PlayerName(playerid));
		SendClientMessageToAll(Color_Info,string);
		g_PlayerInfo[playerid][isLoggedin] = true;
		printf("%s loggedin", PlayerName(playerid));
		LoadPlayerData(playerid);
	}
	else 
	{
		SendClientMessage(playerid,Color_Error, "Falsches Passwort");
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login","Gebe nun dein Passwort ein","Login","Abbrechen");
	}
	return 1;
}

stock PlayerLogin(playerid, pw[])
{
	new hashed[129],mypw[120],query[128];
	hashed = MD5_Hash(pw);
	
	mysql_real_escape_string(hashed, mypw,dbhandle);	
	
	format(query,sizeof(query),"SELECT * FROM `users` WHERE `username`='%s' AND `password`='%s'",PlayerName(playerid), mypw);
	mysql_function_query(dbhandle, query, true, "onPasswordResponse", "i",playerid);
	return 1;
}

//Player Publics
public UpdatePlayer(playerid)
{

	if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid))
	{
		if(g_PlayerInfo[playerid][isLoggedin] == true)
		{
			SetPlayerScore(playerid,GetPlayerScore(playerid) + 1);
			
			g_PlayerInfo[playerid][age] = GetPlayerScore(playerid);
			/*g_PlayerInfo[playerid][payday] = g_PlayerInfo[playerid][payday] - 1;
			if(g_PlayerInfo[playerid][payday] == 0) 
			{
				
			}*/
			//Format Update Query
			SQL_SetInt(dbhandle,"users", 	"sex",			g_PlayerInfo[playerid][sex],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"fraktion",		g_PlayerInfo[playerid][fID],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"staatfrak",	g_PlayerInfo[playerid][sid],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"admin",		g_PlayerInfo[playerid][admin],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users",	"money", 		GetPlayerMoney(playerid),			"username", PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"age",			g_PlayerInfo[playerid][age],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"jail",			g_PlayerInfo[playerid][jail],		"username",PlayerName(playerid));
			
			SendClientMessage(playerid,Color_Info,"Account gespeichert");
		}
		
		
	}
	return 1;
}

stock SavePlayer(playerid)
{
	if(IsPlayerConnected(playerid) && !IsPlayerNPC(playerid))
	{
		if(g_PlayerInfo[playerid][isLoggedin] == true)
		{
			//Format Update Query
			SQL_SetInt(dbhandle,"users", 	"sex",			g_PlayerInfo[playerid][sex],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"fraktion",		g_PlayerInfo[playerid][fID],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"staatfrak",	g_PlayerInfo[playerid][sid],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"admin",		g_PlayerInfo[playerid][admin],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users",	"money", 		GetPlayerMoney(playerid),			"username", PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"age",			g_PlayerInfo[playerid][age],		"username",PlayerName(playerid));
			SQL_SetInt(dbhandle,"users", 	"jail",			g_PlayerInfo[playerid][jail],		"username",PlayerName(playerid));
			
			SendClientMessage(playerid,Color_Info,"Account gespeichert");
		}	
	}
	return 1;
}

public onUserCheck(playerid)
{
	new num_rows,num_fields;
	cache_get_data(num_rows,num_fields,dbhandle);
	if(num_rows == 0)
	{	
		About[playerid] = CreatePlayerTextDraw(playerid, 565.333312, 121.540718, "About");
		Abbrechen[playerid] = CreatePlayerTextDraw(playerid, 565.333312, 140.207427, "Abbrechen");
		PlayerTextDrawLetterSize(playerid, About[playerid], 0.366333, 1.089777);
		PlayerTextDrawTextSize(playerid, About[playerid], 10, 75);
		PlayerTextDrawAlignment(playerid, About[playerid], 2);
		PlayerTextDrawColor(playerid, About[playerid], -1);
		PlayerTextDrawUseBox(playerid, About[playerid], true);
		PlayerTextDrawBoxColor(playerid, About[playerid], 50);
		PlayerTextDrawSetShadow(playerid, About[playerid], 0);
		PlayerTextDrawSetOutline(playerid, About[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, About[playerid], 51);
		PlayerTextDrawFont(playerid, About[playerid], 1);
		
		PlayerTextDrawSetProportional(playerid, About[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, About[playerid], true);

		
		PlayerTextDrawLetterSize(playerid, Abbrechen[playerid], 0.365333, 1.301333);
		PlayerTextDrawTextSize(playerid, Abbrechen[playerid], 10, 75);
		PlayerTextDrawAlignment(playerid, Abbrechen[playerid], 2);
		PlayerTextDrawColor(playerid, Abbrechen[playerid], -1);
		PlayerTextDrawUseBox(playerid, Abbrechen[playerid], true);
		PlayerTextDrawBoxColor(playerid, Abbrechen[playerid], 50);
		PlayerTextDrawSetShadow(playerid, Abbrechen[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Abbrechen[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Abbrechen[playerid], 51);
		PlayerTextDrawFont(playerid, Abbrechen[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Abbrechen[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, Abbrechen[playerid], true);
		
		PlayerTextDrawShow(playerid, About[playerid]);
		PlayerTextDrawShow(playerid, Abbrechen[playerid]);
		PlayerTextDrawShow(playerid, Register[playerid]);
	}
	else 
	{
		About[playerid] = CreatePlayerTextDraw(playerid, 565.333312, 104.948158 , "About");
		Abbrechen[playerid] = CreatePlayerTextDraw(playerid, 565.333312, 121.540718, "Abbrechen");
		PlayerTextDrawLetterSize(playerid, About[playerid], 0.366333, 1.089777);
		PlayerTextDrawTextSize(playerid, About[playerid], 10, 75);
		PlayerTextDrawAlignment(playerid, About[playerid], 2);
		PlayerTextDrawColor(playerid, About[playerid], -1);
		PlayerTextDrawUseBox(playerid, About[playerid], true);
		PlayerTextDrawBoxColor(playerid, About[playerid], 50);
		PlayerTextDrawSetShadow(playerid, About[playerid], 0);
		PlayerTextDrawSetOutline(playerid, About[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, About[playerid], 51);
		PlayerTextDrawFont(playerid, About[playerid], 1);
		
		PlayerTextDrawSetProportional(playerid, About[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, About[playerid], true);

		
		PlayerTextDrawLetterSize(playerid, Abbrechen[playerid], 0.365333, 1.301333);
		PlayerTextDrawTextSize(playerid, Abbrechen[playerid], 10, 75);
		PlayerTextDrawAlignment(playerid, Abbrechen[playerid], 2);
		PlayerTextDrawColor(playerid, Abbrechen[playerid], -1);
		PlayerTextDrawUseBox(playerid, Abbrechen[playerid], true);
		PlayerTextDrawBoxColor(playerid, Abbrechen[playerid], 50);
		PlayerTextDrawSetShadow(playerid, Abbrechen[playerid], 0);
		PlayerTextDrawSetOutline(playerid, Abbrechen[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, Abbrechen[playerid], 51);
		PlayerTextDrawFont(playerid, Abbrechen[playerid], 1);
		PlayerTextDrawSetProportional(playerid, Abbrechen[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, Abbrechen[playerid], true);
		
		PlayerTextDrawShow(playerid, About[playerid]);
		PlayerTextDrawShow(playerid, Abbrechen[playerid]);
		PlayerTextDrawShow(playerid, Login[playerid]);
		
	}
	return 1;
}

stock PlayerName(playerid)
{
	new pName[MAX_PLAYER_NAME];
	GetPlayerName(playerid,pName,sizeof(pName));
	
	return pName;
}

stock PlayerSpawn(playerid)
{
	TogglePlayerSpectating(playerid,false);
	
	SetSpawnInfo(playerid,0,g_PlayerInfo[playerid][pSkin],1958.3783, 1343.1572, 15.3746, 269.1425,0,0,0,0,0,0);
	SpawnPlayer(playerid);
	
	return 1;
}

//Job
public onjobsLoad()
{
	new rows,fields,x[100],y[100],z[100];
	cache_get_data(rows,fields,dbhandle);
	for(new i = 0; i < rows; i++) {
		cache_get_field_content(i,	"jobname",	gJobInfo[i][jobname]);
		cache_get_field_content(i,	"posX",		x);
		gJobInfo[i][jobPosX] = floatstr(x);
		cache_get_field_content(i,	"posY",		y);
		gJobInfo[i][jobPosY] = floatstr(y);
		cache_get_field_content(i,	"posZ",		z);
		gJobInfo[i][jobPosZ] = floatstr(z);
		cache_get_field_content_int(i, "loan", 	gJobInfo[i][jobloan]);		
		CreatePickup(1212,1,gJobInfo[i][jobPosX],gJobInfo[i][jobPosY],gJobInfo[i][jobPosZ],-1);
	}
	return 1;
}

public loadServerJobs()
{
	new query[128];
	format(query,sizeof(query),"SELECT * FROM `jobs` ORDER BY `jobid` ASC");
	mysql_function_query(dbhandle,query,true,"onjobsLoad"," ","");
	

	return 1;
}

//Fraks
public LoadedsFraktion() 
{
	new rows,field,name[70],leader[14];
	cache_get_data(rows,field,dbhandle);
	for(new i = 0; i < rows; i++)
	{
		g_sFrakInfo[i][sID]= cache_get_field_content_int(i,	"sID",dbhandle);
	
		cache_get_field_content(i, 		"name", name, dbhandle);		
		format(g_sFrakInfo[i][sName],sizeof(name),"%s", name);
		cache_get_field_content(i,		"leader",	leader, dbhandle);
		format(g_sFrakInfo[i][sLeader],sizeof(leader), "%s",leader);
		g_sFrakInfo[i][sloan]= cache_get_field_content_int(i,"loan", dbhandle);

		printf("Staatsfraktion: %s loeaded",g_sFrakInfo[i][sName]);
	
		
	}
	
	return 1;
}

public loadStartsFraktion()
{
	new query[128];
	format(query,sizeof(query), "SELECT * FROM `sFraktion`");
	mysql_function_query(dbhandle,query,true,"LoadedsFraktion","","");
	return 1;
}

//Autohaus
public loadAutohaus()
{
	new query[128];
	format(query,sizeof(query),"SELECT * FROM `autohaus` ORDER BY `id` ASC");
	mysql_function_query(dbhandle,query,true,"onAutoHausLoaded","","");
	return 1;
}

public onAutoHausLoaded()
{
	new rows,fields,posx[60],posy[60],aname[120],ainhaber[24],posz[60],possx[60],possy[60],possz[60],possa[60],text[MAX_3DTEXT_GLOBAL];
	cache_get_data(rows,fields,dbhandle);
	for(new i = 0; i < rows; i++)
	{
		cache_get_field_content(i,		"autohausname",		aname);
		format(ahInfo[i][aName], 120, "%s", aname);
		printf("Name %s",ahInfo[i][aName]);
		cache_get_field_content(i,		"ahPosX",			posx,						dbhandle);
		ahInfo[i][ahPosX] = floatstr(posx);
		cache_get_field_content(i,		"ahPosY",			posy,						dbhandle);
		ahInfo[i][ahPosY] = floatstr(posy);
		cache_get_field_content(i,		"ahPosZ",			posz,						dbhandle);
		ahInfo[i][ahPosZ] = floatstr(posz);
		cache_get_field_content(i,		"ahsPosX",			possx,						dbhandle);
		ahInfo[i][ahsPosX] = floatstr(possx);
		cache_get_field_content(i,		"ahsPosY",			possy,						dbhandle);
		ahInfo[i][ahsPosY] = floatstr(possy);
		cache_get_field_content(i,		"ahsPosZ",			possz,						dbhandle);
		ahInfo[i][ahsPosZ] = floatstr(possz);
		cache_get_field_content(i,		"ahsPosA",			possa,						dbhandle);
		ahInfo[i][ahsPosA] = floatstr(possa);
		cache_get_field_content(i,		"inhaber",		ainhaber,	dbhandle);
		format(ahInfo[i][inhaber], 120, "%s", ainhaber);
		printf("Inhaber: %s", ahInfo[i][inhaber]);
		ahInfo[i][kasse] =cache_get_field_content_int(i,	"kasse",					dbhandle);
		
		sFrakPickup[i] = CreatePickup(1239,0,ahInfo[i][ahPosX],ahInfo[i][ahPosY],ahInfo[i][ahPosZ],0);
		format(text, sizeof text, "~~~~%s~~~~\nGeschaeftsfueher: %s\n/cshop (Wenn Aktiv)",ahInfo[i][aName], ahInfo[i][inhaber]);
		sFrakLabel[i] = Create3DTextLabel(text,Color_Info,ahInfo[i][ahPosX],ahInfo[i][ahPosY],ahInfo[i][ahPosZ],10,0);
	}
}

public isPlayerInFrontOfAutohaus(playerid)
{
	for(new i = 0; i < MAX_AUTOHAUS; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid,4.0,ahInfo[i][ahPosX],ahInfo[i][ahPosY],ahInfo[i][ahPosZ]))
		{
			return 1;			
		}
		else 
		{
			return 0;
		}
	}
	return 0;
}

//Other
stock getComponent(data[],wich, delimiter)
{
	new destination[18][20];
	sscanf(data,"",destination[0],destination[1],destination[2],destination[3],destination[4],destination[5],destination[6],destination[7],destination[8],destination[9],destination[10],destination[11],destination[12],destination[13],destination[14],destination[15],destination[16]);
	return destination[wich];
}

CMD:sduty(playerid,params[])
{
	new string[128];
	switch(g_PlayerInfo[playerid][sid])
	{
		case 0:
			SendClientMessage(playerid,Color_Error,"Du bist in keiner Staatsfraktion!");
		
		case 6:
			if(pOnduty[playerid] == 0)
			{
				if(ahOnline == 0)
				{
					ahOnline = 1;
				}
				pOnduty[playerid] = 1;
				format(string,sizeof(string),"%s %s ist nun OnDuty!",g_sFrakInfo[6][sName],PlayerName(playerid));
				SendClientMessageToAll(Color_Info,string);
			}
			else 
			{
				pOnduty[playerid] = 0;
				format(string, sizeof(string),"%s %s ist nicht mehr OnDuty!",g_sFrakInfo[6][sName],PlayerName(playerid));
				SendClientMessageToAll(Color_Info,string);
				checkAH();
			}
	}
	return 1;
}

stock checkAH()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(g_PlayerInfo[i][sid] == 6)
		{
			if(pOnduty[i] == 0)
			{
				ahOnline = 0;
			}
			else 
			{
				ahOnline = 1;
			}
		}
	}
	return 1;
}

//Commands
CMD:saveacc(playerid,params[])
{
	SavePlayer(playerid);
	return 1;
}

//Admin Commands
CMD:givemoney(playerid,params[])
{
	if(isPlayerAnAdmin(playerid,3))
	{
		new id,pmoney, string[128];
		if(sscanf(params, "ui", id,pmoney)) SendClientMessage(playerid,Color_Info,"Usage: /givemoney <playerid> <money>");
		else if(id == INVALID_PLAYER_ID) SendClientMessage(playerid,Color_Error, "Player not found");
		else
		{
			GivePlayerMoney(id,pmoney);		
			g_PlayerInfo[id][money] = GetPlayerMoney(id);			
			
			format(string,sizeof(string),"Du hast %s %i$ gegeben",PlayerName(id),pmoney);
			SendClientMessage(playerid,Color_Info,string);
			format(string,sizeof(string), "Du hast von %s %i$ bekommen",PlayerName(playerid),pmoney);
			SendClientMessage(playerid,Color_Info,string);
			return 1;
		}
	}
	else
	{
		if(g_PlayerInfo[playerid][admin] == 0) 
		{
			SendClientMessage(playerid,Color_Error,"Du bist kein Admin!");
			return 1;
		}
		else 
		{
			SendClientMessage(playerid,Color_Error,"Dein Admin level ist zu niedrig!");
			return 1;
		}
	}
	return 1;
}

CMD:delacar(playerid,params[])
{
	if(!isPlayerAnAdmin(playerid,3)) 
        return 0;
		
    for(new i = 0; i< sizeof(VehicleIds); i++) 
	{ //Loop through vehicle ids.

        if(VehicleIds[i] != INVALID_VEHICLE_ID) 
		{ //If the given vehicle ID matches with one among the list.

			DestroyObject(ACarSiren[i]);
            DestroyVehicle(VehicleIds[i]); //Destroy vehicle.			
            VehicleIds[i] = INVALID_VEHICLE_ID; //It's VERY IMPORTANT to reset the value of that index!
            SendClientMessage(playerid, -1, "Vehicle has been destroyed successfully!");           
        }
    }
    //If your code reaches here, it means your parameter didn't match with one created or it isn't created.
    //SendClientMessage(playerid, -1, "ERROR : Failed destroying the given vehicle ID.");
    return 1;
}

CMD:makesleader(playerid,params[])
{
	if(!isPlayerAnAdmin(playerid,5))
	{
		return 0;
	}
	new pid,id,string[129];
	if(sscanf(params,"ui",pid,id)) SendClientMessage(playerid,Color_Info,"Usage: /makesleader <playerid> <sID>");
	else if(pid == INVALID_PLAYER_ID) SendClientMessage(playerid, Color_Error,"Invalid Player");
	else
	{
		g_PlayerInfo[pid][sid]= id;
		format(string,sizeof(string),"Du machst %s zum Leader von der Staatsfraktion %s",PlayerName(pid),g_sFrakInfo[id][sName]);
		SendClientMessage(playerid,Color_Saccess,string);
		format(string,sizeof(string),"Du wurdest zum leader der Staatsfraktion %s gemacht",g_sFrakInfo[id][sName]);
		SendClientMessage(pid,Color_Saccess,string);
		UpdatePlayer(pid);
		
	}
	return 1;
}

CMD:acar(playerid,params[])
{
	if(isPlayerAnAdmin(playerid,1))
	{
		new Float:x,Float:y,Float:z;
		GetPlayerPos(playerid,x,y,z);
		for(new i = 0; i< MAX_VEHICLES; i++) 
		{
		
			if(VehicleIds[i] == INVALID_VEHICLE_ID) 
			{ //We got an unused slot, then:
				VehicleIds[i] = AddStaticVehicleEx(560, x, y, z, 90, 1, 1, -1,1);
				new objectid = CreateObject(19419,0.0,0.0,0.0,0.0,0.0,0.0,1.0);
					
				AddVehicleComponent(VehicleIds[i],1008);
				AddVehicleComponent(VehicleIds[i],1138);
				AddVehicleComponent(VehicleIds[i],1026);
				AddVehicleComponent(VehicleIds[i],1027);
				AddVehicleComponent(VehicleIds[i],1028);
				AddVehicleComponent(VehicleIds[i],1141);
				AddVehicleComponent(VehicleIds[i],1032);
				AddVehicleComponent(VehicleIds[i],1079);
				AddVehicleComponent(VehicleIds[i],1086);
				AddVehicleComponent(VehicleIds[i],1086);
				ChangeVehiclePaintjob(VehicleIds[i],0);
				PutPlayerInVehicle(playerid,VehicleIds[i],0);
				ACarSiren[i] = AttachObjectToVehicle(objectid, VehicleIds[i], -0.010000, -0.209999, 0.819999, 0.000000, 0.000000, 0.000000); //Object Model: 19419 | 
				break;
			}
		}		
	}
	else 
	{
		SendClientMessage(playerid,Color_Error,"Du bist kein Admin!");
		return 1;
	}
	return 1;
}

CMD:makeadmin(playerid,params[])
{
	if(isPlayerAnAdmin(playerid,7))
	{
		new id,alevel,string[90];
		if(sscanf(params,"ui",id,alevel)) SendClientMessage(playerid,Color_Info,"Usage: /makeAdmin <playerid> <level>");
		else if(id == INVALID_PLAYER_ID) SendClientMessage(playerid,Color_Error,"Player not found");
		else if(id == playerid) SendClientMessage(playerid, Color_Error,"Du kannst dein Adminlevel nicht selbst veraendern");
		else if(g_PlayerInfo[playerid][admin] == g_PlayerInfo[id][admin]) SendClientMessage(playerid, Color_Error,"Du kannst User mit dem Selben AdminLevel nicht veraendern");		
		else
		{
			g_PlayerInfo[id][admin] = alevel;
			format(string,sizeof(string),"%s macht dich zum Admin level %i",PlayerName(playerid),alevel);
			SendClientMessage(id,Color_Info,string);
			format(string, sizeof(string),"Du machst %s zum Admin Level: %i", PlayerName(id), alevel);
			SendClientMessage(playerid,Color_Info,string);
			UpdatePlayer(id);
			return 1;
		}
	}
	else
	{
		if(g_PlayerInfo[playerid][admin] == 0) 
		{
			SendClientMessage(playerid,Color_Error,"Du bist kein Admin!");
			return 1;
		}
		else 
		{
			SendClientMessage(playerid,Color_Error,"Dein Admin level ist zu niedrig!");
			return 1;
		}
	}
	return 1;
}

CMD:getJob(playerid,params[])
{	

	if(isPlayerInFrontOfJob(playerid,1))
	{
		new string[129];
		g_PlayerInfo[playerid][jId] = 1;
		g_PlayerInfo[playerid][jpay] = gJobInfo[1][jobloan];
	
		format(string,sizeof(string),"Du bist nun %s dein Lohn betraegt %i$", gJobInfo[1][jobname],gJobInfo[1][jobloan]);
		SendClientMessage(playerid,Color_Info,string);
		return 1;
	}
	else
	{
		SendClientMessage(playerid,Color_Error,"Du bist nicht in der naehe vom Boss");
		return 1;
	}
}

CMD:cshop(playerid,params[])
{
	if(isPlayerInFrontOfAutohaus(playerid))
	{
		if(ahOnline == 0)
		{
			SendClientMessage(playerid,Color_Info,"Willkommen");
			ShowPlayerDialog(playerid,DIALOG_CARSHOP,DIALOG_STYLE_TABLIST_HEADERS,"Car Shop","Auto\tPreis\nSultan\t$30000","Kaufen","Abbrechen");		
			return 1;
		}
		else 
		{
			SendClientMessage(playerid,Color_Error,"Es ist ein Autohaendler Online gehe bitte zu ihm!");
			return 1;
		}
	}

	return 1;
}

CMD:stats(playerid,params[])
{
	new string[200];

	format(string,sizeof(string),"Name: %s | Frak: %i | StaatsFrak: %i | Adminlevel: %i | Money: %i | Job: %i | Gehalt: %i | Alter: %i | Geschlaecht: %i",
		PlayerName(playerid), g_PlayerInfo[playerid][fID], g_PlayerInfo[playerid][sid], g_PlayerInfo[playerid][admin], GetPlayerMoney(playerid),g_PlayerInfo[playerid][jId],
		g_PlayerInfo[playerid][jpay],GetPlayerScore(playerid),g_PlayerInfo[playerid][sex]);
	SendClientMessage(playerid,-1,string);
	return 1;
}
