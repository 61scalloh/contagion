#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <json>
#include <oo>
#include <contagion_const>

#include "playerclass.pwn"
#include "player.pwn"
#include "manager.pwn"
#include "amxx.pwn" // amxmodx
#include "engine.pwn" // fakemeta or engine
#include "ham.pwn" // hamsandwich
#include "utils.pwn"

public oo_init()
{
	PlayerClassOO();
	PlayerOO();
	ManagerOO();
}

public plugin_precache()
{
	PlayerClassPrecache();
}

public plugin_init()
{
	register_plugin("Contagion", "0.1", "peter5001");

	register_clcmd("set_playerclass", "CmdSetPlayerClass");

	PlayerClassInit()
	ManagerInit();
	EngineInit();
	HamInit();
}

public CmdSetPlayerClass(id)
{
	new class[32]
	read_argv(1, class, charsmax(class));

	if (!oo_class_exists(class))
	{
		console_print(id, "Class does not exists.")
		return PLUGIN_HANDLED;
	}

	if (!oo_subclass_of(class, "PlayerClass"))
	{
		console_print(id, "Invalid class.")
		return PLUGIN_HANDLED;
	}

	new Player:oPlayer = any:@call:g_oPlayerManager.PlayerOfIndex(id);
	@call :oPlayer.ChangeClass(class);
	
	return PLUGIN_HANDLED;
}