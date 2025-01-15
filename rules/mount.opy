rule "Mount":
    @Disabled
    @Delimiter


rule "— Mount to player":
    @Event eachPlayer
    @Condition eventPlayer.main_preferences[Main.PLAYER_MODE]
    @Condition not eventPlayer.mount
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition eventPlayer.getPlayerClosestToReticle(Team.ALL).hasSpawned()
    @Condition not eventPlayer.getPlayerClosestToReticle(Team.ALL).rider
    @Condition eventPlayer.getPlayerClosestToReticle(Team.ALL) != eventPlayer.rider
    @Condition eventPlayer.getPlayerClosestToReticle(Team.ALL).special_preferences[Special.ALLOW_MOUNTING]
    @Condition isInMountingRange(eventPlayer)

    eventPlayer.mount = eventPlayer.getPlayerClosestToReticle(Team.ALL)
    eventPlayer.mount.rider = eventPlayer
    iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "mounted to {}".format(eventPlayer.mount))
    BuffPlayer()
    wait(1)


rule "— Keep player mounted":
    @Event eachPlayer
    @Condition eventPlayer.rider

    do:
        UpdateRider()
        wait(1)
    while RULE_CONDITION


def UpdateRider():
    @Name "— Update mounted player"

    if eventPlayer.rider:
        switch eventPlayer.special_preferences[Special.MOUNTING_MODE]:
            case MountingMode.STACK:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, distance(eventPlayer.rider.getPosition(), eventPlayer.rider.getEyePosition()), 0))
                break
            case MountingMode.INTERSECT:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, 0, 0))
                break
            case MountingMode.FRONT:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, 0, 1.5 * (eventPlayer.hero_preferences[Hero.SIZE] / 100) if eventPlayer.main_preferences[Main.PLAYER_MODE] else 1))
                break
            case MountingMode.BACK:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, 0, -1.5 * (eventPlayer.hero_preferences[Hero.SIZE] / 100) if eventPlayer.main_preferences[Main.PLAYER_MODE] else 1))
                break
            case MountingMode.LEFT:
                eventPlayer.rider.attachTo(eventPlayer, vect(1.5 * (eventPlayer.hero_preferences[Hero.SIZE] / 100) if eventPlayer.main_preferences[Main.PLAYER_MODE] else 1, 0, 0))
                break
            case MountingMode.RIGHT:
                eventPlayer.rider.attachTo(eventPlayer, vect(-1.5 * (eventPlayer.hero_preferences[Hero.SIZE] / 100) if eventPlayer.main_preferences[Main.PLAYER_MODE] else 1, 0, 0))
                break


rule "— Unmount":
    @Event eachPlayer
    @Condition eventPlayer.mount
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.INTERACT)

    Unmount()


def Unmount():
    @Name "— Unmount (subroutine)"

    iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "unmounted from {}".format(eventPlayer.mount))
    wait(0.1)
    eventPlayer.mount.rider = null
    eventPlayer.mount = null
    eventPlayer.detach()
    BuffPlayer()


rule "— Unmount on kill mode / mount disconnect":
    @Event eachPlayer
    @Condition eventPlayer.mount
    @Condition (
        not eventPlayer.main_preferences[Main.PLAYER_MODE]
        or not eventPlayer.mount in getAllPlayers()
    )

    eventPlayer.mount = null


rule "— Unmount player":
    @Event eachPlayer
    @Condition eventPlayer.rider
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    UnmountPlayer()


def UnmountPlayer():
    @Name "— Unmount player (subroutine)"

    iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "unmounted {}".format(eventPlayer.rider))
    wait(0.1)
    eventPlayer.rider.detach()
    if eventPlayer.special_preferences[Special.ALLOW_MOUNTING]:
        eventPlayer.rider.applyImpulse(
            eventPlayer.getFacingDirection(),
            25,
            Relativity.TO_WORLD,
            Impulse.CANCEL_CONTRARY_MOTION_XYZ
        )
    eventPlayer.rider.mount = null
    eventPlayer.rider = null
    BuffPlayer()


rule "— Unmount player on player disconnect":
    @Event eachPlayer
    @Condition eventPlayer.rider
    @Condition not eventPlayer.rider in getAllPlayers()

    eventPlayer.rider = null