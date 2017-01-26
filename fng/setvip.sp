/*
	Jailbreak Gang System
		*  This script is created by SkinnyBruv #Scum  *
		
		Description: Part of the VIP System
		-----------
		Set VIP 		- Allows an admin to set a player to VIP.

		
		In Developement
		------
		Nothing.
		

		Credits
		-------
		Bacardi 		- Helping with targeting players partial name [Thread 226728].
*/

/*
		Changelog
		---------
		January 26, 2017	- 	Project Make things Global, instead of calling MySQL names
*/




/* Create Gang */
public Action Cmd_SetVIP(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_setvip <#userid|name>");
		return Plugin_Handled;
	}
	
	if (!IsClientInGame(client))	// Make sure player who used cmd is fully connected in game
	{
		return Plugin_Handled;
	}
	
	char arg[MAX_NAME_LENGTH];
	
	GetCmdArg(1, arg, sizeof(arg));
	
	int targets[1];	// When not target multiple players, COMMAND_FILTER_NO_MULTI
	char target_name[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int targets_found = ProcessTargetString(arg, client, targets, sizeof(targets), COMMAND_FILTER_NO_IMMUNITY|COMMAND_FILTER_NO_MULTI, target_name, sizeof(target_name), tn_is_ml);
	
	if (targets_found <= COMMAND_TARGET_NONE)	// No target found or error
	{
		ReplyToTargetError(client, targets_found);
		return Plugin_Handled;
	}
	
	int target = targets[0];	// Get that one player from list
	
	/*if (target == client)	// Command used to itself
	{
		ReplyToCommand(client, "[SM] You can't target yourself!");
		return Plugin_Handled;
	}*/
	
	
	SetTargetVIP(target);
	
	PrintToChat(client, "'%s' has now been set to a FNG VIP Member.", target);
	PrintToServer("'%s' has now been set to a FNG VIP Member by admin: '%N'.", target, client);
	
	return Plugin_Handled;
	
	/*
	
	char name[32];
	int target = -1;
	
	GetCmdArg(1, name, sizeof(name));
	
	for (int i=1; i<MaxClients; i++)
	{
		if(!IsClientConnected(i))
		{
			continue;
		}
		
		char other[32];
		
		GetClientName(i, other, sizeof(other));
		
		if (StrEqual(name, other))
		{
			target = i;
		}
	}
	
	if (target == -1)
	{
		PrintToChat(client, "Could not find any player with the name: \'%s\'", name);
		return Plugin_Handled;
	}
	
	SetTargetVIP(target);
	
	PrintToChat(client, "Your target: \'%s\' has now been set to a FNG VIP Member Position.", target);
	
	return Plugin_Handled;*/
}