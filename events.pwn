EventsInit()
{
    register_event("HLTV", "Event_RestartRound", "a", "1=0", "2=0");
}

public Event_RestartRound()
{
    GameRules_RestartRound();
}