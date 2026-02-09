#!mainFile "../main.opy"

rule "Mount":
    @Disabled
    @Delimiter


rule "— Mount to player":
    @Event eachPlayer
    @Condition eventPlayer.settings[Setting.PLAYER_MODE]
    @Condition not eventPlayer.mount
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition eventPlayer.uiState == UIState.NORMAL
    @Condition eventPlayer.getRealPlayerClosestToReticle(Team.ALL).hasSpawned()
    @Condition not eventPlayer.getRealPlayerClosestToReticle(Team.ALL).rider
    @Condition eventPlayer.getRealPlayerClosestToReticle(Team.ALL) != eventPlayer.rider
    @Condition eventPlayer.getRealPlayerClosestToReticle(Team.ALL).settings[Setting.ALLOW_MOUNTING]
    @Condition isInMountingRange(eventPlayer)

    eventPlayer.mount = eventPlayer.getRealPlayerClosestToReticle(Team.ALL)
    eventPlayer.mount.rider = eventPlayer
    iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "mounted to {}".format(eventPlayer.mount))
    BuffExplosionSound()
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
        switch eventPlayer.settings[Setting.MOUNTING_MODE]:
            case MountingMode.STACK:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, distance(eventPlayer.rider.getPosition(), eventPlayer.rider.getEyePosition()), 0))
                break
            case MountingMode.INTERSECT:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, 0, 0))
                break
            case MountingMode.FRONT:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, 0, 1.5 * (eventPlayer.settings[Setting.SIZE] / 100) if eventPlayer.settings[Setting.PLAYER_MODE] else 1))
                break
            case MountingMode.BACK:
                eventPlayer.rider.attachTo(eventPlayer, vect(0, 0, -1.5 * (eventPlayer.settings[Setting.SIZE] / 100) if eventPlayer.settings[Setting.PLAYER_MODE] else 1))
                break
            case MountingMode.LEFT:
                eventPlayer.rider.attachTo(eventPlayer, vect(1.5 * (eventPlayer.settings[Setting.SIZE] / 100) if eventPlayer.settings[Setting.PLAYER_MODE] else 1, 0, 0))
                break
            case MountingMode.RIGHT:
                eventPlayer.rider.attachTo(eventPlayer, vect(-1.5 * (eventPlayer.settings[Setting.SIZE] / 100) if eventPlayer.settings[Setting.PLAYER_MODE] else 1, 0, 0))
                break


rule "— Manually eject from mount":
    @Event eachPlayer
    @Condition eventPlayer.mount
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1) and eventPlayer.isHoldingButton(Button.INTERACT)

    EjectFromMount()


def EjectFromMount():
    @Name "— Eject from mount"

    iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "ejected from {}".format(eventPlayer.mount))
    wait(0.1)
    eventPlayer.mount.rider = null
    eventPlayer.mount = null
    eventPlayer.detach()
    DebuffImpactSound()


rule "— Eject from mount on kill mode / mount disconnect":
    @Event eachPlayer
    @Condition eventPlayer.mount
    @Condition (
        not eventPlayer.settings[Setting.PLAYER_MODE]
        or not eventPlayer.mount in getAllPlayers()
    )

    eventPlayer.mount = null


rule "— Manually eject rider":
    @Event eachPlayer
    @Condition eventPlayer.rider
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    EjectRider()


def EjectRider():
    @Name "— Eject rider"

    iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "ejected {}".format(eventPlayer.rider))
    wait(0.1)
    eventPlayer.rider.detach()
    if eventPlayer.settings[Setting.ALLOW_MOUNTING]:
        eventPlayer.rider.applyImpulse(
            eventPlayer.getFacingDirection(),
            25,
            Relativity.TO_WORLD,
            Impulse.CANCEL_CONTRARY_MOTION_XYZ
        )
    eventPlayer.rider.mount = null
    eventPlayer.rider = null
    DebuffImpactSound()


rule "— Eject rider on rider disconnect":
    @Event eachPlayer
    @Condition eventPlayer.rider
    @Condition not eventPlayer.rider in getAllPlayers()

    eventPlayer.rider = null