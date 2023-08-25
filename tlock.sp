/*
  Team Locker - lock teams. restricted to team fortress 2 and mods only.

  sm_tlock_enabled     - enable tlock
  sm_tlock_locked_team - what team to lock

  sm_tlock             - this is a command to easily modify the above cvars. arguments: none, red, blue/blu.
*/

#include <sourcemod>
#define TLOCK_TEAM_BLUE true
#define TLOCK_TEAM_RED false

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = "Team Lock",
    author = "Pug",
    description = "A plugin to lock teams.",
    version = "1.0.0",
    url = "None"
};

ConVar g_cvLockTeam;
ConVar g_cvEnabled;

public void OnPluginStart() {
    LoadTranslations("common.phrases");

    g_cvEnabled = CreateConVar("sm_tlock_enabled",
        "0",
        "Enable Team Lock?",
        FCVAR_NOTIFY);
    g_cvLockTeam = CreateConVar("sm_tlock_locked_team",
        "0",
        "What team to lock. 0 is RED, everything else is BLU.",
        FCVAR_NOTIFY);

    RegAdminCmd("sm_tlock", Command_TLock, ADMFLAG_GENERIC, "sm_tlock <team|none> - locks a team. teams: red, blue, blu");

    AddCommandListener(TLock_JoinTeam, "jointeam");
}

public Action Command_TLock(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage: sm_tlock <team|none>");
        return Plugin_Handled;
    }

    char teamArg[5];
    GetCmdArg(1, teamArg, sizeof(teamArg));

    if (StrEqual(teamArg, "none", false)) {
        g_cvEnabled.SetBool(false);
        return Plugin_Handled;
    }
    g_cvEnabled.SetBool(true);

    if (StrEqual(teamArg, "red", false)) {
        g_cvLockTeam.SetBool(TLOCK_TEAM_RED);
    } else if (StrEqual(teamArg, "blue", false) ||
               StrEqual(teamArg, "blu",  false)) {
        g_cvLockTeam.SetBool(TLOCK_TEAM_BLUE);
    }

    return Plugin_Handled;
}

public Action TLock_JoinTeam(int client, const char[] command, int argc) {
    PrintToServer("[SM] Player ran %s!", command);
    if (!g_cvEnabled.BoolValue) return Plugin_Continue;
    PrintToServer("[SM] TLock is enabled. Doing checks..");

    char teamArg[5];
    char disabledTeamArg[5];

    GetCmdArg(1, teamArg, sizeof(teamArg));
    disabledTeamArg = g_cvLockTeam.BoolValue ? "blue" : "red";

    if (StrEqual(teamArg, disabledTeamArg, false)) {
        PrintCenterText(client, "That team is locked!");
        return Plugin_Stop;
    }
    return Plugin_Continue;
}
