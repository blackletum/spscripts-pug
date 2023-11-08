#if defined _pug_included
        #endinput
#endif
#define _pug_included

// based on micai's pf2mouse.inc

#define CLASS_UNKNOWN 0
#define CLASS_SCOUT 1
#define CLASS_SNIPER 2
#define CLASS_SOLDIER 3
#define CLASS_DEMOMAN 4
#define CLASS_MEDIC 5
#define CLASS_HEAVY 6
#define CLASS_PYRO 7
#define CLASS_SPY 8
#define CLASS_ENGINEER 9
#define CLASS_CIVILIAN 10

#define TEAM_UNASSIGNED 0
#define TEAM_SPECTATOR 1
#define TEAM_RED 2
#define TEAM_BLU 3
#define TEAM_BLUE 3

#define AMMO_PRIMARY 1
#define AMMO_SECONDARY 2
#define AMMO_TERTIARY 2
#define AMMO_METAL 3
#define AMMO_GRENADE1 4
#define AMMO_GRENADE2 5

#define COND_AIMING 0
#define COND_ZOOMED 1
#define COND_DISGUISING 2
#define COND_DISGUISED 3
#define COND_STEALTHED 4 // cloak
#define COND_INVULNERABLE 5
#define COND_TELEPORTED 6
#define COND_TAUNTING 7
#define COND_INVULNERABLE_WEARINGOFF 8
#define COND_STEALTHED_BLINK 9
#define COND_SELECTED_TO_TELEPORT 10
#define COND_CRITBOOSTED 11
#define COND_TMPDAMAGEBONUS 12 // seems to be same as 11; no fucking clue what happens between this and cond19, i recommend just using the numbers instead for now
#define COND_FEIGN_DEATH 13 // just gives crits
#define COND_PHASE 14 // bonk effect in normal game, in this its a weird version of cloak - you dont shimmer and uncloak automatically if you try to attack
#define COND_15 // unknown
#define COND_16 // cant move or reload, can shoot and taunt, similar to round start
#define COND_17 // unknown
#define COND_18 // unknown
#define COND_BURNING 19 // same as 22 in normal tf2? removing it removes afterburn, giving it to players makes them scream "FIRE" but they aren't actually set on fire
// things below are pf2 debuffs and conditions. i have no idea how the pf2 conds are actually called internally so i just made shit up
#define COND_TRANQUILISED 20 // tranq effect
#define COND_CONCUSSION 21 // particles stay on after the effect ends and have to be removed manually
#define COND_BEARTRAP 22
#define COND_DISEASE 23
#define COND_24 24 // idk
#define COND_GASSED 25 // spy gas grenade effect
#define COND_LEGSHOT 26 // slows you down, maybe from being shot in the legs, can't care to double check for now, addcond doesn't work anyway lol

#define PUG_WEAPONCLASS_MAX 32
#define PUG_WEAPON_NUM_PRIMARY 12
#define PUG_WEAPON_NUM_SECONDARY 9
#define PUG_WEAPON_NUM_MELEE 10
#define PUG_WEAPON_NUM_PDA1 2
#define PUG_WEAPON_NUM_TOTAL (PUG_WEAPON_NUM_PRIMARY + PUG_WEAPON_NUM_SECONDARY + PUG_WEAPON_NUM_MELEE + PUG_WEAPON_NUM_PDA1)

stock const char _inc_pug_primary[PUG_WEAPON_NUM_PRIMARY][PUG_WEAPONCLASS_MAX] = {
        "tf_weapon_nailgun",
        "tf_weapon_smg_scout",
        "tf_weapon_rocketlauncher",
        "tf_weapon_flamethrower",
        "tf_weapon_grenadelauncher",
        "tf_weapon_minigun",
        "tf_weapon_shotgun_primary",
        "tf_weapon_syringegun_medic",
        "tf_weapon_smg_medic",
        "tf_weapon_sniperrifle",
        "tf_weapon_pistol_spy",
        "tf_weapon_revolver",
};
stock const char _inc_pug_secondary[PUG_WEAPON_NUM_SECONDARY][PUG_WEAPONCLASS_MAX] = {
        "tf_weapon_pistol",
        "tf_weapon_tranq",
        "tf_weapon_shotgun_soldier",
        "tf_weapon_shotgun_pyro",
        "tf_weapon_shotgun_scout",
        "tf_weapon_shotgun_hwg",
        "tf_weapon_pipebomblauncher",
        "tf_weapon_smg",
        "tf_weapon_medigun",
};
stock const char _inc_pug_melee[PUG_WEAPON_NUM_MELEE][PUG_WEAPONCLASS_MAX] = {
        "tf_weapon_bat",
        "tf_weapon_shovel",
        "tf_weapon_brandingiron",
        "tf_weapon_bottle",
        "tf_weapon_pipe",
        "tf_weapon_wrench",
        "tf_weapon_syringe",
        "tf_weapon_club",
        "tf_weapon_knife",
        "tf_weapon_umbrella",
};
stock const char _inc_pug_pda1[PUG_WEAPON_NUM_PDA1][PUG_WEAPONCLASS_MAX] = {
        "tf_weapon_pda_engineer_build",
        "tf_weapon_pda_spy",
};

// PLAYER CLASS
stock int GetPlayerClass(int client) {
        return GetEntProp(client, Prop_Send, "m_iClass");
}

stock void SetPlayerClass(int client, int class, bool desired = true) {
        SetEntProp(client, Prop_Send, "m_iClass", class);
        if (desired) SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", class);
}

stock void SetPlayerDesiredClass(int client, int class) {
        SetEntProp(client, Prop_Send, "m_iDesiredPlayerClass", class);
}

stock void GetClassName(int class, char[] buffer, int maxlength) {
        char classname[16] = "Unknown";
        switch(class) {
                case CLASS_UNKNOWN: { classname = "Unknown"; }
                case CLASS_SCOUT: { classname = "Scout"; }
                case CLASS_SOLDIER: { classname = "Soldier"; }
                case CLASS_PYRO: { classname = "Pyro"; }
                case CLASS_DEMOMAN: { classname = "Demoman"; }
                case CLASS_HEAVY: { classname = "Heavy"; }
                case CLASS_ENGINEER: { classname = "Engineer"; }
                case CLASS_MEDIC: { classname = "Medic"; }
                case CLASS_SNIPER: { classname = "Sniper"; }
                case CLASS_SPY: { classname = "Spy"; }
                case CLASS_CIVILIAN: { classname = "Civilian"; }
                default: { Format(classname, 16, "Invalid%d", class); }
        }
        StrCopy(buffer, maxlength, classname);
}



// HEALTH
stock void AddPlayerHealth(int client, int health, int clamp = 0) {
        int hp = GetPlayerHealth(client);
        hp = hp + health;
        if(clamp > 0) {
                if (hp > clamp) hp = clamp;
        }
        SetEntProp(client, Prop_Send, "m_iHealth", hp);
}

stock int GetPlayerHealth(int client) {
        return GetEntProp(client, Prop_Send, "m_iHealth");
}

stock void SetPlayerHealth(int client, int health) {
        SetEntProp(client, Prop_Send, "m_iHealth", health);
}

stock int GetPlayerMaxHealth(int client) {
        return GetEntProp(client, Prop_Data, "m_iMaxHealth");
}

stock void SetPlayerMaxHealth(int client, int health) {
        SetEntProp(client, Prop_Data, "m_iMaxHealth", health);
}

stock void AddPlayerMaxHealth(int client, int health, int clamp = 0) {
        int hp = GetPlayerMaxHealth(client);
        hp = hp + health;
        if(clamp > 0) {
                if (hp > clamp) hp = clamp;
        }
        SetEntProp(client, Prop_Data, "m_iMaxHealth", hp);
}

// ARMOR
stock void AddPlayerArmor(int client, int armor, int clamp = 0) {
        int ap = GetPlayerArmor(client);
        ap = ap + armor;
        if(clamp > 0) {
                if (ap > clamp) ap = clamp;
        }
        SetEntProp(client, Prop_Send, "m_ArmorValue", ap);
}

stock int GetPlayerArmor(int client) {
        return GetEntProp(client, Prop_Send, "m_ArmorValue");
}

stock void SetPlayerArmor(int client, int armor) {
        SetEntProp(client, Prop_Send, "m_ArmorValue", armor);
}

stock int GetPlayerMaxArmor(int client, int armor) {
        return GetEntProp(client, Prop_Data, "m_ArmorValue");
}

stock void SetPlayerMaxArmor(int client, int armor) {
        SetEntProp(client, Prop_Data, "m_ArmorValue", armor);
}



// AMMO
stock int GetPlayerAmmo(int client, int type) {
        return GetEntProp(client, Prop_Send, "m_iAmmo", _, type);
}

stock void SetPlayerAmmo(int client, int type, int ammo) {
        SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, type);
}

stock void AddPlayerAmmo(int client, int type, int ammo, int clamp = 0) {
        int am = GetPlayerAmmo(client, type);
        am = am + ammo;
        if(clamp > 0) {
                if (am > clamp) am = clamp;
        }
        SetEntProp(client, Prop_Send, "m_iAmmo", am, _, type);
}


// CLOAK
stock float GetPlayerCloak(int client) {
        return GetEntPropFloat(client, Prop_Send, "m_flCloakMeter");
}

stock void SetPlayerCloak(int client, float cloak) {
        SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
}

stock float AddPlayerCloak(int client, float cloak, float min = 0.0, float max = 100.0) {
        float cl = GetPlayerCloak(client);
        cl = cl + cloak;
        if (cl > max) cl = max;
        if (cl < min) cl = min;
        SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cl);
        return cl;
}

// WEAPON MANAGEMENT

stock int GivePlayerWeapon(int client, char[] weapon, bool equip = false) {
        int wep = GivePlayerItem(client, weapon);
        if (wep != -1) {
                EquipPlayerWeapon(client, wep);
                if (equip)FakeClientCommand(client, "use %s", weapon);
        }
        return wep;
}

stock void RemoveWeaponSlot(int client, int slot) {
        int gunent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", slot);
        if (!IsValidEntity(gunent)) return;
        if(IsValidEntity(gunent)) {
                RemoveEntity(gunent);
                RemoveEdict(gunent);
        }
        SetEntProp(client, Prop_Send, "m_hMyWeapons", -1, _, slot); // might be unnecessary
}

stock int ReplaceWeaponSlot(int client, int slot, char[] item) {
        RemoveWeaponSlot(client, slot);
        return GivePlayerWeapon(client, item);
}

stock int GetPlayerWeaponByName(int client, char[] name, int limit=47) {
        char gunname[64];
        if (limit > 47) limit = 47;

        int wep = -1;

        for (int i = 0; i <= limit; i++) {
                int gunent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
                if (!IsValidEntity(gunent)) continue;
                GetEntityClassname(gunent, gunname, 64);
                if(StrEqual(gunname, name)) {
                        wep = gunent;
                        break;
                }
        }

        return wep;
}

stock void RemoveWeaponName(int client, char[] name, int limit=10) {
        int gunent = GetPlayerWeaponByName(client, name, limit);
        if(IsValidEntity(gunent)) {
                RemoveEntity(gunent);
                RemoveEdict(gunent);
        }
}

stock void RemovePlayerPrimaryWeapons(int client, int type) {
        char gunname[64];
        if (limit > 47) limit = 47;

        int wep = -1;
        int arraysize = sizeof(_inc_pug_primary);

        for (int i = 0; i <= limit; i++) {
                int gunent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);

                if (!IsValidEntity(gunent)) continue;
                GetEntityClassname(gunent, gunname, 64);

                for (int j = 0; j < arraysize; j++) {
                        if(StrEqual(gunname, _inc_pug_primary[j])) {
                                RemoveEntity(i);
                                RemoveEdict(i);
                        }
                }
        }

        return wep;
}

// UBERCHARGE
stock float GetPlayerUbercharge(int client, int limit=47) {
        int medigun = GetPlayerWeaponByName(client, "tf_weapon_medigun", limit);
        if (medigun == -1) return 0.0;
        return GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
}

stock void SetPlayerUbercharge(int client, float charge, int limit=47) {
        int medigun = GetPlayerWeaponByName(client, "tf_weapon_medigun", limit);
        if (medigun == -1) return;
        SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", charge);
}

stock void AddPlayerUbercharge(int client, float charge, float min = 0.0, float max = 1.0, int limit = 47) {
        int medigun = GetPlayerWeaponByName(client, "tf_weapon_medigun", limit);
        if (medigun == -1) return;

        float cl = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
        cl = cl + charge;
        if (cl > max) cl = max;
        if (cl < min) cl = min;
        SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", cl);
}


// PIPEBOMB COUNT
stock int GetPlayerPipebombs(int client, int limit=47) {
        int gun = GetPlayerWeaponByName(client, "tf_weapon_pipebomblauncher", limit);
        if (gun == -1) return 0;
        return GetEntProp(gun, Prop_Send, "m_iPipebombCount");
}

stock void SetPlayerPipebombs(int client, int pbs, int limit=47) {
        int gun = GetPlayerWeaponByName(client, "tf_weapon_pipebomblauncher", limit);
        if (gun == -1) return;
        SetEntProp(gun, Prop_Send, "m_iPipebombCount", pbs);
}

stock void AddPlayerPipebombs(int client, float pbs, int min = 0, int max = 9999, int limit = 47) {
        int gun = GetPlayerWeaponByName(client, "tf_weapon_pipebomblauncher", limit);
        if (gun == -1) return;

        float cl = GetEntProp(medigun, Prop_Send, "m_iPipebombCount");
        cl = cl + pbs;
        if (cl > max) cl = max;
        if (cl < min) cl = min;
        SetEntProp(gun, Prop_Send, "m_iPipebombCount", cl);
}


// MISC PROPERTIES

stock float GetPlayerMaxSpeed(int client) {
        return GetEntPropFloat(client, Prop_Send, "m_flMaxspeed");
}

stock void SetPlayerMaxSpeed(int client, float speed) {
        SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", speed);
}

stock void AddPlayerMaxSpeed(int client, float speed, float clamp = 0.0) {
        float spd = GetPlayerMaxSpeed(client);
        spd = spd + speed;
        if(clamp > 0.0) {
                if (spd > clamp) spd = clamp;
        }
        SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", spd);
}

stock void SetClientTeam(int client, int team) {
        SetVariantInt(team);
        AcceptEntityInput(client, "SetTeam");
        //ClientCommand(client, "jointeam %d", team);
}

// THIRDPERSON (VIA TAUNTCAM)

// use this for thirdperson camera
stock void SetTauntCam(int client, int value) {
        SetEntProp(client, Prop_Send, "m_nForceTauntCam", value);
}

stock int GetTauntCam(int client) {
        return GetEntProp(client, Prop_Send, "m_nForceTauntCam");
}

// HACKY ZONE

// HACK: manipulates sv_cheats during execution
stock void AddCondition(int client, int condition) {
        int fc[2];
        FakeCheats_Start(fc);

        if (IsFakeClient(client)) ServerCommand("bot_command \"%N\" \"addcond %d\"", client, condition);
        FakeClientCommand(client, "addcond %d", condition);

        FakeCheats_End(fc);
}

// HACK: manipulates sv_cheats during execution
stock void RemoveCondition(int client, int condition) {
        int fc[2];
        FakeCheats_Start(fc);

        if (IsFakeClient(client)) ServerCommand("bot_command \"%N\" \"removecond %d\"", client, condition);
        FakeClientCommand(client, "removecond %d", condition);

        FakeCheats_End(fc);
}

stock bool IsPlayerInCondition(int client, int condition) {
        int bit = 1 << condition;
        if ((GetEntProp(client, Prop_Send, "m_nPlayerCond") & bit) == bit) return true;
        return false;
}

// HACK: disguise
stock void DisguisePlayerAs(int client, int target) {
        int targetclass = GetPlayerClass(target);
        int targetteam = GetClientTeam(target);
        int targethealth = GetPlayerHealth(target);
        int targetarmor = GetPlayerArmor(target);

        SetEntProp(client, Prop_Send, "m_nDisguiseClass", targetclass);
        SetEntProp(client, Prop_Send, "m_nDesiredDisguiseClass", targetclass);
        SetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex", target);
        SetEntProp(client, Prop_Send, "m_nDisguiseTeam", targetteam);
        SetEntProp(client, Prop_Send, "m_nDesiredDisguiseTeam", targetteam);
        SetEntProp(client, Prop_Send, "m_iDisguiseHealth", targethealth);
        SetEntProp(client, Prop_Send, "m_iDisguiseArmor", targetarmor);

        AddCondition(client, COND_DISGUISED);
}

stock void DisguisePlayer(int client, int target, int class, int team, int health, int armor, bool addcond = true) {

        SetEntProp(client, Prop_Send, "m_nDisguiseClass", class);
        SetEntProp(client, Prop_Send, "m_nDesiredDisguiseClass", class);
        SetEntProp(client, Prop_Send, "m_iDisguiseTargetIndex", target);
        SetEntProp(client, Prop_Send, "m_nDisguiseTeam", team);
        SetEntProp(client, Prop_Send, "m_nDesiredDisguiseTeam", team);
        SetEntProp(client, Prop_Send, "m_iDisguiseHealth", health);
        SetEntProp(client, Prop_Send, "m_iDisguiseArmor", armor);

        if(addcond) AddCondition(client, COND_DISGUISED);
}


// HACK FAKECHEATS
stock int FakeCheats_Start(int[] data) {
        Handle cheatcvar = FindConVar("sv_cheats");
        int flags = GetConVarFlags(cheatcvar);
        int newflags = flags;

        int defaultstate = GetConVarInt(cheatcvar);

        if (defaultstate == 0) {
                newflags = flags & ~FCVAR_NOTIFY;
                newflags = newflags & ~FCVAR_REPLICATED;
                SetConVarFlags(cheatcvar, newflags);
                SetConVarBool(cheatcvar, true, false, false);
        }

        data[0] = flags;
        data[1] = defaultstate;
}

stock void FakeCheats_End(int[] data) {
        Handle cheatcvar = FindConVar("sv_cheats");
        int flags = data[0];
        int defaultstate = data[1];

        if (defaultstate == 0) SetConVarBool(cheatcvar, false, false, false);
        SetConVarFlags(cheatcvar, flags);
}
