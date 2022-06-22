CommandsInit()
{
    register_clcmd("set_playerclass", "ClCmd_SetPlayerClass");
}

public ClCmd_SetPlayerClass(id)
{
	static arg[32];
	read_argv(1, strcm(arg));

	new player = cmd_target(id, arg);
	if (!player)
		return PLUGIN_HANDLED;
	
	static class[32];
	read_argv(2, strcm(class));

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

	ChangePlayerClass(player, class);
	return PLUGIN_HANDLED;
}