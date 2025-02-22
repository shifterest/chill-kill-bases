rule "HUDs":
    @Disabled
    @Delimiter


rule "— Draw global HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # LEFT
    hudSubheader(
        null if localPlayer.dream_preferences[Dream.DREAM_MODE] else localPlayer,
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

    # TOP
    # server load
    hudSubheader(
        localPlayer
        if ("{}".format(localPlayer) in moderator_list.concat(god_list) or localPlayer == hostPlayer)
        and not localPlayer.dream_preferences[Dream.DREAM_MODE]
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
        if ("{}".format(localPlayer) in moderator_list.concat(god_list) or localPlayer == hostPlayer)
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
    # moderator mode hotkey
    hudSubheader(
        localPlayer
        if ("{}".format(localPlayer) in moderator_list.concat(god_list) or localPlayer == hostPlayer)
        and not localPlayer.dream_preferences[Dream.DREAM_MODE]
        else null,
        "{} + {} • toggle moderator mode\n ".format(
            buttonString(Button.CROUCH), buttonString(Button.RELOAD)
        ) if localPlayer.game_preferences[Game.SHOW_HOTKEYS] else " ",
        HudPosition.TOP,
        2,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # main info
    hudSubtext(
        null
        if localPlayer.isInModeratorMode
        or localPlayer.dream_preferences[Dream.DREAM_MODE]
        else localPlayer,
        localPlayer.onscreen_hud[OnScreenHUD.MAIN],
        HudPosition.TOP,
        3,
        colors_data[main_preferences_data[Main.PLAYER_MODE][Preference.COLORS][localPlayer.main_preferences[Main.PLAYER_MODE]]],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    # moderator mode
    hudSubtext(
        localPlayer if localPlayer.isInModeratorMode else null,
        "{} {}{} • {}".format(
            heroIcon(localPlayer.focused_player.getCurrentHero()),
            localPlayer.focused_player,
            " (host)" if localPlayer.focused_player == hostPlayer
            else " (god)" if "{}".format(localPlayer.focused_player) in god_list
            else " (moderator)" if "{}".format(localPlayer.focused_player) in moderator_list
            else "",
            main_preferences_data[Main.PLAYER_MODE][Preference.PARAMETERS][localPlayer.focused_player.main_preferences[Main.PLAYER_MODE]]
        ),
        HudPosition.TOP,
        3,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    hudSubheader(
        localPlayer if localPlayer.game_preferences[Game.SHOW_HOTKEYS] else null,
        "{} {} • switch players • {} {}\n{} • paralyze / unparalyze\n{} • kill / resurrect\n{} • ban / unban text and voice chat{}\nhold {} • teleport to player\nhold {} • teleport player to you\nhold {} • remove base\nhold {} + {} • ban player".format(
            buttonString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonString(Button.SECONDARY_FIRE),
            buttonString(Button.JUMP),
            buttonString(Button.RELOAD),
            buttonString(Button.MELEE),
            "\n{} • promote player / demote moderator".format(
                buttonString(Button.ABILITY_2)
            )
            if localPlayer == hostPlayer else "",
            buttonString(Button.ULTIMATE),
            buttonString(Button.INTERACT),
            buttonString(Button.CROUCH),
            buttonString(Button.ABILITY_1),
            buttonString(Button.MELEE)
        )
        if localPlayer.isInModeratorMode else
        "{}{}{}{}{}{}{}".format(
            "{} • create base\n{} • cancel\n".format(
                buttonString(Button.PRIMARY_FIRE), buttonString(Button.INTERACT)
            )
            if localPlayer.isInBaseCreationMode
            else "hold {} • create base\n".format(buttonString(Button.INTERACT))
            if not localPlayer.base_vector
            else "",
            "{}".format(
                "hold {} • fast travel to {} {}'s base\n".format(
                    buttonString(Button.MELEE),
                    heroIcon(friendly_base_in_crosshair(localPlayer).getCurrentHero()),
                    friendly_base_in_crosshair(localPlayer)
                )
                if friendly_base_in_crosshair(localPlayer)
                and (
                    localPlayer.main_preferences[Main.PLAYER_MODE]
                    or not localPlayer.main_preferences[Main.PLAYER_MODE]
                    and localPlayer.base_settled_owner
                )
                else "hold {} • fast travel to your base\n".format(buttonString(Button.MELEE))
                if localPlayer.base_vector
                and localPlayer.base_settled_owner != localPlayer
                and (
                    localPlayer.main_preferences[Main.PLAYER_MODE]
                    or not localPlayer.main_preferences[Main.PLAYER_MODE]
                    and localPlayer.base_settled_owner
                )
                else "hold {} • fast travel to last position\n".format(buttonString(Button.MELEE))
                if localPlayer.main_preferences[Main.PLAYER_MODE]
                and localPlayer.base_settled_owner == localPlayer
                and localPlayer.previous_position
                else ""
            )
            if (
                (localPlayer.main_preferences[Main.PLAYER_MODE] or localPlayer.base_settled_owner)
                and localPlayer.game_preferences[Game.FAST_TRAVEL]
                and not localPlayer.mount
                # and localPlayer.base_settled_owner == localPlayer
            )
            else "",
            "hold {} • switch hero\nhold {} • pack base\n".format(
                buttonString(Button.RELOAD), buttonString(Button.INTERACT)
            )
            if localPlayer.base_settled_owner == localPlayer
            else "",
            "{} + {} • {}\n".format(
                buttonString(Button.CROUCH), buttonString(Button.MELEE),
                "self-unparalyze" if localPlayer.isParalyzed else "self-paralyze"
            )
            if localPlayer.main_preferences[Main.PLAYER_MODE]
            and localPlayer.game_preferences[Game.SELF_PARALYSIS]
            else "",
            "hold {} + {} • pack base\n".format(
                buttonString(Button.CROUCH), buttonString(Button.INTERACT)
            )
            if localPlayer.base_vector
            and localPlayer.base_settled_owner != localPlayer
            and localPlayer.game_preferences[Game.REMOTE_PACK_BASE]
            else "",
            "{} + {} • unmount {} {}\n".format(
                buttonString(Button.PRIMARY_FIRE),
                buttonString(Button.SECONDARY_FIRE),
                heroIcon(localPlayer.rider.getCurrentHero()),
                localPlayer.rider
            )
            if localPlayer.rider else "",
            "{} + {} • unmount from {} {}".format(
                buttonString(Button.ABILITY_1),
                buttonString(Button.INTERACT),
                heroIcon(localPlayer.mount.getCurrentHero()),
                localPlayer.mount
            )
            if localPlayer.mount
            else "{} • ride {} {}".format(
                buttonString(Button.INTERACT),
                heroIcon(localPlayer.getPlayerClosestToReticle(Team.ALL).getCurrentHero()),
                localPlayer.getPlayerClosestToReticle(Team.ALL)
            )
            if localPlayer.main_preferences[Main.PLAYER_MODE]
            and localPlayer.getPlayerClosestToReticle(Team.ALL).hasSpawned()
            and not localPlayer.getPlayerClosestToReticle(Team.ALL).rider
            and localPlayer.getPlayerClosestToReticle(Team.ALL) != localPlayer.rider
            and localPlayer.getPlayerClosestToReticle(Team.ALL).special_preferences[Special.ALLOW_MOUNTING]
            and isInMountingRange(localPlayer)
            and not localPlayer.mount
            else ""
        )
        if localPlayer.game_preferences[Game.SHOW_HOTKEYS] and not (
            localPlayer.isViewingPreferences
            or localPlayer.isInModeratorMode
            or localPlayer.isUsingKeyboard
            or localPlayer.dream_preferences[Dream.DREAM_MODE]
        ) else "",
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # padding
    hudSubheader(
        localPlayer,
        " ",
        HudPosition.TOP,
        69,
        Color.WHITE,
        HudReeval.VISIBILITY,
        SpecVisibility.NEVER
    )
    # commmon progress bar
    progressBarHud(
        localPlayer if localPlayer.progress > 0 and localPlayer.progress < 100 else null,
        localPlayer.progress,
        localPlayer.progress_hud[ProgressHUD.TEXT],
        HudPosition.TOP,
        70,
        rainbow_rgb()
        if localPlayer.progress_hud[ProgressHUD.COLOR] == Colors.RAINBOW
        else colors_data[localPlayer.progress_hud[ProgressHUD.COLOR]],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # base settlement progress bar
    progressBarHud(
        localPlayer if localPlayer.base_progress > 0 and localPlayer.base_progress < 100 else null,
        localPlayer.base_progress,
        localPlayer.onscreen_hud[OnScreenHUD.SETTLEMENT],
        HudPosition.TOP,
        71,
        rainbow_rgb()
        if localPlayer.base_within_owner.base_preferences[Base.COLOR]
        == Colors.RAINBOW
        else colors_data[
            localPlayer.base_within_owner.base_preferences[Base.COLOR]
        ],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )

    # RIGHT
    # game info
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

    # IN-WORLD
    # base indicator
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
    # base outline
    createEffect(
        localPlayer if localPlayer.base_settled_owner else null,
        Effect.RING,
        rainbow_rgb()
        if localPlayer.base_settled_owner.base_preferences[Base.COLOR]
        == Colors.RAINBOW
        else colors_data[
            localPlayer.base_settled_owner.base_preferences[Base.COLOR]
        ],
        localPlayer.base_settled_owner.base_vector,
        localPlayer.base_settled_owner.base_preferences[Base.SIZE],
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # center orb
    createEffect(
        null
        if localPlayer.base_settled_owner != localPlayer
        or localPlayer.isInModeratorMode
        or localPlayer.isUsingKeyboard
        or localPlayer.dream_preferences[Dream.DREAM_MODE]
        or localPlayer.cubic_bezier > 0.3
        else localPlayer,
        Effect.ORB,
        rainbow_rgb()
        if localPlayer.base_preferences[Base.COLOR] == Colors.RAINBOW
        else colors_data[localPlayer.base_preferences[Base.COLOR]],
        localPlayer.base_vector,
        orb_radius,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    createEffect(
        null
        if localPlayer.base_settled_owner != localPlayer
        or localPlayer.isInModeratorMode
        or localPlayer.isUsingKeyboard
        or localPlayer.dream_preferences[Dream.DREAM_MODE]
        or localPlayer.cubic_bezier <= 0.3
        else localPlayer,
        Effect.SPHERE,
        rainbow_rgb()
        if localPlayer.base_preferences[Base.COLOR] == Colors.RAINBOW
        else colors_data[localPlayer.base_preferences[Base.COLOR]],
        localPlayer.base_vector,
        orb_radius + ((localPlayer.base_preferences[Base.SIZE] - orb_radius) * (localPlayer.cubic_bezier ** 3)),
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )


def UpdateHUD():
    @Name "— Update HUD"

    if eventPlayer.base_settled_owner == eventPlayer:
        eventPlayer.onscreen_hud[OnScreenHUD.MAIN] = "look at the center orb to change your preferences"
    else:
        eventPlayer.onscreen_hud[OnScreenHUD.MAIN] = "you are currently{} in {} mode".format(
            " invisible"
            if eventPlayer.main_preferences[Main.PLAYER_MODE]
            and eventPlayer.special_preferences[Special.INVISIBILITY]
            else "",
            main_preferences_data[Main.PLAYER_MODE][Preference.PARAMETERS][eventPlayer.main_preferences[Main.PLAYER_MODE]]
        )

    eventPlayer.onscreen_hud[OnScreenHUD.SETTLEMENT] = "entering {}{} {}...".format(
        heroIcon(eventPlayer.base_within_owner.getCurrentHero()) if eventPlayer.base_within_owner != eventPlayer else "",
        "{}'s".format(eventPlayer.base_within_owner) if eventPlayer.base_within_owner != eventPlayer else "your",
        "base"
    )

    if eventPlayer.base_vector:
        eventPlayer.in_world_hud[InWorldHUD.BASE_MODE_ICON] = [
            abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
            abilityIconString(Hero.ZARYA, Button.ABILITY_1),
            iconString(Icon.NO),
            abilityIconString(Hero.CASSIDY, Button.ULTIMATE)
        ][eventPlayer.main_preferences[Main.BASE_MODE]]
        eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = ""
        if eventPlayer.base_preferences[Base.GRAVITY] != 100:
            eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "{} • {} gravity".format(
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY],
                eventPlayer.base_preferences[Base.GRAVITY]
            )
        if eventPlayer.base_preferences[Base.SPEED] != 100:
            eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "{} • {} speed".format(
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY],
                eventPlayer.base_preferences[Base.SPEED]
            )
        if eventPlayer.base_preferences[Base.JUMP_SPEED] != 100:
            eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "{} • {} jump speed".format(
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY],
                eventPlayer.base_preferences[Base.JUMP_SPEED]
            )
    else:
        eventPlayer.in_world_hud[InWorldHUD.BASE_MODE_ICON] = abilityIconString(Hero.ZENYATTA, Button.ULTIMATE)
        eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY] = "none"


def UpdateModeratorListHUD():
    @Name "— Update moderator list HUD"

    moderator_list_hud = ""

    for moderator_list_hud_counter in range(len(moderator_list)):
        if moderator_list[moderator_list_hud_counter] in ["{}".format(p) for p in getAllPlayers().exclude(hostPlayer)]:
            moderator_list_hud = "{}{}   • {}".format(moderator_list_hud, "\n", moderator_list[moderator_list_hud_counter])

    if moderator_list_hud != "":
        moderator_list_hud = "\n\nmoderators:{}".format(moderator_list_hud)


def CreateBaseEffects():
    @Name "— Create base effects"

    if eventPlayer.isInBaseCreationMode:
        # base sphere
        createEffect(
            eventPlayer if eventPlayer.isInBaseCreationMode else null,
            Effect.SPHERE,
            rainbow_rgb()
            if eventPlayer.base_preferences[Base.COLOR] == Colors.RAINBOW
            else colors_data[eventPlayer.base_preferences[Base.COLOR]],
            updateEveryTick(eventPlayer.getPosition()),
            eventPlayer.base_preferences[Base.SIZE],
            EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
        )
        eventPlayer.sphere_effect_id = getLastCreatedEntity()
    else:
        # base sphere
        createEffect(
            [p for p in getAllPlayers() if p.base_settled_owner != eventPlayer],
            Effect.SPHERE,
            rainbow_rgb()
            if eventPlayer.base_preferences[Base.COLOR] == Colors.RAINBOW
            else colors_data[eventPlayer.base_preferences[Base.COLOR]],
            eventPlayer.base_vector
            if eventPlayer.base_vector
            else null,
            eventPlayer.base_preferences[Base.SIZE],
            EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
        )
        eventPlayer.sphere_effect_id = getLastCreatedEntity()
        # base mode icon
        createInWorldText(
            [
                p for p in getAllPlayers()
                if p.base_settled_owner != eventPlayer
                and not p.dream_preferences[Dream.DREAM_MODE]
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
        # base description
        createInWorldText(
            [
                p for p in getAllPlayers()
                if p.base_settled_owner != eventPlayer
                and not p.dream_preferences[Dream.DREAM_MODE]
            ],
            "{} {}'s base{}".format(
                heroIcon(eventPlayer.getCurrentHero()),
                eventPlayer,
                eventPlayer.in_world_hud[InWorldHUD.BASE_SUMMARY]
            ),
            eventPlayer.base_vector + Vector.UP * (eventPlayer.base_preferences[Base.SIZE] + 0.2),
            1,
            Clip.SURFACES,
            WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
            Color.WHITE,
            SpecVisibility.DEFAULT
        )
        eventPlayer.description_effect_id = getLastCreatedText()


def DestroyBaseEffects():
    @Name "— Destroy base effects"

    if eventPlayer.isInModeratorMode:
        destroyEffect(eventPlayer.focused_player.sphere_effect_id)
        destroyInWorldText(eventPlayer.focused_player.icon_effect_id)
        destroyInWorldText(eventPlayer.focused_player.description_effect_id)
    else:
        destroyEffect(eventPlayer.sphere_effect_id)
        destroyInWorldText(eventPlayer.icon_effect_id)
        destroyInWorldText(eventPlayer.description_effect_id)


def UpdateMessage():
    @Name "— Update custom message"

    destroyInWorldText(eventPlayer.message_effect_id)

    if eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE]:
        createInWorldText(
            null
            if not eventPlayer.hasSpawned()
            or eventPlayer.isInvisible
            or eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility1()
            else getAllPlayers(),
            eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE],
            updateEveryTick(eventPlayer.getEyePosition())
            + (
                Vector.UP
                * (
                    (eventPlayer.hero_preferences[Hero.SIZE] / 160)
                    if eventPlayer.main_preferences[Main.PLAYER_MODE]
                    else 0.625
                )
            ),
            1.5,
            Clip.SURFACES,
            WorldTextReeval.VISIBILITY_POSITION_AND_COLOR,
            rainbow_rgb()
            if eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE_COLOR] == Colors.RAINBOW
            else colors_data[eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE_COLOR]],
            SpecVisibility.DEFAULT
        )

        eventPlayer.message_effect_id = getLastCreatedText()


def UpdateAura():
    @Name "— Update aura"

    destroyEffect(eventPlayer.chill_effect_id)

    if eventPlayer.effects_preferences[Effects.AURA]:
        if eventPlayer.effects_preferences[Effects.HIDE_AURA_IN_FIRST_PERSON] and not eventPlayer.game_preferences[Game.THIRD_PERSON]:
            switch eventPlayer.effects_preferences[Effects.AURA_EFFECT]:
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
            switch eventPlayer.effects_preferences[Effects.AURA_EFFECT]:
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

