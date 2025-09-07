#!mainFile "../main.opy"

rule "Dream":
    @Disabled
    @Delimiter


def DreamMode():
    @Name "— Dream mode"

    eventPlayer.previous_facing_direction = eventPlayer.getFacingDirection()
    eventPlayer.disableHeroHUD()
    UpdatePhase()
    waitUntil(eventPlayer.isHoldingButton(Button.JUMP) or isActive(), Math.INFINITY)
    eventPlayer.preferences[Preference.DREAM_MODE] = false
    eventPlayer.enableHeroHud()
    UpdatePhase()
    async(UpdateCamera, AsyncBehavior.RESTART)
    eventPlayer.focused_player = null


rule "— Switch spectated player":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.DREAM_MODE]

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
            not eventPlayer.preferences[Preference.DREAM_MODE]
            or not eventPlayer.focused_player.hasSpawned()
            or eventPlayer.focused_player.isInvisible,
            eventPlayer.preferences[Preference.SWITCH_TIMER]
        )
    while RULE_CONDITION


rule "— Dream on AFK":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.AFK_TIMER] > 0
    @Condition eventPlayer.preferences[Preference.AFK_TIMER] * 60 == eventPlayer.afk_timer

    if (
        eventPlayer.isInModeratorMode
        or eventPlayer.isUsingKeyboard
        or eventPlayer.preferences[Preference.DREAM_MODE]
        or eventPlayer.preferences[Preference.ULTIMATE_MODE] == UltimateMode.INFINITE
    ):
        return
    eventPlayer.preferences[Preference.DREAM_MODE] = true
    DreamMode()


rule "— Reset AFK timer":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.AFK_TIMER] > 0
    @Condition isActive()

    do:
        eventPlayer.afk_timer = 0
        eventPlayer.previous_facing_direction = eventPlayer.getFacingDirection()
        wait(1)
    while RULE_CONDITION


def UpdateAFKTimer():
    @Name "— Update AFK timer"

    if eventPlayer.preferences[Preference.AFK_TIMER] > 0:
        chase(
            eventPlayer.afk_timer,
            eventPlayer.preferences[Preference.AFK_TIMER] * 60,
            rate = 1,
            ChaseReeval.NONE
        )
        eventPlayer.previous_facing_direction = eventPlayer.getFacingDirection()
    else:
        stopChasingVariable(eventPlayer.afk_timer)
        eventPlayer.previous_facing_direction = null