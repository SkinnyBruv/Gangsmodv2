/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Invite to Gang 		- Allows an Gang Admin to invite a player into their gang.
*/


/* Decline Gang Invitation */
public Action:Cmd_DenyGang(client, args)
{
	if(gInvite[client] <= 0)
	{
		PrintToChat(client, "[SM] No pending invites.");
		return Plugin_Handled;
	}
	
	new String:username[MAX_NAME_LENGTH];
	new String:gangName[64];
	
	GetGangName(gInvite[client], gangName, sizeof(gangName));
	GetClientName(client, username, sizeof(username));
	
	PrintToChat(client, "\x01[SM]\x04 Denied request from %s.", gangName);
	
	for(new i=1;i<=MaxClients;i++)
	{
		if(GID[i] == gInvite[client])
		{
			PrintToChat(i, "\x01[SM]\x04 %s\x01 denied your gang request.", username);
		}
	}
	
	gInvite[client] = 0;
	return Plugin_Handled;
}