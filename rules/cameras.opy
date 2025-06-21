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


rule "— Switch shoulder":
    @Event eachPlayer
    @Condition eventPlayer.preferences[Preference.THIRD_PERSON] == ThirdPersonCamera.REAR
    @Condition eventPlayer.preferences[Preference.THIRD_PERSON_OFFSET] != 0
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]
    @Condition not eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    eventPlayer.preferences[Preference.THIRD_PERSON_OFFSET] *= -1
    async(UpdateCamera, AsyncBehavior.RESTART)


def UpdateCamera():
    @Name "— Update camera"

    if eventPlayer.isInBaseCreationMode:
        BaseCreationCamera()
    elif eventPlayer.active_base_owner == eventPlayer:
        switch eventPlayer.preferences[Preference.THIRD_PERSON]:
            default:
            case ThirdPersonCamera.REAR:
                RearCamera()
                break
            case ThirdPersonCamera.OFF:
                StopCamera()
                break
    else:
        switch eventPlayer.preferences[Preference.THIRD_PERSON]:
            default:
            case ThirdPersonCamera.REAR:
                RearCamera()
                break
            case ThirdPersonCamera.TOP_DOWN:
                TopDownCamera()
                break
            case ThirdPersonCamera.STATIC_TOP_DOWN:
                StaticTopDownCamera()
                break
            case ThirdPersonCamera.OFF:
                StopCamera()
                break

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
    if not optimize and not eventPlayer.preferences[Preference.THIRD_PERSON_SMOOTHING]:
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eventPlayer.getEyePosition(),
                    eventPlayer.getEyePosition() + (
                        Vector.UP + eventPlayer.getFacingDirection() * eventPlayer.preferences[Preference.BASE_SIZE] * -1.5
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(
                raycast(
                    eventPlayer.getEyePosition(),
                    eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            0
        )


def RearCamera():
    @Name "— Enable rear camera"

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
                Vector.UP * (
                    (
                        eventPlayer.preferences[Preference.SIZE]
                        if eventPlayer.preferences[Preference.PLAYER_MODE]
                        else 100
                    ) / 100
                ) + eventPlayer.getFacingDirection()
                * (
                    (
                        eventPlayer.preferences[Preference.SIZE]
                        if eventPlayer.preferences[Preference.PLAYER_MODE]
                        else 100
                    ) / -40
                ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                + crossProduct(Vector.UP, eventPlayer.getFacingDirection())
                * eventPlayer.preferences[Preference.THIRD_PERSON_OFFSET]
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
    if not optimize and not eventPlayer.preferences[Preference.THIRD_PERSON_SMOOTHING]:
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eventPlayer.getEyePosition(),
                    eventPlayer.getEyePosition() + (
                        Vector.UP * (
                            (
                                eventPlayer.preferences[Preference.SIZE]
                                if eventPlayer.preferences[Preference.PLAYER_MODE]
                                else 100
                            ) / 100
                        ) + eventPlayer.getFacingDirection()
                        * (
                            (
                                eventPlayer.preferences[Preference.SIZE]
                                if eventPlayer.preferences[Preference.PLAYER_MODE]
                                else 100
                            ) / -40
                        ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                        + crossProduct(Vector.UP, eventPlayer.getFacingDirection())
                        * eventPlayer.preferences[Preference.THIRD_PERSON_OFFSET]
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(
                raycast(
                    eventPlayer.getEyePosition(),
                    eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            0
        )

def RearSpectatorCamera():
    @Name "— Enable rear spectator camera"

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
                Vector.UP * (
                    (
                        eventPlayer.focused_player.preferences[Preference.SIZE]
                        if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE]
                        else 100
                    ) / 100
                ) + eventPlayer.focused_player.getFacingDirection()
                * (
                    (
                        eventPlayer.focused_player.preferences[Preference.SIZE]
                        if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE]
                        else 100
                    ) / -40
                ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                + crossProduct(Vector.UP, eventPlayer.focused_player.getFacingDirection())
                * eventPlayer.focused_player.preferences[Preference.THIRD_PERSON_OFFSET]
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
    if not optimize and not eventPlayer.preferences[Preference.THIRD_PERSON_SMOOTHING]:
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eventPlayer.focused_player.getEyePosition(),
                    eventPlayer.focused_player.getEyePosition() + (
                        Vector.UP * (
                            (
                                eventPlayer.focused_player.preferences[Preference.SIZE]
                                if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE]
                                else 100
                            ) / 100
                        ) + eventPlayer.focused_player.getFacingDirection()
                        * (
                            (
                                eventPlayer.focused_player.preferences[Preference.SIZE]
                                if eventPlayer.focused_player.preferences[Preference.PLAYER_MODE]
                                else 100
                            ) / -40
                        ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                        + crossProduct(Vector.UP, eventPlayer.focused_player.getFacingDirection())
                        * eventPlayer.focused_player.preferences[Preference.THIRD_PERSON_OFFSET]
                    ),
                    null,
                    eventPlayer.focused_player,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(
                raycast(
                    eventPlayer.focused_player.getEyePosition(),
                    eventPlayer.focused_player.getEyePosition() + eventPlayer.focused_player.getFacingDirection() * 100,
                    null,
                    eventPlayer.focused_player,
                    false
                ).getHitPosition()
            ),
            0
        )


def TopDownCamera():
    @Name "— Enable top-down camera"

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
                Vector.UP * (
                    (
                        eventPlayer.preferences[Preference.SIZE]
                        if eventPlayer.preferences[Preference.PLAYER_MODE]
                        else 100
                    ) / 15
                ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                - vect(eventPlayer.getFacingDirection().x, 0, eventPlayer.getFacingDirection().z)
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        eventPlayer.getEyePosition(),
        30
    )
    if not optimize and not eventPlayer.preferences[Preference.THIRD_PERSON_SMOOTHING]:
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eventPlayer.getEyePosition(),
                    eventPlayer.getEyePosition() + (
                        Vector.UP * (
                            (
                                eventPlayer.preferences[Preference.SIZE]
                                if eventPlayer.preferences[Preference.PLAYER_MODE]
                                else 100
                            ) / 15
                        ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                        - vect(eventPlayer.getFacingDirection().x, 0, eventPlayer.getFacingDirection().z)
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(eventPlayer.getEyePosition()),
            0
        )


def StaticTopDownCamera():
    @Name "— Enable static top-down camera"

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
                Vector.UP * (
                    (
                        eventPlayer.preferences[Preference.SIZE]
                        if eventPlayer.preferences[Preference.PLAYER_MODE]
                        else 100
                    ) / 15
                ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                + Vector.FORWARD
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        eventPlayer.getEyePosition(),
        30
    )
    if not optimize and not eventPlayer.preferences[Preference.THIRD_PERSON_SMOOTHING]::
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eventPlayer.getEyePosition(),
                    eventPlayer.getEyePosition() + (
                        Vector.UP * (
                            (
                                eventPlayer.preferences[Preference.SIZE]
                                if eventPlayer.preferences[Preference.PLAYER_MODE]
                                else 100
                            ) / 15
                        ) * (eventPlayer.preferences[Preference.THIRD_PERSON_DISTANCE] / 100)
                        + Vector.FORWARD
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(eventPlayer.getEyePosition()),
            0
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
            2
        )
    else:
        eventPlayer.startCamera(
            eventPlayer.focused_player.getEyePosition() + (
                Vector.UP * (eventPlayer.focused_player.preferences[Preference.SIZE] / 100) + eventPlayer.focused_player.getFacingDirection() * (eventPlayer.focused_player.preferences[Preference.SIZE] / -20)
            ),
            eventPlayer.focused_player.getEyePosition(),
            2
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