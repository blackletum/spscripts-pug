/*
    Healthy - toggle infinite health mode

    sm_healthy [0|1] - toggle infinite health mode or set it depending on
                       if you supplied args or not.
*/

#include <sdktools>
#include <sdkhooks>
//#include <events>
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

bool g_Healthies[MAXPLAYERS];

public void OnPluginStart()
{
    LoadTranslations("common.phrases");
    RegConsoleCmd("sm_healthy", Command_Healthy, "Set infinite health mode. Usage: sm_healthy [0|1]");
    RegConsoleCmd("sm_amihealthy", Command_AmIHealthy, "Prints 0 if healthy mod is off, prints 1 if on.");

    HookEvent("player_spawn", Event_ResetHealthy, EventHookMode_Post);
    HookEvent("player_hurt", Event_Hurt, EventHookMode_Post);
}

public void OnClientPutInServer(int client) {
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action Event_ResetHealthy(Event event, const char[] name, bool dontBroadcast) {
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);

    g_Healthies[client] = false;
    return Plugin_Continue;
}

public Action Event_Hurt(Event event, const char[] name, bool dontBroadcast) {
    int userid = event.GetInt("userid");
    int client = GetClientOfUserId(userid);
    if (!g_Healthies[client]) return Plugin_Continue;

    int health = event.GetInt("health");
    int maxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");

    SetEntProp(client, Prop_Data, "m_iHealth", maxHealth);
    return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
    // PrintToServer("%N damages %N. It hurts! %f. Type: %d", attacker, victim, damage, damagetype);
    if (!g_Healthies[victim]) return Plugin_Continue;
    int health = GetEntProp(victim, Prop_Data, "m_iHealth");
    int predictionHealth = health - RoundFloat(damage);
    if (predictionHealth <= 0)
        damage = float(health - 1);
    // PrintToServer("[healthy] %N damages %N. It hurts! %f. Type: %d", attacker, victim, damage, damagetype);
    return Plugin_Changed;
}

public Action Command_Healthy(int client, int args)
{
    bool newState = true;
    char arg1[2];
    GetCmdArg(1, arg1, sizeof(arg1));

    if (args >= 1)
        newState = !StrEqual(arg1, "0", false);
    else
        newState = !g_Healthies[client];
        //newState = (GetEntProp(client, Prop_Data, "m_takedamage") - 1); // 2 = 1, 1 = 0


    PrintToServer("[SM] Healthy chose '%N's infinite health value to be %d.", client, newState);

    if (newState)
    {
        ReplyToCommand(client, "[SM] You are now in healthy mode!");
        g_Healthies[client] = true;
    }
    else
    {
        ReplyToCommand(client, "[SM] You are no longer in healthy mode!");
        g_Healthies[client] = false;
    }
    return Plugin_Handled;
}

public Action Command_AmIHealthy(int client, int args)
{
    ReplyToCommand(client, "%d", g_Healthies[client]);
    return Plugin_Handled;
}
