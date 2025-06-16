#!mainFile "../main.opy"

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
    
    # PREFERENCES
    # preferences category
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
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
        else colors_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
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
        else colors_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
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
        if localPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] == ExtendedColor.RAINBOW
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
        if localPlayer.preferences[Preference.BASE_COLOR] == ExtendedColor.RAINBOW
        else colors_data[localPlayer.preferences[Preference.BASE_COLOR]],
        null,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # player preference counter hotkeys
    createInWorldText(
        localPlayer if localPlayer.isViewingPreferences else null,
        "{} • jump".format(buttonToString(Button.INTERACT))
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.CATEGORY
        else "{} {} {}  |  {} • reset".format(
            buttonToString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.RELOAD)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.MULTIPLE_CHOICE
        or localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.COLOR_PICKER
        else "{} {} {}  |  {} • interact".format(
            buttonToString(Button.ABILITY_1),
            localPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS],
            buttonToString(Button.ABILITY_2),
            buttonToString(Button.INTERACT)
        )
        if localPlayer.preferences_hud[PreferencesHUD.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE
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
        else colors_data[localPlayer.preferences_hud[PreferencesHUD.ACCENT_COLOR]],
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
        if localPlayer.preferences_hud[PreferencesHUD.CHILL_REQUIRED]
        and localPlayer.isViewingPreferences
        else null,
        "chill / zen required" if localPlayer.preferences_hud[PreferencesHUD.CHILL_REQUIRED] and not localPlayer.preferences[Preference.PLAYER_MODE]
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
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
            eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + 1, len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS]), iconString(Icon.ARROW_RIGHT))
            break
        case PreferenceType.INTERACT_MULTIPLE_CHOICE:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1][eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
            eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + 1, len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1]), iconString(Icon.ARROW_RIGHT))
            break
        case PreferenceType.COLOR_PICKER:
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER_COLOR] = eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]
            eventPlayer.preferences_hud[PreferencesHUD.PARAMETER] = colors_data[eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]]
            eventPlayer.preferences_hud[PreferencesHUD.CURRENT_TOTAL_PARAMETERS] = "{} • {} of {} • {}".format(iconString(Icon.ARROW_LEFT), eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] + 1, len(colors_data), iconString(Icon.ARROW_RIGHT))
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


rule "— View / hide preferences":
    @Event eachPlayer
    @Condition eventPlayer.active_base_owner == eventPlayer
    @Condition not eventPlayer.isInModeratorMode
    @Condition not eventPlayer.isUsingKeyboard
    @Condition not eventPlayer.preferences[Preference.DREAM_MODE]
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
        eventPlayer.active_base_owner != eventPlayer
        or eventPlayer.isUsingKeyboard
        or eventPlayer.preferences[Preference.DREAM_MODE]
        # or eventPlayer.isCommunicatingEmote()
        or distance(
            eventPlayer.getEyePosition()
            + distance(eventPlayer.getEyePosition(), eventPlayer.base_vector)
            * eventPlayer.getFacingDirection(),
            eventPlayer.base_vector
        )
        > orb_radius,
        Math.INFINITY
    )

    eventPlayer.isViewingPreferences = false
    async(UpdateAbilities, AsyncBehavior.RESTART)


rule "— Switch between quick and advanced preferences":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    if eventPlayer.isViewingAdvancedPreferences:
        if (
            eventPlayer.preferences_index >= preferences_category_data[0][PreferenceCategoryProperty.STARTING_INDEX]
            and eventPlayer.preferences_index <= preferences_category_data[0][PreferenceCategoryProperty.ENDING_INDEX]
        ):
            eventPlayer.preferences_index = 0
            eventPlayer.isViewingAdvancedPreferences = false
        else:
            eventPlayer.preferences_index = [
                cat[PreferenceCategoryProperty.CATEGORY_INDEX] for cat in preferences_category_data
                if eventPlayer.preferences_index >= cat[PreferenceCategoryProperty.STARTING_INDEX]
                and eventPlayer.preferences_index <= cat[PreferenceCategoryProperty.ENDING_INDEX]
            ][0]
    else:
        eventPlayer.preferences_index = 0
        eventPlayer.isViewingAdvancedPreferences = true

    UpdatePreferencesHUD()
    BaseRingExplosion()
    RingExplosionSound()


rule "— Interact / toggle preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
        case PreferenceType.BOOLEAN:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = false
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = true
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            UpdatePreferencesHUD()
            BuffImpactSoundQuiet()
            break
        case PreferenceType.CATEGORY:
            eventPlayer.preferences_index = [
                cat[PreferenceCategoryProperty.STARTING_INDEX] for cat in preferences_category_data
                if (cat[PreferenceCategoryProperty.CATEGORY_INDEX] == eventPlayer.preferences_index)
            ][0]
            UpdatePreferencesHUD()
            BaseRingExplosion()
            RingExplosionSound()
            break
        case PreferenceType.NUMERIC_REVERSIBLE:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] *= -1
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
        case PreferenceType.INTERACT:
        case PreferenceType.INTERACT_BOOLEAN:
        case PreferenceType.INTERACT_MULTIPLE_CHOICE:
            if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] == PreferenceType.INTERACT_MULTIPLE_CHOICE:
                chaseInteractionProgress(
                    preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][0],
                    not eventPlayer.isViewingPreferences or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            else:
                chaseInteractionProgress(
                    preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS],
                    not eventPlayer.isViewingPreferences or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            if eventPlayer.interaction_progress == 100:
                if preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE] == PreferenceType.INTERACT_BOOLEAN:
                    if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)]:
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = false
                    else:
                        eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = true
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                UpdatePreferencesHUD()
                BuffImpactSoundQuiet()
            stopChasingVariable(eventPlayer.interaction_progress)
            eventPlayer.interaction_progress = 0
            break


rule "— Go to next preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if eventPlayer.isViewingAdvancedPreferences:
        if eventPlayer.preferences_index < len(preferences_data) - 1:
            eventPlayer.preferences_index += 1
        else:
            eventPlayer.preferences_index = 0
    else:
        if eventPlayer.preferences_index < len(quick_preferences_data) - 1:
            eventPlayer.preferences_index += 1
        else:
            eventPlayer.preferences_index = 0

    UpdatePreferencesHUD()
    BuffExplosionSoundQuiet()


rule "— Go to previous preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.isViewingAdvancedPreferences:
        if eventPlayer.preferences_index > 0:
            eventPlayer.preferences_index -= 1
        else:
            eventPlayer.preferences_index = len(preferences_data) - 1
    else:
        if eventPlayer.preferences_index > 0:
            eventPlayer.preferences_index -= 1
        else:
            eventPlayer.preferences_index = len(quick_preferences_data) - 1

    UpdatePreferencesHUD()
    BuffExplosionSoundQuiet()


rule "— Go to next option / increase preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)

    switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
        case PreferenceType.NUMERIC:
        case PreferenceType.NUMERIC_REVERSIBLE:
            if eventPlayer.isHoldingButton(Button.CROUCH):
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.MAX]
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BaseRingExplosion()
                BuffImpactSound()
            elif eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] < preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.MAX]:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] += preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.STEP]
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BuffImpactSoundQuiet()
            else:
                BaseRingExplosion()
                DebuffImpactSound()
                return
            break
        case PreferenceType.COLOR_PICKER:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] < len(colors_data) - 1:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] += 1
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = 0
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break
        case PreferenceType.MULTIPLE_CHOICE:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] < len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS]) - 1:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] += 1
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = 0
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break
        case PreferenceType.INTERACT_MULTIPLE_CHOICE:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] < len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1]) - 1:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] += 1
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = 0
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
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


rule "— Go to previous option / decrease preference":
    @Event eachPlayer
    @Condition eventPlayer.isViewingPreferences
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_2)

    switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
        case PreferenceType.NUMERIC:
        case PreferenceType.NUMERIC_REVERSIBLE:
            if eventPlayer.isHoldingButton(Button.CROUCH):
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.MIN]
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BaseRingExplosion()
                BuffImpactSound()
            elif eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] > preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.MIN]:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] -= preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][Numeric.STEP]
                async(InteractWithPreferences, AsyncBehavior.RESTART)
                BuffImpactSoundQuiet()
            else:
                BaseRingExplosion()
                DebuffImpactSound()
                return
            break
        case PreferenceType.COLOR_PICKER:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] > 0:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] -= 1
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = len(colors_data) - 1
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break
        case PreferenceType.MULTIPLE_CHOICE:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] > 0:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] -= 1
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS]) - 1
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break
        case PreferenceType.INTERACT_MULTIPLE_CHOICE:
            if eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] > 0:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] -= 1
            else:
                eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = len(preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.PARAMETERS][1]) - 1
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
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

    switch preferences_data[dynamic_preferences_index(eventPlayer)][PreferenceProperty.TYPE]:
        case PreferenceType.MULTIPLE_CHOICE:
        case PreferenceType.COLOR_PICKER:
        case PreferenceType.NUMERIC:
        case PreferenceType.NUMERIC_REVERSIBLE:
            eventPlayer.preferences[dynamic_preferences_index(eventPlayer)] = preferences_default[dynamic_preferences_index(eventPlayer)]
            async(InteractWithPreferences, AsyncBehavior.RESTART)
            BaseRingExplosion()
            BuffImpactSound()
            break


def InteractWithPreferences():
    @Name "— Preferences interactions"

    switch dynamic_preferences_index(eventPlayer):
        case Preference.FAST_TRAVEL_TO_OBJECTIVE:
            if (
                eventPlayer.preferences[Preference.PLAYER_MODE]
                and getObjectivePosition(eventPlayer.preferences[Preference.FAST_TRAVEL_TO_OBJECTIVE]) != vect(0, 0, 0)
            ):
                eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(eventPlayer.preferences[Preference.FAST_TRAVEL_TO_OBJECTIVE])))
                BuffImpactSound()
            elif not eventPlayer.preferences[Preference.PLAYER_MODE]:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "can't fast travel in kill mode")
            else:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "objective doesn't exist")
            break
        case Preference.THIRD_PERSON:
        case Preference.THIRD_PERSON_DISTANCE:
        case Preference.THIRD_PERSON_OFFSET:
            async(UpdateCamera, AsyncBehavior.RESTART)
            break
        case Preference.SWITCH_TEAM:
            if getCurrentGamemode() == Gamemode.SKIRMISH:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "switching teams disabled due to reports of server crashes")
                # moveToTeam(eventPlayer, getOppositeTeam(eventPlayer.getTeam()), -1)
            else:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "gamemode is FFA")
            break
        case Preference.RESET:
            PackBase()
            LoadDefaultPreferences()
            InitializePlayer()
            BuffImpactSound()
            iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "preferences reset")
            break
        case Preference.CUSTOM_MESSAGE:
            eventPlayer.isUsingKeyboard = true
            eventPlayer.previous_position_direction = [
                eventPlayer.getPosition(), vect(
                    eventPlayer.getFacingDirection().x,
                    0,
                    eventPlayer.getFacingDirection().z
                )
            ]
            eventPlayer.disableHeroHUD()
            eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, Math.INFINITY)
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
        case Preference.AURA:
        case Preference.AURA_EFFECT:
        case Preference.HIDE_AURA_IN_FIRST_PERSON:
            async(UpdateAura, AsyncBehavior.RESTART)
            break
        case Preference.DAMAGE:
        case Preference.HEALING:
        case Preference.HEALTH:
            UpdateHero()
            break
        case Preference.OUTLINE_COLOR:
            updateHeroOutline()
            break
        case Preference.SIZE:
            UpdateSizeNoclip()
            break
        case Preference.FLIGHT:
            UpdateFlight()
            break
        case Preference.KNOCKBACK:
            UpdateKnockback()
            break
        case Preference.PROJECTILE_SPEED:
        case Preference.PROJECTILE_GRAVITY:
            UpdateProjectiles()
            break
        case Preference.VOICE_PITCH:
            updatePitch()
            break
        case Preference.AMMO_OVERLOAD:
            UpdateAmmo()
            break
        case Preference.NOCLIP:
            UpdateSizeNoclip()
            break
        case Preference.INVISIBILITY:
            UpdateInvisibility()
            break
        case Preference.ALLOW_MOUNTING:
            if (
                not eventPlayer.preferences[Preference.ALLOW_MOUNTING]
                and eventPlayer.rider
            ):
                EjectRider()
            break
        case Preference.MOUNTING_MODE:
            UpdateRider()
            break
        case Preference.BASE_MODE:
            eventPlayer.activate_base_immediately = true
            break
        case Preference.BASE_SIZE:
        case Preference.BASE_GAP_SIZE:
            while isOverlappingBase(
                eventPlayer.base_vector,
                eventPlayer.preferences[Preference.BASE_SIZE],
                eventPlayer.preferences[Preference.BASE_GAP_SIZE]
            ):
                if eventPlayer.preferences[Preference.BASE] == Preference.BASE_SIZE:
                    eventPlayer.preferences[Preference.BASE_SIZE] -= preferences_data[Preference.BASE_SIZE][PreferenceProperty.PARAMETERS][2]
                    eventPlayer.previous_base_size = eventPlayer.preferences[Preference.BASE_SIZE]
                else:
                    eventPlayer.preferences[Preference.BASE_GAP_SIZE] -= preferences_data[Preference.BASE_GAP_SIZE][PreferenceProperty.PARAMETERS][2]
                    eventPlayer.previous_base_gap_size = eventPlayer.preferences[Preference.BASE_GAP_SIZE]

            if eventPlayer.preferences[Preference.BASE] == Preference.BASE_SIZE:
                eventPlayer.previous_base_size = eventPlayer.preferences[Preference.BASE_SIZE]
            else:
                eventPlayer.previous_base_gap_size = eventPlayer.preferences[Preference.BASE_GAP_SIZE]
            break
        case Preference.BASE_NOCLIP:
        case Preference.BASE_GRAVITY:
        case Preference.BASE_SPEED:
        case Preference.BASE_JUMP_SPEED:
            eventPlayer.base_preferences_changed = true
            break
        case Preference.BASE_LOCK:
            UpdateCurrentBaseOwner()
            break
        case Preference.DREAM_MODE:
            DreamMode()
            break
        case Preference.AFK_TIMER:
            UpdateAFKTimer()
            break
        case Preference.PLAYER_MODE:
            UpdateHero()
            break
        case Preference.GRAVITY:
        case Preference.SPEED:
        case Preference.JUMP_SPEED:
            UpdatePhysics()
            break
    ResetFlux()
    UpdatePreferencesHUD()
    BackupPlayer()