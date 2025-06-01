#!mainFile "../main.opy"

rule "Abilities":
    @Disabled
    @Delimiter


rule "— Ability mode • No cooldown • Primary fire":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.PRIMARY_FIRE) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Recharge primary fire (Moira)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition eventPlayer.getCurrentHero() == Hero.MOIRA
    @Condition eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)


rule "— Ability mode • Hold to spam • Primary fire (Brigitte)":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
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
        wait(eventPlayer.special_preferences[Special.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Reset secondary fire CD":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.NO_COOLDOWN
    @Condition eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)
        if optimize:
            wait(0.5)
        else:
            waitLoad()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Secondary fire (not Reinhardt, Brigitte)":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
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
        wait(eventPlayer.special_preferences[Special.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Recharge secondary fire (Illari)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition eventPlayer.getCurrentHero() == Hero.ILLARI
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) > 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 0)


rule "— Ability mode • No cooldown • Ability 1":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.NO_COOLDOWN
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Ability 1":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
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
        wait(eventPlayer.special_preferences[Special.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Recharge ability 1 (Tracer, Symmetrax)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition (
        eventPlayer.getCurrentHero() == Hero.TRACER
        or eventPlayer.getCurrentHero() == Hero.SYMMETRA
    )
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 3

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)


rule "— Ability mode • No cooldown • Recharge ability 1 (Zarya, Junkrat, Freja)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition (
        eventPlayer.getCurrentHero() == Hero.ZARYA
        or eventPlayer.getCurrentHero() == Hero.JUNKRAT
        or eventPlayer.getCurrentHero() == Hero.FREJA
    )
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 2)


rule "— Ability mode • No cooldown • Ability 2":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.NO_COOLDOWN
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Ability 2":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard

    do:
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)
        if eventPlayer.getCurrentHero() == Hero.MOIRA:
            waitUntil(eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE), 99999)
        wait()
        eventPlayer.forceButtonPress(Button.ABILITY_2)
        wait()
        eventPlayer.stopForcingButton(Button.ABILITY_2)
        wait(eventPlayer.special_preferences[Special.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Recharge ability 2 (Zarya, Reinhardt, Brigitte)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition (
        eventPlayer.getCurrentHero() == Hero.ZARYA
        or eventPlayer.getCurrentHero() == Hero.REINHARDT
        or eventPlayer.getCurrentHero() == Hero.BRIGITTE
    )
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_2) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_2, 2)


rule "— Ability mode • No cooldown • Crouch":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.CROUCH) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.CROUCH, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Interact":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.INTERACT) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.INTERACT, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • No cooldown • Jump":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE]
    @Condition eventPlayer.getAbilityCooldown(Button.JUMP) > 0

    do:
        eventPlayer.setAbilityCooldown(Button.JUMP, 0)
        waitLoad()
    while RULE_CONDITION


rule "— Ability mode • Hold to spam • Jump (Hanzo, Lifeweaver)":
    @Disabled
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ABILITY_MODE] == AbilityMode.HOLD_TO_SPAM
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
        wait(eventPlayer.special_preferences[Special.ABILITY_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION


rule "— Ammo overload (clip 0)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition eventPlayer.getAmmo(0) <= 50

    eventPlayer.setAmmo(0, 1000)


rule "— Ammo overload (clip 1)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition eventPlayer.getAmmo(1) <= 50

    eventPlayer.setAmmo(1, 1000)


rule "— Ammo overload (Orisa)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.ORISA

    do:
        eventPlayer.setAmmo(0, 100)
        wait(3)
    while RULE_CONDITION


rule "— Ammo overload (D.Va, Hazard)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition (
        eventPlayer.getCurrentHero() == Hero.DVA
        or eventPlayer.getCurrentHero() == Hero.HAZARD
    )
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 100)


rule "— Ammo overload (Moira)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.MOIRA
    @Condition eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)


rule "— Ammo overload (Illari)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.ILLARI
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) > 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 0)

rule "— Ammo overload (Freja)":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.AMMO_OVERLOAD]
    @Condition eventPlayer.getCurrentHero() == Hero.FREJA
    @Condition eventPlayer.getAmmo(1) == 0

    eventPlayer.setAmmo(1, 1000)

rule "— Ultimate mode • No cooldown":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ULTIMATE_MODE]
    @Condition eventPlayer.special_preferences[Special.ULTIMATE_MODE] != UltimateMode.HOLD_TO_SPAM
    @Condition eventPlayer.getUltCharge() < 100

    do:
        eventPlayer.setUltCharge(100)
        waitLoad()
    while RULE_CONDITION


rule "— Ultimate mode • Infinite":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ULTIMATE_MODE] == UltimateMode.INFINITE
    @Condition not eventPlayer.isUsingUltimate()

    do:
        switch eventPlayer.getCurrentHero():
            case Hero.WINSTON:
                eventPlayer.setUltCharge(100)
                eventPlayer.forceButtonPress(Button.ULTIMATE)
                wait(5)
                if eventPlayer.main_preferences[Main.PLAYER_MODE] and eventPlayer.special_preferences[Special.ULTIMATE_MODE] == UltimateMode.INFINITE:
                    goto RULE_START
                break
            default:
                eventPlayer.setUltCharge(100)
                eventPlayer.forceButtonPress(Button.ULTIMATE)
                waitLoad()
                waitUntil(
                    not eventPlayer.main_preferences[Main.PLAYER_MODE]
                    or not eventPlayer.special_preferences[Special.ULTIMATE_MODE] == UltimateMode.INFINITE
                    or not eventPlayer.isUsingUltimate(),
                    99999
                )
                break
    while RULE_CONDITION


rule "— Ultimate mode • Hold to spam":
    @Event eachPlayer
    @Condition not optimize
    @Condition not isOverloaded
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.ULTIMATE_MODE] == UltimateMode.HOLD_TO_SPAM
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
        wait(eventPlayer.special_preferences[Special.ULTIMATE_SPAM_DELAY])
        eventPlayer.cancelPrimaryAction()
        wait()
    while RULE_CONDITION