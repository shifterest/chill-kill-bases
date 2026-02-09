#!mainFile "../main.opy"

rule "Settings menu":
    @Disabled
    @Delimiter


rule "— Draw settings HUDs":
    @Condition isGameInProgress()
    @Condition isInitialized

    # Title
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        "Settings",
        menu_vector(localPlayer, 0, 0.3),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )

    # === Left ===
    # Category
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        f"{localPlayer.settings_hud[SettingsHUD.CATEGORY_NAME]} settings",
        menu_vector(localPlayer, 0.6, 0.15),
        1.2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        RainbowColor(localPlayer.settings_hud[SettingsHUD.ACCENT_COLOR]),
        SpecVisibility.NEVER
    )
    # Navigation
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        f"{iconString(Icon.ARROW_LEFT)}                                                                                                                                {iconString(Icon.ARROW_RIGHT)}",
        menu_vector(localPlayer, 0.6, 0.15),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Category hotkeys
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        f"{buttonToString(Button.ULTIMATE)}                                                                                                    {buttonToString(Button.ABILITY_2)}",
        menu_vector(localPlayer, 0.6, 0.15),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Second previous setting
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_SETTING],
        menu_vector(localPlayer, 0.6, -0.05),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Previous setting
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.PREVIOUS_SETTING],
        menu_vector(localPlayer, 0.6, -0.125),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Current setting
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.CURRENT_SETTING],
        menu_vector(localPlayer, 0.6, -0.2),
        2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Next setting
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.NEXT_SETTING],
        menu_vector(localPlayer, 0.6, -0.275),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Second next setting
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.SECOND_NEXT_SETTING],
        menu_vector(localPlayer, 0.6, -0.35),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )

    # === Either ===
    # Up arrow
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        "▲",
        menu_vector(localPlayer, 0.6 if localPlayer.isInCatMode else -0.6, 0.05),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # Previous hotkey
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        buttonToString(Button.PRIMARY_FIRE),
        menu_vector(localPlayer, 0.6 if localPlayer.isInCatMode else -0.6, 0.02),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Next hotkey
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        buttonToString(Button.SECONDARY_FIRE),
        menu_vector(localPlayer, 0.6 if localPlayer.isInCatMode else -0.6, -0.435),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Down arrow
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        "▼",
        menu_vector(localPlayer, 0.6 if localPlayer.isInCatMode else -0.6, -0.475),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )

    # === Right ===
    # Description
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.DESCRIPTION] if localPlayer.settings_hud[SettingsHUD.CHILL_REQUIRED] and not localPlayer.settings[Setting.PLAYER_MODE] else "Chill / zen mode is required for this setting",
        menu_vector(localPlayer, -0.6, 0.15),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Second previous option
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION],
        menu_vector(localPlayer, -0.6, -0.05),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Previous option
    createInWorldText(  
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION],
        menu_vector(localPlayer, -0.6, -0.125),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Current option
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.CURRENT_OPTION],
        menu_vector(localPlayer, -0.6, -0.2),
        2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbow()
        if localPlayer.settings_hud[SettingsHUD.OPTION_COLOR] == ExtendedColor.RAINBOW
        else extended_color_data[localPlayer.settings_hud[SettingsHUD.OPTION_COLOR]]
        if localPlayer.settings_hud[SettingsHUD.CHILL_REQUIRED] and not localPlayer.settings[Setting.PLAYER_MODE]
        else hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Interaction hotkey
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        f"{buttonToString(Button.RELOAD)} • Reset"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.MULTIPLE_CHOICE
        else f"{buttonToString(Button.ULTIMATE)} • Random  |  {buttonToString(Button.RELOAD)} • Reset"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.COLOR_PICKER
        else f"{buttonToString(Button.INTERACT)} • Interact"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.INTERACT_MULTIPLE_CHOICE
        else f"{buttonToString(Button.ULTIMATE)} • Random  |  {buttonToString(Button.INTERACT)} • Interact"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM
        else f"{buttonToString(Button.PRIMARY_FIRE)} • Toggle"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.BOOLEAN
        else f"{buttonToString(Button.INTERACT)} Boost  |  {buttonToString(Button.RELOAD)} • Reset"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.NUMERIC
        else f"{buttonToString(Button.ULTIMATE)} Boost  |  {buttonToString(Button.INTERACT)} Reverse  |  {buttonToString(Button.RELOAD)} • Reset"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.NUMERIC_REVERSIBLE
        else f"{buttonToString(Button.ULTIMATE)} Boost  |  {buttonToString(Button.INTERACT)} Random  |  {buttonToString(Button.RELOAD)} • Reset"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.MULTIPLE_CHOICE_RANDOM
        else f"Hold {buttonToString(Button.INTERACT)} • Interact"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.INTERACT
        or localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.KEYBOARD
        else f"Hold {buttonToString(Button.INTERACT)} • Enable"
        if localPlayer.settings_hud[SettingsHUD.TYPE] == SettingType.INTERACT_BOOLEAN
        else "",
        menu_vector(localPlayer, -0.6, -0.245),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Next option
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.NEXT_OPTION],
        menu_vector(localPlayer, -0.6, -0.3),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )
    # Second next option
    createInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU else null,
        localPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION],
        menu_vector(localPlayer, -0.6, -0.375),
        1.6,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        hsl(0, 0, 1, 100),
        SpecVisibility.NEVER
    )

    # Interaction progress
    createProgressBarInWorldText(
        localPlayer if localPlayer.uiState == UIState.IN_MENU and localPlayer.interaction_progress > 0 else null,
        localPlayer.interaction_progress,
        null,
        menu_vector(localPlayer, 0, -0.6),
        0.8,
        Clip.NONE,
        RainbowColor(localPlayer.settings_hud[SettingsHUD.OPTION_COLOR]),
        null,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    

rule "— Enter settings menu":
    @Event eachPlayer
    @Condition eventPlayer.active_base_owner == eventPlayer
    @Condition eventPlayer.uiState == UIState.NORMAL
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.progress_hud[ProgHUD.TEXT] = "Opening settings menu..."
    eventPlayer.progress_hud[ProgHUD.COLOR] = s(Setting.BASE_COLOR)
    chaseProgress(
        0.75,
        eventPlayer.active_base_owner != eventPlayer
        or eventPlayer.uiState != UIState.NORMAL
        or not eventPlayer.isHoldingButton(Button.INTERACT)
    )
    if eventPlayer.progress == 100:
        eventPlayer.uiState = UIState.IN_MENU
        eventPlayer.progress = 0
        UpdateSettingsHUDs()
        async(EnterMenu, AsyncBehavior.RESTART)
    else:
        unchaseProgress(0.5)


rule "— Exit settings menu":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.IN_MENU
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    async(ExitSettingsMenu, AsyncBehavior.RESTART)


rule "— Switch navigation mode":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.IN_MENU
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    eventPlayer.isInCatMode = not eventPlayer.isInCatMode

    UpdateSettingsHUDs()
    BuffExplosionSoundQuiet()


rule "— Navigate categories":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.IN_MENU
    @Condition eventPlayer.isInCatMode
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) or eventPlayer.isHoldingButton(Button.ABILITY_2)

    eventPlayer.setting_adjustment = -1 if eventPlayer.isHoldingButton(Button.ULTIMATE) else 1

    eventPlayer.cat_i = (
        eventPlayer.cat_i
        + eventPlayer.setting_adjustment
        + len(settings_cat_data) + 1
    ) % (
        len(settings_cat_data) + 1
    )

    if eventPlayer.cat_i == SettingCat.QUICK:
        eventPlayer.settings_i = 0
    else:
        eventPlayer.settings_i = settings_cat_data[eventPlayer.cat_i][SettingsCatProp.STARTING_INDEX]

    UpdateSettingsHUDs()
    BuffExplosionSoundQuiet()

    if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
        GoodPickupEffect(menu_vector(eventPlayer, 0.6, 0.05))
    elif eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
        GoodPickupEffect(menu_vector(eventPlayer, 0.6, -0.45))


rule "— Navigate settings / adjust setting":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.IN_MENU
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    do:
        eventPlayer.setting_adjustment = -1 if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) else 1

        if eventPlayer.isInCatMode:
            if eventPlayer.cat_i == SettingCat.QUICK:
                eventPlayer.settings_i = (
                    eventPlayer.settings_i
                    + eventPlayer.setting_adjustment
                    + len(quick_settings_data) + 1
                ) % (
                    len(quick_settings_data) + 1
                )
            else:
                eventPlayer.settings_i = (
                    eventPlayer.settings_i
                    + eventPlayer.setting_adjustment
                    + len(settings_data) + 1
                ) % (
                    len(settings_data) + 1
                )

            UpdateSettingsHUDs()
            BuffExplosionSoundQuiet()

            wait(0.15, Wait.ABORT_WHEN_FALSE)
        else:
            switch settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE]:
                case SettingType.NUMERIC:
                case SettingType.NUMERIC_REVERSIBLE:
                    eventPlayer.setting_adjustment *= (
                        settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][SettingTypeNumericProp.STEP]
                        * (10 if eventPlayer.isHoldingButton(Button.CROUCH) else 1)
                    )
                    eventPlayer.settings[dynamic_settings_i(eventPlayer)] = (
                        max(
                            settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][SettingTypeNumericProp.MIN],
                            min(
                                settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][SettingTypeNumericProp.MAX],
                                eventPlayer.settings[dynamic_settings_i(eventPlayer)] + eventPlayer.setting_adjustment
                            )
                        )
                    )
                    async(InteractWithSettings, AsyncBehavior.RESTART)
                    BuffImpactSoundQuiet()
                    break
                case SettingType.COLOR_PICKER:
                    eventPlayer.settings[dynamic_settings_i(eventPlayer)] = (
                        (
                            eventPlayer.settings[dynamic_settings_i(eventPlayer)]
                            + eventPlayer.setting_adjustment
                            + len(extended_color_data)
                        ) % (
                            len(extended_color_data)
                        )
                    )
                    async(InteractWithSettings, AsyncBehavior.RESTART)
                    BuffImpactSoundQuiet()
                    break
                case SettingType.MULTIPLE_CHOICE:
                case SettingType.MULTIPLE_CHOICE_RANDOM:
                    eventPlayer.settings[dynamic_settings_i(eventPlayer)] = (
                        (
                            eventPlayer.settings[dynamic_settings_i(eventPlayer)]
                            + eventPlayer.setting_adjustment
                            + len(settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS])
                        ) % (
                            len(settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS])
                        )
                    )
                    async(InteractWithSettings, AsyncBehavior.RESTART)
                    BuffImpactSoundQuiet()
                    break
                case SettingType.INTERACT_MULTIPLE_CHOICE:
                case SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM:
                    eventPlayer.settings[dynamic_settings_i(eventPlayer)] = (
                        (
                            eventPlayer.settings[dynamic_settings_i(eventPlayer)]
                            + eventPlayer.setting_adjustment
                            + len(settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][1])
                        ) % (
                            len(settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][1])
                        )
                    )
                    async(UpdateSettingsHUDs, AsyncBehavior.RESTART)
                    BuffImpactSoundQuiet()
                    break

        if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
            GoodPickupEffect(menu_vector(localPlayer, 0.6 if localPlayer.isInCatMode else -0.6, 0.05))
        elif eventPlayer.isHoldingButton(Button.SECONDARY_FIRE):
            GoodPickupEffect(menu_vector(localPlayer, 0.6 if localPlayer.isInCatMode else -0.6, -0.475))

        wait(0.15, Wait.ABORT_WHEN_FALSE)
    while RULE_CONDITION

    
rule "— Interact / toggle setting":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.IN_MENU
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    switch settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE]:
        case SettingType.BOOLEAN:
            if eventPlayer.settings[dynamic_settings_i(eventPlayer)]:
                eventPlayer.settings[dynamic_settings_i(eventPlayer)] = false
            else:
                eventPlayer.settings[dynamic_settings_i(eventPlayer)] = true
            async(InteractWithSettings, AsyncBehavior.RESTART)
            UpdateSettingsHUDs()
            BuffImpactSoundQuiet()
            break
        case SettingType.NUMERIC_REVERSIBLE:
            eventPlayer.settings[dynamic_settings_i(eventPlayer)] *= -1
            async(InteractWithSettings, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
        case SettingType.INTERACT:
        case SettingType.INTERACT_BOOLEAN:
        case SettingType.INTERACT_MULTIPLE_CHOICE:
        case SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM:
        case SettingType.KEYBOARD:
            if settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE] == SettingType.KEYBOARD:
                chaseInteractionProgress(
                    0.5,
                    eventPlayer.uiState != UIState.IN_MENU or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            elif (
                settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE] == SettingType.INTERACT_MULTIPLE_CHOICE
                or settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE] == SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM
            ):
                chaseInteractionProgress(
                    settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][0],
                    eventPlayer.uiState != UIState.IN_MENU or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            else:
                chaseInteractionProgress(
                    settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS],
                    eventPlayer.uiState != UIState.IN_MENU or not eventPlayer.isHoldingButton(Button.INTERACT)
                )
            if eventPlayer.interaction_progress == 100:
                if settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE] == SettingType.INTERACT_BOOLEAN:
                    if eventPlayer.settings[dynamic_settings_i(eventPlayer)]:
                        eventPlayer.settings[dynamic_settings_i(eventPlayer)] = false
                    else:
                        eventPlayer.settings[dynamic_settings_i(eventPlayer)] = true
                async(InteractWithSettings, AsyncBehavior.RESTART)
                UpdateSettingsHUDs()
                if settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE] != SettingType.KEYBOARD:
                    BuffImpactSoundQuiet()
            stopChasingVariable(eventPlayer.interaction_progress)
            eventPlayer.interaction_progress = 0
            break
        case SettingType.MULTIPLE_CHOICE_RANDOM:
            eventPlayer.settings[dynamic_settings_i(eventPlayer)] = random.randint(
                0,
                len(settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS]) - 1
            )
            async(InteractWithSettings, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break
        case SettingType.COLOR_PICKER:
            eventPlayer.settings[dynamic_settings_i(eventPlayer)] = random.randint(
                0,
                len(extended_color_data) - 1
            )
            async(InteractWithSettings, AsyncBehavior.RESTART)
            BuffImpactSoundQuiet()
            break


rule "— Reset setting":
    @Event eachPlayer
    @Condition eventPlayer.uiState == UIState.IN_MENU
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    switch settings_data[dynamic_settings_i(eventPlayer)][SettingProp.TYPE]:
        case SettingType.MULTIPLE_CHOICE:
        case SettingType.MULTIPLE_CHOICE_RANDOM:
        case SettingType.COLOR_PICKER:
        case SettingType.NUMERIC:
        case SettingType.NUMERIC_REVERSIBLE:
            eventPlayer.settings[dynamic_settings_i(eventPlayer)] = default_settings[dynamic_settings_i(eventPlayer)]
            async(InteractWithSettings, AsyncBehavior.RESTART)
            BaseRingExplosion()
            BuffImpactSound()
            break
        case SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM:
            eventPlayer.settings[dynamic_settings_i(eventPlayer)] = random.randint(
                0,
                len(settings_data[dynamic_settings_i(eventPlayer)][SettingProp.PARAMETERS][1]) - 1
            )
            BuffImpactSoundQuiet()
            UpdateSettingsHUDs()
            break

def EnterMenu():
    @Name "— Enter menu"
    
    eventPlayer.uiState = UIState.IN_MENU
    eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, Math.INFINITY)
    UpdateInvisibility()
    saveTransform()
    restoreTransform()
    eventPlayer.disableHeroHUD()
    async(MenuCamera, AsyncBehavior.RESTART)
    UpdateAbilities()


def ExitMenu():
    @Name "— Exit menu"

    eventPlayer.uiState = UIState.NORMAL
    eventPlayer.clearStatusEffect(Status.ROOTED)
    UpdateInvisibility()
    restoreTransform()
    eventPlayer.last_transform = null
    async(UpdateCamera, AsyncBehavior.RESTART)
    eventPlayer.enableHeroHud()
    UpdateAbilities()


def ExitSettingsMenu():
    @Name "— Exit settings menu (subroutine)"

    eventPlayer.uiState = UIState.NORMAL
    ExitMenu()
    ApplyPendingSettings()

    
def UpdateSettingsHUDs():
    @Name "— Update settings HUD"

    eventPlayer.settings_hud[SettingsHUD.ACCENT_COLOR] = [
        cat[SettingsCatProp.COLOR] for cat in settings_cat_data
        if (dynamic_settings_i(eventPlayer) >= cat[SettingsCatProp.STARTING_INDEX]
        and dynamic_settings_i(eventPlayer) <= cat[SettingsCatProp.ENDING_INDEX])
    ][0]
    eventPlayer.settings_hud[SettingsHUD.CATEGORY_NAME] = [
        cat[SettingsCatProp.NAME] for cat in settings_cat_data
        if (dynamic_settings_i(eventPlayer) >= cat[SettingsCatProp.STARTING_INDEX]
        and dynamic_settings_i(eventPlayer) <= cat[SettingsCatProp.ENDING_INDEX])
    ][0]

    eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_SETTING] = settings_data[dynamic_settings_data(eventPlayer)[(eventPlayer.settings_i - 2 + len(dynamic_settings_data(eventPlayer))) % len(dynamic_settings_data(eventPlayer))]][SettingProp.TITLE]
    eventPlayer.settings_hud[SettingsHUD.PREVIOUS_SETTING] = settings_data[dynamic_settings_data(eventPlayer)[(eventPlayer.settings_i - 1 + len(dynamic_settings_data(eventPlayer))) % len(dynamic_settings_data(eventPlayer))]][SettingProp.TITLE]
    eventPlayer.settings_hud[SettingsHUD.CURRENT_SETTING] = current_setting_data(eventPlayer)[SettingProp.TITLE]
    eventPlayer.settings_hud[SettingsHUD.NEXT_SETTING] = settings_data[dynamic_settings_data(eventPlayer)[(eventPlayer.settings_i + 1) % len(dynamic_settings_data(eventPlayer))]][SettingProp.TITLE]
    eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_SETTING] = settings_data[dynamic_settings_data(eventPlayer)[(eventPlayer.settings_i + 2) % len(dynamic_settings_data(eventPlayer))]][SettingProp.TITLE]
    
    eventPlayer.settings_hud[SettingsHUD.CURRENT_SETTING_INDEX] = eventPlayer.settings_i + 1
    eventPlayer.settings_hud[SettingsHUD.TOTAL_SETTINGS] = len(dynamic_settings_data(eventPlayer))

    eventPlayer.settings_hud[SettingsHUD.TYPE] = current_setting_data(eventPlayer)[SettingProp.TYPE]
    switch eventPlayer.settings_hud[SettingsHUD.TYPE]:
        case SettingType.BOOLEAN:
            eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = ""
            if current_setting_value(eventPlayer):
                eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = "On"
            else:
                eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = "Off"
            eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = ""
            break
        case SettingType.MULTIPLE_CHOICE:
        case SettingType.MULTIPLE_CHOICE_RANDOM:
            if len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS]) >= 5:
                eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][(current_setting_value(eventPlayer) - 2 + len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS])) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS])]
                eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][(current_setting_value(eventPlayer) - 1 + len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS])) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS])]
                eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][(current_setting_value(eventPlayer) + 1) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS])]
                eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][(current_setting_value(eventPlayer) + 2) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS])]
            else:
                eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][current_setting_value(eventPlayer) - 2] if current_setting_value(eventPlayer) - 2 >= 0 else ""
                eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][current_setting_value(eventPlayer) - 1] if current_setting_value(eventPlayer) - 1 >= 0 else ""
                eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][current_setting_value(eventPlayer) + 1] if current_setting_value(eventPlayer) + 1 < len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS]) else ""
                eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][current_setting_value(eventPlayer) + 2] if current_setting_value(eventPlayer) + 2 < len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS]) else ""
            eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][current_setting_value(eventPlayer)]
            break
        case SettingType.INTERACT_MULTIPLE_CHOICE:
        case SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM:
            if len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1]) >= 5:
                eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][(current_setting_value(eventPlayer) - 2 + len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1])) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1])]
                eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][(current_setting_value(eventPlayer) - 1 + len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1])) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1])]
                eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][(current_setting_value(eventPlayer) + 1) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1])]
                eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][(current_setting_value(eventPlayer) + 2) % len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1])]
            else:
                eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][current_setting_value(eventPlayer) - 2] if current_setting_value(eventPlayer) - 2 >= 0 else ""
                eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][current_setting_value(eventPlayer) - 1] if current_setting_value(eventPlayer) - 1 >= 0 else ""
                eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][current_setting_value(eventPlayer) + 1] if current_setting_value(eventPlayer) + 1 < len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1]) else ""
                eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][current_setting_value(eventPlayer) + 2] if current_setting_value(eventPlayer) + 2 < len(current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1]) else ""
            eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = current_setting_data(eventPlayer)[SettingProp.PARAMETERS][1][current_setting_value(eventPlayer)]
            break
        case SettingType.COLOR_PICKER:
            eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = extended_color_data[(current_setting_value(eventPlayer) - 2 + len(extended_color_data)) % len(extended_color_data)]
            eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = extended_color_data[(current_setting_value(eventPlayer) - 1 + len(extended_color_data)) % len(extended_color_data)]
            eventPlayer.settings_hud[SettingsHUD.OPTION_COLOR] = current_setting_value(eventPlayer)
            eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = extended_color_data[current_setting_value(eventPlayer)]
            eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = extended_color_data[(current_setting_value(eventPlayer) + 1) % len(extended_color_data)]
            eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = extended_color_data[(current_setting_value(eventPlayer) + 2) % len(extended_color_data)]
            break
        case SettingType.NUMERIC:
        case SettingType.NUMERIC_REVERSIBLE:
            eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = format_numeric(current_setting_value(eventPlayer), current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.SUFFIX])
            if current_setting_value(eventPlayer) - 2 * current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP] >= current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.MIN]:
                eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = format_numeric(current_setting_value(eventPlayer) - 2 * current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP], current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.SUFFIX])
            else:
                eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = ""
            if current_setting_value(eventPlayer) - current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP] >= current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.MIN]:
                eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = format_numeric(current_setting_value(eventPlayer) - current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP], current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.SUFFIX])
            else:
                eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = ""
            if current_setting_value(eventPlayer) + current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP] <= current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.MAX]:
                eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = format_numeric(current_setting_value(eventPlayer) + current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP], current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.SUFFIX])
            else:
                eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = ""
            if current_setting_value(eventPlayer) + 2 * current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP] <= current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.MAX]:
                eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = format_numeric(current_setting_value(eventPlayer) + 2 * current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.STEP], current_setting_data(eventPlayer)[SettingProp.PARAMETERS][SettingTypeNumericProp.SUFFIX])
            else:
                eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = ""
            break
        case SettingType.KEYBOARD:
            eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = eventPlayer.settings[Setting.CUSTOM_MESSAGE]
            eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = ""
            break
        default:
            eventPlayer.settings_hud[SettingsHUD.SECOND_PREVIOUS_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.PREVIOUS_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.CURRENT_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.NEXT_OPTION] = ""
            eventPlayer.settings_hud[SettingsHUD.SECOND_NEXT_OPTION] = ""
            break

    if current_setting_data(eventPlayer)[SettingProp.COLORS][current_setting_value(eventPlayer)]:
        eventPlayer.settings_hud[SettingsHUD.OPTION_COLOR] = current_setting_data(eventPlayer)[SettingProp.COLORS][current_setting_value(eventPlayer)]
    elif current_setting_data(eventPlayer)[SettingProp.COLORS]:
        eventPlayer.settings_hud[SettingsHUD.OPTION_COLOR] = current_setting_data(eventPlayer)[SettingProp.COLORS]
    else:
        eventPlayer.settings_hud[SettingsHUD.OPTION_COLOR] = ExtendedColor.WHITE    
    
    if current_setting_data(eventPlayer)[SettingProp.DESCRIPTIONS][current_setting_value(eventPlayer)]:
        eventPlayer.settings_hud[SettingsHUD.DESCRIPTION] = current_setting_data(eventPlayer)[SettingProp.DESCRIPTIONS][current_setting_value(eventPlayer)]
    else:
        eventPlayer.settings_hud[SettingsHUD.DESCRIPTION] = current_setting_data(eventPlayer)[SettingProp.DESCRIPTIONS]
    eventPlayer.settings_hud[SettingsHUD.CHILL_REQUIRED] = current_setting_data(eventPlayer)[SettingProp.CHILL_REQUIRED]


def InteractWithSettings():
    @Name "— Interact with settings"

    switch dynamic_settings_i(eventPlayer):
        case Setting.SWITCH_HERO:
            ExitSettingsMenu()
            eventPlayer.startForcingHero(getAllHeroes()[eventPlayer.settings[Setting.SWITCH_HERO]])
            wait()
            eventPlayer.stopForcingCurrentHero()
            break
        case Setting.FAST_TRAVEL_TO_OBJECTIVE:
            ExitSettingsMenu()
            if (
                eventPlayer.settings[Setting.PLAYER_MODE]
                and getObjectivePosition(eventPlayer.settings[Setting.FAST_TRAVEL_TO_OBJECTIVE]) != vect(0, 0, 0)
            ):
                eventPlayer.teleport(nearestWalkablePosition(getObjectivePosition(eventPlayer.settings[Setting.FAST_TRAVEL_TO_OBJECTIVE])))
                BuffImpactSound()
            elif not eventPlayer.settings[Setting.PLAYER_MODE]:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "Can't fast travel in kill mode")
            else:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "Objective doesn't exist")
            break
        case Setting.THIRD_PERSON:
        case Setting.THIRD_PERSON_DISTANCE:
        case Setting.THIRD_PERSON_OFFSET:
        case Setting.THIRD_PERSON_SMOOTHING:
            if PendingSetting.CAMERA not in eventPlayer.pending_settings: 
                eventPlayer.pending_settings.append(PendingSetting.CAMERA)
            break
        case Setting.SWITCH_TEAM:
            ExitSettingsMenu()
            if getCurrentGamemode() == Gamemode.SKIRMISH:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "Switching teams disabled due to server crashes")
                # moveToTeam(eventPlayer, getOppositeTeam(eventPlayer.getTeam()), -1)
            else:
                DebuffImpactSound()
                iconMessage(eventPlayer, iconString(Icon.WARNING), "This gamemode doesn't support switching teams")
            break
        case Setting.RESET:
            ExitSettingsMenu()
            RemoveBase()
            LoadDefaultSettings()
            InitializePlayer()
            BuffImpactSound()
            iconMessage(eventPlayer, iconString(Icon.CHECKMARK), "Settings reset")
            break
        case Setting.CUSTOM_MESSAGE:
            eventPlayer.uiState = UIState.KEYBOARD_INPUT
            break
        case Setting.AURA:
        case Setting.AURA_EFFECT:
        case Setting.HIDE_AURA_IN_FIRST_PERSON:
            async(UpdateAura, AsyncBehavior.RESTART)
            break
        case Setting.PLAYER_MODE:
        case Setting.DAMAGE:
        case Setting.HEALING:
        case Setting.HEALTH:
            if PendingSetting.HERO not in eventPlayer.pending_settings: 
                eventPlayer.pending_settings.append(PendingSetting.HERO)
            break
        case Setting.OUTLINE_COLOR:
            updateHeroOutline()
            break
        case Setting.SIZE:
        case Setting.NOCLIP:
            if PendingSetting.SIZE_NOCLIP not in eventPlayer.pending_settings: 
                eventPlayer.pending_settings.append(PendingSetting.SIZE_NOCLIP)
            break
        case Setting.FLIGHT:
            UpdateFlight()
            break
        case Setting.KNOCKBACK:
            UpdateKnockback()
            break
        case Setting.PROJECTILE_SPEED:
        case Setting.PROJECTILE_GRAVITY:
            UpdateProjectiles()
            break
        case Setting.VOICE_PITCH:
            updatePitch()
            break
        case Setting.AMMO_OVERLOAD:
            UpdateAmmo()
            break
        case Setting.INVISIBILITY:
            if PendingSetting.SIZE_NOCLIP not in eventPlayer.pending_settings: 
                eventPlayer.pending_settings.append(PendingSetting.SIZE_NOCLIP)
            break
        case Setting.ALLOW_MOUNTING:
            if (
                not eventPlayer.settings[Setting.ALLOW_MOUNTING]
                and eventPlayer.rider
            ):
                EjectRider()
            break
        case Setting.MOUNTING_MODE:
            UpdateRider()
            break
        case Setting.BASE_MODE:
            recreateBase()
            eventPlayer.activate_base_now = true
            break
        case Setting.BASE_SIZE:
            while isOverlappingBase(
                eventPlayer.base_vector,
                eventPlayer.settings[Setting.BASE_SIZE],
                eventPlayer.settings[Setting.BASE_GAP_SIZE]
            ) and eventPlayer.settings[Setting.BASE_SIZE] > settings_data[Setting.BASE_SIZE][SettingProp.PARAMETERS][SettingTypeNumericProp.MIN]:
                eventPlayer.settings[Setting.BASE_SIZE] -= settings_data[Setting.BASE_SIZE][SettingProp.PARAMETERS][SettingTypeNumericProp.STEP]
            eventPlayer.settings[Setting.BASE_SIZE] = max(
                eventPlayer.settings[Setting.BASE_SIZE],
                settings_data[Setting.BASE_SIZE][SettingProp.PARAMETERS][SettingTypeNumericProp.MIN]
            )
            break
        case Setting.BASE_GAP_SIZE:
            while isOverlappingBase(
                eventPlayer.base_vector,
                eventPlayer.settings[Setting.BASE_SIZE],
                eventPlayer.settings[Setting.BASE_GAP_SIZE]
            ) and eventPlayer.settings[Setting.BASE_GAP_SIZE] > settings_data[Setting.BASE_GAP_SIZE][SettingProp.PARAMETERS][SettingTypeNumericProp.MIN]:
                eventPlayer.settings[Setting.BASE_GAP_SIZE] -= settings_data[Setting.BASE_GAP_SIZE][SettingProp.PARAMETERS][SettingTypeNumericProp.STEP]
            eventPlayer.settings[Setting.BASE_GAP_SIZE] = max(
                eventPlayer.settings[Setting.BASE_GAP_SIZE],
                settings_data[Setting.BASE_GAP_SIZE][SettingProp.PARAMETERS][SettingTypeNumericProp.MIN]
            )
            break
        case Setting.BASE_NOCLIP:
        case Setting.BASE_GRAVITY:
        case Setting.BASE_SPEED:
        case Setting.BASE_JUMP_SPEED:
            eventPlayer.base_settings_changed = true
            break
        case Setting.BASE_LOCK:
            UpdateBaseOwner()
            break
        case Setting.DREAM_MODE:
            ExitSettingsMenu()
            DreamMode()
            break
        case Setting.AFK_TIMER:
            UpdateAFKTimer()
            break
        case Setting.GRAVITY:
        case Setting.SPEED:
        case Setting.JUMP_SPEED:
            UpdatePhysics()
            break
    UpdateSettingsHUDs()
    BackupPlayer()


def ApplyPendingSettings():
    @Name "— Apply settings"

    while len(eventPlayer.pending_settings) > 0:
        switch eventPlayer.pending_settings[0]:
            case PendingSetting.CAMERA:
                UpdateCamera()
                break
            case PendingSetting.HERO:
                UpdateHero()
                break
            case PendingSetting.SIZE_NOCLIP:
                UpdateSizeNoclip()
                break
            case PendingSetting.INVISIBILITY:
                UpdateInvisibility()
                break
        del eventPlayer.pending_settings[0]


def Tutorial():
    @Name "— Tutorial"

    if not eventPlayer.has_created_base_once:
        eventPlayer.has_created_base_once = true
        # Camera
        eventPlayer.startCamera(
            eye(), 
            raycast(
                eye(),
                eye() + face() * 100,
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            1
        )
        wait()
        eventPlayer.startCamera(
            raycast(
                eventPlayer.base_vector,
                eventPlayer.base_vector + (Vector.UP * s(Setting.BASE_SIZE) * 2) + (Vector.BACKWARD / 2),
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            eventPlayer.base_vector,
            30
        )
        # Force position and facing
        eventPlayer.startForcingPosition(
            raycast(
                eventPlayer.base_vector,
                eventPlayer.base_vector + Vector.BACKWARD * min(1, s(Setting.BASE_SIZE)),
                null,
                eventPlayer,
                false
            ).getHitPosition(),
            false
        )
        eventPlayer.startFacing(
            directionTowards(eventPlayer.base_vector, eye()),
            360,
            Relativity.TO_WORLD,
            FacingReeval.DIRECTION_AND_TURN_RATE
        )
        eventPlayer.disableHeroHUD()
        eventPlayer.setInvisibility(Invis.ALL)
        bigMessage(eventPlayer, f"Awesome! Check out the settings menu by holding {buttonToString(Button.INTERACT)}.")
        wait(4)
        bigMessage(eventPlayer, "Change a setting or two and see what happens!")
        wait(4)
        switch workshop_settings[WorkshopSettings.SERVER_MODE]:
            case Mode.SLEEP:
                bigMessage(eventPlayer, f"Sweet dreams, {eventPlayer}!")
                break
            case Mode.MUSIC:
                bigMessage(eventPlayer, f"Enjoy the music, {eventPlayer}!")
                break
            default:
                bigMessage(eventPlayer, f"Happy chilling, {eventPlayer}!")
                break
        eventPlayer.stopForcingPosition()
        eventPlayer.stopFacing()
        eventPlayer.enableHeroHud()
    UpdateCamera()
    UpdateInvisibility()