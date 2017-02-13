/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Show Online 		- Allows a Player to leave their gang, if they are not the owner of the gang.
*/


/* See whose Online */
public Action Cmd_Online(int client, int args)
{
	if(GID[client] <= 0)
	{
		PrintToChat(client, "[SM] Must be in a gang.");
		return Plugin_Handled;
	}
	
	char gangName[64];
	
	GetGangName(GID[client], gangName, sizeof(gangName));
	
	Handle menu = CreateMenu(Menu_Online);
	bool anyOnline = false;
	char  username[MAX_NAME_LENGTH];
	
	SetMenuTitle(menu, gangName);
	
	for(int i=1;i<=MaxClients;i++)
	{
		if(GID[i] == GID[client] && i != client)
		{
			GetClientName(i, username, sizeof(username));
			AddMenuItem(menu, "", username);
			anyOnline = true;
		}
	}
	
	if(!anyOnline)
	{
		AddMenuItem(menu, "", "No gang members online.");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 60);
	return Plugin_Handled;
}

public int Menu_Online(Handle menu, MenuAction action, int param1, int param2)
{
	CloseHandle(menu);
	return;
}