#!mainFile "../main.opy"

rule "Loops":
    @Disabled
    @Delimiter


rule "— Transition rainbow color":
    @Condition isGameInProgress()

    # Simplified HSL-based rainbow cycling
    do:
        chase(rainbow_hue, 360, duration = 6, ChaseReeval.NONE)
        wait(6)
        rainbow_hue = 0
    while RULE_CONDITION


rule "— Rainbow hero outline":
    @Event eachPlayer
    @Condition eventPlayer.settings[Setting.OUTLINE_COLOR] == ExtendedColor.RAINBOW

    do:
        updateHeroOutline()
        wait(0.3)
    while RULE_CONDITION


rule "— Chill mode hint":
    @Event eachPlayer
    @Condition not eventPlayer.has_created_base_once
    @Condition not eventPlayer.settings[Setting.PLAYER_MODE]

    do:
        wait(60, Wait.ABORT_WHEN_FALSE)
        bigMessage(eventPlayer, "create a base to access other features!")
    while RULE_CONDITION