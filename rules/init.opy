#!mainFile "../main.opy"

rule "Initialization":
    @Delimiter
    @Disabled


rule "— Assemble heroes":
    @Condition isAssemblingHeroes()

    setMatchTime(0)


rule "— Avoid server crashes":
    @Condition getServerLoad() >= 175

    wait(1, Wait.ABORT_WHEN_FALSE)

    isOverloaded = true
    iconMessage(getAllPlayers(), iconString(Icon.WARNING), "slowing down to avoid server crash")
    setSlowMotion(20)

    wait(1)
    waitUntil(getServerLoad() < 175, Math.INFINITY)

    isOverloaded = false
    setSlowMotion(100)


rule "— Populate global variables":
    

    switch workshop_settings[WorkshopSettings.SERVER_MODE]:
        case Mode.SHIFTEREST:
            god_usernames = ["shifterest", "Cage", "aerhysu", "IAmNoOb", "Bastion", "Quiver", "Forgive", "Zeshirow"]
            break
        default:
            god_usernames = []
            break
    ban_usernames = []
    comms_ban_usernames = []
    mod_usernames = [f"{hostPlayer}"]

    extended_color_data = [
        Color.WHITE,
        Color.GRAY,
        Color.BLACK,
        Color.RED,
        Color.ORANGE,
        Color.YELLOW,
        Color.GREEN,
        Color.LIME_GREEN,
        Color.AQUA,
        Color.TURQUOISE,
        Color.SKY_BLUE,
        Color.BLUE,
        Color.VIOLET,
        Color.PURPLE,
        Color.ROSE,
        "rainbow"
    ]

    base_mode_icon_data = [
        abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
        iconString(Icon.EYE),
        abilityIconString(Hero.ZARYA, Button.ABILITY_1),
        iconString(Icon.NO),
        abilityIconString(Hero.HAZARD, Button.ABILITY_2)
    ]

    # Game
    settings_data[Setting.PLAYER_MODE] = [
        "player mode",
        [
            "No special features, kill or be killed.",
            "Enable chill features. Be as harmless or lethal as you want.",
            "Enable invulnerability, disable most abilities."
        ],
        SettingType.MULTIPLE_CHOICE,
        [
            f"{iconString(Icon.SKULL)} kill",
            f"{abilityIconString(Hero.MEI, Button.ULTIMATE)} chill",
            f"{abilityIconString(Hero.ZENYATTA, Button.ULTIMATE)} zen"
        ],
        [ExtendedColor.RED, ExtendedColor.SKY_BLUE, ExtendedColor.GREEN]
    ]
    settings_data[Setting.THIRD_PERSON] = [
        "third-person camera",
        "Select a third-person camera perspective.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["off", "rear", "top-down", "static top-down", "front"]
    ]
    settings_data[Setting.THIRD_PERSON_DISTANCE] = [
        "third-person camera distance",
        "Specify the distance of the camera in third-person view.",
        SettingType.NUMERIC,
        [10, 1000, 10, "%"]
    ]
    settings_data[Setting.THIRD_PERSON_OFFSET] = [
        "third-person offset",
        "Specify the horizontal offset of the camera in third-person view.",
        SettingType.NUMERIC_REVERSIBLE,
        [-5, 5, 0.5, "m"]
    ]
    settings_data[Setting.THIRD_PERSON_SMOOTHING] = [
        "third-person smoothing",
        "Third-person camera smoothing is forcibly enabled in this server." if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else "Enable third-person camera smoothing, sacrificing accuracy.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.SWITCH_HERO] = [
        "Switch hero",
        "Switch heroes (in case of bugs in the Overwatch hero picker).",
        SettingType.INTERACT_MULTIPLE_CHOICE_RANDOM,
        [0.6, [f"{heroIcon(hero)} {hero}" for hero in getAllHeroes()]]
    ]
    settings_data[Setting.SHOW_HOTKEYS] = [
        "show hotkeys",
        "Enable the display of gameplay hotkeys.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.STASIS] = [
        "stasis",
        "Temporarily immobilize yourself.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    settings_data[Setting.STASIS_MODE] = [
        "stasis mode",
        "Select the status effect to apply during stasis.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["knock down", "stun", "sleep", "freeze"],
        null,
        true
    ]
    settings_data[Setting.FAST_TRAVEL] = [
        "fast travel",
        "Enable teleportation between bases and key locations.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    settings_data[Setting.FAST_TRAVEL_TO_OBJECTIVE] = [
        "fast travel to objective",
        "Quickly jump to objectives.",
        SettingType.INTERACT_MULTIPLE_CHOICE,
        [0.6, ["first", "second", "third"]],
        null,
        true
    ]
    settings_data[Setting.INSTANT_RESPAWN] = [
        "instant respawn",
        "Initiate immediate respawn at the base after death.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.REMOVE_BASE_REMOTELY] = [
        "remove base remotely",
        "Enable remote removal of your base.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.SWITCH_TEAM] = [
        "switch team",
        "Switch teams in skirmish maps.",
        SettingType.INTERACT,
        1
    ]
    settings_data[Setting.RESET] = [
        "reset",
        "Reset all your settings.",
        SettingType.INTERACT,
        1
    ]
    # Hero
    settings_data[Setting.OUTLINE_COLOR] = [
        "outline color",
        "Select an outline color.",
        SettingType.COLOR_PICKER,
        true
    ]
    settings_data[Setting.FLIGHT] = [
        "flight",
        "Enable or disable flight capability.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    settings_data[Setting.FLIGHT_ACCELERATION] = [
        "flight acceleration",
        "Set the acceleration for flight.",
        SettingType.NUMERIC,
        [5, 100, 5],
        null,
        true
    ]
    settings_data[Setting.SIZE] = [
        "size",
        "Adjust the size of the hero.",
        SettingType.NUMERIC,
        [10, 500, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.GRAVITY] = [
        "gravity",
        "Set the gravity on the hero.",
        SettingType.NUMERIC,
        [0, 500, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.SPEED] = [
        "speed",
        "Define the movement speed of the hero.",
        SettingType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.JUMP_SPEED] = [
        "jump speed",
        "Adjust the jump speed of the hero.",
        SettingType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.VOICE_PITCH] = [
        "voice pitch",
        "Adjust the pitch of the hero's voice.",
        SettingType.NUMERIC,
        [50, 150, 10, "%"]
    ]
    # Abilities
    settings_data[Setting.DAMAGE] = [
        "damage",
        "Set the damage output percentage.",
        SettingType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        true
    ]
    settings_data[Setting.DAMAGE_EFFECT] = [
        "damage effect",
        "Select the effect applied upon dealing damage.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        true
    ]
    settings_data[Setting.HEALING] = [
        "healing",
        "Set the healing output percentage.",
        SettingType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        true
    ]
    settings_data[Setting.HEALING_EFFECT] = [
        "healing effect",
        "Select the effect applied during healing.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        true
    ]
    settings_data[Setting.HEALTH] = [
        "health",
        "Set the health pool percentage.",
        SettingType.NUMERIC,
        [10, 5000, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.THORNS] = [
        "thorns",
        "Set the damage reflection percentage.",
        SettingType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        true
    ]
    settings_data[Setting.THORNS_EFFECT] = [
        "thorns effect",
        "Select the effect applied when reflecting damage.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        true
    ]
    settings_data[Setting.ABILITY_MODE] = [
        "ability mode",
        [
            "Standard ability cooldowns.",
            "Reduced ability cooldowns.",
            "Hold for repeated use."
        ],
        SettingType.MULTIPLE_CHOICE,
        ["normal", "no cooldown"] if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else ["normal", "no cooldown", "hold to spam"],
        null,
        true
    ]
    settings_data[Setting.ABILITY_SPAM_DELAY] = [
        "ability spam delay",
        "Ability spam is disabled on this server." if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else "Set the delay between successive ability activations.",
        SettingType.NUMERIC,
        [0.01, 1, 0.01, " second(s)"],
        ExtendedColor.GRAY if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else ExtendedColor.WHITE,
        true
    ]
    settings_data[Setting.ULTIMATE_MODE] = [
        "ultimate mode",
        [
            "Standard ultimate cooldowns.",
            "Reduced ultimate cooldowns.",
            "Instant ultimate recasts.",
            "Hold for repeated use."
        ],
        SettingType.MULTIPLE_CHOICE,
        ["normal", "no cooldown"] if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else ["normal", "no cooldown", "infinite", "hold to spam"],
        null,
        true
    ]
    settings_data[Setting.ULTIMATE_SPAM_DELAY] = [
        "ultimate spam delay",
        "Ultimate spam is disabled on this server." if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else "Set the delay between successive ultimate activations.",
        SettingType.NUMERIC,
        [0.01, 1, 0.01, " second(s)"],
        ExtendedColor.GRAY if workshop_settings[WorkshopSettings.REDUCE_SERVER_LOAD] else ExtendedColor.WHITE,
        true
    ]
    settings_data[Setting.KNOCKBACK] = [
        "knockback",
        "Adjust the force of the knockback effect.",
        SettingType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.PROJECTILE_SPEED] = [
        "projectile speed",
        "Specify the speed of projectiles.",
        SettingType.NUMERIC,
        [0, 1000, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.PROJECTILE_GRAVITY] = [
        "projectile gravity",
        "Set the gravitational effect on projectiles.",
        SettingType.NUMERIC,
        [0, 1000, 10, "%"],
        null,
        true
    ]
    settings_data[Setting.AMMO_OVERLOAD] = [
        "ammo overload",
        "Enable unlimited ammo and increased ammo clips.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    # Effects
    settings_data[Setting.CUSTOM_MESSAGE] = [
        "custom message",
        "Enter a personal message to be displayed above the player.",
        SettingType.KEYBOARD
    ]
    settings_data[Setting.CUSTOM_MESSAGE_COLOR] = [
        "custom message color",
        "Select a color for the displayed message.",
        SettingType.COLOR_PICKER,
        true
    ]
    settings_data[Setting.AURA] = [
        "aura",
        "Enable or disable a surrounding glowing effect.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    settings_data[Setting.AURA_EFFECT] = [
        "aura effect",
        "Select the shape of the aura effect.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["sparkles", "cloud", "light shaft", "good aura", "bad aura", "ring", "sphere"],
        null,
        true
    ]
    settings_data[Setting.AURA_COLOR] = [
        "aura color",
        "Select a color for the aura effect.",
        SettingType.COLOR_PICKER,
        true,
        null,
        true
    ]
    settings_data[Setting.AURA_SIZE] = [
        "aura size",
        "Specify the size of the aura effect.",
        SettingType.NUMERIC,
        [10, 1000, 10, "m"],
        null,
        true
    ]
    settings_data[Setting.HIDE_AURA_IN_FIRST_PERSON] = [
        "hide aura in first-person",
        "Disable the aura effect when in first-person view.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    # Special
    settings_data[Setting.NOCLIP] = [
        "noclip",
        "Enable or disable the ability to move through walls.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    settings_data[Setting.INVISIBILITY] = [
        "invisibility",
        "Enable or disable the invisibility state of the hero.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    settings_data[Setting.ALLOW_MOUNTING] = [
        "allow mounting",
        "Enable or disable mounting.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.MOUNTING_MODE] = [
        "mounting mode",
        "Select the preferred arrangement for mounting.",
        SettingType.MULTIPLE_CHOICE_RANDOM,
        ["stack", "intersect", "front", "back", "left", "right"]
    ]
    settings_data[Setting.TRAMPOLINE] = [
        "trampoline mode",
        "Enable automatic jump upon landing. Hold crouch to stop.",
        SettingType.BOOLEAN,
        null,
        null,
        true
    ]
    # Base
    settings_data[Setting.BASE_MODE] = [
        "base mode",
        [
            "Provides protection for the player, disregarding other players.",
            "Provides protection for the player, disappearing from sight.",
            "Provides protection and serves as a fast travel point for all players.",
            "Provides protection for the player, actively repelling other players.",
            "Provides protection for the player, actively damaging other players."
        ],
        SettingType.MULTIPLE_CHOICE,
        [
            "{} passive".format(base_mode_icon_data[BaseMode.PASSIVE]),
            "{} hidden".format(base_mode_icon_data[BaseMode.HIDDEN]),
            "{} friendly".format(base_mode_icon_data[BaseMode.FRIENDLY]),
            "{} repulsive".format(base_mode_icon_data[BaseMode.REPULSIVE]),
            "{} hostile".format(base_mode_icon_data[BaseMode.HOSTILE])
        ],
        [
            ExtendedColor.GREEN,
            ExtendedColor.PURPLE,
            ExtendedColor.BLUE,
            ExtendedColor.ORANGE,
            ExtendedColor.RED
        ]
    ]
    settings_data[Setting.BASE_COLOR] = [
        "base color",
        "Select a color for the base.",
        SettingType.COLOR_PICKER,
        true
    ]
    settings_data[Setting.BASE_SIZE] = [
        "base size",
        "Specify the size of the base.",
        SettingType.NUMERIC,
        [1, 15, 0.5, "m"]
    ]
    settings_data[Setting.BASE_GAP_SIZE] = [
        "base gap size",
        "Define the minimum distance between bases.",
        SettingType.NUMERIC,
        [0, 8, 0.5, "m"]
    ]
    settings_data[Setting.BASE_LOCK] = [
        "base lock",
        "Enable or disable base locking for security.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.BASE_NOCLIP] = [
        "in-base noclip",
        "Enable or disable noclip within the base.",
        SettingType.BOOLEAN
    ]
    settings_data[Setting.BASE_GRAVITY] = [
        "in-base gravity",
        "Specify the gravity setting within the base.",
        SettingType.NUMERIC,
        [0, 500, 10, "%"]
    ]
    settings_data[Setting.BASE_SPEED] = [
        "in-base speed",
        "Specify the movement speed within the base.",
        SettingType.NUMERIC,
        [10, 500, 10, "%"]
    ]
    settings_data[Setting.BASE_JUMP_SPEED] = [
        "in-base jump speed",
        "Specify the jump speed within the base.",
        SettingType.NUMERIC,
        [10, 500, 10, "%"]
    ]
    # Dream
    settings_data[Setting.DREAM_MODE] = [
        "enable dream mode",
        "Activate dream mode to allow spectator view.",
        SettingType.INTERACT_BOOLEAN,
        0.6
    ]
    settings_data[Setting.AFK_TIMER] = [
        "AFK timer",
        "Set the idle time (in minutes) after which dream mode is activated.",
        SettingType.NUMERIC,
        [0, 60, 0.5, " minute(s)"]
    ]
    settings_data[Setting.SWITCH_TIMER] = [
        "player switch timer",
        "Define the duration for switching players in dream mode.",
        SettingType.NUMERIC,
        [3, 180, 1, " seconds"]
    ]
    settings_data[Setting.CLIP_CAMERA] = [
        "clip camera",
        "Enable or disable camera collision in dream mode.",
        SettingType.BOOLEAN
    ]

    settings_cat_data = [
        ["Quick", -1, -1, ExtendedColor.BLUE],
        ["Game", Setting.PLAYER_MODE, Setting.RESET, ExtendedColor.GREEN],
        ["Hero", Setting.OUTLINE_COLOR, Setting.VOICE_PITCH, ExtendedColor.YELLOW],
        ["Abilities", Setting.DAMAGE, Setting.AMMO_OVERLOAD, ExtendedColor.PURPLE],
        ["Effects", Setting.CUSTOM_MESSAGE, Setting.HIDE_AURA_IN_FIRST_PERSON, ExtendedColor.VIOLET],
        ["Special", Setting.NOCLIP, Setting.TRAMPOLINE, ExtendedColor.TURQUOISE],
        ["Base", Setting.BASE_MODE, Setting.BASE_JUMP_SPEED, ExtendedColor.ROSE],
        ["Dream", Setting.DREAM_MODE, Setting.CLIP_CAMERA, ExtendedColor.AQUA],
    ]

    quick_settings_data = [
        Setting.PLAYER_MODE,
        Setting.BASE_MODE,
        Setting.THIRD_PERSON,
        Setting.SWITCH_HERO,
        Setting.FAST_TRAVEL_TO_OBJECTIVE,
        Setting.CUSTOM_MESSAGE,
        Setting.AURA,
        Setting.SIZE,
        Setting.SPEED,
        Setting.DAMAGE,
        Setting.HEALTH,
        Setting.THORNS,
        Setting.NOCLIP,
        Setting.INVISIBILITY,
        Setting.TRAMPOLINE,
        Setting.BASE_COLOR,
        Setting.BASE_SIZE,
        Setting.DREAM_MODE,
    ]

    # Game
    default_settings[Setting.PLAYER_MODE] = PlayerMode.CHILL
    default_settings[Setting.THIRD_PERSON] = ThirdPersonCamera.REAR
    default_settings[Setting.THIRD_PERSON_DISTANCE] = 100
    default_settings[Setting.THIRD_PERSON_OFFSET] = 1
    default_settings[Setting.THIRD_PERSON_SMOOTHING] = true
    default_settings[Setting.SHOW_HOTKEYS] = true
    default_settings[Setting.STASIS] = true
    default_settings[Setting.STASIS_MODE] = Stasis.KNOCKED_DOWN
    default_settings[Setting.FAST_TRAVEL] = true
    default_settings[Setting.INSTANT_RESPAWN] = true
    default_settings[Setting.REMOVE_BASE_REMOTELY] = true
    # Hero
    default_settings[Setting.OUTLINE_COLOR] = ExtendedColor.WHITE
    default_settings[Setting.FLIGHT] = true
    default_settings[Setting.FLIGHT_ACCELERATION] = 25
    default_settings[Setting.SIZE] = 100
    default_settings[Setting.GRAVITY] = 100
    default_settings[Setting.SPEED] = 100
    default_settings[Setting.JUMP_SPEED] = 100
    default_settings[Setting.VOICE_PITCH] = 100
    # Abilities
    default_settings[Setting.DAMAGE] = 100
    default_settings[Setting.DAMAGE_EFFECT] = AbilityEffect.NONE
    default_settings[Setting.HEALING] = 100
    default_settings[Setting.HEALING_EFFECT] = AbilityEffect.NONE
    default_settings[Setting.HEALTH] = 100
    default_settings[Setting.THORNS] = 100
    default_settings[Setting.THORNS_EFFECT] = AbilityEffect.NONE
    default_settings[Setting.ABILITY_MODE] = AbilityMode.NO_COOLDOWN
    default_settings[Setting.ABILITY_SPAM_DELAY] = 0.05
    default_settings[Setting.ULTIMATE_MODE] = UltimateMode.NO_COOLDOWN
    default_settings[Setting.ULTIMATE_SPAM_DELAY] = 0.05
    default_settings[Setting.KNOCKBACK] = 100
    default_settings[Setting.PROJECTILE_SPEED] = 100
    default_settings[Setting.PROJECTILE_GRAVITY] = 100
    default_settings[Setting.AMMO_OVERLOAD] = true
    # Effects
    default_settings[Setting.CUSTOM_MESSAGE] = ""
    default_settings[Setting.CUSTOM_MESSAGE_COLOR] = ExtendedColor.WHITE
    default_settings[Setting.AURA] = true
    default_settings[Setting.AURA_EFFECT] = ChillEffect.SPARKLES
    default_settings[Setting.AURA_COLOR] = ExtendedColor.WHITE
    default_settings[Setting.AURA_SIZE] = 150
    default_settings[Setting.HIDE_AURA_IN_FIRST_PERSON] = false
    # Special
    default_settings[Setting.NOCLIP] = false
    default_settings[Setting.INVISIBILITY] = false
    default_settings[Setting.ALLOW_MOUNTING] = true
    default_settings[Setting.MOUNTING_MODE] = MountingMode.STACK
    default_settings[Setting.TRAMPOLINE] = false
    # Base
    default_settings[Setting.BASE_MODE] = BaseMode.PASSIVE
    default_settings[Setting.BASE_COLOR] = ExtendedColor.ORANGE
    default_settings[Setting.BASE_SIZE] = 3.5
    default_settings[Setting.BASE_GAP_SIZE] = 0
    default_settings[Setting.BASE_LOCK] = false
    default_settings[Setting.BASE_NOCLIP] = false
    default_settings[Setting.BASE_GRAVITY] = 100
    default_settings[Setting.BASE_SPEED] = 100
    default_settings[Setting.BASE_JUMP_SPEED] = 100
    # Dream
    default_settings[Setting.AFK_TIMER] = 0
    default_settings[Setting.SWITCH_TIMER] = 10
    default_settings[Setting.CLIP_CAMERA] = true

    isInitialized = true


rule "— Initialize game":
    @Condition isGameInProgress()
    @Condition isInitialized

    setMatchTime(workshop_settings[WorkshopSettings.MATCH_TIME])
    disableGamemodeCompletion()
    if not workshop_settings[WorkshopSettings.ENABLE_MATCH_TIMER]:
        pauseMatchTime()
    if not workshop_settings[WorkshopSettings.ENABLE_INSPECTOR]:
        disableInspector()


rule "— Initialize player":
    @Event eachPlayer
    @Condition isInitialized

    eventPlayer.disableGamemodeHud()
    if not workshop_settings[WorkshopSettings.ENABLE_SCOREBOARD]:
        eventPlayer.disableScoreboard()
    if eventPlayer.settings:
        HardReset()
    if f"{eventPlayer}" in mod_usernames:
        async(UpdateModeratorListHUD, AsyncBehavior.RESTART)
    if player_names_backups.index(f"{eventPlayer}") >= 0:
        if base_vectors_backups[player_names_backups.index(f"{eventPlayer}")] and not isOverlappingBase(
            base_vectors_backups[player_names_backups.index(f"{eventPlayer}")],
            settings_backups[player_names_backups.index(f"{eventPlayer}")][Setting.BASE_SIZE],
            settings_backups[player_names_backups.index(f"{eventPlayer}")][Setting.BASE_GAP_SIZE]
        ):
            eventPlayer.base_vector = base_vectors_backups[player_names_backups.index(f"{eventPlayer}")]
            eventPlayer.has_created_base_once = true
            CreateBase()
        eventPlayer.settings = settings_backups[player_names_backups.index(f"{eventPlayer}")]
    else:
        LoadDefaultSettings()

        # loadouts
        switch f"{eventPlayer}":
            case "shifterest":
                eventPlayer.has_created_base_once = true
                s(Setting.PLAYER_MODE) = PlayerMode.CHILL
                s(Setting.BASE_MODE) = BaseMode.FRIENDLY
                s(Setting.FLIGHT) = true
                s(Setting.SPEED) = 200
                s(Setting.JUMP_SPEED) = 150
                s(Setting.KNOCKBACK) = 100
                s(Setting.PROJECTILE_GRAVITY) = 100
                s(Setting.PROJECTILE_SPEED) = 1000
                s(Setting.DAMAGE) = 0
                s(Setting.HEALTH) = 1000
                s(Setting.DAMAGE_EFFECT) = AbilityEffect.SLEEP
                s(Setting.THORNS_EFFECT) = AbilityEffect.SLEEP
                s(Setting.CUSTOM_MESSAGE) = "uwu"
                s(Setting.CUSTOM_MESSAGE_COLOR) = ExtendedColor.RAINBOW
                s(Setting.AURA_EFFECT) = ChillEffect.SPARKLES
                s(Setting.AURA_COLOR) = ExtendedColor.RAINBOW
                s(Setting.BASE_SPEED) = 200
                s(Setting.BASE_JUMP_SPEED) = 500
                s(Setting.AFK_TIMER) = 1
                s(Setting.THIRD_PERSON) = false
                break
            case "QueenWolf":
                eventPlayer.has_created_base_once = true
                s(Setting.CUSTOM_MESSAGE) = "♡ R O Y A L T Y ♡"
                s(Setting.PLAYER_MODE) = PlayerMode.CHILL
                s(Setting.OUTLINE_COLOR) = ExtendedColor.RAINBOW
                s(Setting.CUSTOM_MESSAGE_COLOR) = random.choice([ExtendedColor.ROSE, ExtendedColor.RAINBOW])
                s(Setting.AURA_COLOR) = random.choice([ExtendedColor.ROSE, ExtendedColor.RAINBOW])
                break
            case "DJBASTION":
            case "Bastion":
                eventPlayer.setAllowedHeroes(Hero.BASTION)
                break
    InitializePlayer()
    chase(eventPlayer.death_throttle, 0, rate=0.5, ChaseReeval.NONE)

    wait(0.25)

    if player_names_backups.index(f"{eventPlayer}") < 0:
        bigMessage(eventPlayer, "welcome to chill / kill bases!")

        wait(4)

        bigMessage(eventPlayer, "to get started, hold {} to create a base.".format(buttonToString(Button.INTERACT)))
        switch workshop_settings[WorkshopSettings.SERVER_MODE]:
            case Mode.MUSIC:
            case Mode.SLEEP:
                wait(4)

                bigMessage(eventPlayer, "then, join match voice chat for some music!".format(buttonToString(Button.INTERACT)))
                break
    else:
        bigMessage(eventPlayer, "welcome back! Your settings have been restored.")


rule "— End game":
    @Condition getMatchTime() <= 0

    wait(0.25, Wait.ABORT_WHEN_FALSE)
    declarePlayerVictory(null)

    if workshop_settings[WorkshopSettings.ENABLE_POTG]:
        wait(10)

    restartMatch()


def LoadDefaultSettings():
    @Name "— Load default settings"

    eventPlayer.settings = default_settings

    if workshop_settings[WorkshopSettings.RANDOMIZE_OUTLINE_COLOR]:
        s(Setting.OUTLINE_COLOR) = random.randint(ExtendedColor.YELLOW, ExtendedColor.BLACK)
    if workshop_settings[WorkshopSettings.RANDOMIZE_BASE_COLOR]:
        s(Setting.BASE_COLOR) = random.randint(ExtendedColor.YELLOW, ExtendedColor.BLACK)
    if workshop_settings[WorkshopSettings.RANDOMIZE_CHILL_COLOR]:
        s(Setting.AURA_COLOR) = random.randint(ExtendedColor.YELLOW, ExtendedColor.BLACK)


def HardReset():
    @Name "— Hard reset"

    # Find: playervar\s+(\w+)
    # Replace: eventPlayer.$1 = null

    eventPlayer.progress_hud = null
    eventPlayer.in_world_hud = null
    eventPlayer.settings_hud = null
    eventPlayer.onscreen_hud = null
    eventPlayer.name_to_ban = null
    eventPlayer.base_vector = null
    eventPlayer.has_created_base_once = null
    eventPlayer.activate_base_now = null
    eventPlayer.base_settings_changed = null
    eventPlayer.last_known_base_owner = null
    eventPlayer.last_known_base_mode = null
    eventPlayer.current_base_owner = null
    eventPlayer.active_base_owner = null
    eventPlayer.base_to_fast_travel_owner = null
    eventPlayer.settings_i = null
    eventPlayer.settings = null
    eventPlayer.setting_adjustment = null
    eventPlayer.uiState = null
    eventPlayer.isInModStasis = null
    eventPlayer.isInStasis = null
    eventPlayer.isInvisible = null
    eventPlayer.death_throttle = null
    eventPlayer.progress = null
    eventPlayer.base_progress = null
    eventPlayer.interaction_progress = null
    eventPlayer.afk_timer = null
    eventPlayer.mount = null
    eventPlayer.rider = null
    eventPlayer.chill_effect_id = null
    eventPlayer.base_effect_id = null
    eventPlayer.icon_effect_id = null
    eventPlayer.description_effect_id = null
    eventPlayer.message_effect_id = null
    eventPlayer.focused_player = null
    eventPlayer.last_pos = null
    eventPlayer.last_transform = null
    eventPlayer.keyboard_input_char = null
    eventPlayer.last_facing_dir = null
    eventPlayer.last_hero = null