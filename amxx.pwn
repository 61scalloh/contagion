public client_connectex(id)
{
	@call :g_oPlayerManager.Connect(id);
}

public client_disconnected(id)
{
	@call :g_oPlayerManager.Disconnect(id);
}