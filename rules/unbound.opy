#!mainFile "../main.opy"

rule "Unbound":
    @Disabled
    @Delimiter


rule "— Dealt damage":
    @Event playerDealtDamage
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer != victim

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
        victim.applyImpulse(directionTowards(eventPlayer.getPosition(), victim.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

    if eventPlayer.unbound_preferences[Unbound.ATTRACTIVE_SHOTS]:
        victim.applyImpulse(directionTowards(victim.getPosition(), eventPlayer.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

    wait(0.25)


rule "— Dealt healing":
    @Event playerDealtHealing
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE] == PlayerMode.UNBOUND
    @Condition eventPlayer != healee

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
        healee.applyImpulse(directionTowards(eventPlayer.getPosition(), healee.getPosition()), eventHealing * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

    if eventPlayer.unbound_preferences[Unbound.ATTRACTIVE_SHOTS]:
        healee.applyImpulse(directionTowards(healee.getPosition(), eventPlayer.getPosition()), eventHealing * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)

    wait(0.25)