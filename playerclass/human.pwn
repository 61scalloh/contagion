#if defined _ctg_human_included
	#endinput
#endif

#define _ctg_human_included

new HumanInfo:g_HumanInfo;

HumanOO()
{
	@subclass ("HumanInfo", "PlayerClassInfo")
	{
		@init_class("HumanInfo");

		// (const name[], const desc[], team, flags)
		@construct :Ctor(@string, @string, @cell, @cell);

		@method0 :LoadAssets();
	}

	@subclass ("Human", "PlayerClass");
	{
		@init_class("Human");

		@construct :Ctor(@cell); // (Obj:player_obj)
		@destruct  :Dtor();

		@method0 :AssignClassInfo();
	}
}

HumanPrecache()
{
	g_HumanInfo = any:@new("HumanInfo", "Human", "", Team_Human, 0);
}

HumanInit()
{
	CreateBasicPlayerClassCvars(g_HumanInfo, 99, 1.0, 1.0);
}

public HumanInfo@Ctor(const name[], const desc[], PlayerTeam:team, flags)
{
	oo_super_ctor("PlayerClassInfo", name, desc, team, flags);
}

public HumanInfo@LoadAssets() // override
{
	@call :_this.LoadJson("human");
}

public Human@Ctor(Player:obj)
{
	oo_super_ctor("PlayerClass", obj);
}

public Human@Dtor() {}

public Human@AssignClassInfo() // override
{
	@set (_this.m_oClassInfo: = g_HumanInfo);
}