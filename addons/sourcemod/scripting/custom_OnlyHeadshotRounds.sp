// List of Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

// The code formatting rules we wish to follow
#pragma semicolon 1;
#pragma newdecls required;


// The retrievable information about the plugin itself 
public Plugin myinfo =
{
	name		= "[CS:GO] Headshot Only Rounds",
	author		= "Manifest @Road To Glory",
	description	= "Rounds have a percentage chance to become a 'headshots only' round.",
	version		= "V. 1.0.0 [Beta]",
	url			= ""
};


//////////////////////////
// - Global Variables - //
//////////////////////////

bool HeadshotOnlyRound = false;

ConVar Cvar_HeadshotRoundChance;



//////////////////////////
// - Forwards & Hooks - //
//////////////////////////


// This happens when the plugin is loaded
public void OnPluginStart()
{
	// Creates the convars which we intend for the server owner to be able to configure
	Cvar_HeadshotRoundChance = CreateConVar("HeadshotOnly_Chance", 	"33", 	"What is the chance in percentages for the round being a headshot only round? - [Default = 33]");

	// Hooks the events which we intend to use
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);

	// Adds late load support
	LateLoadSupport();

	// Automatically generates a config file that contains our plugins configurable variables
	AutoExecConfig(true, "custom_OnlyHeadshotRounds");

	// Adds files to the download list, and precaches them
	DownloadAndPrecacheFiles();
}


// This happens when a new map is loaded
public void OnMapStart()
{
	// Adds files to the download list, and precaches them
	DownloadAndPrecacheFiles();
}


// This happens after a playr has had their admin flags checked
public void OnClientPostAdminCheck(int client)
{
	// If the client meets our validation criteria then execute this section
	if(IsValidClient(client))
	{
		// Hooks the OnTakeDamage function to check when the player takes damage
		SDKHook(client, SDKHook_OnTakeDamage, Hook_OnDamageTaken);
	}
}


// This happns when a player takes damage
public Action Hook_OnDamageTaken(int client, int &attacker, int &inflictor, float &damage, int &damagetype) 
{
	// If this round is a headshot only round then execute this section
	if(!HeadshotOnlyRound)
	{
		return Plugin_Continue;
	}

	// If the client does not meet our validation criteria then execute this section
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	// If the attacker does not meet our validation criteria then execute this section
	if(!IsValidClient(attacker))
	{
		return Plugin_Continue;
	}


	char classname[64];

	GetEdictClassname(inflictor, classname, sizeof(classname));

/* - Enables the possibility of hegrenades dealing damage during headshot only rounds
	if(StrEqual(classname, "hegrenade_projectile", false))
	{
		return Plugin_Continue;
	}
*/

	// If the damage type is headshot damage then execute this section
	if(damagetype & CS_DMG_HEADSHOT)
	{
		// Picks a random number between 0 and 4
		int RandomSound = GetRandomInt(0, 4);

		// If the randomly picked number is 0 then execute this section
		if(RandomSound == 0)
		{
			// Plays a sound only the specified client can hear
			PlaySoundForClient(client, "physics/flesh/flesh_bloody_break.wav");
		}

		// If the randomly picked number is 1 then execute this section
		else if(RandomSound == 1)
		{
			// Plays a sound only the specified client can hear
			PlaySoundForClient(client, "physics/flesh/flesh_squishy_impact_hard1.wav");
		}

		// If the randomly picked number is 2 then execute this section
		else if(RandomSound == 2)
		{
			// Plays a sound only the specified client can hear
			PlaySoundForClient(client, "physics/flesh/flesh_squishy_impact_hard2.wav");
		}

		// If the randomly picked number is 3 then execute this section
		else if(RandomSound == 3)
		{
			// Plays a sound only the specified client can hear
			PlaySoundForClient(client, "physics/flesh/flesh_squishy_impact_hard3.wav");
		}

		// If the randomly picked number is 4 then execute this section
		else if(RandomSound == 4)
		{
			// Plays a sound only the specified client can hear
			PlaySoundForClient(client, "physics/flesh/flesh_squishy_impact_hard4.wav");
		}

		return Plugin_Continue;
	}

	// Changes the damage inflicted upon the victim to 0
	damage = 0.0;

	// Creates a variable which we will store our message within called message_string
	char message_string[1024];

	// Formats the message that we wish to send to the player and store it within our message_string variable
	Format(message_string, 1024, "%s\n<font color='#ff8000'>Headshot Only:</font>", message_string);
	Format(message_string, 1024, "%s\n<font color='#FFFFFF'>Only headshot attacks can kill.</font>", message_string);

	// Sends the message_string message to the client
	PrintHintText(attacker, message_string);

	return Plugin_Handled;
}



////////////////
// - Events - //
////////////////


// This happens when a new round starts
public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	// Obtains the convar's value and store it within our variable
	int HeadshotRoundChance = GetConVarInt(Cvar_HeadshotRoundChance);

	// If the MedKitChance is larger than chosen random number then execute this section
	if(GetRandomInt(0, 100) <= HeadshotRoundChance)
	{
		// Changes the HeadshotOnlyRound status to true 
		HeadshotOnlyRound = true;

		return Plugin_Continue;
	}
	
	// Changes the HeadshotOnlyRound status to false
	HeadshotOnlyRound = false;
	
	return Plugin_Continue;
}


// This happens when a player spawns
public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	// Obtains the client's userid and converts it to an index and store it within our client variable
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	// If the client does not meet our validation criteria then execute this section
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	// After 0.1 seconds applies the overlay to the client's screen
	CreateTimer(0.1, Timer_ApplyOverlay, client, TIMER_FLAG_NO_MAPCHANGE);

	// After 5.0 seconds removes the overlay from the client's screen
	CreateTimer(5.0, Timer_RemoveOverlay, client, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}



///////////////////////////
// - Regular Functions - //
///////////////////////////


// This happens when the plugin is loaded
public Action LateLoadSupport()
{
	// Loops through all of the clients
	for (int client = 1; client <= MaxClients; client++)
	{
		// If the client does not meet our validation criteria then execute this section
		if(!IsValidClient(client))
		{
			continue;
		}

		// Hooks the OnTakeDamage function to check when the player takes damage
		SDKHook(client, SDKHook_OnTakeDamage, Hook_OnDamageTaken);
	}

	return Plugin_Continue;
}


// This happens when a knife king is killed
public void PlaySoundForClient(int client, const char[] SoundName)
{
	// If the sound is not already precached then execute this section
	if(!IsSoundPrecached(SoundName))
	{	
		// Precaches the sound file
		PrecacheSound(SoundName, true);
	}

	// Creates a variable called FullSoundName which we will use to store the sound's full name path within
	char FullSoundName[256];

	// Formats a message which we intend to use as a client command
 	Format(FullSoundName, sizeof(FullSoundName), "play */%s", SoundName);

	// Performs a clientcommand to play a sound only the clint can hear
	ClientCommand(client, FullSoundName);
}


// This happen when the plugin is loaded and when a new map starts
public void DownloadAndPrecacheFiles()
{
	// Adds the model related files to the download table
	AddFileToDownloadsTable("materials/manifest/overlays/normal_round.vtf");
	AddFileToDownloadsTable("materials/manifest/overlays/normal_round.vmt");
	AddFileToDownloadsTable("materials/manifest/overlays/only_headshot_round.vtf");
	AddFileToDownloadsTable("materials/manifest/overlays/only_headshot_round.vmt");

	// Precaches the model which we intend to use
	PrecacheGeneric("materials/manifest/overlays/normal_round.vtf", true);
	PrecacheGeneric("materials/manifest/overlays/normal_round.vmt", true);
	PrecacheGeneric("materials/manifest/overlays/only_headshot_round.vtf", true);
	PrecacheGeneric("materials/manifest/overlays/only_headshot_round.vmt", true);

	// Precaches the sound which we intend to use
	PrecacheSound("physics/flesh/flesh_bloody_break.wav", true);
	PrecacheSound("physics/flesh/flesh_squishy_impact_hard1.wav", true);
	PrecacheSound("physics/flesh/flesh_squishy_impact_hard2.wav", true);
	PrecacheSound("physics/flesh/flesh_squishy_impact_hard3.wav", true);
	PrecacheSound("physics/flesh/flesh_squishy_impact_hard4.wav", true);
}



///////////////////////////////
// - Timer Based Functions - //
///////////////////////////////


// This happens 0.1 seconds after a player spawns
public Action Timer_ApplyOverlay(Handle timer, int client)
{
	// If the client does not meet our validation criteria then execute this section
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	if(HeadshotOnlyRound)
	{
		// Applies an overlay to the client's screen
		ClientCommand(client, "r_screenoverlay manifest/overlays/only_headshot_round.vmt");

		return Plugin_Continue;
	}

	// Removes any scren overlay currently added to the client's screen
	ClientCommand(client, "r_screenoverlay manifest/overlays/normal_round.vmt");

	return Plugin_Continue;
}


// This happens 5.0 seconds after a player spawns
public Action Timer_RemoveOverlay(Handle timer, int client)
{
	// If the client does not meet our validation criteria then execute this section
	if(!IsValidClient(client))
	{
		return Plugin_Continue;
	}

	// Removes any scren overlay currently added to the client's screen
	ClientCommand(client, "r_screenoverlay 0");

	return Plugin_Continue;
}



////////////////////////////////
// - Return Based Functions - //
////////////////////////////////


// Returns true if the client meets the validation criteria. elsewise returns false
public bool IsValidClient(int client)
{
	if (!(1 <= client <= MaxClients) || !IsClientConnected(client) || !IsClientInGame(client) || IsClientSourceTV(client) || IsClientReplay(client))
	{
		return false;
	}

	return true;
}
