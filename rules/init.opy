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
    mode = createWorkshopSetting(enum["Default", "Music", "Sleep", "shifterest"], "game preferences", "lobby mode", 0, 0)
    optimize = createWorkshopSetting(bool, "game preferences", "optimize server load", false, 2)

    switch mode:
        case Mode.SHIFTEREST:
            god_list = ["shifterest", "Cage", "aerhysu", "IAmNoOb", "Bastion", "Quiver", "Forgive", "Zeshirow"]
            break
        default:
            god_list = []
            break
    ban_list = []
    moderator_list = ["{}".format(hostPlayer)]

    extended_color_data = [
        Color.WHITE,
        Color.LIGHT_GRAY,
        Color.GRAY,
        Color.BLACK,
        Color.LIGHT_RED,
        Color.RED,
        Color.ORANGE,
        Color.YELLOW,
        Color.GREEN,
        Color.LIME_GREEN,
        Color.AQUA,
        Color.TURQUOISE,
        Color.SKY_BLUE,
        Color.BLUE,
        Color.LIGHT_VIOLET,
        Color.VIOLET,
        Color.LIGHT_PURPLE,
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

    preferences_data[Preference.GAME] = [
        "game preferences",
        "Customize various game settings.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.GREEN
    ]
    preferences_data[Preference.HERO] = [
        "hero preferences",
        "Modify hero attributes.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.YELLOW
    ]
    preferences_data[Preference.ABILITIES] = [
        "ability preferences",
        "Configure ability and ultimate mechanics.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.PURPLE
    ]
    preferences_data[Preference.EFFECTS] = [
        "effects preferences",
        "Adjust various visual effects.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.VIOLET
    ]
    preferences_data[Preference.SPECIAL] = [
        "special preferences",
        "Control special game features.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.TURQUOISE
    ]
    preferences_data[Preference.BASE] = [
        "base preferences",
        "Customize base appearance and behavior.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.ROSE
    ]
    preferences_data[Preference.DREAM] = [
        "dream preferences",
        "Adjust dream mode settings.",
        PreferenceType.CATEGORY,
        null,
        ExtendedColor.AQUA
    ]
    # Game
    preferences_data[Preference.PLAYER_MODE] = [
        "player mode",
        [
            "No special features, kill or be killed.",
            "Enable chill features. Be as harmless or lethal as you want.",
            "Enable invulnerability, disable most abilities."
        ],
        PreferenceType.MULTIPLE_CHOICE,
        [
            "{} kill".format(iconString(Icon.SKULL)),
            "{} chill".format(abilityIconString(Hero.MEI, Button.ULTIMATE)),
            "{} zen".format(abilityIconString(Hero.ZENYATTA, Button.ULTIMATE))
        ],
        [ExtendedColor.RED, ExtendedColor.SKY_BLUE, ExtendedColor.GREEN]
    ]
    preferences_data[Preference.THIRD_PERSON] = [
        "third-person camera",
        "Select a third-person camera perspective.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["off", "rear", "top-down", "static top-down"],
        null,
        true
    ]
    preferences_data[Preference.THIRD_PERSON_DISTANCE] = [
        "third-person camera distance",
        "Specify the distance of the camera in third-person view.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"]
    ]
    preferences_data[Preference.THIRD_PERSON_OFFSET] = [
        "third-person offset",
        "Specify the horizontal offset of the camera in third-person view.",
        PreferenceType.NUMERIC_REVERSIBLE,
        [-5, 5, 0.5, "m"]
    ]
    preferences_data[Preference.THIRD_PERSON_SMOOTHING] = [
        "third-person smoothing",
        "Third-person camera smoothing is forcibly enabled in this server." if optimize else "Enable third-person camera smoothing, sacrificing accuracy.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.SWITCH_HERO] = [
        "Switch hero",
        "Switch heroes (in case of bugs in the Overwatch hero picker).",
        PreferenceType.INTERACT_MULTIPLE_CHOICE_RANDOM,
        [0.6, [f"{heroIcon(hero)} {hero}" for hero in getAllHeroes()]]
    ]
    preferences_data[Preference.SHOW_HOTKEYS] = [
        "show hotkeys",
        "Enable the display of gameplay hotkeys.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.STASIS] = [
        "stasis",
        "Temporarily immobilize yourself.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    preferences_data[Preference.STASIS_MODE] = [
        "stasis mode",
        "Select the status effect to apply during stasis.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["knock down", "stun", "sleep", "freeze"],
        null,
        true
    ]
    preferences_data[Preference.FAST_TRAVEL] = [
        "fast travel",
        "Enable teleportation between bases and key locations.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    preferences_data[Preference.FAST_TRAVEL_TO_OBJECTIVE] = [
        "fast travel to objective",
        "Quickly jump to objectives.",
        PreferenceType.INTERACT_MULTIPLE_CHOICE,
        [0.6, ["first", "second", "third"]],
        null,
        true
    ]
    preferences_data[Preference.INSTANT_RESPAWN] = [
        "instant respawn",
        "Initiate immediate respawn at the base after death.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.REMOVE_BASE_REMOTELY] = [
        "remove base remotely",
        "Enable remote removal of your base.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.SWITCH_TEAM] = [
        "switch team",
        "Switch teams in skirmish maps.",
        PreferenceType.INTERACT,
        1
    ]
    preferences_data[Preference.RESET] = [
        "reset",
        "Reset all your settings.",
        PreferenceType.INTERACT,
        1
    ]
    # Hero
    preferences_data[Preference.OUTLINE_COLOR] = [
        "outline color",
        "Select an outline color.",
        PreferenceType.COLOR_PICKER,
        true
    ]
    preferences_data[Preference.FLIGHT] = [
        "flight",
        "Enable or disable flight capability.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    preferences_data[Preference.FLIGHT_ACCELERATION] = [
        "flight acceleration",
        "Set the acceleration for flight.",
        PreferenceType.NUMERIC,
        [5, 100, 5],
        null,
        true
    ]
    preferences_data[Preference.SIZE] = [
        "size",
        "Adjust the size of the hero.",
        PreferenceType.NUMERIC,
        [10, 500, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.GRAVITY] = [
        "gravity",
        "Set the gravity on the hero.",
        PreferenceType.NUMERIC,
        [0, 500, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.SPEED] = [
        "speed",
        "Define the movement speed of the hero.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.JUMP_SPEED] = [
        "jump speed",
        "Adjust the jump speed of the hero.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.VOICE_PITCH] = [
        "voice pitch",
        "Adjust the pitch of the hero's voice.",
        PreferenceType.NUMERIC,
        [50, 150, 10, "%"]
    ]
    # Abilities
    preferences_data[Preference.DAMAGE] = [
        "damage",
        "Set the damage output percentage.",
        PreferenceType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        true
    ]
    preferences_data[Preference.DAMAGE_EFFECT] = [
        "damage effect",
        "Select the effect applied upon dealing damage.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        true
    ]
    preferences_data[Preference.HEALING] = [
        "healing",
        "Set the healing output percentage.",
        PreferenceType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        true
    ]
    preferences_data[Preference.HEALING_EFFECT] = [
        "healing effect",
        "Select the effect applied during healing.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        true
    ]
    preferences_data[Preference.HEALTH] = [
        "health",
        "Set the health pool percentage.",
        PreferenceType.NUMERIC,
        [10, 5000, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.THORNS] = [
        "thorns",
        "Set the damage reflection percentage.",
        PreferenceType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        true
    ]
    preferences_data[Preference.THORNS_EFFECT] = [
        "thorns effect",
        "Select the effect applied when reflecting damage.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        true
    ]
    preferences_data[Preference.ABILITY_MODE] = [
        "ability mode",
        [
            "Standard ability cooldowns.",
            "Reduced ability cooldowns.",
            "Hold for repeated use."
        ],
        PreferenceType.MULTIPLE_CHOICE,
        ["normal", "no cooldown"] if optimize else ["normal", "no cooldown", "hold to spam"],
        null,
        true
    ]
    preferences_data[Preference.ABILITY_SPAM_DELAY] = [
        "ability spam delay",
        "Ability spam is disabled on this server." if optimize else "Set the delay between successive ability activations.",
        PreferenceType.NUMERIC,
        [0.01, 1, 0.01, " second(s)"],
        ExtendedColor.GRAY if optimize else ExtendedColor.WHITE,
        true
    ]
    preferences_data[Preference.ULTIMATE_MODE] = [
        "ultimate mode",
        [
            "Standard ultimate cooldowns.",
            "Reduced ultimate cooldowns.",
            "Instant ultimate recasts.",
            "Hold for repeated use."
        ],
        PreferenceType.MULTIPLE_CHOICE,
        ["normal", "no cooldown", "infinite"] if optimize else ["normal", "no cooldown", "infinite", "hold to spam"],
        null,
        true
    ]
    preferences_data[Preference.ULTIMATE_SPAM_DELAY] = [
        "ultimate spam delay",
        "Ultimate spam is disabled on this server." if optimize else "Set the delay between successive ultimate activations.",
        PreferenceType.NUMERIC,
        [0.01, 1, 0.01, " second(s)"],
        ExtendedColor.GRAY if optimize else ExtendedColor.WHITE,
        true
    ]
    preferences_data[Preference.KNOCKBACK] = [
        "knockback",
        "Adjust the force of the knockback effect.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.PROJECTILE_SPEED] = [
        "projectile speed",
        "Specify the speed of projectiles.",
        PreferenceType.NUMERIC,
        [0, 1000, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.PROJECTILE_GRAVITY] = [
        "projectile gravity",
        "Set the gravitational effect on projectiles.",
        PreferenceType.NUMERIC,
        [0, 1000, 10, "%"],
        null,
        true
    ]
    preferences_data[Preference.AMMO_OVERLOAD] = [
        "ammo overload",
        "Enable unlimited ammo and increased ammo clips.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    # Effects
    preferences_data[Preference.CUSTOM_MESSAGE] = [
        "custom message",
        "Enter a personal message to be displayed above the player.",
        PreferenceType.KEYBOARD
    ]
    preferences_data[Preference.CUSTOM_MESSAGE_COLOR] = [
        "custom message color",
        "Select a color for the displayed message.",
        PreferenceType.COLOR_PICKER,
        true
    ]
    preferences_data[Preference.AURA] = [
        "aura",
        "Enable or disable a surrounding glowing effect.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    preferences_data[Preference.AURA_EFFECT] = [
        "aura effect",
        "Select the shape of the aura effect.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["sparkles", "cloud", "light shaft", "good aura", "bad aura", "ring", "sphere"],
        null,
        true
    ]
    preferences_data[Preference.AURA_COLOR] = [
        "aura color",
        "Select a color for the aura effect.",
        PreferenceType.COLOR_PICKER,
        true,
        null,
        true
    ]
    preferences_data[Preference.AURA_SIZE] = [
        "aura size",
        "Specify the size of the aura effect.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "m"],
        null,
        true
    ]
    preferences_data[Preference.HIDE_AURA_IN_FIRST_PERSON] = [
        "hide aura in first-person",
        "Disable the aura effect when in first-person view.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    # Special
    preferences_data[Preference.NOCLIP] = [
        "noclip",
        "Enable or disable the ability to move through walls.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    preferences_data[Preference.INVISIBILITY] = [
        "invisibility",
        "Enable or disable the invisibility state of the hero.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    preferences_data[Preference.ALLOW_MOUNTING] = [
        "allow mounting",
        "Enable or disable mounting.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.MOUNTING_MODE] = [
        "mounting mode",
        "Select the preferred arrangement for mounting.",
        PreferenceType.MULTIPLE_CHOICE_RANDOM,
        ["stack", "intersect", "front", "back", "left", "right"]
    ]
    preferences_data[Preference.TRAMPOLINE] = [
        "trampoline mode",
        "Enable automatic jump upon landing. Hold crouch to stop.",
        PreferenceType.BOOLEAN,
        null,
        null,
        true
    ]
    # Base
    preferences_data[Preference.BASE_MODE] = [
        "base mode",
        [
            "Provides protection for the player, disregarding other players.",
            "Provides protection for the player, disappearing from sight.",
            "Provides protection and serves as a fast travel point for all players.",
            "Provides protection for the player, actively repelling other players.",
            "Provides protection for the player, actively damaging other players."
        ],
        PreferenceType.MULTIPLE_CHOICE,
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
    preferences_data[Preference.BASE_COLOR] = [
        "base color",
        "Select a color for the base.",
        PreferenceType.COLOR_PICKER,
        true
    ]
    preferences_data[Preference.BASE_SIZE] = [
        "base size",
        "Specify the size of the base.",
        PreferenceType.NUMERIC,
        [1, 15, 0.5, "m"]
    ]
    preferences_data[Preference.BASE_GAP_SIZE] = [
        "base gap size",
        "Define the minimum distance between bases.",
        PreferenceType.NUMERIC,
        [0, 8, 0.5, "m"]
    ]
    preferences_data[Preference.BASE_LOCK] = [
        "base lock",
        "Enable or disable base locking for security.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.BASE_NOCLIP] = [
        "in-base noclip",
        "Enable or disable noclip within the base.",
        PreferenceType.BOOLEAN
    ]
    preferences_data[Preference.BASE_GRAVITY] = [
        "in-base gravity",
        "Specify the gravity setting within the base.",
        PreferenceType.NUMERIC,
        [0, 500, 10, "%"]
    ]
    preferences_data[Preference.BASE_SPEED] = [
        "in-base speed",
        "Specify the movement speed within the base.",
        PreferenceType.NUMERIC,
        [10, 500, 10, "%"]
    ]
    preferences_data[Preference.BASE_JUMP_SPEED] = [
        "in-base jump speed",
        "Specify the jump speed within the base.",
        PreferenceType.NUMERIC,
        [10, 500, 10, "%"]
    ]
    # Dream
    preferences_data[Preference.DREAM_MODE] = [
        "enable dream mode",
        "Activate dream mode to allow spectator view.",
        PreferenceType.INTERACT_BOOLEAN,
        0.6
    ]
    preferences_data[Preference.AFK_TIMER] = [
        "AFK timer",
        "Set the idle time (in minutes) after which dream mode is activated.",
        PreferenceType.NUMERIC,
        [0, 60, 0.5, " minute(s)"]
    ]
    preferences_data[Preference.SWITCH_TIMER] = [
        "player switch timer",
        "Define the duration for switching players in dream mode.",
        PreferenceType.NUMERIC,
        [3, 180, 1, " seconds"]
    ]
    preferences_data[Preference.CLIP_CAMERA] = [
        "clip camera",
        "Enable or disable camera collision in dream mode.",
        PreferenceType.BOOLEAN
    ]

    preferences_category_data = [
        [-1, Preference.GAME, Preference.DREAM, ExtendedColor.ORANGE],
        [Preference.GAME, Preference.PLAYER_MODE, Preference.RESET, ExtendedColor.GREEN],
        [Preference.HERO, Preference.OUTLINE_COLOR, Preference.VOICE_PITCH, ExtendedColor.YELLOW],
        [Preference.ABILITIES, Preference.DAMAGE, Preference.AMMO_OVERLOAD, ExtendedColor.PURPLE],
        [Preference.EFFECTS, Preference.CUSTOM_MESSAGE, Preference.HIDE_AURA_IN_FIRST_PERSON, ExtendedColor.VIOLET],
        [Preference.SPECIAL, Preference.NOCLIP, Preference.TRAMPOLINE, ExtendedColor.TURQUOISE],
        [Preference.BASE, Preference.BASE_MODE, Preference.BASE_JUMP_SPEED, ExtendedColor.ROSE],
        [Preference.DREAM, Preference.DREAM_MODE, Preference.CLIP_CAMERA, ExtendedColor.AQUA],
    ]

    quick_preferences_data = [
        Preference.PLAYER_MODE,
        Preference.BASE_MODE,
        Preference.THIRD_PERSON,
        Preference.SWITCH_HERO,
        Preference.FAST_TRAVEL_TO_OBJECTIVE,
        Preference.CUSTOM_MESSAGE,
        Preference.AURA,
        Preference.SIZE,
        Preference.SPEED,
        Preference.DAMAGE,
        Preference.HEALTH,
        Preference.THORNS,
        Preference.NOCLIP,
        Preference.INVISIBILITY,
        Preference.TRAMPOLINE,
        Preference.BASE_COLOR,
        Preference.BASE_SIZE,
        Preference.DREAM_MODE,
    ]

    # Game
    preferences_default[Preference.PLAYER_MODE] = PlayerMode.CHILL
    preferences_default[Preference.THIRD_PERSON] = ThirdPersonCamera.OFF
    preferences_default[Preference.THIRD_PERSON_DISTANCE] = 100
    preferences_default[Preference.THIRD_PERSON_OFFSET] = 1
    preferences_default[Preference.THIRD_PERSON_SMOOTHING] = true
    preferences_default[Preference.SHOW_HOTKEYS] = true
    preferences_default[Preference.STASIS] = true
    preferences_default[Preference.STASIS_MODE] = Stasis.KNOCKED_DOWN
    preferences_default[Preference.FAST_TRAVEL] = true
    preferences_default[Preference.INSTANT_RESPAWN] = true
    preferences_default[Preference.REMOVE_BASE_REMOTELY] = true
    # Hero
    preferences_default[Preference.OUTLINE_COLOR] = ExtendedColor.WHITE
    preferences_default[Preference.FLIGHT] = true
    preferences_default[Preference.FLIGHT_ACCELERATION] = 25
    preferences_default[Preference.SIZE] = 100
    preferences_default[Preference.GRAVITY] = 100
    preferences_default[Preference.SPEED] = 100
    preferences_default[Preference.JUMP_SPEED] = 100
    preferences_default[Preference.VOICE_PITCH] = 100
    # Abilities
    preferences_default[Preference.DAMAGE] = 100
    preferences_default[Preference.DAMAGE_EFFECT] = AbilityEffect.NONE
    preferences_default[Preference.HEALING] = 100
    preferences_default[Preference.HEALING_EFFECT] = AbilityEffect.NONE
    preferences_default[Preference.HEALTH] = 100
    preferences_default[Preference.THORNS] = 100
    preferences_default[Preference.THORNS_EFFECT] = AbilityEffect.NONE
    preferences_default[Preference.ABILITY_MODE] = AbilityMode.NO_COOLDOWN
    preferences_default[Preference.ABILITY_SPAM_DELAY] = 0.01
    preferences_default[Preference.ULTIMATE_MODE] = UltimateMode.NO_COOLDOWN
    preferences_default[Preference.ULTIMATE_SPAM_DELAY] = 0.01
    preferences_default[Preference.KNOCKBACK] = 100
    preferences_default[Preference.PROJECTILE_SPEED] = 100
    preferences_default[Preference.PROJECTILE_GRAVITY] = 100
    preferences_default[Preference.AMMO_OVERLOAD] = true
    # Effects
    preferences_default[Preference.CUSTOM_MESSAGE] = ""
    preferences_default[Preference.CUSTOM_MESSAGE_COLOR] = ExtendedColor.WHITE
    preferences_default[Preference.AURA] = true
    preferences_default[Preference.AURA_EFFECT] = ChillEffect.SPARKLES
    preferences_default[Preference.AURA_COLOR] = ExtendedColor.WHITE
    preferences_default[Preference.AURA_SIZE] = 150
    preferences_default[Preference.HIDE_AURA_IN_FIRST_PERSON] = false
    # Special
    preferences_default[Preference.NOCLIP] = false
    preferences_default[Preference.INVISIBILITY] = false
    preferences_default[Preference.ALLOW_MOUNTING] = true
    preferences_default[Preference.MOUNTING_MODE] = MountingMode.STACK
    preferences_default[Preference.TRAMPOLINE] = false
    # Base
    preferences_default[Preference.BASE_MODE] = BaseMode.PASSIVE
    preferences_default[Preference.BASE_COLOR] = ExtendedColor.ORANGE
    preferences_default[Preference.BASE_SIZE] = 3.5
    preferences_default[Preference.BASE_GAP_SIZE] = 0
    preferences_default[Preference.BASE_LOCK] = false
    preferences_default[Preference.BASE_NOCLIP] = false
    preferences_default[Preference.BASE_GRAVITY] = 100
    preferences_default[Preference.BASE_SPEED] = 100
    preferences_default[Preference.BASE_JUMP_SPEED] = 100
    # Dream
    preferences_default[Preference.DREAM_MODE] = false
    preferences_default[Preference.AFK_TIMER] = 0
    preferences_default[Preference.SWITCH_TIMER] = 10
    preferences_default[Preference.CLIP_CAMERA] = true

    isInitialized = true

    moderator_list_hud = ""

    rainbow_red = 0
    rainbow_green = 0
    rainbow_blue = 255
    
    orb_radius = 0.4


rule "— Initialize game":
    @Condition isGameInProgress()
    @Condition isInitialized

    setMatchTime(createWorkshopSetting(int[30:270], "match preferences", "match time", 270, 0) * 60)
    disableGamemodeCompletion()
    if not createWorkshopSetting(bool, "match preferences", "enable match timer", false, 1):
        pauseMatchTime()
    if not createWorkshopSetting(bool, "game preferences", "enable inspector (increases server load)", false, 3):
        disableInspector()


rule "— Initialize player":
    @Event eachPlayer
    @Condition isInitialized

    eventPlayer.disableGamemodeHud()
    if not createWorkshopSetting(bool, "match preferences", "enable scoreboard", true, 2):
        eventPlayer.disableScoreboard()
    if eventPlayer.preferences:
        HardReset()
    if "{}".format(eventPlayer) in moderator_list:
        async(UpdateModeratorListHUD, AsyncBehavior.RESTART)
    if player_names_backups.index("{}".format(eventPlayer)) >= 0:
        if base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))] and not isOverlappingBase(
            base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))],
            preferences_backups[player_names_backups.index("{}".format(eventPlayer))][Preference.BASE_SIZE],
            preferences_backups[player_names_backups.index("{}".format(eventPlayer))][Preference.BASE_GAP_SIZE]
        ):
            eventPlayer.base_vector = base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))]
            eventPlayer.has_created_base_once = true
            CreateBase()
        eventPlayer.preferences = preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
    else:
        LoadDefaultPreferences()

        # loadouts
        switch "{}".format(eventPlayer):
            case "shifterest":
                eventPlayer.has_created_base_once = true
                eventPlayer.preferences[Preference.PLAYER_MODE] = PlayerMode.CHILL
                eventPlayer.preferences[Preference.BASE_MODE] = BaseMode.FRIENDLY
                eventPlayer.preferences[Preference.FLIGHT] = true
                eventPlayer.preferences[Preference.SPEED] = 200
                eventPlayer.preferences[Preference.JUMP_SPEED] = 150
                eventPlayer.preferences[Preference.KNOCKBACK] = 100
                eventPlayer.preferences[Preference.PROJECTILE_GRAVITY] = 100
                eventPlayer.preferences[Preference.PROJECTILE_SPEED] = 1000
                eventPlayer.preferences[Preference.DAMAGE] = 0
                eventPlayer.preferences[Preference.HEALTH] = 1000
                eventPlayer.preferences[Preference.DAMAGE_EFFECT] = AbilityEffect.SLEEP
                eventPlayer.preferences[Preference.THORNS_EFFECT] = AbilityEffect.SLEEP
                eventPlayer.preferences[Preference.CUSTOM_MESSAGE] = "hey there!"
                eventPlayer.preferences[Preference.CUSTOM_MESSAGE_COLOR] = ExtendedColor.RAINBOW
                eventPlayer.preferences[Preference.AURA_EFFECT] = ChillEffect.SPARKLES
                eventPlayer.preferences[Preference.AURA_COLOR] = ExtendedColor.RAINBOW
                eventPlayer.preferences[Preference.BASE_SPEED] = 200
                eventPlayer.preferences[Preference.BASE_JUMP_SPEED] = 500
                eventPlayer.preferences[Preference.AFK_TIMER] = 1
                break
            case "QueenWolf":
                eventPlayer.has_created_base_once = true
                eventPlayer.preferences[Preference.CUSTOM_MESSAGE] = "♡ R O Y A L T Y ♡"
                eventPlayer.preferences[Preference.PLAYER_MODE] = PlayerMode.CHILL
                eventPlayer.preferences[Preference.OUTLINE_COLOR] = ExtendedColor.RAINBOW
                eventPlayer.preferences[Preference.CUSTOM_MESSAGE_COLOR] = random.choice([ExtendedColor.ROSE, ExtendedColor.RAINBOW])
                eventPlayer.preferences[Preference.AURA_COLOR] = random.choice([ExtendedColor.ROSE, ExtendedColor.RAINBOW])
                break
            case "DJBASTION":
            case "Bastion":
                eventPlayer.setAllowedHeroes(Hero.BASTION)
                break
    InitializePlayer()
    chase(eventPlayer.death_throttle, 0, rate=0.5, ChaseReeval.NONE)

    wait(0.25)

    if player_names_backups.index("{}".format(eventPlayer)) < 0:
        bigMessage(eventPlayer, "welcome to chill / kill bases!")

        wait(4)

        bigMessage(eventPlayer, "to get started, hold {} to create a base.".format(buttonToString(Button.INTERACT)))
        switch mode:
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

    if createWorkshopSetting(bool, "match preferences", "enable play of the game", false, 3):
        wait(10)

    restartMatch()


def LoadDefaultPreferences():
    @Name "— Load default preferences"

    eventPlayer.preferences = preferences_default

    if createWorkshopSetting(bool, "game preferences", "randomize hero outline color", true, 4):
        eventPlayer.preferences[Preference.OUTLINE_COLOR] = random.randint(ExtendedColor.YELLOW, ExtendedColor.BLACK)
    if createWorkshopSetting(bool, "game preferences", "randomize base color", true, 5):
        eventPlayer.preferences[Preference.BASE_COLOR] = random.randint(ExtendedColor.YELLOW, ExtendedColor.BLACK)
    if createWorkshopSetting(bool, "game preferences", "randomize chill mode effect color", true, 6):
        eventPlayer.preferences[Preference.AURA_COLOR] = random.randint(ExtendedColor.YELLOW, ExtendedColor.BLACK)


def HardReset():
    @Name "— Hard reset"

    eventPlayer.progress_hud = null
    eventPlayer.in_world_hud = null
    eventPlayer.preferences_hud = null
    eventPlayer.onscreen_hud = null
    eventPlayer.name_to_ban = null
    eventPlayer.base_vector = null
    eventPlayer.has_created_base_once = null
    eventPlayer.activate_base_immediately = null
    eventPlayer.base_preferences_changed = null
    eventPlayer.last_known_base_owner = null
    eventPlayer.last_known_base_mode = null
    eventPlayer.previous_base_size = null
    eventPlayer.previous_base_gap_size = null
    eventPlayer.current_base_owner = null
    eventPlayer.active_base_owner = null
    eventPlayer.base_to_fast_travel_owner = null
    eventPlayer.preferences_index = null
    eventPlayer.preferences = null
    eventPlayer.isViewingAdvancedPreferences = null
    eventPlayer.isViewingPreferences = null
    eventPlayer.isAdjustingPreference = null
    eventPlayer.isInModeratorMode = null
    eventPlayer.isInBaseCreationMode = null
    eventPlayer.isUsingKeyboard = null
    eventPlayer.isInModeratorStasis = null
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
    eventPlayer.previous_position = null
    eventPlayer.previous_position_direction = null
    eventPlayer.keyboard_input_character = null
    eventPlayer.previous_facing_direction = null
    eventPlayer.last_hero = null