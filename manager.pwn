#if defined _ctg_manager_included
	#endinput
#endif

#define _ctg_manager_included

new PlayerManager:g_oPlayerManager;

ManagerOO()
{
	@class ("PlayerManager")
	{
		@init_class("PlayerManager");

		@var (OO_ARRAY[MAX_PLAYERS+1]:m_oPlayers);

		@construct0 :Ctor();

		@method :PlayerOfIndex(@cell); // Player:(id)
		@method :IndexOfPlayer(@cell); // (Player:oPlayer)
		@method :GetPlayerClass(@cell); // PlayerClass:(id)
		
		@method :Connect(@cell); // (id)
		@method :Disconnect(@cell); // (id)

		// bool:(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
		@method :EmitSound(@cell, @cell, @string, @float, @float, @cell, @cell);
		@method :ResetMaxSpeed(@cell); // bool:(id)
		@method :ItemDeploy(@cell, @cell); // bool:(ent, player)	
	}
}

ManagerInit()
{
	g_oPlayerManager = any:@new0("PlayerManager");
}

public PlayerManager@Ctor()
{
	/* not needed?
	new Player:oPlayers[MAX_PLAYERS+1] = {@null, ...};
	@seta(_this.m_oPlayer[0..sizeof(oPlayers)] >> oPlayers[0..sizeof(oPlayers)]);
	*/
}

public Player:PlayerManager@PlayerOfIndex(id)
{
	if (!(1 <= id <= MaxClients)) // index out of bounds
		return @null;
	
	new Player:oPlayer = @null;
	@geta(_this.m_oPlayers[id..id+1] >> oPlayer[0..1]);
	return oPlayer;
}

public PlayerManager@IndexOfPlayer(Player:oPlayer)
{
	return @get(oPlayer.m_PlayerIndex);
}

public PlayerClass:PlayerManager@GetPlayerClass(id)
{
	new Player:oPlayer = any:@call:_this.PlayerOfIndex(id);
	if (oPlayer == @null)
		return @null;
	
	new PlayerClass:oClass = any:@get(oPlayer.m_oClass);
	if (oClass == @null)
		return @null;
	
	return oClass;
}

public PlayerManager@Connect(id)
{
	new Player:oPlayer = any:@new("Player", id);
	@seta(_this.m_oPlayers[id..id+1] << oPlayer[0..1]);
}

public PlayerManager@Disconnect(id)
{
	new Player:oPlayer = @null;
	@geta(_this.m_oPlayers[id..id+1] >> oPlayer[0..1]);
	
	if (oPlayer != @null)
	{
		@delete (oPlayer);
		oPlayer = @null;
		@seta (_this.m_oPlayers[id..id+1] << oPlayer[0..1]);
	}
}

public bool:PlayerManager@EmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	new PlayerClass:oClass = any:@call:_this.GetPlayerClass(id);
	if (oClass == @null)
		return false;

	return bool:@call:oClass.ChangeSound(channel, sample, volume, attn, flags, pitch);
}

public bool:PlayerManager@ResetMaxSpeed(id)
{
	new PlayerClass:oClass = any:@call:_this.GetPlayerClass(id);
	if (oClass == @null)
		return false;

	return bool:@call0:oClass.SetMaxSpeed();
}

public bool:PlayerManager@ItemDeploy(ent, id)
{
	new PlayerClass:oClass = any:@call:_this.GetPlayerClass(id);
	if (oClass == @null)
		return false;
	
	return bool:@call:oClass.SetWeaponModel(ent);
}