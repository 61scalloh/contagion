#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <amxmisc>
#include <json>
#include <oo>
#include <contagion_const>

#include "playerclass.pwn"
#include "player.pwn"
#include "utils.pwn"

public oo_init()
{
    PlayerClassOO();
    PlayerOO();
    ManagerOO();
}

public plugin_init()
{
    register_plugin("Contagion", "0.1", "colgay");
}