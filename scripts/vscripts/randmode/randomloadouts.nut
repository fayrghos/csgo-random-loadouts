// By fayrghos.

::RL_WeaponRollTime <- 15;
::RL_MaxGrenadeCount <- 3;
::RL_PrimUnluckChance <- 9;

::RL_PrimList <-
[
	// Rifles
	"weapon_famas",
	"weapon_galilar",
	"weapon_ak47",
	"weapon_m4a1",
	"weapon_m4a1_silencer",
	"weapon_ssg08",
	"weapon_sg556",
	"weapon_aug",
	"weapon_awp",
	"weapon_g3sg1",
	"weapon_scar20",

	// SMGs
	"weapon_mac10",
	"weapon_mp9",
	"weapon_mp5sd",
	"weapon_mp7",
	"weapon_ump45",
	"weapon_p90",
	"weapon_bizon",

	// Heavy
	"weapon_nova",
	"weapon_xm1014",
	"weapon_mag7",
	"weapon_sawedoff",
	"weapon_m249",
	"weapon_negev",
]

::RL_SecList <-
[
	"weapon_usp_silencer",
	"weapon_hkp2000",
	"weapon_glock",
	"weapon_elite",
	"weapon_p250",
	"weapon_fiveseven",
	"weapon_cz75a",
	"weapon_tec9",
	"weapon_revolver",
	"weapon_deagle",
]

::RL_UtilList <-
[
	"weapon_molotov",
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade",
//	"weapon_decoy",
	"weapon_tagrenade",
]

::RL_KnifeList <-
[
	"weapon_knife_css",
	"weapon_bayonet",
	"weapon_knife_flip",
	"weapon_knife_gut",
	"weapon_knife_karambit",
	"weapon_knife_m9_bayonet",
	"weapon_knife_tactical",
	"weapon_knife_butterfly",
	"weapon_knife_falchion",
	"weapon_knife_push",
	"weapon_knife_survival_bowie",
	"weapon_knife_ursus",
	"weapon_knife_gypsy_jackknife",
	"weapon_knife_stiletto",
	"weapon_knife_widowmaker",
	"weapon_knife_canis",
	"weapon_knife_cord",
	"weapon_knife_skeleton",
	"weapon_knife_outdoor",
]

::PreservedItemsGiven <- false;

// Triggers the script if possible
::RL_RoundStart <- function()
{
	if(!Entities.FindByName(null, "rl_timer"))
	{
		local timer = Entities.CreateByClassname("logic_timer");

		timer.__KeyValueFromString("targetname", "rl_timer");
		EntFireByHandle(timer, "RefireTime", RL_WeaponRollTime.tostring(), 0.0, null, null);
		EntFireByHandle(timer, "AddOutput", "OnTimer logic_timer:RunScriptCode:RandWeapons():0.0:-1", 0.0, null, null);

		PreservedItemsGiven = false;
		RandWeapons();
		RandModels();

		foreach(player in FindPlayers())
		{
			player.SetMaxHealth(200);
			player.SetHealth(200);
		}
	}
}

// Gives the same weapon loadout to every player
::RandWeapons <- function()
{
	local plyequip = Entities.CreateByClassname("game_player_equip");
	local clientcmd = Entities.CreateByClassname("point_clientcommand");

	local drawnprim = RandomInt(0, RL_PrimList.len()-1);
	local drawnsec = RandomInt(0, RL_SecList.len()-1);

	StripAllWeapons();

	// Primaries
	if(RandomInt(1, RL_PrimUnluckChance) != RL_PrimUnluckChance)
	{plyequip.__KeyValueFromInt(RL_PrimList[drawnprim], 0)}

	// Pistols
	plyequip.__KeyValueFromInt(RL_SecList[drawnsec], 0);

	// Grenades
	for(local i = 0; i < RL_MaxGrenadeCount; i++)
	{plyequip.__KeyValueFromInt(RL_UtilList[RandomInt(0, RL_UtilList.len()-1)], 0)}

	// Extras
	if(!PreservedItemsGiven)
	{
		switch(RandomInt(0, 2))
		{
			case 0:
				plyequip.__KeyValueFromInt("weapon_healthshot", 0);
				break;

			case 1:
				plyequip.__KeyValueFromInt("weapon_breachcharge", 0);
				break;

			case 2:
				plyequip.__KeyValueFromInt("weapon_bumpmine", 0);
				break;
		}

		RandKnives();
		PreservedItemsGiven = true;
	}

	foreach(player in FindPlayers())
	{
		EntFireByHandle(plyequip, "Use", "", 0, player, player);
		EntFireByHandle(clientcmd, "Command", "slot1", 0.1, player, player);
	}

	EntFireByHandle(plyequip, "Kill", "", 1.0, null, null);
	EntFireByHandle(clientcmd, "Kill", "", 1.0, null, null);
}

// Give knives to humans only
// Bots don't like custom knives so much
::RandKnives <- function()
{
	local knifeequip = Entities.CreateByClassname("game_player_equip");
	local drawnknf = RandomInt(0, RL_KnifeList.len()-1);

	knifeequip.__KeyValueFromInt(RL_KnifeList[drawnknf], 0);
	EntFire("weapon_knife*", "AddOutput", "classname weapon_knifegg", 0.05, null);

	foreach(player in FindPlayers(true))
	{
		local knife = null;
		while((knife = Entities.FindByClassname(knife, "weapon_knife*")) != null)
		{
			if(knife.GetOwner() == player)
			{EntFireByHandle(knife, "Kill", "", 0.0, null, null)}
		}

		EntFireByHandle(knifeequip, "Use", "", 0, player, player);
	}

	EntFireByHandle(knifeequip, "Kill", "", 1.0, null, null);
}

::StripAllWeapons <- function()
{
	local weparray = []
	weparray.extend(RL_PrimList);
	weparray.extend(RL_SecList);
	weparray.extend(RL_UtilList);

	foreach(weapon in weparray)
	{EntFire(weapon, "Kill", "", 0.0, null)}
}

// Pick a random model for each player
::RandModels <- function()
{
	foreach(player in FindPlayers())
	{
		PrecacheHands(player);

		if(player.GetTeam() == 2)
		{
			local drawnmodel = RandomInt(0, RL_TerrorModels.len()-1)

			player.PrecacheModel(RL_TerrorModels[drawnmodel]);
			player.SetModel(RL_TerrorModels[drawnmodel]);
		}

		else
		{
			local drawnmodel = RandomInt(0, RL_CounterModels.len()-1)

			player.PrecacheModel(RL_CounterModels[drawnmodel]);
			player.SetModel(RL_CounterModels[drawnmodel]);
		}
	}
}

::FindPlayers <- function(humansonly=false)
{
	local playerlist = [];
	local player = null;

	while((player = Entities.FindByClassname(player, "player")) != null)
	{
		if(player.GetTeam() == 2 || player.GetTeam() == 3)
		{playerlist.push(player)}
	}

	if(!humansonly)
	{
		while((player = Entities.FindByClassname(player, "cs_bot")) != null)
		{playerlist.push(player)}
	}

	return playerlist;
}

::RL_TerrorModels <-
[
	"models/player/custom_player/legacy/tm_anarchist.mdl",
	"models/player/custom_player/legacy/tm_anarchist_variantd.mdl",
	"models/player/custom_player/legacy/tm_balkan_variantc.mdl",
	"models/player/custom_player/legacy/tm_balkan_variantg.mdl",
	"models/player/custom_player/legacy/tm_balkan_varianth.mdl",
	"models/player/custom_player/legacy/tm_balkan_variantj.mdl",
	"models/player/custom_player/legacy/tm_jungle_raider_variantb.mdl",
	"models/player/custom_player/legacy/tm_jungle_raider_variante.mdl",
	"models/player/custom_player/legacy/tm_leet_variantk.mdl",
	"models/player/custom_player/legacy/tm_leet_varianth.mdl",
	"models/player/custom_player/legacy/tm_leet_variantf.mdl",
	"models/player/custom_player/legacy/tm_pirate.mdl",
	"models/player/custom_player/legacy/tm_pirate_variantb.mdl",
	"models/player/custom_player/legacy/tm_pirate_variantd.mdl",
	"models/player/custom_player/legacy/tm_professional_vari.mdl",
	"models/player/custom_player/legacy/tm_professional_varj.mdl",
	"models/player/custom_player/legacy/tm_separatist.mdl",
	"models/player/custom_player/legacy/tm_separatist_variantd.mdl",
	"models/player/custom_player/legacy/tm_separatist_variantb.mdl",
]

::RL_CounterModels <-
[
	"models/player/custom_player/legacy/ctm_diver_varianta.mdl",
	"models/player/custom_player/legacy/ctm_diver_variantc.mdl",
	"models/player/custom_player/legacy/ctm_gendarmerie_varianta.mdl",
	"models/player/custom_player/legacy/ctm_gendarmerie_variantb.mdl",
	"models/player/custom_player/legacy/ctm_gendarmerie_variante.mdl",
	"models/player/custom_player/legacy/ctm_idf.mdl",
	"models/player/custom_player/legacy/ctm_idf_variantb.mdl",
	"models/player/custom_player/legacy/ctm_sas.mdl",
	"models/player/custom_player/legacy/ctm_sas_variantf.mdl",
	"models/player/custom_player/legacy/ctm_st6.mdl",
	"models/player/custom_player/legacy/ctm_st6_varianta.mdl",
	"models/player/custom_player/legacy/ctm_st6_variante.mdl",
	"models/player/custom_player/legacy/ctm_st6_varianti.mdl",
	"models/player/custom_player/legacy/ctm_st6_variantn.mdl",
	"models/player/custom_player/legacy/ctm_swat_variante.mdl",
	"models/player/custom_player/legacy/ctm_swat_variantf.mdl",
	"models/player/custom_player/legacy/ctm_swat_variantg.mdl",
	"models/player/custom_player/legacy/ctm_swat_varianti.mdl",
	"models/player/custom_player/legacy/ctm_swat_variantk.mdl",
]

::PrecacheHands <- function(player)
{
	// Pirates
	player.PrecacheModel("models/weapons/t_arms_pirate.mdl");
	player.PrecacheModel("models/weapons/v_models/arms/pirate/v_pirate_watch.mdl");
	player.PrecacheModel("models/weapons/v_models/arms/bare/v_bare_hands.mdl");

	// Anarchists
	player.PrecacheModel("models/weapons/t_arms_anarchist.mdl");
	player.PrecacheModel("models/weapons/v_models/arms/anarchist/v_glove_anarchist.mdl");
	player.PrecacheModel("models/weapons/v_models/arms/anarchist/v_sleeve_anarchist.mdl");
}