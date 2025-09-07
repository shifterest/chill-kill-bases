#!mainFile "../main.opy"

rule "Abilities":
    @Disabled
    @Delimiter


rule "— Ability mode • No cooldown":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]

    do:
        resetCooldown(Button.PRIMARY_FIRE)
        resetCooldown(Button.SECONDARY_FIRE)
        resetCooldown(Button.ABILITY_1)
        resetCooldown(Button.ABILITY_2)
        resetCooldown(Button.CROUCH)
        # resetCooldown(Button.INTERACT)
        resetCooldown(Button.JUMP)

        switch eventPlayer.getCurrentHero():
            case Hero.TRACER:
            case Hero.JUNKRAT:
                if eventPlayer.getAbilityCharge(Button.ABILITY_1) < 2:
                    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)
                break
            case Hero.BRIGITTE:
                if eventPlayer.getAbilityCharge(Button.ABILITY_2) < 2:
                    eventPlayer.setAbilityCharge(Button.ABILITY_2, 2)
                break
            case Hero.ROADHOG:
                if eventPlayer.getAbilityResource(Button.ABILITY_2) < 50:
                    eventPlayer.setAbilityResource(Button.ABILITY_2, 100)
                break
            case Hero.DVA:
                if eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) < 50:
                    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 100)
                break

        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Primary fire (Brigitte)":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
    @Condition eventPlayer.getCurrentHero() == Hero.BRIGITTE
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
        wait()
        eventPlayer.forceButtonPress(Button.PRIMARY_FIRE)
        wait()
        eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
        wait(eventPlayer.preferences[Preference.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION





rule "— Ability mode • Hold to spam • Secondary fire":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
    @Condition not (
        eventPlayer.getCurrentHero() == Hero.REINHARDT
        or eventPlayer.getCurrentHero() == Hero.BRIGITTE
    )
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        wait()
        eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
        wait()
        eventPlayer.stopForcingButton(Button.SECONDARY_FIRE)
        wait(eventPlayer.preferences[Preference.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Ability 1":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
        wait()
        eventPlayer.forceButtonPress(Button.ABILITY_1)
        wait()
        eventPlayer.stopForcingButton(Button.ABILITY_1)
        wait(eventPlayer.preferences[Preference.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Ability 2":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
        if eventPlayer.getCurrentHero() == Hero.MOIRA:
            waitUntil(eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), Math.INFINITY)
        wait()
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        wait()
        eventPlayer.stopForcingButton(Button.ABILITY_2)
        wait(eventPlayer.preferences[Preference.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ammo overload":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]

    do:
        switch eventPlayer.getCurrentHero():
            case Hero.ORISA:
                eventPlayer.setAmmo(0, 100)
                break
            case Hero.MOIRA:
                if eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 50:
                    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)
                break
            case Hero.ILLARI:
                if eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) > 50:
                    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 0)
                break
            default:
                if eventPlayer.getAmmo(0) <= 50:
                    eventPlayer.setAmmo(0, 1000)
                if eventPlayer.getAmmo(1) <= 50:
                    eventPlayer.setAmmo(1, 1000)
                break
        wait(1, Wait.ABORT_WHEN_FALSE)
    while RULE_CONDITION


rule "— Ultimate mode • No cooldown":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ULTIMATE_MODE]
    @Condition eventPlayer.preferences[Preference.ULTIMATE_MODE] != UltimateMode.HOLD_TO_SPAM
    @Condition eventPlayer.getUltCharge() < 100

    do:
        eventPlayer.setUltCharge(100)
        waitLoad()
    while RULE_CONDITION


rule "— Ultimate mode • Infinite":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.INFINITE
    @Condition not eventPlayer.isUsingUltimate()
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        switch eventPlayer.getCurrentHero():
            case Hero.WINSTON:
                while eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.INFINITE:
                    eventPlayer.setUltCharge(100)
                    eventPlayer.forceButtonPress(Button.ULTIMATE)
                    wait(5)
                break
            default:
                eventPlayer.setUltCharge(100)
                eventPlayer.forceButtonPress(Button.ULTIMATE)
                waitLoad()
                waitUntil(
                    not eventPlayer.preferences[Preference.PLAYER_MODE]
                    or eventPlayer.preferences[Preference.ULTIMATE_MODE] != UltimateMode.INFINITE
                    or not eventPlayer.isUsingUltimate(),
                    Math.INFINITY
                )
                break
    while RULE_CONDITION


rule "— Ultimate mode • Hold to spam":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.HOLD_TO_SPAM
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setUltCharge(100)
        wait()
        eventPlayer.forceButtonPress(Button.ULTIMATE)
        wait()
        eventPlayer.stopForcingButton(Button.ULTIMATE)
        wait(eventPlayer.preferences[Preference.ULTIMATE_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION