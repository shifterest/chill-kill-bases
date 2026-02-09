#!mainFile "../main.opy"

rule "Dream":
    @Disabled
    @Delimiter


def DreamMode():
    @Name "— Dream mode"

    eventPlayer.uiState = UIState.DREAM_MODE
    eventPlayer.last_facing_dir = eventPlayer.getFacingDirection()
    eventPlayer.disableHeroHUD()
    UpdatePhase()
    waitUntil(eventPlayer.isHoldingButton(Button.JUMP) or isActive(), Math.INFINITY)
    eventPlayer.uiState = UIState.NORMAL
    s(Setting.DREAM_MODE) = false
    eventPlayer.enableHeroHud()
    UpdatePhase()
    async(UpdateCamera, AsyncBehavior.RESTART)
    eventPlayer.focused_player = null


rule "— Switch spectated player":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.DREAM_MODE

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
        DreamCamera()
        waitUntil(
            eventPlayer.uiState != UIState.DREAM_MODE
            or not eventPlayer.focused_player.hasSpawned()
            or eventPlayer.focused_player.isInvisible,
            s(Setting.SWITCH_TIMER)
        )
    while RULE_CONDITION


rule "— Dream on AFK":
    @Event eachPlayer
    @Condition s(Setting.AFK_TIMER) > 0
    @Condition s(Setting.AFK_TIMER) * 60 == eventPlayer.afk_timer

    if (
        eventPlayer.uiState != UIState.NORMAL
        or s(Setting.ULTIMATE_MODE) == UltimateMode.INFINITE
    ):
        return
    DreamMode()


rule "— Reset AFK timer":
    @Event eachPlayer
    @Condition s(Setting.AFK_TIMER) > 0
    @Condition isActive()

    do:
        eventPlayer.afk_timer = 0
        eventPlayer.last_facing_dir = eventPlayer.getFacingDirection()
        wait(1)
    while RULE_CONDITION


def UpdateAFKTimer():
    @Name "— Update AFK timer"

    if s(Setting.AFK_TIMER) > 0:
        chase(
            eventPlayer.afk_timer,
            s(Setting.AFK_TIMER) * 60,
            rate = 1,
            ChaseReeval.NONE
        )
        eventPlayer.last_facing_dir = eventPlayer.getFacingDirection()
    else:
        stopChasingVariable(eventPlayer.afk_timer)
        eventPlayer.last_facing_dir = null