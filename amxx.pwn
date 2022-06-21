public client_connect(id)
{
	@call :g_oPlayerManager.Connect(id);
}

public client_disconnected(id)
{
	@call :g_oPlayerManager.Disconnect(id);
}