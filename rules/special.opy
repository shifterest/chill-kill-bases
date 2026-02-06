#!mainFile "../main.opy"

rule "Special":
    @Disabled
    @Delimiter


rule "— Trampoline mode":
    @Event eachPlayer
    @Condition pref(Preference.PLAYER_MODE)
    @Condition pref(Preference.TRAMPOLINE)
    @Condition eventPlayer.isOnGround()
    @Condition not eventPlayer.isHoldingButton(Button.CROUCH)

    do:
        eventPlayer.applyImpulse(Vector.UP, 10, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
        wait(0.25)
    while RULE_CONDITION