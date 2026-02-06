#!mainFile "../main.opy"

rule "Cameras":
    @Disabled
    @Delimiter


rule "— ADS in third-person":
    @Event eachPlayer
    @Condition not optimize
    @Condition pref(Preference.THIRD_PERSON)
    @Condition (
        eventPlayer.getCurrentHero() == Hero.ANA
        or eventPlayer.getCurrentHero() == Hero.ASHE
        or eventPlayer.getCurrentHero() == Hero.WIDOWMAKER
        or eventPlayer.getCurrentHero() == Hero.FREJA
    )
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
    @Condition eventPlayer.uiState == UIState.NORMAL

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.uiState != UIState.NORMAL
        or eventPlayer.isDead(),
        Math.INFINITY
    )

    if eventPlayer.uiState != UIState.MODERATING:
        async(UpdateCamera, AsyncBehavior.RESTART)


rule "— Ultimate in third-person":
    @Event eachPlayer
    @Condition not optimize
    @Condition pref(Preference.THIRD_PERSON)
    @Condition (
        eventPlayer.getCurrentHero() == Hero.BASTION
        or eventPlayer.getCurrentHero() == Hero.JUNKRAT
    )
    @Condition eventPlayer.isUsingUltimate()
    @Condition eventPlayer.uiState == UIState.NORMAL

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isUsingUltimate()
        or eventPlayer.uiState != UIState.NORMAL
        or eventPlayer.isDead(),
        Math.INFINITY
    )

    if eventPlayer.uiState != UIState.MODERATING:
        async(UpdateCamera, AsyncBehavior.RESTART)


rule "— Switch shoulder":
    @Event eachPlayer
    @Condition pref(Preference.THIRD_PERSON) == ThirdPersonCamera.REAR
    @Condition pref(Preference.THIRD_PERSON_OFFSET) != 0
    @Condition eventPlayer.uiState == UIState.NORMAL
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    pref(Preference.THIRD_PERSON_OFFSET) = pref(Preference.THIRD_PERSON_OFFSET) * -1
    async(UpdateCamera, AsyncBehavior.RESTART)


def UpdateCamera():
    @Name "— Update camera"

    if eventPlayer.uiState == UIState.MODERATING:
        return
    if eventPlayer.uiState == UIState.BASE_CREATION:
        BaseCreationCamera()
    elif eventPlayer.active_base_owner == eventPlayer:
        switch pref(Preference.THIRD_PERSON):
            default:
            case ThirdPersonCamera.REAR:
                RearCamera()
                break
            case ThirdPersonCamera.OFF:
                StopCamera()
                break
    else:
        switch pref(Preference.THIRD_PERSON):
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
            case ThirdPersonCamera.FRONT:
                FrontCamera()
                break
            case ThirdPersonCamera.OFF:
                StopCamera()
                break

    async(UpdateAura, AsyncBehavior.RESTART)


def BaseCreationCamera():
    @Name "— Enable base creation camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    snapCamera()
    eventPlayer.startCamera(
        raycast(
            eye(),
            eye() + (
                Vector.UP + face() * pref(Preference.BASE_SIZE) * -1.5
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        raycast(
            eye(),
            eye() + face() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        30
    )
    if not optimize and not pref(Preference.THIRD_PERSON_SMOOTHING):
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + (
                        Vector.UP + face() * pref(Preference.BASE_SIZE) * -1.5
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + face() * 100,
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
    snapCamera()
    eventPlayer.startCamera(
        raycast(
            eye(),
            eye() + (
                Vector.UP * (
                    (
                        pref(Preference.SIZE)
                        if pref(Preference.PLAYER_MODE)
                        else 100
                    ) / 100
                ) + face()
                * (
                    (
                        pref(Preference.SIZE)
                        if pref(Preference.PLAYER_MODE)
                        else 100
                    ) / -40
                ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                + crossProduct(Vector.UP, face())
                * pref(Preference.THIRD_PERSON_OFFSET)
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        raycast(
            eye(),
            eye() + face() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        30
    )
    if not optimize and not pref(Preference.THIRD_PERSON_SMOOTHING):
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + (
                        Vector.UP * (
                            (
                                pref(Preference.SIZE)
                                if pref(Preference.PLAYER_MODE)
                                else 100
                            ) / 100
                        ) + face()
                        * (
                            (
                                pref(Preference.SIZE)
                                if pref(Preference.PLAYER_MODE)
                                else 100
                            ) / -40
                        ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                        + crossProduct(Vector.UP, face())
                        * pref(Preference.THIRD_PERSON_OFFSET)
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + face() * 100,
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
    snapCamera()
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
                ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
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
    if not optimize and not pref(Preference.THIRD_PERSON_SMOOTHING):
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
                        ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
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

    snapCamera()
    eventPlayer.startCamera(
        raycast(
            eye(),
            eye() + (
                Vector.UP * (
                    (
                        pref(Preference.SIZE)
                        if pref(Preference.PLAYER_MODE)
                        else 100
                    ) / 15
                ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                - vect(face().x, 0, face().z)
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        eye(),
        30
    )
    if not optimize and not pref(Preference.THIRD_PERSON_SMOOTHING):
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + (
                        Vector.UP * (
                            (
                                pref(Preference.SIZE)
                                if pref(Preference.PLAYER_MODE)
                                else 100
                            ) / 15
                        ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                        - vect(face().x, 0, face().z)
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(eye()),
            0
        )


def StaticTopDownCamera():
    @Name "— Enable static top-down camera"

    snapCamera()
    eventPlayer.startCamera(
        raycast(
            eye(),
            eye() + (
                Vector.UP * (
                    (
                        pref(Preference.SIZE)
                        if pref(Preference.PLAYER_MODE)
                        else 100
                    ) / 15
                ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                + Vector.FORWARD
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        eye(),
        30
    )
    if not optimize and not pref(Preference.THIRD_PERSON_SMOOTHING):
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + (
                        Vector.UP * (
                            (
                                pref(Preference.SIZE)
                                if pref(Preference.PLAYER_MODE)
                                else 100
                            ) / 15
                        ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                        + Vector.FORWARD
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(eye()),
            0
        )


def DreamCamera():
    @Name "— Enable dream camera"

    snapCamera()
    if pref(Preference.CLIP_CAMERA):
        eventPlayer.startCamera(
            raycast(
                evalOnce(eventPlayer.focused_player).getEyePosition(),
                evalOnce(eventPlayer.focused_player).getEyePosition() + (
                    Vector.UP * (evalOnce(eventPlayer.focused_player).preferences[Preference.SIZE] / 100) + evalOnce(eventPlayer.focused_player).getFacingDirection() * (evalOnce(eventPlayer.focused_player).preferences[Preference.SIZE] / -20)
                ),
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            evalOnce(eventPlayer.focused_player).getEyePosition(),
            2
        )
    else:
        eventPlayer.startCamera(
            evalOnce(eventPlayer.focused_player).getEyePosition() + (
                Vector.UP * (evalOnce(eventPlayer.focused_player).preferences[Preference.SIZE] / 100) + evalOnce(eventPlayer.focused_player).getFacingDirection() * (evalOnce(eventPlayer.focused_player).preferences[Preference.SIZE] / -20)
            ),
            evalOnce(eventPlayer.focused_player).getEyePosition(),
            2
        )


def FrontCamera():
    @Name "— Enable front camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    snapCamera()
    eventPlayer.startCamera(
        raycast(
            eye(),
            eye() + (
                Vector.UP * (
                    (
                        pref(Preference.SIZE)
                        if pref(Preference.PLAYER_MODE)
                        else 100
                    ) / 100
                ) + face()
                * (
                    (
                        pref(Preference.SIZE)
                        if pref(Preference.PLAYER_MODE)
                        else 100
                    ) / 40
                ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                + crossProduct(Vector.UP, face())
                * pref(Preference.THIRD_PERSON_OFFSET)
            ),
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        eye(),
        30
    )
    if not optimize and not pref(Preference.THIRD_PERSON_SMOOTHING):
        wait(0.2)
        eventPlayer.startCamera(
            updateEveryFrame(
                raycast(
                    eye(),
                    eye() + (
                        Vector.UP * (
                            (
                                pref(Preference.SIZE)
                                if pref(Preference.PLAYER_MODE)
                                else 100
                            ) / 100
                        ) + face()
                        * (
                            (
                                pref(Preference.SIZE)
                                if pref(Preference.PLAYER_MODE)
                                else 100
                            ) / 40
                        ) * (pref(Preference.THIRD_PERSON_DISTANCE) / 100)
                        + crossProduct(Vector.UP, face())
                        * pref(Preference.THIRD_PERSON_OFFSET)
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryFrame(eye()),
            0
        )


def StopCamera():
    @Name "— Stop camera"

    eventPlayer.startCamera(
        eye(), 
        raycast(
            eye(),
            eye() + face() * 100,
            null,
            eventPlayer,
            false
        ).getHitPosition(),
        30
    )
    wait(0.2)
    eventPlayer.stopCamera()