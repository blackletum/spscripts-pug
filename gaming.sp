/*
  Gaming - force a class. restricted to team fortress 2 and mods only.

  sm_gaming <class|none> - set the forced class
*/

#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = "Gaming",
    author = "Pug",
    description = "Force a certain class on everyone.",
    version = "1.0.0",
    url = "None"
};

#define CLASSNAME_SIZE 11 /* how many classes including civilian */
#define CLASSNAME_LONGEST 13 /* longest class name (heavyweapons) */

int gamingIndex;

char classNames[][] = {
    "none",
    "scout",   "soldier",      "pyro",
    "demoman", "heavyweapons", "engineer",
    "medic",   "sniper",       "spy",
    "civilian",
};

char humanClassNames[][] = {
    "NONE",
    "Scout",   "Soldier", "Pyro",
    "Demo",    "Heavy",   "Engineer",
    "Medic",   "Sniper",  "Spy",
    "Civilian",
};

public void OnPluginStart() {
    LoadTranslations("common.phrases");
    gamingIndex = 0; // none

    /*
    g_cvLockTeam = CreateConVar("sm_gaming_class",
        "none",
        "The class to lock. Valid values are: scout, soldier, pyro, demoman, heavyweapons, engineer, medic, sniper, spy, civilian.",
        FCVAR_NOTIFY);
    */

    RegConsoleCmd("sm_gaming", Command_Gaming, "sm_gaming <class|none> - forces a class on the entire server. Valid values: none, scout, soldier, pyro, demoman, heavyweapons, engineer, medic, sniper, spy, civilian.");

    AddCommandListener(Gaming_JoinClass, "joinclass");
}

public Action Command_Gaming(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Current gaming value: %s (human-readable value: %s)", classNames[gamingIndex], humanClassNames[gamingIndex]);
        return Plugin_Handled;
    }
    if (GetUserFlagBits(client) == 0)
    {
        ReplyToCommand(client, "[SM] You do not have privileges to use this command.");
        return Plugin_Handled;
    }

    char classArg[CLASSNAME_LONGEST];
    GetCmdArg(1, classArg, sizeof(classArg));

    for (int i = 0; i < CLASSNAME_SIZE; i++) {
        if (StrEqual(classArg, classNames[i], false) &&
            !StrEqual(classArg, classNames[0], false)) {
            gamingIndex = i;
            PrintCenterTextAll("%s gaming!", humanClassNames[gamingIndex]);
            for (int user = 1; user <= MaxClients; user++) {
                if (IsClientInGame(user)) {
                    FakeClientCommand(user, "joinclass %s", classNames[gamingIndex]);
                }
            }
            return Plugin_Handled;
        }
    }

    PrintCenterTextAll("%s gaming is now over.", humanClassNames[gamingIndex]);
    gamingIndex = 0; // none
    return Plugin_Handled;
}

public Action Gaming_JoinClass(int client, const char[] command, int argc) {
    PrintToServer("[SM] Player ran %s!", command);
    if (gamingIndex == 0) return Plugin_Continue;
    PrintToServer("[SM] Gaming is enabled. Doing checks..");

    char classArg[CLASSNAME_LONGEST];
    GetCmdArg(1, classArg, sizeof(classArg));

    if (!StrEqual(classArg, classNames[gamingIndex], false)) {
        PrintCenterText(client, "That class is locked! Switching you to %s...", humanClassNames[gamingIndex]);
        FakeClientCommand(client, "joinclass %s", classNames[gamingIndex]);
        return Plugin_Stop;
    }
    return Plugin_Continue;
}
