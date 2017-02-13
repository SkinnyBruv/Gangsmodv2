/*	Script Created by SkinnyBruv	*/

/*
		Part of the Gang Menu
		----------------------
		Invite to Gang 		- Allows an Gang Admin to invite a player into their gang.
*/


/* Decline Gang Invitation */
public Action Cmd_DenyGang(int client, int args)
{
	if(gInvite[client] <= 0)
	{
		PrintToChat(client, "[SM] No pending invites.");
		return Plugin_Handled;
	}
	
	char gangName[64];
	
	GetGangName(gInvite[client], gangName, sizeof(gangName));
	
	PrintToChat(client, "\x01[SM]\x04 Denied request from %s.", gangName);
	
	for(int i=1;i<=MaxClients;i++)
	{
		if(GID[i] == gInvite[client])
		{
			PrintToChat(i, "\x01[SM]\x04 %N\x01 denied your gang request.", client);
		}
	}
	
	gInvite[client] = 0;
	return Plugin_Handled;
}