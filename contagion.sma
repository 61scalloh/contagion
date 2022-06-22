#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <json>
#include <orpheu>
#include <orpheu_stocks>
#include <oo>
#include <contagion_const>

#include "const.pwn"
#include "language.pwn"
#include "playerclass.pwn"
#include "player.pwn"
#include "gamerules.pwn"
#include "amxx.pwn" // amxmodx
#include "engine.pwn" // fakemeta or engine
#include "ham.pwn" // hamsandwich
#include "events.pwn"
#include "messages.pwn"
#include "commands.pwn"
#include "utils.pwn"

public oo_init()
{
	PlayerClassOO();
}

public plugin_precache()
{
	PlayerClassPrecache();
	GameRulesPrecache();
}

public plugin_init()
{
	register_plugin("Contagion", "0.1", "peter5001");

	LanguageInit();
	PlayerClassInit()
	GameRulesInit();
	EngineInit();
	HamInit();
	EventsInit();
	MessagesInit();
	CommandsInit();
}