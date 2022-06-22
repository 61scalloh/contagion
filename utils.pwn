stock PrecachePlayerModel(const model[])
{
	static modelPath[128];
	formatex(strcm(modelPath), "models/player/%s/%s.mdl", model, model);
	precache_model(modelPath);

	// Support modelT.mdl files
	formatex(strcm(modelPath), "models/player/%s/%sT.mdl", model, model);
	if (file_exists(modelPath)) precache_model(modelPath);
}

stock CreateBasicPlayerClassCvars(any:oInfo, health, Float:gravity, Float:speed)
{
	new str[20];
	num_to_str(health, strcm(str));
	@call :oInfo.CreateCvar("health", str, FCVAR_NONE, "");

	float_to_str(gravity, strcm(str));
	@call :oInfo.CreateCvar("gravity", str, FCVAR_NONE, "");

	float_to_str(speed, strcm(str));
	@call :oInfo.CreateCvar("speed", str, FCVAR_NONE, "");
}

stock CountPlayers(bool:alive=true, const matchClass[]="", CsTeams:matchTeam=CS_TEAM_UNASSIGNED)
{
	new count = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_connected(i))
			continue;
		
		new CsTeams:team = cs_get_user_team(i);
		if (matchTeam != CS_TEAM_UNASSIGNED && team != matchTeam)
			continue;

		if (alive && !is_user_alive(i))
			continue;

		if (matchClass[0] && !PlayerIsA(i, matchClass))
			continue;

		count++;
	}

	return count;
}

stock CsMenu:GetPlayerCsMenu(id)
{
	return CsMenu:get_ent_data(id, "CBasePlayer", "m_iMenu");
}