#define CAREPACKRESPAWN 120000
enum cPack {
	bool:CarePackageUsed,
	bool:CarePackageLanded,
	bool:PlaneMoveStage,
	Float:CarePackageRotation,
	CarePackagePlane,
	CarePackageFlare,
	CarePackageParachute,
	CarePackageBox,
	CarePackageStuff,
	Float:CarePackageLand[3],
	Text3D:CarePackageText,
	CarePackageInterior,
	CarePackageWorld,
}
enum cPstuff {
	type,
	sid,
	Lname[26],
	Xvalue
}
new CarePackageContains[][cPstuff] = {
	{0,9,"Chainsaw",1},
	{0,22,"Colt-45",50},
	{0,23,"Colt-45 Silenced",50},
	{0,24,"Desert Eagle",50},
	{0,25,"Shotgun",50},
	{0,26,"Sawnoff Shotgun",50},
	{0,27,"Combat Shotgun",50},
	{0,28,"Micro SMG/Uzi",50},
	{0,29,"MP5",50},
	{0,30,"AK-47",50},
	{0,31,"M4",50},
	{0,32,"TEC-9",50},
	{0,33,"Country Rifle",50},
	{0,34,"Sniper Rifle",50},
	{0,35,"RPG",50},
	{0,36,"Heat Seeker",50},
	//{0,38,"Minigun",50},
	{0,37,"Flamethrower",50}
};
#define MAX_CARE_PACKAGES 25
new pCarePackage[MAX_CARE_PACKAGES][cPack];
new Iterator:CarePackages<MAX_CARE_PACKAGES>;
new CarePackageDespawnTimer[MAX_CARE_PACKAGES];

CMD:carepackage(playerid, params[])
{
    if(GetPlayerMoney(playerid) < 50000) return SendClientMessage(playerid, Red, "[SERVER]: You don't have enough money to call the care package");
    if(GetPlayerScore(playerid) < 500) return SendClientMessage(playerid, Red, "[SERVER]: You don't have enough score to call the care package");
    GivePlayerMoney(playerid,-50000);
  	if(pCarePackage[playerid][CarePackageUsed] == true) return SendClientMessage(playerid,0xFF0000FF,"Care package is already incomming");
	new Float:X,Float:Y,Float:Z;
	GetPlayerPos(playerid,Float:X,Float:Y,Float:Z);
	if(!CreateCarePackageForPlayer(playerid,Float:X,Float:Y,Float:Z)) return SendClientMessage(playerid,0xFF0000FF,"Care package limit reached!");
  	return 1;
}
stock CreateCarePackageForPlayer(playerid,Float:X,Float:Y,Float:Z) {
	new carepackid;
	for(new i = 0; i < MAX_CARE_PACKAGES; i++) {
	    if(pCarePackage[i][CarePackageUsed] == false) {
	        carepackid = i;
	        break;
	    }
	    if( i == MAX_CARE_PACKAGES-1) {
			return 0;
	    }
	}
	Iter_Add(CarePackages,carepackid);
	new angle = random(360);
	pCarePackage[carepackid][CarePackageUsed] = true;
	pCarePackage[carepackid][PlaneMoveStage] = false;
	pCarePackage[carepackid][CarePackageFlare] = CreateDynamicObject(18728,X,Y,Z-2,0,0,0,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid),-1,250,250);
	pCarePackage[carepackid][CarePackageLand][0] = X;
    pCarePackage[carepackid][CarePackageLand][1] = Y;
    pCarePackage[carepackid][CarePackageLand][2] = Z-1.5;
    pCarePackage[carepackid][CarePackageRotation] = angle;
    pCarePackage[carepackid][CarePackageInterior] = GetPlayerInterior(playerid);
    pCarePackage[carepackid][CarePackageWorld] = GetPlayerVirtualWorld(playerid);
    GetXYFromPosWithAngle(X,Y,angle,300);
    pCarePackage[carepackid][CarePackagePlane] = CreateDynamicObject(14553,X,Y,Z+75,11.9,0,-angle,GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid),-1,500,500);
    MoveDynamicObject(pCarePackage[carepackid][CarePackagePlane], pCarePackage[playerid][CarePackageLand][0], pCarePackage[playerid][CarePackageLand][1], pCarePackage[playerid][CarePackageLand][2]+75, 30, 11.9, 0, -angle);
	foreach(new b : Player) Streamer_Update(b);
	pCarePackage[carepackid][CarePackageLanded] = false;
	return 1;
}
forward DespawnCarePackage(i);
public DespawnCarePackage(i) {
    DestroyDynamicObject(pCarePackage[i][CarePackageBox]);
    Delete3DTextLabel(pCarePackage[i][CarePackageText]);
    pCarePackage[i][CarePackageBox] = -1;
	pCarePackage[i][CarePackageUsed] = false;
	pCarePackage[i][CarePackageLanded] = false;
	if(IsValidDynamicObject(pCarePackage[i][CarePackagePlane])) DestroyDynamicObject(pCarePackage[i][CarePackagePlane]);
	Iter_Remove(CarePackages,i);
	return 1;
}
forward OnPlayerPickUpCarePackage(playerid,pickupid);
public OnPlayerPickUpCarePackage(playerid,pickupid) {
	if(CarePackageContains[pickupid][type] == 0) GivePlayerWeapon(playerid,CarePackageContains[pickupid][sid],CarePackageContains[pickupid][Xvalue]);

}
GetXYFromPosWithAngle(&Float:x, &Float:y,Float:Angle,Float:distance) {
    x += (distance * floatsin(Angle, degrees));
    y += (distance * floatcos(Angle, degrees));
}
