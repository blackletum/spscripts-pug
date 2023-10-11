/*
    Healthy - toggle infinite health mode

    sm_healthy [0|1] - toggle infinite health mode or set it depending on
                       if you supplied args or not.
*/

#include <sdktools>
#include <events>
#pragma newdecls required
#pragma semicolon 1

#define DAMAGE_NO           0   // Godmode
#define DAMAGE_EVENTS_ONLY  1	// Call damage functions, but don't modify health
#define DAMAGE_YES          2   // Allow taking damage
#define DAMAGE_AIM          3   // ???

public Plugin myinfo =
{
    name = "Healthy",
    author = "Pug",
    description = "Toggle infinite health mode.",
    version = "1.0.0",
    url = "None"
}

public void OnPluginStart()
{
    LoadTranslations("common.phrases");
    RegConsoleCmd("sm_healthy", Command_Healthy, "Set infinite health mode. Usage: sm_healthy [0|1]");

    //HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
}

/*
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    SetEntProp(client, Prop_Data, "m_takedamage", infiniteHealth[client] ? DAMAGE_EVENTS_ONLY : DAMAGE_YES, 1);
}
*/

public Action Command_Healthy(int client, int args)
{
    bool newState = true;
    char arg1[2];
    GetCmdArg(1, arg1, sizeof(arg1));

    if (args >= 1)
        newState = !StrEqual(arg1, "0", false);
    else
        newState = (GetEntProp(client, Prop_Data, "m_takedamage") - 1); // 2 = 1, 1 = 0


    PrintToServer("[SM] Infinite Health chose '%N's infinite health value to be %d.", client, newState);

    if (newState)
    {
        ReplyToCommand(client, "[SM] You are now in healthy mode!");
        SetEntProp(client, Prop_Data, "m_takedamage", DAMAGE_EVENTS_ONLY, 1);
    }
    else
    {
        ReplyToCommand(client, "[SM] You are no longer in healthy mode!");
        SetEntProp(client, Prop_Data, "m_takedamage", DAMAGE_YES, 1);
    }
    return Plugin_Handled;
}
