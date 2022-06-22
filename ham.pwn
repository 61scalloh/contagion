HamInit()
{
	RegisterHam(Ham_Spawn,  "player", "OnHamPlayerSpawn");
	RegisterHam(Ham_Spawn,  "player", "OnHamPlayerSpawn_Post", 1);
	RegisterHam(Ham_Killed, "player", "OnHamPlayerKilled_Post", 1);
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "OnHamResetPlayerSpeed_Post", 1);

	RegisterHam(Ham_Touch, "weaponbox", 	 "OnHamWeaponTouch", 0);
	RegisterHam(Ham_Touch, "armoury_entity", "OnHamWeaponTouch", 0);
	RegisterHam(Ham_Touch, "weapon_shield",  "OnHamWeaponTouch", 0);


	new weaponName[32];
	for (new i = CSW_P228; i <= CSW_P90; i++)
	{
		get_weaponname(i, strcm(weaponName));
		if (weaponName[0])
			RegisterHam(Ham_Item_Deploy, weaponName, "OnHamItemDeploy_Post", 1);
	}
}

public OnHamPlayerSpawn(id)
{
	if (!pev_valid(id))
		return;
	
	GameRules_PlayerSpawn(id);
}

public OnHamPlayerSpawn_Post(id)
{
	if (!is_user_alive(id))
		return;
	
	Player_Spawned(id);
}

public OnHamPlayerKilled_Post(id, attacker, shouldgib)
{
	GameRules_PlayerKilled(id, attacker);
}

public OnHamResetPlayerSpeed_Post(id)
{
	if (is_user_alive(id))
	{
		if (Player_ResetMaxSpeed(id))
			return HAM_HANDLED;
	}

	return HAM_IGNORED;
}

public OnHamItemDeploy_Post(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	new id = get_ent_data_entity(ent, "CBasePlayerItem", "m_pPlayer");
	if (is_user_alive(id))
	{
		if (Player_ItemDeploy(ent, id))
			return HAM_HANDLED;
	}

	return HAM_IGNORED;
}

public OnHamWeaponTouch(ent, toucher)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;

	if (is_user_alive(toucher))
	{
		if (!GameRules_CanPickupWeapon(ent, toucher))
			return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}