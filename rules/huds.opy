#!mainFile "../main.opy"

rule "HUDs":
    @Disabled
    @Delimiter


rule "— Draw global HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # --- Left ---
    hudSubheader(
        localPlayer,
        "lobby {} • hosted by {} {}{}\n ".format(
            "up for {} minutes".format(floor(getTotalTimeElapsed() / 60)) if getTotalTimeElapsed() > 120 else "just started",
            heroIcon(hostPlayer.getCurrentHero()),
            hostPlayer,
            moderator_list_hud
        ),
        HudPosition.LEFT,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )

    # --- TOP ---
    # Server load
    hudSubheader(
        localPlayer
        if ("{}".format(localPlayer) in mod_usernames.concat(god_usernames) or localPlayer == hostPlayer)
        and not localPlayer.isInDreamMode
        else null,
        "{} current • {} mean • {} peak".format(
            getServerLoad(), getAverageServerLoad(), getPeakServerLoad()
        ),
        HudPosition.TOP,
        0,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    hudSubheader(
        localPlayer
        if ("{}".format(localPlayer) in mod_usernames.concat(god_usernames) or localPlayer == hostPlayer)
        and localPlayer.isInModeratorMode
        else null,
        "{} entities • {} text • {} dmg mods • {} heal mods".format(
            getNumberOfEntityIds(), getNumberOfTextIds(), getNumberOfDamageModificationIds(), getNumberOfHealingModificationIds()
        ),
        HudPosition.TOP,
        1,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # Moderator mode hotkey
    hudSubheader(
        localPlayer
        if ("{}".format(localPlayer) in mod_usernames.concat(god_usernames) or localPlayer == hostPlayer)
        and not localPlayer.isInDreamMode
        else null,
        "{} + {} • toggle moderator mode\n ".format(
            buttonToString(Button.CROUCH), buttonToString(Button.RELOAD)
        ) if localPlayer.preferences[Preference.SHOW_HOTKEYS] else " ",
        HudPosition.TOP,
        2,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # Main info
    hudSubtext(
        null
        if localPlayer.isInModeratorMode
        or localPlayer.isInDreamMode
        else localPlayer,
        localPlayer.onscreen_hud[OnScreenHUD.MAIN],
        HudPosition.TOP,
        3,
        rainbow_rgb()
        if localPlayer.onscreen_hud[OnScreenHUD.COLOR] == ExtendedColor.RAINBOW
        else localPlayer.onscreen_hud[OnScreenHUD.COLOR],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    # Moderator mode
    hudSubtext(
        localPlayer if localPlayer.isInModeratorMode else null,
        "{} {}{} • {} • {}".format(
            heroIcon(localPlayer.focused_player.getCurrentHero()),
            localPlayer.focused_player,
            " (host)" if localPlayer.focused_player == hostPlayer
            else " (god)" if "{}".format(localPlayer.focused_player) in god_usernames
            else " (moderator)" if "{}".format(localPlayer.focused_player) in mod_usernames
            else "",
            preferences_data[Preference.PLAYER_MODE][PreferenceProperty.PARAMETERS][localPlayer.focused_player.preferences[Preference.PLAYER_MODE]],
            preferences_data[Preference.BASE_MODE][PreferenceProperty.PARAMETERS][localPlayer.focused_player.preferences[Preference.BASE_MODE]]
            if localPlayer.focused_player.base_vector else "no base"
        ),
        HudPosition.TOP,
        3,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    hudSubheader(
        localPlayer if localPlayer.preferences[Preference.SHOW_HOTKEYS] else null,
        "{} {} • switch players • {} {}\n{} • apply / remove stasis\n{} • kill / resurrect\n{} • ban / unban text and voice chat{}\nhold {} • teleport to player\nhold {} • teleport player to you\nhold {} • remove base\nhold {} + {} • ban player".format(
            buttonToString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.SECONDARY_FIRE),
            buttonToString(Button.JUMP),
            buttonToString(Button.RELOAD),
            buttonToString(Button.MELEE),
            "\n{} • promote player / demote moderator".format(
                buttonToString(Button.ABILITY_2)
            )
            if localPlayer == hostPlayer else "",
            buttonToString(Button.ULTIMATE),
            buttonToString(Button.INTERACT),
            buttonToString(Button.ABILITY_1),
            buttonToString(Button.CROUCH),
            buttonToString(Button.MELEE)
        )
        if localPlayer.isInModeratorMode else
        "{}{}{}{}{}{}{}{}".format(
            "{} • create base\n{} • cancel\n".format(
                buttonToString(Button.PRIMARY_FIRE), buttonToString(Button.INTERACT)
            )
            if localPlayer.isInBaseCreationMode
            else "hold {} • create base\n".format(buttonToString(Button.INTERACT))
            if not localPlayer.base_vector
            else "",
            "{}".format(
                "hold {} • fast travel to {} {}'s base\n".format(
                    buttonToString(Button.MELEE),
                    heroIcon(friendly_base_in_crosshair(localPlayer).getCurrentHero()),
                    friendly_base_in_crosshair(localPlayer)
                )
                if friendly_base_in_crosshair(localPlayer)
                and (
                    localPlayer.preferences[Preference.PLAYER_MODE]
                    or not localPlayer.preferences[Preference.PLAYER_MODE]
                    and localPlayer.active_base_owner
                )
                else "hold {} • fast travel to your base\n".format(buttonToString(Button.MELEE))
                if localPlayer.base_vector
                and localPlayer.active_base_owner != localPlayer
                and (
                    localPlayer.preferences[Preference.PLAYER_MODE]
                    or not localPlayer.preferences[Preference.PLAYER_MODE]
                    and localPlayer.active_base_owner
                )
                else "hold {} • fast travel to last position\n".format(buttonToString(Button.MELEE))
                if localPlayer.preferences[Preference.PLAYER_MODE]
                and localPlayer.active_base_owner == localPlayer
                and localPlayer.previous_position
                else ""
            )
            if (
                (localPlayer.preferences[Preference.PLAYER_MODE] or localPlayer.active_base_owner)
                and localPlayer.preferences[Preference.FAST_TRAVEL]
                and not localPlayer.mount
                # and localPlayer.active_base_owner == localPlayer
            )
            else "",
            "hold {} • switch hero\nhold {} • remove base\n".format(
                buttonToString(Button.RELOAD), buttonToString(Button.INTERACT)
            )
            if localPlayer.active_base_owner == localPlayer
            else "",
            "{} + {} • {}\n".format(
                buttonToString(Button.CROUCH), buttonToString(Button.MELEE),
                "exit stasis" if localPlayer.isInStasis else "enter stasis"
            )
            if localPlayer.preferences[Preference.PLAYER_MODE]
            and localPlayer.preferences[Preference.STASIS]
            else "",
            "{} + {} • switch shoulder\n".format(
                buttonToString(Button.INTERACT), buttonToString(Button.MELEE)
            )
            if localPlayer.preferences[Preference.THIRD_PERSON] == ThirdPersonCamera.REAR
            and localPlayer.preferences[Preference.THIRD_PERSON_OFFSET] != 0
            else "",
            "hold {} + {} • remove base\n".format(
                buttonToString(Button.CROUCH), buttonToString(Button.INTERACT)
            )
            if localPlayer.base_vector
            and localPlayer.active_base_owner != localPlayer
            and localPlayer.preferences[Preference.REMOVE_BASE_REMOTELY]
            else "",
            "{} + {} • eject {} {}\n".format(
                buttonToString(Button.PRIMARY_FIRE),
                buttonToString(Button.SECONDARY_FIRE),
                heroIcon(localPlayer.rider.getCurrentHero()),
                localPlayer.rider
            )
            if localPlayer.rider else "",
            "{} + {} • eject from {} {}".format(
                buttonToString(Button.ABILITY_1),
                buttonToString(Button.INTERACT),
                heroIcon(localPlayer.mount.getCurrentHero()),
                localPlayer.mount
            )
            if localPlayer.mount
            else "{} • ride {} {}".format(
                buttonToString(Button.INTERACT),
                heroIcon(localPlayer.getRealPlayerClosestToReticle(Team.ALL).getCurrentHero()),
                localPlayer.getRealPlayerClosestToReticle(Team.ALL)
            )
            if localPlayer.preferences[Preference.PLAYER_MODE]
            and localPlayer.getRealPlayerClosestToReticle(Team.ALL).hasSpawned()
            and not localPlayer.getRealPlayerClosestToReticle(Team.ALL).rider
            and localPlayer.getRealPlayerClosestToReticle(Team.ALL) != localPlayer.rider
            and localPlayer.getRealPlayerClosestToReticle(Team.ALL).preferences[Preference.ALLOW_MOUNTING]
            and isInMountingRange(localPlayer)
            and not localPlayer.mount
            else ""
        )
        if localPlayer.preferences[Preference.SHOW_HOTKEYS] and not (
            localPlayer.isViewingPreferences
            or localPlayer.isInModeratorMode
            or localPlayer.isUsingKeyboard
            or localPlayer.isInDreamMode
        ) else "",
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # Padding
    hudSubheader(
        localPlayer,
        " ",
        HudPosition.TOP,
        69,
        Color.WHITE,
        HudReeval.VISIBILITY,
        SpecVisibility.NEVER
    )
    # Progress HUD
    progressBarHud(
        localPlayer if localPlayer.progress > 0 and localPlayer.progress < 100 else null,
        localPlayer.progress,
        localPlayer.progress_hud[ProgressHUD.TEXT],
        HudPosition.TOP,
        70,
        rainbow_rgb()
        if localPlayer.progress_hud[ProgressHUD.COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.progress_hud[ProgressHUD.COLOR]],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # Base activation progress bar
    progressBarHud(
        localPlayer if localPlayer.base_progress > 0 and localPlayer.base_progress < 100 else null,
        localPlayer.base_progress,
        localPlayer.onscreen_hud[OnScreenHUD.ACTIVATION],
        HudPosition.TOP,
        71,
        rainbow_rgb()
        if localPlayer.current_base_owner.preferences[Preference.BASE_COLOR]
        == ExtendedColor.RAINBOW
        else extended_color_data[
            localPlayer.current_base_owner.preferences[Preference.BASE_COLOR]
        ],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )

    # --- Right ---
    # Game info
    switch mode:
        case Mode.MUSIC:
            hudSubheader(
                localPlayer,
                "chill / kill bases • join mvc for music • TSX53",
                HudPosition.RIGHT,
                0,
                rainbow_rgb(),
                HudReeval.VISIBILITY_AND_COLOR,
                SpecVisibility.DEFAULT
            )
            break
        case Mode.SLEEP:
            hudSubheader(
                localPlayer,
                "chill / kill bases • sleep tight • TSX53",
                HudPosition.RIGHT,
                0,
                rainbow_rgb(),
                HudReeval.VISIBILITY_AND_COLOR,
                SpecVisibility.DEFAULT
            )
            break
        case Mode.SHIFTEREST:
            hudSubheader(
                localPlayer,
                "chill / kill bases (by shifterest) • TSX53",
                HudPosition.RIGHT,
                0,
                rainbow_rgb(),
                HudReeval.VISIBILITY_AND_COLOR,
                SpecVisibility.DEFAULT
            )
            break
        default:
            hudSubheader(
                localPlayer,
                "chill / kill bases • TSX53",
                HudPosition.RIGHT,
                0,
                rainbow_rgb(),
                HudReeval.VISIBILITY_AND_COLOR,
                SpecVisibility.DEFAULT
            )
            break

    # --- In-world ---
    # Base indicator
    createIcon(
        localPlayer
        if localPlayer.base_vector
        and not localPlayer.isViewingPreferences
        else null,
        localPlayer.base_vector + Vector.UP / 10,
        Icon.ARROW_DOWN,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        true
    )
    # Base outline
    createEffect(
        localPlayer if localPlayer.active_base_owner else null,
        Effect.RING,
        rainbow_rgb()
        if localPlayer.active_base_owner.preferences[Preference.BASE_COLOR]
        == ExtendedColor.RAINBOW
        else extended_color_data[
            localPlayer.active_base_owner.preferences[Preference.BASE_COLOR]
        ],
        localPlayer.active_base_owner.base_vector,
        localPlayer.active_base_owner.preferences[Preference.BASE_SIZE],
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # Center orb
    createEffect(
        null
        if localPlayer.active_base_owner != localPlayer
        or localPlayer.isInModeratorMode
        or localPlayer.isUsingKeyboard
        or localPlayer.isInDreamMode
        else localPlayer,
        Effect.ORB,
        rainbow_rgb()
        if localPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences[Preference.BASE_COLOR]],
        localPlayer.base_vector,
        orb_radius,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # Adjusting preferences indicator
    createEffect(
        null
        if localPlayer.active_base_owner != localPlayer
        or localPlayer.isInModeratorMode
        or localPlayer.isUsingKeyboard
        or localPlayer.isInDreamMode
        or not localPlayer.isViewingPreferences
        else localPlayer,
        Effect.LIGHT_SHAFT,
        rainbow_rgb()
        if localPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences[Preference.BASE_COLOR]],
        localPlayer.base_vector,
        orb_radius,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # Advanced preferences indicator
    createEffect(
        null
        if localPlayer.active_base_owner != localPlayer
        or localPlayer.isInModeratorMode
        or localPlayer.isUsingKeyboard
        or localPlayer.isInDreamMode
        or not localPlayer.isViewingPreferences
        or not localPlayer.isViewingAdvancedPreferences
        else localPlayer,
        Effect.RING,
        rainbow_rgb()
        if localPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences[Preference.BASE_COLOR]],
        localPlayer.base_vector,
        orb_radius + 0.5,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )


def UpdateHUD():
    @Name "— Update HUD"

    if eventPlayer.active_base_owner == eventPlayer:
        eventPlayer.onscreen_hud[OnScreenHUD.MAIN] = "Your base is currently in {} mode".format(
            preferences_data[Preference.BASE_MODE][PreferenceProperty.PARAMETERS][eventPlayer.preferences[Preference.BASE_MODE]]
        )
        eventPlayer.onscreen_hud[OnScreenHUD.COLOR] = extended_color_data[preferences_data[Preference.BASE_MODE][PreferenceProperty.COLORS][eventPlayer.preferences[Preference.BASE_MODE]]]
    else:
        eventPlayer.onscreen_hud[OnScreenHUD.MAIN] = "You are currently{} in {} mode".format(
            " invisible"
            if eventPlayer.preferences[Preference.PLAYER_MODE]
            and eventPlayer.preferences[Preference.INVISIBILITY]
            else "",
            preferences_data[Preference.PLAYER_MODE][PreferenceProperty.PARAMETERS][eventPlayer.preferences[Preference.PLAYER_MODE]]
        )
        eventPlayer.onscreen_hud[OnScreenHUD.COLOR] = extended_color_data[preferences_data[Preference.PLAYER_MODE][PreferenceProperty.COLORS][eventPlayer.preferences[Preference.PLAYER_MODE]]]

    eventPlayer.onscreen_hud[OnScreenHUD.ACTIVATION] = "entering {}{} {}...".format(
        heroIcon(eventPlayer.current_base_owner.getCurrentHero()) if eventPlayer.current_base_owner != eventPlayer else "",
        "{}'s".format(eventPlayer.current_base_owner) if eventPlayer.current_base_owner != eventPlayer else "your",
        "base"
    )

    if eventPlayer.base_vector:
        eventPlayer.in_world_hud[InWorldHUD.BASE_MODE_ICON] = base_mode_icon_data[
            eventPlayer.preferences[Preference.BASE_MODE]
        ]
        eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = ""
        if eventPlayer.preferences[Preference.BASE_GRAVITY] != 100:
            eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "{} • {} gravity".format(
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY],
                eventPlayer.preferences[Preference.BASE_GRAVITY]
            )
        if eventPlayer.preferences[Preference.BASE_SPEED] != 100:
            eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "{} • {} speed".format(
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY],
                eventPlayer.preferences[Preference.BASE_SPEED]
            )
        if eventPlayer.preferences[Preference.BASE_JUMP_SPEED] != 100:
            eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "{} • {} jump speed".format(
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY],
                eventPlayer.preferences[Preference.BASE_JUMP_SPEED]
            )
    else:
        eventPlayer.in_world_hud[InWorldHUD.BASE_MODE_ICON] = abilityIconString(Hero.ZENYATTA, Button.ULTIMATE)
        eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "none"


def UpdateModeratorListHUD():
    @Name "— Update moderator list HUD"

    moderator_list_hud = ""

    for moderator_list_hud_counter in range(len(mod_usernames)):
        if mod_usernames[moderator_list_hud_counter] in ["{}".format(p) for p in getAllPlayers().exclude(hostPlayer)]:
            moderator_list_hud = "{}{}   • {}".format(moderator_list_hud, "\n", mod_usernames[moderator_list_hud_counter])

    if moderator_list_hud != "":
        moderator_list_hud = "\n\nmoderators:{}".format(moderator_list_hud)


def CreateBase():
    @Name "— Create base"

    if eventPlayer.isInBaseCreationMode:
        # Base sphere
        createEffect(
            eventPlayer if eventPlayer.isInBaseCreationMode else null,
            Effect.SPHERE,
            rainbow_rgb()
            if eventPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
            else extended_color_data[eventPlayer.preferences[Preference.BASE_COLOR]],
            updateEveryFrame(eventPlayer.getPosition()),
            eventPlayer.preferences[Preference.BASE_SIZE],
            EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
        )
        eventPlayer.base_effect_id = getLastCreatedEntity()
    else:
        if eventPlayer.preferences[Preference.BASE_MODE] == BaseMode.HIDDEN:
            # Base sphere
            createEffect(
                eventPlayer if eventPlayer.active_base_owner != eventPlayer else null,
                Effect.SPHERE,
                rainbow_rgb()
                if eventPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
                else extended_color_data[eventPlayer.preferences[Preference.BASE_COLOR]],
                eventPlayer.base_vector
                if eventPlayer.base_vector
                else null,
                eventPlayer.preferences[Preference.BASE_SIZE],
                EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
            )
            eventPlayer.base_effect_id = getLastCreatedEntity()
            # Base mode icon
            createInWorldText(
                eventPlayer
                if eventPlayer.active_base_owner != eventPlayer
                and not eventPlayer.isInDreamMode
                else null,
                eventPlayer.in_world_hud[InWorldHUD.BASE_MODE_ICON],
                eventPlayer.base_vector,
                1.7,
                Clip.NONE,
                WorldTextReeval.VISIBILITY_AND_STRING,
                Color.WHITE,
                SpecVisibility.DEFAULT
            )
            eventPlayer.icon_effect_id = getLastCreatedText()
            # Base description
            createInWorldText(
                eventPlayer
                if eventPlayer.active_base_owner != eventPlayer
                and not eventPlayer.isInDreamMode
                else null,
                "{} {}'s base{}".format(
                    heroIcon(eventPlayer.getCurrentHero()),
                    eventPlayer,
                    eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY]
                ),
                eventPlayer.base_vector + Vector.UP * (eventPlayer.preferences[Preference.BASE_SIZE] + 0.2),
                1,
                Clip.SURFACES,
                WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
                Color.WHITE,
                SpecVisibility.DEFAULT
            )
            eventPlayer.description_effect_id = getLastCreatedText()
        else:
            # Base sphere
            createEffect(
                [p for p in getAllPlayers() if p.active_base_owner != eventPlayer],
                Effect.SPHERE,
                rainbow_rgb()
                if eventPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
                else extended_color_data[eventPlayer.preferences[Preference.BASE_COLOR]],
                eventPlayer.base_vector
                if eventPlayer.base_vector
                else null,
                eventPlayer.preferences[Preference.BASE_SIZE],
                EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
            )
            eventPlayer.base_effect_id = getLastCreatedEntity()
            # Base mode icon
            createInWorldText(
                [
                    p for p in getAllPlayers()
                    if p.active_base_owner != eventPlayer
                    and not p.isInDreamMode
                ],
                eventPlayer.in_world_hud[InWorldHUD.BASE_MODE_ICON],
                eventPlayer.base_vector,
                1.7,
                Clip.NONE,
                WorldTextReeval.VISIBILITY_AND_STRING,
                Color.WHITE,
                SpecVisibility.DEFAULT
            )
            eventPlayer.icon_effect_id = getLastCreatedText()
            # Base description
            createInWorldText(
                [
                    p for p in getAllPlayers()
                    if p.active_base_owner != eventPlayer
                    and not p.isInDreamMode
                ],
                "{} {}'s base{}".format(
                    heroIcon(eventPlayer.getCurrentHero()),
                    eventPlayer,
                    eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY]
                ),
                eventPlayer.base_vector + Vector.UP * (eventPlayer.preferences[Preference.BASE_SIZE] + 0.2),
                1,
                Clip.SURFACES,
                WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
                Color.WHITE,
                SpecVisibility.DEFAULT
            )
            eventPlayer.description_effect_id = getLastCreatedText()


def DestroyBase():
    @Name "— Destroy base"

    if eventPlayer.isInModeratorMode:
        destroyEffect(eventPlayer.focused_player.base_effect_id)
        destroyInWorldText(eventPlayer.focused_player.icon_effect_id)
        destroyInWorldText(eventPlayer.focused_player.description_effect_id)
    else:
        destroyEffect(eventPlayer.base_effect_id)
        destroyInWorldText(eventPlayer.icon_effect_id)
        destroyInWorldText(eventPlayer.description_effect_id)


def UpdateMessage():
    @Name "— Update custom message"

    destroyInWorldText(eventPlayer.message_effect_id)

    if eventPlayer.preferences[Preference.CUSTOM_MESSAGE]:        
        createInWorldText(
            null
            if not eventPlayer.hasSpawned()
            or eventPlayer.isInvisible
            else getAllPlayers(),
            eventPlayer.preferences[Preference.CUSTOM_MESSAGE],
            updateEveryFrame(eventPlayer.getEyePosition())
            + (
                Vector.UP
                * (
                    (eventPlayer.preferences[Preference.SIZE] / 160)
                    if eventPlayer.preferences[Preference.PLAYER_MODE]
                    else 0.625
                )
            ),
            1.5,
            Clip.SURFACES,
            WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,
            rainbow_rgb()
            if eventPlayer.preferences[Preference.CUSTOM_MESSAGE_COLOR] == ExtendedColor.RAINBOW
            else extended_color_data[eventPlayer.preferences[Preference.CUSTOM_MESSAGE_COLOR]],
            SpecVisibility.DEFAULT
        )

        eventPlayer.message_effect_id = getLastCreatedText()


def UpdateAura():
    @Name "— Update aura"

    destroyEffect(eventPlayer.chill_effect_id)

    if eventPlayer.preferences[Preference.AURA]:
        if eventPlayer.preferences[Preference.HIDE_AURA_IN_FIRST_PERSON] and not eventPlayer.preferences[Preference.THIRD_PERSON]:
            switch eventPlayer.preferences[Preference.AURA_EFFECT]:
                case ChillEffect.SPARKLES:
                    AuraHidden(Effect.SPARKLES, eventPlayer)
                    break
                case ChillEffect.CLOUD:
                    AuraHidden(Effect.CLOUD, eventPlayer)
                    break
                case ChillEffect.LIGHT_SHAFT:
                    AuraHidden(Effect.LIGHT_SHAFT, eventPlayer.getPosition())
                    break
                case ChillEffect.GOOD_AURA:
                    AuraHidden(Effect.GOOD_AURA, eventPlayer)
                    break
                case ChillEffect.BAD_AURA:
                    AuraHidden(Effect.BAD_AURA, eventPlayer)
                    break
                case ChillEffect.RING:
                    AuraHidden(Effect.RING, eventPlayer)
                    break
                case ChillEffect.SPHERE:
                    AuraHidden(Effect.SPHERE, eventPlayer)
                    break
        else:
            switch eventPlayer.preferences[Preference.AURA_EFFECT]:
                case ChillEffect.SPARKLES:
                    Aura(Effect.SPARKLES, eventPlayer)
                    break
                case ChillEffect.CLOUD:
                    Aura(Effect.CLOUD, eventPlayer)
                    break
                case ChillEffect.LIGHT_SHAFT:
                    Aura(Effect.LIGHT_SHAFT, eventPlayer.getPosition())
                    break
                case ChillEffect.GOOD_AURA:
                    Aura(Effect.GOOD_AURA, eventPlayer)
                    break
                case ChillEffect.BAD_AURA:
                    Aura(Effect.BAD_AURA, eventPlayer)
                    break
                case ChillEffect.RING:
                    Aura(Effect.RING, eventPlayer)
                    break
                case ChillEffect.SPHERE:
                    Aura(Effect.SPHERE, eventPlayer)
                    break

        eventPlayer.chill_effect_id = getLastCreatedEntity()

rule "— Draw preferences HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # --- Keyboard HUD ---
    # Cursor
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "▲",
        updateEveryFrame(
            localPlayer.getEyePosition()
            + vect(
                min(43.5, max(-43.5, angleDifference(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]), localPlayer.getHorizontalFacingAngle()))) / 35
                * cosDeg(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]))
                + sinDeg(horizontalAngleOfDirection(localPlayer.previous_position_direction[1])),
                -min(27, max(-21.7, angleDifference(verticalAngleOfDirection( localPlayer.previous_position_direction[1]), localPlayer.getVerticalFacingAngle()))) / 35,
                -min(43.5, max(-43.5, angleDifference(horizontalAngleOfDirection( localPlayer.previous_position_direction[1]), localPlayer.getHorizontalFacingAngle()))) / 35
                * sinDeg(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]))
                + cosDeg(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]))
            )
        ),
        2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.ORANGE,
        SpecVisibility.NEVER
    )
    # Keyboard
    # createInWorldText(
    #     localPlayer if localPlayer.isUsingKeyboard else null,
    #     "{} | {}".format(
    #         angleDifference(horizontalAngleOfDirection(localPlayer.previous_position_direction[1]), localPlayer.getHorizontalFacingAngle()),
    #         angleDifference(verticalAngleOfDirection(localPlayer.previous_position_direction[1]), localPlayer.getVerticalFacingAngle())
    #     ),
    #     menu_vector(0, 0.35),
    #     1,
    #     Clip.NONE,
    #     WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
    #     Color.WHITE,
    #     SpecVisibility.NEVER
    # )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "{}{}".format(
            localPlayer.preferences[Preference.CUSTOM_MESSAGE],
            "|" if getTotalTimeElapsed() % 1 <= 0.5 else " "
        ),
        menu_vector(0, 0.3),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "♥     ♡     ツ     ♪     ★     ▲     ▼",
        menu_vector(0, 0.15),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "~     !     @     #     $     %     ^     &     *     (     )     _     +     backspace",
        menu_vector(0, 0.05),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "`     1     2     3     4     5     6     7     8     9     0     -     =     {     [     |     ",
        menu_vector(0, -0.05),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "q     w     e     r     t     y     u     i     o     p          }     ]     \\",
        menu_vector(0, -0.2),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "a     s     d     f     g     h     j     k     l     :     ;     \"     '",
        menu_vector(0, -0.3),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "          z     x     c     v     b     n     m     <     >     ,     .     ?     /",
        menu_vector(0, -0.4),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "space     •     exit",
        menu_vector(0, -0.55),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )

    # --- Preferences ---
    # Category
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and not localPlayer.isPlayingUno else null,
        "viewing quick settings | {} • go to advanced settings".format(buttonToString(Button.MELEE))
        if not localPlayer.isViewingAdvancedPreferences
        else "viewing advanced settings | {} • go to quick settings".format(buttonToString(Button.MELEE))
        if (localPlayer.preferences_index >= preferences_category_data[0][PreferenceCategoryProperty.STARTING_INDEX]
        and localPlayer.preferences_index <= preferences_category_data[0][PreferenceCategoryProperty.ENDING_INDEX])
        else "viewing advanced settings | {} • go to categories".format(buttonToString(Button.MELEE)),
        orb_vector(0.9),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
        SpecVisibility.NEVER
    )
    # Title
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and not localPlayer.isPlayingUno else null,
        localPlayer.preferences_hud[PreferencesHUD.TITLE],
        orb_vector(0.8),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Preference counter and hotkeys
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and not localPlayer.isPlayingUno else null,
        "{} {} • {} of {} • {} {}".format(
            buttonToString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_PREFERENCE],
            localPlayer.preferences_hud[PreferencesHUD.TOTAL_PREFERENCES],
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.SECONDARY_FIRE)
        ),
        orb_vector(0.7),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
        SpecVisibility.NEVER
    )
    # Parameter
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and not localPlayer.isPlayingUno else null,
        localPlayer.preferences_hud[PreferencesHUD.PARAMETER],
        orb_vector(0.5),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR]],
        SpecVisibility.NEVER
    )
    # Interaction progress
    createProgressBarInWorldText(
        localPlayer if (
            localPlayer.isViewingPreferences or localPlayer.isPlayingUno
        ) and localPlayer.interaction_progress > 0 else null,
        localPlayer.interaction_progress,
        null,
        orb_vector(0.4),
        0.8,
        Clip.NONE,
        rainbow_rgb()
        if localPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences[Preference.BASE_COLOR]],
        null,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # Parameter counter and hotkeys
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and not localPlayer.isPlayingUno else null,
        "{} • jump".format(buttonToString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.CATEGORY
        else "{} {} {}  |  {} • reset".format(
            buttonToString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.RELOAD)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.MULTIPLE_CHOICE
        else "{} {} {}  |  {} • random  |  {} • reset".format(
            buttonToString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.INTERACT),
            buttonToString(Button.RELOAD)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.COLOR_PICKER
        else "{} {} {}  |  {} • interact".format(
            buttonToString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.INTERACT)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE
        else "{} {} {}   |  {} • random  |  {} • interact".format(
            buttonToString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.RELOAD),
            buttonToString(Button.INTERACT)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM
        else "{} • toggle".format(buttonToString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.BOOLEAN
        else "{0} {1} • {2} {3}  |  {4} + {0} {5} • {6} {4} + {3}  |  {7} • reset".format(
            buttonToString(Button.ABILITY_1),
            iconString(Icon.ARROW_DOWN),
            iconString(Icon.ARROW_UP),
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.CROUCH),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.RELOAD)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.NUMERIC
        else "{0} {1} • {2} {3}  |  {4} + {0} {5} • {6} {4} + {3}  |  {8} • reverse  |  {7} • reset".format(
            buttonToString(Button.ABILITY_1),
            iconString(Icon.ARROW_DOWN),
            iconString(Icon.ARROW_UP),
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.CROUCH),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.RELOAD),
            buttonToString(Button.INTERACT)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.NUMERIC_REVERSIBLE
        else "{0} {1} • {2} {3}  |  {4} + {0} {5} • {6} {4} + {3}  |  {8} • random  |  {7} • reset".format(
            buttonToString(Button.ABILITY_1),
            iconString(Icon.ARROW_DOWN),
            iconString(Icon.ARROW_UP),
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.CROUCH),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.RELOAD),
            buttonToString(Button.INTERACT)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.MULTIPLE_CHOICE_RANDOM
        else "hold {} • interact".format(buttonToString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT
        or localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.KEYBOARD
        else "hold {} • enable".format(buttonToString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT_BOOLEAN
        else "",
        orb_vector(0.4),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
        SpecVisibility.NEVER
    )
    # Description
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and not localPlayer.isPlayingUno else null,
        localPlayer.preferences_hud[PreferencesHUD.DESCRIPTION],
        orb_vector(0.2),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Chill or zen mode required
    createInWorldText(
        localPlayer
        if localPlayer.preferences_hud[PreferencesHUD.CHILL_REQUIRED]
        and localPlayer.isViewingPreferences
        and not localPlayer.isPlayingUno
        else null,
        "Chill / zen required" if localPlayer.preferences_hud[PreferencesHUD.CHILL_REQUIRED] and not localPlayer.preferences[Preference.PLAYER_MODE]
        else "",
        localPlayer.base_vector,
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.ORANGE,
        SpecVisibility.NEVER
    )


def UpdatePreferencesHUD():
    @Name "— Update preferences HUD"

    eventPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] = [
        cat[PreferenceCategoryProperty.COLOR] for cat in preferences_category_data
        if (dynamic_preferences_index(eventPlayer) >= cat[PreferenceCategoryProperty.STARTING_INDEX]
        and dynamic_preferences_index(eventPlayer) <= cat[PreferenceCategoryProperty.ENDING_INDEX])
    ][0]
    eventPlayer.preferences_hud[PreferencesHUD.TITLE] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TITLE]
    eventPlayer.preferences_hud[PreferencesHUD.CURRENT_PREFERENCE] = eventPlayer.preferences_index + 1
    if eventPlayer.isViewingAdvancedPreferences:
        eventPlayer.preferences_hud[PreferencesHUD.TOTAL_PREFERENCES] = len(preferences_data)
    else:
        eventPlayer.preferences_hud[PreferencesHUD.TOTAL_PREFERENCES] = len(quick_preferences_data)
    eventPlayer.preferences_hud[PreferencesHUD.TYPE] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]
    eventPlayer.preferences_hud[PreferencesHUD.CHILL_REQUIRED] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.CHILL_REQUIRED]
    if not eventPlayer.preferences[Preference.PLAYER_MODE] and preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.CHILL_REQUIRED]:
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = ExtendedColor.GRAY
    elif preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.COLORS][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]:
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.COLORS][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
    elif preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.COLORS]:
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.COLORS]
    else:
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = ExtendedColor.WHITE
    switch eventPlayer.preferences_hud[PreferencesHUD.TYPE]:
        case PreferenceType.BOOLEAN:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]:
                eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "on"
            else:
                eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "off"
            break
        case PreferenceType.MULTIPLE_CHOICE:
        case PreferenceType.MULTIPLE_CHOICE_RANDOM:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
            eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + 1, len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS]), iconString(Icon.ARROW_RIGHT))
            break
        case PreferenceType.INTERACT_MULTIPLE_CHOICE:
        case PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
            eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + 1, len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1]), iconString(Icon.ARROW_RIGHT))
            break
        case PreferenceType.COLOR_PICKER:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = extended_color_data[eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
            eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + 1, len(extended_color_data), iconString(Icon.ARROW_RIGHT))
            break
        case PreferenceType.CATEGORY:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "• • •"
            break
        case PreferenceType.NUMERIC:
        case PreferenceType.NUMERIC_REVERSIBLE:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "{}{}".format(eventPlayer.preferences[dynamic_preferences_index(eventPlayer)], preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.SUFFIX] if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.SUFFIX] else " units")
            break
        case PreferenceType.KEYBOARD:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = eventPlayer.preferences[Preference.CUSTOM_MESSAGE]
            break
        default:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = ""
            break
    if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.DESCRIPTIONS][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]:
        eventPlayer.preferences_hud[PreferencesHUD.DESCRIPTION] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.DESCRIPTIONS][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
    else:
        eventPlayer.preferences_hud[PreferencesHUD.DESCRIPTION] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.DESCRIPTIONS]


rule "— UNO • Draw UNO HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # Timer
    createProgressBarInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        uno_timer,
        null,
        orb_vector(1),
        0.6,
        Clip.NONE,
        rainbow_rgb(),
        Color.WHITE,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # Header
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        f"Playing UNO | {buttonToString(Button.MELEE)} • Leave game",
        orb_vector(0.9),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb(),
        SpecVisibility.NEVER
    )
    # Top card
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        global_uno_hud[GlobalUnoHUD.TOP_CARD],
        orb_vector(0.8),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        extended_color_data[global_uno_hud[GlobalUnoHUD.TOP_CARD_COLOR]],
        SpecVisibility.NEVER
    )
    # Current player
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        localPlayer.uno_hud[UnoHUD.CURRENT_TURN_DETAILS],
        orb_vector(0.7),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Current card
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        localPlayer.uno_hud[UnoHUD.CURRENT_CARD],
        orb_vector(0.5),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        extended_color_data[localPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR]],
        SpecVisibility.NEVER
    )
    # Card counter and hotkeys
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        "{} {} • {} • {} {}{}{}{}{}{}{}".format(
            buttonToString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            localPlayer.uno_hud[UnoHUD.CURRENT_TOTAL_CARDS],
            iconString(Icon.ARROW_RIGHT),
            buttonToString(Button.SECONDARY_FIRE),
            f"  |  {buttonToString(Button.JUMP)} • Play"
            if localPlayer.uno_hud[UnoHUD.PLAY] else "",
            f"  |  {buttonToString(Button.INTERACT)} • Cycle color"
            if localPlayer.uno_hud[UnoHUD.PLAY] else "",
            f"  |  {buttonToString(Button.RELOAD)} • Draw"
            if localPlayer.uno_hud[UnoHUD.DRAW] else "",
            f"  |  {iconString(Icon.WARNING)}  {buttonToString(Button.ULTIMATE)} • Challenge Wild +4"
            if localPlayer.uno_hud[UnoHUD.CHALLENGE] else "",
            f"  |  {iconString(Icon.WARNING)}  {buttonToString(Button.ABILITY_1)} • Call UNO!"
            if localPlayer.uno_hud[UnoHUD.CALL] else "",
            f"  |  {buttonToString(Button.ABILITY_2)} • Catch UNO!"
            if localPlayer.uno_hud[UnoHUD.CATCH] else ""
        ),
        orb_vector(0.4),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR]],
        SpecVisibility.NEVER
    )
    # Description
    createInWorldText(
        localPlayer if localPlayer.isPlayingUno else null,
        localPlayer.uno_hud[UnoHUD.DETAILS],
        orb_vector(0.2),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )


def UpdateGlobalUnoHUD():
    @Name "— Update global UNO HUD"

    global_uno_hud[GlobalUnoHUD.TOP_CARD] = "Top card: {} {} ({})".format(
        [i for i in uno_icon_data if i[IconData.TYPE] == uno_top_card[UnoCard.TYPE]][0][IconData.ICON],
        [c for c in uno_card_data if c[CardData.TYPE] == uno_top_card[UnoCard.TYPE]][0][CardData.NAME],
        uno_top_card[UnoCard.COLOR]
    )
    global_uno_hud[GlobalUnoHUD.TOP_CARD_COLOR] = extended_color_data[uno_top_card[UnoCard.COLOR]]


def UpdateUnoHUD():
    @Name "— Update UNO HUD"

    eventPlayer.uno_hud[UnoHUD.CURRENT_TURN_DETAILS] = "Current turn: {} | {}".format(
        uno_players[uno_player_index],
        "{} until your turn".format(
            (
                (uno_players.index(eventPlayer) - uno_player_index)
                * uno_direction
            ) % len(uno_players)
        ) if (
            (
                (uno_players.index(eventPlayer) - uno_player_index)
                * uno_direction
            ) % len(uno_players)
        ) != 1 else "Your turn next"
    )
    eventPlayer.uno_hud[UnoHUD.CURRENT_CARD] = "{} {} ({})".format(
        [
            i for i in uno_icon_data
            if i[IconData.TYPE] == eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE]
        ][0][IconData.ICON],
        [
            c for c in uno_card_data
            if c[CardData.TYPE] == eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.TYPE]
        ][0][CardData.NAME],
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        if eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        else "Wild"
    )
    eventPlayer.uno_hud[UnoHUD.CURRENT_TOTAL_CARDS] = "{} of {}".format(
        eventPlayer.uno_selected_card + 1,
        len(eventPlayer.uno_hand)
    )
    eventPlayer.uno_hud[UnoHUD.CURRENT_CARD_COLOR] = extended_color_data[
        eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        if eventPlayer.uno_hand[eventPlayer.uno_selected_card][UnoCard.COLOR]
        else ExtendedColor.RAINBOW
    ]
    eventPlayer.uno_hud[UnoHUD.DETAILS] = ""
    eventPlayer.uno_hud[UnoHUD.PLAY] = uno_players.index(eventPlayer) == uno_player_index
    eventPlayer.uno_hud[UnoHUD.DRAW] = uno_players.index(eventPlayer) == uno_player_index and uno_pending_draw > 0
    eventPlayer.uno_hud[UnoHUD.SKIP] = uno_players.index(eventPlayer) == uno_player_index and uno_pending_draw == 0
    eventPlayer.uno_hud[UnoHUD.CHALLENGE] = false
    eventPlayer.uno_hud[UnoHUD.CALL] = len(eventPlayer.uno_hand) == 1
    eventPlayer.uno_hud[UnoHUD.CATCH] = false