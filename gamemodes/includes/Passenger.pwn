new sExplode[MAX_VEHICLES] = {-1, ...};
new bool:tCount[MAX_VEHICLES];

#define S_EXPLODE_X 2.4015
#define S_EXPLODE_Y 29.2775
#define S_EXPLODE_Z 1199.593
#define S_EXPLODE_RANGE 13.4

forward ExplodeShamal(vehicleid);

GetPlayerShamalID(playerid)
{
	return GetPlayerVirtualWorld(playerid) > cellmax-MAX_VEHICLES ? cellmax-GetPlayerVirtualWorld(playerid)+1 : 0;
}
public ExplodeShamal(vehicleid)
{
	KillTimer(sExplode[vehicleid-1]);
	if (tCount[vehicleid-1])
	{
		for (new i = 0; i < MAX_PLAYERS; i++)
		{
			if (GetPlayerShamalID(i) == vehicleid)
			{
				CreateExplosionForPlayer(i, S_EXPLODE_X, S_EXPLODE_Y, S_EXPLODE_Z, 2, S_EXPLODE_RANGE);
			}
		}
		sExplode[vehicleid-1] = SetTimerEx("ExplodeShamal", random(1300) + 100, 0, "d", vehicleid);
	}
	else
	{
		sExplode[vehicleid-1] = -1;
	}
}
