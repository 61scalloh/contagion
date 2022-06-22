// no oop needed

const WEAPON_SUIT_BIT = 1 << 31;

const OFFSET_MAPZONES = 235;
const MAPZONE_BUY = (1 << 0);

new const SHOWMENU_JOINCLASS_T[] = "#Terrorist_Select";
new const SHOWMENU_JOINCLASS_CT[] = "#CT_Select";
const VGUIMENU_JOINCLASS_T = 26;
const VGUIMENU_JOINCLASS_CT = 27;

new TASK_RESPAWN;

new g_pGameRules;
new g_fwEntitiySpawn;
new Trie:g_tRemoveObjectiveEnts;

new g_cvarMinPlayers;
new g_cvarDeathMatch;
new g_cvarRespawnSuicide;
new g_cvarRespawnHumans;
new g_cvarRespawnZombies;
new Float:g_cvarRespawnDelay;

GameRulesPrecache()
{
	g_tRemoveObjectiveEnts = TrieCreate();
	LoadObjectiveEnts();

	g_fwEntitiySpawn = register_forward(FM_Spawn, "OnEntitySpawn");

	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules", OrpheuHookPost);

	CreateDummyBuyZone();
	CreateMapParamEnt();
}

GameRulesInit()
{
	taskid(TASK_RESPAWN);

	unregister_forward(FM_Spawn, g_fwEntitiySpawn);
	TrieClear(g_tRemoveObjectiveEnts);

	OrpheuRegisterHookFromObject(g_pGameRules, "CheckWinConditions", "CGameRules", "OnCheckWinConditions");
	OrpheuRegisterHookFromObject(g_pGameRules, "Think", "CGameRules", "OnGameRulesThink");

	new pcvar = create_cvar("ctg_min_players", "5");
	bind_pcvar_num(pcvar, g_cvarMinPlayers);

	pcvar = create_cvar("ctg_deathmatch", "2");
	bind_pcvar_num(pcvar, g_cvarDeathMatch);

	pcvar = create_cvar("ctg_respawn_on_suicide", "0");
	bind_pcvar_num(pcvar, g_cvarRespawnSuicide);

	pcvar = create_cvar("ctg_respawn_humans", "1");
	bind_pcvar_num(pcvar, g_cvarRespawnHumans);

	pcvar = create_cvar("ctg_respawn_zombies", "1");
	bind_pcvar_num(pcvar, g_cvarRespawnZombies);

	pcvar = create_cvar("ctg_respawn_delay", "3");
	bind_pcvar_float(pcvar, g_cvarRespawnDelay);
}

public OnEntitySpawn(ent)
{
	if (!pev_valid(ent))
		return FMRES_IGNORED;
	
	static className[32];
	entity_get_string(ent, EV_SZ_classname, strcm(className));

	if (TrieKeyExists(g_tRemoveObjectiveEnts, className))
	{
		remove_entity(ent);
		return FMRES_SUPERCEDE;
	}

	return FMRES_IGNORED;
}

public OnInstallGameRules()
{
	g_pGameRules = OrpheuGetReturn();
}

public OrpheuHookReturn:OnCheckWinConditions()
{
	new numSpawnableTs, numSpawnableCt;
	InitializePlayerCounts(_, _, numSpawnableTs, numSpawnableCt);

	if (get_gamerules_int("CHalfLifeMultiplay", "m_iRoundWinStatus") != WINSTATUS_NONE)
		return OrpheuSupercede;

	// needed players
	if (!get_gamerules_int("CHalfLifeMultiplay", "m_bFirstConnected"))
	{
		// enough players
		if (numSpawnableTs + numSpawnableCt >= g_cvarMinPlayers)
		{
			// execute game commencing
			set_gamerules_int("CGameRules", "m_bFreezePeriod", 0);
			set_gamerules_int("CHalfLifeMultiplay", "m_bCompleteReset", 1);

			EndRoundMessage("#Game_Commencing", ROUND_GAME_COMMENCE);
			TerminateRound(3.0, WINSTATUS_DRAW);

			set_gamerules_int("CHalfLifeMultiplay", "m_bFirstConnected", 1);
		}

		return OrpheuSupercede;
	}
	else
	{/*
		// gamemode not yet started
		if (ctg_GetCurrentGameMode() == CTG_NULL)
		{
			// not enough players
			if (numSpawnableTs + numSpawnableCt < CvarMinPlayers)
			{
				set_gamerules_int("CHalfLifeMultiplay", "m_bFirstConnected", 0); // reset
				return OrpheuSupercede;
			}
		}
		else
		{
			// zombies win
			if (CountPlayers(true, ctg_Human(), true) < 1)
			{
				Broadcast("terwin");
				EndRoundMessage("#Terrorists_Win", ROUND_TERRORISTS_WIN);
				TerminateRound(5.0, WINSTATUS_TERRORISTS);
				return OrpheuSupercede;
			}
		}*/
	}

	return OrpheuSupercede;
}

public OnGameRulesThink(pGameRules)
{
	if (!get_gamerules_int("CGameRules", "m_bFreezePeriod") && GetRoundRemainingTime() <= 0 
	&& get_gamerules_int("CHalfLifeMultiplay", "m_iRoundWinStatus") == WINSTATUS_NONE)
	{
		Broadcast("ctwin");
		EndRoundMessage("#Target_Saved", ROUND_TARGET_SAVED);
		TerminateRound(5.0, WINSTATUS_CTS);

		set_gamerules_float("CHalfLifeMultiplay", "m_fRoundCount", get_gametime() + 60.0);
	}
}

GameRules_RestartRound()
{
	for (new i = 1; i < MaxClients; i++)
	{
		if (!is_user_connected(i) || !(CS_TEAM_T <= cs_get_user_team(i) <= CS_TEAM_CT))
			continue;
		
		SetPlayerClass(i, "Human");
	}
}

bool:GameRules_ShowMenu(id)
{
	static menucode[32];
	get_msg_arg_string(4, strcm(menucode));

	if (equal(menucode, SHOWMENU_JOINCLASS_T) || equal(menucode, SHOWMENU_JOINCLASS_CT))
	{
		RequestFrame("AutoJoinClass", id);
		return true;
	}

	return false;
}

bool:GameRules_VGUIMenu(id)
{
	new menuId = get_msg_arg_int(1);
	if (menuId == VGUIMENU_JOINCLASS_T || menuId == VGUIMENU_JOINCLASS_CT)
	{
		RequestFrame("AutoJoinClass", id);
		return true;
	}

	return false;
}

bool:GameRules_StatusIcon(id)
{
	if (is_user_alive(id))
	{
		static icon[8];
		get_msg_arg_string(2, strcm(icon));

		if (equal(icon, "buyzone") && get_msg_arg_int(1))
		{
			set_pdata_int(id, OFFSET_MAPZONES, get_pdata_int(id, OFFSET_MAPZONES) & ~MAPZONE_BUY);
			return true;
		}
	}

	return false;
}

public AutoJoinClass(id)
{
	if (is_user_connected(id))
		engclient_cmd(id, "joinclass", "5");
}

GameRules_SetPlayerProperties(id)
{
	switch (g_PlayerTeam[id])
	{
		case Team_Human:
			cs_set_user_team(id, CS_TEAM_CT, CS_NORESET);
		case Team_Zombie:
			cs_set_user_team(id, CS_TEAM_T, CS_NORESET);
	}
}

GameRules_ChangePlayerClass(id)
{
	OnCheckWinConditions();
}

GameRules_PlayerSpawn(id)
{
	if (!(1 <= get_ent_data(id, "CBasePlayer", "m_iTeam") <= 2))
		return;
	
	static team; team = !team;
	set_ent_data(id, "CBasePlayer", "m_iTeam", team + 1); // fix spawn points
	set_ent_data(id, "CBasePlayer", "m_bNotKilled", true);

	new weaponbits = pev(id, pev_weapons);
	if (~weaponbits & WEAPON_SUIT_BIT)
		set_pev(id, pev_weapons, weaponbits | WEAPON_SUIT_BIT);
}

GameRules_PlayerSpawned(id)
{
	if (!(1 <= get_ent_data(id, "CBasePlayer", "m_iTeam") <= 2))
		return;
	
	if (!user_has_weapon(id, CSW_KNIFE))
		give_item(id, "weapon_knife");
	
	if (g_PlayerClass[id] == @null)
		SetPlayerClass(id, "Human");
	
	remove_task(id + TASK_RESPAWN);
}

GameRules_PlayerKilled(id, attacker)
{
	DeathmatchRespawn(id, attacker);
}

GameRules_Disconnect(id)
{
	remove_task(id + TASK_RESPAWN);
}

bool:GameRules_CanPickupWeapon(ent, id)
{
	if (PlayerIsA(id, "Zombie"))
		return false;
	
	return true;
}

bool:DeathmatchRespawn(id, attacker)
{
	if (g_cvarDeathMatch)
	{
		server_print("Suicide");
		if (!g_cvarRespawnSuicide && (id == attacker || !is_user_connected(attacker)))
			return false;

		server_print("Team");
		new PlayerTeam:team = g_PlayerTeam[id];
		if ((team == Team_Zombie && !g_cvarRespawnZombies) || (team == Team_Human && !g_cvarRespawnHumans))
			return false;

		set_task(g_cvarRespawnDelay, "TaskRespawnPlayer", id+TASK_RESPAWN);
		return true;
	}

	return false;
}

public TaskRespawnPlayer(taskid)
{
	new id = taskid - TASK_RESPAWN;
	if (is_user_alive(id))
		return;
	
	new CsTeams:team = cs_get_user_team(id);
	if (team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
		return;

	new bool:respawnAsZombie = false;
	if (g_cvarDeathMatch == 2 || (g_cvarDeathMatch == 3 && random_num(0, 1)) 
	|| (g_cvarDeathMatch == 4 && CountPlayers(true, "Zombie") <= CountPlayers(true) / 2))
		respawnAsZombie = true;
	
	SetPlayerClass(id, respawnAsZombie ? "Zombie" : "Human");
	ExecuteHamB(Ham_CS_RoundRespawn, id);
}

LoadObjectiveEnts()
{
	static filePath[100];
	get_configsdir(strcm(filePath));
	format(strcm(filePath), "%s/contagion/remove_entities.ini", filePath);

	new file = fopen(filePath, "r");
	if (file)
	{
		static lineStr[40];
		while (!feof(file))
		{
			fgets(file, strcm(lineStr));

			if (lineStr[0] == ';' || strlen(lineStr) < 1)
				continue;
			
			trim(lineStr);
			TrieSetCell(g_tRemoveObjectiveEnts, lineStr, 1);
		}

		fclose(file);
	}
}

CreateDummyBuyZone()
{
	new ent;
	for (new team = 1; team <= 2; team++)
	{
		ent = create_entity("func_buyzone");
		if (ent)
		{
			entity_set_int(ent, EV_INT_team, team);
			DispatchSpawn(ent);
			entity_set_origin(ent, Float:{0.0, 0.0, 0.0});
			entity_set_size(ent, Float:{-4096.0, -4096.0, -4096.0}, Float:{4096.0, 4096.0, 4096.0});
		} 
	}
}

CreateMapParamEnt()
{
	new ent = create_entity("info_map_parameters");
	DispatchKeyValue(ent, "buying", "1");
	DispatchSpawn(ent);
}

stock InitializePlayerCounts(&numTs=0, &numCt=0, &numSpawnableTs=0, &numSpawnableCt=0)
{
	numTs = 0;
	numCt = 0;
	numSpawnableTs = 0;
	numSpawnableCt = 0;

	for (new i = 1; i <= MaxClients; i++)
	{
		if (!is_user_connected(i))
			continue;
		
		switch (cs_get_user_team(i))
		{
			case CS_TEAM_T:
			{
				numTs++;

				if (GetPlayerCsMenu(i) != CS_Menu_ChooseAppearance)
					numSpawnableTs++;
			}
			case CS_TEAM_CT:
			{
				numCt++;

				if (GetPlayerCsMenu(i) != CS_Menu_ChooseAppearance)
					numSpawnableCt++;
			}
		}
	}

	set_gamerules_int("CHalfLifeMultiplay", "m_iNumTerrorist", numTs);
	set_gamerules_int("CHalfLifeMultiplay", "m_iNumSpawnableTerrorist", numSpawnableTs);
	set_gamerules_int("CHalfLifeMultiplay", "m_iNumCT", numCt);
	set_gamerules_int("CHalfLifeMultiplay", "m_iNumSpawnableCT", numSpawnableCt);
}

EndRoundMessage(const message[], type)
{
	static OrpheuFunction:func;
	func || (func = OrpheuGetFunction("EndRoundMessage"));

	OrpheuCallSuper(func, message, type);
}

TerminateRound(Float:delay, status)
{
	set_gamerules_int("CHalfLifeMultiplay", "m_iRoundWinStatus", status);
	set_gamerules_float("CHalfLifeMultiplay", "m_fTeamCount", get_gametime() + delay);
	set_gamerules_int("CHalfLifeMultiplay", "m_bRoundTerminating", 1);
}

Broadcast(const sentence[])
{
	new text[32];
	formatex(strcm(text), "%!MRAD_%s", sentence);

	static msgSendAudio;
	msgSendAudio || (msgSendAudio = get_user_msgid("SendAudio"));

	emessage_begin(MSG_BROADCAST, msgSendAudio)
	ewrite_byte(0);
	ewrite_string(text);
	ewrite_short(PITCH_NORM);
	emessage_end();
}

Float:GetRoundRemainingTime()
{
	return get_gamerules_float("CHalfLifeMultiplay", "m_fRoundCount") + float(get_gamerules_int("CHalfLifeMultiplay", "m_iRoundTimeSecs")) - get_gametime();
}