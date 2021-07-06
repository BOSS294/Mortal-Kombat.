#define ID_LOTERIA (1) //The id of the menu of the lottery.
#define VALOR_TICKET (500) //The value of the ticket.
#define TIEMPO_LOTERIA (30) //cada 30 Minutos sorteara.
#define PREMIO_INICIAL (100) //initial well lottery is multiplied according to the number of ticket's sold.
#define POZO_LIMITE (200)  //the limit for the initial well will return.
new NumeroLoteria[MAX_PLAYERS];
new PozoLoteria=PREMIO_INICIAL;
new bool:TicketLoteria[MAX_PLAYERS]=false;
new MatarLoteria;
new PozoLoteriaLimite=0;


COMMAND:ticket(playerid, params[]) {
	ShowPlayerDialog(playerid,ID_LOTERIA+0, DIALOG_STYLE_INPUT, "Easy Lottery System BASE", "Enter a number between 0 and 100:", "Buy "," Exit ");
	return true;
}
forward Lottery();
public Lottery() {
    new str[200];
	for(new player=0; player<GetMaxPlayers(); player++) {
        if(!IsPlayerConnected(player) || TicketLoteria[player]!=true) continue;
		if(IsPlayerConnected(player) && TicketLoteria[player]!=false) {
			new numero=random(100);
			if(NumeroLoteria[player]==numero) {
			    format(str, sizeof(str), "~y~lottery raffled~n~~w~Number drawn was the ~g~%d~w~~n~with a prize of ~g~$%d~w~ dollars.~n~~g~Make won the lottery, Congratulations!.", numero, PozoLoteria*PozoLoteriaLimite);
			    GameTextForPlayer(player, str, 15*1000, 3);
                GivePlayerMoney(player,(0+PozoLoteria*PozoLoteriaLimite));
				NumeroLoteria[player]=0;
				TicketLoteria[player]=false;
			} else {
			    format(str, sizeof(str), "~y~lottery raffled~n~~w~Number drawn was the ~g~%d~w~~n~with a prize of ~g~$%d~w~ dollars.~n~~r~You have lost the lottery, Luck!.", numero, PozoLoteria*PozoLoteriaLimite);
			    GameTextForPlayer(player, str, 15*1000, 3);
			    NumeroLoteria[player]=0;
			    TicketLoteria[player]=false;
			}
		}
	}
}
