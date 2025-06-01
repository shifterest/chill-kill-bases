#!mainFile "../main.opy"

rule "Dream":
    @Disabled
    @Delimiter


def DreamMode():
    @Name "— Dream mode"

    eventPlayer.previous_facing_direction = eventPlayer.getFacingDirection()
    eventPlayer.disableHeroHUD()
    UpdatePhase()
    DreamCamera()

    waitUntil(eventPlayer.isHoldingButton(Button.JUMP) or isActive(), 99999)

    eventPlayer.dream_preferences[Dream.DREAM_MODE] = false
    eventPlayer.enableHeroHud()
    UpdatePhase()
    async(UpdateCamera, AsyncBehavior.RESTART)
    eventPlayer.focused_player = null


rule "— Dream on AFK":
    @Event eachPlayer
    @Condition eventPlayer.dream_preferences[Dream.AFK_TIMER] > 0
    @Condition eventPlayer.dream_preferences[Dream.AFK_TIMER] * 60 == eventPlayer.afk_timer

    if (
        eventPlayer.isInModeratorMode
        or eventPlayer.isUsingKeyboard
        or eventPlayer.dream_preferences[Dream.DREAM_MODE]
        or eventPlayer.special_preferences[Special.ULTIMATE_MODE] == UltimateMode.INFINITE
    ):
        return

    eventPlayer.dream_preferences[Dream.DREAM_MODE] = true
    DreamMode()


rule "— Switch spectated player":
    @Event eachPlayer
    @Condition eventPlayer.dream_preferences[Dream.DREAM_MODE]

    do:
        eventPlayer.focused_player = random.choice(
            [
                p
                for p in getAllPlayers()
                if p.hasSpawned()
                and p != eventPlayer.focused_player
                and p != eventPlayer
                and not p.isInvisible
            ]
        )

        if not eventPlayer.focused_player:
            eventPlayer.focused_player = eventPlayer

        waitUntil(
            not eventPlayer.dream_preferences[Dream.DREAM_MODE]
            or not eventPlayer.focused_player.hasSpawned()
            or eventPlayer.focused_player.isInvisible,
            eventPlayer.dream_preferences[Dream.SWITCH_TIMER]
        )
    while RULE_CONDITION


rule "— Reset AFK timer":
    @Event eachPlayer
    @Condition eventPlayer.dream_preferences[Dream.AFK_TIMER] > 0
    @Condition isActive()

    do:
        eventPlayer.afk_timer = 0
        eventPlayer.previous_facing_direction = eventPlayer.getFacingDirection()
        wait(1)
    while RULE_CONDITION


def UpdateAFKTimer():
    @Name "— Update AFK timer"

    if eventPlayer.dream_preferences[Dream.AFK_TIMER] > 0:
        chase(
            eventPlayer.afk_timer,
            eventPlayer.dream_preferences[Dream.AFK_TIMER] * 60,
            rate = 1,
            ChaseReeval.NONE
        )
        eventPlayer.previous_facing_direction = eventPlayer.getFacingDirection()
    else:
        stopChasingVariable(eventPlayer.afk_timer)
        eventPlayer.previous_facing_direction = null