#if defined _ctg_playerclass_included
	#endinput
#endif

#define _ctg_playerclass_included

PlayerClassOO()
{
	@class ("PlayerClassInfo")
	{
		@init_class("PlayerClassInfo");

		@var (OO_ARRAY[32]:m_Name);
		@var (OO_ARRAY[32]:m_Desc);
		@var (OO_CELL:m_Team);
		@var (OO_CELL:m_Flags);
		@var (OO_CELL:m_Models); // Array:
		@var (OO_CELL:m_vModels); // Trie:
		@var (OO_CELL:m_pModels); // Trie:
		@var (OO_CELL:m_Sounds); // Trie:
		@var (OO_CELL:m_Cvars) // Trie:

		// (const name[], const desc[], team, flags)
		@construct :Ctor(@string, @string, @cell, @cell);
		@destruct  :Dtor();

		// (const name[], const string[], flags, const desc[])
		@method :CreateCvar(@string, @string, @cell, @string);

		@method0 :LoadAssets();
		@method  :LoadJson(@string); // (const fileName[])
	}

	@class ("PlayerClass")
	{
		@init_class("PlayerClass");

		@var (OO_CELL:m_oPlayer); // Obj:
		@var (OO_CELL:m_oClassInfo); // Obj:

		@construct :Ctor(@cell); // (Obj:oPlayer)
		@destruct  :Dtor();

		@method0 :GetPlayerIndex();
		@method0 :AssignClassInfo();
		@method0 :SetProperties();
		@method0 :SetMaxSpeed();
		@method  :SetWeaponModel(@cell); // (entity)

		// (channel, const sample[], Float:volume, Float:attn, flags, pitch)
		@method :ChangeSound(@cell, @string, @float, @float, @cell, @cell);
	}

	PlayerClassesOO();
}

public PlayerClassInfo@Ctor(const name[], const desc[], PlayerTeam:team, flags)
{
	server_print("call PlayerClassInfo@Ctor()");

	@init_this(this);

	@sets (this.m_Name[] << name);
	@sets (this.m_Desc[] << desc);
	@sets (this.m_Team[] << team);
	@set  (this.m_Flags: = flags);

	@set (this.m_Models: 	= ArrayCreate(32));
	@set (this.m_vModels: 	= TrieCreate());
	@set (this.m_pModels: 	= TrieCreate());
	@set (this.m_Sounds: 	= TrieCreate());
	@set (this.m_Cvars: 	= TrieCreate());

	@call0 :this.LoadAssets();
}

public PlayerClassInfo@Dtor() {}

public PlayerClassInfo@CreateCvar(const name[], const string[], flags, const desc[])
{
	@init_this(this);

	static cvarName[50], className[32];
	@gets (this.m_Name[] >> className[32]);
	strtolower(className);

	formatex(cvarName, charsmax(cvarName), "ctg_%s_%s", className, name);
	TrieSetCell(Trie:@get(this.m_Cvars), name, create_cvar(cvarName, string, flags, desc));
}

public PlayerClassInfo@LoadAssets() // override this
{
	@call :_this.LoadJson("player");
}

public PlayerClassInfo@LoadJson(const fileName[])
{
	@init_this(this);

	static path[100];
	get_configsdir(path, charsmax(path));
	format(path, charsmax(path), "%s/contagion/playerclass/%s.json", path, fileName);

	new JSON:json = json_parse(path, true, true);
	if (json != Invalid_JSON)
	{
		static key[128], value[128];

		// load player models
		new JSON:models_json = json_object_get_value(json, "models");
		if (models_json != Invalid_JSON)
		{
			new Array:aModels = Array:@get(this.m_Models);
			for (new i = json_array_get_count(models_json) - 1; i >= 0; i--)
			{
				json_array_get_string(models_json, i, value, charsmax(value));
				ArrayPushString(aModels, value);
				PrecachePlayerModel(value);
			}
			json_free(models_json);
		}

		// load view models
		new JSON:vmodels_json = json_object_get_value(json, "v_models");
		if (vmodels_json != Invalid_JSON)
		{
			new JSON:vmodel_val = Invalid_JSON;
			new Trie:vmodel_trie = Trie:@get(this.m_vModels);
			for (new i = json_object_get_count(vmodels_json) - 1; i >= 0; i--)
			{
				json_object_get_name(vmodels_json, i, key, charsmax(key));
				vmodel_val = json_object_get_value_at(vmodels_json, i);
				json_get_string(vmodel_val, value, charsmax(value));
				json_free(vmodel_val);
				TrieSetString(vmodel_trie, key, value);
				if (value[0])
					precache_model(value);
			}
			json_free(vmodels_json);
		}

		// load 3rd person models
		new JSON:pmodel_json = json_object_get_value(json, "p_models");
		if (pmodel_json != Invalid_JSON)
		{
			new JSON:pmodel_val = Invalid_JSON;
			new Trie:pmodel_trie = Trie:@get(this.m_pModels);
			for (new i = json_object_get_count(pmodel_json) - 1; i >= 0; i--)
			{
				json_object_get_name(pmodel_json, i, key, charsmax(key));
				pmodel_val = json_object_get_value_at(pmodel_json, i);
				json_get_string(pmodel_val, value, charsmax(value));
				json_free(pmodel_val);
				TrieSetString(pmodel_trie, key, value);
				if (value[0])
					precache_model(value);
			}
			json_free(pmodel_json);
		}

		// load sound_json
		new JSON:sound_json = json_object_get_value(json, "sounds");
		if (sound_json != Invalid_JSON)
		{
			new Array:aSounds = Invalid_Array;
			new JSON:sound_val = Invalid_JSON;
			new Trie:sound_trie = Trie:@get(this.m_Sounds);
			for (new i = json_object_get_count(sound_json) - 1; i >= 0; i--)
			{
				json_object_get_name(sound_json, i, key, charsmax(key));
				sound_val = json_object_get_value_at(sound_json, i);
				aSounds = ArrayCreate(100);
				for (new i = json_array_get_count(sound_val) - 1; i >= 0; i--)
				{
					json_array_get_string(sound_val, i, value, charsmax(value));
					ArrayPushString(aSounds, value);
					if (value[0])
						precache_sound(value);
				}
				json_free(sound_val);
				TrieSetCell(sound_trie, key, aSounds);
			}
			json_free(sound_json);
		}

		json_free(json);

		server_print("PlayerClass@LoadJson(%s)", fileName);
	}
}

// constructor
public PlayerClass@Ctor(Object:oPlayer)
{
	@init_this(this);
	@set (this.m_oPlayer: = oPlayer);
	@call0 :this.AssignClassInfo();
}

public PlayerClass@Dtor() {}

// Get player index
public PlayerClass@GetPlayerIndex()
{
	new Player:oPlayer = any:@get(_this.m_oPlayer);
	if (oPlayer == @null)
		return 0;
	
	return @get(oPlayer.m_PlayerIndex);
}

// Assign player class info
public PlayerClass@AssignClassInfo() // override this?
{
	@set (_this.m_oClassInfo: = @null); // assign nothing
}

public PlayerClass@SetProperties()
{
	@init_this(this);

	new PlayerClassInfo:oInfo = any:@get(this.m_oClassInfo);
	if (oInfo == @null)
		return;

	new id = @call0:this.GetPlayerIndex();
	new Trie:tCvars = Trie:@get(oInfo.m_Cvars);
	new pCvar;

	// has health
	if (TrieGetCell(tCvars, "health", pCvar))
		set_user_health(id, get_pcvar_num(pCvar));

	// has gravity
	if (TrieGetCell(tCvars, "gravity", pCvar))
		set_user_gravity(id, get_pcvar_float(pCvar));

	new Array:aModel = Array:@get(oInfo.m_Models);
	new modelSize = ArraySize(aModel);
	if (modelSize > 0) // has model
	{
		static buffer[32];
		ArrayGetString(aModel, random(modelSize), buffer, charsmax(buffer));
		cs_set_user_model(id, buffer);
	}

	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id); // update maxspeed

	new ent = get_ent_data_entity(id, "CBasePlayer", "m_pActiveItem");
	if (pev_valid(ent)) ExecuteHamB(Ham_Item_Deploy, ent); // update weapon model
}

public bool:PlayerClass@SetMaxSpeed()
{
	@init_this(this);

	new PlayerClassInfo:oInfo = any:@get(this.m_oClassInfo);
	if (oInfo == @null)
		return false;

	new id = @call0:this.GetPlayerIndex();
	new Trie:tCvars = Trie:@get(oInfo.m_Cvars);
	new pCvar;

	if (TrieGetCell(tCvars, "speed", pCvar)) // has maxspeed
	{
		new Float:speed = get_pcvar_float(pCvar);
		set_user_maxspeed(id, (speed < 5.0) ? get_user_maxspeed(id) * speed : speed);
		return true;
	}

	return false;
}

public bool:PlayerClass@SetWeaponModel(ent)
{
	@init_this(this);

	new PlayerClassInfo:oInfo = any:@get(this.m_oClassInfo);
	if (oInfo == @null)
		return false;

	static className[32], model[100];
	entity_get_string(ent, EV_SZ_classname, className, charsmax(className));

	new id = @call0:this.GetPlayerIndex();

	// has v_model
	if (TrieGetString(Trie:@get(oInfo.m_vModels), className, model, charsmax(model)))
	{
		//server_print("id(%d) className(%s)", id, className);
		set_pev(id, pev_viewmodel2, model);
		return true;
	}

	// has p_model
	if (TrieGetString(Trie:@get(oInfo.m_pModels), className, model, charsmax(model)))
	{
		set_pev(id, pev_weaponmodel2, model);
		return true;
	}

	return false;
}

// return true for blocking the original EmitSound() forward
public bool:PlayerClass@ChangeSound(channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	@init_this(this);

	new PlayerClassInfo:oInfo = any:@get(this.m_oClassInfo);
	if (oInfo == @null)
		return false;

	static sound[100], Array:aSound;

	// has sound
	if (TrieGetCell(Trie:@get(oInfo.m_Sounds), sample, aSound))
	{
		//server_print("pass");
		new id = @call0:this.GetPlayerIndex();
		ArrayGetString(aSound, random(ArraySize(aSound)), sound, charsmax(sound));
		emit_sound(id, channel, sound, volume, attn, flags, pitch);
		return true;
	}

	return false;
}

// --------------------------------------

#include "playerclass/human.pwn"
#include "playerclass/zombie.pwn"

PlayerClassesOO()
{
	HumanOO();
	ZombieOO();
}

PlayerClassPrecache()
{
	HumanPrecache();
	ZombiePrecache();
}

PlayerClassInit()
{
	HumanInit();
	ZombieInit();
}