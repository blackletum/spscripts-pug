/*
  Pajama Man - bans players if their name matches a regex.

  no cvars.
*/

#include <sourcemod>
#include <sdktools>
#include <regex>

#pragma newdecls required

public Plugin myinfo = {
    name = "Pajama Man",
    author = "Pug",
    description = "bans players if their name matches a regex.",
    version = "1.0.0",
    url = "None"
}

ConVar g_cvBanPeople;

#define REGEXES 2
#define REGEX_PROPS 3
#define REGEX_LIST_SIZE (REGEXES*REGEX_PROPS)
char regexes[][] = {
    /* explanation: https://regex101.com/r/kiGfUm/1 */
    "pj.?(is)?.?(the)?.?(primal)?.?(pea)?.?shooter", "i", "nuh uh pj",
};

public int StringToRegexFlags(const char[] flags) {
    int ret = 0;
    for (int i = 0; i < strlen(flags); i++) {
        int as_int = 0;
        switch (flags[i]) {
            case 'i': {
                as_int = PCRE_CASELESS;
            }
            case 'm': {
                as_int = PCRE_MULTILINE;
            }
            case 'x': {
                as_int = PCRE_EXTENDED;
            }
            case 'A': {
                as_int = PCRE_ANCHORED;
            }
            case 'D': {
                as_int = PCRE_DOLLAR_ENDONLY;
            }
            case 'U': {
                as_int = PCRE_UNGREEDY;
            }
            case 'n': {
                as_int = PCRE_NOTEMPTY;
            }
            case 'u': {
                as_int = PCRE_UTF8;
            }
            case '!': {
                as_int = PCRE_NO_UTF8_CHECK;
            }
            case 'C': {
                as_int = PCRE_UCP;
            }
        }
        if (as_int != 0) {
            ret = ret | as_int;
        }
    }
    return ret;
}

public int TestName(const char[] name) {
    for (int reg = 0; reg < REGEX_LIST_SIZE; reg += REGEX_PROPS) {
        PrintToServer("testname|name:%s regid:%d reg:%s", name, reg, regexes[reg]);
        Regex rgx = new Regex(regexes[reg], StringToRegexFlags(regexes[reg + 1]))
        if (rgx.Match(name)) {
            PrintToServer("testname|name:%s regid:%d reg:%s MATCH", name, reg, regexes[reg]);
            return reg;
        }
    }
    return -1;
}


// true if can
// false if cant
public bool DoPrivilegeCheck(int client) {
    if (client == 0) return true;
    AdminId adminid = GetUserAdmin(client);
    if (adminid != INVALID_ADMIN_ID)
        if (adminid.HasFlag(Admin_Generic)) return true;

    return false;
}

public void OnPluginStart() {
    LoadTranslations("common.phrases");

    g_cvBanPeople = CreateConVar("sm_pj_ban_people",
        "0",
        "What to do when an illegal name is encountered. [0 = kick, 1 = ban]",
        FCVAR_NOTIFY);

    HookEvent("player_activate", OnJoin);
    RegAdminCmd("sm_pjtest", PJTest, ADMFLAG_GENERIC, "test a name");
}

public Action PJTest(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage: sm_pjtest <name>");
        return Plugin_Handled;
    }
    char name[MAX_NAME_LENGTH];
    GetCmdArgString(name, sizeof(name));

    int regexStoppedAt = TestName(name);
    if (regexStoppedAt == -1) {
        ReplyToCommand(client, "[SM] name is allowed.");
    } else {
        ReplyToCommand(client, "[SM] name is banned. reason: '%s'", regexes[regexStoppedAt + 2]);
    }

    return Plugin_Handled;
}

public Action OnJoin(Event event, const char[] eventName, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));
    if (DoPrivilegeCheck(client)) return Plugin_Continue;

    char name[MAX_NAME_LENGTH];
	bool getName = GetClientName(client, name, sizeof(name));
	if (!getName) {
	  PrintToServer("getting name for clientid %d failed.");
	  return Plugin_Continue;
	}
    int regexStoppedAt = TestName(name);
	PrintToServer("name:%s, clientid:%d, regexStoppedAt:%d", name, client, regexStoppedAt);
    if (regexStoppedAt != -1) {
        if (g_cvBanPeople.BoolValue) {
            char buffer[MAX_NAME_LENGTH];
            PrintToServer("%s\n", buffer);
            Format(buffer, sizeof(buffer), "\nYou have been banned by PajamaMan. Reason: '%s'.", regexes[regexStoppedAt + 2]);
            BanClient(client, 0, BANFLAG_AUTO, "PajamaMan_Ban", buffer, "", 0);
            PrintToChatAll("\x011[pajamaman] Banned %s for reason '%s'.", name, regexes[regexStoppedAt + 2])
        } else {
            KickClient(client, "\nYou have been kicked by PajamaMan. Reason '%s'.", regexes[regexStoppedAt + 2]);
            PrintToChatAll("\x011[pajamaman] Kicked %s for reason '%s'.", name, regexes[regexStoppedAt + 2])
        }
    }

    return Plugin_Handled;
}
