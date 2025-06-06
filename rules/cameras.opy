#!mainFile "../main.opy"

rule "Cameras":
    @Disabled
    @Delimiter


rule "— ADS in third-person":
    @Event eachPlayer
    @Condition not optimize
    @Condition eventPlayer.preferences[Preference.THIRD_PERSON]
    @Condition (
        eventPlayer.getCurrentHero() == Hero.ANA
        or eventPlayer.getCurrentHero() == Hero.ASHE
        or eventPlayer.getCurrentHero() == Hero.WIDOWMAKER
        or eventPlayer.getCurrentHero() == Hero.FREJA
    )
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.isViewingPreferences
        or eventPlayer.isInModeratorMode
        or eventPlayer.isDead(),
        Math.INFINITY
    )

    if not eventPlayer.isInModeratorMode:
        async(UpdateCamera, AsyncBehavior.RESTART)


rule "— Ultimate in third-person":
    @Event eachPlayer
    @Condition not optimize
    @Condition eventPlayer.preferences[Preference.THIRD_PERSON]
    @Condition (
        eventPlayer.getCurrentHero() == Hero.BASTION
        or eventPlayer.getCurrentHero() == Hero.JUNKRAT
    )
    @Condition eventPlayer.isUsingUltimate()
    @Condition not eventPlayer.isViewingPreferences
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isUsingUltimate()
        or eventPlayer.isViewingPreferences
        or eventPlayer.isInModeratorMode
        or eventPlayer.isDead(),
        Math.INFINITY
    )

    if not eventPlayer.isInModeratorMode:
        async(UpdateCamera, AsyncBehavior.RESTART)


def UpdateCamera():
    @Name "— Reset camera"

    if eventPlayer.isInBaseCreationMode:
        BaseCreationCamera()
    elif eventPlayer.preferences[Preference.THIRD_PERSON]:
        ThirdPersonCamera()
    else:
        StopCamera()

    async(UpdateAura, AsyncBehavior.RESTART)


def BaseCreationCamera():
    @Name "— Enable base creation camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        eventPlayer.getEyePosition(), 
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        1
    )
    wait()
    eventPlayer.startCamera(
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + (
                Vector.UP + eventPlayer.getFacingDirection() * eventPlayer.preferences[Preference.BASE_SIZE] * -1.5
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        30
    )


def ThirdPersonCamera():
    @Name "— Enable third-person camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        eventPlayer.getEyePosition(), 
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        1
    )
    wait()
    eventPlayer.startCamera(
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + (
                Vector.UP * (eventPlayer.preferences[Preference.SIZE] / 100) + eventPlayer.getFacingDirection()
                * (eventPlayer.preferences[Preference.SIZE] / -40) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                if eventPlayer.preferences[Preference.PLAYER_MODE]
                else Vector.UP + eventPlayer.getFacingDirection() * -2.5 * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        30
    )

def ThirdPersonSpectatorCamera():
    @Name "— Enable third-person spectator camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        eventPlayer.getEyePosition(), 
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        1
    )
    wait()
    eventPlayer.startCamera(
        raycast(
            eventPlayer.focused_player.getEyePosition(),
            eventPlayer.focused_player.getEyePosition()
            + (
                Vector.UP * (eventPlayer.focused_player.preferences[Preference.SIZE] / 100) + eventPlayer.focused_player.getFacingDirection()
                * (eventPlayer.focused_player.preferences[Preference.SIZE] / -40) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE]
                else Vector.UP + eventPlayer.focused_player.getFacingDirection() * -2.5 * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
            ),
            null,
            eventPlayer.focused_player,
            false
        ).getHitPosition(),
        raycast(
            eventPlayer.focused_player.getEyePosition(),
            eventPlayer.focused_player.getEyePosition() + eventPlayer.focused_player.getFacingDirection() * 100,
            null,
            eventPlayer.focused_player,
            false
        ).getHitPosition(),
        30
    )


def DreamCamera():
    @Name "— Enable dream camera"

    eventPlayer.startCamera(
        eventPlayer.getEyePosition(), 
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        1
    )
    wait()
    if eventPlayer.preferences[Preference.CLIP_CAMERA]:
        eventPlayer.startCamera(
            raycast(
                eventPlayer.focused_player.getEyePosition(),
                eventPlayer.focused_player.getEyePosition() + (
                    Vector.UP * (eventPlayer.focused_player.preferences[Preference.SIZE] / 100) + eventPlayer.focused_player.getFacingDirection() * (eventPlayer.focused_player.preferences[Preference.SIZE] / -20)
                ),
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            eventPlayer.focused_player.getEyePosition(),
            5
        )
    else:
        eventPlayer.startCamera(
            eventPlayer.focused_player.getEyePosition() + (
                Vector.UP * (eventPlayer.focused_player.preferences[Preference.SIZE] / 100) + eventPlayer.focused_player.getFacingDirection() * (eventPlayer.focused_player.preferences[Preference.SIZE] / -20)
            ),
            eventPlayer.focused_player.getEyePosition(),
            5
        )


def StopCamera():
    @Name "— Stop camera"

    eventPlayer.startCamera(
        eventPlayer.getEyePosition(), 
        raycast(
            eventPlayer.getEyePosition(),
            eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        30
    )
    wait(0.2)
    eventPlayer.stopCamera()