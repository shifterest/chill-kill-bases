#!mainFile "../main.opy"

rule "Player":
    @Disabled
    @Delimiter


rule "— Player joined":
    @Event playerJoined

    async(UpdateGodModList, AsyncBehavior.RESTART)
    async(UpdateModeratorListHUD, AsyncBehavior.RESTART)


rule "— Ban player comms":
    @Event eachPlayer
    @Condition f"{eventPlayer}" in comms_ban_usernames

    eventPlayer.disableTextChat()
    eventPlayer.disableVoiceChat(true, true, true)


rule "— Kick banned player":
    @Event eachPlayer
    @Condition f"{eventPlayer}" in ban_usernames

    removeFromGame(eventPlayer)


rule "— Player spawned":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()

    ReturnImmediately()
    if s(Setting.PLAYER_MODE) and s(Setting.AMMO_OVERLOAD):
        UpdateAmmo()


rule "— Player died":
    @Event playerDied

    eventPlayer.current_base_owner = null
    eventPlayer.active_base_owner = null

    if eventPlayer.death_throttle > 6:
        bigMessage(eventPlayer, "Your base probably wasn't supposed to be there.")
        RemoveBase()
    if eventPlayer.base_vector and s(Setting.INSTANT_RESPAWN):
        eventPlayer.death_throttle += 1
        eventPlayer.respawn()

    waitUntil(eventPlayer.isAlive(), Math.INFINITY)

    if eventPlayer.base_vector:
        wait(0.1)
        eventPlayer.teleport(eventPlayer.base_vector)
        eventPlayer.activate_base_now = true


rule "— Player left":
    @Event playerLeft

    async(UpdateGodModList, AsyncBehavior.RESTART)
    async(UpdateModeratorListHUD, AsyncBehavior.RESTART)


def ReturnImmediately():
    @Name "— Return immediately"

    if eventPlayer.base_vector:
        wait(0.1)
        if eventPlayer.last_transform:
            eventPlayer.teleport(eventPlayer.last_transform[0])
            restoreTransform()
            eventPlayer.last_transform = null
        else:
            eventPlayer.teleport(eventPlayer.base_vector)
        eventPlayer.activate_base_now = true
        eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
        wait(0.5)
        eventPlayer.stopForcingPosition()