EngineInit()
{
	register_forward(FM_EmitSound, "OnFmEmitSound");
}

public OnFmEmitSound(id, channel, const sample[], Float:volume, Float:attn, flags, pitch)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED;

	if (@call:g_oPlayerManager.EmitSound(id, channel, sample, volume, attn, flags, pitch))
		return FMRES_SUPERCEDE;

	return FMRES_IGNORED;
}