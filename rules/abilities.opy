#!mainFile "../main.opy"

rule "Abilities":
    @Disabled
    @Delimiter


rule "— Ability mode • No cooldown • Primary fire":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.PRIMARY_FIRE) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Primary fire (Moira)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getCurrentHero() == Hero.MOIRA
    @Condition eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)


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


rule "— Ability mode • No cooldown • Secondary fire":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.NO_COOLDOWN
    @Condition eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) > 0 or (
        eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) == 0 and eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    )

    do:
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        waitLoad()
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


rule "— Ability mode • No cooldown • Secondary fire (Illari)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getCurrentHero() == Hero.ILLARI
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) > 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 0)


rule "— Ability mode • No cooldown • Ability 1":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.NO_COOLDOWN
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0 or (
        eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0 and eventPlayer.isHoldingButton(Button.ABILITY_1)
    )

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
        waitLoad()
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


rule "— Ability mode • No cooldown • Ability 1 (Tracer, Junkrat)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getCurrentHero() == Hero.TRACER or eventPlayer.getCurrentHero() == Hero.JUNKRAT
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)


rule "— Ability mode • No cooldown • Ability 2":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.NO_COOLDOWN
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0 or (
        eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0 and eventPlayer.isHoldingButton(Button.ABILITY_2)
    )

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
        waitLoad()
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


rule "— Ability mode • No cooldown • Ability 2 (Brigitte)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getCurrentHero() == Hero.BRIGITTE
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_2) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_2, 2)


rule "— Ability mode • No cooldown • Crouch":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.CROUCH) > 0 or (
        eventPlayer.getAbilityCooldown(Button.CROUCH) == 0 and eventPlayer.isHoldingButton(Button.CROUCH)
    )

    do:
        eventPlayer.setAbilityCooldown(Button.CROUCH, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Interact":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.INTERACT) > 0 or (
        eventPlayer.getAbilityCooldown(Button.INTERACT) == 0 and eventPlayer.isHoldingButton(Button.INTERACT)
    )

    do:
        eventPlayer.setAbilityCooldown(Button.INTERACT, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Jump":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE]
    @Condition eventPlayer.isHoldingButton(Button.JUMP) or (
        eventPlayer.getAbilityCooldown(Button.JUMP) == 0 and eventPlayer.isHoldingButton(Button.JUMP)
    )

    do:
        eventPlayer.setAbilityCooldown(Button.JUMP, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Jump (Hanzo, Lifeweaver)":
    @Disabled
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
    @Condition eventPlayer.getCurrentHero() == Hero.HANZO or eventPlayer.getCurrentHero() == Hero.LIFEWEAVER
    @Condition eventPlayer.isHoldingButton(Button.JUMP)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setAbilityCooldown(Button.JUMP, 0)
        wait()
        eventPlayer.forceButtonPress(Button.JUMP)
        wait()
        eventPlayer.stopForcingButton(Button.JUMP)
        wait(eventPlayer.preferences[Preference.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ammo overload (clip 0)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]
    @Condition eventPlayer.getAmmo(0) <= 50

    eventPlayer.setAmmo(0, 1000)


rule "— Ammo overload (clip 1)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]
    @Condition eventPlayer.getAmmo(1) <= 50

    eventPlayer.setAmmo(1, 1000)


rule "— Ammo overload (Orisa)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.ORISA

    do:
        eventPlayer.setAmmo(0, 100)
        wait(3)
    while RULE_CONDITION


rule "— Ammo overload (D.Va)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.DVA
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 100)


rule "— Ammo overload (Moira)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.MOIRA
    @Condition eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)


rule "— Ammo overload (Illari)":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.ILLARI
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) > 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 0)


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
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.INFINITE
    @Condition not eventPlayer.isUsingUltimate()

    do:
        switch eventPlayer.getCurrentHero():
            case Hero.WINSTON:
                eventPlayer.setUltCharge(100)
                eventPlayer.forceButtonPress(Button.ULTIMATE)
                wait(5)
                if eventPlayer.preferences[Preference.PLAYER_MODE] and eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.INFINITE:
                    goto RULE_START
                break
            default:
                eventPlayer.setUltCharge(100)
                eventPlayer.forceButtonPress(Button.ULTIMATE)
                waitLoad()
                waitUntil(
                    not eventPlayer.preferences[Preference.PLAYER_MODE]
                    or not eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.INFINITE
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