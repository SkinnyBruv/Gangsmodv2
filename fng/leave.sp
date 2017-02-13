/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Leave Gang 		- Allows a Player to leave their gang, if they are not the owner of the gang.
*/


/* Leave Gang */
public Action Cmd_LeaveGang(int client, int args)
{
	if(GID[client] <= 0)
	{
		PrintToChat(client, "[SM] No gang to leave.");
		return Plugin_Handled;
	}
	
	bool onlyMember = false;
	
	if(RetrieveInt(TABLE_GANG, "membercount", GID[client]) <= 1)
	{
		onlyMember = true;
	}
	
	if(gRank[client] == 1 && onlyMember == false)
	{
		PrintToChat(client, "[SM] Must give leadership to another member first.");
		return Plugin_Handled;
	}
	
	//new slot = FindGangSlot(client);
	char query[200];
	Handle queryH = null;
	
	GetConVarTable(TABLE_GANG);
	
	if(onlyMember)
	{
		Format(query, sizeof(query), sQuery_LeaveGang, tableGang, GID[client]);
		queryH = SQL_Query(dbConn, query);
		
		if(queryH == null)
		{
			PrintToServer("[DrugMoney] SQL-ERROR[006]: Failed to delete gangid row %d.", GID[client]);
			PrintToChat(client, "[SM] Failed to delete your gang.");
			return Plugin_Handled;
		}
		
		else
		{
			PrintToChat(client, "\x01[SM]\x04 Gang successfully deleted.");
		}
		
		GID[client] = 0;
		gRank[client] = 0;
		
		CS_SetClientClanTag(client, "");
		
		/*for(new i=slot;i<=MaxClients;i++)
		{//Fixes gang array.
			gGID[i] = gGID[i + 1];
			gLevel[i] = gLevel[i + 1];
		}*/
		delete queryH;

	}
	
	else
	{
		int currentCount = 0;
		currentCount = RetrieveInt(TABLE_GANG, "membercount", GID[client]);
		
		Format(query, sizeof(query), sQuery_UpdateLeave, tableGang, (currentCount - 1), GID[client]);
		queryH = SQL_Query(dbConn, query);
		
		//gLevel[slot] -= pLevel[client];
		GID[client] = 0;
		gRank[client] = 0;
		
		PrintToChat(client, "\x01[SM]\x04 Successfully left gang.");
		
		CS_SetClientClanTag(client, "");
		delete queryH;
	}
	return Plugin_Handled;
}