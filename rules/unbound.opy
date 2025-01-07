rule "Unbound":
    @Disabled
    @Delimiter


rule "— Sleeping shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.SLEEPING]

    victim.setStatusEffect(eventPlayer, Status.ASLEEP, 1)
    wait(0.25)


rule "— Burning shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.BURNING]

    victim.setStatusEffect(eventPlayer, Status.BURNING, 1)
    wait(0.25)


rule "— Freezing shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.FREEZING]

    victim.setStatusEffect(eventPlayer, Status.FROZEN, 1)
    wait(0.25)


rule "— Hacking shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.HACKING]

    victim.setStatusEffect(eventPlayer, Status.HACKED, 1)
    wait(0.25)


rule "— Knocking shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.KNOCKING]

    victim.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)
    wait(0.25)

    
rule "— Stunning shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.STUNNING]

    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
    wait(0.25)


rule "— Repulsive shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.REPULSIVE]

    victim.applyImpulse(directionTowards(eventPlayer.getPosition(), victim.getPosition()), eventDamage, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.1)


rule "— Attractive shots":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.unbound_preferences[Unbound.ATTRACTIVE]

    victim.applyImpulse(directionTowards(victim.getPosition(), eventPlayer.getPosition()), eventDamage, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.1)