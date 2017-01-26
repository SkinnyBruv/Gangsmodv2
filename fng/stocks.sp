/*	Script Created by SkinnyBruv	*/

/*
		Part of the Stocks System
		----------------------
		Stocks 		- Creates "Stocks" that can be referred to, for easy connections.
*/


/* Stock List */
stock bool IsValidClient(int client)
{
	if (client >= 1 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client))
	{
		return true;
	}
	return false;
}

stock bool ObtainPlayerInformation(int I_Client)
{
	/****************************
	* name - pName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
	* steamid - SID[MAXPLAYERS + 1];
	* gangid - GID[MAXPLAYERS + 1];
	* gangname - gName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
	* gangrank - gRank[MAXPLAYERS + 1];
	* vip - gVIP[MAXPLAYERS + 1];
	****************************/
	
	PrintToServer("[Database] SQL-SUCCESS[000]: Gathered information for player");
	
	int client = GetClientOfUserId(I_Client);
	if (client == 0)
	{
		return;
	}
	
	/* These Variables must be Local */
	// Setup the information needed to send Queries to MYSQL
	char query[255];
	char query2[255];
	Handle querySend = INVALID_HANDLE;
	
	// Obtain SteamID, Players Name and MySQL Table
	GetClientName(client, pName[client], sizeof(pName));	// Gets Players Name
	GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));	// Gets Players SteamID
	GetConVarTable(TABLE_PLAYER);
	
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
		Format(query2, sizeof(query2), sQuery_CheckUpdatePlayer, tablePlayer, pName[client], SID[client]);
		SQL_TQuery(dbConn, SQL_dbDoNothing1, query2);	// Send the Information off to the MySQL Database
		
		if(querySend == INVALID_HANDLE)
		{
			PrintToServer("[Database] SQL-ERROR[001]: Failed to update information for player %s.", pName[client]);
		}
	}
	else
	{
		Format(query2, sizeof(query2), sQuery_CheckInsertPlayer, tablePlayer, SID[client], pName[client]);
		//SQL_FastQuery(dbConn, query);
		SQL_TQuery(dbConn, SQL_dbDoNothing, query2);	// Send the Information off to the MySQL Database
		
		// Store Players Information
		GID[client] = 0;	// GangID
		gName[client] = "nogang";	// GangName
		gRank[client] = 0;	// GangRank
		gVIP[client] = 0;	// VIP
		
		PrintToServer("[Database] SQL-SUCCESS[000]: Insert information for player %s.", pName[client]);
		
		if(querySend == INVALID_HANDLE)
		{
			PrintToServer("[Database] SQL-ERROR[002]: Failed to insert information for player %s.", pName[client]);
		}
	}
}

stock bool ObtainPlayersGangInformation(int I_Client)
{
	/****************************
	* gangid - GID[MAXPLAYERS + 1];
	* name - gName[MAXPLAYERS + 1][MAX_NAME_LENGTH];
	* steamid - SID[MAXPLAYERS + 1];
	* level - gLevel[MAXPLAYERS + 1];
	* admincount //Not used
	* membercount //Not used
	****************************/
	
	int client = GetClientOfUserId(I_Client);
	if (client == 0)
	{
		return;
	}
	
	/* These Variables must be Local */
	// Setup the information needed to send Queries to MYSQL
	char query[255];
	char query2[255];
	Handle querySend = INVALID_HANDLE;
	
	// Obtain SteamID, Players Name and MySQL Table
	GetClientName(client, pName[client], sizeof(pName));	// Gets Players Name
	GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));	// Gets Players SteamID
	GetConVarTable(TABLE_GANG);
	
	// See if SteamID is in the Database
	Format(query, sizeof(query), sQuery_ObtainGangInformation, tableGang, SID[client]);
	querySend = SQL_Query(dbConn, query);
	
	// If there is a SteamID of that Particular Player... Update his Username!
	if(SQL_FetchRow(querySend))
	{
		// Store Players Gang Information
		SQL_FetchString(querySend, 0, gName[client], sizeof(gName));	// GangName
		gLevel[client] = SQL_FetchInt(querySend, 1);	// GangLevel
		
		PrintToServer("[Database] SQL-SUCCESS[000]: Gathered gang information for player %s.", pName[client]);
	}
	else
	{
		PrintToServer("[Database] SQL-ERROR[001]: Failed to gather gang information for player %s.", pName[client]);
	}
}

stock bool GetClientIndexes(int I_Client)
{
	int client = GetClientOfUserId(I_Client);
	if (client == 0)
	{
		return;
	}
	
	/* Continue on with GetClientIndexes */
	
	char query[255];
	Handle querySend = INVALID_HANDLE;
	
	GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));
	GetConVarTable(TABLE_PLAYER);
	
	Format(query, sizeof(query), sQuery_GetClientIndexes, tablePlayer, SID[client]);//Gets GangCount (or largest gang id)
	
	//SQL_TQuery(dbConn, SQL_GetClientIndexesCallback, query, client, DBPrio_High);
	querySend = SQL_Query(dbConn, query);
	
	if(SQL_FetchRow(querySend))
	{
		GID[client] = SQL_FetchInt(querySend, 0);
		SQL_FetchString(querySend, 1, gName[client], sizeof(gName));
		gRank[client] = SQL_FetchInt(querySend, 2);
		gVIP[client] = SQL_FetchInt(querySend, 3);
	}
	
	else
	{
		PrintToServer("[Database] SQL-ERROR[003]: Failed to gather information for player: %s.", client);
	}
}

stock bool SetTargetVIP(int target)
{
	char query[255];
	
	GetClientAuthId(target, AuthId_Steam3, SID[target], sizeof(SID));
	GetConVarTable(TABLE_PLAYER);
	
	FormatEx(query, sizeof(query),  sQuery_SetVip, tablePlayer, SID[target]);
	SQL_TQuery(dbConn, SQL_dbDoNothing, query, target, DBPrio_High);
}

stock bool GetConVarTable(int tableval)
{
	if(tableval == TABLE_DBCN)
	{
		GetConVarString(cv_dbConnTable, tb_connValue, sizeof(tb_connValue));
	}
	
	else if(tableval == TABLE_PLAYER)
	{//Users
		GetConVarString(cv_dbPlayerTable, tablePlayer, sizeof(tablePlayer));
	}
	
	else if(tableval == TABLE_GANG)
	{//Users
		GetConVarString(cv_dbGangTable, tableGang, sizeof(tableGang));
	}
}

stock void GetGangName(int gangID, char[] name, int maxlength)
{
	char temp[64]; 
	char query[200];
	Handle queryH = INVALID_HANDLE;
	
	Format(query, sizeof(query), sQuery_GetGangName, name);
	queryH = SQL_Query(dbConn, query);
	
	if(SQL_FetchRow(queryH))
	{
		SQL_FetchString(queryH, 0, temp, sizeof(temp));
		strcopy(name, maxlength, temp);
	}
	
	else
	{
		PrintToServer("[DrugMoney] SQL-ERROR[004]: Failed to retrieve name of gang id '%s'.", gangID);
	}
}

stock int RetrieveInt(int tableval, const char[] value, int condition, int extra=-1)
{
	char query[200];
	Handle queryH = INVALID_HANDLE;
	char condKey[48];
	char temp[100];
	
	if(tableval == TABLE_PLAYER)
	{//Users
		GetConVarTable(TABLE_PLAYER);
		Format(condKey, sizeof(condKey), "auth");
		GetClientAuthId(condition, AuthId_Steam3, temp, sizeof(temp));
	}
	
	else if(tableval == TABLE_GANG)
	{//Gang
		GetConVarTable(TABLE_GANG);
		Format(condKey, sizeof(condKey), "gangid");
		Format(temp, sizeof(temp), "%d", condition);
	}
	
	else
	{//VIP
		Format(condKey, sizeof(condKey), "auth");
		GetClientAuthId(condition, AuthId_Steam3, temp, sizeof(temp));
	}
	
	if(extra == -1)
	{
		Format(query, sizeof(query), sQuery_RetrieveInt, value, tablePlayer, condKey, temp);
		queryH = SQL_Query(dbConn, query);
		
		if(SQL_FetchRow(queryH))
		{
			return SQL_FetchInt(queryH, 0);
		}
		
		else
		{
			PrintToServer("[DrugMoney] SQL-ERROR[005]: Could not FetchRow() with variables: %s, %s, %s.", tableval, value, temp);
		}
	}
	
	else
	{//If we're going to change data instead of retrieve.
		Format(query, sizeof(query), sQuery_RetrieveInt2, tablePlayer, value, extra, condKey, temp);
		queryH = SQL_Query(dbConn, query);
	}
	return -1;
}