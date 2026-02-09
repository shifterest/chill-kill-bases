#!mainFile "../main.opy"

# Shorthand
macro s(setting):
    eventPlayer.settings[setting]

macro pos():
    eventPlayer.getPosition()

macro eye():
    eventPlayer.getEyePosition()

macro face():
    eventPlayer.getFacingDirection()


# Constants
macro dynamic_settings_i(player):
    (
        quick_settings_data[player.settings_i]
        if player.cat_i == SettingCat.QUICK
        else player.settings_i
    )


macro dynamic_settings_data(player):
    (
        quick_settings_data
        if player.cat_i == SettingCat.QUICK
        else settings_data
    )


macro menu_vector(player, x, y):
    player.getEyePosition() + vect(
        x
        * cosDeg(horizontalAngleOfDirection(player.last_transform[1]))
        + sinDeg(
            horizontalAngleOfDirection(player.last_transform[1])
        ),
        y,
        -x
        * sinDeg(horizontalAngleOfDirection(player.last_transform[1]))
        + cosDeg(
            horizontalAngleOfDirection(player.last_transform[1])
        )
    )


macro rainbow():
    hsl(rainbow_hue, 1, 0.5)

macro RainbowColor(color):
    rainbow() if color == ExtendedColor.RAINBOW else extended_color_data[color]
macro friendly_base_in_crosshair(player):
    [
        p
        for p in getAllPlayers().exclude(player).exclude(player.current_base_owner)
        if (
            p.base_vector
            and p.settings[Setting.BASE_MODE] == BaseMode.FRIENDLY
            and distance(
                player.getEyePosition()
                + distance(player.getEyePosition(), p.base_vector)
                * player.getFacingDirection(),
                p.base_vector
            )
            <= p.settings[Setting.BASE_SIZE]
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
            <= p.settings[Setting.BASE_SIZE]
        )
    ][0]


# Settings data access shortcuts
macro current_setting_data(player):
    settings_data[dynamic_settings_i(player)]


macro current_setting_value(player):
    player.settings[dynamic_settings_i(player)]


macro format_numeric(value, suffix):
    f"{value}{suffix if suffix else ' units'}"


# Conditions
macro isOverlappingBase(vector, size, gap_size):
    any(
        [
            p != eventPlayer
            and p.base_vector
            and distance(vector, p.base_vector)
            <= p.settings[Setting.BASE_SIZE]
            + size
            + max(p.settings[Setting.BASE_GAP_SIZE], gap_size)
            for p in getAllPlayers()
        ]
    )


macro isInMountingRange(player):
    distance(player.getRealPlayerClosestToReticle(Team.ALL), player.getPosition()) <= (
        (
            player.settings[Setting.SIZE] * (3 / 200)
            if player.settings[Setting.PLAYER_MODE]
            else 1.5
        )
        + (
            player.getRealPlayerClosestToReticle(Team.ALL).settings[Setting.SIZE]
            * (3 / 200)
            if player.getRealPlayerClosestToReticle(Team.ALL).settings[
                Setting.PLAYER_MODE
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
            p.base_vector, p.settings[Setting.BASE_SIZE], Team.ALL, LosCheck.OFF
        )
    ][0] != eventPlayer.current_base_owner


macro isConfined():
    (
        eventPlayer.active_base_owner
        and eventPlayer.active_base_owner.base_vector
        and eventPlayer.base_vector
        and eventPlayer.active_base_owner == eventPlayer
        and eventPlayer.settings[Setting.BASE_LOCK]
    )


macro isActive():
    (
        eventPlayer.getThrottle() != vect(0, 0, 0)
        or eventPlayer.getFacingDirection() != eventPlayer.last_facing_dir
    )


# Functions
macro recreateBase():
    DestroyBase()
    CreateBase()

    
macro waitLoad():
    wait(getAverageServerLoad() / 150)


macro saveTransform():
    eventPlayer.last_transform = [
        eventPlayer.getPosition(),
        vect(
            eventPlayer.getFacingDirection().x,
            0,
            eventPlayer.getFacingDirection().z
        )
    ]


macro restoreTransform():
    eventPlayer.setFacing(
        eventPlayer.last_transform[LastTransformProp.LAST_FACING_DIR],
        Relativity.TO_WORLD
    )


macro iconMessage(visibility, icon, message):
    smallMessage(visibility, "   {}  {}".format(icon, message))
    # smallMessage(visibility, _("   {}  "message).format(icon))


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
        RainbowColor(eventPlayer.settings[Setting.OUTLINE_COLOR]),
        OutlineVisibility.DEFAULT
    )


macro updatePitch():
    eventPlayer.startModifyingVoicelinePitch(
        eventPlayer.settings[Setting.VOICE_PITCH] / 100, false
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


macro chaseInteractionProgress(duration, condition):
    chaseOverTime(eventPlayer.interaction_progress, 100, duration, ChaseTimeReeval.NONE)
    waitUntil(eventPlayer.interaction_progress == 100 or condition, duration)
    stopChasingVariable(eventPlayer.interaction_progress)


macro unchaseInteractionProgress(duration):
    chaseOverTime(
        eventPlayer.interaction_progress, 0, (duration / 4), ChaseTimeReeval.NONE
    )


macro resetCooldown(button):
    if (
        eventPlayer.getAbilityCooldown(button) > 0 
        or (
            eventPlayer.getAbilityCooldown(button) == 0
            and eventPlayer.isHoldingButton(button)
        )
    ):
        eventPlayer.setAbilityCooldown(button, 0)


macro spamAbility(button):
    eventPlayer.setAbilityCooldown(button, 0)
    wait()
    eventPlayer.forceButtonPress(button)
    wait()
    eventPlayer.stopForcingButton(button)
    wait(eventPlayer.settings[Setting.ABILITY_SPAM_DELAY])
    eventPlayer.cancelPrimaryAction()
    wait()


# Effects
macro Aura(effect, pos):
    createEffect(
        (
            null
            if not eventPlayer.settings[Setting.PLAYER_MODE]
            or eventPlayer.isInvisible
            else getAllPlayers()
        ),
        effect,
        RainbowColor(eventPlayer.settings[Setting.AURA_COLOR]),
        pos,
        eventPlayer.settings[Setting.AURA_SIZE] / 100,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )


macro AuraHidden(effect, pos):
    createEffect(
        (
            null
            if not eventPlayer.settings[Setting.PLAYER_MODE]
            or eventPlayer.isInvisible
            else getAllPlayers().exclude(eventPlayer)
        ),
        effect,
        RainbowColor(eventPlayer.settings[Setting.AURA_COLOR]),
        pos,
        eventPlayer.settings[Setting.AURA_SIZE] / 100,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )


macro BaseRingExplosion():
    playEffect(
        eventPlayer,
        DynamicEffect.RING_EXPLOSION,
        RainbowColor(eventPlayer.settings[Setting.BASE_COLOR]),
        eventPlayer.base_vector,
        eventPlayer.settings[Setting.BASE_SIZE] * 2
    )


macro DebuffImpactSoundPlayerFocus():
    playEffect(
        eventPlayer,
        DynamicEffect.DEBUFF_IMPACT_SOUND,
        null,
        eventPlayer.focused_player.getPosition(),
        100
    )


macro BuffImpactSoundBothFocus():
    playEffect(
        [eventPlayer, eventPlayer.focused_player],
        DynamicEffect.BUFF_IMPACT_SOUND,
        null,
        eventPlayer.focused_player.getPosition(),
        100
    )


macro DebuffImpactSoundBothFocus():
    playEffect(
        [eventPlayer, eventPlayer.focused_player],
        DynamicEffect.DEBUFF_IMPACT_SOUND,
        null,
        eventPlayer.focused_player.getPosition(),
        100
    )


macro BuffImpactSound():
    playEffect(
        eventPlayer,
        DynamicEffect.BUFF_IMPACT_SOUND,
        null,
        eventPlayer.getPosition(),
        100
    )


macro BuffImpactSoundQuiet():
    playEffect(
        eventPlayer,
        DynamicEffect.BUFF_IMPACT_SOUND,
        null,
        eventPlayer.getPosition(),
        15
    )


macro DebuffImpactSound():
    playEffect(
        eventPlayer,
        DynamicEffect.DEBUFF_IMPACT_SOUND,
        null,
        eventPlayer.getPosition(),
        100
    )


macro RingExplosionSound():
    playEffect(
        eventPlayer,
        DynamicEffect.RING_EXPLOSION_SOUND,
        null,
        eventPlayer.getPosition(),
        100
    )


macro BuffExplosionSound():
    playEffect(
        eventPlayer,
        DynamicEffect.BUFF_EXPLOSION_SOUND,
        null,
        eventPlayer.getPosition(),
        100
    )


macro BuffExplosionSoundQuiet():
    playEffect(
        eventPlayer,
        DynamicEffect.BUFF_EXPLOSION_SOUND,
        null,
        eventPlayer.getPosition(),
        15
    )


macro GoodPickupEffect(position):
    playEffect(
        eventPlayer,
        DynamicEffect.GOOD_PICKUP_EFFECT,
        # RainbowColor(eventPlayer.settings[Setting.BASE_COLOR]),
        Color.WHITE,
        position,
        10
    )