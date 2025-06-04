#!mainFile "../main.opy"

rule "Special":
    @Disabled
    @Delimiter


rule "— Trampoline mode":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.PLAYER_MODE]
    @Condition eventPlayer.preferences[Preference.TRAMPOLINE]
    @Condition eventPlayer.isOnGround()
    @Condition not eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.startForcingButton(Button.JUMP)
    wait()
    eventPlayer.stopForcingButton(Button.JUMP)
    # eventPlayer.applyImpulse(Vector.UP, 10, Relativity.TO_PLAYER, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)