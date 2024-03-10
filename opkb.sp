/*
  Other People Kill Blocker - a grief command blocker for sv_cheats servers.

  no cvars.
*/

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo = {
    name = "Other People Kill Blocker",
    author = "Pug",
    description = "A plugin to disable annoying grief commands on sv_cheats 1 servers.",
    version = "1.0.0",
    url = "None"
}

#define BLOCK_LIST_SIZE 3
#define PATH_BLOCK_LIST_SIZE 1

char block_list[][] = {
    "player", "worldspawn", "tf_player_manager"
};

char path_block_list[][] = {
    "props_junk/watermelon01.mdl",
}

public Action EntLog(int client, const char[] command, int argc) {
    char allArgs[MAX_NAME_LENGTH];
    char clientBuffer[MAX_NAME_LENGTH];

    GetCmdArgString(allArgs, sizeof(allArgs));
    GetClientName(client, clientBuffer, sizeof(clientBuffer));
    PrintToServer("[entlog] %s: %s %s", clientBuffer, command, allArgs);

    return Plugin_Continue;
}

public bool DoPrivilegeCheck(int client, const char[] command, int argc) {
    if (client == 0) return true;
    if (CheckCommandAccess(client, command, ADMFLAG_GENERIC)) return true;
    return false;
}

// returns true if it passes
// returns false it it fails
public bool DoRemoveCheck(int client, const char[] command, int argc, bool autoReply) {
    if (DoPrivilegeCheck(client, command, argc)) return true;
    if (argc <= 0) return true;

    char argBuffer[MAX_NAME_LENGTH];

    GetCmdArg(1, argBuffer, sizeof(argBuffer));
    PrintToServer("i got a %s", argBuffer);
    for (int entname = 0; entname < BLOCK_LIST_SIZE; entname++) {
        if (StrEqual(argBuffer, block_list[entname])) {
            if (autoReply)
                ReplyToCommand(client, "[SM] Your command was ignored because you can't remove/create that type of entity.");
            return false;
        }
    }
    return true;
}

public bool BlockPath(char[] path) {
    for (int index = 0; index < PATH_BLOCK_LIST_SIZE; index++) {
        char as_linux_path[MAX_NAME_LENGTH];
        strcopy(as_linux_path, sizeof(as_linux_path), path);
        ReplaceString(as_linux_path, sizeof(as_linux_path), "\\", "/", false);

        if (StrEqual(as_linux_path, path_block_list[index], false)) {
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
    AddCommandListener(OPKB_BlockEntirely, "ent_pause");
    AddCommandListener(OPKB_BlockEntirely, "mp_forcerespawnplayers");
    AddCommandListener(OPKB_BlockEntirely, "bot");
    AddCommandListener(OPKB_Impulse, "impulse");
}

public Action OPKB_Kill(int client, const char[] command, int argc) {
    if (argc != 0) {
        ReplyToCommand(client, "[SM] Your command was ignored because you can't kill other players.");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action OPKB_Ent_Remove_All(int client, const char[] command, int argc) {
    EntLog(client, command, argc);
    if (!DoRemoveCheck(client, command, argc, true)) return Plugin_Handled;
    return Plugin_Continue;
}

/*
// fuck this
public Action OPKB_Ent_Create(int client, const char[] command, int argc) {
    EntLog(client, command, argc);
    if (!DoRemoveCheck(client, command, argc, true)) return Plugin_Handled;
    char entname[MAX_NAME_LENGTH];
    bool encounteredModelname = false;
    GetCmdArg(1, entname, sizeof(entname));
    if (!StrEqual(entname, "generic_actor", false))
        return Plugin_Continue;
    for (int keyI = 2; keyI < argc; keyI += 2) {
        int valI = keyI + 1;
        char key[MAX_NAME_LENGTH];
        char val[MAX_NAME_LENGTH];
        GetCmdArg(keyI, key, sizeof(key));
        GetCmdArg(valI, val, sizeof(val));
        if (!StrEqual(key, "modelname", false)) continue;
        if (!BlockPath(val)) return Plugin_Handled;
        encounteredModelname = true;
    }
    if (!encounteredModelname) {
        ReplyToCommand(client, "[SM] Your command was ignored because it could crash the server");
    }
    return Plugin_Continue;
}
*/

public Action OPKB_Ent_Remove(int client, const char[] command, int argc) {
    EntLog(client, command, argc);
    if (!DoRemoveCheck(client, command, argc, true)) return Plugin_Handled;
    int aimTarget = GetClientAimTarget(client, true) > 0

    PrintToServer("[debug] Return code: %d", aimTarget);
    if (aimTarget) {
        ReplyToCommand(client, "[SM] Your command was ignored because removing players is not allowed.");
        return Plugin_Handled;
    }
    return Plugin_Continue;
}

public Action OPKB_BlockEntirely(int client, const char[] command, int argc) {
    EntLog(client, command, argc);
    if (DoPrivilegeCheck(client, command, argc)) return Plugin_Continue;
    ReplyToCommand(client, "[SM] Your command was ignored because the command '%s' is blocked entirely.", command);
    return Plugin_Handled;
}

public Action OPKB_Impulse(int client, const char[] command, int argc) {
    EntLog(client, command, argc);
    if (DoPrivilegeCheck(client, command, argc)) return Plugin_Continue;
    char impulseAction[4];
    GetCmdArg(1, impulseAction, sizeof(impulseAction));

    int impulseAsInt = StringToInt(impulseAction);

    if (impulseAsInt != 203) return Plugin_Continue; // impulse 203 can remove players
    return Plugin_Handled;
}

public Action OPKB_AddCond(int client, const char[] command, int argc) {
    if (DoPrivilegeCheck(client, command, argc)) return Plugin_Continue;
    bool condBlocked = false;

    char condString[16];
    int cond;
    GetCmdArg(1, condString, sizeof(condString));
    cond = StringToInt(condString);

    switch (cond) {
        case 47: {
            condBlocked = true;
        }
    }

    if (condBlocked) {
        ReplyToCommand(client, "[SM] Your command was ignored because the condition '%d' is blocked.", cond);
        return Plugin_Handled;
    }
    return Plugin_Continue;
}
