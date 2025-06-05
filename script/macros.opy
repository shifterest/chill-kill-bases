#!mainFile "../main.opy"


# Constants
macro orb_vector(y):
    localPlayer.base_vector + (
        y
        * Vector.UP
        * distance(
            localPlayer.base_vector,
            (
                raycast(
                    localPlayer.getEyePosition(),
                    localPlayer.getEyePosition()
                    + (
                        Vector.UP * (localPlayer.preferences[Preference.SIZE] / 100)
                        + localPlayer.getFacingDirection()
                        * (localPlayer.preferences[Preference.SIZE] / -40)
                        * (
                            localPlayer.preferences[Preference.THIRD_PERSON_DISTANCE]
                            / 100
                        )
                        if localPlayer.preferences[Preference.PLAYER_MODE]
                        else Vector.UP
                        + localPlayer.getFacingDirection()
                        * -2.5
                        * (
                            localPlayer.preferences[Preference.THIRD_PERSON_DISTANCE]
                            / 100
                        )
                    ),
                    null,
                    localPlayer,
                    false
                ).getHitPosition()
                if localPlayer.preferences[Preference.THIRD_PERSON]
                else localPlayer.getEyePosition()
            )
        )
        / 2.5
    )


macro menu_vector(x, y):
    localPlayer.getEyePosition() + vect(
        x
        * cosDeg(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]))
        + sinDeg(
            horizontalAngleOfDirection(localPlayer.previous_position_direction[1])
        ),
        y,
        -x
        * sinDeg(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]))
        + cosDeg(
            horizontalAngleOfDirection(localPlayer.previous_position_direction[1])
        )
    )


macro rainbow_rgb():
    rgb(rainbow_red, rainbow_green, rainbow_blue)


macro friendly_base_in_crosshair(player):
    [
        p
        for p in getAllPlayers().exclude(player).exclude(player.current_base_owner)
        if (
            p.base_vector
            and p.preferences[Preference.BASE_MODE] == BaseMode.FRIENDLY
            and distance(
                player.getEyePosition()
                + distance(player.getEyePosition(), p.base_vector)
                * player.getFacingDirection(),
                p.base_vector
            )
            <= p.preferences[Preference.BASE_SIZE]
        )
    ][0]


macro base_in_crosshair(player):
    [
        p
        for p in getAllPlayers()
        if (
            p.base_vector
            and distance(
                player.getEyePosition()
                + distance(player.getEyePosition(), p.base_vector)
                * player.getFacingDirection(),
                p.base_vector
            )
            <= p.preferences[Preference.BASE_SIZE]
        )
    ][0]


macro dynamic_preferences_index(player):
    (
        player.preferences_index
        if player.isViewingAdvancedPreferences
        else quick_preferences_data[player.preferences_index]
    )


# Conditions
macro isOverlappingBase(vector, size, gap_size):
    any(
        [
            p != eventPlayer
            and p.base_vector
            and distance(vector, p.base_vector)
            <= p.preferences[Preference.BASE_SIZE]
            + size
            + max(p.preferences[Preference.BASE_GAP_SIZE], gap_size)
            for p in getAllPlayers()
        ]
    )


macro isInMountingRange(player):
    distance(player.getRealPlayerClosestToReticle(Team.ALL), player.getPosition()) <= (
        (
            player.preferences[Preference.SIZE] * (3 / 200)
            if player.preferences[Preference.PLAYER_MODE]
            else 1.5
        )
        + (
            player.getRealPlayerClosestToReticle(Team.ALL).preferences[Preference.SIZE]
            * (3 / 200)
            if player.getRealPlayerClosestToReticle(Team.ALL).preferences[
                Preference.PLAYER_MODE
            ]
            else 1.5
        )
    ) and distance(
        player.getRealPlayerClosestToReticle(Team.ALL), player.getPosition()
    ) > 0


macro isInDifferentBase():
    [
        p
        for p in getAllPlayers()
        if p.base_vector
        and eventPlayer
        in getPlayersInRadius(
            p.base_vector, p.preferences[Preference.BASE_SIZE], Team.ALL, LosCheck.OFF
        )
    ][0] != eventPlayer.current_base_owner


macro isConfined():
    eventPlayer.active_base_owner and eventPlayer.active_base_owner.base_vector and eventPlayer.base_vector and eventPlayer.active_base_owner == eventPlayer and eventPlayer.preferences[
        Preference.BASE_LOCK
    ]


macro isActive():
    eventPlayer.getThrottle() != vect(
        0, 0, 0
    ) or eventPlayer.getFacingDirection() != eventPlayer.previous_facing_direction


# Functions
macro waitLoad():
    wait(getAverageServerLoad() / 150)


macro iconMessage(visibility, icon, message):
    smallMessage(visibility, "   {}  {}".format(icon, message))


macro stopMomentum():
    eventPlayer.applyImpulse(
        -eventPlayer.getVelocity(),
        0.00001,
        Relativity.TO_PLAYER,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )


macro updateHeroOutline():
    eventPlayer.startForcingOutlineFor(
        getAllPlayers(),
        true,
        (
            rainbow_rgb()
            if eventPlayer.preferences[Preference.OUTLINE_COLOR]
            == ExtendedColor.RAINBOW
            else colors_data[eventPlayer.preferences[Preference.OUTLINE_COLOR]]
        ),
        OutlineVisibility.DEFAULT
    )


macro updatePitch():
    eventPlayer.startModifyingVoicelinePitch(
        eventPlayer.preferences[Preference.VOICE_PITCH] / 100, false
    )


macro chaseProgress(duration, condition):
    chaseOverTime(eventPlayer.progress, 100, duration, ChaseTimeReeval.NONE)
    waitUntil(eventPlayer.progress == 100 or condition, duration)
    stopChasingVariable(eventPlayer.progress)


macro unchaseProgress(duration):
    chaseOverTime(eventPlayer.progress, 0, (duration / 4), ChaseTimeReeval.NONE)


macro chaseBaseProgress(duration, condition):
    chaseOverTime(eventPlayer.base_progress, 100, duration, ChaseTimeReeval.NONE)
    waitUntil(eventPlayer.base_progress == 100 or condition, duration)
    stopChasingVariable(eventPlayer.base_progress)


macro chaseCubicBezier():
    chaseOverTime(eventPlayer.cubic_bezier, 0, 0.4, ChaseTimeReeval.NONE)


macro chaseInteractionProgress(duration, condition):
    chaseOverTime(eventPlayer.interaction_progress, 100, duration, ChaseTimeReeval.NONE)
    waitUntil(eventPlayer.interaction_progress == 100 or condition, duration)
    stopChasingVariable(eventPlayer.interaction_progress)


macro unchaseInteractionProgress(duration):
    chaseOverTime(
        eventPlayer.interaction_progress, 0, (duration / 4), ChaseTimeReeval.NONE
    )


# Effects
macro RainbowColor(color):
    rainbow_rgb() if color == ExtendedColor.RAINBOW else colors_data[color]


macro Aura(effect, pos):
    createEffect(
        (
            null
            if not eventPlayer.preferences[Preference.PLAYER_MODE]
            or eventPlayer.isInvisible
            else getAllPlayers()
        ),
        effect,
        (
            rainbow_rgb()
            if eventPlayer.preferences[Preference.AURA_COLOR] == ExtendedColor.RAINBOW
            else colors_data[eventPlayer.preferences[Preference.AURA_COLOR]]
        ),
        pos,
        eventPlayer.preferences[Preference.AURA_SIZE] / 100,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )


macro AuraHidden(effect, pos):
    createEffect(
        (
            null
            if not eventPlayer.preferences[Preference.PLAYER_MODE]
            or eventPlayer.isInvisible
            else getAllPlayers().exclude(eventPlayer)
        ),
        effect,
        (
            rainbow_rgb()
            if eventPlayer.preferences[Preference.AURA_COLOR] == ExtendedColor.RAINBOW
            else colors_data[eventPlayer.preferences[Preference.AURA_COLOR]]
        ),
        pos,
        eventPlayer.preferences[Preference.AURA_SIZE] / 100,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )


macro BaseRingExplosion():
    playEffect(
        eventPlayer,
        DynamicEffect.RING_EXPLOSION,
        (
            rainbow_rgb()
            if eventPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
            else colors_data[eventPlayer.preferences[Preference.BASE_COLOR]]
        ),
        eventPlayer.base_vector,
        eventPlayer.preferences[Preference.BASE_SIZE] * 2
    )


macro DebuffSoundPlayerFocus():
    playEffect(
        eventPlayer,
        DynamicEffect.DEBUFF_IMPACT_SOUND,
        null,
        eventPlayer.focused_player.getPosition(),
        100
    )


macro BuffSoundBothFocus():
    playEffect(
        [eventPlayer, eventPlayer.focused_player],
        DynamicEffect.BUFF_IMPACT_SOUND,
        null,
        eventPlayer.focused_player.getPosition(),
        100
    )


macro DebuffSoundBothFocus():
    playEffect(
        [eventPlayer, eventPlayer.focused_player],
        DynamicEffect.DEBUFF_IMPACT_SOUND,
        null,
        eventPlayer.focused_player.getPosition(),
        100
    )


macro BuffSound():
    playEffect(
        eventPlayer,
        DynamicEffect.BUFF_IMPACT_SOUND,
        null,
        eventPlayer.getPosition(),
        100
    )


macro DebuffSound():
    playEffect(
        eventPlayer,
        DynamicEffect.DEBUFF_IMPACT_SOUND,
        null,
        eventPlayer.getPosition(),
        100
    )
