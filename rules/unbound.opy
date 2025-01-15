rule "Unbound":
    @Disabled
    @Delimiter


rule "— Dealt damage":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND

    if eventPlayer.unbound_preferences[Unbound.SLEEPING_SHOTS]:
        victim.setStatusEffect(eventPlayer, Status.ASLEEP, 1)

    if eventPlayer.unbound_preferences[Unbound.BURNING_SHOTS]:
        victim.setStatusEffect(eventPlayer, Status.BURNING, 1)

    if eventPlayer.unbound_preferences[Unbound.FREEZING_SHOTS]:
        victim.setStatusEffect(eventPlayer, Status.FROZEN, 1)

    if eventPlayer.unbound_preferences[Unbound.HACKING_SHOTS]:
        victim.setStatusEffect(eventPlayer, Status.HACKED, 1)

    if eventPlayer.unbound_preferences[Unbound.KNOCKING_SHOTS]:
        victim.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)

    if eventPlayer.unbound_preferences[Unbound.STUNNING_SHOTS]:
        victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)

    if eventPlayer.unbound_preferences[Unbound.REPULSIVE_SHOTS]:
        victim.applyImpulse(directionTowards(eventPlayer.getPosition(), victim.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)

    if eventPlayer.unbound_preferences[Unbound.ATTRACTIVE_SHOTS]:
        victim.applyImpulse(directionTowards(victim.getPosition(), eventPlayer.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)

    wait(0.25)


rule "— Dealt healing":
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND

    if eventPlayer.unbound_preferences[Unbound.SLEEPING_SHOTS]:
        healee.setStatusEffect(eventPlayer, Status.ASLEEP, 1)

    if eventPlayer.unbound_preferences[Unbound.BURNING_SHOTS]:
        healee.setStatusEffect(eventPlayer, Status.BURNING, 1)

    if eventPlayer.unbound_preferences[Unbound.FREEZING_SHOTS]:
        healee.setStatusEffect(eventPlayer, Status.FROZEN, 1)

    if eventPlayer.unbound_preferences[Unbound.HACKING_SHOTS]:
        healee.setStatusEffect(eventPlayer, Status.HACKED, 1)

    if eventPlayer.unbound_preferences[Unbound.KNOCKING_SHOTS]:
        healee.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)

    if eventPlayer.unbound_preferences[Unbound.STUNNING_SHOTS]:
        healee.setStatusEffect(eventPlayer, Status.STUNNED, 1)

    if eventPlayer.unbound_preferences[Unbound.REPULSIVE_SHOTS]:
        healee.applyImpulse(directionTowards(eventPlayer.getPosition(), healee.getPosition()), eventHealing * 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)

    if eventPlayer.unbound_preferences[Unbound.ATTRACTIVE_SHOTS]:
        healee.applyImpulse(directionTowards(healee.getPosition(), eventPlayer.getPosition()), eventHealing * 2, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)

    wait(0.25)


rule "— Sleeping shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.SLEEPING_SHOTS]

    victim.setStatusEffect(eventPlayer, Status.ASLEEP, 1)
    wait(0.25)


rule "— Burning shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.BURNING_SHOTS]

    victim.setStatusEffect(eventPlayer, Status.BURNING, 1)
    wait(0.25)


rule "— Freezing shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.FREEZING_SHOTS]

    victim.setStatusEffect(eventPlayer, Status.FROZEN, 1)
    wait(0.25)


rule "— Hacking shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.HACKING_SHOTS]

    victim.setStatusEffect(eventPlayer, Status.HACKED, 1)
    wait(0.25)


rule "— Knocking shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.KNOCKING_SHOTS]

    victim.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)
    wait(0.25)

    
rule "— Stunning shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.STUNNING_SHOTS]

    victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
    wait(0.25)


rule "— Repulsive shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.REPULSIVE_SHOTS]

    victim.applyImpulse(directionTowards(eventPlayer.getPosition(), victim.getPosition()), eventDamage, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.1)


rule "— Attractive shots":
    @Disabled
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.ATTRACTIVE_SHOTS]

    victim.applyImpulse(directionTowards(victim.getPosition(), eventPlayer.getPosition()), eventDamage, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.1)


rule "— Sleeping heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.SLEEPING_HEALS]

    healee.setStatusEffect(eventPlayer, Status.ASLEEP, 1)
    wait(0.25)


rule "— Burning heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.BURNING_HEALS]

    healee.setStatusEffect(eventPlayer, Status.BURNING, 1)
    wait(0.25)


rule "— Freezing heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.FREEZING_HEALS]

    healee.setStatusEffect(eventPlayer, Status.FROZEN, 1)
    wait(0.25)


rule "— Hacking heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.HACKING_HEALS]

    healee.setStatusEffect(eventPlayer, Status.HACKED, 1)
    wait(0.25)


rule "— Knocking heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.KNOCKING_HEALS]

    healee.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)
    wait(0.25)

    
rule "— Stunning heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.STUNNING_HEALS]

    healee.setStatusEffect(eventPlayer, Status.STUNNED, 1)
    wait(0.25)


rule "— Repulsive heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.REPULSIVE_HEALS]

    healee.applyImpulse(directionTowards(eventPlayer.getPosition(), healee.getPosition()), eventHealing, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.1)


rule "— Attractive heals":
    @Disabled
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer.unbound_preferences[Unbound.ATTRACTIVE_HEALS]

    healee.applyImpulse(directionTowards(healee.getPosition(), eventPlayer.getPosition()), eventHealing, Relativity.TO_WORLD, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.1)