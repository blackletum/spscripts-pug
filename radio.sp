/*
    Radio - play songs lol

    sm_radio <song file>             - play a song
    sm_stopradio                     - stop the currently playing song.
    sm_radiofix                      - fix the song if you alt tab out and it stops.
*/

#include <sourcemod>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define RADIO_CFG "addons/sourcemod/configs/radio.cfg" // where the config is located
#define RADIO_DISPLAYLENGTH 256 // the max length of a display name

public Plugin myinfo = {
    name = "Radio",
    author = "Pug",
    description = "play songs lol",
    version = "1.0.0",
    url = "None"
};

enum RadioResult {
    Radio_Success = 0,
    Radio_FileNotFound = 1,
    Radio_NotPlaying = 2,
    Radio_InvalidHandle = 3
};

bool g_IsPlaying = false;
char g_CurrentMusic[PLATFORM_MAX_PATH];
//Handle g_MusicTimer;
//float g_MusicStart;

public void OnPluginStart() {
    LoadTranslations("common.phrases");

    RegAdminCmd("sm_radio", Command_Radio, ADMFLAG_GENERIC, "sm_radio <music> - play a song");
    RegAdminCmd("sm_stopradio", Command_StopRadio, ADMFLAG_GENERIC, "sm_stopradio - stop the currently playing song.");
    RegConsoleCmd("sm_radiofix", Command_RadioFix, "sm_radiofix - fix the song if it stops.");
}

float GetSongLength(const char[] filename)
{
    KeyValues kv = new KeyValues("Radio");
    kv.ImportFromFile(RADIO_CFG);

    if (!kv.JumpToKey(filename))
    {
        delete kv;
        return -1.0;
    }

    float length = kv.GetFloat("length", -1.0);
    delete kv;

    return length;
}

bool GetSongDisplayName(const char[] filename, char[] name)
{
    KeyValues kv = new KeyValues("Radio");
    kv.ImportFromFile(RADIO_CFG);

    if (!kv.JumpToKey(filename))
    {
        delete kv;
        return false;
    }

    kv.GetString("displayname", name, RADIO_DISPLAYLENGTH);
    delete kv;

    return true;
}

RadioResult Radio_Play(const char MusicName[PLATFORM_MAX_PATH]) {
    char AbsPath[PLATFORM_MAX_PATH];
    Format(AbsPath, sizeof(AbsPath), "sound/music/%s.wav", MusicName);

    if (!FileExists(AbsPath, true)) {
        return Radio_FileNotFound;
    }

    char SoundPath[PLATFORM_MAX_PATH];
    Format(SoundPath, sizeof(SoundPath), "music/%s.wav", MusicName);

    Radio_Stop();
    PrecacheScriptSound(SoundPath);
    EmitSoundToAll(SoundPath);
    g_CurrentMusic = MusicName;
    g_IsPlaying = true;

    return Radio_Success;
}

RadioResult Radio_Stop() {
    if (!g_IsPlaying) {
        return Radio_NotPlaying;
    }

    char SoundPath[PLATFORM_MAX_PATH];
    Format(SoundPath, sizeof(SoundPath), "music/%s.wav", g_CurrentMusic);

    for (int client = 1; client <= MaxClients; client++) {
        StopSound(client, SNDCHAN_AUTO, SoundPath);
    }

    g_IsPlaying = false;
    return Radio_Success;
}

RadioResult Radio_Fix(int client) {
    if (!g_IsPlaying) {
        return Radio_NotPlaying;
    }

    char AbsPath[PLATFORM_MAX_PATH];
    Format(AbsPath, sizeof(AbsPath), "sound/music/%s.wav", g_CurrentMusic);

    if (!FileExists(AbsPath, true)) {
        return Radio_FileNotFound;
    }

    char SoundPath[PLATFORM_MAX_PATH];
    Format(SoundPath, sizeof(SoundPath), "music/%s.wav", g_CurrentMusic);

    StopSound(client, SNDCHAN_AUTO, g_CurrentMusic);

    EmitSoundToClient(
        client,
        SoundPath,
        SOUND_FROM_PLAYER, // entity
        SNDCHAN_AUTO, // channel
        SNDLEVEL_NORMAL, // level
        SND_NOFLAGS, // flags
        SNDVOL_NORMAL, // volume
        SNDPITCH_NORMAL, // pitch
        -1, // speakerentity
        NULL_VECTOR, // origin
        NULL_VECTOR, // dir
        true, // updatePos
        // GetMusicTime() // soundtime
        0.0 // soundtime
    );

    return Radio_Success;
}

public Action Command_Radio(int client, int argc) {
    if (argc < 1) {
        ReplyToCommand(
            client,
            "[SM] Usage - sm_radio <song name>\n     The song should be located under sound/music/."
        );
        return Plugin_Handled;
    }
    char MusicName[PLATFORM_MAX_PATH];
    GetCmdArgString(MusicName, sizeof(MusicName));

    RadioResult result = Radio_Play(MusicName);

    switch (result) {
        case Radio_Success: {
            char DisplayName[RADIO_DISPLAYLENGTH];
            bool hasDisplayName = GetSongDisplayName(MusicName, DisplayName);

            if (hasDisplayName) {
                PrintCenterTextAll("Now Playing: %s", DisplayName);
            } else {
                PrintCenterTextAll("Now Playing: %s", MusicName);
            }
        }
        case Radio_FileNotFound: {
            ReplyToCommand(client, "[SM] File not found: '%s'", MusicName);
        }
    }

    return Plugin_Handled;
}

public Action Command_StopRadio(int client, int argc) {
    RadioResult result = Radio_Stop();

    switch (result) {
        case Radio_Success: {
            PrintCenterTextAll("Radio stopped.");
        }
        case Radio_NotPlaying: {
            ReplyToCommand(client, "[SM] The radio isn't playing anything!");
        }
    }
    return Plugin_Handled;
}

public Action Command_RadioFix(int client, int argc) {
    RadioResult result = Radio_Fix(client);

    switch (result) {
        case Radio_Success: {
            ReplyToCommand(client, "[SM] Radio fixed.");
        }
        case Radio_FileNotFound: {
            ReplyToCommand(client, "[SM] File not found.");
        }
        case Radio_NotPlaying: {
            ReplyToCommand(client, "[SM] The radio isn't playing anything!");
        }
        case Radio_InvalidHandle: {
            ReplyToCommand(client, "[SM] Invalid handle encountered while trying to restore radio.");
        }
    }
    return Plugin_Handled;
}
