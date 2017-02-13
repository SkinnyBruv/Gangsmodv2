/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Gang Menu 		- Allows the Gang Leader to show up thier menu.
*/


/* Gang Menu */
/*
public Action:Cmd_Gang(client, args)
{
	if(GID[client] <= 0)
	{
		PrintToChat(client, "[SM] Must be in a gang to use gang menu.");
		return Plugin_Handled;
	}
	if(gRank[client] <= 0)
	{
		PrintToChat(client, "[SM] Must be a gang admin to use gang menu.");
		return Plugin_Handled;
	}
	
	new String:gangName[64];
	
	GetGangName(GID[client], gangName, sizeof(gangName));
	
	new Handle:menu = CreateMenu(Menu_Gang);
	
	SetMenuTitle(menu, gangName);
	AddMenuItem(menu, "invite", "Invite Player");
	
	if(gRank[client] == 1)
	{
		AddMenuItem(menu, "promote", "Promote Member");
		AddMenuItem(menu, "kick", "Kick Member");
		AddMenuItem(menu, "newowner", "Give Ownership");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
	return Plugin_Handled;
}

public Menu_Gang(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:inform[50];
		GetMenuItem(menu, param2, inform, sizeof(inform));
		
		if(StrEqual(inform, "invite", false))
		{
			InviteMenu(param1);
		}
		
		if(StrEqual(inform, "promote", false))
		{
			PromoteMenu(param1);
		}
		
		if(StrEqual(inform, "kick", false))
		{
			KickMenu(param1);
		}
		
		if(StrEqual(inform, "newowner", false))
		{
			GiveOwnership(param1);
		}
	}
	CloseHandle(menu);
}

public Menu_Invite(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:inform[10];
		GetMenuItem(menu, param2, inform, sizeof(inform));
		new targ = StringToInt(inform);
		
		if(targ == -1)
		{
			CloseHandle(menu);
			return;
		}
		
		if(!IsClientInGame(targ))
		{
			PrintToChat(param1, "[SM] That player is offline.");
			CloseHandle(menu);
			return;
		}
		
		new String:gangName[64];
		
		GetGangName(GID[param1], gangName, sizeof(gangName));
		
		gInvite[targ] = GID[param1];// Invite target
		
		PrintToChat(targ, "\x01[SM]\x04 %N\x01 invited you to %s; !accept or !deny.", param1, gangName);
		PrintToChat(param1, "\x01[SM]\x04 Target invited.");
	}
	CloseHandle(menu);
	return;
}

stock InviteMenu(any:client)
{
	new Handle:menu = CreateMenu(Menu_Invite);
	new bool:anyone=false;
	new String:username[MAX_NAME_LENGTH];
	new String:temp[10];
	
	SetMenuTitle(menu, "Invite Player");
	
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && GID[i] <= 0 && client != i && IsFakeClient(i) == false)
		{
			GetClientName(i, username, sizeof(username));
			Format(temp, sizeof(temp), "%d", i);
			AddMenuItem(menu, temp, username);
			anyone = true;
		}
	}
	
	if(!anyone)
	{
		AddMenuItem(menu, "-1", "No online players without a gang.");
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 60);
}

public Menu_Promote(Handle:menu, MenuAction:action, client, choice)
{
	if(action == MenuAction_Select)
	{
		new String:inform[10];
		
		GetMenuItem(menu, choice, inform, sizeof(inform));
		
		new targ = StringToInt(inform);
		
		if(targ == -1)
		{
			CloseHandle(menu);
			return;
		}
		
		if(!IsClientInGame(targ))
		{
			PrintToChat(client, "[SM] That player is offline.");
			CloseHandle(menu);
			return;
		}
		
		new String:username[MAX_NAME_LENGTH];
		
		GetClientName(client, username, sizeof(username));
		gRank[targ] = 2;//Set to co-admin rank.
		PrintToChat(targ, "\x01[SM]\x04 %s\x01 has set your gang rank to\x04 Co-Admin\x01.", username);
		PrintToChat(client, "\x01[SM]\x04 Target promoted.");
		
		//GetGangAdminCount(GID[client], 1);
	}
	CloseHandle(menu);
	return;
}

stock PromoteMenu(any:client)
{
	new Handle:menu = CreateMenu(Menu_Promote);
	new bool:anyone=false;
	new String:username[MAX_NAME_LENGTH];
	new String:temp[10];
	
	SetMenuTitle(menu, "Promote Member");
	
	new count = -1;//GetGangAdminCount(GID[client]);
	
	if(count == -1)
	{
		PrintToChat(client, "[SM] An error occurred when retrieving data. Please contact a server admin.");
		return;
	}
	
	if(count >= 6)
	{
		PrintToChat(client, "[SM] Too many co-admins already.");
		return;
	}
	
	for(new i=1;i<=MaxClients;i++)
	{
		if(GID[i] == GID[client] && i != client && gRank[i] == 0)
		{
			Format(temp, sizeof(temp), "%d", i);
			GetClientName(i, username, sizeof(username));
			AddMenuItem(menu, temp, username);
			anyone = true;
		}
	}
	
	if(!anyone)
	{
		AddMenuItem(menu, "-1", "Nobody online to promote.");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
}

public Menu_Kick(Handle:menu, MenuAction:action, client, choice)
{
	if(action == MenuAction_Select)
	{
		new String:inform[10];
		
		GetMenuItem(menu, choice, inform, sizeof(inform));
		
		new targ = StringToInt(inform);
		
		if(targ == -1)
		{
			CloseHandle(menu);
			return;
		}
		
		if(!IsClientInGame(targ))
		{
			PrintToChat(client, "[SM] That player is offline.");
			CloseHandle(menu);
			return;
		}
		
		new String:gangName[64];
		
		GetGangName(GID[client], gangName, sizeof(gangName));
		
		if(gRank[targ] > 0)
		{//Thus, kicking a co-admin out of the group. Therefore, subtract one from admin count.
			//GetGangAdminCount(GID[targ], -1);
		}
		GID[targ] = 0;//Reset gang variables.
		gRank[targ] = 0;
		PrintToChat(targ, "\x01[SM]\x04 %N\x01 has kicked you out of\x04 %s\x01.", client, gangName);
		PrintToChat(client, "\x01[SM]\x04 Target kicked.");
	}
	CloseHandle(menu);
	return;
}

stock KickMenu(any:client)
{
	new Handle:menu = CreateMenu(Menu_Kick);
	new bool:anyone=false;
	new String:username[MAX_NAME_LENGTH];
	new String:temp[10];
	
	SetMenuTitle(menu, "Kick Member");
	
	for(new i=1;i<=MaxClients;i++)
	{
		if(GID[i] == GID[client] && i != client && gRank[i] != 1)
		{
			Format(temp, sizeof(temp), "%d", i);
			GetClientName(i, username, sizeof(username));
			AddMenuItem(menu, temp, username);
			anyone = true;
		}
	}
	
	if(!anyone)
	{
		AddMenuItem(menu, "-1", "Nobody online to kick.");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
}

stock GiveOwnership(any:client)
{
	new Handle:menu = CreateMenu(Menu_Ownership);
	new bool:anyone=false;
	new String:username[MAX_NAME_LENGTH];
	new String:temp[10];
	
	SetMenuTitle(menu, "Give Ownership");
	
	for(new i=1;i<=MaxClients;i++)
	{
		if(GID[i] == GID[client] && i != client)
		{
			Format(temp, sizeof(temp), "%d", i);
			GetClientName(i, username, sizeof(username));
			AddMenuItem(menu, temp, username);
			anyone = true;
		}
	}
	
	if(!anyone)
	{
		AddMenuItem(menu, "-1", "Nobody online in your gang.");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 30);
}*/