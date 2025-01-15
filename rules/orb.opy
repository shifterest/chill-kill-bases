#!mainFile "../orb.opy"

#!define UpdateSubPreferencesHUD(subpreference, data, preferences)\
eventPlayer.preferences_hud[PreferencesHUD.TITLE] = data[eventPlayer.main_preferences[subpreference]][Preference.TITLE]\
eventPlayer.preferences_hud[PreferencesHUD.CURRENT_PREFERENCE] = eventPlayer.main_preferences[subpreference] + 1\
eventPlayer.preferences_hud[PreferencesHUD.TOTAL_PREFERENCES] = len(data)\
eventPlayer.preferences_hud[PreferencesHUD.TYPE] = data[eventPlayer.main_preferences[subpreference]][Preference.TYPE]\
eventPlayer.preferences_hud[PreferencesHUD.CHILL_UNBOUND] = data[eventPlayer.main_preferences[subpreference]][Preference.CHILL_UNBOUND]\
if not eventPlayer.main_preferences[Main.PLAYER_MODE] and data[eventPlayer.main_preferences[subpreference]][Preference.CHILL_UNBOUND]:\
    eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = Colors.GRAY\
elif data[eventPlayer.main_preferences[subpreference]][Preference.COLORS][preferences[eventPlayer.main_preferences[subpreference]]]:\
    if len(data[eventPlayer.main_preferences[subpreference]][Preference.COLORS]) > 1:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = data[eventPlayer.main_preferences[subpreference]][Preference.COLORS][preferences[eventPlayer.main_preferences[subpreference]]]\
    else:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = data[eventPlayer.main_preferences[subpreference]][Preference.COLORS]\
else:\
    eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = Colors.WHITE\
switch eventPlayer.preferences_hud[PreferencesHUD.TYPE]:\
    case PreferenceType.MULTIPLE_CHOICE:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = data[eventPlayer.main_preferences[subpreference]][Preference.PARAMETERS][preferences[eventPlayer.main_preferences[subpreference]]]\
        eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), preferences[eventPlayer.main_preferences[subpreference]] + 1, len(data[eventPlayer.main_preferences[subpreference]][Preference.PARAMETERS]), iconString(Icon.ARROW_RIGHT))\
        break\
    case PreferenceType.INTERACT_MULTIPLE_CHOICE:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = data[eventPlayer.main_preferences[subpreference]][Preference.PARAMETERS][1][preferences[eventPlayer.main_preferences[subpreference]]]\
        eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), preferences[eventPlayer.main_preferences[subpreference]] + 1, len(data[eventPlayer.main_preferences[subpreference]][Preference.PARAMETERS][1]), iconString(Icon.ARROW_RIGHT))\
        break\
    case PreferenceType.COLOR_PICKER:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = preferences[eventPlayer.main_preferences[subpreference]]\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = colors_data[preferences[eventPlayer.main_preferences[subpreference]]]\
        eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), preferences[eventPlayer.main_preferences[subpreference]] + 1, len(colors_data), iconString(Icon.ARROW_RIGHT))\
        break\
    case PreferenceType.BOOLEAN:\
        if preferences[eventPlayer.main_preferences[subpreference]]:\
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "on"\
        else:\
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "off"\
        break\
    case PreferenceType.NUMERIC:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "{}{}".format(preferences[eventPlayer.main_preferences[subpreference]], data[eventPlayer.main_preferences[subpreference]][Preference.PARAMETERS][3] if data[eventPlayer.main_preferences[subpreference]][Preference.PARAMETERS][3] else " units")\
        break\
    case PreferenceType.KEYBOARD:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE]\
        break\
    default:\
        eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = ""\
        break\
if data[eventPlayer.main_preferences[subpreference]][Preference.DESCRIPTIONS][preferences[eventPlayer.main_preferences[subpreference]]]:\
    eventPlayer.preferences_hud[PreferencesHUD.DESCRIPTION] = data[eventPlayer.main_preferences[subpreference]][Preference.DESCRIPTIONS][preferences[eventPlayer.main_preferences[subpreference]]]\
else:\
    eventPlayer.preferences_hud[PreferencesHUD.DESCRIPTION] = data[eventPlayer.main_preferences[subpreference]][Preference.DESCRIPTIONS]


rule "Preferences":
    @Disabled
    @Delimiter


rule "— Draw preferences HUD":
    @Condition isGameInProgress()
    @Condition isInitialized

    # cursor
    createInWorldText(
        localPlayer if localPlayer.isUsingKeyboard else null,
        "▲",
        updateEveryTick(
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
    # keyboard
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
            localPlayer.effects_preferences[Effects.CUSTOM_MESSAGE],
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
        # PREFERENCES
    # preferences category
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences and localPlayer.isInSubPreference else null,
        "{} • go back".format(buttonString(Button.MELEE)),
        orb_vector(0.9),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        colors_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
        SpecVisibility.NEVER
    )

    # preferences title
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
        localPlayer.preferences_hud[PreferencesHUD.TITLE],
        orb_vector(0.8),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # preferences counter, previous / next preference hotkeys
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
        "{} {} • {} of {} • {} {}".format(
            buttonString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_PREFERENCE],
            localPlayer.preferences_hud[PreferencesHUD.TOTAL_PREFERENCES],
            iconString(Icon.ARROW_RIGHT),
            buttonString(Button.SECONDARY_FIRE)
        ),
        orb_vector(0.7),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        colors_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
        SpecVisibility.NEVER
    )
    # player preference
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
        localPlayer.preferences_hud[PreferencesHUD.PARAMETER],
        orb_vector(0.5),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow_rgb()
        if localPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] == Colors.RAINBOW
        else colors_data[localPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR]],
        SpecVisibility.NEVER
    )
    # preference interaction progress
    createProgressBarInWorldText(
        localPlayer
        if localPlayer.isViewingPreferences
        and localPlayer.interaction_progress > 0
        else null,
        localPlayer.interaction_progress,
        null,
        orb_vector(0.4),
        0.8,
        Clip.NONE,
        rainbow_rgb()
        if localPlayer.base_preferences[Base.COLOR] == Colors.RAINBOW
        else colors_data[localPlayer.base_preferences[Base.COLOR]],
        null,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # player preference counter hotkeys
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
        "{} • see more".format(buttonString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.SUB_PREFERENCE
        else "{} {} {}  |  {} • reset".format(
            buttonString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonString(Button.ABILITY_2),
            buttonString(Button.RELOAD)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.MULTIPLE_CHOICE
        or localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.COLOR_PICKER
        else "{} {} {}  |  {} • interact".format(
            buttonString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonString(Button.ABILITY_2),
            buttonString(Button.INTERACT)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE
        else "{} • toggle".format(buttonString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.BOOLEAN
        else "{0} {1} • {2} {3}  |  {4} + {0} {5} • {6} {4} + {3}  |  {7} • reset".format(
            buttonString(Button.ABILITY_1),
            iconString(Icon.ARROW_DOWN),
            iconString(Icon.ARROW_UP),
            buttonString(Button.ABILITY_2),
            buttonString(Button.CROUCH),
            iconString(Icon.ARROW_LEFT),
            iconString(Icon.ARROW_RIGHT),
            buttonString(Button.RELOAD)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.NUMERIC
        else "hold {} • interact".format(buttonString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT
        or localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.KEYBOARD
        else "hold {} • enable".format(buttonString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT_BOOLEAN
        else "",
        orb_vector(0.4),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        colors_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
        SpecVisibility.NEVER
    )
    # preference description
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
        localPlayer.preferences_hud[PreferencesHUD.DESCRIPTION],
        orb_vector(0.2),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # chill or zen mode required
    createInWorldText(
        localPlayer
        if localPlayer.preferences_hud[PreferencesHUD.CHILL_UNBOUND]
        and localPlayer.isViewingPreferences
        else null,
        "unbound required" if localPlayer.preferences_hud[PreferencesHUD.CHILL_UNBOUND] == ChillUnbound.UNBOUND and localPlayer.main_preferences[Main.PLAYER_MODE] != PlayerMode.UNBOUND
        else "chill / unbound / zen required" if localPlayer.preferences_hud[PreferencesHUD.CHILL_UNBOUND] == ChillUnbound.CHILL and not localPlayer.main_preferences[Main.PLAYER_MODE]
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

    if eventPlayer.isInSubPreference:
        eventPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] = main_preferences_data[eventPlayer.preferences_index][Preference.COLORS]
        switch eventPlayer.preferences_index:
            case Main.GAME:
                UpdateSubPreferencesHUD(Main.GAME, game_preferences_data, eventPlayer.game_preferences)
                break
            case Main.EFFECTS:
                UpdateSubPreferencesHUD(Main.EFFECTS, effects_preferences_data, eventPlayer.effects_preferences)
                break
            case Main.HERO:
                UpdateSubPreferencesHUD(Main.HERO, hero_preferences_data, eventPlayer.hero_preferences)
                break
            case Main.UNBOUND:
                UpdateSubPreferencesHUD(Main.UNBOUND, unbound_preferences_data, eventPlayer.unbound_preferences)
                break
            case Main.SPECIAL:
                UpdateSubPreferencesHUD(Main.SPECIAL, special_preferences_data, eventPlayer.special_preferences)
                break
            case Main.HERO:
                UpdateSubPreferencesHUD(Main.HERO, hero_preferences_data, eventPlayer.hero_preferences)
                break
            case Main.BASE:
                UpdateSubPreferencesHUD(Main.BASE, base_preferences_data, eventPlayer.base_preferences)
                break
            case Main.DREAM:
                UpdateSubPreferencesHUD(Main.DREAM, dream_preferences_data, eventPlayer.dream_preferences)
                break
    else:
        eventPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] = Colors.ORANGE
        eventPlayer.preferences_hud[PreferencesHUD.TITLE] = main_preferences_data[eventPlayer.preferences_index][Preference.TITLE]
        eventPlayer.preferences_hud[PreferencesHUD.CURRENT_PREFERENCE] = eventPlayer.preferences_index + 1
        eventPlayer.preferences_hud[PreferencesHUD.TOTAL_PREFERENCES] = len(main_preferences_data)
        eventPlayer.preferences_hud[PreferencesHUD.TYPE] = main_preferences_data[eventPlayer.preferences_index][Preference.TYPE]
        eventPlayer.preferences_hud[PreferencesHUD.CHILL_UNBOUND] = main_preferences_data[eventPlayer.preferences_index][Preference.CHILL_UNBOUND]
        if not eventPlayer.main_preferences[Main.PLAYER_MODE] and main_preferences_data[eventPlayer.preferences_index][Preference.CHILL_UNBOUND]:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = Colors.GRAY
        elif main_preferences_data[eventPlayer.preferences_index][Preference.COLORS][eventPlayer.main_preferences[eventPlayer.preferences_index]]:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = main_preferences_data[eventPlayer.preferences_index][Preference.COLORS][eventPlayer.main_preferences[eventPlayer.preferences_index]]
        elif main_preferences_data[eventPlayer.preferences_index][Preference.COLORS]:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = main_preferences_data[eventPlayer.preferences_index][Preference.COLORS]
        else:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = Colors.WHITE
        switch eventPlayer.preferences_hud[PreferencesHUD.TYPE]:
            case PreferenceType.BOOLEAN:
                if eventPlayer.main_preferences[eventPlayer.preferences_index]:
                    eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "on"
                else:
                    eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "off"
                break
            case PreferenceType.MULTIPLE_CHOICE:
                eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = main_preferences_data[eventPlayer.preferences_index][Preference.PARAMETERS][eventPlayer.main_preferences[eventPlayer.preferences_index]]
                eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.main_preferences[eventPlayer.preferences_index] + 1, len(main_preferences_data[eventPlayer.preferences_index][Preference.PARAMETERS]), iconString(Icon.ARROW_RIGHT))
                break
            case PreferenceType.SUB_PREFERENCE:
                eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = "• • •"
                break
            default:
                eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = ""
                break
        if main_preferences_data[eventPlayer.preferences_index][Preference.DESCRIPTIONS][eventPlayer.main_preferences[eventPlayer.preferences_index]]:
            eventPlayer.preferences_hud[PreferencesHUD.DESCRIPTION] = main_preferences_data[eventPlayer.preferences_index][Preference.DESCRIPTIONS][eventPlayer.main_preferences[eventPlayer.preferences_index]]
        else:
            eventPlayer.preferences_hud[PreferencesHUD.DESCRIPTION] = main_preferences_data[eventPlayer.preferences_index][Preference.DESCRIPTIONS]


rule "— View / hide preferences":
    @Event eachPlayer
    @Condition eventPlayer.base_settled_owner == eventPlayer
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.dream_preferences[Dream.DREAM_MODE]
    @Condition distance(
        eventPlayer.getEyePosition()
        + distance(eventPlayer.getEyePosition(), eventPlayer.base_vector)
        * eventPlayer.getFacingDirection(),
        eventPlayer.base_vector
    ) <= orb_radius

    eventPlayer.isViewingPreferences = true
    async(UpdateAbilities, AsyncBehavior.RESTART)
    UpdatePreferencesHUD()

    waitUntil(
        eventPlayer.base_settled_owner != eventPlayer
        or eventPlayer.isUsingKeyboard
        or eventPlayer.dream_preferences[Dream.DREAM_MODE]
        # or eventPlayer.isCommunicatingEmote()
        or distance(
            eventPlayer.getEyePosition()
            + distance(eventPlayer.getEyePosition(), eventPlayer.base_vector)
            * eventPlayer.getFacingDirection(),
            eventPlayer.base_vector
        )
        > orb_radius,
        99999
    )

    eventPlayer.isViewingPreferences = false
    async(UpdateAbilities, AsyncBehavior.RESTART)


rule "— Go back to main preferences":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition eventPlayer.isInSubPreference

    eventPlayer.isInSubPreference = false
    UpdatePreferencesHUD()
    ExplodeBase()
    BuffPlayer()


rule "— Interact / toggle parameter":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.isInSubPreference:
        switch eventPlayer.preferences_index:
            case Main.GAME:
                switch game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]]:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = false
                        else:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.INTERACT:
                        chase(
                            eventPlayer.interaction_progress,
                            100,
                            duration = game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS],
                            ChaseReeval.NONE
                        )
                        waitUntil(
                            eventPlayer.interaction_progress == 100
                            or not eventPlayer.isHoldingButton(Button.INTERACT)
                            or not eventPlayer.isViewingPreferences,
                            game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS]
                        )
                        if eventPlayer.interaction_progress == 100:
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        stopChasingVariable(eventPlayer.interaction_progress)
                        eventPlayer.interaction_progress = 0
                        break
                    case PreferenceType.INTERACT_MULTIPLE_CHOICE:
                        chase(
                            eventPlayer.interaction_progress,
                            100,
                            duration = game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS][0],
                            ChaseReeval.NONE
                        )
                        waitUntil(
                            eventPlayer.interaction_progress == 100
                            or not eventPlayer.isHoldingButton(Button.INTERACT)
                            or not eventPlayer.isViewingPreferences,
                            game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS][0]
                        )
                        if eventPlayer.interaction_progress == 100:
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        stopChasingVariable(eventPlayer.interaction_progress)
                        eventPlayer.interaction_progress = 0
                        break
                break
            case Main.EFFECTS:
                switch effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]]:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = false
                        else:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.KEYBOARD:
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                break
            case Main.HERO:
                switch hero_preferences_data[eventPlayer.main_preferences[Main.HERO]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]]:
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = false
                        else:
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                break
            case Main.UNBOUND:
                switch unbound_preferences_data[eventPlayer.main_preferences[Main.UNBOUND]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]]:
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] = false
                        else:
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                break
            case Main.SPECIAL:
                switch special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]]:
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = false
                        else:
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                break
            case Main.BASE:
                switch base_preferences_data[eventPlayer.main_preferences[Main.BASE]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]]:
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = false
                        else:
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                break
            case Main.DREAM:
                switch dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.TYPE]:
                    case PreferenceType.BOOLEAN:
                        if eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]]:
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = false
                        else:
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = true
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.INTERACT_BOOLEAN:
                        chase(
                            eventPlayer.interaction_progress,
                            100,
                            duration = dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.PARAMETERS],
                            ChaseReeval.NONE
                        )
                        waitUntil(
                            eventPlayer.interaction_progress == 100
                            or not eventPlayer.isHoldingButton(Button.INTERACT)
                            or not eventPlayer.isViewingPreferences,
                            dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.PARAMETERS]
                        )
                        if eventPlayer.interaction_progress == 100:
                            if eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]]:
                                eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = false
                            else:
                                eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = true
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        stopChasingVariable(eventPlayer.interaction_progress)
                        eventPlayer.interaction_progress = 0
                        break
                break
    else:
        switch main_preferences_data[eventPlayer.preferences_index][Preference.TYPE]:
            case PreferenceType.BOOLEAN:
                if eventPlayer.main_preferences[eventPlayer.preferences_index]:
                    eventPlayer.main_preferences[eventPlayer.preferences_index] = false
                else:
                    eventPlayer.main_preferences[eventPlayer.preferences_index] = true
                UpdatePreferencesHUD()
                break
            case PreferenceType.SUB_PREFERENCE:
                eventPlayer.isInSubPreference = true
                UpdatePreferencesHUD()
                ExplodeBase()
                BuffPlayer()
                break


rule "— Go to next preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if eventPlayer.isInSubPreference:
        switch eventPlayer.preferences_index:
            case Main.GAME:
                if eventPlayer.main_preferences[Main.GAME] < len(game_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.GAME] += 1
                else:
                    eventPlayer.main_preferences[Main.GAME] = 0
                break
            case Main.EFFECTS:
                if eventPlayer.main_preferences[Main.EFFECTS] < len(effects_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.EFFECTS] += 1
                else:
                    eventPlayer.main_preferences[Main.EFFECTS] = 0
                break
            case Main.UNBOUND:
                if eventPlayer.main_preferences[Main.UNBOUND] < len(unbound_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.UNBOUND] += 1
                else:
                    eventPlayer.main_preferences[Main.UNBOUND] = 0
                break
            case Main.HERO:
                if eventPlayer.main_preferences[Main.HERO] < len(hero_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.HERO] += 1
                else:
                    eventPlayer.main_preferences[Main.HERO] = 0
                break
            case Main.SPECIAL:
                if eventPlayer.main_preferences[Main.SPECIAL] < len(special_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.SPECIAL] += 1
                else:
                    eventPlayer.main_preferences[Main.SPECIAL] = 0
                break
            case Main.BASE:
                if eventPlayer.main_preferences[Main.BASE] < len(base_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.BASE] += 1
                else:
                    eventPlayer.main_preferences[Main.BASE] = 0
                break
            case Main.DREAM:
                if eventPlayer.main_preferences[Main.DREAM] < len(dream_preferences_data) - 1:
                    eventPlayer.main_preferences[Main.DREAM] += 1
                else:
                    eventPlayer.main_preferences[Main.DREAM] = 0
                break
    else:
        if eventPlayer.preferences_index < len(main_preferences_data) - 1:
            eventPlayer.preferences_index += 1
        else:
            eventPlayer.preferences_index = 0

    UpdatePreferencesHUD()


rule "— Go to previous preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.isInSubPreference:
        switch eventPlayer.preferences_index:
            case Main.GAME:
                if eventPlayer.main_preferences[Main.GAME] > 0:
                    eventPlayer.main_preferences[Main.GAME] -= 1
                else:
                    eventPlayer.main_preferences[Main.GAME] = len(game_preferences_data) - 1
                break
            case Main.EFFECTS:
                if eventPlayer.main_preferences[Main.EFFECTS] > 0:
                    eventPlayer.main_preferences[Main.EFFECTS] -= 1
                else:
                    eventPlayer.main_preferences[Main.EFFECTS] = len(effects_preferences_data) - 1
                break
            case Main.HERO:
                if eventPlayer.main_preferences[Main.HERO] > 0:
                    eventPlayer.main_preferences[Main.HERO] -= 1
                else:
                    eventPlayer.main_preferences[Main.HERO] = len(hero_preferences_data) - 1
                break
            case Main.UNBOUND:
                if eventPlayer.main_preferences[Main.UNBOUND] > 0:
                    eventPlayer.main_preferences[Main.UNBOUND] -= 1
                else:
                    eventPlayer.main_preferences[Main.UNBOUND] = len(unbound_preferences_data) - 1
                break
            case Main.SPECIAL:
                if eventPlayer.main_preferences[Main.SPECIAL] > 0:
                    eventPlayer.main_preferences[Main.SPECIAL] -= 1
                else:
                    eventPlayer.main_preferences[Main.SPECIAL] = len(special_preferences_data) - 1
                break
            case Main.BASE:
                if eventPlayer.main_preferences[Main.BASE] > 0:
                    eventPlayer.main_preferences[Main.BASE] -= 1
                else:
                    eventPlayer.main_preferences[Main.BASE] = len(base_preferences_data) - 1
                break
            case Main.DREAM:
                if eventPlayer.main_preferences[Main.DREAM] > 0:
                    eventPlayer.main_preferences[Main.DREAM] -= 1
                else:
                    eventPlayer.main_preferences[Main.DREAM] = len(dream_preferences_data) - 1
                break
    else:
        if eventPlayer.preferences_index > 0:
            eventPlayer.preferences_index -= 1
        else:
            eventPlayer.preferences_index = len(main_preferences_data) - 1

    UpdatePreferencesHUD()


rule "— Go to next / increase parameter":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)

    if eventPlayer.isInSubPreference:
        switch eventPlayer.preferences_index:
            case Main.GAME:
                switch game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        if (
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]]
                            < len(game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS]) - 1
                        ):
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] += 1
                        else:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = 0
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.INTERACT_MULTIPLE_CHOICE:
                        if (
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]]
                            < len(game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS][1]) - 1
                        ):
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] += 1
                        else:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = 0
                        async(UpdatePreferencesHUD, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = game_preferences_data[
                                eventPlayer.main_preferences[Main.GAME]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]]
                            < game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] += game_preferences_data[
                                eventPlayer.main_preferences[Main.GAME]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.EFFECTS:
                switch effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        if (
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]]
                            < len(effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.PARAMETERS]) - 1
                        ):
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] += 1
                        else:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = 0
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.COLOR_PICKER:
                        if (
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]]
                            < len(colors_data) - 1
                        ):
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] += 1
                        else:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = 0
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = effects_preferences_data[
                                eventPlayer.main_preferences[Main.EFFECTS]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]]
                            < effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] += effects_preferences_data[
                                eventPlayer.main_preferences[Main.EFFECTS]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.HERO:
                switch hero_preferences_data[eventPlayer.main_preferences[Main.HERO]][Preference.TYPE]:
                    case PreferenceType.COLOR_PICKER:
                        if (
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]]
                            < len(colors_data) - 1
                        ):
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] += 1
                        else:
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = 0
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = hero_preferences_data[
                                eventPlayer.main_preferences[Main.HERO]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]]
                            < hero_preferences_data[eventPlayer.main_preferences[Main.HERO]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] += hero_preferences_data[
                                eventPlayer.main_preferences[Main.HERO]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.UNBOUND:
                switch unbound_preferences_data[eventPlayer.main_preferences[Main.UNBOUND]][Preference.TYPE]:
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] = unbound_preferences_data[
                                eventPlayer.main_preferences[Main.UNBOUND]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]]
                            < unbound_preferences_data[eventPlayer.main_preferences[Main.UNBOUND]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] += unbound_preferences_data[
                                eventPlayer.main_preferences[Main.UNBOUND]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.SPECIAL:
                switch special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        if (
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]]
                            < len(special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.PARAMETERS]) - 1
                        ):
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] += 1
                        else:
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = 0
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = special_preferences_data[
                                eventPlayer.main_preferences[Main.SPECIAL]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]]
                            < special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] += special_preferences_data[
                                eventPlayer.main_preferences[Main.SPECIAL]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.BASE:
                switch base_preferences_data[eventPlayer.main_preferences[Main.BASE]][Preference.TYPE]:
                    case PreferenceType.COLOR_PICKER:
                        if (
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]]
                            < len(colors_data) - 1
                        ):
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] += 1
                        else:
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = 0
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = base_preferences_data[
                                eventPlayer.main_preferences[Main.BASE]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]]
                            < base_preferences_data[eventPlayer.main_preferences[Main.BASE]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] += base_preferences_data[
                                eventPlayer.main_preferences[Main.BASE]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.DREAM:
                switch dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.TYPE]:
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = dream_preferences_data[
                                eventPlayer.main_preferences[Main.DREAM]
                            ][Preference.PARAMETERS][1]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]]
                            < dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.PARAMETERS][1]
                        ):
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] += dream_preferences_data[
                                eventPlayer.main_preferences[Main.DREAM]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
    else:
        switch main_preferences_data[eventPlayer.preferences_index][Preference.TYPE]:
            case PreferenceType.MULTIPLE_CHOICE:
                if (
                    eventPlayer.main_preferences[eventPlayer.preferences_index]
                    < len(main_preferences_data[eventPlayer.preferences_index][Preference.PARAMETERS]) - 1
                ):
                    eventPlayer.main_preferences[eventPlayer.preferences_index] += 1
                else:
                    eventPlayer.main_preferences[eventPlayer.preferences_index] = 0
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                break

    if not eventPlayer.isAdjustingPreference:
        waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_2), 0.4)

    if eventPlayer.isHoldingButton(Button.ABILITY_2):
        if not eventPlayer.isAdjustingPreference:
            eventPlayer.isAdjustingPreference = true
    else:
        if eventPlayer.isAdjustingPreference:
            eventPlayer.isAdjustingPreference = false
        return

    wait(0.12)

    goto RULE_START


rule "— Go to previous / decrease parameter":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_2)

    if eventPlayer.isInSubPreference:
        switch eventPlayer.preferences_index:
            case Main.GAME:
                switch game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        if eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] > 0:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] -= 1
                        else:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = len(
                                game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS]
                            ) - 1
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.INTERACT_MULTIPLE_CHOICE:
                        if eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] > 0:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] -= 1
                        else:
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = len(
                                game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS][1]
                            ) - 1
                        async(UpdatePreferencesHUD, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = game_preferences_data[
                                eventPlayer.main_preferences[Main.GAME]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]]
                            > game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] -= game_preferences_data[
                                eventPlayer.main_preferences[Main.GAME]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.EFFECTS:
                switch effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        if eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] > 0:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] -= 1
                        else:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = len(
                                effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.PARAMETERS]
                            ) - 1
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.COLOR_PICKER:
                        if eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] > 0:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] -= 1
                        else:
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = len(colors_data) - 1
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] = effects_preferences_data[
                                eventPlayer.main_preferences[Main.EFFECTS]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]]
                            > effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.effects_preferences[eventPlayer.main_preferences[Main.EFFECTS]] -= effects_preferences_data[
                                eventPlayer.main_preferences[Main.EFFECTS]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.HERO:
                switch hero_preferences_data[eventPlayer.main_preferences[Main.HERO]][Preference.TYPE]:
                    case PreferenceType.COLOR_PICKER:
                        if eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] > 0:
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] -= 1
                        else:
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = len(colors_data) - 1
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = hero_preferences_data[
                                eventPlayer.main_preferences[Main.HERO]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]]
                            > hero_preferences_data[eventPlayer.main_preferences[Main.HERO]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] -= hero_preferences_data[
                                eventPlayer.main_preferences[Main.HERO]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.UNBOUND:
                switch unbound_preferences_data[eventPlayer.main_preferences[Main.UNBOUND]][Preference.TYPE]:
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] = unbound_preferences_data[
                                eventPlayer.main_preferences[Main.UNBOUND]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]]
                            > unbound_preferences_data[eventPlayer.main_preferences[Main.UNBOUND]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] -= unbound_preferences_data[
                                eventPlayer.main_preferences[Main.UNBOUND]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.SPECIAL:
                switch special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        if eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] > 0:
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] -= 1
                        else:
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = len(
                                special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.PARAMETERS]
                            ) - 1
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = special_preferences_data[
                                eventPlayer.main_preferences[Main.SPECIAL]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]]
                            > special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] -= special_preferences_data[
                                eventPlayer.main_preferences[Main.SPECIAL]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.BASE:
                switch base_preferences_data[eventPlayer.main_preferences[Main.BASE]][Preference.TYPE]:
                    case PreferenceType.COLOR_PICKER:
                        if eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] > 0:
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] -= 1
                        else:
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = len(colors_data) - 1
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        break
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = base_preferences_data[
                                eventPlayer.main_preferences[Main.BASE]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]]
                            > base_preferences_data[eventPlayer.main_preferences[Main.BASE]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] -= base_preferences_data[
                                eventPlayer.main_preferences[Main.BASE]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
            case Main.DREAM:
                switch dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.TYPE]:
                    case PreferenceType.NUMERIC:
                        if eventPlayer.isHoldingButton(Button.CROUCH):
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = dream_preferences_data[
                                eventPlayer.main_preferences[Main.DREAM]
                            ][Preference.PARAMETERS][0]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                            ExplodeBase()
                            BuffPlayer()
                        elif (
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]]
                            > dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.PARAMETERS][0]
                        ):
                            eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] -= dream_preferences_data[
                                eventPlayer.main_preferences[Main.DREAM]
                            ][Preference.PARAMETERS][2]
                            async(InteractWithPreferences, AsyncBehavior.RESTART)
                        else:
                            ExplodeBase()
                            BuffPlayer()
                            return
                        break
                break
    else:
        switch main_preferences_data[eventPlayer.preferences_index][Preference.TYPE]:
            case PreferenceType.MULTIPLE_CHOICE:
                if eventPlayer.main_preferences[eventPlayer.preferences_index] > 0:
                    eventPlayer.main_preferences[eventPlayer.preferences_index] -= 1
                else:
                    eventPlayer.main_preferences[eventPlayer.preferences_index] = len(main_preferences_data[eventPlayer.preferences_index][Preference.PARAMETERS]) - 1
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                break

    if not eventPlayer.isAdjustingPreference:
        waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_1), 0.4)

    if eventPlayer.isHoldingButton(Button.ABILITY_1):
        if not eventPlayer.isAdjustingPreference:
            eventPlayer.isAdjustingPreference = true
    else:
        if eventPlayer.isAdjustingPreference:
            eventPlayer.isAdjustingPreference = false
        return

    wait(0.12)

    goto RULE_START


rule "— Reset preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if eventPlayer.isInSubPreference:
        switch eventPlayer.preferences_index:
            case Main.GAME:
                switch game_preferences_data[eventPlayer.main_preferences[Main.GAME]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                        eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = game_preferences_default[eventPlayer.main_preferences[Main.GAME]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                    case PreferenceType.NUMERIC:
                        eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = game_preferences_default[eventPlayer.main_preferences[Main.GAME]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break
            case Main.EFFECTS:
                switch effects_preferences_data[eventPlayer.main_preferences[Main.EFFECTS]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                    case PreferenceType.COLOR_PICKER:
                    case PreferenceType.NUMERIC:
                        eventPlayer.game_preferences[eventPlayer.main_preferences[Main.GAME]] = game_preferences_default[eventPlayer.main_preferences[Main.GAME]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break
            case Main.HERO:
                switch hero_preferences_data[eventPlayer.main_preferences[Main.HERO]][Preference.TYPE]:
                    case PreferenceType.COLOR_PICKER:
                    case PreferenceType.NUMERIC:
                        eventPlayer.hero_preferences[eventPlayer.main_preferences[Main.HERO]] = hero_preferences_default[eventPlayer.main_preferences[Main.HERO]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break
            case Main.UNBOUND:
                switch unbound_preferences_data[eventPlayer.main_preferences[Main.UNBOUND]][Preference.TYPE]:
                    case PreferenceType.NUMERIC:
                        eventPlayer.unbound_preferences[eventPlayer.main_preferences[Main.UNBOUND]] = unbound_preferences_default[eventPlayer.main_preferences[Main.UNBOUND]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break
            case Main.SPECIAL:
                switch special_preferences_data[eventPlayer.main_preferences[Main.SPECIAL]][Preference.TYPE]:
                    case PreferenceType.MULTIPLE_CHOICE:
                    case PreferenceType.NUMERIC:
                        eventPlayer.special_preferences[eventPlayer.main_preferences[Main.SPECIAL]] = special_preferences_default[eventPlayer.main_preferences[Main.SPECIAL]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break
            case Main.BASE:
                switch base_preferences_data[eventPlayer.main_preferences[Main.BASE]][Preference.TYPE]:
                    case PreferenceType.COLOR_PICKER:
                    case PreferenceType.NUMERIC:
                        eventPlayer.base_preferences[eventPlayer.main_preferences[Main.BASE]] = base_preferences_default[eventPlayer.main_preferences[Main.BASE]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break
            case Main.DREAM:
                switch dream_preferences_data[eventPlayer.main_preferences[Main.DREAM]][Preference.TYPE]:
                    case PreferenceType.NUMERIC:
                        eventPlayer.dream_preferences[eventPlayer.main_preferences[Main.DREAM]] = dream_preferences_default[eventPlayer.main_preferences[Main.DREAM]]
                        async(InteractWithPreferences, AsyncBehavior.RESTART)
                        ExplodeBase()
                        BuffPlayer()
                        break
                break


def InteractWithPreferences():
    @Name "— Preferences interactions"

    if eventPlayer.isInSubPreference:
        eventPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR] = main_preferences_data[eventPlayer.preferences_index][Preference.COLORS]
        switch eventPlayer.preferences_index:
            case Main.GAME:
                switch eventPlayer.main_preferences[Main.GAME]:
                    case Game.FAST_TRAVEL_TO_OBJECTIVE:
                        if (
                            eventPlayer.main_preferences[Main.PLAYER_MODE]
                            and getObjectivePosition(eventPlayer.game_preferences[Game.FAST_TRAVEL_TO_OBJECTIVE]) != vect(0, 0, 0)
                        ):
                            eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(eventPlayer.game_preferences[Game.FAST_TRAVEL_TO_OBJECTIVE])))
                            BuffPlayer()
                        elif not eventPlayer.main_preferences[Main.PLAYER_MODE]:
                            DebuffPlayer()
                            iconMessage(eventPlayer, iconString(Icon.WARNING), "can't fast travel in kill mode")
                        else:
                            DebuffPlayer()
                            iconMessage(eventPlayer, iconString(Icon.WARNING), "objective doesn't exist")
                        break
                    case Game.THIRD_PERSON:
                    case Game.THIRD_PERSON_DISTANCE:
                        async(UpdateCamera, AsyncBehavior.RESTART)
                        break
                    case Game.SWITCH_TEAM:
                        if getCurrentGamemode() == Gamemode.SKIRMISH:
                            DebuffPlayer()
                            iconMessage(eventPlayer, iconString(Icon.WARNING), "switching teams disabled due to reports of server crashes")
                            # moveToTeam(eventPlayer, getOppositeTeam(eventPlayer.getTeam()), -1)
                        else:
                            DebuffPlayer()
                            iconMessage(eventPlayer, iconString(Icon.WARNING), "gamemode is FFA")
                        break
                    case Game.RESET:
                        PackBase()
                        LoadDefaultPreferences()
                        InitializePlayer()
                        BuffPlayer()
                        iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "preferences reset")
                        break
                break
            case Main.EFFECTS:
                switch eventPlayer.main_preferences[Main.EFFECTS]:
                    case Effects.CUSTOM_MESSAGE:
                        eventPlayer.isUsingKeyboard = true
                        eventPlayer.previous_position_direction = [
                            eventPlayer.getPosition(), vect(
                                eventPlayer.getFacingDirection().x,
                                0,
                                eventPlayer.getFacingDirection().z
                            )
                        ]
                        eventPlayer.disableHeroHUD()
                        eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, 99999)
                        eventPlayer.setFacing(eventPlayer.previous_position_direction[1], Relativity.TO_WORLD)
                        eventPlayer.setInvisibility(Invis.ALL)
                        eventPlayer.isInvisible = true
                        UpdateAbilities()
                        eventPlayer.startCamera(
                            eventPlayer.getEyePosition(),
                            eventPlayer.getEyePosition() + eventPlayer.previous_position_direction[1],
                            0
                        )
                        break
                    case Effects.AURA:
                    case Effects.AURA_EFFECT:
                    case Effects.HIDE_AURA_IN_FIRST_PERSON:
                        async(UpdateAura, AsyncBehavior.RESTART)
                        break
                break
            case Main.UNBOUND:
                switch eventPlayer.main_preferences[Main.UNBOUND]:
                    case Unbound.DAMAGE:
                    case Unbound.HEALING:
                    case Unbound.HEALTH:
                        UpdateHero()
                        break
            case Main.HERO:
                switch eventPlayer.main_preferences[Main.HERO]:
                    case Hero.OUTLINE_COLOR:
                        updateHeroOutline()
                        break
                    case Hero.SIZE:
                        UpdateSizeNoclip()
                        break
                    case Hero.FLIGHT:
                        UpdateFlight()
                        break
                    case Hero.KNOCKBACK:
                        UpdateKnockback()
                        break
                    case Hero.PROJECTILE_SPEED:
                    case Hero.PROJECTILE_GRAVITY:
                        UpdateProjectiles()
                        break
                    case Hero.VOICE_PITCH:
                        updatePitch()
                        break
                break
            case Main.SPECIAL:
                switch eventPlayer.main_preferences[Main.SPECIAL]:
                    case Special.AMMO_OVERLOAD:
                        UpdateAmmo()
                        break
                    case Special.NOCLIP:
                        UpdateSizeNoclip()
                        break
                    case Special.INVISIBILITY:
                        UpdateInvisibility()
                        break
                    case Special.ALLOW_MOUNTING:
                        if (
                            not eventPlayer.special_preferences[Special.ALLOW_MOUNTING]
                            and eventPlayer.rider
                        ):
                            UnmountPlayer()
                        break
                    case Special.MOUNTING_MODE:
                        UpdateRider()
                        break
                break
            case Main.BASE:
                switch eventPlayer.main_preferences[Main.BASE]:
                    case Base.SIZE:
                    case Base.GAP_SIZE:
                        while isOverlappingBase(
                            eventPlayer.base_vector,
                            eventPlayer.base_preferences[Base.SIZE],
                            eventPlayer.base_preferences[Base.GAP_SIZE]
                        ):
                            if eventPlayer.main_preferences[Main.BASE] == Base.SIZE:
                                eventPlayer.base_preferences[Base.SIZE] -= base_preferences_data[Base.SIZE][Preference.PARAMETERS][2]
                                eventPlayer.previous_base_size = eventPlayer.base_preferences[Base.SIZE]
                            else:
                                eventPlayer.base_preferences[Base.GAP_SIZE] -= base_preferences_data[Base.GAP_SIZE][Preference.PARAMETERS][2]
                                eventPlayer.previous_base_gap_size = eventPlayer.base_preferences[Base.GAP_SIZE]

                        if eventPlayer.main_preferences[Main.BASE] == Base.SIZE:
                            eventPlayer.previous_base_size = eventPlayer.base_preferences[Base.SIZE]
                        else:
                            eventPlayer.previous_base_gap_size = eventPlayer.base_preferences[Base.GAP_SIZE]
                        break
                    case Base.NOCLIP:
                    case Base.GRAVITY:
                    case Base.SPEED:
                    case Base.JUMP_SPEED:
                        eventPlayer.base_preferences_changed = true
                        break
                    case Base.BASE_LOCK:
                        UpdateBaseWithinOwner()
                        break
                break
            case Main.DREAM:
                switch eventPlayer.main_preferences[Main.DREAM]:
                    case Dream.DREAM_MODE:
                        DreamMode()
                        break
                    case Dream.AFK_TIMER:
                        UpdateAFKTimer()
                        break
                break
    else:
        switch eventPlayer.preferences_index:
            case Main.PLAYER_MODE:
                UpdateHero()
                break
    UpdatePreferencesHUD()
    BackupPlayer()