rule "Special":
    @Disabled
    @Delimiter


rule "— Trampoline mode":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition eventPlayer.special_preferences[Special.TRAMPOLINE]
    @Condition eventPlayer.isOnGround()
    @Condition not eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.startForcingButton(Button.JUMP)
    wait()
    eventPlayer.stopForcingButton(Button.JUMP)
    # eventPlayer.applyImpulse(Vector.UP, 10, Relativity.TO_PLAYER, Impulse.INCORPORATE_CONTRARY_MOTION)
    wait(0.25)