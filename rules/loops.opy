rule "Loops":
    @Disabled
    @Delimiter


rule "— Transition rainbow color":
    @Condition isGameInProgress()

    # based on u/Halex000's RGB rainbow cycling HUD text (code CZ97D)
    chase(rainbow_green, 255, duration = 1, ChaseReeval.NONE)
    wait(1)
    stopChasingVariable(rainbow_green)

    chase(rainbow_blue, 0, duration = 1, ChaseReeval.NONE)
    wait(1)
    stopChasingVariable(rainbow_blue)

    chase(rainbow_red, 255, duration = 1, ChaseReeval.NONE)
    wait(1)
    stopChasingVariable(rainbow_red)

    chase(rainbow_green, 0, duration = 1, ChaseReeval.NONE)
    wait(1)
    stopChasingVariable(rainbow_green)

    chase(rainbow_blue, 255, duration = 1, ChaseReeval.NONE)
    wait(1)
    stopChasingVariable(rainbow_blue)

    chase(rainbow_red, 0, duration = 1, ChaseReeval.NONE)
    wait(1)
    stopChasingVariable(rainbow_red)

    goto RULE_START


rule "— Rainbow hero outline":
    @Event eachPlayer
    @Condition eventPlayer.hero_preferences[Hero.OUTLINE_COLOR] == Colors.RAINBOW

    do:
        updateHeroOutline()
        wait (0.3)
    while RULE_CONDITION


rule "— Chill mode hint":
    @Event eachPlayer
    @Condition not eventPlayer.has_created_base_once
    @Condition not eventPlayer.main_preferences[Main.PLAYER_MODE]

    do:
        wait(60, Wait.ABORT_WHEN_FALSE)
        bigMessage(eventPlayer, "create a base to access other features!")
    while RULE_CONDITION