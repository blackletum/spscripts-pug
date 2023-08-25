/* 
  Other People Kill Blocker - a grief command blocker for sv_cheats servers.

  no cvars.
*/

#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#define PLAYER_ENT_NAME "player"
#define WORLD_ENT_NAME "worldspawn"

public Plugin myinfo = {
    name = "Other People Kill Blocker",
    author = "Pug",
    description = "A plugin to disable annoying grief commands on sv_cheats 1 servers.",
    version = "1.0.0",
    url = "None"
}

public void EntLog(int client, const char[] command) {
    char allArgs[MAX_NAME_LENGTH];
    char clientBuffer[MAX_NAME_LENGTH];

    GetCmdArgString(allArgs, sizeof(allArgs));
    GetClientName(client, clientBuffer, sizeof(clientBuffer));
    PrintToServer("[entlog] %s: %s %s", clientBuffer, command, allArgs);
}

// returns true if it passes
// returns false it it fails
public bool DoRemoveCheck(int client, const char[] command, int argc, bool autoReply) {
    if (client == 0) return true;

    char argBuffer[MAX_NAME_LENGTH];
    if (argc > 0) {
        GetCmdArg(1, argBuffer, sizeof(argBuffer));
        if (StrEqual(argBuffer, PLAYER_ENT_NAME) || StrEqual(argBuffer, WORLD_ENT_NAME)) {
            ReplyToCommand(client, "[SM] Your command was ignored because you can't remove/create that type of entity.");
            return false;
        }
    }
    return true;
}

public void OnPluginStart() {
    LoadTranslations("common.phrases");
    AddCommandListener(OPKB_Kill, "kill");
    AddCommandListener(OPKB_Kill, "explode");
    AddCommandListener(OPKB_Ent_Remove_All, "ent_remove_all");
    AddCommandListener(OPKB_Ent_Remove, "ent_remove");
    AddCommandListener(OPKB_Ent_Remove_All, "ent_create");
}

public Action OPKB_Kill(int client, const char[] command, int argc) {
    if (argc != 0) {
        ReplyToCommand(client, "[SM] Your command was ignored because you can't kill other players.");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action OPKB_Ent_Remove_All(int client, const char[] command, int argc) {
    EntLog(client, command);
    if (!DoRemoveCheck(client, command, argc, true)) return Plugin_Handled;
    return Plugin_Continue;
}

public Action OPKB_Ent_Remove(int client, const char[] command, int argc) {
    EntLog(client, command);
    if (!DoRemoveCheck(client, command, argc, true)) return Plugin_Handled;
    int aimTarget = GetClientAimTarget(client, true) > 0
    if (aimTarget) {
        ReplyToCommand(client, "[SM] Your command was ignored because removing players is not allowed.");
        return Plugin_Handled;
    } else {
        PrintToServer("[debug] Return code: %d", aimTarget);
    }
    return Plugin_Continue;
}
