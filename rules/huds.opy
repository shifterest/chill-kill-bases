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
        and localPlayer.uiState != UIState.DREAM_MODE
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
        and localPlayer.uiState == UIState.MODERATING
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
        and localPlayer.uiState != UIState.DREAM_MODE
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
        if localPlayer.uiState == UIState.MODERATING
        or localPlayer.uiState == UIState.DREAM_MODE
        else localPlayer,
        localPlayer.onscreen_hud[OnScreenHUD.MAIN],
        HudPosition.TOP,
        3,
        rainbow()
        if localPlayer.onscreen_hud[OnScreenHUD.COLOR] == ExtendedColor.RAINBOW
        else localPlayer.onscreen_hud[OnScreenHUD.COLOR],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    # Moderator mode
    hudSubtext(
        localPlayer if localPlayer.uiState == UIState.MODERATING else null,
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
        if localPlayer.uiState == UIState.MODERATING else
        "{}{}{}{}{}{}{}{}".format(
            "{} • create base\n{} • cancel\n".format(
                buttonToString(Button.PRIMARY_FIRE), buttonToString(Button.INTERACT)
            )
            if localPlayer.uiState == UIState.BASE_CREATION
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
            or localPlayer.preferences[Preference.THIRD_PERSON] == ThirdPersonCamera.FRONT
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
            localPlayer.uiState == UIState.VIEWING_PREFERENCES
            or localPlayer.uiState == UIState.MODERATING
            or localPlayer.uiState == UIState.KEYBOARD_INPUT
            or localPlayer.uiState == UIState.DREAM_MODE
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
        localPlayer.progress_hud[ProgHUD.TEXT],
        HudPosition.TOP,
        70,
        rainbow()
        if localPlayer.progress_hud[ProgHUD.COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.progress_hud[ProgHUD.COLOR]],
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
        rainbow()
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
                rainbow(),
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
                rainbow(),
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
                rainbow(),
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
                rainbow(),
                HudReeval.VISIBILITY_AND_COLOR,
                SpecVisibility.DEFAULT
            )
            break

    # --- In-world ---
    # Base indicator
    createIcon(
        localPlayer
        if localPlayer.base_vector
        and localPlayer.uiState != UIState.VIEWING_PREFERENCES
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
        rainbow()
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
        or localPlayer.uiState == UIState.MODERATING
        or localPlayer.uiState == UIState.KEYBOARD_INPUT
        or localPlayer.uiState == UIState.DREAM_MODE
        else localPlayer,
        Effect.ORB,
        rainbow()
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
        or localPlayer.uiState == UIState.MODERATING
        or localPlayer.uiState == UIState.KEYBOARD_INPUT
        or localPlayer.uiState == UIState.DREAM_MODE
        or localPlayer.uiState != UIState.VIEWING_PREFERENCES
        else localPlayer,
        Effect.LIGHT_SHAFT,
        rainbow()
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
        or localPlayer.uiState == UIState.MODERATING
        or localPlayer.uiState == UIState.KEYBOARD_INPUT
        or localPlayer.uiState == UIState.DREAM_MODE
        or localPlayer.uiState != UIState.VIEWING_PREFERENCES
        or not localPlayer.isViewingAdvancedPreferences
        else localPlayer,
        Effect.RING,
        rainbow()
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

    if eventPlayer.uiState == UIState.BASE_CREATION:
        # Base sphere
        createEffect(
            eventPlayer if eventPlayer.uiState == UIState.BASE_CREATION else null,
            Effect.SPHERE,
            rainbow()
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
                rainbow()
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
                and eventPlayer.uiState != UIState.DREAM_MODE
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
                and eventPlayer.uiState != UIState.DREAM_MODE
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
                rainbow()
                if eventPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
                else extended_color_data[eventPlayer.preferences[Preference.BASE_COLOR]],
                eventPlayer.base_vector
                if eventPlayer.base_vector
                else null,
                eventPlayer.preferences[Preference.BASE_SIZE],
                EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
            )
            eventPlayer.base_effect_id = getLastCreatedEntity()
            # base mode icon
            createInWorldText(
                [
                    p for p in getAllPlayers()
                    if p.active_base_owner != eventPlayer
                    and p.uiState != UIState.DREAM_MODE
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
                    and p.uiState != UIState.DREAM_MODE
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
            rainbow()
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

