/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Create a Gang 		- Allows a user to create a gang by paying money.
*/

public Action:Cmd_CreateGang(client, args)
{
	//ReplyToCommand(client, "Sorry only VIP's are allowed to create gangs!");
	if(args != 1)
	{
		PrintToChat(client, "[FNG] Usage: !create [Gang-Name]");
		return Plugin_Handled;
	}
	
	if(args == 1)
	{
		// Gets Player Table, and if GID == 0, then allow the player to create a gang
		//GetClientIndexes(client);
		
		if(GID[client] > 0)
		{
			PrintToChat(client, "[FNG] Already in a gang.");
			return Plugin_Handled;
		}
		
		if(GID[client] == 0)
		{
			PrintToChat(client, "[FNG] You may proceed.");
			
			// Setup MySQL
			new String:query[200];
			new Handle:querySend = INVALID_HANDLE;
			new String:arg1[80];
			
			// Obtain Table Values
			GetConVarTable(TABLE_PLAYER);	//Usually fngls
			GetConVarTable(TABLE_GANG);	//Usually gfng
			GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));
			
			// Create gang on table
			GetCmdArg(1, arg1, sizeof(arg1));	// Gets the inputted gang name
			Format(query, sizeof(query), sQuery_CreateGang, tableGang, arg1, SID[client]);
			querySend = SQL_Query(dbConn, query);
			
			// Do everything to get Clients GangID
			GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));
			GetConVarTable(TABLE_GANG);
	
			Format(query, sizeof(query),  sQuery_GetGangID, tableGang, SID[client]);//Gets GangCount (or largest gang id)
			//SQL_TQuery(dbConn, SQL_GetClientIndexesCallback, query, client, DBPrio_High);
			querySend = SQL_Query(dbConn, query);
			
			new String:clientname[200];
			GetClientName(client, clientname, sizeof(clientname));
			
			if(SQL_FetchRow(querySend))
			{
				GID[client] = SQL_FetchInt(querySend, 0);
				PrintToServer("[Database] SQL[000]: Successfully gathered GangID: %s.", clientname);
			}
	
			else
			{
				PrintToServer("[Database] SQL-ERROR[003]: Failed to gather information for player: %s.", client);
			}
			
			// Update Player Table and GangID
			//Format(query, sizeof(query), sQuery_UpdatePlayer, tablePlayer, GID[client], arg1, SID);
			Format(query, sizeof(query), sQuery_UpdatePlayer, tablePlayer, GID[client], arg1, SID);
			querySend = SQL_Query(dbConn, query);
			
			// Give Player Clan Tag
			CS_SetClientClanTag(client, arg1);
		}
	}
	
	/*
	Format(query, sizeof(query), sQuery_CreateGangAI, tablePlayer, tableGang);//Gets GangCount (or largest gang id)
	querySend = SQL_Query(dbConn, query);
	
	if(SQL_FetchRow(querySend))
	{
		gangCount = (SQL_FetchInt(querySend, 0) + 1);//One more than the current amount of gangs.
	}
	
	else
	{
		PrintToServer("[DrugMoney] SQL-ERROR: Could not find default gang row.");
	}
	
	
	GetClientAuthId(client, AuthId_Steam3, SID, sizeof(SID));
	
	new String:error[120];
	SQL_GetError(dbConn, error, sizeof(error));
	PrintToServer("Attempted to retrieve an error: %s", error);
	
	gRank[client] = 1;
	GID[client] = gangCount;*/
	/*for(new i=0;i<=MaxClients;i++)
	{
		if(gGID[i] <= 0)
		{//Free Spot
			gGID[i] = gangCount;
			gLevel[i] = pLevel[client];
			break;
		}
	}*/
	
	//Format(query, sizeof(query), , tableGang, gangCount);
	//querySend = SQL_Query(dbConn, query);
	/*
	
	*/
	return Plugin_Handled;
}