 /*
		TODO LIST:
		--------------------------------------------
		*	Get this shit working!
		*	Try to do custom weapons and knives
		--------------------------------------------
*/

/*
	Jailbreak Gang System
		*  This script is created by SkinnyBruv #Scum  *
		
		Description
		-----------
		This plugin allows prisoners to create gangs and upgrade specific skills that apply to everybody in the gang.


		Gang Menu
		---------
		Create a Gang 		- Allows a user to create a gang by paying money to the server (VIP's Only).
		Invite to Gang 		- Only the leader of the gang can invite people to the gang.
		Accept Gang Invite 	- Player being invited to a gang, can accept the gang invitation.
		Decline Gang Invite - Player being invited to a gang, can decline the gang invitation.
		Leave Gang 			- Allows a player to leave the gang. The leader cannot leave the gang until he transfers leadership to somebody else (explained later).
		Online Members 		- Shows a list of gang members that are currently in the server.
		
	
		Skills 				- Opens the skills menu, where any member of the gang can pay money to upgrade their skills.
		Top-10 				- Shows a MOTD with the top10 gangs, SORTED BY KILLS. (If you have a good way to sort it, please post it below)
		Gang Leader Menu 	- Shows a menu with options to disband the gang, kick a player from the gang, or transfer leadership to somebody else in the gang.
		
		
		In Developement
		------
		Making things global variables, instead of calling mysql queries 24/7.
		Invite to Gang (Currently Broken) - Never in gang? (Fixed, but then doesn't target player?)
		Set VIP - Currently Broken (Doesn't Target Players Partial names)
		Set VIP ConVar - Currently Broken
		stock GetGangName - Currently Slow way to grab MySQL Data
		Create Gang - Currently Slow way to grab MySQL Data
		

		Skills
		------
		HP - Increased health
		Stealing - Increased money earnings.
		Gravity - Lower Gravity
		Damage - Increased damage
		Stamina - Gives higher speed to players.
		Weapon Drop - Chance of making the guard drop the weapon when you knife them. (%1 chance increase per level)
	

		CVARS
		-----
		jb_gang_cost 		- The cost to create a gang.
		jb_health_cost 		- The cost to upgrade gang health.
		jb_stealing_cost 	- The cost to upgrade gang money earning.
		jb_gravity_cost 	- The cost to upgrade gang gravity.
		jb_damage_cost 		- The cost to upgrade gang damage.
		jb_stamina_cost 	- The cost to upgrade gang stamina (speed).
		jb_weapondrop_cost 	- The cost to upgrade gang weapon drop percentage.

		Additionally there are CVars for the max level for each type of upgrade, so replace _cost above with _max.
		Also there are CVars for the amount per level, so replace _cost above with _per.
		
		jb_points_per_kill	- The amount of points you get for a kill
		jb_headshot_bonus	- The amount of points you get for a headshot
		
		jb_max_members		- The max amount of members a gang can hold
		jb_admin_create		- Whether or not an admin can create gangs without using points

		Credits
		-------
		F0RCE 		- Original Plugin Idea on AMX Mod X.
		H3avY Ra1n 	- Second Original Plugin Idea on AMX Mod X.
		Neuro Toxin	- Helping change normal Queries to Threaded Queries.
		Phil25		- Showing me how to use Transactions for Queries.
*/
#define PLUGIN_VERSION "0.0.1.0"
/*
		Changelog
		---------
		January 26, 2017	- v0.0.1.0 - 	Project Make things Global, instead of calling MySQL names (setupclient.sp, sqls.sp)
		January 26, 2017	- v0.0.1.0 - 	Fixed SetVIP, now targets partial player names
		January 25, 2017	- v0.0.0.9 - 	Fixed Clan Tags after Player Spawns in a team
		January 25, 2017	- v0.0.0.8 - 	Fixed Create Gangs, Gang now inputs gang table, and updates player table in MySQL
		January 24, 2017	- v0.0.0.6 - 	Scrapped new code, coming back to old code
		
		October   08, 2016	- v0.0.0.5 -	Queries have been changed into QueryStrings and all layed out on main page.
		October	  01, 2016	- v0.0.0.4 -	CreateGang command completed. Only works for non-threaded queries.
		October   01, 2016	- v0.0.0.4 -	CheckClient OnClientAuthorized Completed. - Setup of Player.
		September 30, 2016	- v0.0.0.3 -	Files configurated into separate scripts! Actually working :D
		September 29, 2016	- v0.0.0.2 -	Fixed Respawning without Clan Tag Issue
		September 28, 2016	- v0.0.0.1 - 	Initial Release


		http://forums.alliedmods.net/showthread.php?p=1563919
*/

/*****************************************************************


			P L U G I N   F U N C T I O N S


*****************************************************************/
/* Includes */
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>


/* We like semicolons */
#pragma semicolon 1


/* Query Strings */
char sQuery_CheckUpdatePlayer[] = "UPDATE %s SET name='%s' WHERE steamid='%s';";														// SQL_CheckPlayer - sqls.sp
char sQuery_CheckInsertPlayer[] = "INSERT INTO %s (steamid, name, gangid, gangname, gangrank) VALUES ('%s', '%s', '0', '0', '0');";		// SQL_CheckPlayer - sqls.sp
char sQuery_SetGangName[] = "SELECT gangname FROM %s WHERE steamid='%s'";

/* Global Variable Setup Strings */
char sQuery_ObtainPlayerInformation[] = "SELECT name, gangid, gangname, gangrank, vip FROM %s WHERE steamid='%s';";						// GetClientIndexes - stocks.sp
char sQuery_ObtainGangInformation[] = "SELECT name, level FROM %s WHERE steamid='%s';";											// GetClientIndexes - stocks.sp

char sQuery_CreateGang[] = "INSERT INTO %s (level, name, admincount, membercount, steamid) VALUES ('1', '%s', '1', '1', '%s');";			// Cmd_CreateGang - creategang.sp
char sQuery_UpdatePlayer[] = "UPDATE %s SET gangid='%d', gangrank='1', gangname='%s' WHERE steamid='%s';";								// Cmd_CreateGang - creategang.sp
//char sQuery_SelectGangID[] = "SELECT gangid FROM %s WHERE steamid='%s';";																		// Cmd_CreateGang - creategang.sp
//char sQuery_UpdateGangID[] = "UPDATE %s SET gangid='%s' WHERE steamid='%s';";																	// Cmd_CreateGang - creategang.sp

char sQuery_AcceptInvite[] = "UPDATE %s SET membercount='%d' WHERE gangid='%d';";															// Cmd_AcceptGang - accept.sp

char sQuery_LeaveGang[] = "DELETE FROM %s WHERE gangid='%d';";																			// Cmd_LeaveGang - leave.sp
char sQuery_UpdateLeave[] = "UPDATE %s SET membercount='%d' WHERE gangid='%d';";

char sQuery_RetrieveInt[] = "SELECT %s FROM %s WHERE %s='%s';";																			// RetrieveInt - stocks.sp
char sQuery_RetrieveInt2[] = "UPDATE %s SET %s='%d' WHERE %s='%s';";																		// RetrieveInt - stocks.sp
char sQuery_GetGangName[] = "SELECT gangname FROM %s WHERE name='%s';";																	// Cmd_InviteGang - invitetogang.sp
char sQuery_GetClientIndexes[] = "SELECT gangid, gangname, gangrank, vip FROM %s WHERE steamid='%s';";									// GetClientIndexes - stocks.sp
char sQuery_GetGangID[] = "SELECT gangid FROM %s WHERE steamid='%s';";									// GetClientIndexes - stocks.sp
char sQuery_GetGangIDnGRank[] = "SELECT gangid, gangrank FROM %s WHERE steamid='%s';";

char sQuery_SetVip[] = "UPDATE %s SET vip = '1' WHERE steamid = '%s';";


/* Plugin & Author Information */
#define PLUGIN_AUTHOR "SkinnyBruv"
#define PLUGIN_NAME "[SM] JailBreak Gang System"
#define PLUGIN_URL "http://steamcommunity.com/id/skinnybruv"
#define PLUGIN_DESCRIPTION "GangsMod, Create, Invite, Promote Members in a Gang, Created for FNG"


/* Handles */
new Handle:dbConn = INVALID_HANDLE;	// Database Connection Handle
new String:dbError[255];	// Database Error Handle


/* Database Setups */
/* Player Table */
/****************************
* id - AI (AutoIncrement)
* steamid (VarChar)
* name (VarChar)
* gangid (Int)
* gangname (VarChar)
* gangrank (Int)
* vip (Int)
****************************/

/* Gang Table */
/****************************
* gangid - AI (AutoIncrement)
* level (Int)
* name (VarChar)
* admincount (Int)
* membercount (Int)
****************************/

/* Temporary Values to Store for Fixing CreateGang.sp */
//new String:arg1Temp[255];


/* Setups for Levels % Experience 	*/
/*		New Global Variables		*/
/*		gv = Global Variable		*/
int GID[MAXPLAYERS + 1];								//	globalvarible 	- 	interger 	- 	GangID
int gRank[MAXPLAYERS + 1];							//	globalvarible 	- 	interger 	- 	GangRank
int gLevel[MAXPLAYERS + 1];							//	globalvarible 	- 	interger 	- 	GangLevel
int gVIP[MAXPLAYERS + 1];								//	globalvarible 	- 	interger 	- 	VIP
char gName[MAXPLAYERS + 1][MAX_NAME_LENGTH];			//	globalvariable	-	string		-	GangName
char SID[MAXPLAYERS + 1];								//	globalvariable	-	string		-	SteamID
char pName[MAXPLAYERS + 1][MAX_NAME_LENGTH];			//	globalvariable	-	string		-	PlayersName

//new GID[255];		// GangID
//new gRank[255];	// GangRank
//new gName[255];	// GangName
//new gVIP[255];		// VIP
new gInvite[255];	// GangInvite


/* ConVars Setup */
new Handle:cv_dbConnTable = INVALID_HANDLE;
new String:tb_connValue[70];	//tb = Table
new Handle:cv_dbPlayerTable = INVALID_HANDLE;
new String:tablePlayer[70];	//tb = Table
new Handle:cv_dbGangTable = INVALID_HANDLE;
new String:tableGang[70];	//tb = Table

//new Handle:cv_SetVIP = INVALID_HANDLE;

new Handle:cv_jb_gangs = INVALID_HANDLE;
new Handle:cv_jb_gangs_version = INVALID_HANDLE;


/* MYSQL Table Definitions */
#define TABLE_DBCN		1
#define TABLE_PLAYER		2
#define TABLE_GANG		3

//new Handle:cv_pCreateCost = INVALID_HANDLE;


/* File Includes */
#include "fng/registerdatabase.sp"
#include "fng/setupclient.sp"

#include "fng/creategang.sp"
#include "fng/invite.sp"
#include "fng/accept.sp"
#include "fng/decline.sp"
#include "fng/leave.sp"
#include "fng/online.sp"
#include "fng/menugang.sp"
#include "fng/setvip.sp"

#include "fng/stocks.sp"
#include "fng/sqls.sp"


/* Plugin Info */
public Plugin:myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}


public OnPluginStart()
{
	/* Translations */
	LoadTranslations("common.phrases");
	
	
	/* AutoExecConfig */
	AutoExecConfig( true, "jb_fngsystem.gangs");
	
	
	/* ConVars Setup */	
	cv_jb_gangs_version = CreateConVar( "jb_fngsystem_gangs_version", PLUGIN_VERSION, "Version - Created by SkinnyBruv", FCVAR_SPONLY|FCVAR_NOTIFY );	// Creates Heading
	cv_jb_gangs = CreateConVar("jb_gangs_enabled", 		"1", 		"Sets whether this plugin is enabled/active", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	
	/* ConVar Database Setup */
	cv_dbConnTable = CreateConVar("sm_db_conn",				"fngls",		"This value sets the Database connection  value in databases.cfg");
	cv_dbPlayerTable = CreateConVar("sm_db_player",			"fngls",		"This value sets the Player Database connection table name for MYSQL");
	cv_dbGangTable = CreateConVar("sm_db_gang",				"gfng",			"This value sets the Gangs Database connection table name for MYSQL");
	
	
	//cv_SetVIP = CreateConVar("sm_vipgangs",					"1",			"Enable or disable VIP Only to create gangs", 0, true, 0.0, true, 1.0);
	
	//cv_pCreateCost = CreateConVar("jb_gang_cost",		"50");
	
	/* Event Setup */
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre);
	

	/* Commands	*/
	RegConsoleCmd("sm_create", Cmd_CreateGang, "Create a gang.");
	RegConsoleCmd("sm_invite", Cmd_InviteGang, "Invite someone online to your gang.");
	RegConsoleCmd("sm_accept", Cmd_AcceptGang, "Accept an invite request to a players gang.");
	RegConsoleCmd("sm_decline", Cmd_DenyGang, "Decline an invite to a players gang.");
	RegConsoleCmd("sm_deny", Cmd_DenyGang, "Decline an invite to a players gang.");
	RegConsoleCmd("sm_leave", Cmd_LeaveGang, "Leave current gang.");
	RegConsoleCmd("sm_online", Cmd_Online, "See online fellow gang members.");
	
	//RegConsoleCmd("sm_gang", Cmd_Gang, "Gang Admins can pull up a menu with commands.");//Rank 1 = Leader, 2= Co-Admin
	
	RegAdminCmd("sm_setvip", Cmd_SetVIP, ADMFLAG_ROOT, "Set a player to VIP.");
	

	//RegConsoleCmd("sm_ginfo", Cmd_GInfo, "Gang Info");
	
	//RegConsoleCmd("sm_ghelp", Cmd_Help, "Help for gang plugin.");
}