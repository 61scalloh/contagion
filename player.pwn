new PlayerTeam:g_PlayerTeam[MAX_PLAYERS + 1];
new PlayerClass:g_PlayerClass[MAX_PLAYERS + 1];

Player_Disconnect(id)
{
    g_PlayerTeam[id] = Team_None;
    
    if (g_PlayerClass[id] != @null)
    {
        @delete(g_PlayerClass[id]);
        g_PlayerClass[id] = @null;
    }
}

bool:Player_EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	new PlayerClass:oClass = g_PlayerClass[id];
	if (oClass == @null)
		return false;

	return bool:@call:oClass.ChangeSound(channel, sample, volume, attn, flags, pitch);
}

bool:Player_ResetMaxSpeed(id)
{
	new PlayerClass:oClass = g_PlayerClass[id];
	if (oClass == @null)
		return false;

	return bool:@call0:oClass.SetMaxSpeed();
}

bool:Player_ItemDeploy(ent, id)
{
	new PlayerClass:oClass = g_PlayerClass[id];
	if (oClass == @null)
		return false;
	
	return bool:@call:oClass.SetWeaponModel(ent);
}

Player_Spawned(id)
{
	GameRules_PlayerSpawned(id);

	if (g_PlayerClass[id] != @null)
		@call0:g_PlayerClass[id].SetProperties();
}

stock ChangePlayerClass(id, const destClass[])
{
	new PlayerClass:oClass = g_PlayerClass[id]
	if (oClass != @null)
	{
		// delete old player class
		@delete (oClass);
		g_PlayerClass[id] = @null;
	}

	// safe check: if destClass is vaild
	if (oo_class_exists(destClass) && oo_subclass_of(destClass, "PlayerClass"))
	{
		oClass = @new (destClass, id); // new object
		g_PlayerClass[id] = oClass; // assign to the player

		new PlayerClassInfo:o_info = any:@get(oClass.m_oClassInfo);
		g_PlayerTeam[id] = any:@get(o_info.m_Team); // set player team

		@call0 :oClass.SetProperties(); // set player properties
	}

	GameRules_ChangePlayerClass(id);
}

stock bool:PlayerIsA(id, const class[])
{
	if (g_PlayerClass[id] == @null)
		return false;
	
	return oo_isa(g_PlayerClass[id], class);
}

stock SetPlayerClass(id, const class[])
{
	if (g_PlayerClass[id] != @null)
	{
		@delete(g_PlayerClass[id]);
		g_PlayerClass[id] = @null;
	}

	g_PlayerClass[id] = @new(class, id);

	new PlayerClassInfo:oInfo = any:@get(g_PlayerClass[id].m_oClassInfo);
	if (oInfo != @null)
	{
		g_PlayerTeam[id] = any:@get(oInfo.m_Team);
	}
}