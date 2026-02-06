#!mainFile "../main.opy"

rule "Stasis":
    @Disabled
    @Delimiter


rule "— Enter stasis":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.STASIS]
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition eventPlayer.uiState != UIState.MODERATING
    @Condition eventPlayer.uiState != UIState.VIEWING_PREFERENCES

    if eventPlayer.isInStasis:
        ExitStasis()
    else:
        eventPlayer.isInStasis = true
        iconMessage(eventPlayer, abilityIconString(Hero.ANA, Button.ABILITY_1), "Entered stasis!")
    wait(1)


def ExitStasis():
    @Name "— Exit stasis"

    eventPlayer.isInStasis = false
    if not eventPlayer.isInModeratorStasis:
        switch eventPlayer.preferences[Preference.STASIS_MODE]:
            case Stasis.KNOCKED_DOWN:
                eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
                break
            case Stasis.STUNNED:
                eventPlayer.clearStatusEffect(Status.STUNNED)
                break
            case Stasis.ASLEEP:
                eventPlayer.clearStatusEffect(Status.ASLEEP)
                break
            case Stasis.FROZEN:
                eventPlayer.clearStatusEffect(Status.FROZEN)
                break
    iconMessage(eventPlayer, iconString(Icon.BOLT), "Exited stasis!")


rule "— Enter / remain in stasis":
    @Event eachPlayer
    @Condition eventPlayer.isInModeratorStasis or eventPlayer.isInStasis

    do:
        switch eventPlayer.preferences[Preference.STASIS_MODE]:
            case Stasis.KNOCKED_DOWN:
                if not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, Math.INFINITY)
                break
            case Stasis.STUNNED:
                if not eventPlayer.hasStatusEffect(Status.STUNNED):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.STUNNED, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.STUNNED, Math.INFINITY)
                break
            case Stasis.ASLEEP:
                if not eventPlayer.hasStatusEffect(Status.ASLEEP):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.ASLEEP, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.ASLEEP, Math.INFINITY)
                break
            case Stasis.FROZEN:
                if not eventPlayer.hasStatusEffect(Status.FROZEN):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.FROZEN, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.FROZEN, Math.INFINITY)
                break
        wait(1)
    while RULE_CONDITION