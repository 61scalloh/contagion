MessagesInit()
{
	register_message(get_user_msgid("ShowMenu"), "Message_ShowMenu");
	register_message(get_user_msgid("VGUIMenu"), "Message_VGUIMenu");
}

public Message_ShowMenu(iMsgid, iDest, id)
{
	if (GameRules_ShowMenu(id))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public Message_VGUIMenu(iMsgid, iDest, id)
{
	if (GameRules_VGUIMenu(id))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}

public Message_StatusIcon(msgid, msgdest, id)
{
	if (GameRules_StatusIcon(id))
		return PLUGIN_HANDLED;

	return PLUGIN_CONTINUE;
}