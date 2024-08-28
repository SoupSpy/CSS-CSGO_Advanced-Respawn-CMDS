#include <cstrike>
#include <sdktools> 
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.1"

public Plugin myinfo = 
{
	name = "[VX] Advanced Respawn Commands", 
	author = "Yekta.T [The SoupSpy]", 
	description = "This plugin contains advanced respawn commands that can be really useful in game modes like fun, public, or jailbreak.", 
	version = PLUGIN_VERSION, 
	url = "vortexguys.com"
}

ConVar gc_enabled;
ConVar gc_gRes;
ConVar gc_Res;
ConVar gc_freezeCmd;

float g_corpsePos[MAXPLAYERS + 1][3];

int gc_ienabled;
int gc_igRes;
int gc_iRes;

//char prefix[66] = "{darkred}[ {olive}VortéX Respawn {darkred}]{default}";
char gc_sfreezeCmd[66];


public void OnPluginStart()
{
	RegAdminCmd("sm_hrespawn", CMD_Hrespawn, ADMFLAG_BAN, "Respawns the dead player(s) at the position where they died.");
	RegAdminCmd("sm_respawn", CMD_respawn, ADMFLAG_BAN, "Respawns the dead player(s)");
	RegAdminCmd("sm_grespawn", CMD_Grespawn, ADMFLAG_BAN, "Respawns the dead player(s) at the eye position of the person using the command, i.e., where they are looking.");
	RegAdminCmd("sm_hgoto", CMD_Hgoto, ADMFLAG_BAN, "Teleports the person using the command to the position where the player died.");
	
	
	gc_gRes = CreateConVar("sm_vxrespawn_grespawn", "1", "Enables or Disables the Grespawn command.", _, true, 0.0, true, 1.0);
	gc_enabled = CreateConVar("sm_vxrespawn_enable", "1", "Enables or Disables the plugin itself.", _, true, 0.0, true, 1.0);
	gc_Res = CreateConVar("sm_vxrespawn_respawn", "1", "Enables or Disables the regular respawn command.", _, true, 0.0, true, 1.0);
	gc_freezeCmd = CreateConVar("sm_vxrespawn_freezecmd", "sm_freeze", "Enter the command line required to trigger the freeze plugin on your server; if there isn't one, leave it blank. Leaving it blank will disable the freeze arguments in the Grespawn command.");
	
	AutoExecConfig(true, "vx_respawn.plugin");
	
	HookConVarChange(gc_freezeCmd, ConVarChanged_Callback);
	HookConVarChange(gc_gRes, ConVarChanged_Callback);
	HookConVarChange(gc_enabled, ConVarChanged_Callback);
	HookConVarChange(gc_Res, ConVarChanged_Callback);
	
	HookEvent("player_death", Event_PlayerDeath);
	
	LoadTranslations("common.phrases");
	LoadTranslations("vx_respawn.phrases");
}

public void OnConfigsExecuted()
{
	GetConVarString(gc_freezeCmd, gc_sfreezeCmd, sizeof(gc_sfreezeCmd));
	gc_igRes = GetConVarInt(gc_gRes);
	gc_iRes = GetConVarInt(gc_Res);
	gc_ienabled = GetConVarInt(gc_enabled);
}

public void ConVarChanged_Callback(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrEqual(oldValue, newValue, true))return;
	
	if (convar == gc_freezeCmd)
		FormatEx(gc_sfreezeCmd, sizeof(gc_sfreezeCmd), newValue);
	else if (convar == gc_gRes)
		gc_igRes = StringToInt(newValue);
	else if (convar == gc_Res)
	{
		gc_iRes = StringToInt(newValue);
	}
	else if (convar == gc_enabled)
	{
		gc_ienabled = StringToInt(newValue);
	}
}

public void OnMapStart()
{
	if (!gc_ienabled)return;
	for (int i = 0; i <= MAXPLAYERS; i++)
	{
		g_corpsePos[i][0] = 0.0;
		g_corpsePos[i][1] = 0.0;
		g_corpsePos[i][2] = 0.0;
	}
}

public void OnClientDisconnect(int client)
{
	if (!gc_ienabled)return;
	for (int j = 0; j < 3; j++)
	{
		g_corpsePos[client][j] = 0.0;
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if (!gc_ienabled)return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client)return;
	
	GetClientAbsOrigin(client, g_corpsePos[client]);
}

public Action CMD_respawn(int client, int args)
{
	if (!gc_ienabled)
	{
		CReplyToCommand(client, "%t %t", "prefix", "disabled");
		return Plugin_Handled;
	}
	
	if (!gc_iRes)
	{
		return Plugin_Handled;
	}
	
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_respawn <name|userid>]");
		return Plugin_Handled;
	}
	
	char arg[MAX_NAME_LENGTH];
	GetCmdArg(1, arg, sizeof(arg));
	
	int targets[MAXPLAYERS];
	char TargetName[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int count = ProcessTargetString(arg, client, targets, MAXPLAYERS, COMMAND_FILTER_CONNECTED, TargetName, sizeof(TargetName), tn_is_ml);
	
	if (count < 1)
	{
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	CPrintToChat(client, "%t %t", "prefix", "checkConsole");
	for (int i = 0; i < count; i++)
	{
		CS_RespawnPlayer(targets[i]);
		char sName[32]; GetClientName(targets[i], sName, 32);
		PrintToConsole(client, "[VX-Respawn] %t", 
			"respawned", sName);
	}
	
	return Plugin_Handled;
}

public Action CMD_Grespawn(int client, int args)
{
	if (!gc_ienabled)
	{
		CReplyToCommand(client, "%t %t", "prefix", "disabled");
		return Plugin_Handled;
	}
	
	
	if (!gc_igRes)
	{
		CReplyToCommand(client, "%t %t", "prefix", "disabledCmd");
		return Plugin_Handled;
	}
	
	char szarg[512] = "";
	if (!StrEqual("", gc_sfreezeCmd, false))
		FormatEx(szarg, sizeof(szarg), "<freeze 1|0> <freeze time != 0>");
	
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_grespawn <name|userid> %s", szarg);
		return Plugin_Handled;
	}
	
	char starget[MAX_NAME_LENGTH], freeze[2], freezeTime[11];
	GetCmdArg(1, starget, sizeof(starget));
	
	
	int targets[MAXPLAYERS];
	char TargetName[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int count = ProcessTargetString(starget, client, targets, MAXPLAYERS, COMMAND_FILTER_DEAD, TargetName, sizeof(TargetName), tn_is_ml);
	
	if (count < 1)
	{
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	GetCmdArg(2, freeze, sizeof(freeze));
	GetCmdArg(3, freezeTime, sizeof(freezeTime));
	
	int iFreeze = StringToInt(freeze), iTime = StringToInt(freezeTime);
	if (StrEqual(szarg, ""))iFreeze = 0;
	
	if (iFreeze > 0 && (args != 3 || iTime == 0))
	{
		ReplyToCommand(client, "[SM] Usage: sm_grespawn <name|userid> <freeze 1|0> <freeze time != 0>");
		return Plugin_Handled;
	}
	
	float eyeang[3];
	GetCollisionPoint(client, eyeang);
	eyeang[2] += 4;
	
	CPrintToChat(client, "%t %t", "prefix", "checkConsole");
	for (int i = 0; i < count; i++)
	{
		CS_RespawnPlayer(targets[i]);
		TeleportEntity(targets[i], eyeang, NULL_VECTOR, NULL_VECTOR);
		char name[32]; GetClientName(targets[i], name, 32);
		PrintToConsole(client, "[VX-Respawn] %t, %0.0f %0.0f %0.0f", 
			"eye angle pos", name, eyeang[0], eyeang[1], eyeang[2]);
		
		if (iFreeze)
		{
			ServerCommand("%s %N %d", gc_sfreezeCmd, targets[i], iTime);
			PrintToConsole(client, "[VX-Respawn] %t %0.0f %0.0f %0.0f", 
				"freeze", name, iTime, eyeang[0], eyeang[1], eyeang[2]);
		}
	}
	
	return Plugin_Handled;
}

public Action CMD_Hrespawn(int client, int args)
{
	if (!gc_ienabled)
	{
		CReplyToCommand(client, "%t %t", "prefix", "disabled");
		return Plugin_Handled;
	}
	
	
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_hrespawn <name|userid> [Players must be dead]");
		return Plugin_Handled;
	}
	char arg[MAX_NAME_LENGTH];
	GetCmdArg(1, arg, sizeof(arg));
	
	int targets[MAXPLAYERS];
	char TargetName[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int count = ProcessTargetString(arg, client, targets, MAXPLAYERS, COMMAND_FILTER_DEAD, TargetName, sizeof(TargetName), tn_is_ml);
	
	if (count < 1)
	{
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	CPrintToChat(client, "%t %t", "prefix", "checkConsole");
	for (int i = 0; i < count; i++)
	{
		CS_RespawnPlayer(targets[i]);
		
		char name[32]; GetClientName(targets[i], name, 32);
		if (!g_corpsePos[targets[i]][0] && !g_corpsePos[targets[i]][1] && !g_corpsePos[targets[i]][2])
		{
			PrintToConsole(client, "[VX-Respawn] %t", 
				"tp to corpse failed", name);
			continue;
		}
		
		TeleportEntity(targets[i], g_corpsePos[targets[i]], NULL_VECTOR, NULL_VECTOR);
		PrintToConsole(client, "[VX-Respawn] %t %0.0f %0.0f %0.0f", 
			"hrespawn", name, g_corpsePos[targets[i]][0], g_corpsePos[targets[i]][1], g_corpsePos[targets[i]][2]);
	}
	
	return Plugin_Handled;
}

public Action CMD_Hgoto(int client, int args)
{
	if (!gc_ienabled)
	{
		CReplyToCommand(client, "%t %t", "prefix", "disabled");
		return Plugin_Handled;
	}
	
	
	if (!client)return Plugin_Handled;
	
	if (args != 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_hgoto <name|userid> [Players must be dead]");
		return Plugin_Handled;
	}
	
	char arg[MAX_NAME_LENGTH];
	GetCmdArg(1, arg, sizeof(arg));
	
	int targets[1];
	char TargetName[MAX_TARGET_LENGTH];
	bool tn_is_ml;
	
	int count = ProcessTargetString(arg, client, targets, 1, COMMAND_FILTER_DEAD | COMMAND_FILTER_NO_MULTI, TargetName, sizeof(TargetName), tn_is_ml);
	
	if (count < 1)
	{
		ReplyToTargetError(client, count);
		return Plugin_Handled;
	}
	
	int target = targets[0];
	char name[32]; GetClientName(target, name, 32);
	if (!g_corpsePos[target][0] && !g_corpsePos[target][1] && !g_corpsePos[target][2])
	{
		CReplyToCommand(client, "%t %t", "prefix", "tp to corpse failed chat", target);
		return Plugin_Handled;
	}
	
	TeleportEntity(client, g_corpsePos[target], NULL_VECTOR, NULL_VECTOR);
	CReplyToCommand(client, "%t %t {red}%0.0f %0.0f %0.0f", "prefix", "tp to corpse", name, g_corpsePos[target][0], g_corpsePos[target][1], g_corpsePos[target][2]);
	
	return Plugin_Handled;
}

// below here is from https://forums.alliedmods.net/showthread.php?t=114393
stock void GetCollisionPoint(int client, float pos[3])
{
	float vOrigin[3], vAngles[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);
	
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		
		return;
	}
	
	CloseHandle(trace);
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask)
{
	return entity > MaxClients;
} 