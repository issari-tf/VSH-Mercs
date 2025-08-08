#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <saxtonhale>
#include <sdktools>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2>
#include <tf2_stocks>
#include <tf_econ_data>
#include <dhooks>

#undef REQUIRE_EXTENSIONS
#tryinclude <tf2items>
#define REQUIRE_EXTENSIONS

#define PLUGIN_VERSION                "1.0.0"
#define PLUGIN_VERSION_REVISION       "manual"

#define MAX_ATTRIBUTES_SENT 			    20
#define ATTRIB_LESSHEALING				    734
#define ATTRIB_MELEE_RANGE_MULTIPLIER 264
#define ATTRIB_JUMP_HEIGHT            326

#define PARTICLE_GHOST                "ghost_appearation"

#define SOUND_ALERT                   "ui/system_message_alert.wav"
#define SOUND_BACKSTAB                "player/spy_shield_break.wav"
#define SOUND_NULL                    "vo/null.mp3"

const TFTeam TFTeam_Boss = TFTeam_Blue;
const TFTeam TFTeam_Attack = TFTeam_Red;

const TFObjectType TFObject_Invalid = view_as<TFObjectType>(-1);
const TFObjectMode TFObjectMode_Invalid = view_as<TFObjectMode>(-1);

enum
{
  WeaponSlot_Primary = 0,
  WeaponSlot_Secondary,
  WeaponSlot_Melee,
  WeaponSlot_PDABuild,
  WeaponSlot_PDADisguise = 3,
  WeaponSlot_PDADestroy,
  WeaponSlot_InvisWatch = 4,
  WeaponSlot_BuilderEngie,
  WeaponSlot_Unknown1,
  WeaponSlot_Head,
  WeaponSlot_Misc1,
  WeaponSlot_Action,
  WeaponSlot_Misc2
};

enum
{
  LifeState_Alive = 0,
  LifeState_Dead = 2
};

// TF ammo types - from tf_shareddefs.h
enum
{
  TF_AMMO_DUMMY = 0,
  TF_AMMO_PRIMARY,
  TF_AMMO_SECONDARY,
  TF_AMMO_METAL,
  TF_AMMO_GRENADES1,
  TF_AMMO_GRENADES2,
  TF_AMMO_GRENADES3,

  TF_AMMO_COUNT,
};

enum
{
  COLLISION_GROUP_NONE  = 0,
  COLLISION_GROUP_DEBRIS,             // Collides with nothing but world and static stuff
  COLLISION_GROUP_DEBRIS_TRIGGER,     // Same as debris, but hits triggers
  COLLISION_GROUP_INTERACTIVE_DEBRIS, // Collides with everything except other interactive debris or debris
  COLLISION_GROUP_INTERACTIVE,        // Collides with everything except interactive debris or debris
  COLLISION_GROUP_PLAYER,
  COLLISION_GROUP_BREAKABLE_GLASS,
  COLLISION_GROUP_VEHICLE,
  COLLISION_GROUP_PLAYER_MOVEMENT,    // For HL2, same as Collision_Group_Player, for
                                      // TF2, this filters out other players and CBaseObjects
  COLLISION_GROUP_NPC,			          // Generic NPC group
  COLLISION_GROUP_IN_VEHICLE,		      // for any entity inside a vehicle
  COLLISION_GROUP_WEAPON,			        // for any weapons that need collision detection
  COLLISION_GROUP_VEHICLE_CLIP,	      // vehicle clip brush to restrict vehicle movement
  COLLISION_GROUP_PROJECTILE,		      // Projectiles!
  COLLISION_GROUP_DOOR_BLOCKER,	      // Blocks entities not permitted to get near moving doors
  COLLISION_GROUP_PASSABLE_DOOR,	    // Doors that the player shouldn't collide with
  COLLISION_GROUP_DISSOLVING,		      // Things that are dissolving are in this group
  COLLISION_GROUP_PUSHAWAY,		        // Nonsolid on client and server, pushaway in player code

  COLLISION_GROUP_NPC_ACTOR,		      // Used so NPCs in scripts ignore the player.
  COLLISION_GROUP_NPC_SCRIPTED,	      // USed for NPCs in scripts that should not collide with each other

  LAST_SHARED_COLLISION_GROUP
};

// entity effects
enum
{
  EF_BONEMERGE          = (1<<0),	// Performs bone merge on client side
  EF_BRIGHTLIGHT        = (1<<1),	// DLIGHT centered at entity origin
  EF_DIMLIGHT           = (1<<2),	// player flashlight
  EF_NOINTERP           = (1<<3),	// don't interpolate the next frame
  EF_NOSHADOW           = (1<<4),	// Don't cast no shadow
  EF_NODRAW             = (1<<5),	// don't draw entity
  EF_NORECEIVESHADOW		= (1<<6),	// Don't receive no shadow
  EF_BONEMERGE_FASTCULL	= (1<<7),	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
                                  // parent and uses the parent's bbox + the max extents of the aiment.
                                  // Otherwise, it sets up the parent's bones every frame to figure out where to place
                                  // the aiment, which is inefficient because it'll setup the parent's bones even if
                                  // the parent is not in the PVS.
  EF_ITEM_BLINK         = (1<<8), // blink an item so that the user notices it.
  EF_PARENT_ANIMATES		= (1<<9),	// always assume that the parent entity is animating
};

// Settings for m_takedamage - from shareddefs.h
enum
{
  DAMAGE_NO = 0,
  DAMAGE_EVENTS_ONLY, // Call damage functions, but don't modify health
  DAMAGE_YES,
  DAMAGE_AIM,
};

enum
{
	DONT_BLEED = -1,
	
	BLOOD_COLOR_RED = 0,
	BLOOD_COLOR_YELLOW,
	BLOOD_COLOR_GREEN,
	BLOOD_COLOR_MECH,
};

#include "vsh_mercs/bosses/boss_orangeman.sp"
#include "vsh_mercs/stocks.sp"

public Plugin myinfo =
{
  name               = "VSH Mercs",
  author             = "Aidan Sanders, Koto",
  description        = "VSH Addon to add Player Bosses",
  version            = PLUGIN_VERSION ... "." ... PLUGIN_VERSION_REVISION,
  url                = "",
};

bool g_bEnabled = false;
int g_iTotalRoundPlayed = 0;

public void OnPluginStart()
{
  // Call on RoundStart to randomly get a player.
  HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_Post);
  HookEvent("teamplay_round_win",   Event_RoundEnd);
}

public void OnMapStart()
{
  g_iTotalRoundPlayed = 0;
}

public void OnLibraryAdded(const char[] name)
{
  if (StrEqual(name, "saxtonhale"))
  {
    // Register our Boss
    g_bEnabled = true;
    SaxtonHale_RegisterClass("Orangeman", VSHClassType_Boss);
  }
}

public void OnLibraryRemoved(const char[] name)
{
  if (StrEqual(name, "saxtonhale"))
  {
    g_bEnabled = false;
  }
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
  if (!g_bEnabled || GameRules_GetProp("m_bInWaitingForPlayers"))
    return Plugin_Handled;

   // Play one round of arena
  if (g_iTotalRoundPlayed <= 0)
    return Plugin_Handled;

  int[] iPlayers = new int[MaxClients];
  int iPlayerCount = 0;

  for (int i = 1; i <= MaxClients; i++)
  {
    SaxtonHaleBase boss = SaxtonHaleBase(i);
    // if not valid, if is boss, if is bot
    if (!IsValidClient(i) && boss.bValid && IsFakeClient(i))
      continue;

    iPlayers[iPlayerCount++] = i;
  }

  if (iPlayerCount == 0)
    return Plugin_Handled; // No valid players found

  // issue here
  int iRandomIndex = GetRandomInt(0, iPlayerCount - 1);
  int iClient = iPlayers[iRandomIndex];

  // Do something with iClient
  PrintToChatAll("Random client selected: %N", iClient);

  SaxtonHaleBase boss = SaxtonHaleBase(iClient);
  if (boss.bValid) {
    return Plugin_Handled;
  }
  boss.CreateClass("Orangeman");
  TF2_RespawnPlayer(boss.iClient); // Might not be needed
  return Plugin_Handled;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
  if (!g_bEnabled)
    return;

  g_iTotalRoundPlayed++;
}

stock bool IsValidClient(const int iClient, bool bReplayCheck=true)
{
  if (iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
    return false;
  else if (GetEntProp(iClient, Prop_Send, "m_bIsCoaching"))
    return false;
  else if (bReplayCheck && (IsClientSourceTV(iClient) || IsClientReplay(iClient)))
    return false;
  else if (TF2_GetPlayerClass(iClient) == TFClass_Unknown)
    return false;
  return true;
}