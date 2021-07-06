new FalloutPlayer[MAX_PLAYERS], //Player Variable that let us know if the player is inside the event or not
FalloutStarted = 0, //Global Variable to know if the Event has started or not
FalloutPlayers = 0, //Global Variable to know how much players we have in the event, if < 1 the event will NOT start.
FalloutWaiting = 0; //Global variable to know if we're waiting for the event to start or not

//Do not edit this
#define PLATFORMS 63 //Number of platforms in the game (Don't change it)

//Editable settings
#define EVENT_START 1 //Calculated in minutes you have to change it (1 = 1 minute)
#define MONEY 10000 //The money that the player wins, change it from there if you want

//Forwards
forward FalloutStarting(playerid);
forward CheckPlayer();
forward FallingPlat();
forward RegenPlatforms();

//Platforms
new PlatformObject[63];

//Some random colors needed
#define Red 0xFF0000FF
#define Grey 0xAFAFAFAA
#define Green 0x33AA33AA
#define Yellow 0xFFFF00AA
#define White 0xFFFFFFAA
#define Blue 0x0000BBAA
#define Lightblue 0x33CCFFAA
#define Orange 0xFF9900AA
#define Lime 0x10F441AA
#define Magenta 0xFF00FFFFT
#define Navy 0x000080AA
#define Aqua 0xF0F8FFAA
#define Crimson 0xDC143CAA
#define Black 0x000000AA
#define Brown 0XA52A2AAA
#define Gold 0xB8860BAA
#define Limegreen 0x32CD32AA


//========================== [ COMMANDS ] ======================================

COMMAND:joinfallout(playerid,params[])
{
	if(FalloutWaiting == 0) return SendClientMessage(playerid,Red,"There's no active Fallout Event!"); //If the player tries to join it while there's no active event
	if(FalloutStarted == 1) return SendClientMessage(playerid,Red,"The Fallout event has already started, you can't join it now!"); //If the players tries to join it while the Event has already started
	if(FalloutPlayer[playerid] == 1) return SendClientMessage(playerid,Red,"You can't join this, you're already in the event!"); //If the player tries to join the event but he's already inside it.

	//Join the event
	FalloutPlayers++; //Increase the players in the event
	FalloutPlayer[playerid] = 1; //The player is now a Fallout Partecipant
	SendClientMessage(playerid,Green,"You joined the Fallout Event! Just wait until the event starts!");

	return 1;
}


//=============================== FALLOUT CORE FUNCTIONS =======================

public FalloutStarting(playerid) //The function from the timer: We do start the event or delete it if there are not enough players
{
	if(FalloutPlayers < 2) //If the players that joined the event are less than 2 then it triggers this
	{
	    SendClientMessageToAll(Red,"Sadly there were not enough players to start the Fallout Event :("); //Send the player a message to let him know that the event isn't started cause of missing players
	    FalloutPlayers = 0; //Reset the fallout players to 0
	    FalloutWaiting = 0; //Reset the fallout Waiting to 0
	    FalloutPlayer[playerid] = 0; //Let's reset the player variable

	} else { //Otherwise the event begins

	    FalloutWaiting = 0; //Let's avoid more players to join the event by putting this to 0
	    FalloutStarted = 1; //Put this to 1 to start the event
	    Platforms(); //Let's create the platforms

	    SetTimer("FallingPlat",1000,1);
	    SetTimer("CheckPlayer",1000,1);

	//We're now cycling into all players to see if they are Players of the Fallout Event and teleport them if they are so.
	    for(new i; i < MAX_PLAYERS; i++)
	    {
		    if(FalloutPlayer[i] == 1)
		    {
			    SetPlayerPos(i,-1737.18042, 845.63318, 435.79611);
			    SetPlayerVirtualWorld(i,5000); //Set all the players in the Virtual World 5000
		    }
	    }

	} //Close
}


/* Here we do check the player and see if he's still in the platform or he has fallen
   this gets checked every 1 second.
*/

public CheckPlayer()
{
    //If there is only 1 player remaining he's the winner
    if(FalloutPlayers == 1) //Checking if there's 1 player remaining
    {
        for ( new z; z < MAX_PLAYERS; z++)
        {
            if(FalloutPlayer[z] == 1) //Checking if he's a fallout player
            {
               SendClientMessage(z,Green,"Congratz, you're the last man standing on the platform, you won! And you got some extra money for it!"); //Let's send him a message
               GivePlayerMoney(z,MONEY); //Give him the money for the victory you can change it from the top of the Filterscript
               SpawnPlayer(z); //Spawn him
               SetPlayerVirtualWorld(z,0); //Reset his virtual world

               //Reset everything for a new run
               FalloutPlayer[z] = 0;
               FalloutStarted = 0;
               FalloutPlayers = 0;

	           SetTimer("RegenPlatforms",5000,0); //Let's recreate all the platforms in 20 seconds meanwhile they get destroyed and recreated

               //Now let's destroy all objects and reset them
               for(new o=0;o<sizeof(PlatformObject);o++) //Cycle to get all the objects
               {
                    if(IsValidObject(PlatformObject[o])) //Then destroy it
                    {
                        DestroyObject(PlatformObject[o]);
                    }
               }

        }
    }

    } else { //Otherwise do the following

	for(new i; i < MAX_PLAYERS; i++) //Cycle it to get all players id
	{
        new Float: px, Float: py, Float: pz; //Let's define px, py, pz
        GetPlayerPos(i,px,py,pz); //Get everyone position

        if(IsPlayerConnected(i))
        {
		    if(FalloutPlayer[i] == 1)
		    {
	            if(pz < 400) //Let's check who has fallen from the platform
	            {

	            new name[25];
	            new string[100];

	            GetPlayerName(i,name,25);
                format(string,sizeof(string),"%s has been eliminated from the Fallout Event, Players Remaining: %d",name, FalloutPlayers);
	            SendClientMessageToAll(Red,string);

	            FalloutPlayers--; //Decrease by 1 the Fallout Players count
	            FalloutPlayer[i] = 0; //Reset his variables
	            SpawnPlayer(i); //Spawn him
	            SetPlayerVirtualWorld(i,0); //Reset his virtual world

		        }
            }
	    }
	}
    }
}

public FallingPlat() //Destroyer of the platforms :^) It destroys a random object from the platform
{
    if(IsValidObject(PlatformObject[random(PLATFORMS)]))
    {
        DestroyObject(PlatformObject[random(PLATFORMS)]);
    }
}


public RegenPlatforms() //Regenerate all the platform for a second run
{
	 Platforms();
}

//================================= PLATFORMS ==================================

stock Platforms()
{
     //Platform objects
     PlatformObject[0] = CreateObject(1649, -1740.44092, 845.66888, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[1] = CreateObject(1649, -1737.18042, 845.63318, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[2] = CreateObject(1649, -1740.48816, 841.32959, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[3] = CreateObject(1649, -1737.22803, 841.29327, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[4] = CreateObject(1649, -1743.76868, 841.38629, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[5] = CreateObject(1649, -1743.70081, 845.68628, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[6] = CreateObject(1649, -1743.67358, 850.00671, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[7] = CreateObject(1649, -1740.37341, 849.96948, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[8] = CreateObject(1649, -1737.11243, 849.93317, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[9] = CreateObject(1649, -1733.85181, 849.89679, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[10] = CreateObject(1649, -1733.93787, 845.51715, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[11] = CreateObject(1649, -1733.96399, 841.24866, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[12] = CreateObject(1649, -1730.74585, 841.14685, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[13] = CreateObject(1649, -1730.63953, 845.54553, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[14] = CreateObject(1649, -1730.59717, 849.84680, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[15] = CreateObject(1649, -1743.81250, 837.06433, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[16] = CreateObject(1649, -1740.53174, 837.00037, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[17] = CreateObject(1649, -1737.23096, 836.97479, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[18] = CreateObject(1649, -1734.09045, 836.91614, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[19] = CreateObject(1649, -1730.79199, 836.81165, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[20] = CreateObject(1649, -1747.12341, 837.09131, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[21] = CreateObject(1649, -1747.06689, 841.43445, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[22] = CreateObject(1649, -1747.01526, 845.75745, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[23] = CreateObject(1649, -1746.95740, 849.99884, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[24] = CreateObject(1649, -1730.82996, 832.48993, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[25] = CreateObject(1649, -1734.09753, 832.52924, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[26] = CreateObject(1649, -1737.34229, 832.58447, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[27] = CreateObject(1649, -1740.63342, 832.60742, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[28] = CreateObject(1649, -1743.83813, 832.65540, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[29] = CreateObject(1649, -1747.13342, 832.65881, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[30] = CreateObject(1649, -1750.43262, 832.73029, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[31] = CreateObject(1649, -1750.41174, 837.09027, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[32] = CreateObject(1649, -1750.32996, 841.42944, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[33] = CreateObject(1649, -1750.28845, 845.78906, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[34] = CreateObject(1649, -1750.24622, 850.10901, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[35] = CreateObject(1649, -1730.54651, 854.22644, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[36] = CreateObject(1649, -1733.78687, 854.29486, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[37] = CreateObject(1649, -1737.08728, 854.30304, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[38] = CreateObject(1649, -1740.26367, 854.29370, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[39] = CreateObject(1649, -1743.52954, 854.32788, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[40] = CreateObject(1649, -1746.84167, 854.36127, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[41] = CreateObject(1649, -1750.14624, 854.45685, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[42] = CreateObject(1649, -1753.71252, 832.77502, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[43] = CreateObject(1649, -1753.56506, 837.16809, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[44] = CreateObject(1649, -1753.59863, 841.46564, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[45] = CreateObject(1649, -1753.53516, 845.80377, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[46] = CreateObject(1649, -1753.46643, 850.09772, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[47] = CreateObject(1649, -1753.44092, 854.44940, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[48] = CreateObject(1649, -1730.49390, 858.64581, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[49] = CreateObject(1649, -1733.77344, 858.66431, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[50] = CreateObject(1649, -1737.05298, 858.68329, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[51] = CreateObject(1649, -1740.31287, 858.70197, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[52] = CreateObject(1649, -1743.45178, 858.75903, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[53] = CreateObject(1649, -1746.75024, 858.76831, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[54] = CreateObject(1649, -1750.05212, 858.79803, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[55] = CreateObject(1649, -1753.37537, 858.88470, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[56] = CreateObject(1649, -1756.61438, 858.90198, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[57] = CreateObject(1649, -1756.71008, 854.54590, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[58] = CreateObject(1649, -1756.71973, 850.21057, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[59] = CreateObject(1649, -1756.76819, 845.92291, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[60] = CreateObject(1649, -1756.84387, 841.63708, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[61] = CreateObject(1649, -1756.79749, 837.29614, 428.79611, -90.00000, 0.00000, -90.60000);
     PlatformObject[62] = CreateObject(1649, -1756.81995, 832.97583, 428.79611, -90.00000, 0.00000, -90.60000);
}
