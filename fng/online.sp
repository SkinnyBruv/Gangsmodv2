/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Show Online 		- Allows a Player to leave their gang, if they are not the owner of the gang.
*/


/* See whose Online */
public Action:Cmd_Online(client, args)
{
	if(GID[client] <= 0)
	{
		PrintToChat(client, "[SM] Must be in a gang.");
		return Plugin_Handled;
	}
	
	new String:gangName[64];
	
	GetGangName(GID[client], gangName, sizeof(gangName));
	
	new Handle:menu = CreateMenu(Menu_Online);
	new bool:anyOnline = false;
	new String:username[MAX_NAME_LENGTH];
	
	SetMenuTitle(menu, gangName);
	
	for(new i=1;i<=MaxClients;i++)
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

public Menu_Online(Handle:menu, MenuAction:action, param1, param2)
{
	CloseHandle(menu);
	return;
}