/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Invite to Gang 		- Allows an Gang Admin to invite a player into their gang.
*/


/* Create Gang */
public Action Cmd_InviteGang(int client, int args)
{	
	// Arguments = 0
	if(args != 1)
	{
		PrintToChat(client, "[SM] Usage: !invite [NAME]");
		return Plugin_Handled;
	}
	
	// Arguments == 1
	if(args == 1)
	{
		PrintToChat(client, "[SM] Lets do this");
		
		char query[255];
		Handle querySend = INVALID_HANDLE;
	
		GetClientAuthId(client, AuthId_Steam3, SID[client], sizeof(SID));
		
		Format(query, sizeof(query), sQuery_GetGangIDnGRank, tablePlayer, SID[client]);
		querySend = SQL_Query(dbConn, query);
	
		if(SQL_FetchRow(querySend))
		{
			GID[client] = SQL_FetchInt(querySend, 0);
			gRank[client] = SQL_FetchInt(querySend, 1);
		}
		
		// GangID = 0
		if(GID[client] <= 0)
		{	
			PrintToChat(client, "[SM] You're not in a gang.");
			return Plugin_Handled;
		}
	
		// GangRank = 0
		if(gRank[client] <= 0)
		{
			PrintToChat(client, "[SM] Must be gang admin to invite others.");
			return Plugin_Handled;
		}
		return Plugin_Handled;
	}
	
	char arg1[MAX_NAME_LENGTH];
	char username[MAX_NAME_LENGTH];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	int targ = FindTarget(client, arg1, true, false);
	
	if(targ == -1 || targ == client)
	{
		return Plugin_Handled;
	}
	
	// GangID of Target = 0
	/*if(GID[targ] > 0)
	{
		PrintToChat(client, "[SM] Target is in a gang already.");
		return Plugin_Handled;
	}*/
	
	char gangName[64];
	
	GetGangName(GID[client], gangName, sizeof(gangName));
	GetClientName(client, username, sizeof(username));
	gInvite[targ] = GID[client];// Invite target
	
	PrintToChat(targ, "\x01[SM]\x04 %s\x01 invited you to %s: Please '!accept' or '!deny' the gang invitation.", username, gangName);
	PrintToChat(client, "\x01[SM]\x04 Target invited.");
	return Plugin_Handled;
}