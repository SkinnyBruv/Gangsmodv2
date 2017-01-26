/*
	Jailbreak Gang System
		*  This script is created by SkinnyBruv #Scum  *
		
		Description: Part of the Player Setup System
		-----------
		Setup Client 		- Creates the clients MySQL database Row in the database.

		
		In Developement
		------
		Project Make things Global, instead of calling MySQL names
		

		Credits
		-------
		N/A 		- N/A.
*/

/*
		Changelog
		---------
		January 26, 2017	- 	Project Make things Global, instead of calling MySQL names
*/


/* Setup Client */
public void OnClientPostAdminCheck(int client)
{
	//////////////////////////////////////////////////////////////////////////////////ONE//////////////////////////////////////////////////////////////////////////////////
	/****************************
	* name - pName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
	* steamid - SID[MAXPLAYERS + 1];
	* gangid - GID[MAXPLAYERS + 1];
	* gangname - gName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
	* gangrank - gRank[MAXPLAYERS + 1];
	* vip - gVIP[MAXPLAYERS + 1];
	****************************/
	
	if (IsValidClient(client) == true)
	{
		/* These Variables must be Local */
		// Setup the information needed to send Queries to MYSQL
		char query[255];
		Handle querySend = null;
		
		// Obtain SteamID, Players Name and MySQL Table
		GetClientName(client, pName[client], sizeof(pName));	// Gets Players Name
		GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));	// Gets Players SteamID
		GetConVarTable(TABLE_PLAYER);
		GetConVarTable(TABLE_GANG);
		
		// See if SteamID is in the Database (IF NOT, Add a row with SteamID)
		Format(query, sizeof(query), sQuery_ObtainPlayerInformation, tablePlayer, SID[client]);
		querySend = SQL_Query(dbConn, query);
		
		// If there is a SteamID of that Particular Player... Update his Username!
		if(SQL_FetchRow(querySend))
		{
			// Store Players Information
			GID[client] = SQL_FetchInt(querySend, 0);	// GangID
			SQL_FetchString(querySend, 1, gName[client], sizeof(gName));	// GangName
			gRank[client] = SQL_FetchInt(querySend, 2);	// GangRank
			gVIP[client] = SQL_FetchInt(querySend, 3);	// VIP
			
			PrintToServer("[Database] SQL-SUCCESS[000]: Gathered information for player %s.", pName[client]);
			
			// Update his Username, using SteamID
			Format(query, sizeof(query), sQuery_CheckUpdatePlayer, tablePlayer, pName[client], SID[client]);
			SQL_TQuery(dbConn, SQL_dbDoNothing1, query);	// Send the Information off to the MySQL Database
		}
		else
		{
			Format(query, sizeof(query), sQuery_CheckInsertPlayer, tablePlayer, SID[client], pName[client]);
			SQL_TQuery(dbConn, SQL_dbDoNothing, query);	// Send the Information off to the MySQL Database
			
			// Store Players Information
			GID[client] = 0;	// GangID
			gName[client] = "nogang";	// GangName
			gRank[client] = 0;	// GangRank
			gVIP[client] = 0;	// VIP
			
			PrintToServer("[Database] SQL-SUCCESS[001]: Insert information for player %s.", pName[client]);
			
			if(querySend == null)
			{
				PrintToServer("[Database] SQL-ERROR[002]: Failed to insert information for player %s.", pName[client]);
			}
		}
		
		/****************************
		* gangid - GID[MAXPLAYERS + 1];
		* name - gName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
		* steamid - SID[MAXPLAYERS + 1];
		* level - gLevel[MAXPLAYERS + 1];
		* admincount //Not used
		* membercount //Not used
		****************************/
		
		// See if SteamID is in the Database
		Format(query, sizeof(query), sQuery_ObtainGangInformation, tableGang, SID[client]);
		querySend = SQL_Query(dbConn, query);
		
		// If there is a SteamID of that Particular Player... Update his Username!
		if(SQL_FetchRow(querySend))
		{
			// Store Players Gang Information
			SQL_FetchString(querySend, 0, gName[client], sizeof(gName));	// GangName
			gLevel[client] = SQL_FetchInt(querySend, 1);	// GangLevel
			
			PrintToServer("[Database] SQL-SUCCESS[002]: Gathered gang information for player %s.", pName[client]);
		}
	}
}

public Action Event_OnPlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// If it IS NOT a fake client, then Check to see if the Player is in the Database!
	if (IsValidClient(client) == true)
	{
		if(GetClientTeam(client) == 0)	// Spectator
		{
			char NameOfPlayer[70];
			
			GetClientName(client, NameOfPlayer, sizeof(NameOfPlayer));
			PrintToServer("[CHECKING] Cannot update Clients ClanTag for Player: %s", NameOfPlayer);
			CreateTimer(5.0, TimerCB_RetryLoadClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		if(GetClientTeam(client) == 1)	// Terrorists
		{
			PrintToServer("[CHECKING] UPDATING CLIENT");
			UpdateClanTag(client);
		}
		
		if(GetClientTeam(client) == 2)	// CounterTerrorists
		{
			PrintToServer("[CHECKING] UPDATING CLIENT");
			UpdateClanTag(client);
		}
		if (GetClientTeam(client) > 3)
		{
			CreateTimer(5.0, TimerCB_RetryLoadClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action TimerCB_RetryLoadClient(Handle hTimer, any iUserID)
{	
	int client = GetClientOfUserId(iUserID);
	
	ObtainPlayerInformation(client);
	ObtainPlayersGangInformation(client);
	
	if(GetClientTeam(client) == 0)	// Spectator
	{
		char NameOfPlayer[70];
		
		GetClientName(client, NameOfPlayer, sizeof(NameOfPlayer));
		PrintToServer("[CHECKING] Cannot update Clients ClanTag for Player: %s", NameOfPlayer);
		CreateTimer(5.0, TimerCB_RetryLoadClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	if(GetClientTeam(client) == 1)	// Terrorists
	{
		PrintToServer("[CHECKING] UPDATING CLIENT");
		UpdateClanTag(client);
	}
	
	if(GetClientTeam(client) == 2)	// CounterTerrorists
	{
		PrintToServer("[CHECKING] UPDATING CLIENTS CLAN TAG");
		UpdateClanTag(client);
	}
	if (GetClientTeam(client) > 3)
	{
		CreateTimer(5.0, TimerCB_RetryLoadClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void UpdateClanTag(int client)
{
	char query[255];
	Handle querySend = null;
	//decl String:szTag[36];
	//new String:clantag;
	
	GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));	// Gets Players SteamID
	/*GetConVarTable(TABLE_PLAYER);
	
	Format(query, sizeof(query), sQuery_SetGangName, tablePlayer, SID[client]);
	querySend = SQL_Query(dbConn, query);
	
	if(SQL_FetchRow(querySend))
	{
		SQL_FetchString(querySend, 0, szTag, sizeof(szTag));
	}
	
	else
	{
		PrintToServer("[Database] SQL-ERROR[003]: Failed to gather information for player: %s.", client);
	}*/
	
	//szTag = gName[client];
	
	CS_SetClientClanTag(client, gName[client]);
}