stock PrecachePlayerModel(const model[])
{
	static modelPath[128];
	formatex(modelPath, charsmax(modelPath), "models/player/%s/%s.mdl", model, model);
	precache_model(modelPath);

	// Support modelT.mdl files
	formatex(modelPath, charsmax(modelPath), "models/player/%s/%sT.mdl", model, model);
	if (file_exists(modelPath)) precache_model(modelPath);
}

stock CreateBasicPlayerClassCvars(any:oInfo, health, Float:gravity, Float:speed)
{
	new str[20];
	num_to_str(health, str, charsmax(str));
	@call :oInfo.CreateCvar("health", str, FCVAR_NONE, "");

	float_to_str(gravity, str, charsmax(str));
	@call :oInfo.CreateCvar("gravity", str, FCVAR_NONE, "");

	float_to_str(speed, str, charsmax(str));
	@call :oInfo.CreateCvar("speed", str, FCVAR_NONE, "");
}