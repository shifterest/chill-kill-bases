#!mainFile "../main.opy"

rule "Paralysis":
    @Disabled
    @Delimiter


rule "— Self-paralyze":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.SELF_PARALYSIS]
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.isViewingPreferences

    if eventPlayer.isParalyzed:
        Unparalyze()
    else:
        eventPlayer.isParalyzed = true
        iconMessage(eventPlayer, abilityIconString(Hero.ANA, Button.ABILITY_1), "paralyzed!")
    wait(1)


def Unparalyze():
    @Name "— Unparalyze"

    eventPlayer.isParalyzed = false
    if not eventPlayer.isParalyzedByModerator:
        switch eventPlayer.preferences[Preference.PARALYSIS_MODE]:
            case Paralysis.KNOCKED_DOWN:
                eventPlayer.clearStatusEffect(Status.KNOCKED_DOWN)
                break
            case Paralysis.STUNNED:
                eventPlayer.clearStatusEffect(Status.STUNNED)
                break
            case Paralysis.ASLEEP:
                eventPlayer.clearStatusEffect(Status.ASLEEP)
                break
            case Paralysis.FROZEN:
                eventPlayer.clearStatusEffect(Status.FROZEN)
                break
    iconMessage(eventPlayer, iconString(Icon.BOLT), "unparalyzed!")


rule "— Keep paralysis inflicted":
    @Event eachPlayer
    @Condition eventPlayer.isParalyzedByModerator or eventPlayer.isParalyzed

    do:
        switch eventPlayer.preferences[Preference.PARALYSIS_MODE]:
            case Paralysis.KNOCKED_DOWN:
                if not eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, Math.INFINITY)
                break
            case Paralysis.STUNNED:
                if not eventPlayer.hasStatusEffect(Status.STUNNED):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.STUNNED, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.STUNNED, Math.INFINITY)
                break
            case Paralysis.ASLEEP:
                if not eventPlayer.hasStatusEffect(Status.ASLEEP):
                    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
                        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
                        eventPlayer.setStatusEffect(null, Status.ASLEEP, Math.INFINITY)
                        UpdatePhase()
                    else:
                        eventPlayer.setStatusEffect(null, Status.ASLEEP, Math.INFINITY)
                break
            case Paralysis.FROZEN:
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