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
    iconMessage(hostPlayer, iconString(Icon.WARNING), "slowing down to avoid server crash")
    setSlowMotion(20)

    wait(1)
    waitUntil(getServerLoad() < 175, 99999)

    isOverloaded = false
    setSlowMotion(100)


rule "— Populate global variables":
    mode = createWorkshopSetting(enum["default", "music", "sleep", "shifterest"], "game preferences", "lobby mode", 0, 0)
    optimize = createWorkshopSetting(bool, "game preferences", "optimize server load", false, 2)

    switch mode:
        case Mode.SHIFTEREST:
            god_list = ["shifterest", "Cage", "aerhysu", "IAmNoOb", "Bastion", "Quiver", "Forgive", "Zeshirow"]
            ban_list = []
        default:
            god_list = []
            ban_list = []
            break
    moderator_list = ["{}".format(hostPlayer)]

    colors_data = [
        Color.WHITE,
        Color.YELLOW,
        Color.GREEN,
        Color.PURPLE,
        Color.RED,
        Color.BLUE,
        Color.AQUA,
        Color.ORANGE,
        Color.SKY_BLUE,
        Color.TURQUOISE,
        Color.LIME_GREEN,
        Color.GRAY,
        Color.VIOLET,
        Color.ROSE,
        Color.BLACK,
        "rainbow"
    ]

    main_preferences_data[Main.PLAYER_MODE] = [
        "player mode",
        [
            "No special features, kill or be killed.",
            "Enable chill features and protection, but no damage.",
            "Enable unbound features. Be as harmless or lethal as you want.",
            "Enable invulnerability, disable most abilities."
        ],
        PreferenceType.MULTIPLE_CHOICE,
        [
            "{} kill".format(iconString(Icon.SKULL)),
            "{} chill".format(abilityIconString(Hero.MEI, Button.ULTIMATE)),
            "{} unbound".format(abilityIconString(Hero.HAZARD, Button.ABILITY_2)),
            "{} zen".format(abilityIconString(Hero.ZENYATTA, Button.ULTIMATE))
        ],
        [Colors.RED, Colors.SKY_BLUE, Colors.PURPLE, Colors.GREEN]
    ]

    main_preferences_data[Main.BASE_MODE] = [
        "base mode",
        [
            "Provides protection exclusively for the player, disregarding other players.",
            "Provides protection to other players and serves as a fast travel point for all players.",
            "Provides protection exclusively for the player while actively repelling other players."
        ],
        PreferenceType.MULTIPLE_CHOICE,
        [
            "{} passive".format(abilityIconString(Hero.SOLDIER, Button.ABILITY_1)),
            "{} friendly".format(abilityIconString(Hero.ZARYA, Button.ABILITY_1)),
            "{} exclusive".format(iconString(Icon.NO))
        ],
        [Colors.WHITE, Colors.BLUE, Colors.ORANGE]
    ]
    main_preferences_data[Main.GAME] = [
        "game preferences",
        "Customize various gameplay settings.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.GREEN
    ]
    main_preferences_data[Main.EFFECTS] = [
        "effects preferences",
        "Adjust various visual effect settings.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.VIOLET
    ]
    main_preferences_data[Main.HERO] = [
        "hero preferences",
        "Modify hero attributes and mechanics.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.YELLOW
    ]
    main_preferences_data[Main.UNBOUND] = [
        "unbound preferences",
        "Configure features exclusive to unbound mode.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.PURPLE,
        ChillUnbound.UNBOUND
    ]
    main_preferences_data[Main.SPECIAL] = [
        "special preferences",
        "Control special gameplay features.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.TURQUOISE
    ]
    main_preferences_data[Main.BASE] = [
        "base preferences",
        "Customize base appearance and functionality.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.ROSE
    ]
    main_preferences_data[Main.DREAM] = [
        "dream preferences",
        "Adjust the dream mode settings.",
        PreferenceType.SUB_PREFERENCE,
        null,
        Colors.AQUA
    ]

    game_preferences_data[Game.THIRD_PERSON] = [
        "third-person camera",
        "Enable a third-person camera perspective.",
        PreferenceType.BOOLEAN
    ]
    game_preferences_data[Game.THIRD_PERSON_DISTANCE] = [
        "third-person camera distance",
        "Specify the distance of the camera in third-person view.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"]
    ]
    game_preferences_data[Game.SHOW_HOTKEYS] = [
        "show hotkeys",
        "Enable the display of gameplay hotkeys.",
        PreferenceType.BOOLEAN
    ]
    game_preferences_data[Game.SELF_PARALYSIS] = [
        "self-paralysis",
        "Temporarily immobilize yourself.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    game_preferences_data[Game.PARALYSIS_MODE] = [
        "paralysis mode",
        "Select the status effect to apply during paralysis.",
        PreferenceType.MULTIPLE_CHOICE,
        ["knock down", "stun", "sleep", "freeze"],
        null,
        ChillUnbound.CHILL
    ]
    game_preferences_data[Game.FAST_TRAVEL] = [
        "fast travel",
        "Enable teleportation between bases and key locations.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    game_preferences_data[Game.FAST_TRAVEL_TO_OBJECTIVE] = [
        "fast travel to objective",
        "Quickly jump to objectives.",
        PreferenceType.INTERACT_MULTIPLE_CHOICE,
        [1, ["first", "second", "third"]],
        null,
        ChillUnbound.CHILL
    ]
    game_preferences_data[Game.REMOTE_PACK_BASE] = [
        "remote pack base",
        "Enable remote removal of your base.",
        PreferenceType.BOOLEAN
    ]
    game_preferences_data[Game.INSTANT_RESPAWN] = [
        "instant respawn",
        "Initiate immediate respawn at the base after death.",
        PreferenceType.BOOLEAN
    ]
    game_preferences_data[Game.SWITCH_TEAM] = [
        "switch team",
        "Switch teams in skirmish maps.",
        PreferenceType.INTERACT,
        1
    ]
    game_preferences_data[Game.RESET] = [
        "reset",
        "Reset all your settings.",
        PreferenceType.INTERACT,
        1
    ]

    effects_preferences_data[Effects.CUSTOM_MESSAGE] = [
        "custom message",
        "Enter a personal message to be displayed above the player.",
        PreferenceType.KEYBOARD
    ]
    effects_preferences_data[Effects.CUSTOM_MESSAGE_COLOR] = [
        "custom message color",
        "Select a color for the displayed message.",
        PreferenceType.COLOR_PICKER,
        true
    ]
    effects_preferences_data[Effects.AURA] = [
        "aura",
        "Enable or disable a surrounding glowing effect.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    effects_preferences_data[Effects.AURA_EFFECT] = [
        "aura effect",
        "Select the shape of the aura effect.",
        PreferenceType.MULTIPLE_CHOICE,
        ["sparkles", "cloud", "light shaft", "good aura", "bad aura", "ring", "sphere"],
        null,
        ChillUnbound.CHILL
    ]
    effects_preferences_data[Effects.AURA_COLOR] = [
        "aura color",
        "Select a color for the aura effect.",
        PreferenceType.COLOR_PICKER,
        true,
        null,
        ChillUnbound.CHILL
    ]
    effects_preferences_data[Effects.AURA_SIZE] = [
        "aura size",
        "Specify the size of the aura effect.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "m"],
        null,
        ChillUnbound.CHILL
    ]
    effects_preferences_data[Effects.HIDE_AURA_IN_FIRST_PERSON] = [
        "hide aura in first-person",
        "Disable the aura effect when in first-person view.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]

    unbound_preferences_data[Unbound.DAMAGE] = [
        "damage",
        "Set the damage output value.",
        PreferenceType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        ChillUnbound.UNBOUND
    ]
    unbound_preferences_data[Unbound.THORNS] = [
        "thorns",
        "Set the damage reflection value.",
        PreferenceType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        ChillUnbound.UNBOUND
    ]
    unbound_preferences_data[Unbound.HEALING] = [
        "healing",
        "Set the healing output value.",
        PreferenceType.NUMERIC,
        [0, 5000, 50, "%"],
        null,
        ChillUnbound.UNBOUND
    ]
    unbound_preferences_data[Unbound.HEALTH] = [
        "health",
        "Set the health pool value.",
        PreferenceType.NUMERIC,
        [10, 5000, 10, "%"],
        null,
        ChillUnbound.UNBOUND
    ]
    unbound_preferences_data[Unbound.DAMAGE_EFFECT] = [
        "damage effect",
        "Select the effect applied upon dealing damage.",
        PreferenceType.MULTIPLE_CHOICE,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        ChillUnbound.UNBOUND
    ]
    unbound_preferences_data[Unbound.THORNS_EFFECT] = [
        "thorns effect",
        "Select the effect applied when reflecting damage.",
        PreferenceType.MULTIPLE_CHOICE,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        ChillUnbound.UNBOUND
    ]
    unbound_preferences_data[Unbound.HEALING_EFFECT] = [
        "healing effect",
        "Select the effect applied during healing.",
        PreferenceType.MULTIPLE_CHOICE,
        ["none", "sleep", "burn", "freeze", "hack", "knock down", "stun", "repel", "attract"],
        null,
        ChillUnbound.UNBOUND
    ]

    hero_preferences_data[Hero.OUTLINE_COLOR] = [
        "outline color",
        "Select an outline color.",
        PreferenceType.COLOR_PICKER,
        true
    ]
    hero_preferences_data[Hero.FLIGHT] = [
        "flight",
        "Enable or disable flight capability.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.FLIGHT_ACCELERATION] = [
        "flight acceleration",
        "Set the acceleration for flight.",
        PreferenceType.NUMERIC,
        [5, 100, 5],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.KNOCKBACK] = [
        "knockback",
        "Adjust the force of the knockback effect.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.SIZE] = [
        "size",
        "Adjust the size attribute of the hero.",
        PreferenceType.NUMERIC,
        [10, 500, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.GRAVITY] = [
        "gravity",
        "Set the gravitational effect on the hero.",
        PreferenceType.NUMERIC,
        [0, 500, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.SPEED] = [
        "speed",
        "Define the movement speed of the hero.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.JUMP_SPEED] = [
        "jump speed",
        "Adjust the jump speed of the hero.",
        PreferenceType.NUMERIC,
        [10, 1000, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.PROJECTILE_SPEED] = [
        "projectile speed",
        "Specify the speed of projectiles.",
        PreferenceType.NUMERIC,
        [0, 1000, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.PROJECTILE_GRAVITY] = [
        "projectile gravity",
        "Set the gravitational effect on projectiles.",
        PreferenceType.NUMERIC,
        [0, 1000, 10, "%"],
        null,
        ChillUnbound.CHILL
    ]
    hero_preferences_data[Hero.VOICE_PITCH] = [
        "voice pitch",
        "Adjust the pitch of the hero's voice.",
        PreferenceType.NUMERIC,
        [50, 150, 10, "%"]
    ]
    
    special_preferences_data[Special.NOCLIP] = [
        "noclip",
        "Enable or disable the ability to move through walls.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.INVISIBILITY] = [
        "invisibility",
        "Enable or disable invisibility.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.AMMO_OVERLOAD] = [
        "ammo overload",
        "Enable unlimited ammo and increased ammo clips.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.TRAMPOLINE] = [
        "trampoline mode",
        "Enable automatic jump upon landing. Hold crouch to stop.",
        PreferenceType.BOOLEAN,
        null,
        null,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.ABILITY_MODE] = [
        "ability mode",
        [
            "Standard ability cooldowns.",
            "Reduced ability cooldowns.",
            "Hold for repeated use."
        ],
        PreferenceType.MULTIPLE_CHOICE,
        ["normal", "no cooldown"] if optimize else ["normal", "no cooldown", "hold to spam"],
        null,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.ABILITY_SPAM_DELAY] = [
        "ability spam delay",
        "Ability spam is disabled on this server." if optimize else "Set the delay between successive ability activations.",
        PreferenceType.NUMERIC,
        [0.01, 1, 0.01, " second(s)"],
        Colors.GRAY if optimize else Colors.WHITE,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.ULTIMATE_MODE] = [
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
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.ULTIMATE_SPAM_DELAY] = [
        "ultimate spam delay",
        "Ultimate spam is disabled on this server." if optimize else "Set the delay between successive ultimate activations.",
        PreferenceType.NUMERIC,
        [0.01, 1, 0.01, " second(s)"],
        Colors.GRAY if optimize else Colors.WHITE,
        ChillUnbound.CHILL
    ]
    special_preferences_data[Special.ALLOW_MOUNTING] = [
        "allow mounting",
        "Enable or disable mounting.",
        PreferenceType.BOOLEAN
    ]
    special_preferences_data[Special.MOUNTING_MODE] = [
        "mounting mode",
        "Select the preferred arrangement for mounting.",
        PreferenceType.MULTIPLE_CHOICE,
        ["stack", "intersect", "front", "back", "left", "right"]
    ]

    base_preferences_data[Base.COLOR] = [
        "base color",
        "Select a color for the base.",
        PreferenceType.COLOR_PICKER,
        true
    ]
    base_preferences_data[Base.SIZE] = [
        "base size",
        "Specify the size of the base.",
        PreferenceType.NUMERIC,
        [1, 15, 0.5, "m"]
    ]
    base_preferences_data[Base.GAP_SIZE] = [
        "base gap size",
        "Define the minimum distance between bases.",
        PreferenceType.NUMERIC,
        [0, 8, 0.5, "m"]
    ]
    base_preferences_data[Base.BASE_LOCK] = [
        "base lock",
        "Enable or disable base locking for security.",
        PreferenceType.BOOLEAN
    ]
    base_preferences_data[Base.NOCLIP] = [
        "in-base noclip",
        "Enable or disable noclip within the base.",
        PreferenceType.BOOLEAN
    ]
    base_preferences_data[Base.GRAVITY] = [
        "in-base gravity",
        "Specify the gravity setting within the base.",
        PreferenceType.NUMERIC,
        [0, 500, 10, "%"]
    ]
    base_preferences_data[Base.SPEED] = [
        "in-base speed",
        "Specify the movement speed within the base.",
        PreferenceType.NUMERIC,
        [10, 500, 10, "%"]
    ]
    base_preferences_data[Base.JUMP_SPEED] = [
        "in-base jump speed",
        "Specify the jump speed within the base.",
        PreferenceType.NUMERIC,
        [10, 500, 10, "%"]
    ]
    
    dream_preferences_data[Dream.DREAM_MODE] = [
        "enable dream mode",
        "Activate dream mode to allow spectator view.",
        PreferenceType.INTERACT_BOOLEAN,
        0.6
    ]
    dream_preferences_data[Dream.AFK_TIMER] = [
        "AFK timer",
        "Set the idle time (in minutes) after which dream mode is activated.",
        PreferenceType.NUMERIC,
        [0, 60, 0.5, " minute(s)"]
    ]
    dream_preferences_data[Dream.SWITCH_TIMER] = [
        "player switch timer",
        "Define the duration for switching players in dream mode.",
        PreferenceType.NUMERIC,
        [3, 180, 1, " seconds"]
    ]
    dream_preferences_data[Dream.CLIP_CAMERA] = [
        "clip camera",
        "Enable or disable camera collision in dream mode.",
        PreferenceType.BOOLEAN
    ]

    main_preferences_default[Main.PLAYER_MODE] = PlayerMode.KILL
    main_preferences_default[Main.BASE_MODE] = BaseMode.PASSIVE

    game_preferences_default[Game.THIRD_PERSON] = false
    game_preferences_default[Game.THIRD_PERSON_DISTANCE] = 100
    game_preferences_default[Game.SHOW_HOTKEYS] = true
    game_preferences_default[Game.SELF_PARALYSIS] = true
    game_preferences_default[Game.PARALYSIS_MODE] = Paralysis.KNOCKED_DOWN
    game_preferences_default[Game.FAST_TRAVEL] = true
    game_preferences_default[Game.REMOTE_PACK_BASE] = true
    game_preferences_default[Game.INSTANT_RESPAWN] = true

    effects_preferences_default[Effects.CUSTOM_MESSAGE] = ""
    effects_preferences_default[Effects.CUSTOM_MESSAGE_COLOR] = Colors.WHITE
    effects_preferences_default[Effects.AURA] = true
    effects_preferences_default[Effects.AURA_EFFECT] = ChillEffect.SPARKLES
    effects_preferences_default[Effects.AURA_COLOR] = Colors.WHITE
    effects_preferences_default[Effects.AURA_SIZE] = 150
    effects_preferences_default[Effects.HIDE_AURA_IN_FIRST_PERSON] = false

    hero_preferences_default[Hero.OUTLINE_COLOR] = Colors.WHITE
    hero_preferences_default[Hero.FLIGHT] = false
    hero_preferences_default[Hero.FLIGHT_ACCELERATION] = 25
    hero_preferences_default[Hero.KNOCKBACK] = 100
    hero_preferences_default[Hero.SIZE] = 100
    hero_preferences_default[Hero.GRAVITY] = 100
    hero_preferences_default[Hero.SPEED] = 100
    hero_preferences_default[Hero.JUMP_SPEED] = 100
    hero_preferences_default[Hero.PROJECTILE_SPEED] = 100
    hero_preferences_default[Hero.PROJECTILE_GRAVITY] = 100
    hero_preferences_default[Hero.VOICE_PITCH] = 100

    unbound_preferences_default[Unbound.DAMAGE] = 100
    unbound_preferences_default[Unbound.THORNS] = 100
    unbound_preferences_default[Unbound.HEALING] = 100
    unbound_preferences_default[Unbound.HEALTH] = 100
    unbound_preferences_default[Unbound.DAMAGE_EFFECT] = UnboundEffect.NONE
    unbound_preferences_default[Unbound.THORNS_EFFECT] = UnboundEffect.NONE
    unbound_preferences_default[Unbound.HEALING_EFFECT] = UnboundEffect.NONE

    special_preferences_default[Special.NOCLIP] = false
    special_preferences_default[Special.INVISIBILITY] = false
    special_preferences_default[Special.TRAMPOLINE] = false
    special_preferences_default[Special.AMMO_OVERLOAD] = true
    special_preferences_default[Special.ABILITY_MODE] = AbilityMode.NO_COOLDOWN
    special_preferences_default[Special.ABILITY_SPAM_DELAY] = 0.01
    special_preferences_default[Special.ULTIMATE_MODE] = UltimateMode.NO_COOLDOWN
    special_preferences_default[Special.ULTIMATE_SPAM_DELAY] = 0.01
    special_preferences_default[Special.ALLOW_MOUNTING] = true
    special_preferences_default[Special.MOUNTING_MODE] = MountingMode.STACK

    base_preferences_default[Base.COLOR] = Colors.ORANGE
    base_preferences_default[Base.SIZE] = 3.5
    base_preferences_default[Base.GAP_SIZE] = 0
    base_preferences_default[Base.BASE_LOCK] = false
    base_preferences_default[Base.GRAVITY] = 100
    base_preferences_default[Base.SPEED] = 100
    base_preferences_default[Base.JUMP_SPEED] = 100

    dream_preferences_default[Dream.DREAM_MODE] = false
    dream_preferences_default[Dream.AFK_TIMER] = 0
    dream_preferences_default[Dream.CLIP_CAMERA] = true
    dream_preferences_default[Dream.SWITCH_TIMER] = 10

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

    eventPlayer.cubic_bezier = 1

    eventPlayer.disableGamemodeHud()
    if not createWorkshopSetting(bool, "match preferences", "enable scoreboard", true, 2):
        eventPlayer.disableScoreboard()
    if eventPlayer.main_preferences:
        HardReset()
    if "{}".format(eventPlayer) in moderator_list:
        async(UpdateModeratorListHUD, AsyncBehavior.RESTART)
    if player_names_backups.index("{}".format(eventPlayer)) >= 0:
        if base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))] and not isOverlappingBase(
            base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))],
            base_preferences_backups[player_names_backups.index("{}".format(eventPlayer))][Base.SIZE],
            base_preferences_backups[player_names_backups.index("{}".format(eventPlayer))][Base.GAP_SIZE]
        ):
            eventPlayer.base_vector = base_vectors_backups[player_names_backups.index("{}".format(eventPlayer))]
            eventPlayer.has_created_base_once = true
            CreateBaseEffects()
        eventPlayer.main_preferences = main_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.game_preferences = game_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.effects_preferences = effects_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.hero_preferences = hero_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.unbound_preferences = unbound_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.special_preferences = special_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.base_preferences = base_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
        eventPlayer.dream_preferences = dream_preferences_backups[player_names_backups.index("{}".format(eventPlayer))]
    else:
        LoadDefaultPreferences()

        # loadouts
        switch "{}".format(eventPlayer):
            case "shifterest":
                eventPlayer.has_created_base_once = true
                eventPlayer.main_preferences[Main.PLAYER_MODE] = PlayerMode.UNBOUND
                eventPlayer.main_preferences[Main.BASE_MODE] = BaseMode.FRIENDLY
                eventPlayer.hero_preferences[Hero.FLIGHT] = true
                eventPlayer.hero_preferences[Hero.SPEED] = 200
                eventPlayer.hero_preferences[Hero.JUMP_SPEED] = 150
                eventPlayer.hero_preferences[Hero.KNOCKBACK] = 100
                eventPlayer.hero_preferences[Hero.PROJECTILE_GRAVITY] = 100
                eventPlayer.hero_preferences[Hero.PROJECTILE_SPEED] = 1000
                eventPlayer.unbound_preferences[Unbound.DAMAGE] = 0
                eventPlayer.unbound_preferences[Unbound.HEALTH] = 1000
                eventPlayer.unbound_preferences[Unbound.DAMAGE_EFFECT] = UnboundEffect.SLEEP
                eventPlayer.unbound_preferences[Unbound.THORNS_EFFECT] = UnboundEffect.SLEEP
                eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE] = "hey there!"
                eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE_COLOR] = Colors.RAINBOW
                eventPlayer.effects_preferences[Effects.AURA_EFFECT] = ChillEffect.SPARKLES
                eventPlayer.effects_preferences[Effects.AURA_COLOR] = Colors.RAINBOW
                eventPlayer.base_preferences[Base.SPEED] = 200
                eventPlayer.base_preferences[Base.JUMP_SPEED] = 500
                eventPlayer.dream_preferences[Dream.AFK_TIMER] = 1
                break
            case "QueenWolf":
                eventPlayer.has_created_base_once = true
                eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE] = "♡ R O Y A L T Y ♡"
                eventPlayer.main_preferences[Main.PLAYER_MODE] = PlayerMode.CHILL
                eventPlayer.hero_preferences[Hero.OUTLINE_COLOR] = Colors.RAINBOW
                eventPlayer.effects_preferences[Effects.CUSTOM_MESSAGE_COLOR] = random.choice([Colors.ROSE, Colors.RAINBOW])
                eventPlayer.effects_preferences[Effects.AURA_COLOR] = random.choice([Colors.ROSE, Colors.RAINBOW])
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

        bigMessage(eventPlayer, "to get started, hold {} to create a base.".format(buttonString(Button.INTERACT)))
        switch mode:
            case Mode.MUSIC:
            case Mode.SLEEP:
                wait(4)

                bigMessage(eventPlayer, "then, join match voice chat for some music!".format(buttonString(Button.INTERACT)))
                break
    else:
        bigMessage(eventPlayer, "welcome back!")


rule "— End game":
    @Condition getMatchTime() <= 0

    wait(0.25, Wait.ABORT_WHEN_FALSE)
    declarePlayerVictory(null)

    if createWorkshopSetting(bool, "match preferences", "enable play of the game", false, 3):
        wait(10)

    restartMatch()


def LoadDefaultPreferences():
    @Name "— Load default preferences"

    eventPlayer.main_preferences = main_preferences_default
    eventPlayer.game_preferences = game_preferences_default
    eventPlayer.effects_preferences = effects_preferences_default
    eventPlayer.hero_preferences = hero_preferences_default
    eventPlayer.unbound_preferences = unbound_preferences_default
    eventPlayer.special_preferences = special_preferences_default
    eventPlayer.base_preferences = base_preferences_default
    eventPlayer.dream_preferences = dream_preferences_default

    if createWorkshopSetting(bool, "game preferences", "randomize hero outline color", true, 4):
        eventPlayer.hero_preferences[Hero.OUTLINE_COLOR] = random.randint(Colors.YELLOW, Colors.BLACK)
    if createWorkshopSetting(bool, "game preferences", "randomize base color", true, 5):
        eventPlayer.base_preferences[Base.COLOR] = random.randint(Colors.YELLOW, Colors.BLACK)
    if createWorkshopSetting(bool, "game preferences", "randomize chill mode effect color", true, 6):
        eventPlayer.effects_preferences[Effects.AURA_COLOR] = random.randint(Colors.YELLOW, Colors.BLACK)


def HardReset():
    @Name "— Hard reset"

    eventPlayer.progress_hud = null
    eventPlayer.in_world_hud = null
    eventPlayer.preferences_hud = null
    eventPlayer.onscreen_hud = null

    eventPlayer.name_to_ban = null

    eventPlayer.base_vector = null
    eventPlayer.has_created_base_once = null
    eventPlayer.settle_immediately = null
    eventPlayer.base_preferences_changed = null
    eventPlayer.previous_base_within_radius = null
    eventPlayer.previous_base_mode = null
    eventPlayer.previous_base_size = null
    eventPlayer.previous_base_gap_size = null

    eventPlayer.base_within_owner = null
    eventPlayer.base_settled_owner = null
    eventPlayer.base_to_fast_travel_owner = null

    eventPlayer.preferences_index = null
    eventPlayer.main_preferences = null
    eventPlayer.game_preferences = null
    eventPlayer.effects_preferences = null
    eventPlayer.hero_preferences = null
    eventPlayer.unbound_preferences = null
    eventPlayer.special_preferences = null
    eventPlayer.base_preferences = null
    eventPlayer.dream_preferences = null
    eventPlayer.isInSubPreference = null
    eventPlayer.isViewingPreferences = null
    eventPlayer.isAdjustingPreference = null

    eventPlayer.isInModeratorMode = null
    eventPlayer.isInBaseCreationMode = null
    eventPlayer.isUsingKeyboard = null

    eventPlayer.isParalyzedByModerator = null
    eventPlayer.isParalyzed = null
    eventPlayer.isInvisible = null

    eventPlayer.death_throttle = null
    eventPlayer.progress = null
    eventPlayer.base_progress = null
    eventPlayer.interaction_progress = null
    eventPlayer.afk_timer = null

    eventPlayer.mount = null
    eventPlayer.rider = null

    eventPlayer.chill_effect_id = null
    eventPlayer.sphere_effect_id = null
    eventPlayer.icon_effect_id = null
    eventPlayer.description_effect_id = null
    eventPlayer.message_effect_id = null

    eventPlayer.focused_player = null
    eventPlayer.previous_position = null
    eventPlayer.previous_position_direction = null
    eventPlayer.keyboard_input_character = null
    eventPlayer.previous_facing_direction = null
    eventPlayer.last_hero = null