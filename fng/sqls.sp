/*
	Jailbreak Gang System
		*  This script is created by SkinnyBruv #Scum  *
		
		Description: Part of the MySQL System
		-----------
		SQLs 		- References that can be used within other scripts

		
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

public void SQL_dbDoNothing(Handle owner, Handle hndl, const char[] error, any errorCount)
{
	if(!StrEqual(error, ""))
	{
		PrintToServer("SQL-ERROR[100]: %s", error);
	}
}

public void SQL_dbDoNothing1(Handle owner, Handle hndl, const char[] error, any errorCount)
{
	if(!StrEqual(error, ""))
	{
		PrintToServer("SQL-ERROR[200]: %s", error);
	}
}

public void SQL_GetClientIndexesCallback(Handle owner, Handle hndl, char[] error, int client)
{
	if(SQL_FetchRow(hndl))
	{
		GID[client] = SQL_FetchInt(hndl, 0);
		//gName[client] = SQL_FetchInt(hndl, 1);
		gRank[client] = SQL_FetchInt(hndl, 2);
		gVIP[client] = SQL_FetchInt(hndl, 3);
		
		PrintToServer("[Database] SQL-SUCCESS[003]: Successfully gathered information for player: %s.", client);
	}
	
	else
	{
		PrintToServer("[Database] SQL-ERROR[003]: Failed to gather information for player: %s.", client);
	}
}

/*
public void CheckGang(int I_Client)
{
	char C_buffer[512];
	char C_ClientID[32];

	GetClientAuthId(I_Client, AuthId_Steam3, C_ClientID, sizeof(C_ClientID), true);

	Format(C_buffer, sizeof(C_buffer), "SELECT gangname FROM fngls WHERE steamID = '%s'", C_ClientID);
	SQL_TQuery(dbConn, SQL_GangNameCallback, C_buffer, I_Client, DBPrio_High);
}

public void SQL_GangNameCallback(Handle owner, Handle hndl, char[] error, int I_Client)
{
	char C_GangName[64];
	
	if (SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 0, gC_ClanTags[I_Client], 128);
		SQL_FetchString(hndl, 0, C_GangName, 128);
	}
	CS_SetClientClanTag(I_Client, C_GangName);
}*/