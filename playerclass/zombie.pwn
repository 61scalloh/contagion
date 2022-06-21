#if defined _ctg_zombie_included
	#endinput
#endif

#define _ctg_zombie_included

new ZombieInfo:g_ZombieInfo;

ZombieOO()
{
	@subclass ("ZombieInfo", "PlayerClassInfo")
	{
		@init_class("ZombieInfo");

		// (const name[], const desc[], team, flags)
		@construct :Ctor(@string, @string, @cell, @cell);

		@method0 :LoadAssets();
	}

	@subclass ("Zombie", "PlayerClass");
	{
		@init_class("Zombie");

		@construct :Ctor(@cell); // (Obj:player_obj)
		@destruct  :Dtor();

		@method0 :AssignClassInfo();
	}
}

ZombiePrecache()
{
	g_ZombieInfo = any:@new("ZombieInfo", "Zombie", "", Team_Zombie, 0);
}

ZombieInit()
{
	CreateBasicPlayerClassCvars(g_ZombieInfo, 250, 0.5, 1.2);
}

public ZombieInfo@Ctor(const name[], const desc[], PlayerTeam:team, flags)
{
	oo_super_ctor("PlayerClassInfo", name, desc, team, flags);
}

public ZombieInfo@LoadAssets() // override
{
	@call :_this.LoadJson("zombie");
}

public Zombie@Ctor(Player:obj)
{
	oo_super_ctor("PlayerClass", obj);
}

public Zombie@Dtor() {}

public Zombie@AssignClassInfo() // override
{
	@set (_this.m_oClassInfo: = g_ZombieInfo);
}