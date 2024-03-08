/*
   Radio - play songs lol

   sm_radio <song file>             - play a song
   sm_radiofix                      - fix the song if you alt tab out and it stops.
   sm_stop                          - stop the currently playing song.
   */

#include <sourcemod>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = {
    name = "Radio",
    author = "Pug",
    description = "play songs lol",
    version = "1.0.0",
    url = "None"
};

char g_PlayingMusic[PLATFORM_MAX_PATH];

public void OnPluginStart() {
    LoadTranslations("common.phrases");

    RegAdminCmd("sm_radio", Command_Radio, ADMFLAG_GENERIC, "sm_radio <music> - play a song");
    RegConsoleCmd("sm_radiofix", Command_RadioFix, "sm_radiofix - fix the song if you alt tab and it stops.");
    RegAdminCmd("sm_stop", Command_StopRadio, ADMFLAG_GENERIC, "sm_stop - stop the currently playing song.");
}

public Action Command_Radio(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(client, "[SM] Usage - sm_radio <song file>");
        return Plugin_Handled;
    }
    char SoundPath[PLATFORM_MAX_PATH];
    GetCmdArgString(SoundPath, sizeof(SoundPath));

    for (int user = 1; user <= MaxClients; user++) {
        if (!IsClientInGame(user)) continue;
        g_PlayingMusic = SoundPath;
        ClientCommand(user, "stopsound");
    }
    ServerCommand("sm_play @all \"music/%s.wav\"", SoundPath);

    PrintCenterTextAll("Now playing: %s", SoundPath);
    return Plugin_Handled;
}

public Action Command_RadioFix(int client, int argc) {
    ServerCommand("sm_play #%d \"music/%s.wav\"", client, g_PlayingMusic);
    return Plugin_Handled;
}

public Action Command_StopRadio(int client, int argc) {
    for (int user = 1; user <= MaxClients; user++) {
        if (!IsClientInGame(user)) continue;
        ClientCommand(user, "stopsound");
        g_PlayingMusic = "";
    }
    return Plugin_Handled;
}
