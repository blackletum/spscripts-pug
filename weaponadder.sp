/*
 * Weapon Adder - give yourself weapons
 *
 * sm_give             - give someone a weapon. admin only.
 * sm_giveme           - same as above but it only works on you. normal players can run.
 * sm_take             - remove someone's weapon. admin only.
 * sm_takeme           - same as above but it only works on you. normal players can run.
 * sm_civilian         - remove all weapon slots from a player. admin only.
 * sm_civilianme       - same as above but it only works on you. normal players can run.
*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <pug>

#pragma newdecls required
#pragma semicolon 1

#define SLOT1     2
#define SLOT2     1
#define SLOT3     0
#define SLOT4     3
#define SLOT5     4

public Plugin myinfo = {
    name = "Weapon Adder",
    author = "Pug",
    description = "Give people weapons.",
    version = "1.0.0",
    url = "None"
};

public void OnPluginStart() {
    LoadTranslations("common.phrases");

    RegAdminCmd("sm_give", Command_Give, ADMFLAG_GENERIC, "sm_give <target(s)> <weapon> - gives target(s) a weapon.");
    RegConsoleCmd("sm_giveme", Command_GiveMe, "sm_giveme <weapon> - gives you a weapon.");

    RegAdminCmd("sm_take", Command_Take, ADMFLAG_GENERIC, "sm_take <target(s)> <weapon> - removes weapon from target(s).");
    RegConsoleCmd("sm_takeme", Command_TakeMe, "sm_takeme <weapon> - removes a weapon from you.");

    RegAdminCmd("sm_civilian", Command_Civilian, ADMFLAG_GENERIC, "sm_civilian <target(s)> - removes all of the target(s) weapons, causing a civilian pose.");
    RegConsoleCmd("sm_civilianme", Command_CivilianMe, "sm_civilianme - removes all of your weapons, causing a civilian pose.");

    RegAdminCmd("sm_trade", Command_Trade, ADMFLAG_GENERIC, "sm_trade <target> - trades your currently equipped weapon with someone else's weapon in that same slot.");
}

int GetSlotFromWeapon(char[] weapon) {
    for (int primary = 0; primary < PUG_WEAPON_NUM_PRIMARY; primary++) {
        if (StrEqual(_inc_pug_primary[primary], weapon, false)) {
            return SLOT1;
        }
    }
    for (int secondary = 0; secondary < PUG_WEAPON_NUM_SECONDARY; secondary++) {
        if (StrEqual(_inc_pug_secondary[secondary], weapon, false)) {
            return SLOT2;
        }
    }
    for (int melee = 0; melee < PUG_WEAPON_NUM_MELEE; melee++) {
        if (StrEqual(_inc_pug_melee[melee], weapon, false)) {
            return SLOT3;
        }
    }
    /*
    for (int pda1 = 0; pda1 < PUG_WEAPON_NUM_PDA1; pda1++) {
        if (StrEqual(_inc_pug_pda1[pda1], weapon, false)) {
            return SLOT4;
        }
    }
    */
    return SLOT4;
}

void CivilianPose(int client) {
    RemoveWeaponSlot(client, SLOT1);
    RemoveWeaponSlot(client, SLOT2);
    RemoveWeaponSlot(client, SLOT3);
    RemoveWeaponSlot(client, SLOT4);
    RemoveWeaponSlot(client, SLOT5);
}

public Action Command_Give(int client, int argc) {
    if (argc < 2) {
        ReplyToCommand(client, "[SM] Usage: sm_give <target(s)> <weapon>");
        return Plugin_Handled;
    }

    char targetBuffer[MAX_NAME_LENGTH];
    char targetName[MAX_TARGET_LENGTH];
    int targetList[MAXPLAYERS];
    int targetCount;
    bool tn_is_ml;

    GetCmdArg(1, targetBuffer, sizeof(targetBuffer));
    if ((targetCount = ProcessTargetString(targetBuffer,
                    client,
                    targetList,
                    MAXPLAYERS,
                    COMMAND_FILTER_ALIVE,
                    targetName, sizeof(targetName),
                    tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, targetCount);
        return Plugin_Handled;
    }

    char weaponBuffer[PUG_WEAPONCLASS_MAX];
    GetCmdArg(2, weaponBuffer, sizeof(weaponBuffer));

    for (int i = 0; i < targetCount; i++) {
        int target = targetList[i];
        if (!IsClientInGame(target)) {
            continue;
        }
        RemoveWeaponSlot(target, GetSlotFromWeapon(weaponBuffer));
        FakeClientCommand(target, "give %s", weaponBuffer);
        FakeClientCommand(target, "use %s", weaponBuffer);
    }

    return Plugin_Handled;
}

public Action Command_GiveMe(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage: sm_giveme <weapon>");
        return Plugin_Handled;
    }
    char weaponBuffer[PUG_WEAPONCLASS_MAX];
    GetCmdArg(1, weaponBuffer, sizeof(weaponBuffer));

    RemoveWeaponSlot(client, GetSlotFromWeapon(weaponBuffer));
    FakeClientCommand(client, "give %s", weaponBuffer);
    FakeClientCommand(client, "use %s", weaponBuffer);

    return Plugin_Handled;
}

public Action Command_Take(int client, int argc) {
    if (argc < 2) {
        ReplyToCommand(client, "[SM] Usage: sm_take <target(s)> <weapon>");
        return Plugin_Handled;
    }

    char targetBuffer[MAX_NAME_LENGTH];
    char targetName[MAX_TARGET_LENGTH];
    int targetList[MAXPLAYERS];
    int targetCount;
    bool tn_is_ml;

    GetCmdArg(1, targetBuffer, sizeof(targetBuffer));
    if ((targetCount = ProcessTargetString(targetBuffer,
                    client,
                    targetList,
                    MAXPLAYERS,
                    COMMAND_FILTER_ALIVE,
                    targetName, sizeof(targetName),
                    tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, targetCount);
        return Plugin_Handled;
    }

    char weaponBuffer[PUG_WEAPONCLASS_MAX];
    GetCmdArg(2, weaponBuffer, sizeof(weaponBuffer));

    for (int i = 0; i < targetCount; i++) {
        int target = targetList[i];
        if (!IsClientInGame(target)) {
            continue;
        }
        RemoveWeaponSlot(target, GetSlotFromWeapon(weaponBuffer));
    }

    return Plugin_Handled;
}

public Action Command_TakeMe(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage: sm_takeme <weapon>");
        return Plugin_Handled;
    }
    char weaponBuffer[PUG_WEAPONCLASS_MAX];
    GetCmdArg(1, weaponBuffer, sizeof(weaponBuffer));

    RemoveWeaponSlot(client, GetSlotFromWeapon(weaponBuffer));

    return Plugin_Handled;
}

public Action Command_Civilian(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage: sm_civilian <target(s)>");
        return Plugin_Handled;
    }

    char targetBuffer[MAX_NAME_LENGTH];
    char targetName[MAX_TARGET_LENGTH];
    int targetList[MAXPLAYERS];
    int targetCount;
    bool tn_is_ml;

    GetCmdArg(1, targetBuffer, sizeof(targetBuffer));
    if ((targetCount = ProcessTargetString(targetBuffer,
                    client,
                    targetList,
                    MAXPLAYERS,
                    COMMAND_FILTER_ALIVE,
                    targetName, sizeof(targetName),
                    tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, targetCount);
        return Plugin_Handled;
    }

    for (int i = 0; i < targetCount; i++) {
        int target = targetList[i];
        if (!IsClientInGame(target)) {
            continue;
        }
        CivilianPose(target);
    }

    return Plugin_Handled;
}

public Action Command_CivilianMe(int client, int argc) {
    CivilianPose(client);

    return Plugin_Handled;
}

public Action Command_Trade(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage: sm_civilian <target(s)>");
        return Plugin_Handled;
    }

    char targetBuffer[MAX_NAME_LENGTH];
    char targetName[MAX_TARGET_LENGTH];
    int targetList[MAXPLAYERS];
    int targetCount;
    bool tn_is_ml;

    GetCmdArg(1, targetBuffer, sizeof(targetBuffer));
    if ((targetCount = ProcessTargetString(targetBuffer,
                    client,
                    targetList,
                    MAXPLAYERS,
                    COMMAND_FILTER_ALIVE|COMMAND_FILTER_NO_MULTI,
                    targetName, sizeof(targetName),
                    tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, targetCount);
        return Plugin_Handled;
    }

    int target = targetList[0];
    if (target == client) {
        ReplyToCommand(client, "[SM] That's you!");
        return Plugin_Handled;
    }

    int myWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", 0);
    if (myWep == -1) {
        ReplyToCommand(client, "[SM] Please equip a weapon first.");
        return Plugin_Handled;
    }

    char myWepName[PUG_WEAPONCLASS_MAX];
    bool myWepNameResult = GetEdictClassname(myWep, myWepName, sizeof(myWepName));
    if (!myWepNameResult) {
        ReplyToCommand(client, "[SM] Unknown error while trying to get the classname of your weapon.");
        return Plugin_Handled;
    }

    int mySlot = GetSlotFromWeapon(myWepName);

    // now we get their weapon

    int theirWep;
    char theirWepName[PUG_WEAPONCLASS_MAX];
    /*
    for (int i = MaxClients+1; i < GetMaxEntities(); i++) {
        if (!IsValidEntity(i)) {
            continue;
        }
        bool theirWepNameResult = GetEdictClassname(i, theirWepName, sizeof(theirWepName));
        if (!theirWepNameResult) {
            ReplyToCommand(client, "[SM] Unknown error while trying to get the classname of their weapon.");
            return Plugin_Handled;
        }
        if (!StrContains(theirWepName, "tf_weapon_", false) == 0) continue;

        theirSlot = GetSlotFromWeapon(theirWepName);
    }
    */
    // laskfsdfasf
    // please tell me theres a way to improve this stupid code
    if (mySlot == SLOT1)
        for (int i = 0; i < PUG_WEAPON_NUM_PRIMARY; i++) {
            theirWep = GetPlayerWeaponByName(target, _inc_pug_primary[i]);
            PrintToServer("::: primary loop. theirWep: %d name: %s", theirWep, _inc_pug_primary[i]);
            if (theirWep == -1) continue;
            strcopy(theirWepName, sizeof(theirWepName), _inc_pug_primary[i]);
            break;
        }
    else if (mySlot == SLOT2)
        for (int i = 0; i < PUG_WEAPON_NUM_SECONDARY; i++) {
            theirWep = GetPlayerWeaponByName(target, _inc_pug_secondary[i]);
            PrintToServer("::: secondary loop. theirWep: %d name: %s", theirWep, _inc_pug_secondary[i]);
            if (theirWep == -1) continue;
            strcopy(theirWepName, sizeof(theirWepName), _inc_pug_secondary[i]);
            break;
        }
    else if (mySlot == SLOT3)
        for (int i = 0; i < PUG_WEAPON_NUM_MELEE; i++) {
            theirWep = GetPlayerWeaponByName(target, _inc_pug_melee[i]);
            PrintToServer("::: melee loop. theirWep: %d name: %s", theirWep, _inc_pug_melee[i]);
            if (theirWep == -1) continue;
            strcopy(theirWepName, sizeof(theirWepName), _inc_pug_melee[i]);
            break;
        }
    else if (mySlot == SLOT4)
        for (int i = 0; i < PUG_WEAPON_NUM_PDA1; i++) {
            theirWep = GetPlayerWeaponByName(target, _inc_pug_pda1[i]);
            PrintToServer("::: pda1 loop. theirWep: %d name: %s", theirWep, _inc_pug_pda1[i]);
            if (theirWep == -1) continue;
            strcopy(theirWepName, sizeof(theirWepName), _inc_pug_pda1[i]);
            break;
        }
    if (theirWep == -1) {
        ReplyToCommand(client, "[SM] Something went wrong while trying to get their weapon.");
        return Plugin_Handled;
    }
    // finally, we trade weapons
    RemoveEdict(theirWep);
    RemoveEdict(myWep);
    FakeClientCommand(target, "give %s", myWepName);
    FakeClientCommand(client, "give %s", theirWepName);

    return Plugin_Handled;
}
