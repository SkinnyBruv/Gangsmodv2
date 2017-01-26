/*
	Jailbreak Gang System
		*  This script is created by SkinnyBruv #Scum  *
		
		Description: Part of the Database System
		-----------
		Register Database Systen 		- Creates the connection for MySQL between the Game Server and Database Server.

		
		In Developement
		------
		Nothing.
		

		Credits
		-------
		N/A 		- N/A
*/

/*
		Changelog
		---------
		January 26, 2017	- 	Added timer every 5 seconds, on Database failure. To notify server administrators 24/7.
*/


/* Register Database */
public OnMapStart()
{
	/* Database Connection */
	GetConVarTable(TABLE_DBCN);
	
	dbConn = SQL_Connect(tb_connValue, true, dbError, sizeof(dbError)); /* Name of dbConenction in database.cfg */
	
	if  (dbConn == INVALID_HANDLE)
	{
		PrintToServer("[FNG Database] - Could not connect to database: %s", dbError);
		CloseHandle(dbConn);
		
		CreateTimer(5.0, TimerCB_RetryLoadDatabase, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		PrintToServer("[FNG Database] - Connected Successfully!");
	}
	
	if (cv_jb_gangs_version == INVALID_HANDLE)
	{
		return;
	}
	
	else
	{
		PrintToChatAll("[SM] This server is created by SkinnyBruv.");
	}
	
	if (cv_jb_gangs == INVALID_HANDLE)
	{
		return;
	}
}

public Action TimerCB_RetryLoadDatabase(Handle hTimer, any databaseError)
{
	PrintToServer("[FNG Database] - Could not connect to database, check log");
	
	CreateTimer(5.0, TimerCB_RetryLoadDatabase, TIMER_FLAG_NO_MAPCHANGE);
}