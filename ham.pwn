HamInit()
{
    RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "OnHamResetPlayerSpeed_Post", 1);

    new weaponName[32];
    for (new i = CSW_P228; i <= CSW_P90; i++)
    {
        get_weaponname(i, weaponName, charsmax(weaponName));
        if (weaponName[0])
            RegisterHam(Ham_Item_Deploy, weaponName, "OnHamItemDeploy_Post", 1);
    }
}

public OnHamResetPlayerSpeed_Post(id)
{
    if (is_user_alive(id))
    {
        if (@call:g_oPlayerManager.ResetMaxSpeed(id))
            return HAM_HANDLED;
    }

    return HAM_IGNORED;
}

public OnHamItemDeploy_Post(ent)
{
    if (!pev_valid(ent))
        return HAM_IGNORED;

    new id = get_ent_data_entity(ent, "CBasePlayerItem", "m_pPlayer");
    if (is_user_alive(id))
    {
        if (@call:g_oPlayerManager.ItemDeploy(ent, id))
            return HAM_HANDLED;
    }

    return HAM_IGNORED;
}