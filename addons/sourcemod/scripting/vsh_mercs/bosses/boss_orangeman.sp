#define ORANGEMAN_MODEL "models/hunters/oemo/demo.mdl"

#define SHIELD_MODEL "models/props_mvm/mvm_player_shield.mdl"
#define SHIELD_SOUND "weapons/medi_shield_deploy.wav"

static char g_strOrangemanRoundStart[][] = {
  "vo/demoman_gibberish03.mp3",
  "vo/demoman_gibberish11.mp3"
};

static char g_strOrangemanWin[][] = {
  "vo/demoman_gibberish01.mp3",
  "vo/demoman_gibberish12.mp3",
  "vo/demoman_cheers02.mp3",
  "vo/demoman_cheers03.mp3",
  "vo/demoman_cheers06.mp3",
  "vo/demoman_cheers07.mp3",
  "vo/demoman_cheers08.mp3",
  "vo/taunts/demoman_taunts12.mp3"
};

static char g_strOrangemanLose[][] = {
  "vo/demoman_gibberish04.mp3",
  "vo/demoman_gibberish10.mp3",
  "vo/demoman_jeers03.mp3",
  "vo/demoman_jeers06.mp3",
  "vo/demoman_jeers07.mp3",
  "vo/demoman_jeers08.mp3"
};

static char g_strOrangemanRage[][] = {
  "vo/demoman_positivevocalization03.mp3",
  "vo/demoman_dominationscout05.mp3",
  "vo/demoman_cheers02.mp3"
};

static char g_strOrangemanJump[][] = {
  "vo/demoman_gibberish07.mp3",
  "vo/demoman_gibberish08.mp3",
  "vo/demoman_laughshort01.mp3",
  "vo/demoman_positivevocalization04.mp3"
};

static char g_strOrangemanKill[][] = {
  "vo/demoman_gibberish09.mp3",
  "vo/demoman_cheers02.mp3",
  "vo/demoman_cheers07.mp3",
  "vo/demoman_positivevocalization03.mp3"
};

static char g_strOrangemanLastMan[][] = {
  "vo/taunts/demoman_taunts05.mp3",
  "vo/taunts/demoman_taunts04.mp3",
  "vo/demoman_specialcompleted07.mp3"
};

static char g_strOrangemanBackStabbed[][] = {
  "vo/demoman_sf12_badmagic01.mp3",
  "vo/demoman_sf12_badmagic07.mp3",
  "vo/demoman_sf12_badmagic10.mp3"
};

public bool Orangeman_IsBossHidden(SaxtonHaleBase boss)
{
  return true;
}

public void Orangeman_Create(SaxtonHaleBase boss)
{
  boss.CreateClass("BraveJump");
  
  boss.CreateClass("ScareRage");
  boss.SetPropFloat("ScareRage", "Radius", 200.0);
  
  boss.CreateClass("Lunge"); // add lunge

  boss.iHealthPerPlayer    = 600;
  boss.flHealthExponential = 1.05;
  boss.nClass              = TFClass_DemoMan;
  boss.iMaxRageDamage      = 2500;
}

public void Orangeman_GetBossName(SaxtonHaleBase boss, char[] sName, int length)
{
  strcopy(sName, length, "OrangeMan");
}

public void Orangeman_GetBossInfo(SaxtonHaleBase boss, char[] sInfo, int length)
{
  StrCat(sInfo, length, "\nHealth: Medium");
  StrCat(sInfo, length, "\n ");
  StrCat(sInfo, length, "\nAbilities");
  StrCat(sInfo, length, "\n- Brave Jump");
  StrCat(sInfo, length, "\n- Lunge, reload to use");
  StrCat(sInfo, length, "\n ");
  StrCat(sInfo, length, "\nRage");
  StrCat(sInfo, length, "\n- Damage requirement: 2500");
  StrCat(sInfo, length, "\n- Coming Soon!");
}

public void Orangeman_OnSpawn(SaxtonHaleBase boss)
{
  int iWeapon;
  char attribs[128];
  Format(attribs, sizeof(attribs), "2 ; 2.31 ; 812 ; 2.0");
  
  // Spawn Frying Pan
  iWeapon = boss.CallFunction("CreateWeapon", 264, "tf_weapon_bottle", 100, TFQual_Collectors, attribs);	//Frying Pan Index, classname doesnt like saxxy
  if (iWeapon > MaxClients)
    SetEntPropEnt(boss.iClient, Prop_Send, "m_hActiveWeapon", iWeapon);

  // Spawn Grenade Launcher
  iWeapon = boss.CallFunction("CreateWeapon", 19, "tf_weapon_grenadelauncher", 100, TFQual_Collectors, attribs);

  // Spawn Pipebomb
  iWeapon = boss.CallFunction("CreateWeapon", 20, "tf_weapon_pipebomblauncher", 100, TFQual_Collectors, attribs);
}

public void Orangeman_GetSound(SaxtonHaleBase boss, char[] sSound, int length, SaxtonHaleSound iSoundType)
{
  switch (iSoundType)
  {
    case VSHSound_RoundStart: strcopy(sSound, length, g_strOrangemanRoundStart[GetRandomInt(0,sizeof(g_strOrangemanRoundStart)-1)]);
    case VSHSound_Win:        strcopy(sSound, length, g_strOrangemanWin[GetRandomInt(0,sizeof(g_strOrangemanWin)-1)]);
    case VSHSound_Lose:       strcopy(sSound, length, g_strOrangemanLose[GetRandomInt(0,sizeof(g_strOrangemanLose)-1)]);
    case VSHSound_Rage:       strcopy(sSound, length, g_strOrangemanRage[GetRandomInt(0,sizeof(g_strOrangemanRage)-1)]);
    case VSHSound_Lastman:    strcopy(sSound, length, g_strOrangemanLastMan[GetRandomInt(0,sizeof(g_strOrangemanLastMan)-1)]);
    case VSHSound_Backstab:   strcopy(sSound, length, g_strOrangemanBackStabbed[GetRandomInt(0,sizeof(g_strOrangemanBackStabbed)-1)]);
  }
}

public void Orangeman_GetSoundKill(SaxtonHaleBase boss, char[] sSound, int length, TFClassType nClass)
{
  strcopy(sSound, length, g_strOrangemanKill[GetRandomInt(0,sizeof(g_strOrangemanKill)-1)]);
}

public void Orangeman_OnPlayerKilled(SaxtonHaleBase boss, Event event, int iVictim)
{
 
}

public void Orangeman_GetSoundAbility(SaxtonHaleBase boss, char[] sSound, int length, const char[] sType)
{
  if (strcmp(sType, "BraveJump") == 0)
    strcopy(sSound, length, g_strOrangemanJump[GetRandomInt(0,sizeof(g_strOrangemanJump)-1)]);
}


public void Orangeman_OnThink(SaxtonHaleBase boss)
{
  
}

public void Orangeman_GetHudInfo(SaxtonHaleBase boss, char[] sMessage, int iLength, int iColor[4])
{
  
}

public void Orangeman_OnRage(SaxtonHaleBase boss)
{
  
}

public void Orangeman_GetModel(SaxtonHaleBase boss, char[] sModel, int length)
{
  strcopy(sModel, length, ORANGEMAN_MODEL);
}

public void Orangeman_Precache(SaxtonHaleBase boss)
{
  // Models
  AddFileToDownloadsTable("models/hunters/oemo/demo.mdl");
  AddFileToDownloadsTable("models/hunters/oemo/demo.vvd");
  AddFileToDownloadsTable("models/hunters/oemo/demo.phy");
  AddFileToDownloadsTable("models/hunters/oemo/demo.dx80.vtx");
  AddFileToDownloadsTable("models/hunters/oemo/demo.dx90.vtx");
  AddFileToDownloadsTable("models/hunters/oemo/demo.sw.vtx");
  
  // Materials
  AddFileToDownloadsTable("materials/hunters/oemo/demo_sfm_hands.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/demo_sfm_hands.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demo_sfm_hands_exponent.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demo_sfm_hands_phongmask.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demo_sfm_hands_red_invun.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demo_sfm_hands_red_invun.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_head_red.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_head_red_invun.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_head_red_invun.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_org.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_red.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_red_invun.vtf");
  AddFileToDownloadsTable("materials/hunters/oemo/demoman_red_invun.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/eyeball_invun.vmt");
  AddFileToDownloadsTable("materials/hunters/oemo/eyeball_r.vmt");
  
  PrecacheSound(SHIELD_SOUND, true);
  PrecacheModel(SHIELD_MODEL, true);
  
  for (int i = 0; i < sizeof(g_strOrangemanRoundStart); i++)  PrecacheSound(g_strOrangemanRoundStart[i]);
  for (int i = 0; i < sizeof(g_strOrangemanWin); i++)         PrecacheSound(g_strOrangemanWin[i]);
  for (int i = 0; i < sizeof(g_strOrangemanLose); i++)        PrecacheSound(g_strOrangemanLose[i]);
  for (int i = 0; i < sizeof(g_strOrangemanRage); i++)        PrecacheSound(g_strOrangemanRage[i]);
  for (int i = 0; i < sizeof(g_strOrangemanJump); i++)        PrecacheSound(g_strOrangemanJump[i]);
  for (int i = 0; i < sizeof(g_strOrangemanKill); i++)        PrecacheSound(g_strOrangemanKill[i]);
  for (int i = 0; i < sizeof(g_strOrangemanLastMan); i++)     PrecacheSound(g_strOrangemanLastMan[i]);
  for (int i = 0; i < sizeof(g_strOrangemanBackStabbed); i++) PrecacheSound(g_strOrangemanBackStabbed[i]);
}