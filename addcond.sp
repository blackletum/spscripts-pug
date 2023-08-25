/* 
  Addcond - quickly add, remove, and toggle conditions from the target(s).

  this plugin was modified from https://forums.alliedmods.net/showthread.php?t=200410
  depending on the game, you might want to include <tf2> and <tf2_stocks> instead of <pf2>, as this was made for pf2.
  for tf2classic, you would replace it with <tf2classic>.

  i might translate this to new syntax.

  sm_addcond <target> <condition> [duration] - adds a condition to the target. if duration is not specified, assume infinite (-1).
  sm_rmcond <target> <condition>             - remove a condition from the target.
  sm_togglecond <target> <condition>         - toggle a condition on the target.
*/

#include <pf2>

public Plugin:myinfo =
{
    name = "PF2 Add Condition",
    author = "Pug",
    description = "Add a condition to the target(s)",
    version = "1.0.0",
    url = "None"
}

public OnPluginStart()
{
    LoadTranslations("common.phrases");
    RegAdminCmd("sm_addcond", Command_AddCondition, ADMFLAG_GENERIC, "Add a condition to the target(s), Usage: sm_addcond \"target\" \"condition number\" \"duration\"");
    RegAdminCmd("sm_rmcond", Command_RemoveCondition, ADMFLAG_GENERIC, "Add a condition to the target(s), Usage: sm_rmcond \"target\" \"condition number\"");
    RegAdminCmd("sm_togglecond", Command_ToggleCondition, ADMFLAG_GENERIC, "Toggle a condition on the target(s), Usage: sm_togglecond \"target\" \"condition number\"");
}

public Action:Command_AddCondition(client, args)
{
    if(args < 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_addcond \"target\" \"condition number\" \"duration\"");
        return Plugin_Handled;
    }

    new String:strBuffer[MAX_NAME_LENGTH], String:target_name[MAX_TARGET_LENGTH], target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
    GetCmdArg(1, strBuffer, sizeof(strBuffer));
    if ((target_count = ProcessTargetString(strBuffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    new iCondition, Float:flDuration;

    GetCmdArg(2, strBuffer, sizeof(strBuffer));
    iCondition = StringToInt(strBuffer);

    flDuration = -1.0;
    if(args == 3)
    {
        GetCmdArg(3, strBuffer, sizeof(strBuffer));
        flDuration = StringToFloat(strBuffer);
    }

    for(new i = 0; i < target_count; i++)
    {
        TF2_AddCondition(target_list[i], TFCond:iCondition, flDuration);
    }
    return Plugin_Handled;
}

public Action:Command_RemoveCondition(client, args)
{

    if(args != 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_rmcond \"target\" \"condition number\"");
        return Plugin_Handled;
    }

    new String:strBuffer[MAX_NAME_LENGTH], String:target_name[MAX_TARGET_LENGTH], target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
    GetCmdArg(1, strBuffer, sizeof(strBuffer));
    if ((target_count = ProcessTargetString(strBuffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    new iCondition;

    GetCmdArg(2, strBuffer, sizeof(strBuffer));
    iCondition = StringToInt(strBuffer);

    for(new i = 0; i < target_count; i++)
    {
        TF2_RemoveCondition(target_list[i], TFCond:iCondition);
    }
    return Plugin_Handled;
}


public Action:Command_ToggleCondition(client, args)
{

    if(args != 2)
    {
        ReplyToCommand(client, "[SM] Usage: sm_togglecond \"target\" \"condition number\"");
        return Plugin_Handled;
    }

    new String:strBuffer[MAX_NAME_LENGTH], String:target_name[MAX_TARGET_LENGTH], target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
    GetCmdArg(1, strBuffer, sizeof(strBuffer));
    if ((target_count = ProcessTargetString(strBuffer, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
    {
        ReplyToTargetError(client, target_count);
        return Plugin_Handled;
    }

    new iCondition;

    GetCmdArg(2, strBuffer, sizeof(strBuffer));
    iCondition = StringToInt(strBuffer);

    for(new i = 0; i < target_count; i++)
    {
        if(TF2_IsPlayerInCondition(target_list[i], TFCond:iCondition))
        {
            TF2_RemoveCondition(target_list[i], TFCond:iCondition);
        } else {
            TF2_AddCondition(target_list[i], TFCond:iCondition, TFCondDuration_Infinite);
        }
    }
    return Plugin_Handled;
}
