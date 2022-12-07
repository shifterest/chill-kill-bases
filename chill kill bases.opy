settings {
    "main": {
        "description": "<FGA5F2F3FF>chill<FGFFFFFFFF> / <FGFF6961FF>kill<FGFFFFFFFF> bases (by shifterest) • <FGFDFD96FF>TSX53<FGFFFFFFFF>\r\n<FGC1E1C1FF>» [v2.11.1] last updated: 12/6/2022<FGFFFFFFFF>\r\n\r\na chill or kill gamemode designed with AFKing in mind.\r\n\r\nbased on:\r\n» Chill Zone Base Creator by AlaskaWolf • <FGFDFD96FF>ARYD2<FGFFFFFFFF>\r\n» Base Wars by Zezombye • <FGFDFD96FF>14WON<FGFFFFFFFF>",
        "modeName": "<FGA5F2F3FF>chill <FGFF6961FF>kill <FGFFFFFFFF>bases"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "team1Slots": 6,
        "team2Slots": 6,
        "spectatorSlots": 12,
        "returnToLobby": "never"
    },
    "gamemodes": {
        "ffa": {
            "disabledMaps": [
                "workshopChamber",
                "workshopGreenScreen",
                "workshopIsland",
            ]
        },
        "skirmish": {
            "disabledMaps": [
                "workshopExpanse",
                "workshopChamber",
                "workshopGreenScreen",
                "workshopIsland",
            ]
        },
        "general": {
            "gamemodeStartTrigger": "immediately",
            "heroLimit": "off",
            "respawnTime%": 50,
            "spawnHealthPacks": "enabled"
        }
    }
}


/* GLOBAL VARIABLES */
# lists
globalvar modList
globalvar banList
globalvar playerNameList
globalvar baseVectorList
globalvar prefsList
# data
globalvar COLORS
globalvar KEY_DATA
globalvar PREFS_DATA
globalvar BASE_MODE_ICONS
# constants
globalvar CENTER_ORB_RADIUS
globalvar RAINBOW_DURATION
# initialization
globalvar defaultPrefs
globalvar playerInit
# chased
globalvar angle
globalvar red
globalvar green
globalvar blue

/* PLAYER VARIABLES */
playervar modVars
playervar baseVars
playervar prefsVars
playervar modeVars
playervar statusVars
playervar miscVars
# core
playervar prefs
playervar baseVector
# HUD
playervar progressHUD
playervar inWorldHUD
playervar prefsHUD
playervar onScreenHUD
# chased
playervar progress
playervar baseProgress
playervar interactProgress
playervar afkTimer


/* SUBROUTINE NAMES */
subroutine UpdateHUD
subroutine UpdatePrefsHUD
subroutine UpdateHero
subroutine UpdateAbilities
subroutine UpdateAFKTimer
subroutine DisableAbilities
subroutine EnableAbilities
subroutine ThirdPersonCam
subroutine ThirdPersonSpecCam
subroutine SpectatorCam
subroutine ResetCam
subroutine SpectatorMode
subroutine Confine
subroutine SettleInOwn
subroutine SettleInFriendly
subroutine Repel
subroutine SettleInArena
subroutine PrefsInteract
subroutine BackupPlayer
subroutine HardReset


/* MACROS */
# constants
#!define keyboardVect(n) localPlayer.getEyePosition() + vect(sinDeg(horizontalAngleOfDirection(localPlayer.miscVars[miscVarsI.lastPosDir][1])), n, cosDeg(horizontalAngleOfDirection(localPlayer.miscVars[miscVarsI.lastPosDir][1])))
#!define prefsVect(n) localPlayer.baseVector + (vect([], n, []) * distance(localPlayer.baseVector, raycast(localPlayer.getEyePosition(), localPlayer.getEyePosition() + (Vector.UP * (localPlayer.prefs[prefsI.heroSize] / 100) + localPlayer.getFacingDirection() * (localPlayer.prefs[prefsI.heroSize] / -20) if localPlayer.prefs[prefsI.playerMode] else Vector.UP + localPlayer.getFacingDirection() * -5), null, localPlayer, false).getHitPosition() if localPlayer.prefs[prefsI.thirdPersonMode] else localPlayer.getEyePosition()) / 2.5)
#!define rainbowColor() rgb(red, green, blue)
#!define colorsEnum() enum["white", "yellow", "green", "purple", "red", "blue", "aqua", "orange", "sky blue", "turquoise", "lime green", "gray", "violet", "rose", "black", "rainbow"]
#!define colorsEnumNoRainbow() enum["white", "yellow", "green", "purple", "red", "blue", "aqua", "orange", "sky blue", "turquoise", "lime green", "gray", "violet", "rose", "black"]
#!define friendlyBaseInCrosshair() [player for player in getAllPlayers().exclude(eventPlayer).exclude(eventPlayer.baseVars[baseVarsI.baseInRadiusOf]) if player.baseVector and player.prefs[prefsI.baseMode] == 1 and distance(eventPlayer.getEyePosition() + distance(eventPlayer.getEyePosition(), player.baseVector) * eventPlayer.getFacingDirection(), player.baseVector) <= player.prefs[prefsI.baseSize]][0]
# conditions
#!define isCurrOrDupHero(hero) eventPlayer.getCurrentHero() == hero or eventPlayer.getHeroOfDuplication() == hero
#!define isInDiffBase() [player for player in getAllPlayers() if player.baseVector and eventPlayer in getPlayersInRadius(player.baseVector, player.prefs[prefsI.baseSize], Team.ALL, LosCheck.OFF)][0] != eventPlayer.baseVars[baseVarsI.baseInRadiusOf]
#!define isConfined() eventPlayer.baseVars[baseVarsI.baseSettledIn] and eventPlayer.baseVars[baseVarsI.baseSettledIn].baseVector and (not eventPlayer.prefs[prefsI.playerMode] and eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] == baseModesI.arena) or (eventPlayer.baseVector and eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer and eventPlayer.prefs[prefsI.baseLock])
#!define isActive() eventPlayer.getThrottle() != vect(0, 0, 0) or eventPlayer.getFacingDirection() != eventPlayer.miscVars[miscVarsI.facingDirPrev] or eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) or eventPlayer.isHoldingButton(Button.ABILITY_1) or eventPlayer.isHoldingButton(Button.ABILITY_2) or eventPlayer.isHoldingButton(Button.RELOAD) or eventPlayer.isHoldingButton(Button.CROUCH) or eventPlayer.isHoldingButton(Button.JUMP) or eventPlayer.isHoldingButton(Button.MELEE)
# functions
#!define ChaseColor(c, d) chase(c, d, duration = RAINBOW_DURATION, ChaseReeval.NONE)\
wait(RAINBOW_DURATION)\
stopChasingVariable(c)
#!define StopMomentum() eventPlayer.applyImpulse(-eventPlayer.getVelocity(), 0.00001, Relativity.TO_PLAYER, Impulse.CANCEL_CONTRARY_MOTION_XYZ)
#!define UpdateHeroOutline() eventPlayer.startForcingOutlineFor(getAllPlayers(), true, COLORS[eventPlayer.prefs[prefsI.heroOutlineColor]], OutlineVisibility.DEFAULT)
#!define UpdateVoicelinePitch() eventPlayer.startModifyingVoicelinePitch(eventPlayer.prefs[prefsI.voicePitch] / 100, false)
# effects
#!define ExplodeBase() playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION, rainbowColor() if eventPlayer.prefs[prefsI.baseColor] == colorsI.rainbow else COLORS[eventPlayer.prefs[prefsI.baseColor]], eventPlayer.baseVector, eventPlayer.prefs[prefsI.baseSize] * 2)
#!define DebuffPlayerOnFocus() playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.miscVars[miscVarsI.playerInFocus].getPosition(), 100)
#!define BuffFocus() playEffect([eventPlayer, eventPlayer.miscVars[miscVarsI.playerInFocus]], DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer.miscVars[miscVarsI.playerInFocus].getPosition(), 100)
#!define DebuffFocus() playEffect([eventPlayer, eventPlayer.miscVars[miscVarsI.playerInFocus]], DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.miscVars[miscVarsI.playerInFocus].getPosition(), 100)
#!define BuffPlayer() playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, null, eventPlayer.getPosition(), 100)
#!define DebuffPlayer() playEffect(eventPlayer, DynamicEffect.DEBUFF_IMPACT_SOUND, null, eventPlayer.getPosition(), 100)


enum modVarsI:
    nameToBan


enum baseVarsI:
    baseInRadiusOf,
    baseToFastTravelTo,
    baseSettledIn,
    settleImmediately,
    lastPosFastTravel,
    baseInRadiusOfPrev,
    baseModePrev,
    baseSizePrev,
    basePaddingPrev,
    basePrefsPrev


enum prefsVarsI:
    prefsPage,
    isViewingPrefs,
    isAdjustingPrefs,


enum modeVarsI:
    modMode,
    createMode,
    keyboardMode


enum statusVarsI:
    isAsleepMod,
    isAsleep,
    isInvisible


enum miscVarsI:
    lastPosDir,
    playerInFocus,
    keyboardChar,
    facingDirPrev


enum prefsI:
    playerMode,
    resetPrefs,
    switchTeam,
    fastTravel,
    thirdPersonMode,
    customMessage,
    customMessageColor,
    instantRespawn,
    selfSleep,
    spectatorMode,
    spectateOnAFK,
    smoothSpectatorCam,
    clipSpectatorCam,
    spectatorCamDist,
    spectatorSwitchTimer,
    heroOutlineColor,
    flight,
    flightAccel,
    invisibility,
    noEnvCollision,
    noCooldowns,
    fastReload,
    fastUlt,
    infiniteUlt,
    heroSize,
    gravity,
    knockback,
    movementSpeed,
    projectileSpeed,
    projectileGravity,
    voicePitch,
    baseMode,
    baseColor,
    baseLock,
    baseSize,
    basePadding,
    inBaseGravity,
    inBaseMovementSpeed


enum progressHUDI:
    text,
    color


enum inWorldHUDI:
    baseModeIcon,
    baseDescription


enum prefsHUDI:
    category,
    categoryColor,
    preference,
    color,
    counter,
    description


enum onScreenHUDI:
    mainInfo,
    settleInfo


enum colorsI:
    white,
    yellow,
    green,
    purple,
    red,
    blue,
    aqua,
    orange,
    skyBlue,
    turquoise,
    limeGreen,
    gray,
    violet,
    rose,
    black,
    rainbow


enum playerModesI:
    kill,
    chill,
    zen


enum baseModesI:
    passive,
    friendly,
    exclusive,
    arena


enum prefsDataI:
    title,
    descriptions,
    type,
    parameters,
    colors,
    chillZenOnly


enum prefsTypeI:
    multipleChoice,
    boolean,
    numeric, # [min, max, step, suffix]
    interact,
    interactHold, # duration
    interactHoldBoolean, # duration
    customMessage, # duration
    colorPicker, # includes rainbow


rule "setup":
    @Delimiter
    @Disabled


rule " • assemble heroes quickly":
    @Condition isAssemblingHeroes()

    setMatchTime(0)


rule " • server crash mitigation":
    @Condition getServerLoad() >= 175

    wait(0.5, Wait.ABORT_WHEN_FALSE)
    setSlowMotion(20)

    waitUntil(getServerLoad() < 175, 99999)
    setSlowMotion(100)


rule " • global initialization":
    @Condition isGameInProgress()

    disableGamemodeCompletion()
    disableScoring()

    if createWorkshopSetting(
        bool,
        "match preferences",
        "disable workshop inspector (reduces server load)",
        false,
        4
    ):
        disableInspector()

    setMatchTime(
        createWorkshopSetting(int[30:270], "match preferences", "match time", 270, 0) * 60
    )

    if createWorkshopSetting(bool, "match preferences", "disable match timer", true, 1):
        pauseMatchTime()

    startDamageModification(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] == baseModesI.arena
        ],
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] != baseModesI.arena
        ],
        0,
        DamageReeval.RECEIVERS_AND_DAMAGERS
    )

    startDamageModification(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] != baseModesI.arena
        ],
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] == baseModesI.arena
        ],
        0,
        DamageReeval.RECEIVERS_AND_DAMAGERS
    )

    startHealingModification(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] == baseModesI.arena
        ],
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] != baseModesI.arena
        ],
        0,
        HealingReeval.RECEIVERS_AND_HEALERS
    )

    startHealingModification(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] != baseModesI.arena
        ],
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] == baseModesI.arena
        ],
        0,
        HealingReeval.RECEIVERS_AND_HEALERS
    )


rule " • global variables":
    @Condition isGameInProgress()

    COLORS = [
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

    PREFS_DATA = [
        [
            "player mode",
            [
                "you are vulnerable to damage",
                "you are resilient to damage and knockback",
                "you are phased but can't use abilities"
            ],
            prefsTypeI.multipleChoice,
            [
                "{} kill".format(iconString(Icon.SKULL)),
                "{} chill".format(abilityIconString(Hero.MEI, Button.ULTIMATE)),
                "{} zen".format(abilityIconString(Hero.ZENYATTA, Button.ULTIMATE))
            ],
            [colorsI.red, colorsI.skyBlue, colorsI.green]
        ],
        [
            "reset preferences",
            "reset your preferences to defaults",
            prefsTypeI.interactHold,
            1
        ],
        [
            "switch team",
            "switch to the opposite team on skirmish maps",
            prefsTypeI.interactHold,
            1
        ],
        ["fast travel", "lets you teleport to, from, or between bases", prefsTypeI.boolean],
        ["third-person mode", "toggles the third-person camera", prefsTypeI.boolean],
        [
            "custom message",
            "type a custom message that floats above your head",
            prefsTypeI.customMessage,
            0.6
        ],
        [
            "custom message color",
            "changes the color of your custom message",
            prefsTypeI.colorPicker,
            true
        ],
        [
            "instant respawn",
            "instantly respawns you in your base upon death",
            prefsTypeI.boolean
        ],
        [
            "self-sleep",
            "lets you sleep yourself",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "spectator mode",
            "gain zen mode effects and spectate players randomly",
            prefsTypeI.interactHoldBoolean,
            0.6
        ],
        [
            "auto-spectate on AFK",
            "automatically enables spectator mode after being inactive for the minutes you set",
            prefsTypeI.numeric,
            [0, 30, 0.5, " minute(s)"]
        ],
        [
            "smooth spectator camera",
            "smoothly transitions between players in spectator mode",
            prefsTypeI.boolean,
        ],
        [
            "clip spectator camera",
            "sets camera collision for spectator mode",
            prefsTypeI.boolean,
        ],
        [
            "spectator camera distance",
            "the distance of the spectator camera from spectated players",
            prefsTypeI.numeric,
            [1, 15, 1],
        ],
        [
            "spectator switch timer",
            "the time in seconds it takes to switch to a different player in spectator mode",
            prefsTypeI.numeric,
            [3, 180, 1, " seconds"],
        ],
        [
            "hero outline color",
            "changes the color of your hero outline",
            prefsTypeI.colorPicker
        ],
        ["flight", "lets you fly", prefsTypeI.boolean, null, null, true],
        [
            "flight acceleration",
            "the upwards acceleration for flying",
            prefsTypeI.numeric,
            [5, 50, 5],
            null,
            true
        ],
        [
            "invisibility",
            "makes you (and your custom message) invisible",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "no environment collision",
            "lets you walk through walls and fall through floors",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "no cooldowns",
            "disables ability cooldowns and enables ability spam for certain heroes",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "fast reload",
            "reloads your weapon instantly",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "fast ultimate",
            "reduces ultimate cooldown time",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "infinite ultimate",
            "recasts certain ultimates as soon as they finish",
            prefsTypeI.boolean,
            null,
            null,
            true
        ],
        [
            "hero size",
            "the scale of your hero. 100+ forcibly will disable environment collision",
            prefsTypeI.numeric,
            [10, 500, 10, "%"],
            null,
            true
        ],
        [
            "gravity",
            "your gravity outside bases",
            prefsTypeI.numeric,
            [10, 500, 10, "%"],
            null,
            true
        ],
        [
            "knockback",
            "your knockback dealt to other players. 100+ will disable knockback resilience",
            prefsTypeI.numeric,
            [10, 500, 10, "%"],
            null,
            true
        ],
        [
            "movement speed",
            "your movement speed outside a base",
            prefsTypeI.numeric,
            [10, 500, 10, "%"],
            null,
            true
        ],
        [
            "projectile speed",
            "your projectile speed",
            prefsTypeI.numeric,
            [0, 500, 10, "%"],
            null,
            true
        ],
        [
            "projectile gravity",
            "your projectile gravity",
            prefsTypeI.numeric,
            [0, 500, 10, "%"],
            null,
            true
        ],
        [
            "voice pitch",
            "the pitch of your hero's voice",
            prefsTypeI.numeric,
            [50, 150, 10, "%"]
        ],
        [
            "base mode",
            [
                "your base has no effect to players",
                "your base protects players. players can fast travel to your base",
                "your base repels visitors",
                "your base traps players, forcing them to kill mode until death",
            ],
            prefsTypeI.multipleChoice,
            [
                "{} passive".format(abilityIconString(Hero.SOLDIER, Button.ABILITY_1)),
                "{} friendly".format(abilityIconString(Hero.ZARYA, Button.ABILITY_1)),
                "{} exclusive".format(iconString(Icon.NO)),
                "{} arena".format(abilityIconString(Hero.MCCREE, Button.ULTIMATE))
            ],
            [colorsI.white, colorsI.blue, colorsI.orange, colorsI.red]
        ],
        [
            "base color",
            "changes the color of your base (due to limitations, rainbow isn't smooth)",
            prefsTypeI.colorPicker,
            true
        ],
        ["base lock", "prevents you from leaving your base", prefsTypeI.boolean],
        ["base size", "the radius of your base", prefsTypeI.numeric, [1, 15, 0.5]],
        [
            "base padding",
            "the minimum distance of your base to another's",
            prefsTypeI.numeric,
            [0, 5, 0.5]
        ],
        [
            "in-base gravity",
            "the gravity in your base",
            prefsTypeI.numeric,
            [0, 500, 10, "%"]
        ],
        [
            "in-base movement speed",
            "the speed of players in your base",
            prefsTypeI.numeric,
            [10, 500, 10, "%"]
        ]
    ]

    # character, horizontal angle, vertical angle, half-width
    KEY_DATA = [
        ["~", 26.3, -3],
        ["!", 23.3, -3],
        ["@", 19.8, -3],
        ["#", 17.1, -3],
        ["$", 16, -3],
        ["%", 9.1, -3],
        ["^", 5.5, -3],
        ["&", 2.1, -3],
        ["*", -1.1, -3],
        ["(", -4, -3],
        [")", -6.7, -3],
        ["_", -9.8, -3],
        ["+", -13, -3],
        ["back", -21.4, -3, 5.5],
        ["`", 25.2, 0.5],
        ["1", 22.5, 0.5],
        ["2", 19.3, 0.5],
        ["3", 15.9, 0.5],
        ["4", 12.6, 0.5],
        ["5", 9.2, 0.5],
        ["6", 5.8, 0.5],
        ["7", 2.4, 0.5],
        ["8", -1, 0.5],
        ["9", -4.3, 0.5],
        ["0", -7.7, 0.5],
        ["-", -10.9, 0.5],
        ["=", -14, 0.5],
        ["{", -17.2, 0.5],
        ["[", -20.1, 0.5],
        ["|", -23, 0.5],
        ["q", 20.9, 5.8],
        ["w", 17, 5.8],
        ["e", 13.5, 5.8],
        ["r", 10, 5.8],
        ["t", 6.7, 5.8],
        ["y", 3.4, 5.8],
        ["u", 0, 5.8],
        ["i", -3.2, 5.8],
        ["o", -6.3, 5.8],
        ["p", -9.8, 5.8],
        ["}", -15.1, 5.8],
        ["]", -18.1, 5.8],
        ["\\", -21.1, 5.8],
        ["a", 19.1, 9.1],
        ["s", 15.7, 9.1],
        ["d", 12.3, 9.1],
        ["f", 9, 9.1],
        ["g", 5.4, 9.1],
        ["h", 2, 9.1],
        ["j", -1.3, 9.1],
        ["k", -4.6, 9.1],
        ["l", -8, 9.1],
        [":", -11, 9.1],
        [";", -13.6, 9.1],
        ['"', -16.5, 9.1],
        ["'", -19.4, 9.1],
        ["z", 17.3, 12.7],
        ["x", 13.9, 12.7],
        ["c", 10.6, 12.7],
        ["v", 7.1, 12.7],
        ["b", 3.7, 12.7],
        ["n", 0.2, 12.7],
        ["m", -3.4, 12.7],
        ["<", -7, 12.7],
        [">", -10.2, 12.7],
        [",", -13, 12.7],
        [".", -15.8, 12.7],
        ["?", -18.7, 12.7],
        ["/", -21.9, 12.7],
        [" ", 4.6, 18, 3],
        ["exit", -5.9, 18, 2.5],
    ]

    BASE_MODE_ICONS = [
        abilityIconString(Hero.SOLDIER, Button.ABILITY_1),
        abilityIconString(Hero.ZARYA, Button.ABILITY_1),
        iconString(Icon.NO),
        abilityIconString(Hero.MCCREE, Button.ULTIMATE)
    ]

    RAINBOW_DURATION = createWorkshopSetting(
        float[0.1:5], "game preferences", "rainbow color duration", 1, 0
    )

    CENTER_ORB_RADIUS = 0.4

    # rainbow stuff
    red = 0
    green = 0
    blue = 255
    chase(angle, -10000, rate = 7, ChaseReeval.NONE)

    banList = []
    modList = []

    defaultPrefs[prefsI.playerMode] = createWorkshopSetting(
        enum["kill", "chill", "zen"],
        "default game preferences",
        "player mode",
        0,
        prefsI.playerMode
    )
    defaultPrefs[prefsI.fastTravel] = createWorkshopSetting(
        bool, "default game preferences", "fast travel", true, prefsI.fastTravel
    )
    defaultPrefs[prefsI.thirdPersonMode] = createWorkshopSetting(
        bool,
        "default game preferences",
        "third-person mode",
        false,
        prefsI.thirdPersonMode
    )
    defaultPrefs[prefsI.customMessage] = ""
    defaultPrefs[prefsI.customMessageColor] = createWorkshopSetting(
        colorsEnum(),
        "default game preferences",
        "custom message color",
        0,
        prefsI.customMessageColor
    )
    defaultPrefs[prefsI.instantRespawn] = createWorkshopSetting(
        bool, "default game preferences", "instant respawn", true, prefsI.instantRespawn
    )
    defaultPrefs[prefsI.spectatorMode] = false
    defaultPrefs[prefsI.spectateOnAFK] = createWorkshopSetting(
        float[0:30],
        "default spectator preferences",
        "auto-spectate on AFK",
        0,
        prefsI.spectateOnAFK
    )
    defaultPrefs[prefsI.smoothSpectatorCam] = createWorkshopSetting(
        bool,
        "default spectator preferences",
        "smooth spectator camera",
        true,
        prefsI.smoothSpectatorCam
    )
    defaultPrefs[prefsI.clipSpectatorCam] = createWorkshopSetting(
        bool,
        "default spectator preferences",
        "clip spectator camera",
        true,
        prefsI.clipSpectatorCam
    )
    defaultPrefs[prefsI.spectatorCamDist] = createWorkshopSetting(
        int[1:15],
        "default spectator preferences",
        "spectator camera distance",
        4,
        prefsI.spectatorCamDist
    )
    defaultPrefs[prefsI.spectatorSwitchTimer] = createWorkshopSetting(
        int[3:180],
        "default spectator preferences",
        "spectator switch timer",
        10,
        prefsI.spectatorSwitchTimer
    )
    defaultPrefs[prefsI.selfSleep] = createWorkshopSetting(
        bool, "default spectator preferences", "self-sleep", true, prefsI.selfSleep
    )
    defaultPrefs[prefsI.heroOutlineColor] = createWorkshopSetting(
        colorsEnumNoRainbow(),
        "default special hero preferences",
        "hero outline color",
        0,
        prefsI.heroOutlineColor
    )
    defaultPrefs[prefsI.flight] = createWorkshopSetting(
        bool, "default special hero preferences", "flight", false, prefsI.flight
    )
    defaultPrefs[prefsI.flightAccel] = createWorkshopSetting(
        int[5:50],
        "default special hero preferences",
        "flight acceleration",
        25,
        prefsI.flightAccel
    )
    defaultPrefs[prefsI.invisibility] = createWorkshopSetting(
        bool, "default special hero preferences", "invisibility", false, prefsI.invisibility
    )
    defaultPrefs[prefsI.noEnvCollision] = createWorkshopSetting(
        bool,
        "default special hero preferences",
        "no environment collision",
        false,
        prefsI.noEnvCollision
    )
    defaultPrefs[prefsI.noCooldowns] = createWorkshopSetting(
        bool, "default special hero preferences", "no cooldowns", true, prefsI.noCooldowns
    )
    defaultPrefs[prefsI.fastReload] = createWorkshopSetting(
        bool, "default special hero preferences", "fast reload", true, prefsI.fastReload
    )
    defaultPrefs[prefsI.fastUlt] = createWorkshopSetting(
        bool, "default special hero preferences", "fast ultimate", true, prefsI.fastUlt
    )
    defaultPrefs[prefsI.infiniteUlt] = createWorkshopSetting(
        bool, "default special hero preferences", "infinite ultimate", false, prefsI.infiniteUlt
    )
    defaultPrefs[prefsI.heroSize] = createWorkshopSetting(
        int[10:500], "default other hero preferences", "hero size", 100, prefsI.heroSize
    )
    defaultPrefs[prefsI.gravity] = createWorkshopSetting(
        int[10:500], "default other hero preferences", "gravity", 100, prefsI.gravity
    )
    defaultPrefs[prefsI.knockback] = createWorkshopSetting(
        int[10:500], "default other hero preferences", "knockback", 100, prefsI.knockback
    )
    defaultPrefs[prefsI.movementSpeed] = createWorkshopSetting(
        int[10:500],
        "default other hero preferences",
        "movement speed",
        100,
        prefsI.movementSpeed
    )
    defaultPrefs[prefsI.projectileSpeed] = createWorkshopSetting(
        int[0:500],
        "default other hero preferences",
        "projectile speed",
        100,
        prefsI.projectileSpeed
    )
    defaultPrefs[prefsI.projectileGravity] = createWorkshopSetting(
        int[0:500],
        "default other hero preferences",
        "projectile gravity",
        100,
        prefsI.projectileGravity
    )
    defaultPrefs[prefsI.voicePitch] = createWorkshopSetting(
        int[50:150],
        "default other hero preferences",
        "voice pitch",
        100,
        prefsI.voicePitch
    )

    defaultPrefs[prefsI.baseMode] = createWorkshopSetting(
        enum["passive", "friendly", "exclusive", "arena"],
        "default base preferences",
        "base mode",
        0,
        prefsI.baseMode
    )
    defaultPrefs[prefsI.baseColor] = createWorkshopSetting(
        colorsEnum(), "default base preferences", "base color", 7, prefsI.baseColor
    )
    defaultPrefs[prefsI.baseLock] = createWorkshopSetting(
        bool, "default base preferences", "base lock", false, prefsI.baseLock
    )
    defaultPrefs[prefsI.baseSize] = createWorkshopSetting(
        float[1:15], "default base preferences", "base radius", 3, prefsI.baseSize
    )
    defaultPrefs[prefsI.basePadding] = createWorkshopSetting(
        float[0:5], "default base preferences", "base padding", 0, prefsI.basePadding
    )
    defaultPrefs[prefsI.inBaseGravity] = createWorkshopSetting(
        int[0:500],
        "default base preferences",
        "in-base gravity",
        100,
        prefsI.inBaseGravity
    )
    defaultPrefs[prefsI.inBaseMovementSpeed] = createWorkshopSetting(
        int[10:500],
        "default base preferences",
        "in-base movement speed",
        100,
        prefsI.inBaseMovementSpeed
    )

    playerInit = true


rule " • player initialization":
    @Event eachPlayer

    eventPlayer.disableGamemodeHud()

    if createWorkshopSetting(bool, "match preferences", "disable scoreboard", false, 2):
        eventPlayer.disableScoreboard()

    waitUntil(playerInit, 99999)

    if eventPlayer.prefs:
        HardReset()

    if playerNameList.index("{}".format(eventPlayer)) >= 0:
        if not any(
            [
                player != eventPlayer
                and player.baseVector
                and distance(
                    baseVectorList[playerNameList.index("{}".format(eventPlayer))],
                    player.baseVector
                )
                <= player.prefs[prefsI.baseSize]
                + prefsList[playerNameList.index("{}".format(eventPlayer))].prefs[
                    prefsI.baseSize
                ]
                + max(
                    player.prefs[prefsI.basePadding],
                    prefsList[playerNameList.index("{}".format(eventPlayer))].prefs[
                        prefsI.basePadding
                    ]
                )
                for player in getAllPlayers()
            ]
        ):
            eventPlayer.baseVector = baseVectorList[
                playerNameList.index("{}".format(eventPlayer))
            ]
        eventPlayer.prefs = prefsList[playerNameList.index("{}".format(eventPlayer))]
    else:
        eventPlayer.prefs = defaultPrefs

        if createWorkshopSetting(
            bool,
            "default hero preferences",
            "randomize hero outline color",
            true,
            prefsI.heroOutlineColor
        ):
            eventPlayer.prefs[prefsI.heroOutlineColor] = random.randint(
                colorsI.yellow, colorsI.black
            )

        if createWorkshopSetting(
            bool,
            "default base preferences",
            "randomize base color",
            true,
            prefsI.baseColor
        ):
            eventPlayer.prefs[prefsI.baseColor] = random.randint(
                colorsI.yellow, colorsI.black
            )

    async(UpdateHero, AsyncBehavior.RESTART)
    ResetCam()
    UpdateVoicelinePitch()
    UpdateAFKTimer()

    waitUntil(eventPlayer.hasSpawned(), 99999)

    UpdateHeroOutline()

    wait(0.25)
    if playerNameList.index("{}".format(eventPlayer)) < 0:
        bigMessage(eventPlayer, "welcome to chill / kill bases!")
        wait(3)
        bigMessage(
            eventPlayer,
            "to get started, hold {} to create a base.".format(
                buttonString(Button.INTERACT)
            )
        )
    else:
        bigMessage(eventPlayer, "welcome back!")


rule " • global HUD":
    @Condition isGameInProgress()

    /* LEFT */
    hudSubheader(
        null
        if localPlayer.prefs[prefsI.spectatorMode]
        else localPlayer,
        "lobby up for {} • hosted by {} {}\n".format(
            "{} minute{}".format(
                floor(getTotalTimeElapsed() / 60),
                "" if floor(getTotalTimeElapsed() / 60) == 1 else "s"
            ),
            heroIcon(hostPlayer.getCurrentHero()),
            hostPlayer
        ),
        HudPosition.LEFT,
        0,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.DEFAULT
    )

    /* TOP */
    # server load
    hudSubheader(
        null
        if localPlayer.prefs[prefsI.spectatorMode]
        else modList.concat(hostPlayer),
        "{} current • {} mean • {} peak".format(
            getServerLoad(), getAverageServerLoad(), getPeakServerLoad(), localPlayer.prefs[prefsI.infiniteUlt]
        ),
        HudPosition.TOP,
        0,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    hudSubheader(
        modList.concat(hostPlayer)
        if localPlayer.modeVars[modeVarsI.modMode]
        and not localPlayer.prefs[prefsI.spectatorMode]
        else null,
        "{} entities • {} text • {} dmg mods • {} heal mods".format(
            getNumberOfEntityIds(), getNumberOfTextIds(), getNumberOfDamageModificationIds(), getNumberOfHealingModificationIds()
        ),
        HudPosition.TOP,
        0,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # moderator mode hotkey
    hudSubheader(
        null
        if localPlayer.prefs[prefsI.spectatorMode]
        else modList.concat(hostPlayer),
        "{} + {} • toggle moderator mode".format(
            buttonString(Button.CROUCH), buttonString(Button.RELOAD)
        ),
        HudPosition.TOP,
        1,
        Color.ORANGE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # padding
    hudSubheader(
        modList.concat(hostPlayer),
        " ",
        HudPosition.TOP,
        2,
        Color.WHITE,
        HudReeval.VISIBILITY,
        SpecVisibility.NEVER
    )
    # main info
    hudSubtext(
        null
        if localPlayer.modeVars[modeVarsI.modMode]
        or localPlayer.prefs[prefsI.spectatorMode]
        else localPlayer,
        localPlayer.onScreenHUD[onScreenHUDI.mainInfo],
        HudPosition.TOP,
        3,
        COLORS[
            PREFS_DATA[prefsI.playerMode][prefsDataI.colors][
                localPlayer.prefs[prefsI.playerMode]
            ]
        ],
        HudReeval.VISIBILITY_STRING_AND_COLOR,
        SpecVisibility.NEVER
    )
    # moderator mode
    hudSubtext(
        localPlayer if localPlayer.modeVars[modeVarsI.modMode] else null,
        "{} {}{} • {}".format(
            heroIcon(localPlayer.miscVars[miscVarsI.playerInFocus].getCurrentHero()),
            localPlayer.miscVars[miscVarsI.playerInFocus],
            " (host)"
            if localPlayer.miscVars[miscVarsI.playerInFocus] == hostPlayer
            else " (moderator)"
            if localPlayer.miscVars[miscVarsI.playerInFocus] in modList
            else "",
            PREFS_DATA[prefsI.playerMode][prefsDataI.parameters][
                localPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                    prefsI.playerMode
                ]
            ]
        ),
        HudPosition.TOP,
        3,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # moderator hotkeys
    hudSubheader(
        localPlayer if localPlayer.modeVars[modeVarsI.modMode] else null,
        "{} • switch player\n{} • sleep / wake up\n{} • kill\nhold {} • teleport to player\nhold {} • teleport player to you\nhold {} • ban until server restart\nhold {} • delete base\n{}".format(
            buttonString(Button.JUMP),
            buttonString(Button.PRIMARY_FIRE),
            buttonString(Button.SECONDARY_FIRE),
            buttonString(Button.ULTIMATE),
            buttonString(Button.INTERACT),
            buttonString(Button.MELEE),
            buttonString(Button.ABILITY_1),
            "{} • promote or demote moderator".format(buttonString(Button.ABILITY_2))
            if localPlayer == hostPlayer
            else ""
        ),
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # keyboard hotkeys
    hudSubheader(
        localPlayer
        if localPlayer.modeVars[modeVarsI.keyboardMode]
        else null,
        "hold BACKSPACE • clear",
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # base creation hotkeys
    hudSubheader(
        null
        if localPlayer.baseVector
        or localPlayer.modeVars[modeVarsI.modMode]
        or localPlayer.prefs[prefsI.spectatorMode]
        else localPlayer,
        "{} • create base\n{} • cancel".format(
            buttonString(Button.PRIMARY_FIRE), buttonString(Button.INTERACT)
        )
        if localPlayer.modeVars[modeVarsI.createMode]
        else "hold {} • create base".format(buttonString(Button.INTERACT)),
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # in-base hotkeys
    hudSubheader(
        null
        if localPlayer.baseVars[baseVarsI.baseSettledIn] != localPlayer
        or localPlayer.modeVars[modeVarsI.modMode]
        or localPlayer.modeVars[modeVarsI.keyboardMode]
        or localPlayer.prefs[prefsI.spectatorMode]
        else localPlayer,
        "hold {} • switch hero\nhold {} • pack base".format(
            buttonString(Button.RELOAD), buttonString(Button.INTERACT)
        ),
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # arena hotkeys
    hudSubheader(
        null
        if localPlayer.baseVars[baseVarsI.baseSettledIn] == localPlayer
        or not localPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
        == baseModesI.arena
        or localPlayer.modeVars[modeVarsI.modMode]
        else localPlayer,
        "hold {} • forfeit".format(buttonString(Button.MELEE)),
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # fast travel hotkeys
    hudSubheader(
        null
        if (
            localPlayer.baseVars[baseVarsI.baseSettledIn] != localPlayer
            and localPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
            == baseModesI.arena
        )
        or localPlayer.modeVars[modeVarsI.modMode]
        or localPlayer.modeVars[modeVarsI.keyboardMode]
        or not localPlayer.prefs[prefsI.fastTravel]
        or localPlayer.prefs[prefsI.spectatorMode]
        or (
            not localPlayer.prefs[prefsI.playerMode]
            and not localPlayer.baseVars[baseVarsI.baseSettledIn]
        )
        else localPlayer,
        "hold {} • fast travel to {}friendly base{}".format(
            buttonString(Button.MELEE),
            "your base / "
            if localPlayer.baseVector
            and localPlayer.baseVars[baseVarsI.baseSettledIn] != localPlayer
            and (
                (
                    not localPlayer.prefs[prefsI.playerMode]
                    and localPlayer.baseVars[baseVarsI.baseSettledIn]
                )
                or localPlayer.prefs[prefsI.playerMode]
            )
            else "",
            " / last position"
            if localPlayer.prefs[prefsI.playerMode]
            and localPlayer.baseVars[baseVarsI.lastPosFastTravel]
            else ""
        ),
        HudPosition.TOP,
        4,
        Color.WHITE,
        HudReeval.VISIBILITY_AND_STRING,
        SpecVisibility.NEVER
    )
    # self-sleep hotkey
    hudSubheader(
        null
        if localPlayer.modeVars[modeVarsI.modMode]
        or localPlayer.modeVars[modeVarsI.keyboardMode]
        or not localPlayer.prefs[prefsI.playerMode]
        or localPlayer.prefs[prefsI.spectatorMode]
        or not localPlayer.prefs[prefsI.selfSleep]
        else localPlayer,
        "hold {} + {} • {}".format(
            buttonString(Button.CROUCH), buttonString(Button.MELEE),
            "wake up" if localPlayer.statusVars[statusVarsI.isAsleep] else "sleep"
        ),
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
        5,
        Color.WHITE,
        HudReeval.VISIBILITY,
        SpecVisibility.NEVER
    )
    # commmon progress bar
    progressBarHud(
        localPlayer if localPlayer.progress > 0 and localPlayer.progress < 100 else null,
        localPlayer.progress,
        localPlayer.progressHUD[progressHUDI.text],
        HudPosition.TOP,
        6,
        rainbowColor()
        if localPlayer.progressHUD[progressHUDI.color] == colorsI.rainbow
        else COLORS[localPlayer.progressHUD[progressHUDI.color]],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # base settlement progress bar
    progressBarHud(
        localPlayer
        if localPlayer.baseProgress > 0 and localPlayer.baseProgress < 100
        else null,
        localPlayer.baseProgress,
        localPlayer.onScreenHUD[onScreenHUDI.settleInfo],
        HudPosition.TOP,
        7,
        rainbowColor()
        if localPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseColor]
        == colorsI.rainbow
        else COLORS[
            localPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseColor]
        ],
        Color.WHITE,
        ProgressHudReeval.VISIBILITY_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )

    # * RIGHT
    # game info
    hudSubheader(
        localPlayer,
        "chill / kill bases • workshop.codes/TSX53",
        HudPosition.RIGHT,
        0,
        rainbowColor(),
        HudReeval.VISIBILITY_AND_COLOR,
        SpecVisibility.DEFAULT
    )

    /* IN-WORLD */
    # base indicator
    createIcon(
        localPlayer
        if localPlayer.baseVector
        and not localPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        else null,
        localPlayer.baseVector + Vector.UP / 10,
        Icon.ARROW_DOWN,
        IconReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        true
    )
    # base outline
    createEffect(
        localPlayer if localPlayer.baseVars[baseVarsI.baseSettledIn] else null,
        Effect.RING,
        rainbowColor()
        if localPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseColor]
        == colorsI.rainbow
        else COLORS[
            localPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseColor]
        ],
        localPlayer.baseVars[baseVarsI.baseSettledIn].baseVector,
        localPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseSize],
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # center orb
    createEffect(
        null
        if localPlayer.baseVars[baseVarsI.baseSettledIn] != localPlayer
        or localPlayer.modeVars[modeVarsI.modMode]
        or localPlayer.modeVars[modeVarsI.keyboardMode]
        or localPlayer.prefs[prefsI.spectatorMode]
        else localPlayer,
        Effect.ORB,
        rainbowColor()
        if localPlayer.prefs[prefsI.baseColor] == colorsI.rainbow
        else COLORS[localPlayer.prefs[prefsI.baseColor]],
        localPlayer.baseVector,
        CENTER_ORB_RADIUS,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # keyboard
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "{}{}".format(
            localPlayer.prefs[prefsI.customMessage],
            "|" if getTotalTimeElapsed() % 1 <= 0.5 else " "
        ),
        keyboardVect(0.25),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "~     !     @     #     $     %     ^     &     *     (     )     _     +     backspace",
        keyboardVect(0.1),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "`     1     2     3     4     5     6     7     8     9     0     -     =     {     [     |     ",
        keyboardVect(0),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "q     w     e     r     t     y     u     i     o     p          }     ]     \\",
        keyboardVect(-0.15),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "a     s     d     f     g     h     j     k     l     :     ;     \"     '",
        keyboardVect(-0.25),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "          z     x     c     v     b     n     m     <     >     ,     .     ?     /",
        keyboardVect(-0.35),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "space     •     exit",
        keyboardVect(-0.5),
        2.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # cursor
    createInWorldText(
        localPlayer if localPlayer.modeVars[modeVarsI.keyboardMode] else null,
        "▲",
        updateEveryTick(
            localPlayer.getEyePosition()
            + vect(
                min(
                    43.5,
                    max(
                        -43.5,
                        angleDifference(
                            horizontalAngleOfDirection(
                                localPlayer.miscVars[miscVarsI.lastPosDir][1]
                            ),
                            localPlayer.getHorizontalFacingAngle()
                        )
                    )
                )
                / 35
                * cosDeg(
                    horizontalAngleOfDirection(
                        localPlayer.miscVars[miscVarsI.lastPosDir][1]
                    )
                )
                + sinDeg(
                    horizontalAngleOfDirection(
                        localPlayer.miscVars[miscVarsI.lastPosDir][1]
                    )
                ),
                -min(
                    27,
                    max(
                        -21.7,
                        angleDifference(
                            verticalAngleOfDirection(
                                localPlayer.miscVars[miscVarsI.lastPosDir][1]
                            ),
                            localPlayer.getVerticalFacingAngle()
                        )
                    )
                )
                / 35,
                -min(
                    43.5,
                    max(
                        -43.5,
                        angleDifference(
                            horizontalAngleOfDirection(
                                localPlayer.miscVars[miscVarsI.lastPosDir][1]
                            ),
                            localPlayer.getHorizontalFacingAngle()
                        )
                    )
                )
                / 35
                * sinDeg(
                    horizontalAngleOfDirection(
                        localPlayer.miscVars[miscVarsI.lastPosDir][1]
                    )
                )
                + cosDeg(
                    horizontalAngleOfDirection(
                        localPlayer.miscVars[miscVarsI.lastPosDir][1]
                    )
                )
            )
        ),
        2,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.ORANGE,
        SpecVisibility.NEVER
    )

    # * PREFERENCES
    # preferences category
    createInWorldText(
        localPlayer if localPlayer.prefsVars[prefsVarsI.isViewingPrefs] else null,
        "press {} • jump to {} preferences".format(
            buttonString(Button.MELEE), localPlayer.prefsHUD[prefsHUDI.category]
        ),
        prefsVect(0.9),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        COLORS[localPlayer.prefsHUD[prefsHUDI.categoryColor]],
        SpecVisibility.NEVER
    )
    # preferences title
    createInWorldText(
        localPlayer if localPlayer.prefsVars[prefsVarsI.isViewingPrefs] else null,
        PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.title],
        prefsVect(0.8),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # preferences counter, previous / next preference hotkeys
    createInWorldText(
        localPlayer if localPlayer.prefsVars[prefsVarsI.isViewingPrefs] else null,
        "{} {} • {} of {} • {} {}".format(
            buttonString(Button.PRIMARY_FIRE),
            iconString(Icon.ARROW_LEFT),
            localPlayer.prefsVars[prefsVarsI.prefsPage] + 1,
            len(PREFS_DATA),
            iconString(Icon.ARROW_RIGHT),
            buttonString(Button.SECONDARY_FIRE)
        ),
        prefsVect(0.7),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        COLORS[localPlayer.prefsHUD[prefsHUDI.categoryColor]],
        SpecVisibility.NEVER
    )
    # player preference
    createInWorldText(
        localPlayer if localPlayer.prefsVars[prefsVarsI.isViewingPrefs] else null,
        localPlayer.prefsHUD[prefsHUDI.preference],
        prefsVect(0.5),
        1.5,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbowColor()
        if localPlayer.prefsHUD[prefsHUDI.color] == colorsI.rainbow
        else COLORS[localPlayer.prefsHUD[prefsHUDI.color]],
        SpecVisibility.NEVER
    )
    # preference interaction progress
    createProgressBarInWorldText(
        localPlayer
        if localPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        and localPlayer.interactProgress > 0
        else null,
        localPlayer.interactProgress,
        null,
        prefsVect(0.4),
        0.8,
        Clip.NONE,
        rainbowColor()
        if localPlayer.prefs[prefsI.baseColor] == colorsI.rainbow
        else COLORS[localPlayer.prefs[prefsI.baseColor]],
        null,
        ProgressWorldTextReeval.VISIBILITY_POSITION_VALUES_AND_COLOR,
        SpecVisibility.NEVER
    )
    # player preference counter hotkeys
    createInWorldText(
        localPlayer if localPlayer.prefsVars[prefsVarsI.isViewingPrefs] else null,
        "{} {} {}  |  {} • reset".format(
            buttonString(Button.ABILITY_1),
            localPlayer.prefsHUD[prefsHUDI.counter],
            buttonString(Button.ABILITY_2),
            buttonString(Button.RELOAD)
        )
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.multipleChoice
        or PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.colorPicker
        else "{} • toggle".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.boolean
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
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.numeric
        else "{} • interact".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.interact
        else "hold {} • interact".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.interactHold
        or PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.customMessage
        else "hold {} • enable".format(buttonString(Button.INTERACT))
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
        == prefsTypeI.interactHoldBoolean
        else "",
        prefsVect(0.4),
        0.9,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        COLORS[localPlayer.prefsHUD[prefsHUDI.categoryColor]],
        SpecVisibility.NEVER
    )
    # preference description
    createInWorldText(
        localPlayer if localPlayer.prefsVars[prefsVarsI.isViewingPrefs] else null,
        localPlayer.prefsHUD[prefsHUDI.description],
        prefsVect(0.2),
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.NEVER
    )
    # chill or zen mode required
    createInWorldText(
        localPlayer
        if PREFS_DATA[localPlayer.prefsVars[prefsVarsI.prefsPage]][
            prefsDataI.chillZenOnly
        ]
        and localPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        and not localPlayer.prefs[prefsI.playerMode]
        else null,
        "chill or zen mode required",
        localPlayer.baseVector,
        1,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_AND_POSITION,
        Color.SKY_BLUE,
        SpecVisibility.NEVER
    )


rule " • player HUD":
    @Event eachPlayer

    # chill mode indicator
    createEffect(
        null
        if eventPlayer.statusVars[statusVarsI.isInvisible]
        or not eventPlayer.prefs[prefsI.playerMode]
        or (eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility1())
        else getAllPlayers().exclude(eventPlayer),
        Effect.SPARKLES,
        COLORS[eventPlayer.prefs[prefsI.heroOutlineColor]],
        eventPlayer,
        (eventPlayer.prefs[prefsI.heroSize] / 200) if eventPlayer.prefs[prefsI.playerMode] else 0.5,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # spectator mode indicator
    createEffect(
        null
        if not eventPlayer.prefs[prefsI.spectatorMode]
        or eventPlayer.statusVars[statusVarsI.isInvisible]
        or (eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility1())
        else getAllPlayers().exclude(eventPlayer),
        Effect.CLOUD,
        COLORS[eventPlayer.prefs[prefsI.heroOutlineColor]],
        eventPlayer,
        (eventPlayer.prefs[prefsI.heroSize] / 200) if eventPlayer.prefs[prefsI.playerMode] else 0.5,
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # custom message
    createInWorldText(
        null
        if eventPlayer.statusVars[statusVarsI.isInvisible]
        or (eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility1())
        else getAllPlayers(),
        eventPlayer.prefs[prefsI.customMessage],
        updateEveryTick(eventPlayer.getEyePosition())
        + (
            Vector.UP
            * (
                (eventPlayer.prefs[prefsI.heroSize] / 160)
                if eventPlayer.prefs[prefsI.playerMode]
                else 0.625
            )
        ),
        1.5,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_STRING_AND_COLOR,
        rainbowColor()
        if eventPlayer.prefs[prefsI.customMessageColor] == colorsI.rainbow
        else COLORS[eventPlayer.prefs[prefsI.customMessageColor]],
        SpecVisibility.DEFAULT
    )
    # base sphere
    createEffect(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn] != eventPlayer
        ]
        if eventPlayer.baseVector
        else eventPlayer
        if eventPlayer.modeVars[modeVarsI.createMode]
        else null,
        Effect.SPHERE,
        rainbowColor()
        if eventPlayer.prefs[prefsI.baseColor] == colorsI.rainbow
        else COLORS[eventPlayer.prefs[prefsI.baseColor]],
        eventPlayer.baseVector
        if eventPlayer.baseVector
        else updateEveryTick(eventPlayer.getPosition())
        if eventPlayer.modeVars[modeVarsI.createMode]
        else null,
        eventPlayer.prefs[prefsI.baseSize],
        EffectReeval.VISIBILITY_POSITION_RADIUS_AND_COLOR
    )
    # base mode icon
    createInWorldText(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn] != eventPlayer
            and not player.prefs[prefsI.spectatorMode]
        ]
        if eventPlayer.baseVector
        else null,
        eventPlayer.inWorldHUD[inWorldHUDI.baseModeIcon],
        eventPlayer.baseVector,
        1.7,
        Clip.NONE,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )
    # base description
    createInWorldText(
        [
            player
            for player in getAllPlayers()
            if player.baseVars[baseVarsI.baseSettledIn] != eventPlayer
            and not player.prefs[prefsI.spectatorMode]
        ]
        if eventPlayer.baseVector
        else null,
        "{} {}'s base • {}".format(
            heroIcon(eventPlayer.getCurrentHero()),
            eventPlayer,
            eventPlayer.inWorldHUD[inWorldHUDI.baseDescription]
        ),
        eventPlayer.baseVector + Vector.UP * (eventPlayer.prefs[prefsI.baseSize] + 0.2),
        1,
        Clip.SURFACES,
        WorldTextReeval.VISIBILITY_POSITION_AND_STRING,
        Color.WHITE,
        SpecVisibility.DEFAULT
    )


rule " • end game":
    @Condition getMatchTime() <= 0

    wait(0.25, Wait.ABORT_WHEN_FALSE)
    declarePlayerVictory(null)

    if not createWorkshopSetting(
        bool, "match preferences", "disable play of the game", true, 3
    ):
        wait(10)

    restartMatch()


rule "loops":
    @Delimiter
    @Disabled


rule " • rainbow color":
    @Condition isGameInProgress()

    # * based on u/Halex000's RGB rainbow cycling HUD text (code CZ97D)
    ChaseColor(green, 255)
    ChaseColor(blue, 0)
    ChaseColor(red, 255)
    ChaseColor(green, 0)
    ChaseColor(blue, 255)
    ChaseColor(red, 0)

    goto RULE_START


rule " • reset spectator camera angle":
    @Condition angle == -10000

    angle = 0


rule "player":
    @Delimiter
    @Disabled


rule " • kick banned player":
    @Event eachPlayer
    @Condition "{}".format(eventPlayer) in banList

    removeFromGame(eventPlayer)


rule " • player died":
    @Event playerDied

    eventPlayer.baseVars[baseVarsI.baseInRadiusOf] = null
    eventPlayer.baseVars[baseVarsI.baseSettledIn] = null

    if (
        not eventPlayer.prefs[prefsI.playerMode]
        and eventPlayer.prefs[prefsI.baseMode] == baseModesI.arena
    ):
        eventPlayer.prefs[prefsI.playerMode] = 1
        async(UpdateHero, AsyncBehavior.RESTART)

    if eventPlayer.baseVector and eventPlayer.prefs[prefsI.instantRespawn]:
        eventPlayer.respawn()

    waitUntil(eventPlayer.isAlive(), 99999)

    if eventPlayer.baseVector:
        wait(0.1)
        eventPlayer.teleport(eventPlayer.baseVector)
        eventPlayer.baseVars[baseVarsI.settleImmediately] = true


rule " • player spawned":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()

    if eventPlayer.baseVector:
        wait(0.1)

        if eventPlayer.miscVars[miscVarsI.lastPosDir]:
            eventPlayer.teleport(eventPlayer.miscVars[miscVarsI.lastPosDir][0])
            eventPlayer.setFacing(eventPlayer.miscVars[miscVarsI.lastPosDir][1], Relativity.TO_WORLD)
            eventPlayer.miscVars[miscVarsI.lastPosDir] = null
        else:
            eventPlayer.teleport(eventPlayer.baseVector)
        eventPlayer.baseVars[baseVarsI.settleImmediately] = true
        eventPlayer.startForcingPosition(eventPlayer.getPosition(), false)
        wait(0.5)
        eventPlayer.stopForcingPosition()


rule " • switch spectated player":
    @Event eachPlayer
    @Condition eventPlayer.miscVars[miscVarsI.playerInFocus].isAlive()
    @Condition eventPlayer.prefs[prefsI.spectatorMode]

    eventPlayer.miscVars[miscVarsI.playerInFocus] = random.choice(
        [
            player
            for player in getAllPlayers()
            if player.hasSpawned()
            and not player.statusVars[statusVarsI.isInvisible]
            and not (
                eventPlayer.getCurrentHero() == Hero.SOMBRA
                and eventPlayer.isUsingAbility1()
            )
        ]
    )

    SpectatorCam()

    waitUntil(
        not eventPlayer.prefs[prefsI.spectatorMode]
        or not eventPlayer.miscVars[miscVarsI.playerInFocus].hasSpawned()
        or eventPlayer.miscVars[miscVarsI.playerInFocus].statusVars[statusVarsI.isInvisible]
        or (eventPlayer.getCurrentHero() == Hero.SOMBRA and eventPlayer.isUsingAbility1()),
        eventPlayer.prefs[prefsI.spectatorSwitchTimer]
    )

    if RULE_CONDITION:
        goto RULE_START


rule " • reset AFK timer":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.spectateOnAFK] > 0
    @Condition isActive()

    eventPlayer.afkTimer = 0
    eventPlayer.miscVars[miscVarsI.facingDirPrev] = eventPlayer.getFacingDirection()
    wait(1)

    if RULE_CONDITION:
        goto RULE_START


rule " • auto-spectate on AFK":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.spectateOnAFK] > 0
    @Condition eventPlayer.prefs[prefsI.spectateOnAFK] * 60 == eventPlayer.afkTimer

    if (
        eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.prefs[prefsI.spectatorMode]
    ):
        return

    eventPlayer.prefs[prefsI.spectatorMode] = true
    SpectatorMode()


rule " • keyboard mode":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.keyboardMode]
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.miscVars[miscVarsI.keyboardChar] = [
        char
        for char in KEY_DATA
        if char[1]
        < angleDifference(
            horizontalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        + char[3]
        + 1.25
        and char[1]
        > angleDifference(
            horizontalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        - char[3]
        - 1.25
        and char[2]
        < angleDifference(
            verticalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getVerticalFacingAngle()
        )
        + 1.25
        and char[2]
        > angleDifference(
            verticalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getVerticalFacingAngle()
        )
        - 1.25
    ][0][0]

    if eventPlayer.miscVars[miscVarsI.keyboardChar]:
        if eventPlayer.miscVars[miscVarsI.keyboardChar] == "back":
            eventPlayer.prefs[prefsI.customMessage] = eventPlayer.prefs[
                prefsI.customMessage
            ].substring(
                0, strLen(eventPlayer.prefs[prefsI.customMessage]) - 1
            )

            waitUntil(not eventPlayer.isHoldingButton(Button.PRIMARY_FIRE), 0.6)

            if eventPlayer.isHoldingButton(Button.PRIMARY_FIRE):
                eventPlayer.prefs[prefsI.customMessage] = ""
        elif eventPlayer.miscVars[miscVarsI.keyboardChar] == "exit":
            eventPlayer.modeVars[modeVarsI.keyboardMode] = false
            eventPlayer.enableHeroHud()
            eventPlayer.clearStatusEffect(Status.ROOTED)
            eventPlayer.setFacing(
                eventPlayer.miscVars[miscVarsI.lastPosDir][1], Relativity.TO_WORLD
            )
            async(UpdateHero, AsyncBehavior.RESTART)
            ResetCam()
            eventPlayer.miscVars[miscVarsI.lastPosDir] = null
        else:
            eventPlayer.prefs[prefsI.customMessage] = "{}{}".format(
                eventPlayer.prefs[prefsI.customMessage],
                eventPlayer.miscVars[miscVarsI.keyboardChar]
            )


rule " • keyboard mode • cursor bounds":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.keyboardMode]

    if (
        angleDifference(
            horizontalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        > 43.5
    ):
        eventPlayer.setFacing(
            angleToDirection(
                horizontalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]) + 43.5,
                eventPlayer.getVerticalFacingAngle()
            ),
            Relativity.TO_WORLD
        )
    if (
        angleDifference(
            horizontalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getHorizontalFacingAngle()
        )
        < -43.5
    ):
        eventPlayer.setFacing(
            angleToDirection(
                horizontalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]) - 43.5,
                eventPlayer.getVerticalFacingAngle()
            ),
            Relativity.TO_WORLD
        )
    if (
        angleDifference(
            verticalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getVerticalFacingAngle()
        )
        > 27
    ):
        eventPlayer.setFacing(
            angleToDirection(
                eventPlayer.getHorizontalFacingAngle(),
                verticalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]) + 27
            ),
            Relativity.TO_WORLD
        )
    if (
        angleDifference(
            verticalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]),
            eventPlayer.getVerticalFacingAngle()
        )
        < -21.7
    ):
        eventPlayer.setFacing(
            angleToDirection(
                eventPlayer.getHorizontalFacingAngle(),
                verticalAngleOfDirection(eventPlayer.miscVars[miscVarsI.lastPosDir][1]) - 21.7
            ),
            Relativity.TO_WORLD
        )

    wait(0.15)

    if RULE_CONDITION:
        goto RULE_START


rule " • third-person mode • ADS":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.thirdPersonMode]
    @Condition (
        isCurrOrDupHero(Hero.ANA)
        or isCurrOrDupHero(Hero.ASHE)
        or isCurrOrDupHero(Hero.WIDOWMAKER)
    )
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if (
        eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.statusVars[statusVarsI.isInvisible]
    ):
        return

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.isDead(),
        99999
    )

    ResetCam()


rule " • third-person mode • ultimate":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.thirdPersonMode]
    @Condition isCurrOrDupHero(Hero.BASTION) or isCurrOrDupHero(Hero.JUNKRAT)
    @Condition eventPlayer.isUsingUltimate()

    if (
        eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.prefs[prefsI.spectatorMode]
    ):
        return

    eventPlayer.stopCamera()

    waitUntil(
        not eventPlayer.isUsingUltimate()
        or eventPlayer.modeVars[modeVarsI.modMode],
        99999
    )

    ResetCam()


rule " • self-sleep":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.selfSleep]
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    if (
        eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    ):
        return

    if eventPlayer.statusVars[statusVarsI.isAsleep]:
        eventPlayer.progressHUD[progressHUDI.text] = "waking up..."
    else:
        eventPlayer.progressHUD[progressHUDI.text] = "sleeping..."

    eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.prefs[prefsI.heroOutlineColor]
    chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or not eventPlayer.prefs[prefsI.playerMode]
        or not eventPlayer.prefs[prefsI.selfSleep]
        or not eventPlayer.isHoldingButton(Button.CROUCH)
        or not eventPlayer.isHoldingButton(Button.MELEE)
        or eventPlayer.isDead(),
        0.6
    )

    if eventPlayer.progress == 100:
        if eventPlayer.statusVars[statusVarsI.isAsleep]:
            eventPlayer.statusVars[statusVarsI.isAsleep] = false
            if not eventPlayer.statusVars[statusVarsI.isAsleepMod]:
                eventPlayer.clearStatusEffect(Status.ASLEEP)
        else:
            eventPlayer.statusVars[statusVarsI.isAsleep] = true

    stopChasingVariable(eventPlayer.progress)
    eventPlayer.progress = 0


rule " • keep slept player asleep":
    @Event eachPlayer
    @Condition (
        eventPlayer.statusVars[statusVarsI.isAsleepMod]
        or eventPlayer.statusVars[statusVarsI.isAsleep]
    )
    @Condition not eventPlayer.hasStatusEffect(Status.ASLEEP)

    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        eventPlayer.setStatusEffect(null, Status.ASLEEP, 99999)
        async(UpdateHero, AsyncBehavior.RESTART)
    else:
        eventPlayer.setStatusEffect(null, Status.ASLEEP, 99999)

    wait(0.1)

    if RULE_CONDITION:
        goto RULE_START


rule "moderator":
    @Delimiter
    @Disabled


rule " • toggle moderator mode":
    @Event eachPlayer
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if (
        not eventPlayer in modList.concat(hostPlayer)
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or eventPlayer.modeVars[modeVarsI.createMode]
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.prefs[prefsI.spectatorMode]
    ):
        return

    if eventPlayer.modeVars[modeVarsI.modMode]:
        eventPlayer.modeVars[modeVarsI.modMode] = false
        eventPlayer.miscVars[miscVarsI.playerInFocus] = null
        ResetCam()
    else:
        eventPlayer.modeVars[modeVarsI.modMode] = true
        if eventPlayer.getPlayerClosestToReticle(Team.ALL):
            eventPlayer.miscVars[miscVarsI.playerInFocus] = eventPlayer.getPlayerClosestToReticle(Team.ALL)
        else:
            eventPlayer.miscVars[miscVarsI.playerInFocus] = getAllPlayers()[0]
        ThirdPersonSpecCam()

    async(UpdateAbilities, AsyncBehavior.RESTART)


rule " • switch focused player":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.JUMP) or not eventPlayer.miscVars[miscVarsI.playerInFocus] in getAllPlayers()

    if not eventPlayer.miscVars[miscVarsI.playerInFocus] in getAllPlayers():
        eventPlayer.miscVars[miscVarsI.playerInFocus] = eventPlayer

        smallMessage(eventPlayer, "player left, switching to you")
    elif (
        getNumberOfPlayers(Team.ALL)
        < getAllPlayers().index(eventPlayer.miscVars[miscVarsI.playerInFocus]) + 2
    ):
        eventPlayer.miscVars[miscVarsI.playerInFocus] = getAllPlayers()[0]
    else:
        eventPlayer.miscVars[miscVarsI.playerInFocus] = getAllPlayers()[
            getAllPlayers().index(eventPlayer.miscVars[miscVarsI.playerInFocus]) + 1
        ]

    ThirdPersonSpecCam()


rule " • sleep / wake up player":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if (
        eventPlayer.miscVars[miscVarsI.playerInFocus]
        in modList.concat(hostPlayer)
        or eventPlayer.miscVars[miscVarsI.playerInFocus].isDead()
        or not eventPlayer.miscVars[miscVarsI.playerInFocus].hasSpawned()
    ):
        DebuffPlayerOnFocus()
        if eventPlayer.miscVars[miscVarsI.playerInFocus].hasStatusEffect(Status.ASLEEP):
            smallMessage(
                eventPlayer,
                "   {}  you can't wake this player up".format(iconString(Icon.WARNING))
            )
        else:
            smallMessage(
                eventPlayer,
                "   {}  you can't sleep this player".format(iconString(Icon.WARNING))
            )
    else:
        if eventPlayer.miscVars[miscVarsI.playerInFocus].statusVars[statusVarsI.isAsleepMod]:
            eventPlayer.miscVars[miscVarsI.playerInFocus].statusVars[
                statusVarsI.isAsleepMod
            ] = false
            if not eventPlayer.miscVars[miscVarsI.playerInFocus].statusVars[statusVarsI.isAsleep]:
                eventPlayer.miscVars[miscVarsI.playerInFocus].clearStatusEffect(Status.ASLEEP)
            smallMessage(
                eventPlayer, "   {}  player woken up".format(iconString(Icon.CHECKMARK))
            )
            BuffPlayer()
        else:
            eventPlayer.miscVars[miscVarsI.playerInFocus].statusVars[
                statusVarsI.isAsleepMod
            ] = true
            if eventPlayer.miscVars[miscVarsI.playerInFocus] != eventPlayer:
                smallMessage(
                    eventPlayer.miscVars[miscVarsI.playerInFocus],
                    "   {}  put to sleep by a moderator".format(
                        abilityIconString(Hero.ANA, Button.ABILITY_1)
                    )
                )
            smallMessage(
                eventPlayer,
                "   {}  player put to sleep".format(
                    abilityIconString(Hero.ANA, Button.ABILITY_1)
                )
            )
            DebuffFocus()

    wait(0.5)


rule " • teleport player to you":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer.miscVars[miscVarsI.playerInFocus] == eventPlayer or eventPlayer.miscVars[
        miscVarsI.playerInFocus
    ] in modList.concat(hostPlayer):
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "   {}  you can't teleport this player to you".format(iconString(Icon.WARNING))
        )
    else:
        eventPlayer.progressHUD[progressHUDI.text] = "teleporting {} {} to you...".format(
            heroIcon(eventPlayer.miscVars[miscVarsI.playerInFocus].getCurrentHero()),
            eventPlayer.miscVars[miscVarsI.playerInFocus]
        )
        eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.miscVars[
            miscVarsI.playerInFocus
        ].prefs[prefsI.heroOutlineColor]
        chase(eventPlayer.progress, 100, duration=0.6, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.INTERACT)
            or not eventPlayer.miscVars[miscVarsI.playerInFocus].hasSpawned(),
            0.6
        )

        if eventPlayer.progress == 100:
            eventPlayer.miscVars[miscVarsI.playerInFocus].teleport(eventPlayer.getPosition())
            BuffFocus()
            smallMessage(
                eventPlayer.miscVars[miscVarsI.playerInFocus],
                "   {}  teleported by moderator".format(
                    abilityIconString(Hero.SOMBRA, Button.ABILITY_2)
                )
            )
            smallMessage(
                eventPlayer,
                "   {}  player teleported".format(
                    abilityIconString(Hero.SOMBRA, Button.ABILITY_2)
                )
            )

        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0

    wait(0.5)


rule " • teleport to player":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)

    if (
        eventPlayer.miscVars[miscVarsI.playerInFocus] == eventPlayer
        or not eventPlayer.miscVars[miscVarsI.playerInFocus].hasSpawned()
    ):
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "   {}  you can't teleport to this player".format(iconString(Icon.WARNING))
        )
    else:
        eventPlayer.progressHUD[progressHUDI.text] = "teleporting to {} {}...".format(
            heroIcon(eventPlayer.miscVars[miscVarsI.playerInFocus].getCurrentHero()),
            eventPlayer.miscVars[miscVarsI.playerInFocus]
        )
        eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.miscVars[
            miscVarsI.playerInFocus
        ].prefs[prefsI.heroOutlineColor]
        chase(eventPlayer.progress, 100, duration=0.6, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.ULTIMATE)
            or not eventPlayer.miscVars[miscVarsI.playerInFocus].hasSpawned(),
            0.6
        )

        if eventPlayer.progress == 100:
            eventPlayer.teleport(eventPlayer.miscVars[miscVarsI.playerInFocus].getPosition())
            BuffFocus()
            smallMessage(
                eventPlayer,
                "   {}  teleported to player".format(
                    abilityIconString(Hero.SOMBRA, Button.ABILITY_2)
                )
            )

        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0

    wait(0.5)


rule " • kill player":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if (
        eventPlayer.miscVars[miscVarsI.playerInFocus]
        in modList.concat(hostPlayer).exclude(eventPlayer)
        or eventPlayer.miscVars[miscVarsI.playerInFocus].isDead()
        or not eventPlayer.miscVars[miscVarsI.playerInFocus].hasSpawned()
    ):
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer, "   {}  you can't kill this player".format(iconString(Icon.WARNING))
        )
    else:
        # temporarily allow damage if player is on chill or zen mode
        if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[prefsI.playerMode]:
            eventPlayer.miscVars[miscVarsI.playerInFocus].setDamageReceived(100)
        # temporarily disable base protection if needed
        if eventPlayer.miscVars[miscVarsI.playerInFocus].hasStatusEffect(Status.PHASED_OUT):
            eventPlayer.miscVars[miscVarsI.playerInFocus].clearStatusEffect(
                Status.PHASED_OUT
            )
            kill(eventPlayer.miscVars[miscVarsI.playerInFocus], null)
            eventPlayer.miscVars[miscVarsI.playerInFocus].setStatusEffect(
                null, Status.PHASED_OUT, 99999
            )
        else:
            kill(eventPlayer.miscVars[miscVarsI.playerInFocus], null)
        if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[prefsI.playerMode]:
            eventPlayer.miscVars[miscVarsI.playerInFocus].setDamageReceived(0)
        DebuffFocus()
        if eventPlayer.miscVars[miscVarsI.playerInFocus] != eventPlayer:
            smallMessage(
                eventPlayer.miscVars[miscVarsI.playerInFocus],
                "   {}  killed by moderator".format(iconString(Icon.SKULL))
            )
        smallMessage(eventPlayer, "   {}  player killed".format(iconString(Icon.SKULL)))

    wait(1)


rule " • delete base":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer.miscVars[miscVarsI.playerInFocus] in modList.concat(hostPlayer).exclude(
        eventPlayer
    ):
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "   {}  you can't delete this player's base".format(iconString(Icon.WARNING))
        )
    elif not eventPlayer.miscVars[miscVarsI.playerInFocus].baseVector:
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "   {}  this player doesn't have a base".format(iconString(Icon.WARNING))
        )
    else:
        eventPlayer.progressHUD[progressHUDI.text] = "deleting {} {}'s base...".format(
            heroIcon(eventPlayer.miscVars[miscVarsI.playerInFocus].getCurrentHero()),
            eventPlayer.miscVars[miscVarsI.playerInFocus]
        )
        eventPlayer.progressHUD[progressHUDI.color] = colorsI.red

        chase(eventPlayer.progress, 100, duration=1, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.ABILITY_1)
            or not eventPlayer.miscVars[miscVarsI.playerInFocus].baseVector,
            1
        )

        if eventPlayer.progress == 100:
            eventPlayer.miscVars[miscVarsI.playerInFocus].baseVars[
                baseVarsI.baseInRadiusOf
            ] = null
            eventPlayer.miscVars[miscVarsI.playerInFocus].baseVars[
                baseVarsI.baseSettledIn
            ] = null
            eventPlayer.miscVars[miscVarsI.playerInFocus].baseVector = null
            DebuffFocus()
            if eventPlayer.miscVars[miscVarsI.playerInFocus] != eventPlayer:
                smallMessage(
                    eventPlayer.miscVars[miscVarsI.playerInFocus],
                    "   {}  base deleted by moderator".format(iconString(Icon.TRASHCAN))
                )
            smallMessage(eventPlayer, "   {}  base deleted".format(iconString(Icon.TRASHCAN)))

        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0

    wait(0.5)


rule " • ban player":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer.isHoldingButton(Button.MELEE)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.INTERACT)
    @Condition not eventPlayer.isHoldingButton(Button.ULTIMATE)

    if eventPlayer.miscVars[miscVarsI.playerInFocus] in modList.concat(hostPlayer):
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "   {}  you can't ban this player".format(iconString(Icon.WARNING))
        )
    else:
        eventPlayer.modVars[modVarsI.nameToBan] = "{}".format(
            eventPlayer.miscVars[miscVarsI.playerInFocus]
        )

        eventPlayer.progressHUD[progressHUDI.text] = "banning {}...".format(
            eventPlayer.modVars[modVarsI.nameToBan]
        )
        eventPlayer.progressHUD[progressHUDI.color] = colorsI.red

        chase(eventPlayer.progress, 100, duration=1.5, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.MELEE),
            1.5
        )

        if eventPlayer.progress == 100:
            banList.append(eventPlayer.modVars[modVarsI.nameToBan])
            DebuffPlayerOnFocus()
            smallMessage(eventPlayer, "   {}  player banned".format(iconString(Icon.CROSS)))

        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0
        eventPlayer.modVars[modVarsI.nameToBan] = null

    wait(0.5)


rule " • promote / demote player":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.modMode]
    @Condition eventPlayer == hostPlayer
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    if eventPlayer.miscVars[miscVarsI.playerInFocus] == hostPlayer:
        DebuffPlayerOnFocus()
        smallMessage(
            eventPlayer,
            "   {}  you can't promote / demote yourself".format(iconString(Icon.WARNING))
        )
    elif eventPlayer.miscVars[miscVarsI.playerInFocus] in modList:
        modList.remove(eventPlayer.miscVars[miscVarsI.playerInFocus])
        DebuffFocus()
        smallMessage(
            eventPlayer, "   {}  player demoted".format(iconString(Icon.ARROW_DOWN))
        )
        bigMessage(eventPlayer.miscVars[miscVarsI.playerInFocus], "you were demoted.")
    else:
        modList.append(eventPlayer.miscVars[miscVarsI.playerInFocus])
        BuffFocus()
        smallMessage(
            eventPlayer, "   {}  player promoted to moderator".format(iconString(Icon.BOLT))
        )
        bigMessage(
            eventPlayer.miscVars[miscVarsI.playerInFocus], "you were promoted to moderator!"
        )

    wait(0.5)


rule "base":
    @Delimiter
    @Disabled


rule " • base preparation":
    @Event eachPlayer
    @Condition not eventPlayer.baseVector
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.modeVars[modeVarsI.createMode]:
        eventPlayer.modeVars[modeVarsI.createMode] = false
        async(UpdateAbilities, AsyncBehavior.RESTART)
    else:
        eventPlayer.progressHUD[progressHUDI.text] = "preparing base..."
        eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.prefs[prefsI.baseColor]
        chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.INTERACT)
            or eventPlayer.isDead()
            or eventPlayer.modeVars[modeVarsI.modMode],
            0.6
        )

        if eventPlayer.progress == 100:
            eventPlayer.prefs[prefsI.baseSize] = defaultPrefs[
                prefsI.baseSize
            ]
            eventPlayer.baseVars[baseVarsI.baseSizePrev] = eventPlayer.prefs[prefsI.baseSize]
            eventPlayer.baseVars[baseVarsI.basePaddingPrev] = eventPlayer.prefs[prefsI.basePadding]
            eventPlayer.modeVars[modeVarsI.createMode] = true
            async(UpdateAbilities, AsyncBehavior.RESTART)

        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0


rule " • base creation":
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.createMode]
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if any(
        [
            player.baseVector
            and distance(eventPlayer.getPosition(), player.baseVector)
            <= player.prefs[prefsI.baseSize]
            + eventPlayer.prefs[prefsI.baseSize]
            + max(
                player.prefs[prefsI.basePadding],
                eventPlayer.prefs[prefsI.basePadding]
            )
            for player in getAllPlayers()
        ]
    ):
        DebuffPlayer()
        smallMessage(eventPlayer, "   {}  can't place a base here".format(iconString(Icon.WARNING)))
    else:
        if eventPlayer.isInAir():
            if createWorkshopSetting(
                bool, "game preferences", "allow floating bases", true, 1
            ):
                StopMomentum()

                if createWorkshopSetting(
                    bool,
                    "game preferences",
                    "adjust floating bases automatically (disable gravity, enable base lock)",
                    false,
                    2
                ):
                    eventPlayer.prefs[prefsI.inBaseGravity] = 0
                    eventPlayer.prefs[prefsI.baseLock] = true

                    smallMessage(
                        eventPlayer,
                        "   {}  disabled gravity and enabled base lock".format(iconString(Icon.CHECKMARK))
                    )
            else:
                DebuffPlayer()
                smallMessage(eventPlayer, "   {}  floating bases aren't allowed".format(iconString(Icon.WARNING)))

                return

        eventPlayer.baseVector = eventPlayer.getPosition()
        async(BackupPlayer, AsyncBehavior.NOOP)

        eventPlayer.baseVars[baseVarsI.settleImmediately] = true
        eventPlayer.modeVars[modeVarsI.createMode] = false

        eventPlayer.allowButton(Button.PRIMARY_FIRE)

        # display tips
        smallMessage(eventPlayer, "   {}  base created successfully".format(iconString(Icon.CHECKMARK)))


rule " • base creation • third-person mode quick switch":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.modeVars[modeVarsI.createMode]
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if eventPlayer.prefs[prefsI.thirdPersonMode]:
        eventPlayer.prefs[prefsI.thirdPersonMode] = false
    else:
        eventPlayer.prefs[prefsI.thirdPersonMode] = true

    ResetCam()


rule " • base detection / confinement":
    @Event eachPlayer
    @Condition isInDiffBase()

    if isConfined():
        async(Confine, AsyncBehavior.RESTART)
        return

    eventPlayer.baseVars[baseVarsI.baseInRadiusOf] = ([
        player for player in getAllPlayers() if player.baseVector
        and eventPlayer in getPlayersInRadius(
            player.baseVector,
            player.prefs[prefsI.baseSize],
            Team.ALL,
            LosCheck.OFF
    )])[0]

    if not eventPlayer.baseVars[baseVarsI.baseInRadiusOf]:
        eventPlayer.baseVars[baseVarsI.settleImmediately] = false

    async(UpdateHero, AsyncBehavior.RESTART)


rule " • base settlement / mode change":
    @Event eachPlayer
    @Condition (
        eventPlayer.baseVars[baseVarsI.baseInRadiusOfPrev] != eventPlayer.baseVars[baseVarsI.baseInRadiusOf]
        or eventPlayer.baseVars[baseVarsI.baseModePrev]
        != eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseMode]
    )

    eventPlayer.baseVars[baseVarsI.baseInRadiusOfPrev] = eventPlayer.baseVars[baseVarsI.baseInRadiusOf]
    eventPlayer.baseVars[baseVarsI.baseModePrev] = eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[
        prefsI.baseMode
    ]

    if eventPlayer.baseVars[baseVarsI.baseInRadiusOf] == eventPlayer:
        if eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer:
            async(UpdateHero, AsyncBehavior.RESTART)
            return
        async(SettleInOwn, AsyncBehavior.RESTART)
    else:
        switch eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseMode]:
            case baseModesI.friendly:
                async(SettleInFriendly, AsyncBehavior.RESTART)
                break
            case baseModesI.exclusive:
                async(Repel, AsyncBehavior.RESTART)
                break
            case baseModesI.arena:
                async(SettleInArena, AsyncBehavior.RESTART)
                break

    eventPlayer.baseVars[baseVarsI.baseSettledIn] = null


rule " • base preferences change":
    @Event eachPlayer
    @Condition eventPlayer.baseVars[baseVarsI.baseInRadiusOf] != eventPlayer
    @Condition (
        eventPlayer.baseVars[baseVarsI.basePrefsPrev]
        != eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs.slice(
            prefsI.inBaseGravity, 2
        )
    )

    eventPlayer.baseVars[baseVarsI.basePrefsPrev] = eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs.slice(
        prefsI.inBaseGravity, 2
    )

    async(UpdateHero, AsyncBehavior.RESTART)


rule " • switch hero":
    @Event eachPlayer
    @Condition eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer
    @Condition not eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    if (
        eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.prefs[prefsI.spectatorMode]
        or eventPlayer.hasStatusEffect(Status.ASLEEP)
    ):
        return

    eventPlayer.progressHUD[progressHUDI.text] = "entering hero picker..."
    eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.prefs[prefsI.baseColor]
    chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.RELOAD)
        or eventPlayer.baseVars[baseVarsI.baseSettledIn] != eventPlayer
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or eventPlayer.modeVars[modeVarsI.modMode],
        0.6
    )

    if eventPlayer.progress == 100:
        eventPlayer.miscVars[miscVarsI.lastPosDir] = [
            eventPlayer.getPosition(),
            eventPlayer.getFacingDirection(),
        ]
        eventPlayer.setAllowedHeroes(
            getAllHeroes().exclude(eventPlayer.getCurrentHero())
        )
        eventPlayer.resetHeroAvailability()
    stopChasingVariable(eventPlayer.progress)
    eventPlayer.progress = 0
    wait(0.1)


rule " • pack base":
    @Event eachPlayer
    @Condition eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer
    @Condition not eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    if eventPlayer.modeVars[modeVarsI.keyboardMode] or eventPlayer.modeVars[modeVarsI.modMode] or eventPlayer.prefs[prefsI.spectatorMode]:
        return

    eventPlayer.progressHUD[progressHUDI.text] = "preparing to pack base..."
    eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.prefs[prefsI.baseColor]
    chase(eventPlayer.progress, 100, duration = 1, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.INTERACT)
        or eventPlayer.baseVars[baseVarsI.baseSettledIn] != eventPlayer
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or eventPlayer.modeVars[modeVarsI.modMode],
        1
    )

    if eventPlayer.progress == 100:
        eventPlayer.baseVars[baseVarsI.baseInRadiusOf] = null
        eventPlayer.baseVars[baseVarsI.baseSettledIn] = null
        eventPlayer.baseVector = null
        async(UpdateHero, AsyncBehavior.RESTART)
        async(BackupPlayer, AsyncBehavior.NOOP)

    stopChasingVariable(eventPlayer.progress)
    eventPlayer.progress = 0
    wait(0.1)


rule " • arena forfeit":
    @Event eachPlayer
    @Condition eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode] == baseModesI.arena
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    # disable forfeit in player's own arena and in moderator mode
    if eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer or eventPlayer.modeVars[modeVarsI.modMode]:
        return

    eventPlayer.progressHUD[progressHUDI.text] = "forfeiting..."
    eventPlayer.progressHUD[progressHUDI.color] = colorsI.red

    chase(eventPlayer.progress, 100, duration = 3, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.MELEE)
        or eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer
        or eventPlayer.modeVars[modeVarsI.modMode],
        3
    )

    if eventPlayer.progress == 100:
        kill(eventPlayer, null)

    stopChasingVariable(eventPlayer.progress)

    eventPlayer.progress = 0


rule " • fast travel":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.fastTravel]
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    if not eventPlayer.prefs[prefsI.playerMode]:
        if (
            (
                eventPlayer.baseVars[baseVarsI.baseSettledIn] != eventPlayer
                and eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
                == baseModesI.arena
            ) or not eventPlayer.baseVars[baseVarsI.baseSettledIn]
        ):
            return

    if (
        eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.prefs[prefsI.spectatorMode]
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        or (
            eventPlayer.prefs[prefsI.selfSleep]
            and eventPlayer.isHoldingButton(Button.CROUCH)
        )
    ):
        return

    eventPlayer.baseVars[baseVarsI.baseToFastTravelTo] = friendlyBaseInCrosshair()

    if eventPlayer.baseVars[baseVarsI.baseToFastTravelTo]:
        eventPlayer.progressHUD[progressHUDI.text] = "fast traveling to {} {}'s base...".format(
            heroIcon(eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].getCurrentHero()),
            eventPlayer.baseVars[baseVarsI.baseToFastTravelTo]
        )
        eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].prefs[prefsI.baseColor]
    elif (
        eventPlayer.baseVector
        and eventPlayer.baseVars[baseVarsI.baseInRadiusOf] != eventPlayer
    ):
        eventPlayer.baseVars[baseVarsI.baseToFastTravelTo] = eventPlayer
        eventPlayer.progressHUD[progressHUDI.text] = "fast traveling to your base..."
        eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.prefs[prefsI.baseColor]
    elif (
        eventPlayer.prefs[prefsI.playerMode]
        and eventPlayer.baseVars[baseVarsI.baseSettledIn]
        and eventPlayer.baseVars[baseVarsI.lastPosFastTravel]
    ):
        eventPlayer.progressHUD[progressHUDI.text] = "fast traveling to previous position..."
        eventPlayer.progressHUD[progressHUDI.color] = eventPlayer.prefs[prefsI.baseColor]
        chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

        waitUntil(
            eventPlayer.progress == 100
            or not eventPlayer.isHoldingButton(Button.MELEE)
            or not eventPlayer.baseVars[baseVarsI.baseSettledIn]
            or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
            or (
                eventPlayer.prefs[prefsI.selfSleep]
                and eventPlayer.isHoldingButton(Button.CROUCH)
            )
            or eventPlayer.isDead(),
            0.6
        )

        if eventPlayer.progress == 100:
            eventPlayer.teleport(eventPlayer.baseVars[baseVarsI.lastPosFastTravel])
            eventPlayer.baseVars[baseVarsI.lastPosFastTravel] = null
            BuffPlayer()

        stopChasingVariable(eventPlayer.progress)
        eventPlayer.progress = 0
        return
    else:
        return

    chase(eventPlayer.progress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.progress == 100
        or not eventPlayer.isHoldingButton(Button.MELEE)
        or (
            eventPlayer.baseVars[baseVarsI.baseToFastTravelTo] != eventPlayer
            and eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].prefs[prefsI.baseMode] != 1
        )
        or (
            not eventPlayer.prefs[prefsI.playerMode]
            and not eventPlayer.baseVars[baseVarsI.baseSettledIn]
        )
        or (
            eventPlayer.prefs[prefsI.selfSleep]
            and eventPlayer.isHoldingButton(Button.CROUCH)
        )
        or not eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].baseVector
        or eventPlayer
        in getPlayersInRadius(
            eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].baseVector,
            eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].prefs[prefsI.baseSize],
            Team.ALL,
            LosCheck.OFF
        )
        or eventPlayer.isDead(),
        0.6
    )

    if eventPlayer.progress == 100:
        eventPlayer.baseVars[baseVarsI.lastPosFastTravel] = eventPlayer.getPosition()
        eventPlayer.baseVars[baseVarsI.settleImmediately] = true
        eventPlayer.teleport(eventPlayer.baseVars[baseVarsI.baseToFastTravelTo].baseVector)

    if not (
        eventPlayer.prefs[prefsI.selfSleep]
        and eventPlayer.isHoldingButton(Button.CROUCH)
    ):
        stopChasingVariable(eventPlayer.progress)
    eventPlayer.progress = 0


rule "preferences":
    @Delimiter
    @Disabled


rule " • view / hide preferences":
    @Event eachPlayer
    @Condition eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer
    @Condition distance(
        eventPlayer.getEyePosition()
        + distance(eventPlayer.getEyePosition(), eventPlayer.baseVector)
        * eventPlayer.getFacingDirection(),
        eventPlayer.baseVector
    ) <= CENTER_ORB_RADIUS

    if (
        eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
    ):
        return

    eventPlayer.prefsVars[prefsVarsI.isViewingPrefs] = true
    async(UpdateAbilities, AsyncBehavior.RESTART)
    UpdatePrefsHUD()

    waitUntil(
        distance(
            eventPlayer.getEyePosition()
            + distance(eventPlayer.getEyePosition(), eventPlayer.baseVector)
            * eventPlayer.getFacingDirection(),
            eventPlayer.baseVector
        )
        > CENTER_ORB_RADIUS
        or eventPlayer.baseVars[baseVarsI.baseSettledIn] != eventPlayer
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.prefs[prefsI.spectatorMode]
        or eventPlayer.isCommunicatingEmote(),
        99999
    )

    eventPlayer.prefsVars[prefsVarsI.isViewingPrefs] = false
    async(UpdateAbilities, AsyncBehavior.RESTART)


rule " • jump preferences":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.MELEE)

    if eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.spectatorMode:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = prefsI.spectatorMode
    elif eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.heroOutlineColor:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = prefsI.heroOutlineColor
    elif eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.heroSize:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = prefsI.heroSize
    elif eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.baseMode:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = prefsI.baseMode
    else:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = 0

    ExplodeBase()
    BuffPlayer()
    UpdatePrefsHUD()


rule " • next item":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if eventPlayer.prefsVars[prefsVarsI.prefsPage] < len(PREFS_DATA) - 1:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] += 1
    else:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = 0

    UpdatePrefsHUD()


rule " • previous item":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    if eventPlayer.prefsVars[prefsVarsI.prefsPage] > 0:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] -= 1
    else:
        eventPlayer.prefsVars[prefsVarsI.prefsPage] = len(PREFS_DATA) - 1

    UpdatePrefsHUD()


rule " • next option / increase":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_1)

    if (
        PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.multipleChoice
        or PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.colorPicker
    ):
        if (
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
            < (
                len(COLORS) - (1 if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters] else 2)
                if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.colorPicker
                else len(PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters]) - 1
            )
        ):
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] += 1
        else:
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = 0

        PrefsInteract()
    elif PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.numeric:
        if eventPlayer.isHoldingButton(Button.CROUCH):
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = PREFS_DATA[
                eventPlayer.prefsVars[prefsVarsI.prefsPage]
            ][prefsDataI.parameters][1]

            PrefsInteract()
            goto max
        elif (
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
            < PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters][1]
        ):
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] += PREFS_DATA[
                eventPlayer.prefsVars[prefsVarsI.prefsPage]
            ][prefsDataI.parameters][2]

            PrefsInteract()
        else:
            max:
            ExplodeBase()
            BuffPlayer()
            return

    UpdatePrefsHUD()

    if not eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs]:
        waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_2), 0.6)

    if eventPlayer.isHoldingButton(Button.ABILITY_2):
        if not eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs]:
            eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs] = true
    else:
        if eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs]:
            eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs] = false
        return

    wait(0.12)

    goto RULE_START


rule " • previous option / decrease":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)
    @Condition not eventPlayer.isHoldingButton(Button.ABILITY_2)

    if (
        PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.multipleChoice
        or PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.colorPicker
    ):
        if eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] > 0:
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] -= 1
        else:
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = (
                len(COLORS) - (1 if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters] else 2)
                if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.colorPicker
                else len(PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters]) - 1
            )
        PrefsInteract()
    elif PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.numeric:
        if eventPlayer.isHoldingButton(Button.CROUCH):
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = PREFS_DATA[
                eventPlayer.prefsVars[prefsVarsI.prefsPage]
            ][prefsDataI.parameters][0]

            PrefsInteract()
            goto min
        elif (
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
            > PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters][0]
        ):
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] -= PREFS_DATA[
                eventPlayer.prefsVars[prefsVarsI.prefsPage]
            ][prefsDataI.parameters][2]

            PrefsInteract()
        else:
            min:
            ExplodeBase()
            DebuffPlayer()
            return

    UpdatePrefsHUD()

    if not eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs]:
        waitUntil(not eventPlayer.isHoldingButton(Button.ABILITY_1), 0.6)

    if eventPlayer.isHoldingButton(Button.ABILITY_1):
        if not eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs]:
            eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs] = true
    else:
        if eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs]:
            eventPlayer.prefsVars[prefsVarsI.isAdjustingPrefs] = false
        return

    wait(0.12)

    goto RULE_START


rule " • reset option":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.RELOAD)

    switch PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]:
        case prefsTypeI.multipleChoice:
        case prefsTypeI.numeric:
        case prefsTypeI.colorPicker:
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = defaultPrefs[
                eventPlayer.prefsVars[prefsVarsI.prefsPage]
            ]

            ExplodeBase()
            BuffPlayer()
            PrefsInteract()

            break


rule " • toggle option / interact":
    @Event eachPlayer
    @Condition eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    switch PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]:
        case prefsTypeI.boolean:
            if eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]:
                eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = false
            else:
                eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = true

            PrefsInteract()
            break
        case prefsTypeI.interact:
            PrefsInteract()
            break
        case prefsTypeI.interactHold:
        case prefsTypeI.interactHoldBoolean:
        case prefsTypeI.customMessage:
            chase(
                eventPlayer.interactProgress,
                100,
                duration = PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters],
                ChaseReeval.DESTINATION_AND_DURATION
            )

            waitUntil(
                eventPlayer.interactProgress == 100
                or not eventPlayer.isHoldingButton(Button.INTERACT)
                or not eventPlayer.prefsVars[prefsVarsI.isViewingPrefs],
                PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters]
            )

            if eventPlayer.interactProgress == 100:
                if (
                    PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]
                    == prefsTypeI.interactHoldBoolean
                ):
                    if eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]:
                        eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = false
                    else:
                        eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] = true

                PrefsInteract()

            stopChasingVariable(eventPlayer.interactProgress)

            eventPlayer.interactProgress = 0
            break


rule "hero":
    @Delimiter
    @Disabled


rule " • no cooldowns • primary fire":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)

    eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 0)


rule " • no cooldowns • primary fire (moira)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition isCurrOrDupHero(Hero.MOIRA)
    @Condition eventPlayer.getAbilityResource(Button.PRIMARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.PRIMARY_FIRE, 100)


rule " • no cooldowns • secondary fire":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)

    if isCurrOrDupHero(Hero.SIGMA):
        wait(0.5)

    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0)

    switch eventPlayer.getCurrentHero():
        case Hero.BASTION:
            eventPlayer.cancelPrimaryAction()

    switch eventPlayer.getHeroOfDuplication():
        case Hero.BASTION:
            eventPlayer.cancelPrimaryAction()

rule " • no cooldowns • secondary fire (d.va)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition isCurrOrDupHero(Hero.DVA)
    @Condition eventPlayer.getAbilityResource(Button.SECONDARY_FIRE) < 50

    eventPlayer.setAbilityResource(Button.SECONDARY_FIRE, 100)


rule " • no cooldowns • ability 1":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_1)

    if isCurrOrDupHero(Hero.ECHO):
        wait(0.5)

    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)


rule " • no cooldowns • ability 1 (tracer, symmetra)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition isCurrOrDupHero(Hero.TRACER) or isCurrOrDupHero(Hero.SYMMETRA)
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 3

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)


rule " • no cooldowns • ability 1 (junkrat, zarya)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition isCurrOrDupHero(Hero.ZARYA) or isCurrOrDupHero(Hero.JUNKRAT)
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_1) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_1, 2)


rule " • no cooldowns • ability 2":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2)

    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)

    switch eventPlayer.getCurrentHero():
        case Hero.MOIRA:
            waitUntil(
                eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
                99999
            )
        case Hero.ASHE:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            wait(0.2)

    switch eventPlayer.getHeroOfDuplication():
        case Hero.MOIRA:
            waitUntil(
                eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
                or eventPlayer.isHoldingButton(Button.SECONDARY_FIRE),
                99999
            )
        case Hero.ASHE:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            wait(0.2)

    switch eventPlayer.getCurrentHero():
        case Hero.ANA:
        case Hero.MCCREE:
        case Hero.SOLDIER:
        case Hero.BAPTISTE:
        case Hero.MOIRA:
        case Hero.ASHE:
        case Hero.JUNKRAT:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            eventPlayer.cancelPrimaryAction()

    switch eventPlayer.getHeroOfDuplication():
        case Hero.ANA:
        case Hero.MCCREE:
        case Hero.SOLDIER:
        case Hero.BAPTISTE:
        case Hero.MOIRA:
        case Hero.ASHE:
        case Hero.JUNKRAT:
        case Hero.PHARAH:
        case Hero.KIRIKO:
        case Hero.SOJOURN:
            eventPlayer.cancelPrimaryAction()


rule " • no cooldowns • ability 2 (zarya, reinhardt, brigitte)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition (
        isCurrOrDupHero(Hero.ZARYA)
        or isCurrOrDupHero(Hero.REINHARDT)
        or isCurrOrDupHero(Hero.BRIGITTE)
    )
    @Condition eventPlayer.getAbilityCharge(Button.ABILITY_2) < 2

    eventPlayer.setAbilityCharge(Button.ABILITY_2, 2)


rule " • no cooldowns • crouch":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)

    eventPlayer.setAbilityCooldown(Button.CROUCH, 0)


rule " • no cooldowns • interact":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.INTERACT)

    eventPlayer.setAbilityCooldown(Button.INTERACT, 0)


rule " • no cooldowns • jump":
    @Disabled
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.noCooldowns]
    @Condition eventPlayer.isHoldingButton(Button.JUMP)

    eventPlayer.setAbilityCooldown(Button.JUMP, 0)


rule " • fast reload (clip 0)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.fastReload]
    @Condition eventPlayer.getAmmo(0) <= 3

    eventPlayer.setAmmo(0, eventPlayer.getMaxAmmo(0))


rule " • fast reload (clip 1)":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.fastReload]
    @Condition eventPlayer.getAmmo(1) <= 3

    eventPlayer.setAmmo(1, eventPlayer.getMaxAmmo(1))


rule " • fast ultimate":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.fastUlt]
    @Condition (
        eventPlayer.getUltCharge() < 100
        or eventPlayer.isHoldingButton(Button.ULTIMATE)
    )

    if eventPlayer.prefs[prefsI.infiniteUlt]:
        switch eventPlayer.getCurrentHero():
            case Hero.GENJI:
            case Hero.MCCREE:
            case Hero.MERCY:
            case Hero.MOIRA:
            case Hero.REAPER:
            case Hero.ROADHOG:
            case Hero.SIGMA:
            case Hero.SOJOURN:
            case Hero.SOLDIER:
            case Hero.TORBJORN:
            case Hero.WIDOWMAKER:
            case Hero.WINSTON:
            case Hero.ZENYATTA:
                wait(1)

                if RULE_CONDITION:
                    goto RULE_START
                break

    if eventPlayer.getUltCharge() < 100 / 3:
        eventPlayer.setUltCharge(100 / 3)

        wait(1, Wait.ABORT_WHEN_FALSE)

    if eventPlayer.getUltCharge() < 200 / 3:
        eventPlayer.setUltCharge(200 / 3)

        wait(1, Wait.ABORT_WHEN_FALSE)

    eventPlayer.setUltCharge(100)
    wait(0.5)

    if RULE_CONDITION:
        goto RULE_START


rule " • infinite ultimate":
    @Event eachPlayer
    @Condition eventPlayer.prefs[prefsI.playerMode]
    @Condition eventPlayer.prefs[prefsI.infiniteUlt]
    @Condition not eventPlayer.isUsingUltimate()

    switch eventPlayer.getCurrentHero():
        case Hero.WINSTON:
            eventPlayer.setUltCharge(100)
            eventPlayer.forceButtonPress(Button.ULTIMATE)

            wait(1)

            if (
                eventPlayer.prefs[prefsI.playerMode]
                or eventPlayer.prefs[prefsI.infiniteUlt]
            ):
                goto RULE_START
            break
        case Hero.GENJI:
        case Hero.MCCREE:
        case Hero.MERCY:
        case Hero.MOIRA:
        case Hero.REAPER:
        case Hero.ROADHOG:
        case Hero.SIGMA:
        case Hero.SOJOURN:
        case Hero.SOLDIER:
        case Hero.TORBJORN:
        case Hero.WIDOWMAKER:
        case Hero.WINSTON:
        case Hero.ZENYATTA:
            eventPlayer.setUltCharge(100)
            eventPlayer.forceButtonPress(Button.ULTIMATE)

            wait(1)
            waitUntil(
                not eventPlayer.prefs[prefsI.playerMode]
                or not eventPlayer.prefs[prefsI.infiniteUlt]
                or not eventPlayer.isUsingUltimate(),
                99999
            )

            if RULE_CONDITION:
                goto RULE_START
            break
        default:
            wait(1)

            if RULE_CONDITION:
                goto RULE_START
            break


rule "subroutines":
    @Delimiter
    @Disabled


def UpdateHUD():
    @Name " • update HUD"

    if eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer:
        eventPlayer.onScreenHUD[
            onScreenHUDI.mainInfo
        ] = "look at the center orb to change your preferences"
    elif (
        eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
        == baseModesI.arena
    ):
        eventPlayer.onScreenHUD[
            onScreenHUDI.mainInfo
        ] = "you're in an arena; death is your only escape"
    else:
        eventPlayer.onScreenHUD[
            onScreenHUDI.mainInfo
        ] = "you are currently{} in {} mode".format(
            " invisible"
            if eventPlayer.prefs[prefsI.playerMode]
            and eventPlayer.prefs[prefsI.invisibility]
            else "",
            PREFS_DATA[prefsI.playerMode][prefsDataI.parameters][
                eventPlayer.prefs[prefsI.playerMode]
            ]
        )

    eventPlayer.onScreenHUD[onScreenHUDI.settleInfo] = "entering {}{} {}...".format(
        heroIcon(eventPlayer.baseVars[baseVarsI.baseInRadiusOf].getCurrentHero())
        if eventPlayer.baseVars[baseVarsI.baseInRadiusOf] != eventPlayer
        else "",
        "{}'s".format(eventPlayer.baseVars[baseVarsI.baseInRadiusOf])
        if eventPlayer.baseVars[baseVarsI.baseInRadiusOf] != eventPlayer
        else "your",
        "arena"
        if eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseMode]
        == baseModesI.arena
        else "base"
    )

    if eventPlayer.baseVector:
        eventPlayer.inWorldHUD[inWorldHUDI.baseModeIcon] = BASE_MODE_ICONS[
            eventPlayer.prefs[prefsI.baseMode]
        ]
        eventPlayer.inWorldHUD[inWorldHUDI.baseDescription] = PREFS_DATA[
            prefsI.baseMode
        ][prefsDataI.parameters][eventPlayer.prefs[prefsI.baseMode]]
        if eventPlayer.prefs[prefsI.baseLock]:
            eventPlayer.inWorldHUD[
                inWorldHUDI.baseDescription
            ] = "{} • base lock".format(
                eventPlayer.inWorldHUD[inWorldHUDI.baseDescription]
            )
        if eventPlayer.prefs[prefsI.inBaseGravity] != 100:
            eventPlayer.inWorldHUD[
                inWorldHUDI.baseDescription
            ] = "{} • {} gravity".format(
                eventPlayer.inWorldHUD[inWorldHUDI.baseDescription],
                eventPlayer.prefs[prefsI.inBaseGravity]
            )
        if eventPlayer.prefs[prefsI.inBaseMovementSpeed] != 100:
            eventPlayer.inWorldHUD[
                inWorldHUDI.baseDescription
            ] = "{} • {} speed".format(
                eventPlayer.inWorldHUD[inWorldHUDI.baseDescription],
                eventPlayer.prefs[prefsI.inBaseMovementSpeed]
            )
    else:
        eventPlayer.inWorldHUD[inWorldHUDI.baseModeIcon] = abilityIconString(
            Hero.ZENYATTA, Button.ULTIMATE
        )
        eventPlayer.inWorldHUD[inWorldHUDI.baseDescription] = "none"



def UpdatePrefsHUD():
    @Name " • update preferences HUD"

    # category
    if eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.spectatorMode:
        eventPlayer.prefsHUD[prefsHUDI.category] = "spectator"
        eventPlayer.prefsHUD[prefsHUDI.categoryColor] = colorsI.aqua
    elif eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.heroOutlineColor:
        eventPlayer.prefsHUD[prefsHUDI.category] = "special hero"
        eventPlayer.prefsHUD[prefsHUDI.categoryColor] = colorsI.turquoise
    elif eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.heroSize:
        eventPlayer.prefsHUD[prefsHUDI.category] = "other hero"
        eventPlayer.prefsHUD[prefsHUDI.categoryColor] = colorsI.yellow
    elif eventPlayer.prefsVars[prefsVarsI.prefsPage] < prefsI.baseMode:
        eventPlayer.prefsHUD[prefsHUDI.category] = "base"
        eventPlayer.prefsHUD[prefsHUDI.categoryColor] = colorsI.rose
    else:
        eventPlayer.prefsHUD[prefsHUDI.category] = "game"
        eventPlayer.prefsHUD[prefsHUDI.categoryColor] = colorsI.green

    eventPlayer.prefsHUD[prefsHUDI.counter] = null

    # preference
    switch PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type]:
        case prefsTypeI.multipleChoice:
            eventPlayer.prefsHUD[prefsHUDI.preference] = PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters][eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]]
            eventPlayer.prefsHUD[prefsHUDI.counter] = "{} • {} of {} • {}".format(
                iconString(Icon.ARROW_LEFT),
                eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] + 1,
                len(PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters]),
                iconString(Icon.ARROW_RIGHT)
            )
            break
        case prefsTypeI.colorPicker:
            eventPlayer.prefsHUD[prefsHUDI.preference] = COLORS[eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]]
            eventPlayer.prefsHUD[prefsHUDI.counter] = "{} • {} of {} • {}".format(
                iconString(Icon.ARROW_LEFT),
                eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]] + 1,
                len(COLORS) - (0 if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters] else 1),
                iconString(Icon.ARROW_RIGHT)
            )
            break
        case prefsTypeI.boolean:
            if eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]:
                eventPlayer.prefsHUD[prefsHUDI.preference] = "on"
            else:
                eventPlayer.prefsHUD[prefsHUDI.preference] = "off"
            break
        case prefsTypeI.numeric:
            eventPlayer.prefsHUD[prefsHUDI.preference] = "{}{}".format(
                eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]],
                PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters][3]
                if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters][3]
                else ""
            )
            if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.parameters][3]:
            break
        case prefsTypeI.customMessage:
            eventPlayer.prefsHUD[prefsHUDI.preference] = eventPlayer.prefs[
                prefsI.customMessage
            ]
            break
        default:
            eventPlayer.prefsHUD[prefsHUDI.preference] = ""

    # color
    if (
        not eventPlayer.prefs[prefsI.playerMode]
        and PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.chillZenOnly]
    ):
        eventPlayer.prefsHUD[prefsHUDI.color] = colorsI.gray
    elif PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.type] == prefsTypeI.colorPicker:
        eventPlayer.prefsHUD[prefsHUDI.color] = eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
    elif PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.colors][
        eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
    ]:
        eventPlayer.prefsHUD[prefsHUDI.color] = PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.colors][
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
        ]
    else:
        eventPlayer.prefsHUD[prefsHUDI.color] = colorsI.white

    # description
    if PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.descriptions][
        eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
    ]:
        eventPlayer.prefsHUD[prefsHUDI.description] = PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.descriptions][
            eventPlayer.prefs[eventPlayer.prefsVars[prefsVarsI.prefsPage]]
        ]
    else:
        eventPlayer.prefsHUD[prefsHUDI.description] = PREFS_DATA[eventPlayer.prefsVars[prefsVarsI.prefsPage]][prefsDataI.descriptions]


def UpdateHero():
    @Name " • update hero"

    if eventPlayer.prefs[prefsI.playerMode]:
        eventPlayer.setHealth(eventPlayer.getMaxHealth())
        eventPlayer.setDamageDealt(0)
        eventPlayer.setDamageReceived(0)
        eventPlayer.setHealingDealt(0)
        if eventPlayer.prefs[prefsI.flight]:
            eventPlayer.startAcceleration(
                Vector.UP,
                eventPlayer.prefs[prefsI.flightAccel]
                if eventPlayer.isHoldingButton(Button.JUMP)
                else 0,
                eventPlayer.prefs[prefsI.flightAccel] * 2,
                Relativity.TO_PLAYER,
                AccelReeval.DIRECTION_RATE_AND_MAX_SPEED
            )
        else:
            eventPlayer.stopAcceleration()
        if eventPlayer.prefs[prefsI.heroSize] != 100:
            eventPlayer.startScalingSize(
                eventPlayer.prefs[prefsI.heroSize] / 100, false
            )
        else:
            eventPlayer.stopScalingSize()
        if eventPlayer.prefs[prefsI.noEnvCollision]:
            eventPlayer.disableEnvironmentCollision(false)
        elif eventPlayer.prefs[prefsI.heroSize] > 100:
            eventPlayer.disableEnvironmentCollision(false)
        else:
            eventPlayer.enableEnvironmentCollision()
        eventPlayer.setKnockbackDealt(eventPlayer.prefs[prefsI.knockback])
        if eventPlayer.prefs[prefsI.knockback] > 100:
            eventPlayer.setKnockbackReceived(100)
        else:
            eventPlayer.setKnockbackReceived(10)
        if eventPlayer.prefs[prefsI.invisibility]:
            eventPlayer.setInvisibility(Invis.ENEMIES)
            eventPlayer.statusVars[statusVarsI.isInvisible] = true
        else:
            eventPlayer.setInvisibility(Invis.NONE)
            eventPlayer.statusVars[statusVarsI.isInvisible] = false
        eventPlayer.setProjectileSpeed(eventPlayer.prefs[prefsI.projectileSpeed])
        eventPlayer.setProjectileGravity(eventPlayer.prefs[prefsI.projectileGravity])
    else:
        eventPlayer.setDamageDealt(100)
        eventPlayer.setDamageReceived(100)
        eventPlayer.setHealingDealt(100)
        eventPlayer.stopAcceleration()
        eventPlayer.enableEnvironmentCollision()
        eventPlayer.setInvisibility(Invis.NONE)
        eventPlayer.statusVars[statusVarsI.isInvisible] = false
        eventPlayer.stopScalingSize()
        eventPlayer.setKnockbackDealt(100)
        eventPlayer.setKnockbackReceived(100)
        eventPlayer.setProjectileSpeed(100)
        eventPlayer.setProjectileGravity(100)

    if eventPlayer.baseVars[baseVarsI.baseInRadiusOf]:
        eventPlayer.setGravity(
            eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[
                prefsI.inBaseGravity
            ]
        )
        eventPlayer.setMoveSpeed(
            eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[
                prefsI.inBaseMovementSpeed
            ]
        )
    else:
        if eventPlayer.prefs[prefsI.playerMode]:
            eventPlayer.setGravity(eventPlayer.prefs[prefsI.gravity])
            eventPlayer.setMoveSpeed(eventPlayer.prefs[prefsI.movementSpeed])
        else:
            eventPlayer.setGravity(100)
            eventPlayer.setMoveSpeed(100)

    if eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer:
        if (
            eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
            == baseModesI.arena
        ):
            if (
                eventPlayer.prefs[prefsI.playerMode]
                or eventPlayer.prefs[prefsI.spectatorMode]
            ):
                eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
            else:
                eventPlayer.clearStatusEffect(Status.PHASED_OUT)
        else:
            eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    elif (
        eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
        == baseModesI.friendly
        or (eventPlayer.prefs[prefsI.playerMode] == playerModesI.zen)
        or eventPlayer.prefs[prefsI.spectatorMode]
    ):
        eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 99999)
    elif eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.clearStatusEffect(Status.PHASED_OUT)

    if eventPlayer.hasStatusEffect(Status.PHASED_OUT):
        eventPlayer.startHoT(eventPlayer, 99999, 50)
    else:
        eventPlayer.stopAllHoT()

    UpdateAbilities()
    UpdateHUD()


def UpdateAbilities():
    @Name " • update abilities"

    eventPlayer.allowButton(Button.CROUCH)

    if (
        eventPlayer.modeVars[modeVarsI.modMode]
        or eventPlayer.modeVars[modeVarsI.keyboardMode]
        or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
    ):
        DisableAbilities()
        eventPlayer.disallowButton(Button.CROUCH)
    elif eventPlayer.baseVars[baseVarsI.baseSettledIn] == eventPlayer:
        if (
            eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
            == baseModesI.arena
        ):
            if (
                eventPlayer.prefs[prefsI.playerMode]
                or eventPlayer.prefs[prefsI.spectatorMode]
            ):
                DisableAbilities()
            else:
                EnableAbilities()
        else:
            DisableAbilities()
    elif (
        eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseMode]
        == baseModesI.friendly
        or eventPlayer.prefs[prefsI.playerMode] == playerModesI.zen
        or eventPlayer.prefs[prefsI.spectatorMode]
    ):
        DisableAbilities()
    else:
        EnableAbilities()

    if (
        (
            eventPlayer.prefs[prefsI.playerMode] == playerModesI.zen
            or eventPlayer.baseVars[baseVarsI.baseSettledIn]
        )
        and not (
            eventPlayer.isDuplicatingAHero()
            or eventPlayer.modeVars[modeVarsI.modMode]
            or eventPlayer.modeVars[modeVarsI.keyboardMode]
            or eventPlayer.prefsVars[prefsVarsI.isViewingPrefs]
        )
    ):
        switch eventPlayer.getCurrentHero():
            case Hero.ASHE:
            case Hero.ANA:
                eventPlayer.setSecondaryFireEnabled(true)
                eventPlayer.allowButton(Button.SECONDARY_FIRE)
                break
            case Hero.ORISA:
            case Hero.ECHO:
            case Hero.MEI:
            case Hero.PHARAH:
            case Hero.KIRIKO:
            case Hero.LUCIO:
            case Hero.ZARYA:
            case Hero.BASTION:
            case Hero.SOJOURN:
            case Hero.MOIRA:
            case Hero.MCCREE:
                eventPlayer.setAbility1Enabled(true)
                break
            case Hero.WINSTON:
                eventPlayer.allowButton(Button.ULTIMATE)
                break
            case Hero.REAPER:
            case Hero.SOMBRA:
            case Hero.TRACER:
            case Hero.HANZO:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.allowButton(Button.INTERACT)
                break
            case Hero.SOLDIER:
            case Hero.MERCY:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.allowButton(Button.ULTIMATE)
                break
            case Hero.TORBJORN:
            case Hero.ROADHOG:
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.allowButton(Button.ULTIMATE)
                eventPlayer.allowButton(Button.INTERACT)
                break
            case Hero.WIDOWMAKER:
                eventPlayer.setSecondaryFireEnabled(true)
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.allowButton(Button.SECONDARY_FIRE)
                eventPlayer.allowButton(Button.ULTIMATE)
                break
            case Hero.HAMMOND:
                eventPlayer.setAbility1Enabled(true)
                eventPlayer.setAbility2Enabled(true)
                eventPlayer.disallowButton(Button.CROUCH)


def UpdateAFKTimer():
    @Name " • update AFK timer"

    if eventPlayer.prefs[prefsI.spectateOnAFK] > 0:
        chase(
            eventPlayer.afkTimer,
            eventPlayer.prefs[prefsI.spectateOnAFK] * 60,
            rate = 1,
            ChaseReeval.NONE
        )
        eventPlayer.miscVars[miscVarsI.facingDirPrev] = eventPlayer.getFacingDirection()
    else:
        stopChasingVariable(eventPlayer.afkTimer)
        eventPlayer.miscVars[miscVarsI.facingDirPrev] = null


def DisableAbilities():
    @Name " • disable abilities"

    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.disallowButton(Button.PRIMARY_FIRE)
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.disallowButton(Button.ULTIMATE)
    eventPlayer.disallowButton(Button.INTERACT)


def EnableAbilities():
    @Name " • enable abilities"

    eventPlayer.setSecondaryFireEnabled(true)
    eventPlayer.setMeleeEnabled(true)
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setAbility2Enabled(true)
    eventPlayer.allowButton(Button.PRIMARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.ULTIMATE)
    eventPlayer.allowButton(Button.INTERACT)


def ResetCam():
    @Name " • reset camera"

    if eventPlayer.prefs[prefsI.thirdPersonMode]:
        ThirdPersonCam()
    else:
        eventPlayer.stopCamera()


def ThirdPersonCam():
    @Name " • enable third-person camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        updateEveryTick(
            raycast(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition()
                + (
                    Vector.UP * (eventPlayer.prefs[prefsI.heroSize] / 100)
                    + eventPlayer.getFacingDirection()
                    * (eventPlayer.prefs[prefsI.heroSize] / -20)
                    if eventPlayer.prefs[prefsI.playerMode]
                    else Vector.UP + eventPlayer.getFacingDirection() * -5
                ),
                null,
                eventPlayer,
                false
            ).getHitPosition()
        ),
        updateEveryTick(
            raycast(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 100,
                null,
                eventPlayer,
                false
            ).getHitPosition()
        ),
        0
    )


def ThirdPersonSpecCam():
    @Name " • enable third-person spectator camera"

    # based on "Waitedboat4's Thirdperson Mod" (code 3F79Z)
    eventPlayer.startCamera(
        updateEveryTick(
            raycast(
                eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition(),
                eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition()
                + (
                    Vector.UP
                    * (
                        eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[prefsI.heroSize]
                        / 100
                    )
                    + eventPlayer.miscVars[miscVarsI.playerInFocus].getFacingDirection()
                    * (
                        eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[prefsI.heroSize]
                        / -20
                    )
                    if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                        prefsI.playerMode
                    ]
                    else Vector.UP
                    + eventPlayer.miscVars[miscVarsI.playerInFocus].getFacingDirection()
                    * -5
                ),
                null,
                eventPlayer.miscVars[miscVarsI.playerInFocus],
                false
            ).getHitPosition()
        ),
        updateEveryTick(
            raycast(
                eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition(),
                eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition()
                + eventPlayer.miscVars[miscVarsI.playerInFocus].getFacingDirection() * 100,
                null,
                eventPlayer.miscVars[miscVarsI.playerInFocus],
                false
            ).getHitPosition()
        ),
        0
    )


def SpectatorCam():
    @Name " • enable spectator camera"

    if eventPlayer.prefs[prefsI.clipSpectatorCam]:
        eventPlayer.startCamera(
            updateEveryTick(
                raycast(
                    eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition(),
                    eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition()
                    + vect(
                        evalOnce(eventPlayer.prefs[prefsI.spectatorCamDist])
                        * (
                            (
                                eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                                    prefsI.heroSize
                                ]
                                / 100
                            )
                            if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                                prefsI.playerMode
                            ]
                            else 1
                        )
                        * cosDeg(angle),
                        0,
                        evalOnce(eventPlayer.prefs[prefsI.spectatorCamDist])
                        * (
                            (
                                eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                                    prefsI.heroSize
                                ]
                                / 100
                            )
                            if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                                prefsI.playerMode
                            ]
                            else 1
                        )
                        * sinDeg(angle)
                    ),
                    null,
                    eventPlayer,
                    false
                ).getHitPosition()
            ),
            updateEveryTick(eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition()),
            evalOnce(10 if eventPlayer.prefs[prefsI.smoothSpectatorCam] else 0)
        )
    else:
        eventPlayer.startCamera(
            updateEveryTick(
                eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition()
                + vect(
                    evalOnce(eventPlayer.prefs[prefsI.spectatorCamDist])
                    * (
                        (
                            eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                                prefsI.heroSize
                            ]
                            / 100
                        )
                        if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                            prefsI.playerMode
                        ]
                        else 1
                    )
                    * cosDeg(angle),
                    0,
                    evalOnce(eventPlayer.prefs[prefsI.spectatorCamDist])
                    * (
                        (
                            eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                                prefsI.heroSize
                            ]
                            / 100
                        )
                        if eventPlayer.miscVars[miscVarsI.playerInFocus].prefs[
                            prefsI.playerMode
                        ]
                        else 1
                    )
                    * sinDeg(angle)
                )
            ),
            updateEveryTick(eventPlayer.miscVars[miscVarsI.playerInFocus].getEyePosition()),
            evalOnce(10 if eventPlayer.prefs[prefsI.smoothSpectatorCam] else 0)
        )


def SpectatorMode():
    @Name " • spectator mode"

    eventPlayer.miscVars[miscVarsI.facingDirPrev] = eventPlayer.getFacingDirection()
    eventPlayer.disableHeroHUD()
    UpdateHero()

    waitUntil(isActive(), 99999)

    eventPlayer.prefs[prefsI.spectatorMode] = false
    eventPlayer.enableHeroHud()
    UpdateHero()
    ResetCam()


def Confine():
    @Name " • confine"

    eventPlayer.applyImpulse(
        directionTowards(
            eventPlayer.getPosition(),
            eventPlayer.baseVars[baseVarsI.baseInRadiusOf].baseVector
        ),
        10 if eventPlayer.isOnGround() else 0.00001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )

    if not eventPlayer in getPlayersInRadius(
        eventPlayer.baseVars[baseVarsI.baseSettledIn].baseVector,
        eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseSize] + 3,
        Team.ALL,
        LosCheck.OFF
    ):
        eventPlayer.cancelPrimaryAction()
        eventPlayer.teleport(
            directionTowards(
                eventPlayer.baseVars[baseVarsI.baseSettledIn].baseVector,
                eventPlayer.getPosition()
            )
            * (eventPlayer.baseVars[baseVarsI.baseSettledIn].prefs[prefsI.baseSize])
            + eventPlayer.baseVars[baseVarsI.baseSettledIn].baseVector
        )

    wait(0.1)

    if isInDiffBase():
        if isConfined():
            goto RULE_START


def Repel():
    @Name " • repel"

    eventPlayer.applyImpulse(
        directionTowards(
            eventPlayer.baseVars[baseVarsI.baseInRadiusOf].baseVector,
            eventPlayer.getPosition()
        ),
        10 if eventPlayer.isOnGround() else 0.00001,
        Relativity.TO_WORLD,
        Impulse.CANCEL_CONTRARY_MOTION_XYZ
    )

    wait(0.1)

    if [
        player
        for player in getAllPlayers()
        if player.baseVector
        and eventPlayer
        in getPlayersInRadius(
            player.baseVector, player.prefs[prefsI.baseSize], Team.ALL, LosCheck.OFF
        )
    ][0].prefs[prefsI.baseMode] == baseModesI.exclusive:
        goto RULE_START


def SettleInOwn():
    @Name " • enter own base"

    chase(eventPlayer.baseProgress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.baseProgress == 100
        or eventPlayer.baseVars[baseVarsI.baseInRadiusOf] != eventPlayer
        or eventPlayer.baseVars[baseVarsI.settleImmediately],
        0.6
    )

    if eventPlayer.baseProgress == 100 or eventPlayer.baseVars[baseVarsI.settleImmediately]:
        eventPlayer.baseVars[baseVarsI.baseSettledIn] = eventPlayer.baseVars[
            baseVarsI.baseInRadiusOf
        ]
        eventPlayer.baseVars[baseVarsI.settleImmediately] = false
        async(UpdateHero, AsyncBehavior.RESTART)
        BuffPlayer()

    stopChasingVariable(eventPlayer.baseProgress)
    eventPlayer.baseProgress = 0


def SettleInFriendly():
    @Name " • enter friendly base / waypoint"

    chase(eventPlayer.baseProgress, 100, duration = 0.6, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.baseProgress == 100
        or eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseMode]
        != baseModesI.friendly
        or eventPlayer.baseVars[baseVarsI.settleImmediately]
        or eventPlayer.baseVars[baseVarsI.baseInRadiusOfPrev]
        != eventPlayer.baseVars[baseVarsI.baseInRadiusOf],
        0.6
    )

    if eventPlayer.baseProgress == 100 or eventPlayer.baseVars[baseVarsI.settleImmediately]:
        eventPlayer.baseVars[baseVarsI.baseSettledIn] = eventPlayer.baseVars[
            baseVarsI.baseInRadiusOf
        ]
        eventPlayer.baseVars[baseVarsI.settleImmediately] = false
        UpdateHero()
        BuffPlayer()

    stopChasingVariable(eventPlayer.baseProgress)
    eventPlayer.baseProgress = 0


def SettleInArena():
    @Name " • enter arena"

    chase(eventPlayer.baseProgress, 100, duration = 3, ChaseReeval.NONE)

    waitUntil(
        eventPlayer.baseProgress == 100
        or eventPlayer.baseVars[baseVarsI.baseInRadiusOf].prefs[prefsI.baseMode]
        != baseModesI.arena
        or eventPlayer.baseVars[baseVarsI.baseInRadiusOf] == eventPlayer
        or eventPlayer.baseVars[baseVarsI.baseInRadiusOfPrev]
        != eventPlayer.baseVars[baseVarsI.baseInRadiusOf],
        3
    )

    if eventPlayer.baseProgress == 100:
        eventPlayer.baseVars[baseVarsI.baseSettledIn] = eventPlayer.baseVars[
            baseVarsI.baseInRadiusOf
        ]
        eventPlayer.prefs[prefsI.playerMode] = false
        UpdateHero()
        DebuffPlayer()

    stopChasingVariable(eventPlayer.baseProgress)
    eventPlayer.baseProgress = 0


def PrefsInteract():
    @Name " • preferences interactions"

    switch eventPlayer.prefsVars[prefsVarsI.prefsPage]:
        case prefsI.playerMode:
        case prefsI.flight:
        case prefsI.noEnvCollision:
        case prefsI.invisibility:
        case prefsI.heroSize:
        case prefsI.knockback:
        case prefsI.projectileSpeed:
        case prefsI.projectileGravity:
        case prefsI.inBaseGravity:
        case prefsI.inBaseMovementSpeed:
            async(UpdateHero, AsyncBehavior.RESTART)
            break
        case prefsI.resetPrefs:
            eventPlayer.prefs = defaultPrefs
            eventPlayer.prefs[
                prefsI.baseSize
            ] = eventPlayer.baseVars[baseVarsI.baseSizePrev]
            eventPlayer.prefs[
                prefsI.basePadding
            ] = eventPlayer.baseVars[baseVarsI.basePaddingPrev]
            async(UpdateHero, AsyncBehavior.RESTART)
            ResetCam()
            UpdateHeroOutline()
            UpdateVoicelinePitch()
            UpdateAFKTimer()
            BuffPlayer()
            smallMessage(eventPlayer, "   {}  preferences reset".format(iconString(Icon.CHECKMARK)))
            break
        case prefsI.switchTeam:
            if getCurrentGamemode() == Gamemode.SKIRMISH:
                moveToTeam(eventPlayer, getOppositeTeam(eventPlayer.getTeam()), -1)
            else:
                DebuffPlayer()
                smallMessage(eventPlayer, "   {}  gamemode isn't skirmish".format(iconString(Icon.WARNING)))
            break
        case prefsI.thirdPersonMode:
            ResetCam()
            break
        case prefsI.spectatorMode:
            SpectatorMode()
            break
        case prefsI.spectateOnAFK:
            UpdateAFKTimer()
            break
        case prefsI.customMessage:
            eventPlayer.modeVars[modeVarsI.keyboardMode] = true
            eventPlayer.miscVars[miscVarsI.lastPosDir] = [eventPlayer.getPosition(), vect(
                eventPlayer.getFacingDirection().x,
                0,
                eventPlayer.getFacingDirection().z
            )]
            eventPlayer.disableHeroHUD()
            eventPlayer.setStatusEffect(eventPlayer, Status.ROOTED, 99999)
            eventPlayer.setFacing(
                eventPlayer.miscVars[miscVarsI.lastPosDir][1], Relativity.TO_WORLD
            )
            eventPlayer.setInvisibility(Invis.ALL)
            eventPlayer.statusVars[statusVarsI.isInvisible] = true
            eventPlayer.startCamera(
                eventPlayer.getEyePosition(),
                eventPlayer.getEyePosition() + eventPlayer.miscVars[miscVarsI.lastPosDir][1],
                0
            )
            async(UpdateAbilities, AsyncBehavior.RESTART)
            break
        case prefsI.heroOutlineColor:
            UpdateHeroOutline()
            break
        case prefsI.voicePitch:
            UpdateVoicelinePitch()
            break
        case prefsI.baseSize:
            while any(
                [
                    player != eventPlayer
                    and player.baseVector
                    and distance(eventPlayer.baseVector, player.baseVector)
                    <= player.prefs[prefsI.baseSize] + eventPlayer.prefs[prefsI.baseSize]
                    + max(player.prefs[prefsI.basePadding], eventPlayer.prefs[prefsI.basePadding])
                    for player in getAllPlayers()
                ]
            ):
                eventPlayer.prefs[prefsI.baseSize] -= PREFS_DATA[prefsI.baseSize][
                    prefsDataI.parameters
                ][2]

            eventPlayer.baseVars[baseVarsI.baseSizePrev] = eventPlayer.prefs[
                prefsI.baseSize
            ]
            break
        case prefsI.basePadding:
            while any(
                [
                    player != eventPlayer
                    and player.baseVector
                    and distance(eventPlayer.baseVector, player.baseVector)
                    <= player.prefs[prefsI.baseSize] + eventPlayer.prefs[prefsI.baseSize]
                    + max(player.prefs[prefsI.basePadding], eventPlayer.prefs[prefsI.basePadding])
                    for player in getAllPlayers()
                ]
            ):
                eventPlayer.prefs[prefsI.basePadding] -= PREFS_DATA[prefsI.basePadding][
                    prefsDataI.parameters
                ][2]

            eventPlayer.baseVars[baseVarsI.basePaddingPrev] = eventPlayer.prefs[
                prefsI.basePadding
            ]
            break

    UpdatePrefsHUD()
    async(BackupPlayer, AsyncBehavior.NOOP)


def BackupPlayer():
    @Name " • backup player preferences"

    if playerNameList.index("{}".format(eventPlayer)) < 0:
        playerNameList.append("{}".format(eventPlayer))

    baseVectorList[
        playerNameList.index("{}".format(eventPlayer))
    ] = eventPlayer.baseVector

    prefsList[
        playerNameList.index("{}".format(eventPlayer))
    ] = eventPlayer.prefs

    wait(1)


def HardReset():
    @Name " • hard reset"

    eventPlayer.modVars = null
    eventPlayer.baseVars = null
    eventPlayer.prefsVars = null
    eventPlayer.modeVars = null
    eventPlayer.statusVars = null
    eventPlayer.miscVars = null
    eventPlayer.prefs = null
    eventPlayer.baseVector = null
    eventPlayer.progressHUD = null
    eventPlayer.inWorldHUD = null
    eventPlayer.prefsHUD = null
    eventPlayer.progress = null
    eventPlayer.baseProgress = null
    eventPlayer.interactProgress = null
    eventPlayer.afkTimer = null
