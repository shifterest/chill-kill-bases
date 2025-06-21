#!mainFile "../main.opy"

rule "Unbound":
    @Disabled
    @Delimiter


rule "— Dealt damage":
    @Event playerDealtDamage
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE] == PlayerMode.CHILL
    @Condition eventPlayer != victim

    switch eventPlayer.preferences[Preference.DAMAGE_EFFECT]:
        case AbilityEffect.SLEEP:
            victim.setStatusEffect(eventPlayer, Status.ASLEEP, 1)
            break
        case AbilityEffect.BURN:
            victim.setStatusEffect(eventPlayer, Status.BURNING, 1)
            break
        case AbilityEffect.FREEZE:
            victim.setStatusEffect(eventPlayer, Status.FROZEN, 1)
            break
        case AbilityEffect.HACK:
            victim.setStatusEffect(eventPlayer, Status.HACKED, 1)
            break
        case AbilityEffect.KNOCK:
            victim.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)
            break
        case AbilityEffect.STUN:
            victim.setStatusEffect(eventPlayer, Status.STUNNED, 1)
            break
        case AbilityEffect.REPEL:
            victim.applyImpulse(directionTowards(eventPlayer.getPosition(), victim.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            break
        case AbilityEffect.ATTRACT:
            victim.applyImpulse(directionTowards(victim.getPosition(), eventPlayer.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            break

    wait(0.25)


rule "— Received damage":
    @Event playerTookDamage
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE] == PlayerMode.CHILL
    @Condition eventPlayer != attacker

    switch eventPlayer.preferences[Preference.THORNS_EFFECT]:
        case AbilityEffect.SLEEP:
            attacker.setStatusEffect(eventPlayer, Status.ASLEEP, 1)
            break
        case AbilityEffect.BURN:
            attacker.setStatusEffect(eventPlayer, Status.BURNING, 1)
            break
        case AbilityEffect.FREEZE:
            attacker.setStatusEffect(eventPlayer, Status.FROZEN, 1)
            break
        case AbilityEffect.HACK:
            attacker.setStatusEffect(eventPlayer, Status.HACKED, 1)
            break
        case AbilityEffect.KNOCK:
            attacker.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)
            break
        case AbilityEffect.STUN:
            attacker.setStatusEffect(eventPlayer, Status.STUNNED, 1)
            break
        case AbilityEffect.REPEL:
            attacker.applyImpulse(directionTowards(eventPlayer.getPosition(), attacker.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            break
        case AbilityEffect.ATTRACT:
            attacker.applyImpulse(directionTowards(attacker.getPosition(), eventPlayer.getPosition()), eventDamage * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            break

    wait(0.25)


rule "— Dealt healing":
    @Event playerDealtHealing
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE] == PlayerMode.CHILL
    @Condition eventPlayer != healee

    switch eventPlayer.preferences[Preference.HEALING_EFFECT]:
        case AbilityEffect.SLEEP:
            healee.setStatusEffect(eventPlayer, Status.ASLEEP, 1)
            break
        case AbilityEffect.BURN:
            healee.setStatusEffect(eventPlayer, Status.BURNING, 1)
            break
        case AbilityEffect.FREEZE:
            healee.setStatusEffect(eventPlayer, Status.FROZEN, 1)
            break
        case AbilityEffect.HACK:
            healee.setStatusEffect(eventPlayer, Status.HACKED, 1)
            break
        case AbilityEffect.KNOCK:
            healee.setStatusEffect(eventPlayer, Status.KNOCKED_DOWN, 1)
            break
        case AbilityEffect.STUN:
            healee.setStatusEffect(eventPlayer, Status.STUNNED, 1)
            break
        case AbilityEffect.REPEL:
            healee.applyImpulse(directionTowards(eventPlayer.getPosition(), healee.getPosition()), eventHealing * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            break
        case AbilityEffect.ATTRACT:
            healee.applyImpulse(directionTowards(healee.getPosition(), eventPlayer.getPosition()), eventHealing * 2, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
            break

    wait(0.25)