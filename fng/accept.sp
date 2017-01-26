/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Invite to Gang 		- Allows an Gang Admin to invite a player into their gang.
*/


/* Accept Gang Invitation */
public Action Cmd_AcceptGang(int client, int args)
{
	GetClientIndexes(client);
	
	if(GID[client] > 0)
	{
		PrintToChat(client, "[SM] Must leave current gang to join another.");
		return Plugin_Handled;
	}
	
	if(gInvite[client] <= 0)
	{
		PrintToChat(client, "[SM] No pending invites.");
		return Plugin_Handled;
	}
	
	// Variable Ints
	char username[MAX_NAME_LENGTH];
	char gangName[64];
	
	GetGangName(gInvite[client], gangName, sizeof(gangName));
	GetClientName(client, username, sizeof(username));
	
	GID[client] = gInvite[client];
	gInvite[client] = 0;
	//gLevel[FindGangSlot(client)] += pLevel[client];//Adds client level to gang level.
	
	GetConVarTable(TABLE_PLAYER);
	GetConVarTable(TABLE_GANG);
	
	char query[200];
	Handle queryH = INVALID_HANDLE;
	int currentCount;
	
	currentCount = RetrieveInt(TABLE_GANG, "membercount", GID[client]);
	
	Format(query, sizeof(query), sQuery_AcceptInvite, tableGang, (currentCount + 1), GID[client]);
	queryH = SQL_Query(dbConn, query);
	
	if(queryH == INVALID_HANDLE)
	{
		PrintToServer("[DrugMoney] SQL-ERROR: Could not update membercount for gangid %d.", GID[client]);
	}
	
	PrintToChat(client, "\x01[SM]\x04 Successfully joined %s!", gangName);
	
	CS_SetClientClanTag(client, gangName);
	
	for(int i=1;i<=MaxClients;i++)
	{
		if(GID[i] == GID[client])
		{
			PrintToChat(i, "\x01[SM]\x04 %s\x01 has joined your gang!", username);
		}
	}
	return Plugin_Handled;
}